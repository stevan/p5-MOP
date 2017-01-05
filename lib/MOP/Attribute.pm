package MOP::Attribute;

use strict;
use warnings;

use MOP::Object;

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'MOP::Object' };

sub CREATE {
    my ($class, $args) = @_;

    die '[ARGS] You must specify an attribute name'
        unless $args->{name};
    die '[ARGS] You must specify an attribute initializer'
        unless $args->{initializer};
    die '[ARGS] The initializer specified must be a CODE reference'
        unless ref $args->{initializer} eq 'CODE';

    return bless {
        name        => $args->{name},
        initializer => $args->{initializer},
    } => $class;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub initializer {
    my ($self) = @_;
    return $self->{initializer};
}

sub origin_class {
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

    my $class = $self->origin_class;
    foreach my $candidate ( @classnames ) {
        return 1 if $candidate eq $class;
    }
    return 0;
}

1;

__END__

=pod

=head1 NAME

MOP::Attribute

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
