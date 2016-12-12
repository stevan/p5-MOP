package mop::object;

use strict;
use warnings;

use Scalar::Util      ();
use UNIVERSAL::Object ();

use mop::internal::util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our $IS_CLOSED; UNITCHECK { $IS_CLOSED = 1 }
our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

sub new {
    my $class = shift;
       $class = Scalar::Util::blessed( $class ) if ref $class;
    die "[ABSTRACT] Cannot create an instance of '$class', it is abstract"
        if mop::internal::util::IS_CLASS_ABSTRACT( $class );
    return $class->SUPER::new( @_ );
}

1;

__END__

=pod

=head1 NAME

mop::object

=head1 DESCRIPTION

This is really just a subclass of L<UNIVERSAL::Object> which handles
class abstract-ness. 

=cut
