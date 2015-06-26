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
- test that overwriting an existing required method changes nothing
    - this might require checking the "hex id" of the CV
- test that adding the required method does not mess up the glob
    - this will require having @ and % values in the glob, etc.

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub bar { 'BAR' }
    sub baz;
}

my $role = mop::role->new( name => 'Foo' );
isa_ok($role, 'mop::role');
# does_ok($role, 'mop::module'); # TODO
isa_ok($role, 'mop::object');

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
};

subtest '... testing overwriting a regular method with a required method (it should fail)' => sub {
    ok(!$role->requires_method('bar'), '... this method is not required (it is a regular method)');

    like(
        exception { $role->add_required_method('bar') },
        qr/^\[PANIC\] Cannot add a required method \(bar\) when there is a regular method already there/,
        '... added the required method successfully'
    ); 

    ok(!$role->requires_method('bar'), '... this method is still not required');
    is(exception { Foo->bar }, undef, '... and the method still behaves as we expect');     
};


done_testing;
