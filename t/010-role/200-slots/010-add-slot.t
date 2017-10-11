#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

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

    our $foo_initializer = sub { 'Foo::foo' };

    package Bar;
    use strict;
    use warnings;

    our $bar_initializer = sub { 'Bar::bar' };

    our %HAS;
}

subtest '... simple adding a slot test' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     0, '... no slots');
    is(scalar @regular_slots, 0, '... no regular slot');
    is(scalar @aliased_slots, 0, '... no aliased slots');

    ok(!$role->has_slot('foo'), '... we have a no foo slot');
    my $slot = $role->get_slot('foo');
    ok(!$slot, '... we can not get the foo attirbute');

    is(
        exception { $role->add_slot( foo => $Foo::foo_initializer ) },
        undef,
        '... added the slot successfully'
    );

    my $a = $role->get_slot('foo');
    isa_ok($a, 'MOP::Slot');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_stash, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::foo_initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the slot belongs to Foo');
};

subtest '... simple adding a slot test (when %HAS is present)' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     0, '... no slots');
    is(scalar @regular_slots, 0, '... no regular slot');
    is(scalar @aliased_slots, 0, '... no aliased slots');

    ok(!$role->has_slot('bar'), '... we have a no bar slot');
    my $slot = $role->get_slot('bar');
    ok(!$slot, '... we can not get the bar attirbute');

    is(
        exception { $role->add_slot( bar => $Bar::bar_initializer ) },
        undef,
        '... added the slot successfully'
    );

    my $a = $role->get_slot('bar');
    isa_ok($a, 'MOP::Slot');

    is($a->name, 'bar', '... got the name we expected');
    is($a->origin_stash, 'Bar', '... got the origin class we expected');
    is($a->initializer, $Bar::bar_initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Bar'), '... the slot belongs to Bar');
};

subtest '... testing error adding a slot whose initializer is not correct' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    is(
        exception { $role->add_slot( foo => sub { 0 } ) },
        undef,
        '... we can add an initializer that is not from the class, and it will be converted'
    );

    my $slot = $role->get_slot('foo');
    isa_ok($slot, 'MOP::Slot');

    is($slot->origin_stash, 'Foo', '... the origin stash has been set correctly');
};

done_testing;
