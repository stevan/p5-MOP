#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP');
    use_ok('MOP::Role');
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
        MOP::Util::defer_until_UNITCHECK(sub {
            MOP::Util::compose_roles( MOP::Util::get_meta( __PACKAGE__ ) )
        })
    }
}

subtest '... testing sub-roles' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    ok($Foo->has_method('foo'), '... Foo has the foo method');

    my $Bar = MOP::Role->new( name => 'Bar' );
    isa_ok($Bar, 'MOP::Role');

    ok($Bar->has_method('bar'), '... Bar has the bar method');
};

subtest '... testing basics' => sub {
    my $role = MOP::Role->new( name => 'FooBar' );
    isa_ok($role, 'MOP::Role');

    ok($role->does_role('Foo'), '... we do the Foo role');
    ok($role->does_role('Bar'), '... we do the Bar role');

    ok($role->has_method_alias('foo'), '... we have the foo method aliased');
    ok($role->has_method_alias('bar'), '... we have the bar method aliased');

    my $foo = $role->get_method_alias('foo');
    isa_ok($foo, 'MOP::Method');

    is($foo->name, 'foo', '... got the expected name');
    is($foo->origin_stash, 'Foo', '... got the expected origin class');
    is($foo->body, \&Foo::foo, '... got the expected body');
    ok(!$foo->is_required, '... not a required method');

    ok($foo->was_aliased_from('Foo'), '... this is from Foo');
    ok(!$foo->was_aliased_from('FooBar'), '... this is not aliased from FooBar');

    my $bar = $role->get_method_alias('bar');
    isa_ok($bar, 'MOP::Method');

    is($bar->name, 'bar', '... got the expected name');
    is($bar->origin_stash, 'Bar', '... got the expected origin class');
    is($bar->body, \&Bar::bar, '... got the expected body');
    ok(!$bar->is_required, '... not a required method');

    ok($bar->was_aliased_from('Bar'), '... this is from Foo');
    ok(!$bar->was_aliased_from('FooBar'), '... this is not aliased from FooBar');
};

done_testing;
