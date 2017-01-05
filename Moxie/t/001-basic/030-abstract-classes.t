#!perl

use strict;
use warnings;

use Test::More;

use MOP ();

package Foo {
    use Moxie;

    extends 'MOP::Object';

    sub bar;
}

ok(MOP::Class->new( name => 'Foo' )->requires_method('bar'), '... bar is a required method');
ok(MOP::Class->new( name => 'Foo' )->is_abstract, '... Foo is an abstract class');

eval { Foo->new };
like(
    $@,
    qr/^\[ABSTRACT\] Cannot create an instance of \'Foo\', it is abstract/,
    '... cannot create an instance of abstract class Foo'
);

package Bar {
    use Moxie;

    extends 'Foo';

    sub bar { 'Bar::bar' }
}

ok(!MOP::Class->new( name => 'Bar' )->requires_method('bar'), '... bar is a not required method');
ok(!MOP::Class->new( name => 'Bar' )->is_abstract, '... Bar is not an abstract class');

{
    my $bar = eval { Bar->new };
    is($@, "", '... we can create an instance of Bar');
    isa_ok($bar, 'Bar');
    isa_ok($bar, 'Foo');
}

package Baz {
    use Moxie;

    extends 'Bar';

    sub baz;
}

ok(!MOP::Class->new( name => 'Baz' )->requires_method('bar'), '... bar is a not required method');
ok(MOP::Class->new( name => 'Baz' )->requires_method('baz'), '... baz is a required method');
ok(MOP::Class->new( name => 'Baz' )->is_abstract, '... Baz is an abstract class');

eval { Baz->new };
like(
    $@,
    qr/^\[ABSTRACT\] Cannot create an instance of \'Baz\', it is abstract/,
    '... cannot create an instance of abstract class Baz'
);

package Gorch {
    use Moxie;

    extends 'Foo';
}

ok(MOP::Class->new( name => 'Gorch' )->requires_method('bar'), '... bar is a required method');
ok(MOP::Class->new( name => 'Gorch' )->is_abstract, '... Gorch is an abstract class');

eval { Gorch->new };
like(
    $@,
    qr/^\[ABSTRACT\] Cannot create an instance of \'Gorch\', it is abstract/,
    '... cannot create an instance of abstract class Gorch'
);

done_testing;
