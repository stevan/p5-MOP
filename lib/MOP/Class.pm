package MOP::Class;

use strict;
use warnings;

use UNIVERSAL::Object;

use MOP::Module;
use MOP::Role;
use MOP::Method;
use MOP::Slot;

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA;  BEGIN { @ISA  = 'UNIVERSAL::Object' };
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
    die '[ARGS] You must specify at least one superclass'
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

=head1 NAME

MOP::Class - the metaclass for class

=head1 SYNPOSIS

=head1 DESCRIPTION

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
