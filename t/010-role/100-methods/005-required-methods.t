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
- test how required methods are composed

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub bar { 'BAR' }
    sub baz;
}

my $role = MOP::Role->new( name => 'Foo' );
isa_ok($role, 'MOP::Role');

subtest '... testing setting a role that has required method' => sub {
    is($role->name, 'Foo', '... got the expected name');

    ok(!$role->requires_method('bar'), '... this method is not required');
    ok($role->requires_method('baz'), '... this method is required');
    ok($role->has_required_method('baz'), '... this method is required (has)');

    ok(!$role->get_required_method('bar'), '... this method is not required');

    subtest '.... testing get-ing a required method object' => sub {
        my $m = $role->get_required_method('baz');
        ok(defined $m, '... this method is required');
        isa_ok($m, 'MOP::Method');
        is($m->name, 'baz', '... got the expected name');
        is($m->origin_stash, 'Foo', '... got the expected origin class');
        ok($m->is_required, '... this method is required');
        is($m->body, Foo->can('baz'), '... got the expected body');
    };
};

subtest '... testing getting a required method that does not exist' => sub {
    ok(!$role->get_required_method('some_random_NAME'), '... got nothing back if the required method does not exist');
};

done_testing;
