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
- test the mop::util::IS_CLASS_ABSTRACT function here as well
    - the two APIs (mop::util & mop-OO) should have
      the same end result
- test setting abstract-ness from the Role API as well

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 1 };

    package Bar;
    use strict;
    use warnings;

    package Baz;
    use strict;
    use warnings;

    sub baz;

    package Gorch;
    use strict;
    use warnings;

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 0 };

    package Bling;
    use strict;
    use warnings;

    sub baz;

    our $IS_ABSTRACT; BEGIN { $IS_ABSTRACT = 0 };
}

subtest '... testing is_abstract' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Foo', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract');
    ok(mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is abstract');
};

subtest '... testing setting a role to be abstract' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Bar', '... got the expected name');
    ok(!$role->is_abstract, '... the role is not abstract');
    ok(!mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is not abstract');
    is(
        exception { $role->set_is_abstract(1) },
        undef,
        '... was able to set the abstract flag without issue'
    );
    ok($role->is_abstract, '... the role is now abstract');
    ok(mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is now abstract');
};

subtest '... testing setting a role that has required method' => sub {
    my $role = mop::role->new( name => 'Baz' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Baz', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract (even though we mark as not being so)');
    ok(!mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is (not) abstract according to the package');
    ok($role->requires_method('baz'), '... because the baz method is required');
    is(
        exception { $role->set_is_abstract(1) },
        undef,
        '... was able to set the abstract flag without issue'
    );
    ok($role->is_abstract, '... the role is abstract now');
    ok(mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is now abstract according to the package');
};

subtest '... testing setting a role to NOT be abstract' => sub {
    my $role = mop::role->new( name => 'Gorch' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Gorch', '... got the expected name');
    ok(!$role->is_abstract, '... the role is not abstract (because we marked it as not being so)');
    ok(!mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is (not) abstract according to the package');
};

subtest '... testing setting a role to NOT be abstract (w/ required method)' => sub {
    my $role = mop::role->new( name => 'Bling' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Bling', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract (even though we marked it as not being so)');
    ok(!mop::util::IS_CLASS_ABSTRACT($role->name), '... the role however is abstract according to the package');

    ok($role->requires_method('baz'), '... this is all because the &baz method is required');
};

subtest '... testing some edge cases ' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name, 'Foo', '... got the expected name');
    ok($role->is_abstract, '... the role is abstract');
    ok(mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is abstract');

    is(
        exception { $role->set_is_abstract(0) },
        undef,
        '... was able to set the abstract flag without issue'
    );

    ok(!$role->is_abstract, '... the role is not abstract (because we marked it as not being so)');
    ok(!mop::util::IS_CLASS_ABSTRACT($role->name), '... the role is (not) abstract according to the package');

    # close it ...
    $role->set_is_closed(1);

    like(
        exception { $role->set_is_abstract(1) },
        qr/^\[PANIC\] Cannot set a package to be abstract which has been closed/,
        '... set the roles correctly'
    );
};

done_testing;
