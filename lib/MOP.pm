package MOP;
# ABSTRACT: A Meta Object Protocol for Perl 5

use strict;
use warnings;

our $VERSION   = '0.06';
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

This module implements a Meta Object Protocol for Perl 5 with minimal
overhead and no non-core dependencies (eventually).

A Meta Object Protocol, or MOP, is an API to the various parts of the
an object system.

=head1 CONCEPTS

There are only a few key concepts in the MOP, which are described below.

=head2 L<MOP::Role>

A role is simply a package which I<may> have methods, I<may> have slot
defintions, and I<may> consume other roles.

=head2 L<MOP::Class>

A class I<does> all the things a role does, with the addition of
inheritance and instance construction.

=head2 L<MOP::Slot>

A slot is best thought of as representing a single entry in the
package scoped C<%HAS> variable. This is basically just building upon the
conceptual model laid out by L<UNIVERSAL::Object>.

=head2 L<MOP::Method>

A method is simply a wrapper around a reference to a CODE slot inside
a given package.

=head1 SEE ALSO

=head2 L<UNIVERSAL::Object>

This module uses the L<UNIVERSAL::Object> module as the chosen instance
construction protocol, but also in its introspection assumes that a
class uses the conventions of L<UNIVERSAL::Object> specifically with
regards to slot storage.

=head2 L<Class::MOP>

Almost 10 years ago I wrote L<Class::MOP>, whose purpose was also to
bring a MOP to Perl 5. While these modules may have had the same goal,
they have different requirements and priorities and so shouldn't be
compared directly.

=cut
