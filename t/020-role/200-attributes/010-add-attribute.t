#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Role');
    use_ok('MOP::Attribute');
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

subtest '... simple adding an attribute test' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

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
    isa_ok($a, 'MOP::Object');
    isa_ok($a, 'MOP::Attribute');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_class, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::foo_initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
};

subtest '... simple adding an attribute test (when %HAS is present)' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     0, '... no attributes');
    is(scalar @regular_attributes, 0, '... no regular attribute');
    is(scalar @aliased_attributes, 0, '... no aliased attributes');

    ok(!$role->has_attribute('bar'), '... we have a no bar attribute');
    my $attribute = $role->get_attribute('bar');
    ok(!$attribute, '... we can not get the bar attirbute');

    is(
        exception { $role->add_attribute( bar => $Bar::bar_initializer ) },
        undef,
        '... added the attribute successfully'
    );

    my $a = $role->get_attribute('bar');
    isa_ok($a, 'MOP::Object');
    isa_ok($a, 'MOP::Attribute');

    is($a->name, 'bar', '... got the name we expected');
    is($a->origin_class, 'Bar', '... got the origin class we expected');
    is($a->initializer, $Bar::bar_initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Bar'), '... the attribute belongs to Bar');
};

subtest '... testing error adding an attribute whose initializer is not correct' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    like(
        exception { $role->add_attribute( foo => sub { 0 } ) },
        qr/^\[ERROR\] Attribute is not from local \(Foo\)\, it is from \(main\)/,
        '... cannot add an initializer that is not from the class'
    );
};

done_testing;
