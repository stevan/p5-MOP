#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

=pod

Every new instance created should be a new reference
and all attribute data in it should be a clone of the
original data itself, unless you reference something
that already exists, then it will work as expected.

This also illustrates that everything happens at
compile time.

NOTE:
This test might not be that useful, consider reworking
it to something that actually illustrates both sides
of the case.

=cut

our $BAZ; BEGIN { $BAZ = [] };

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has bar => ( default => sub { +{ baz => $::BAZ } } );

    sub bar { $_[0]->{bar} }
}

my $foo = Foo->new;
is_deeply( $foo->bar, { baz => [] }, '... got the expected value' );
is( $foo->bar->{'baz'}, $BAZ, '... these are the same values' );

{
    my $foo2 = Foo->new;
    is_deeply( $foo2->bar, { baz => [] }, '... got the expected value' );

    isnt( $foo->bar, $foo2->bar, '... these are the same values' );
    is( $foo2->bar->{'baz'}, $BAZ, '... these are the same values' );
    is( $foo->bar->{'baz'}, $foo2->bar->{'baz'}, '... these are the same values' );
}

package Bar {
    use Moxie;

    extends 'MOP::Object';

    has bar => ( default => sub { +{ baz => $::BAZ } } );

    sub bar { $_[0]->{bar} }
}

my $bar = Bar->new;
is_deeply( $bar->bar, { baz => [] }, '... got the expected value' );

{
    my $bar2 = Bar->new;
    is_deeply( $bar2->bar, { baz => [] }, '... got the expected value' );

    isnt( $bar->bar, $bar2->bar, '... these are not the same values' );
    is( $bar->bar->{'baz'}, $bar2->bar->{'baz'}, '... these are not the same values' );
}

done_testing;

