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
- test how required methods are composed

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

subtest '... testing setting a role that has required method' => sub {
    is($role->name, 'Foo', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract');

    ok(!$role->requires_method('bar'), '... this method is not required');
    ok($role->requires_method('baz'), '... this method is required');

    ok(!$role->get_required_method('bar'), '... this method is not required');

    subtest '.... testing get-ing a required method object' => sub {
        my $m = $role->get_required_method('baz');
        ok(defined $m, '... this method is required');
        isa_ok($m, 'mop::method');
        is($m->name, 'baz', '... got the expected name');
        is($m->origin_class, 'Foo', '... got the expected origin class');
        ok($m->is_required, '... this method is required');
        is($m->body, \&Foo::baz, '... got the expected body');
    };
};

subtest '... testing setting a role that has required method' => sub {
    ok(!$role->get_required_method('some_random_NAME'), '... got nothing back if the required method does not exist');
};

done_testing;
