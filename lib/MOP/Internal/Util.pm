package MOP::Internal::Util;
# ABSTRACT: For MOP Internal Use Only

use strict;
use warnings;

use B            (); # nasty stuff, all nasty stuff
use Carp         (); # errors and stuff
use Sub::Util    (); # handling some sub stuff
use Symbol       (); # creating the occasional symbol
use Scalar::Util (); # I think I use blessed somewhere in here ...

our $VERSION   = '0.07';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## Basic Glob access
## ------------------------------------------------------------------

sub IS_VALID_MODULE_NAME {
    my ($name) = @_;
    $name =~ /[A-Z_a-z][0-9A-Z_a-z]*(?:::[0-9A-Z_a-z]+)*/
}

sub IS_STASH_REF {
    my ($stash) = @_;
    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    if ( my $name = B::svref_2object( $stash )->NAME ) {
        return IS_VALID_MODULE_NAME( $name );
    }
    return;
}

sub GET_NAME {
    my ($stash) = @_;
    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    B::svref_2object( $stash )->NAME
}

sub GET_STASH_NAME {
    my ($stash) = @_;
    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    B::svref_2object( $stash )->STASH->NAME
}

sub GET_GLOB_NAME {
    my ($stash) = @_;
    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    B::svref_2object( $stash )->GV->NAME
}

sub GET_GLOB_STASH_NAME {
    my ($stash) = @_;
    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    B::svref_2object( $stash )->GV->STASH->NAME
}

sub GET_GLOB_SLOT {
    my ($stash, $name, $slot) = @_;

    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    Carp::croak('[ARGS] You must specify a name')
        unless defined $name;
    Carp::croak('[ARGS] You must specify a slot')
        unless defined $slot;

    # do my best to not autovivify, and
    # return undef if not
    return unless exists $stash->{ $name };
    # occasionally we need to auto-inflate
    # the optimized version of a required
    # method, its annoying, but the XS side
    # should not have to care about this so
    # it can be removed eventually.
    if (( $slot eq 'CODE' && $stash->{ $name } eq "-1" ) || ref $stash->{ $name } ne 'GLOB') {
        B::svref_2object( $stash )->NAME->can( $name );
    }


    # return the reference stored in the glob
    # which might be undef, but that can be
    # handled by the caller
    return *{ $stash->{ $name } }{ $slot };
}

sub SET_GLOB_SLOT {
    my ($stash, $name, $value_ref) = @_;

    Carp::croak('[ARGS] You must specify a stash')
        unless defined $stash;
    Carp::croak('[ARGS] You must specify a name')
        unless defined $name;
    Carp::croak('[ARGS] You must specify a value REF')
        unless defined $value_ref;

    {
        no strict 'refs';
        no warnings 'once';
        # get the name of the stash, we could have
        # passed this in, but it is easy to get in
        # XS, and so we can punt that down the road
        # for the time being
        my $pkg = B::svref_2object( $stash )->NAME;
        *{ $pkg . '::' . $name } = $value_ref;
    }
    return;
}

## ------------------------------------------------------------------
## CV/Glob introspection
## ------------------------------------------------------------------

sub IS_CV_NULL {
    my ($cv) = @_;
    Carp::croak('[ARGS] You must specify a CODE reference')
        unless $cv;
    my $op = B::svref_2object( $cv );
    return !! $op->isa('B::CV') && $op->ROOT->isa('B::NULL');
}

sub DOES_GLOB_HAVE_NULL_CV {
    my ($glob) = @_;
    Carp::croak('[ARGS] You must specify a GLOB')
        unless $glob;
    # NOTE:
    # If the glob eq -1 that means it may well be a null sub
    # this seems to be some kind of artifact of an optimization
    # perhaps, I really don't know, it is odd. It should not
    # need to be dealt with in XS, it seems to be a Perl language
    # level thing.
    # - SL
    return 1 if $glob eq '-1';
    # next lets see if we have a CODE slot ...
    if ( my $code = *{ $glob }{CODE} ) {
        # if it is a CV and the ROOT is a NULL op ...
        my $op = B::svref_2object( $code );
        return !! $op->isa('B::CV') && $op->ROOT->isa('B::NULL');
    }
    # if we had no CODE slot, it can't be a NULL CV ...
    return 0;
}

