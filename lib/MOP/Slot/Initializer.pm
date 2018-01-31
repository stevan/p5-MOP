package MOP::Slot::Initializer;
# ABSTRACT: A representation of a class slot initializer

use strict;
use warnings;

use Carp ();

use MOP::Internal::Util;

our $VERSION   = '0.14';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'UNIVERSAL::Object::Immutable';

our %HAS; BEGIN {
    %HAS = (
        default  => sub {},
        required => sub {},
    )
}

sub BUILDARGS {
    my $class = shift;
    my $args  = $class->SUPER::BUILDARGS( @_ );

    Carp::confess('Cannot have both a default and be required in the same initializer')
        if $args->{default} && $args->{required};

    return $args;
}

sub CREATE {
    my ($class, $args) = @_;

    my $code;
    if ( my $message = $args->{required} ) {
        $code = eval 'sub { die \''.$message.'\' }';
    }
    else {
        $code = $args->{default} || eval 'sub { undef }';
    }

    return $code;
}

sub BUILD {
    my ($self, $params) = @_;

    MOP::Internal::Util::SET_COMP_STASH_FOR_CV( $self, $params->{within_package} )
        if $params->{within_package};
}

1;

__END__

=pod

=head1 DESCRIPTION

Initializer objects for the MOP made out of CODE refs.

=head1 CONSTRUCTORS

=over 4

=item C<new( %args )>

=back

=cut
