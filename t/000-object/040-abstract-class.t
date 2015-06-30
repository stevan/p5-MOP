#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::object');
}

=pod

TODO:
- test with %HAS values

=cut

{
    package Foo;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('mop::object') }

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 1 };

    package Bar;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('mop::object') }
}

subtest '... testing constructor with abstract class' => sub {
    like(
        exception { Foo->new },
        qr/^\[ABSTRACT\] Cannot create an instance of \'Foo\'\, it is abstract/,
        '... got the exception we expected'
    );
    is(exception { Bar->new }, undef, '... got the lack of exception we expected');
};

done_testing;
