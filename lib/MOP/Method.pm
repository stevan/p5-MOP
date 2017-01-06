package MOP::Method;

use strict;
use warnings;

use attributes ();

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object' };
our %HAS; BEGIN {
    %HAS = (
        body => sub { die '[ARGS] You must specify a method body' },
    )
}

sub CREATE {
    my ($class, $args) = @_;

    my $body = $args->{body} || $HAS{body}->();

    die '[ARGS] The body specified must be a CODE reference'
        unless ref $body eq 'CODE';

    # this will get blessed, so we
    # do not actually want the CV
    # to get touched, so we get a
    # ref of a ref here ...
    return \$body;
}

sub name {
    my ($self) = @_;
    return MOP::Internal::Util::GET_GLOB_NAME( $self->body )
}

sub body {
    my ($self) = @_;
    return $$self;
}

sub is_required {
    my ($self) = @_;
    MOP::Internal::Util::IS_CV_NULL( $self->body );
}

sub origin_stash {
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
    return MOP::Internal::Util::GET_GLOB_STASH_NAME( $self->body )
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

sub get_code_attributes {
    my ($self) = @_;
    return attributes::get( $self->body );
}

1;

__END__

=pod

=head1 NAME

MOP::Method

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
