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

=cut

{
    package Baz;
    use strict;
    use warnings;

    sub baz { 'Baz::baz' }

    package Foo;
    use strict;
    use warnings;

    our $bling = 100;

    sub foo { 'Foo::foo' }

    sub bar;

    {
        no warnings 'once';
        *baz = \&Baz::baz;
    }
}

subtest '... testing deleting method' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok($Foo->has_method('foo'), '... [foo] method to get');
    ok($Foo->get_method('foo'), '... [foo] method to get');

    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');

    can_ok('Foo', 'foo');

    $Foo->delete_method('foo');

    ok(!Foo->can('foo'), '... the [foo] method returns nothing for &can');
    ok(!$Foo->has_method('foo'), '... no [foo] method to get');
    ok(!$Foo->get_method('foo'), '... no [foo] method to get');

    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');
};

subtest '... testing deleting a method that does not exist (but has glob already)' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    is($Foo::bling, 100, '... we have our package variable named same as our method');

    is(
        exception { $Foo->delete_method('bling') },
        undef,
        '... deleted method successfully'
    );

    is($Foo::bling, 100, '... and our package variable is fine');
};

subtest '... testing deleting a method that does not exist' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->delete_method('some_random_NAME'), '... got nothing back if the method does not exist');
};

subtest '... testing deleting a method that is actually a required method' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->has_method('bar'), '... this method is required (not a regular method)');
    ok($Foo->requires_method('bar'), '... this method is required (not a regular method)');

    like(
        exception { $Foo->delete_method('bar') },
        qr/^\[CONFLICT\] Cannot delete a regular method \(bar\) when there is a required method already there/,
        '... failed adding the required method successfully'
    );

    ok($Foo->requires_method('bar'), '... this method is not required');
    ok(!$Foo->has_method('bar'), '... this method is not a regular method');
};

subtest '... testing deleting a method that is actually an aliased method' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok(!$Foo->has_method('baz'), '... this method is not a regular method');
    ok($Foo->has_method_alias('baz'), '... this method is an alias (not a regular method)');

    like(
        exception { $Foo->delete_method('baz') },
        qr/^\[CONFLICT\] Cannot delete a regular method \(baz\) when there is an aliased method already there/,
        '... failed adding the aliased method successfully'
    );

    ok($Foo->has_method_alias('baz'), '... this method is still an alias');
    ok(!$Foo->has_method('baz'), '... this method is not a regular method');
};

done_testing;
