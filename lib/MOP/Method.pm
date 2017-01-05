package MOP::Method;

use strict;
use warnings;

use attributes ();

use MOP::Object;

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'MOP::Object' };

sub CREATE {
    my ($class, $args) = @_;

    die '[ARGS] You must specify a method body'
        unless $args->{body};
    die '[ARGS] The body specified must be a CODE reference'
        unless ref $args->{body} eq 'CODE';

    my $body = $args->{body};

    return bless \$body => $class;
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
    return MOP::Internal::Util::GET_GLOB_STASH_NAME( $self->body )
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