sub CREATE_NULL_CV {
    my ($in_pkg, $name) = @_;
    Carp::croak('[ARGS] You must specify a package name')
        unless defined $in_pkg;
    Carp::croak('[ARGS] You must specify a name')
        unless defined $name;
    # this just tries to eval the NULL CV into
    # place, it is ugly, but works for now
    eval "sub ${in_pkg}::${name}; 1;" or do { Carp::croak($@) };
    return;
}

sub INSTALL_CV {
    my ($in_pkg, $name, $code, %opts) = @_;

    Carp::croak('[ARGS] You must specify a package name')
        unless defined $in_pkg;
    Carp::croak('[ARGS] You must specify a name')
        unless defined $name;
    Carp::croak('[ARGS] You must specify a CODE reference')
        unless $code && ref $code eq 'CODE';
    Carp::croak("[ARGS] You must specify a boolean value for `set_subname` option")
        if not exists $opts{set_subname};

    {
        no strict 'refs';
        no warnings 'once', 'redefine';

        my $fullname =  $in_pkg.'::'.$name;
        *{$fullname} = $opts{set_subname} ? Sub::Util::set_subname($fullname, $code) : $code;
    }
    return;
}

sub REMOVE_CV_FROM_GLOB {
    my ($stash, $name) = @_;

    Carp::croak('[ARGS] You must specify a stash')
        unless $stash && ref $stash eq 'HASH';
    Carp::croak('[ARGS] You must specify a name')
        unless defined $name;

    # find the glob we are looking for
    # which might not exist, in which
    # case we do nothing ....
    if ( my $glob = $stash->{ $name } ) {
        # once we find it, extract all the
        # slots we need, note the missing
        # CODE slot since we don't need
        # that in our new glob ...
        my %to_save;
        foreach my $slot (qw[ SCALAR ARRAY HASH FORMAT IO ]) {
            if ( my $val = *{ $glob }{ $slot } ) {
                $to_save{ $slot } = $val;
            }
        }
        # replace the old glob with a new one ...
        $stash->{ $name } = Symbol::gensym();
        # now go about constructing our new
        # glob by restoring the other slots
        {
            no strict 'refs';
            no warnings 'once';
            # get the name of the stash, we could have
            # passed this in, but it is easy to get in
            # XS, and so we can punt that down the road
            # for the time being
            my $pkg = B::svref_2object( $stash )->NAME;
            foreach my $type ( keys %to_save ) {
                *{ $pkg . '::' . $name } = $to_save{ $type };
            }
        }
    }
    # ... the end
    return;
}

## ------------------------------------------------------------------
## Role application and composition
## ------------------------------------------------------------------

