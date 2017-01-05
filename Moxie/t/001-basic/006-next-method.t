#!perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    sub foo { "FOO" }
    sub baz { "BAZ" }
}

package FooBar {
    use Moxie;

    extends 'Foo';

    sub foo ($self) { $self->next::method . "-FOOBAR" }
    sub bar ($self) { $self->next::can }
    sub baz ($self) { $self->next::can }
}

package FooBarBaz {
    use Moxie;

    extends 'FooBar';

    sub foo ($self) { $self->next::method . "-FOOBARBAZ" }
}

package FooBarBazGorch {
    use Moxie;

    extends 'FooBarBaz';

    sub foo ($self) { $self->next::method . "-FOOBARBAZGORCH" }
}

my $foo = FooBarBazGorch->new;
ok( $foo->isa( 'FooBarBazGorch' ), '... the object is from class FooBarBazGorch' );
ok( $foo->isa( 'FooBarBaz' ), '... the object is from class FooBarBaz' );
ok( $foo->isa( 'FooBar' ), '... the object is from class FooBar' );
ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );
ok( $foo->isa( 'MOP::Object' ), '... the object is derived from class Object' );

is( $foo->foo, 'FOO-FOOBAR-FOOBARBAZ-FOOBARBAZGORCH', '... got the chained super calls as expected');

is($foo->bar, undef, '... no next method');

my $method = $foo->baz;
is(ref $method, 'CODE', '... got back a code ref');
is($method->($foo), 'BAZ', '... got the method we expected');

done_testing;
