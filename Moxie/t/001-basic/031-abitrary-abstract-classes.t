#!perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    our $IS_ABSTRACT; BEGIN {
        $IS_ABSTRACT = 1;
    }
}

ok(MOP::Class->new( name => 'Foo' )->is_abstract, '... Foo is an abstract class');

eval { Foo->new };
like(
    $@,
    qr/^\[ABSTRACT\] Cannot create an instance of \'Foo\'\, it is abstract/,
    '... cannot create an instance of abstract class Foo'
);

package Bar {
    use Moxie;

    extends 'Foo';
}

ok(!MOP::Class->new( name => 'Bar' )->is_abstract, '... Bar is not an abstract class');

{
    my $bar = eval { Bar->new };
    is($@, "", '... we can create an instance of Bar');
    isa_ok($bar, 'Bar');
    isa_ok($bar, 'Foo');
}

done_testing;
