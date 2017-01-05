package MOP::Object;

use strict;
use warnings;

use Scalar::Util      ();
use UNIVERSAL::Object ();

use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

sub new {
    my $class = shift;
       $class = Scalar::Util::blessed( $class ) if ref $class;
    die "[ABSTRACT] Cannot create an instance of '$class', it is abstract"
        if MOP::Internal::Util::IS_CLASS_ABSTRACT( $class );
    return $class->SUPER::new( @_ );
}

1;

__END__

=pod

=head1 NAME

MOP::Object

=head1 DESCRIPTION

This is really just a subclass of L<UNIVERSAL::Object> which handles
class abstract-ness.

=cut
