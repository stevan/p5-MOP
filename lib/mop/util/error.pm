package mop::util::error;

use strict;
use warnings;

use mop::util;
use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our (@ISA, %HAS); 

BEGIN {
    @ISA = 'mop::object';
    %HAS = (
        from => sub { die '`from` is required' },
        msg  => sub { die '`msg` is required'  },
    );
}

sub CREATE {
    my ($class, $proto) = @_;
    foreach my $attr ( keys %HAS ) {
        $proto->{ $attr } = $HAS{ $attr }->()
            if not exists $proto->{ $attr };
    }
    $class->next::method( $proto );
}

sub from { $_[0]->{from} }
sub msg  { $_[0]->{msg}  }

1;

__END__