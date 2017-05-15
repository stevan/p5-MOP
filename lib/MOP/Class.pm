package MOP::Class;
# ABSTRACT: A representation of a class

use strict;
use warnings;

use mro  ();
use Carp ();

use UNIVERSAL::Object::Immutable;

use MOP::Role;
use MOP::Method;
use MOP::Slot;

use MOP::Internal::Util;

our $VERSION   = '0.07';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA;  BEGIN { @ISA  = 'UNIVERSAL::Object::Immutable' };
our @DOES; BEGIN { @DOES = 'MOP::Role' }; # to be composed later ...

UNITCHECK {
    # apply them roles  ...
    MOP::Internal::Util::APPLY_ROLES(
        MOP::Role->new( name => __PACKAGE__ ),
        \@DOES,
        to => 'class'
    );
}

# superclasses

sub superclasses {
    my ($self) = @_;
    my $isa = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'ISA', 'ARRAY' );
    return unless $isa;
    return @$isa;
}

sub set_superclasses {
    my ($self, @superclasses) = @_;
    Carp::croak('[ARGS] You must specify at least one superclass')
        if scalar( @superclasses ) == 0;
    MOP::Internal::Util::SET_GLOB_SLOT( $self->stash, 'ISA', \@superclasses );
    return;
}

sub mro {
    my ($self) = @_;
    return mro::get_linear_isa( $self->name );
}

1;

__END__

=pod

=head1 DESCRIPTION

A class I<does> all the things a role does, with the addition of
inheritance and instance construction.

=head1 CONSTRUCTORS

=over 4

=item C<new( name => $package_name )>

=item C<new( $package_name )>

=item C<new( \%package_stash )>

=back

=head1 METHODS

This module I<does> the L<MOP::Role> package, which means
that it also has all the methods from that package as well.

=head2 Inheritance

=over 4

=item C<superclasses()>

=item C<set_superclasses( @supers )>

=item C<mro()>

=back

=cut
