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
- ???

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 1 };

    package Bar;
    use strict;
    use warnings;
}

subtest '... testing is_abstract' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Foo', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract');
};

subtest '... testing setting a role to be abstract' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Bar', '... got the expected name');

    ok(!$role->is_abstract, '... the role is not abstract');
    is(
        exception { $role->set_is_abstract(1) },
        undef,
        '... was able to set the abstract flag without issue'
    );
    ok($role->is_abstract, '... the role is now abstract');
};

done_testing;
