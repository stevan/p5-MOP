#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('MOP::Role');
}

=pod

TODO:
- test aliasing method when a class is closed
- test overwriting
    - alias overwrite regular
    - alias overwrite (satisfy) required
    - alias overwrite alias
- test that aliasing the method does not mess up the glob
    - this will require having @ and % values in the glob, etc.

=cut

{
    package Foo;
    use strict;
    use warnings;
}

subtest '... testing basics' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->has_method('foo'), '... no [foo] method to get');
    ok(!$Foo->get_method('foo'), '... no [foo] method to get');

    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');

    ok(!Foo->can('foo'), '... the [foo] method returns nothing for &can');

    my $Foo_foo_method = sub { 'Foo::foo' };

    $Foo->alias_method('foo' => $Foo_foo_method);

    can_ok('Foo', 'foo');

    ok($Foo->has_method_alias('foo'), '... the [foo] method is not an alias');

    ok(!$Foo->has_method('foo'), '... no [foo] method to get');
    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    subtest '... test the method object as well' => sub {
        my $m = $Foo->get_method_alias('foo');
        ok($m, '... got [foo] method now');
        isa_ok($m, 'MOP::Method');

        is($m->name, '__ANON__', '... got the name we expected');
        is($m->origin_stash, 'main', '... got the origin-class we expected');
        ok(!$m->is_required, '... the method is not required');

        is($m->body, Foo->can('foo'), '... the method body is what we expected');
        is($m->body, $Foo_foo_method, '... the method body is what we expected');
    };
};

done_testing;
