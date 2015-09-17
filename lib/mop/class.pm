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

BEGIN {
    # apply them roles  ...
    mop::internal::util::APPLY_ROLES(
        mop::role->new( name => __PACKAGE__ ), 
        \@DOES, 
        to => 'class' 
    )
}

sub bless_instance { 
    my $self     = $_[0];
    my $instance = $_[1];

    # TODO (eventually)
    # This shold also support Package::Anon
    # type thing, which would likely do the 
    # blessing in a different way.
    # Just something to think about.
    # - SL 

    bless $instance => $self->name;
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

=head2 Instance construction and management

=over 4

=item C<bless_instance( $instance )>

=back

=cut