package Moxie;

use v5.20;

use strict;
use warnings;

our $VERSION;
our $AUTHORITY;

use Devel::CallParser;
use XSLoader;
BEGIN {
    $VERSION   = '0.01';
    $AUTHORITY = 'cpan:STEVAN';
    XSLoader::load( __PACKAGE__, $VERSION );
}

use experimental    (); # need this later when we load features
use Module::Runtime ();

use mop;
use mop::internal::util;

use Moxie::Util;
use Moxie::Util::Syntax;

sub mop::object::DOES {
    my ($self, $role) = @_;
    my $class = ref $self || $self;
    # if we inherit from this, we are good ...
    return 1 if $class->isa( $role );
    # next check the roles ...
    my $meta = mop::class->new( name => $class );
    # test just the local (and composed) roles first ...
    return 1 if $meta->does_role( $role );
    # then check the inheritance hierarchy next ...
    return 1 if scalar grep { mop::class->new( name => $_ )->does_role( $role ) } @{ $meta->mro };
    return 0;
}

our %TRAITS;

# TODO:
# Everything that this &import method does should be
# in util subroutines so that someone else can just
# come in and use it sensibly to implement their own
# object system if they want. The idea is that the
# simple, bare bones sugar I provide here is just barely
# one step above the raw version which uses the package
# variables and mop::internal::util::* methods directly
# inside BEGIN blocks, etc.
#
# In short, there is no need to make people jump through
# stupid meta-layer subclass stuff in order to maintain
# a level or purity that perl just doesn't give a fuck
# about anyway. In the 'age of objects' we have forgotten
# that subroutines are also an excellent form of encapsulation
# and re-use.
# - SL

sub import {
    my ($class, @args) = @_;

    # get the caller ...
    my $caller = caller;

    # make the assumption that if we are
    # loaded outside of main then we are
    # likely being loaded in a class, so
    # turn on all the features
    if ( $caller ne 'main' ) {

        # FIXME:
        # There are a lot of assumptions here that
        # we are not loading mop.pm in a package
        # where it might have already been loaded
        # so we might want to keep that in mind
        # and guard against some of that below,
        # in particular I think the FINALIZE handlers
        # might need to be checked, and perhaps the
        # 'has' keyword importation as well.
        # - SL

        # NOTE:
        # create the meta-object, we start
        # with this as a role, but it will
        # get "cast" to a class if there
        # is a need for it.
        my $meta = mop::role->new( name => $caller );

        # install our finalizer feature ...
        mop::internal::util::INSTALL_FINALIZATION_RUNNER( $caller );

        # turn on strict/warnings
        strict->import;
        warnings->import;

        # turn on signatures and more
        experimental->import($_) foreach qw[
            signatures

            postderef
            postderef_qq

            current_sub
            lexical_subs

            say
            state
        ];

        # turn on refaliasing if we have it ...
        experimental->import('refaliasing') if $] >= 5.022;

        # import has, extend and with keyword
        Moxie::Util::Syntax::setup_keyword_handler(
            ($caller, 'has') => sub {
                my ($name, %traits) = @_;

                # this is the only one we handle
                # specially, everything else gets
                # called as a trait ...
                $traits{default} //= delete $traits{required}
                    ? eval 'package '.$caller.'; sub { die "[mop::ERROR] The attribute \'$name\' is required" }'
                    : eval 'package '.$caller.'; sub { undef }'; # we need this to be a unique CV ... sigh

                $meta->add_attribute( $name, delete $traits{default} );

                if ( keys %traits ) {
                    my $attr = $meta->get_attribute( $name );
                    foreach my $k ( keys %traits ) {
                        die "[mop::PANIC] Cannot locate trait ($k) to apply to attributes ($name)"
                            unless exists $TRAITS{ $k };
                        $TRAITS{ $k }->( $meta, $attr, $traits{ $k } );
                    }
                }
                return;
            }
        );

        Moxie::Util::Syntax::setup_keyword_handler(
            ($caller, 'extends') => sub {
                my @isa = @_;
                Module::Runtime::use_package_optimistically( $_ ) foreach @isa;
                ($meta->isa('mop::class')
                    ? $meta
                    : (bless $meta => 'mop::class') # cast into class
                )->set_superclasses( @isa );
                return;
            }
        );

        Moxie::Util::Syntax::setup_keyword_handler(
            ($caller, 'with') => sub {
                my @does = @_;
                Module::Runtime::use_package_optimistically( $_ ) foreach @does;
                $meta->set_roles( @does );
                return;
            }
        );

        # install our class finalizers
        $meta->add_finalizer(sub {

            if ( $meta->isa('mop::class') ) {
                # make sure to 'inherit' the required methods ...
                Moxie::Util::INHERIT_REQUIRED_METHODS( $meta );

                # this is an optimization to pre-populate the
                # cache for all the attributes
                Moxie::Util::GATHER_ALL_ATTRIBUTES( $meta );
            }

            # apply roles ...
            if ( my @does = $meta->roles ) {
                mop::internal::util::APPLY_ROLES(
                    $meta,
                    \@does,
                    to => ($meta->isa('mop::class') ? 'class' : 'role')
                );
            }

            Moxie::Util::Syntax::teardown_keyword_handler( $meta->name, $_ )
                foreach qw[ with has extends ];

            $meta->set_is_closed(1);
        });
    }

}

