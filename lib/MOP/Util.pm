package MOP::Util;
# ABSTRACT: For MOP External Use Only

use strict;
use warnings;

use MOP::Internal::Util ();

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

sub APPLY_ROLES { MOP::Internal::Util::APPLY_ROLES( @_ ) }

1;

__END__

=pod

=head1 DESCRIPTION

No user serviceable parts inside.

=cut



