#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

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

subtest '... simple deleting an attribute test' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     1, '... one attributes');
    is(scalar @regular_attributes, 1, '... one regular attribute');
    is(scalar @aliased_attributes, 0, '... no aliased attributes');

    ok($role->has_attribute('foo'), '... we have a foo attribute');

    {
        my $attribute = $role->get_attribute('foo');
        ok($attribute, '... we can get the foo attirbute');
        isa_ok($attribute, 'mop::attribute');
        isa_ok($attribute, 'mop::object');
    }

    is(
        exception { $role->delete_attribute( 'foo' ) },
        undef,
        '... deleted the attribute successfully'
    );

    ok(!$role->has_attribute('foo'), '... we no longer have a foo attribute');
    {
        my $attribute = $role->get_attribute('foo');
        ok(!$attribute, '... we can not get the foo attirbute (it has been deleted)');
    }
};

subtest '... testing deleting an attribute when there is no %HAS' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    is(
        exception { $role->delete_attribute( 'foo' ) },
        undef,
        '... deleted the attribute successfully'
    );
};

subtest '... testing deleting an attribute when there is a %HAS, but no entry for that item' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    is(
        exception { $role->delete_attribute( 'gorch' ) },
        undef,
        '... deleted the attribute successfully'
    );
};

subtest '... testing trying to delete attribute when it is an alias' => sub {
    my $role = mop::role->new( name => 'Baz' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    like(
        exception { $role->delete_attribute( 'foo' ) },
        qr/^\[PANIC\] Cannot delete a regular attribute \(foo\) when there is an aliased attribute already there/,
        '... could not delete an attribute when the class is closed'
    );
};

subtest '... testing exception when role is closed' => sub {
    my $Foo = mop::role->new( name => 'Foo' );
    isa_ok($Foo, 'mop::role');
    isa_ok($Foo, 'mop::object');

    is(
        exception { $Foo->set_is_closed(1) },
        undef,
        '... closed class successfully'
    );

    like(
        exception { $Foo->delete_attribute( 'foo' ) },
        qr/^\[PANIC\] Cannot delete an attribute \(foo\) to \(Foo\) because it has been closed/,
        '... could not delete an attribute when the class is closed'
    );
};

done_testing;
