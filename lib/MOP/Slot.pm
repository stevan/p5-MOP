package MOP::Slot;

use strict;
use warnings;

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object' }
our %HAS; BEGIN {
    %HAS = (
        name        => sub { die '[ARGS] You must specify a slot name'        },
        initializer => sub { die '[ARGS] You must specify a slot initializer' },
    )
}

# if called upon to be a CODE ref
# then return the initializer
use overload '&{}' => 'initializer', fallback => 1;

sub CREATE {
    my ($class, $args) = @_;
    my $proto = $class->SUPER::CREATE( $args );

    die '[ARGS] The initializer specified must be a CODE reference'
        unless ref $proto->{initializer} eq 'CODE';

    return $proto;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub initializer {
    my ($self) = @_;
    return $self->{initializer};
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

    die '[ARGS] You must specify at least one classname'
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

=head1 NAME

MOP::Slot

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
