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

subtest '... simple deleting an attribute alias test' => sub {
    my $role = MOP::Role->new( name => 'Baz' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    my @all_attributes     = $role->all_attributes;
    my @regular_attributes = $role->attributes;
    my @aliased_attributes = $role->aliased_attributes;

    is(scalar @all_attributes,     2, '... two attributes');
    is(scalar @regular_attributes, 1, '... one regular attribute');
    is(scalar @aliased_attributes, 1, '... one aliased attribute');

    ok($role->has_attribute_alias('foo'), '... we have a foo attribute alias');

    is(
        exception { $role->delete_attribute_alias( 'foo' ) },
        undef,
        '... deleted the attribute alias successfully'
    );

    ok(!$role->has_attribute_alias('foo'), '... we no longer have a foo attribute alias');
};

subtest '... testing deleting an attribute alias when there is no %HAS' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    is(
        exception { $role->delete_attribute_alias( 'foo' ) },
        undef,
        '... deleted the attribute successfully'
    );
};

subtest '... testing deleting an attribute alias when there is a %HAS, but no entry for that item' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    is(
        exception { $role->delete_attribute_alias( 'gorch' ) },
        undef,
        '... deleted the attribute successfully'
    );
};

subtest '... testing trying to delete attribute alias when it is a regular one' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');
    isa_ok($role, 'MOP::Object');

    like(
        exception { $role->delete_attribute_alias( 'foo' ) },
        qr/^\[CONFLICT\] Cannot delete an attribute alias \(foo\) when there is an regular attribute already there/,
        '... could not delete an attribute when the class is closed'
    );
};


done_testing;
