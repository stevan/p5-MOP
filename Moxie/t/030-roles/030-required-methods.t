#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use MOP;

package Foo {
    use Moxie;

    sub bar;
}

my $correct_code = q[
    package Bar::Correct {
        use Moxie;

        extends 'MOP::Object';
           with 'Foo';

        has 'bar' => ( is => 'ro' );
    }
];

my $incorrect_code = q[
    package Bar::Incorrect {
        use Moxie;

        extends 'MOP::Object';
           with 'Foo';

        has 'bar';
    }
];

ok(not(do { local $@ = undef; eval $correct_code; $@ }), '... this code compiled correctly');
like(
    do { local $@ = undef; eval $incorrect_code; $@ },
    qr/^\[MOP\:\:PANIC\] There should be no required methods when composing \(Foo\) into \(Bar\:\:Incorrect\) but instead we found \(bar\)/,
    '... this code failed to compile correctly'
);


done_testing;
