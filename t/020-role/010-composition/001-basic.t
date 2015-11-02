#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::role');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub foo { 'Foo::foo' }

    package Bar;
    use strict;
    use warnings;

    sub bar { 'Bar::bar' }

    package FooBar;
    use strict;
    use warnings;

    our @DOES; BEGIN { @DOES = ('Foo', 'Bar') }

    BEGIN {
        mop::internal::util::APPLY_ROLES(
            mop::role->new( name => __PACKAGE__ ),
            \@DOES,
            to => 'role'
        )
    }
}

subtest '... testing sub-roles' => sub {
    my $Foo = mop::role->new( name => 'Foo' );
    isa_ok($Foo, 'mop::role');

    ok($Foo->has_method('foo'), '... Foo has the foo method');

    my $Bar = mop::role->new( name => 'Bar' );
    isa_ok($Bar, 'mop::role');

    ok($Bar->has_method('bar'), '... Bar has the bar method');
};

subtest '... testing basics' => sub {
    my $role = mop::role->new( name => 'FooBar' );
    isa_ok($role, 'mop::role');

    ok($role->does_role('Foo'), '... we do the Foo role');
    ok($role->does_role('Bar'), '... we do the Bar role');

    ok($role->has_method_alias('foo'), '... we have the foo method aliased');
    ok($role->has_method_alias('bar'), '... we have the bar method aliased');

    my $foo = $role->get_method_alias('foo');
    isa_ok($foo, 'mop::method');

    is($foo->name, 'foo', '... got the expected name');
    is($foo->origin_class, 'Foo', '... got the expected origin class');
    is($foo->body, \&Foo::foo, '... got the expected body');
    ok(!$foo->is_required, '... not a required method');

    ok($foo->was_aliased_from('Foo'), '... this is from Foo');
    ok(!$foo->was_aliased_from('FooBar'), '... this is not aliased from FooBar');

    my $bar = $role->get_method_alias('bar');
    isa_ok($bar, 'mop::method');

    is($bar->name, 'bar', '... got the expected name');
    is($bar->origin_class, 'Bar', '... got the expected origin class');
    is($bar->body, \&Bar::bar, '... got the expected body');
    ok(!$bar->is_required, '... not a required method');

    ok($bar->was_aliased_from('Bar'), '... this is from Foo');
    ok(!$bar->was_aliased_from('FooBar'), '... this is not aliased from FooBar');
};

done_testing;
