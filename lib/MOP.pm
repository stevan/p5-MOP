package MOP;
# ABSTRACT: A Meta Object Protocol for Perl 5

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use MOP::Role;
use MOP::Class;

use MOP::Slot;
use MOP::Method;

1;

__END__

=pod

=head1 SYNOPSIS

  use MOP;
  
  my $m = MOP::Class->new( 'Foo' );
  
  printf 'Intospecting %s package with version %s', $m->name, $m->version; 
  
  foreach my $s ( $m->all_slots ) {
  	  printf 'Found slot %s', $s->name;
  }
  
  foreach my $m ( $m->all_methods ) {
      printf 'Found method %s', $m->name;
  }

=head1 DESCRIPTION

This module implements a Meta Object Protocol for Perl 5. 

=head1 CONCEPTS

=head2 L<MOP::Role>

=head2 L<MOP::Class>

=head2 L<MOP::Slot>

=head2 L<MOP::Method>

=head1 SEE ALSO 

=head2 L<UNIVERSAL::Object>

=cut
