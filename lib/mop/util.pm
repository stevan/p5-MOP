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

sub IS_CLASS_ABSTRACT { no strict 'refs'; no warnings 'once'; ${$_[0] . '::IS_ABSTRACT'} }
sub IS_CLASS_CLOSED   { no strict 'refs'; no warnings 'once'; ${$_[0] . '::IS_CLOSED'}   }
sub FETCH_CLASS_SLOTS { no strict 'refs'; no warnings 'once'; %{$_[0] . '::HAS'}         }

## ------------------------------------------------------------------
## OBJECT INITIALIZATION AND DESTRUCTION 
## ------------------------------------------------------------------

sub BUILDALL {
    my ($instance, $proto) = @_;
    foreach my $super ( reverse @{ mro::get_linear_isa( Scalar::Util::blessed( $instance ) ) } ) {
        my $fully_qualified_name = $super . '::BUILD';
        if ( defined &{ $fully_qualified_name } ) {
            $instance->$fully_qualified_name( $proto );
        }
    }
    return; 
}

sub DEMOLISHALL {
    my ($instance) = @_;
    foreach my $super ( @{ mro::get_linear_isa( Scalar::Util::blessed( $instance ) ) } ) {
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




