#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::role');
    use_ok('mop::attribute');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;
    
    our %HAS; BEGIN { %HAS = ( foo => sub { 'Foo::foo' } )}

    package Bar;
    use strict;
    use warnings;

    # NOTE: no %HAS here on purpose ...

    package Baz;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( %Foo::HAS, baz => sub { 'Baz::baz' } )}
}

subtest '... simple mop::attribute test' => sub {

    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;    
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     1, '... only one attribute');
    is(scalar @regular_attributes, 1, '... only one attribute');

    is(scalar @aliased_attributes, 0, '... no aliased attributes');

    ok($role->has_attribute('foo'), '... we have a foo attribute');
    my $attribute = $role->get_attribute('foo');
    ok($attribute, '... we can get the foo attirbute');

    ok(!$role->has_attribute('bar'), '... we do not have a bar attribute');
    ok(!$role->get_attribute('bar'), '... we can not get the bar attribute');

    ok(!$role->has_attribute_alias('foo'), '... our foo attribute is not an alias');
    ok(!$role->get_attribute_alias('foo'), '... therefore we can not get the foo attribute alias');

    isnt($all_attributes[0], $regular_attributes[0], '... not the same instance though');
    isnt($attribute, $all_attributes[0], '... not the same instance though');

    foreach my $a ( $all_attributes[0], $regular_attributes[0], $attribute ) {
        isa_ok($a, 'mop::object');
        isa_ok($a, 'mop::attribute');

        is($a->name, 'foo', '... got the name we expected');
        is($a->origin_class, 'Foo', '... got the origin class we expected');
        is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

        ok($a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
    }
};

subtest '... simple test when no %HAS is present' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    my @all_attributes = $role->all_attributes;
    is(scalar @all_attributes, 0, '... no attributes');

    ok(!$role->has_attribute('bar'), '... we do not have a bar attribute');
    ok(!$role->get_attribute('bar'), '... we do not have a bar attribute');

    ok(!$role->has_attribute_alias('bar'), '... we do not have a bar attribute');
    ok(!$role->get_attribute_alias('bar'), '... we do not have a bar attribute');    
};

subtest '... simple mop::attribute test with aliases' => sub {
    my $role = mop::role->new( name => 'Baz' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;    
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     2, '... only one attribute');
    is(scalar @regular_attributes, 1, '... only one attribute');
    is(scalar @aliased_attributes, 1, '... only one aliased attributes');

    ok($role->has_attribute_alias('foo'), '... we have a foo attribute alias');
    my $attribute = $role->get_attribute_alias('foo');
    ok($attribute, '... we can get the baz attribute alias');

    ok(!$role->has_attribute('foo'), '... we do not have a foo attribute (it is an alias)');
    ok(!$role->get_attribute('foo'), '... we can not get the foo attribute (it is an alias)');

    ok(!$role->has_attribute_alias('baz'), '... our baz attribute is not an alias');
    ok(!$role->get_attribute_alias('baz'), '... therefore we can not get the baz attribute alias');
};

subtest '... testing getting an attribute alias that does not exist' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    ok(!$role->get_attribute_alias('some_random_NAME'), '... got nothing back if the aliased attribute does not exist');
    ok(!$role->has_attribute_alias('some_random_NAME'), '... got nothing back if the aliased attribute does not exist');
};

done_testing;
