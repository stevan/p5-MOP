package MOP::Method;
# ABSTRACT: A representation of a method

use strict;
use warnings;

use attributes ();

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.05';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object' };

sub BUILDARGS {
    my $class = shift;
    my %args;

    if ( scalar( @_ ) == 1 ) {
        if ( ref $_[0] ) {
            if ( ref $_[0] eq 'CODE' ) {
                %args = ( body => $_[0] );
            }
            elsif (ref $_[0] eq 'HASH') {
                %args = %{ $_[0] };
            }
        }
    }
    else {
        %args = @_;
    }

    die '[ARGS] You must specify a method body'
        unless $args{body};

    die '[ARGS] The body specified must be a CODE reference'
        unless ref $args{body} eq 'CODE';

    return \%args;
}

sub CREATE {
    my ($class, $args) = @_;

    my $body = $args->{body};
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

sub has_code_attributes {
    my ($self, $to_match) = @_;
    return grep /$to_match/, attributes::get( $self->body );
}

sub get_code_attributes {
    my ($self) = @_;
    return attributes::get( $self->body );
}

1;

__END__

=pod

=head1 DESCRIPTION

A method is simply a wrapper around a reference to a CODE slot inside
a given package.

=head1 CONSTRUCTORS

=over 4

=item C<new( body => \&method )>

=item C<new( \&method )>

=back

=head1 METHODS

=over 4

=item C<name>

=item C<body>

=item C<is_required>

=item C<origin_stash>

=item C<was_aliased_from>

=item C<has_code_attributes>

=item C<get_code_attributes>

=back

=cut
