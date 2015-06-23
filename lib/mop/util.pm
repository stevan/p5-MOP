package mop::util;

use strict;
use warnings;
use mro;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## Dispatching and class MRO walking
## ------------------------------------------------------------------

sub DISPATCHER {
    my ($class, %opts) = @_;
    my @mro = @{ mro::get_linear_isa( $class ) };
    @mro = reverse @mro if $opts{reverse};
    return sub { (shift @mro) || return };
}

sub WALKCLASS { 
    my ($dispatcher) = @_;
    return $dispatcher->();
}

sub WALKMETH  {  
    my ($dispatcher, $method) = @_;
    { 
        no strict 'refs';
        my $class = $dispatcher->();
        return unless $class;
        defined &{ $class . '::' . $method }
            ? \&{ $class . '::' . $method }
            : redo;
    } 
}


## ------------------------------------------------------------------
## Instance construction and destruction protocol
## ------------------------------------------------------------------

sub BUILDALL {
    my ($instance, $args) = @_;
    my $dispatcher = DISPATCHER( ref $instance, reverse => 1 );
    while ( my $method = WALKMETH( $dispatcher, 'BUILD' ) ) {
        $instance->$method( $args );
    }
    return; 
}

sub DEMOLISHALL {
    my ($instance) = @_;
    my $dispatcher = DISPATCHER( ref $instance );
    while ( my $method = WALKMETH( $dispatcher, 'DEMOLISH' ) ) {
        $instance->$method();
    }
    return; 
}

## ------------------------------------------------------------------

1;

__END__

