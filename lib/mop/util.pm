package mop::util;

use strict;
use warnings;

use mro          ();
use Scalar::Util ();


our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## GENERAL
## ------------------------------------------------------------------

*BLESSED = \&Scalar::Util::blessed;

## ------------------------------------------------------------------
## OBJECT INITIALIZATION AND DESTRUCTION 
## ------------------------------------------------------------------

sub BUILDALL {
    my ($class, $instance, $proto) = @_;
    foreach my $super ( reverse @{ mro::get_linear_isa( $class ) } ) {
        my $fully_qualified_name = $super . '::BUILD';
        if ( defined &{ $fully_qualified_name } ) {
            $instance->$fully_qualified_name( $proto );
        }
    }
    return; 
}

sub DEMOLISHALL {
    my ($class, $instance) = @_;
    foreach my $super ( @{ mro::get_linear_isa( $class ) } ) {
        my $fully_qualified_name = $super . '::DEMOLISH';
        if ( defined &{ $fully_qualified_name } ) {
            $instance->$fully_qualified_name();
        }
    }
    return; 
}

## ------------------------------------------------------------------

1;

__END__

