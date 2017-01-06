#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('MOP::Role');
    use_ok('MOP::Slot');
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

subtest '... simple MOP::Slot test' => sub {

    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     1, '... only one slot');
    is(scalar @regular_slots, 1, '... only one slot');

    is(scalar @aliased_slots, 0, '... no aliased slots');

    ok($role->has_slot('foo'), '... we have a foo slot');
    my $slot = $role->get_slot('foo');
    ok($slot, '... we can get the foo attirbute');

    ok(!$role->has_slot('bar'), '... we do not have a bar slot');
    ok(!$role->get_slot('bar'), '... we can not get the bar slot');

    ok(!$role->has_slot_alias('foo'), '... our foo slot is not an alias');
    ok(!$role->get_slot_alias('foo'), '... therefore we can not get the foo slot alias');

    isnt($all_slots[0], $regular_slots[0], '... not the same instance though');
    isnt($slot, $all_slots[0], '... not the same instance though');

    foreach my $a ( $all_slots[0], $regular_slots[0], $slot ) {
        isa_ok($a, 'MOP::Slot');

        is($a->name, 'foo', '... got the name we expected');
        is($a->origin_stash, 'Foo', '... got the origin class we expected');
        is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

        ok($a->was_aliased_from('Foo'), '... the slot belongs to Foo');
    }
};

subtest '... simple test when no %HAS is present' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    my @all_slots = $role->all_slots;
    is(scalar @all_slots, 0, '... no slots');

    ok(!$role->has_slot('bar'), '... we do not have a bar slot');
    ok(!$role->get_slot('bar'), '... we do not have a bar slot');

    ok(!$role->has_slot_alias('bar'), '... we do not have a bar slot');
    ok(!$role->get_slot_alias('bar'), '... we do not have a bar slot');
};

subtest '... simple MOP::Slot test with aliases' => sub {
    my $role = MOP::Role->new( name => 'Baz' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     2, '... only one slot');
    is(scalar @regular_slots, 1, '... only one slot');
    is(scalar @aliased_slots, 1, '... only one aliased slots');

    ok($role->has_slot_alias('foo'), '... we have a foo slot alias');
    my $slot = $role->get_slot_alias('foo');
    ok($slot, '... we can get the baz slot alias');

    ok(!$role->has_slot('foo'), '... we do not have a foo slot (it is an alias)');
    ok(!$role->get_slot('foo'), '... we can not get the foo slot (it is an alias)');

    ok(!$role->has_slot_alias('baz'), '... our baz slot is not an alias');
    ok(!$role->get_slot_alias('baz'), '... therefore we can not get the baz slot alias');
};

subtest '... testing getting an slot alias that does not exist' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    ok(!$role->get_slot_alias('some_random_NAME'), '... got nothing back if the aliased slot does not exist');
    ok(!$role->has_slot_alias('some_random_NAME'), '... got nothing back if the aliased slot does not exist');
};

done_testing;
