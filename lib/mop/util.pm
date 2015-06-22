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
## Instance construction 
## ------------------------------------------------------------------

our %GENERATORS;
BEGIN {
    %GENERATORS = (
        HASH   => sub { +{ %{ $_[0] } }                           },
        ARRAY  => sub { +[ @{ $_[0] } ]                           },
        SCALAR => sub { my $x = $_[0]; \$x                        }, 
        GLOB   => sub { select select my $fh; %{ *$fh } = @_; $fh },  
    ); 
}

sub CONSTRUCT_INSTANCE {
    my %opts = @_;

    my ($generator, $instance);

    $generator = $opts{ generator }
        ? $opts{ generator }
        : ($opts{ repr } && $GENERATORS{ $opts{ repr } });

    die "[mop::PANIC] You must specify either a `generator` or a `repr` to construct an instance"
        unless $generator;

    die "[mop::PANIC] You must specify a class to bless the instance into"
        unless $opts{ bless_into };

    bless $generator->( $opts{ args } || () ) => $opts{ bless_into };
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

