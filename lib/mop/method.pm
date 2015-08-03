package mop::method;

use strict;
use warnings;

use B ();

use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'mop::object' };

sub CREATE {
    my ($class, $args) = @_; 
    die '[MISSING_ARG] You must specify a method body'
        unless $args->{body};
    die '[INVALID_ARG] The body specified must be a CODE reference'
        unless ref $args->{body} eq 'CODE';
    my $body = $args->{body};
    # NOTE:
    # as with ...
    return bless \$body => $class;
}

sub body {
    my ($self) = @_;
    return $$self;
}

sub name {
    my ($self) = @_;
    return B::svref_2object( $self->body )->GV->NAME
}

sub is_required {
    my ($self) = @_;
    my $op = B::svref_2object( $self->body );
    return !! $op->isa('B::CV') && $op->ROOT->isa('B::NULL'); 
}

sub origin_class {
    my ($self) = @_;
    return B::svref_2object( $self->body )->STASH->NAME
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

mop::method

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
