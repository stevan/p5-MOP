#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::object');
}

{
    package Foo;
    use strict;
    use warnings;
    our @ISA = ('mop::object');

    sub foo { "FOO" }
    sub baz { "BAZ" }

    package FooBar;
    use strict;
    use warnings;
    our @ISA = ('Foo');

    sub foo { $_[0]->next::method . "-FOOBAR" }
    sub bar { $_[0]->next::can }
    sub baz { $_[0]->next::can }

    package FooBarBaz;
    use strict;
    use warnings;
    our @ISA = ('FooBar');

    sub foo { $_[0]->next::method . "-FOOBARBAZ" }

    package FooBarBazGorch;
    use strict;
    use warnings;
    our @ISA = ('FooBarBaz');

    sub foo { $_[0]->next::method . "-FOOBARBAZGORCH" }
}

my $foo = FooBarBazGorch->new;
ok( $foo->isa( 'FooBarBazGorch' ), '... the object is from class FooBarBazGorch' );
ok( $foo->isa( 'FooBarBaz' ), '... the object is from class FooBarBaz' );
ok( $foo->isa( 'FooBar' ), '... the object is from class FooBar' );
ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );
ok( $foo->isa( 'mop::object' ), '... the object is derived from class Object' );

is( $foo->foo, 'FOO-FOOBAR-FOOBARBAZ-FOOBARBAZGORCH', '... got the chained super calls as expected');

is($foo->bar, undef, '... no next method');

my $method = $foo->baz;
is(ref $method, 'CODE', '... got back a code ref');
is($method->($foo), 'BAZ', '... got the method we expected');

done_testing;