# TODO: see below ... yeah
BEGIN {

# NOTES:
# This is a rough "drawing" of the lifecycle for
# handling the options for the `has` keyword.
# Exactly how I will do this, we have to work out
# because the Moose/Class::MOP subclassing approach
# got really messy, and just having callback functions
# for traits means that we lose a lot of metadata.
# Need to find some way that is:
# 1) easy to implement new traits into any place in the workflow
# 2) does not lose the metadata generated
# 3) is able to mix-in cleanly with other MOP frontends
# 4) is not mind bendingly complex

#### `has` keyword's option lifecycle

    # is it `required`?
        # if yes
            # no need for `default` or `builder` or `lazy`
                # error if we find one
            # create required `default`

    # does it have a `default`?
        # if yes
            # no need for `builder` or `required`
                # error if we find one

    # does it have a `builder`?
        # if yes
            # no need for `default` or `required`
                # error if we find one
            # can we locate the method
                # is it required/abstract? is it locally defined?

#### initializer is specified now ...

    # does it have `is`?
        # does it have `reader` or `writer`?
            # do they conflict with `is`?
                # ex: the following is sensible
                    # is => 'ro', writer => '_set_foo'
                # ex: the following is NOT (very) sensible
                    # is => 'rw', reader => '_get_foo'
        # does the method name conflict with existing one?

    # does it have `predicate`, `clearer`, `reader` or `writer` specified?
        # does the method name conflict with any existing one?
        # does it conflict with some inherited?
            # is that inherited method also generated by Moxie for an attribute?

    # should we support `handles`?
        # if so, what style?

#### methods to be added is specified now ...

    $TRAITS{'required'} = sub {};
    $TRAITS{'default'}  = sub {};
    $TRAITS{'builder'}  = sub {};

    $TRAITS{'predicate'} = sub {
        my ($m, $a, $method_name) = @_;
        my $slot = $a->name;
        $m->add_method( $method_name => sub { defined $_[0]->{ $slot } } );
    };

    $TRAITS{'clearer'} = sub {
        my ($m, $a, $method_name) = @_;
        my $slot = $a->name;
        $m->add_method( $method_name => sub { undef $_[0]->{ $slot } } );
    };

    $TRAITS{'reader'} = sub {
        my ($m, $a, $method_name) = @_;
        my $slot = $a->name;
        $m->add_method( $method_name => sub {
            die "Cannot assign to `$slot`, it is a readonly attribute" if scalar @_ != 1;
            $_[0]->{ $slot };
        });
    };

    $TRAITS{'writer'} = sub {
        my ($m, $a, $method_name) = @_;
        my $slot = $a->name;
        $m->add_method( $method_name => sub {
            $_[0]->{ $slot } = $_[1] if $_[1];
            $_[0]->{ $slot };
        });
    };

    $TRAITS{'is'} = sub {
        my ($m, $a, $type) = @_;
        if ( $type eq 'ro' ) {
            $TRAITS{'reader'}->( $m, $a, $a->name );
        } elsif ( $type eq 'rw' ) {
            $TRAITS{'writer'}->( $m, $a, $a->name );
        } else {
            die "[mop::PANIC] Got strange option ($type) to trait (is)";
        }
    };
}

1;

__END__

=pod

=head1 NAME

Moxie

=head1 SYNOPSIS

    package Point {
        use Moxie;

        extends 'mop::object';

        has 'x' => (is => 'ro', default => sub { 0 });
        has 'y' => (is => 'ro', default => sub { 0 });

        sub clear ($self) {
            @{$self}{'x', 'y'} = (0, 0);
        }
    }

    package Point3D {
        use Moxie;

        extends 'Point';

        has 'z' => (is => 'ro', default => sub { 0 });

        sub clear ($self) {
            $self->next::method;
            $self->{'z'} = 0;
        }
    }

=head1 DESCRIPTION

Moxie is a reference implemenation for an object system built
on top of the mop. It is purposefully meant to be similar to
the Moose/Mouse/Moo style of classes, but with a number of
improvements as well.

=cut





