package mop::util;

use strict;
use warnings;

use mro          ();
use Scalar::Util ();

use mop::util::error;
use mop::util::error::PANIC;
use mop::util::error::ARGS;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## GENERAL
## ------------------------------------------------------------------

*BLESSED = \&Scalar::Util::blessed;

sub THROW { die join '' => '[', shift, '@', (scalar caller), '] ', @_ }

sub CATCH {
    my ($type, $from, $msg) = ($_[0] =~ /^\[(.*)\@(.*)\] (.*)/);
    my $e_class = 'mop::util::error::' . $type;
    return $e_class->new( from => $from, msg => $msg ); 
}

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

