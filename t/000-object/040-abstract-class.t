#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Object');
}

=pod

TODO:
- test with %HAS values
- test the MOP::Internal::Util::IS_CLASS_ABSTRACT function here as well
    - the two APIs (MOP::Object::util & MOP-OO) should have
      the same end result

=cut

{
    package Foo;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('MOP::Object') }

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 1 };

    package Bar;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('MOP::Object') }
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
