package mop::class;

use strict;
use warnings;

use mop::object;
use mop::module;
use mop::role;
use mop::method;
use mop::attribute;

use mop::internal::util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA;  BEGIN { @ISA  = 'mop::object' };
our @DOES; BEGIN { @DOES = 'mop::role' }; # to be composed later ...

our $IS_CLOSED;
BEGIN {
    # apply them roles  ...
    mop::internal::util::APPLY_ROLES(
        mop::role->new( name => __PACKAGE__ ),
        \@DOES,
        to => 'class'
    );
    $IS_CLOSED = 1;
}

# superclasses

sub superclasses {
    my ($self) = @_;
    my $isa = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'ISA', 'ARRAY' );
    return unless $isa;
    return @$isa;
}

sub set_superclasses {
    my ($self, @superclasses) = @_;
    die '[PANIC] Cannot add superclasses to a package which has been closed'
        if $self->is_closed;
    mop::internal::util::SET_GLOB_SLOT( $self->stash, 'ISA', \@superclasses );
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

mop::class - the metaclass for class

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

This module I<does> the L<mop::role> package, which means
that it also has all the methods from that package as well.

=head2 Inheritance

=over 4

=item C<superclasses()>

=item C<set_superclasses( @supers )>

=item C<mro()>

=back

=cut
