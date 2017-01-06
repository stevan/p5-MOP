#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Role');
}

=pod

TODO:
- test that overwriting an existing required method changes nothing
    - this might require checking the "hex id" of the CV
- test that adding the required method does not mess up the glob
    - this will require having @ and % values in the glob, etc.

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $bling = 100;

    sub bar { 'BAR' }
    sub baz;
}

my $role = MOP::Role->new( name => 'Foo' );
isa_ok($role, 'MOP::Role');

subtest '... testing creating a required method' => sub {
    ok(!$role->requires_method('bar'), '... this method is not required');
    ok($role->requires_method('baz'), '... this method is required');
    ok(!$role->requires_method('gorch'), '... this method is not required and does not even exist');

    is(
        exception { $role->add_required_method('gorch') },
        undef,
        '... added the required method successfully'
    );


    ok(!$role->requires_method('bar'), '... this method is not required (still)');
    ok($role->requires_method('baz'), '... this method is required (still)');
    ok($role->requires_method('gorch'), '... this method is now required because we made it so');

    like(
        exception { Foo->gorch },
        qr/^Undefined subroutine \&Foo\:\:gorch called/,
        '... and our successfully created required method behaves as we expect'
    );

    subtest '.... testing get-ing the required method object we just created' => sub {
        my $m = $role->get_required_method('gorch');
        ok(defined $m, '... this method is required');
        isa_ok($m, 'MOP::Method');
        is($m->name, 'gorch', '... got the expected name');
        is($m->origin_stash, 'Foo', '... got the expected origin class');
        ok($m->is_required, '... this method is required');
        is($m->body, Foo->can('gorch'), '... got the expected body');
    };
};

subtest '... testing adding a duplicate required method' => sub {
    is(
        exception { $role->add_required_method('gorch') },
        undef,
        '... added the duplicate required method successfully'
    );

    ok($role->requires_method('gorch'), '... this method is still required');
};

subtest '... testing overwriting a regular method with a required method (it should fail)' => sub {
    ok(!$role->requires_method('bar'), '... this method is not required (it is a regular method)');

    like(
        exception { $role->add_required_method('bar') },
        qr/^\[CONFLICT\] Cannot add a required method \(bar\) when there is a regular method already there/,
        '... added the required method successfully'
    );

    ok(!$role->requires_method('bar'), '... this method is still not required');
    is(exception { Foo->bar }, undef, '... and the method still behaves as we expect');
};

subtest '... testing creating a required method when glob is already there (w/out a CODE slot)' => sub {

    is($Foo::bling, 100, '... we have our package variable named same as our method');

    ok(!$role->requires_method('bling'), '... this method is not required and does not even exist');

    is(
        exception { $role->add_required_method('bling') },
        undef,
        '... added the required method successfully'
    );

    ok($role->requires_method('gorch'), '... this method is now required because we made it so');

    is($Foo::bling, 100, '... and our package variable is fine');

    like(
        exception { Foo->bling },
        qr/^Undefined subroutine \&Foo\:\:bling called/,
        '... and our successfully created required method behaves as we expect'
    );

    subtest '.... testing get-ing the required method object we just created' => sub {
        my $m = $role->get_required_method('bling');
        ok(defined $m, '... this method is required');
        isa_ok($m, 'MOP::Method');
        is($m->name, 'bling', '... got the expected name');
        is($m->origin_stash, 'Foo', '... got the expected origin class');
        ok($m->is_required, '... this method is required');
        is($m->body, Foo->can('bling'), '... got the expected body');
    };
};

subtest '... testing exception when method name is bad' => sub {
    my $Foo = MOP::Role->new( name => 'Foo' );
    isa_ok($Foo, 'MOP::Role');

    like(
        exception { $Foo->add_required_method('this-canno\tnbeaname') },
        qr/^Illegal declaration of subroutine /,
        '... could not add a required method whose name is not valid perl'
    );
};

done_testing;
