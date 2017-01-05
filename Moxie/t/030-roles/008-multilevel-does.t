#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;
}

package Bar {
    use Moxie;

    with 'Foo';
}

package Baz {
    use Moxie;

    extends 'MOP::Object';
       with 'Bar';
}

ok(Baz->DOES('Bar'), '... Baz DOES Bar');
ok(Baz->DOES('Foo'), '... Baz DOES Foo');

package R1 {
    use Moxie;
}

package R2 {
    use Moxie;
}

package R3 {
    use Moxie;

    with 'R1', 'R2';
}

package C1 {
    use Moxie;

    extends 'MOP::Object';
       with 'R3';
}

ok(C1->DOES('R3'), '... C1 DOES R3');
ok(C1->DOES('R2'), '... C1 DOES R2');
ok(C1->DOES('R1'), '... C1 DOES R1');

done_testing;
