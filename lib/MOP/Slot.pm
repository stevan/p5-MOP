package MOP::Slot;
# ABSTRACT: A representation of a class slot

use strict;
use warnings;

use Carp ();

use UNIVERSAL::Object::Immutable;

use MOP::Internal::Util;

our $VERSION   = '0.07';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object::Immutable' }

# if called upon to be a CODE ref
# then return the initializer
use overload '&{}' => 'initializer', fallback => 1;

sub BUILDARGS {
    my $class = shift;
    my $args;

    if ( scalar( @_ ) eq 2 && !(ref $_[0]) && ref $_[1] eq 'CODE' ) {
        $args = +{ name => $_[0], initializer => $_[1] };
    }
    else {
        $args = $class->SUPER::BUILDARGS( @_ );
    }

    Carp::croak('[ARGS] You must specify a slot name')
        unless $args->{name};
    Carp::croak('[ARGS] You must specify a slot initializer')
        unless $args->{initializer};
    Carp::croak('[ARGS] The initializer specified must be a CODE reference')
        unless ref $args->{initializer} eq 'CODE';

    return $args;
}

sub CREATE {
    my ($class, $args) = @_;
    # NOTE:
    # Ideally this instance would actually just be
    # a reference to an HE (C-level hash entry struct)
    # but that is not something that is exposed at
    # the language level. Instead we use an ARRAY
    # ref to both 1) save space and 2) retain an
    # illusion of opacity regarding these instances.
    # - SL
    return +[ $args->{name}, $args->{initializer} ]
}

sub name {
    my ($self) = @_;
    return $self->[0];
}

sub initializer {
    my ($self) = @_;
    return $self->[1];
}

sub origin_stash {
    my ($self) = @_;
    # NOTE:
    # for the time being we are going to stick with
    # the COMP_STASH as the indicator for the initalizers
    # instead of the glob ref, which might be trickier
    # however I really don't know, so time will tell.
    # - SL
    return MOP::Internal::Util::GET_STASH_NAME( $self->initializer );
}

sub was_aliased_from {
    my ($self, @classnames) = @_;

    Carp::croak('[ARGS] You must specify at least one classname')
        if scalar( @classnames ) == 0;

    my $class = $self->origin_stash;
    foreach my $candidate ( @classnames ) {
        return 1 if $candidate eq $class;
    }
    return 0;
}

1;

__END__

=pod

=head1 DESCRIPTION

A slot is best thought of as representing a single entry in the
package scoped C<%HAS> variable. This is basically just building upon the
conceptual model laid out by L<UNIVERSAL::Object>.

=head1 CONSTRUCTORS

=over 4

=item C<new( name => $name, initializer => $initializer )>

=item C<new( $name, $initializer )>

=back

=head1 METHODS

=over 4

=item C<name>

=item C<initializer>

=item C<origin_stash>

=item C<was_aliased_from>

=back

=cut