sub APPLY_ROLES {
    my ($meta, $roles, %opts) = @_;

    Carp::croak('[ARGS] You must specify a metaclass to apply roles to')
        unless Scalar::Util::blessed( $meta );
    Carp::croak('[ARGS] You must specify a least one roles to apply as an ARRAY ref')
        unless $roles && ref $roles eq 'ARRAY' && scalar( @$roles ) != 0;
    Carp::croak("[ARGS] You must specify what type of object you want roles applied `to`")
        unless exists $opts{to};

    foreach my $r ( $meta->roles ) {
        Carp::croak("[ERROR] Could not find role ($_) in the set of roles in $meta (" . $meta->name . ")")
            unless scalar grep { $r eq $_ } @$roles;
    }

    my @meta_roles = map { MOP::Role->new( name => $_ ) } @$roles;

    my (
        $slots,
        $slot_conflicts
    ) = COMPOSE_ALL_ROLE_SLOTS( @meta_roles );

    Carp::croak("[CONFLICT] There should be no conflicting slots when composing (" . (join ', ' => @$roles) . ") into (" . $meta->name . ")")
        if scalar keys %$slot_conflicts;

    foreach my $name ( keys %$slots ) {
        # if we have a slot already by that name ...
        Carp::croak("[CONFLICT] Role Conflict, cannot compose slot ($name) into (" . $meta->name . ") because ($name) already exists")
            if $meta->has_slot( $name );
        # otherwise alias it ...
        $meta->alias_slot( $name, $slots->{ $name } );
    }

    my (
        $methods,
        $method_conflicts,
        $required_methods
    ) = COMPOSE_ALL_ROLE_METHODS( @meta_roles );

    Carp::croak("[CONFLICT] There should be no conflicting methods when composing (" . (join ', ' => @$roles) . ") into the class (" . $meta->name . ") but instead we found (" . (join ', ' => keys %$method_conflicts)  . ")")
        if $opts{to} eq 'class'           # if we are composing into a class ...
        && (scalar keys %$method_conflicts) # and we have any conflicts ...
        # and the conflicts are not satisfied by the composing class ...
        && (scalar grep { !$meta->has_method( $_ ) } keys %$method_conflicts);

    # check the required method set and
    # see if what we are composing into
    # happens to fulfill them
    foreach my $name ( keys %$required_methods ) {
        delete $required_methods->{ $name }
            if $meta->name->can( $name );
    }

    Carp::croak("[CONFLICT] There should be no required methods when composing (" . (join ', ' => @$roles) . ") into (" . $meta->name . ") but instead we found (" . (join ', ' => keys %$required_methods)  . ")")
        if $opts{to} eq 'class'            # if we are composing into a class ...
        && scalar keys %$required_methods; # and we have required methods ...

    foreach my $name ( keys %$methods ) {
        # if we have a method already by that name ...
        next if $meta->has_method( $name );
        # otherwise, alias it ...
        $meta->alias_method( $name, $methods->{ $name } );
    }

    # if we still have keys in $required, it is
    # because we are a role (class would have
    # died above), so we can just stuff in the
    # required methods ...
    $meta->add_required_method( $_ ) for keys %$required_methods;

    return;
}

sub COMPOSE_ALL_ROLE_SLOTS {
    my @roles = @_;

    Carp::croak('[ARGS] You must specify a least one role to compose slots in')
        if scalar( @roles ) == 0;

    my (%slots, %conflicts);

    foreach my $role ( @roles ) {
        foreach my $slot ( $role->slots ) {
            my $name = $slot->name;
            # if we have one already, but
            # it is not the same refaddr ...
            if ( exists $slots{ $name } && $slots{ $name } != $slot->initializer ) {
                # mark it as a conflict ...
                $conflicts{ $name } = undef;
                # and remove it from our slot set ...
                delete $slots{ $name };
            }
            # if we don't have it already ...
            else {
                # make a note of it
                $slots{ $name } = $slot->initializer;
            }
        }
    }

    return \%slots, \%conflicts;
}


# TODO:
# We should track the name of the role
# where the required method was composed
# from, as well as the two classes in
# which a method conflicted.
# - SL
sub COMPOSE_ALL_ROLE_METHODS {
    my @roles = @_;

    Carp::croak('[ARGS] You must specify a least one role to compose methods in')
        if scalar( @roles ) == 0;

    my (%methods, %conflicts, %required);

    # flatten the set of required methods ...
    foreach my $r ( @roles ) {
        foreach my $m ( $r->required_methods ) {
            $required{ $m->name } = undef;
        }
    }

    # for every role ...
    foreach my $r ( @roles ) {
        # and every method in that role ...
        foreach my $m ( $r->methods ) {
            my $name = $m->name;
            # if we have already seen the method,
            # but it is not the same refaddr
            # it is a conflict, which means:
            if ( exists $methods{ $name } && $methods{ $name } != $m->body  ) {
                # we need to add it to our required-method map
                $required{ $name } = undef;
                # and note that it is also a conflict ...
                $conflicts{ $name } = undef;
                # and remove it from our method map
                delete $methods{ $name };
            }
            # if we haven't seen the method ...
            else {
                # add it to the method map
                $methods{ $name } = $m->body;
                # and remove it from the required-method map
                delete $required{ $name }
                    # if it actually exists in it, and ...
                    if exists $required{ $name }
                    # is not also a conflict ...
                    && !exists $conflicts{ $name };
            }
        }
    }

    #use Data::Dumper;
    #warn Dumper [ [ map { $_->name } @roles ], \%methods, \%conflicts, \%required ];

    return \%methods, \%conflicts, \%required;
}

1;

__END__

=pod

=head1 DESCRIPTION

No user serviceable parts inside.

=cut



