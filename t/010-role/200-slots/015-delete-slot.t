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

subtest '... simple deleting an slot test' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     1, '... one slots');
    is(scalar @regular_slots, 1, '... one regular slot');
    is(scalar @aliased_slots, 0, '... no aliased slots');

    ok($role->has_slot('foo'), '... we have a foo slot');

    {
        my $slot = $role->get_slot('foo');
        ok($slot, '... we can get the foo slot');
        isa_ok($slot, 'MOP::Slot');
    }

    is(
        exception { $role->delete_slot( 'foo' ) },
        undef,
        '... deleted the slot successfully'
    );

    ok(!$role->has_slot('foo'), '... we no longer have a foo slot');
    {
        my $slot = $role->get_slot('foo');
        ok(!$slot, '... we can not get the foo slot (it has been deleted)');
    }
};

subtest '... testing deleting an slot when there is no %HAS' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    is(
        exception { $role->delete_slot( 'foo' ) },
        undef,
        '... deleted the slot successfully'
    );
};

subtest '... testing deleting an slot when there is a %HAS, but no entry for that item' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    is(
        exception { $role->delete_slot( 'gorch' ) },
        undef,
        '... deleted the slot successfully'
    );
};

subtest '... testing trying to delete slot when it is an alias' => sub {
    my $role = MOP::Role->new( name => 'Baz' );
    isa_ok($role, 'MOP::Role');

    like(
        exception { $role->delete_slot( 'foo' ) },
        qr/^\[CONFLICT\] Cannot delete a regular slot \(foo\) when there is an aliased slot already there/,
        '... could not delete an slot when there is an alias'
    );
};

done_testing;
