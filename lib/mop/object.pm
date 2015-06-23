package mop::object;

use strict;
use warnings;

use mop::util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub new {
    my $class = shift;
    my $args  = $class->BUILDARGS( @_ );
    my $self  = $class->CREATE( $args );
    $self->can('BUILD') && mop::util::BUILDALL( $self, $args );
    $self;
}

sub BUILDARGS {
    shift;
    return scalar @_ == 1 && ref $_[0] ? $_[0] : { @_ }
}

sub CREATE {
    my ($class, $proto) = @_;
    bless $proto => $class;
}

sub DESTROY {
    $_[0]->can('DEMOLISH') && mop::util::DEMOLISHALL( $_[0] )
}

1;

__END__
