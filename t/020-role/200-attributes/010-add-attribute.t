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

    our $foo_initializer = sub { 'Foo::foo' };    
}

subtest '... simple adding an attribute test' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;    
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     0, '... no attributes');
    is(scalar @regular_attributes, 0, '... no regular attribute');
    is(scalar @aliased_attributes, 0, '... no aliased attributes');

    ok(!$role->has_attribute('foo'), '... we have a no foo attribute');
    my $attribute = $role->get_attribute('foo');
    ok(!$attribute, '... we can not get the foo attirbute');

    is(
        exception { $role->add_attribute( foo => $Foo::foo_initializer ) },
        undef,
        '... added the attribute successfully'
    );

    my $a = $role->get_attribute('foo');
    isa_ok($a, 'mop::object');
    isa_ok($a, 'mop::attribute');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_class, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::foo_initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
};

subtest '... simple adding an attribute test' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    isa_ok($role, 'mop::object');

    like(
        exception { $role->add_attribute( foo => sub { 0 } ) },
        qr/^\[PANIC\] Attribute is not from the local class \(Foo\)\, it is from \(main\)/,
        '... cannot add an initializer that is not from the class'
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
        exception { $Foo->add_attribute( foo => $Foo::foo_initializer ) },
        qr/^\[PANIC\] Cannot add an attribute \(foo\) to \(Foo\) because it has been closed/,
        '... could not add an attribute when the class is closed'
    );
};

done_testing;
