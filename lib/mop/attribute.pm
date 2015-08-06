package mop::attribute;

use strict;
use warnings;

use B ();

use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'mop::object' };

sub CREATE {
    my ($class, $args) = @_; 
    
    die '[MISSING_ARG] You must specify an attribute name'
        unless $args->{name};
    die '[MISSING_ARG] You must specify an attribute initializer'
        unless $args->{initializer};    
    die '[INVALID_ARG] The initializer specified must be a CODE reference'
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
    return B::svref_2object( $self->initializer )->STASH->NAME
}

sub was_aliased_from {
    my ($self, @classnames) = @_;
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

mop::attribute

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
