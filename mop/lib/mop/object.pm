package mop::object;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our $IS_CLOSED; UNITCHECK { $IS_CLOSED = 1 }

sub new {
    my $class = shift;
       $class = Scalar::Util::blessed( $class ) if ref $class;
    die "[ABSTRACT] Cannot create an instance of '$class', it is abstract"
        if mop::object::util::IS_CLASS_ABSTRACT( $class );
    my $proto = $class->BUILDARGS( @_ );
    my $self  = $class->CREATE( $proto );
    $self->can('BUILD') && mop::object::util::BUILDALL( $self, $proto );
    return $self;
}

sub BUILDARGS {
    shift;
    if ( scalar @_ == 1 && ref $_[0] ) {
        die '[PANIC] expected a HASH reference but got a ' . $_[0]
            unless ref $_[0] eq 'HASH';
        return +{ %{ $_[0] } };
    }
    else {
        die '[PANIC] expected an even sized list reference but instead got ' . (scalar @_) . ' element(s)'
            unless ((scalar @_) % 2) == 0;
        return +{ @_ };
    }
}

sub CREATE {
    my $class = $_[0];
    my $proto = $_[1];
    my $self  = {};
    my %slots = mop::object::util::FETCH_CLASS_SLOTS( $class );

    $self->{ $_ } = exists $proto->{ $_ }
        ? $proto->{ $_ }
        : $slots{ $_ }->( $self, $proto )
            foreach keys %slots;

    return bless $self => $class;
}

sub DESTROY {
    $_[0]->can('DEMOLISH') && mop::object::util::DEMOLISHALL( $_[0] );
    return;
}

package mop::object::util;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our $IS_CLOSED; UNITCHECK { $IS_CLOSED = 1 }

BEGIN { $] >= 5.010 ? eval 'use mro' : eval 'use MRO::Compat' }

sub IS_CLASS_ABSTRACT { no strict 'refs'; no warnings 'once'; return ${$_[0] . '::IS_ABSTRACT'} }
sub IS_CLASS_CLOSED   { no strict 'refs'; no warnings 'once'; return ${$_[0] . '::IS_CLOSED'}   }
sub FETCH_CLASS_SLOTS { no strict 'refs'; no warnings 'once'; return %{$_[0] . '::HAS'}         }

sub BUILDALL {
    my ($instance, $proto) = @_;
    foreach my $super ( reverse @{ mro::get_linear_isa( Scalar::Util::blessed( $instance ) ) } ) {
        my $fully_qualified_name = $super . '::BUILD';
        if ( defined &{ $fully_qualified_name } ) {
            $instance->$fully_qualified_name( $proto );
        }
    }
    return;
}

sub DEMOLISHALL {
    my ($instance) = @_;
    foreach my $super ( @{ mro::get_linear_isa( Scalar::Util::blessed( $instance ) ) } ) {
        my $fully_qualified_name = $super . '::DEMOLISH';
        if ( defined &{ $fully_qualified_name } ) {
            $instance->$fully_qualified_name();
        }
    }
    return;
}

1;

__END__

=pod

=head1 NAME

mop::object

=head1 SYNPOSIS

    package Person {
        use strict;
        use warnings;

        our @ISA = ('mop::object');

        our %HAS = (

            ## Required
            # this attribute is required because if
            # it is not supplied, the initialiser below
            # will run, which will die
            name   => sub { die 'name is required' },

            ## Optional w/ Default
            # this attribute has a default value
            age    => sub { 0 },

            ## Optional w/out Default
            # this attribute has no defualt value
            # and is not required, however we need
            # to still have an empty sub since we
            # use that sub to locate the "home" package
            # of a given attribute (useful when
            # attributes are inherited or composed in
            # via roles)
            gender => sub {},
        );
    }

    package Employee {
        use strict;
        use warnings;

        our @ISA = ('Person');
        our %HAS = (
            %Person::HAS, # inheritance ;)
            job_title => sub { die 'job_title is required' },
            manager   => sub {},
        );
    }

    my $employee = Employee->new;

=head1 DESCRIPTION

This module provides a protocol for object construction and
destruction that aims to be as simple as possible while still
being complete.

=head1 METHODS

=head2 C<new ($class, @args)>

This is the entry point for object construction, from here the
C<@args> are passed into C<BUILDARGS>.

=head2 C<BUILDARGS ($class, @args)>

This method takes the original C<@args> to the C<new> constructor
and is expected to turn them into a canonical form, which is a
HASH ref of name/value pairs. This form is considered a prototype
candidate for the instance and is then passed to C<CREATE> and
should be a (shallow) copy of what was contained in C<@args>.

=head2 C<CREATE ($class, $proto)>

This method receives the C<$proto> candidate from C<BUILDARGS> and
constructs from it a blessed instance using the C<%HAS> hash in the
C<$class>.

This newly blessed instance is then initialized by calling all the
available C<BUILD> methods in the correct (reverse mro) order.

=head2 C<BUILD ($self, $proto)>

This is an optional initialization method which recieves the blessed
instance as well as the prototype candidate. There are no restirctions
as to what this method can do other then just common sense.

It is worth noting that because we call all the C<BUILD> methods
found in the object hierarchy, this return values of these methods
are completly ignored.

=head2 C<DEMOLISH ($self)>

This is an optional destruction method, similar to C<BUILD>, all
available C<DEMOLISH> methods are called in the correct (mro) order
by C<DESTROY>.

=head2 C<DESTROY ($self)>

The sole function of this method is to kick off the call to all the
C<DEMOLISH> methods during destruction.

=cut
