#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    has 'bar' => (default => sub { 'bar' });
    sub bar ($self) { $self->{bar} }
}

package Bar {
    use Moxie;

    has 'foo' => (default => sub { 'foo' });
    sub foo ($self) { $self->{foo} }
}

package Baz {
    use Moxie;

    with 'Foo', 'Bar';

    sub baz ($self) { join ", "  => $self->bar, 'baz', $self->foo }
}

package Gorch {
    use Moxie;

    extends 'MOP::Object';
       with 'Baz';
}

ok( MOP::Role->new(name => 'Baz')->does_role( 'Foo' ), '... Baz does the Foo role');
ok( MOP::Role->new(name => 'Baz')->does_role( 'Bar' ), '... Baz does the Foo role');

my $bar_method = MOP::Role->new(name => 'Baz')->get_method('bar');
ok( $bar_method->isa( 'MOP::Method' ), '... got a method object' );
is( $bar_method->name, 'bar', '... got the method we expected' );

my $bar_attribute = MOP::Role->new(name => 'Baz')->get_attribute('bar');
ok( $bar_attribute->isa( 'MOP::Attribute' ), '... got an attribute object' );
is( $bar_attribute->name, 'bar', '... got the attribute we expected' );

my $foo_method = MOP::Role->new(name => 'Baz')->get_method('foo');
ok( $foo_method->isa( 'MOP::Method' ), '... got a method object' );
is( $foo_method->name, 'foo', '... got the method we expected' );

my $foo_attribute = MOP::Role->new(name => 'Baz')->get_attribute('foo');
ok( $foo_attribute->isa( 'MOP::Attribute' ), '... got an attribute object' );
is( $foo_attribute->name, 'foo', '... got the attribute we expected' );

my $baz_method = MOP::Role->new(name => 'Baz')->get_method('baz');
ok( $baz_method->isa( 'MOP::Method' ), '... got a method object' );
is( $baz_method->name, 'baz', '... got the method we expected' );

my $gorch = Gorch->new;
isa_ok($gorch, 'Gorch');
ok($gorch->DOES('Baz'), '... gorch does Baz');
ok($gorch->DOES('Bar'), '... gorch does Bar');
ok($gorch->DOES('Foo'), '... gorch does Foo');

is($gorch->baz, 'bar, baz, foo', '... got the expected output');

done_testing;
