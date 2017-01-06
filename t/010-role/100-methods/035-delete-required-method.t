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
- test deleting when ...
    - alias method exists

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $bling = 100;

    sub foo;

    sub bar { 'Foo::bar' }
}

subtest '... testing deleting method alias' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->has_method('foo'), '... [foo] method to get');
    ok(!$Foo->get_method('foo'), '... [foo] method to get');

    ok($Foo->requires_method('foo'), '... the [foo] method is not required');
    ok($Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');

    can_ok('Foo', 'foo');

    $Foo->delete_required_method('foo');

    ok(!Foo->can('foo'), '... the [foo] method returns nothing for &can');
    ok(!$Foo->has_method('foo'), '... no [foo] method to get');
    ok(!$Foo->get_method('foo'), '... no [foo] method to get');

    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');
};

subtest '... testing deleting a required method that does not exist (but has glob already)' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    is($Foo::bling, 100, '... we have our package variable named same as our method');

    is(
        exception { $Foo->delete_required_method('bling') },
        undef,
        '... deleted required method successfully'
    );

    is($Foo::bling, 100, '... and our package variable is fine');
};

subtest '... testing deleting a required method that does not exist' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->delete_required_method('some_random_NAME'), '... got nothing back if the required method does not exist');
};

subtest '... testing deleting a required method that is actually a reqular method' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->requires_method('bar'), '... this method is not required (it is a regular method)');
    ok($Foo->has_method('bar'), '... this method is not required (it is a regular method)');

    like(
        exception { $Foo->delete_required_method('bar') },
        qr/^\[CONFLICT\] Cannot delete a required method \(bar\) when there is a regular method already there/,
        '... added the required method successfully'
    );

    ok(!$Foo->requires_method('bar'), '... this method is still not required');
    ok($Foo->has_method('bar'), '... this method is a regular method');

    is(exception { Foo->bar }, undef, '... and the method still behaves as we expect');
    is(Foo->bar, 'Foo::bar', '... and the method still behaves as we expect');
};

done_testing;
