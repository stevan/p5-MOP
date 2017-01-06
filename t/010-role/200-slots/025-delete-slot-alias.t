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

subtest '... simple deleting an slot alias test' => sub {
    my $role = MOP::Role->new( name => 'Baz' );
    isa_ok($role, 'MOP::Role');

    my @all_slots     = $role->all_slots;
    my @regular_slots = $role->slots;
    my @aliased_slots = $role->aliased_slots;

    is(scalar @all_slots,     2, '... two slots');
    is(scalar @regular_slots, 1, '... one regular slot');
    is(scalar @aliased_slots, 1, '... one aliased slot');

    ok($role->has_slot_alias('foo'), '... we have a foo slot alias');

    is(
        exception { $role->delete_slot_alias( 'foo' ) },
        undef,
        '... deleted the slot alias successfully'
    );

    ok(!$role->has_slot_alias('foo'), '... we no longer have a foo slot alias');
};

subtest '... testing deleting an slot alias when there is no %HAS' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    is(
        exception { $role->delete_slot_alias( 'foo' ) },
        undef,
        '... deleted the slot successfully'
    );
};

subtest '... testing deleting an slot alias when there is a %HAS, but no entry for that item' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    is(
        exception { $role->delete_slot_alias( 'gorch' ) },
        undef,
        '... deleted the slot successfully'
    );
};

subtest '... testing trying to delete slot alias when it is a regular one' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

    like(
        exception { $role->delete_slot_alias( 'foo' ) },
        qr/^\[CONFLICT\] Cannot delete an slot alias \(foo\) when there is an regular slot already there/,
        '... could not delete an slot when the class has a regular slot'
    );
};


done_testing;
