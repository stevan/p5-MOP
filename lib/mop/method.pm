package mop::method;

use v5.10;

use strict;
use warnings;

use B          ();
use attributes ();

use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'mop::object' };

our $IS_CLOSED; BEGIN { $IS_CLOSED = 1 }

sub CREATE {
    my ($class, $args) = @_;

    die '[MISSING_ARG] You must specify a method body'
        unless $args->{body};
    die '[INVALID_ARG] The body specified must be a CODE reference'
        unless ref $args->{body} eq 'CODE';

    my $body = $args->{body};

    return bless \$body => $class;
}

sub name {
    my ($self) = @_;
    return B::svref_2object( $self->body )->GV->NAME
}

sub body {
    my ($self) = @_;
    return $$self;
}

sub is_required {
    my ($self) = @_;
    my $op = B::svref_2object( $self->body );
    return !! $op->isa('B::CV') && $op->ROOT->isa('B::NULL');
}

sub origin_class {
    my ($self) = @_;
    # NOTE:
    # Here we actually want the stash that is
    # associated with the GV (glob) that the
    # method body is associated with. This is
    # sometimes different then the COMP_STASH
    # meaning the stash it was compiled in. It
    # seems to vary most with required subs,
    # which seem to be compiled in main:: even
    # when I am expecting it not to be.
    # - SL
    return B::svref_2object( $self->body )->GV->STASH->NAME
}

sub was_aliased_from {
    my ($self, @classnames) = @_;
    my $class = $self->origin_class;
    foreach my $candidate ( @classnames ) {
        return 1 if $candidate eq $class;
    }
    return 0;
}

sub get_code_attributes {
    my ($self) = @_;
    return attributes::get( $self->body );
}

1;

__END__

=pod

=head1 NAME

mop::method

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
