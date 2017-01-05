#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

=pod

This test is from p5-MOP-redux to show an oddity
that worked the opposite of what people might
expect, which is not the case here, so we keep
the test, but change what is expected. We keep the
original comment for posterity.

# NOTE FROM p5-MOP-redux TEST

This test illustrates how the attributes are
private and allocated on a per-class basis.
So when you override an attribute in a subclass
the methods of the superclass will not get
the value 'virtually', since the storage is
class specific.

This is perhaps not ideal, the older p5-MOP
prototype did the opposite and in some ways
that is more what I think people would expect.

The solution to making this work like the
older prototype would be to lookup the
attribute storage hash on each method call,
this should then give us the virtual behavior
but it seems a lot of overhead, so perhaps
I will just punt until we do the real thing.

=cut

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar' => (default => sub { 10 });

    sub bar ($self) { $self->{bar} }
}

package FooBar {
    use Moxie;

    extends 'Foo';

    has 'bar' => (default => sub { 100 });

    sub derived_bar ($self) { $self->{bar} }
}

my $foobar = FooBar->new;

is($foobar->bar, 100, '... got the expected value (for the superclass method)');
is($foobar->derived_bar, 100, '... got the expected value (for the derived method)');

done_testing;
