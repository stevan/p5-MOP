#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('mop::role');
}

=pod

TODO:
- test more varients of role composition

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    package Bar;
    use strict;
    use warnings;

    our $VERSION   = '0.02';
    our $AUTHORITY = 'cpan:STEVAN';

    our @DOES = ('Foo');

    package Baz;
    use strict;
    use warnings;

    our $VERSION   = '0.03';
    our $AUTHORITY = 'cpan:STEVAN';

    package Gorch;
    use strict;
    use warnings;

    our $VERSION   = '0.04';
    our $AUTHORITY = 'cpan:STEVAN';
}

subtest '... testing basics' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    ok(!blessed(\%Foo::), '... check that the stash did not get blessed');

    is($role->name,      'Foo',         '... got the expected name');
    is($role->version,   '0.01',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    ok(!$role->is_abstract, '... the role is not abstract');

    is_deeply([ $role->roles ], [], '... this role does no roles');

    ok(!$role->does_role('Bar'), '... we do not do the role Bar');
};

subtest '... testing simple role relationships' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    ok(!blessed(\%Bar::), '... check that the stash did not get blessed');

    is($role->name,      'Bar',         '... got the expected name');
    is($role->version,   '0.02',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    ok(!$role->is_abstract, '... the role is not abstract');

    is_deeply([ $role->roles ], ['Foo'], '... this role does no roles');

    ok($role->does_role('Foo'), '... we do the role Foo');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar (ourselves)');
};

subtest '... testing setting roles' => sub {
    my $role = mop::role->new( name => 'Baz' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    ok(!blessed(\%Baz::), '... check that the stash did not get blessed');

    is($role->name,      'Baz',         '... got the expected name');
    is($role->version,   '0.03',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    ok(!$role->is_abstract, '... the role is not abstract');

    is_deeply([ $role->roles ], [], '... this role does no roles');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar');

    is(exception { $role->set_roles('Bar') }, undef, '... set the roles correctly');

    is_deeply([ $role->roles ], ['Bar'], '... this role does one role now');
    ok($role->does_role('Bar'), '... we do the role Bar');
    ok($role->does_role('Foo'), '... we do the role Foo (via Bar)');
};

subtest '... testing setting roles (on closed class)' => sub {
    my $role = mop::role->new( name => 'Gorch' );
    isa_ok($role, 'mop::role');
    # does_ok($role, 'mop::module'); # TODO
    isa_ok($role, 'mop::object');

    is($role->name,      'Gorch',         '... got the expected name');
    is($role->version,   '0.04',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    ok(!$role->is_abstract, '... the role is not abstract');

    is_deeply([ $role->roles ], [], '... this role does no roles');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar');

    $role->set_is_closed(1);

    like(
        exception { $role->set_roles('Bar') },
        qr/^\[PANIC\] Cannot add roles to a package which has been closed/,
        '... set the roles correctly'
    );

    is_deeply([ $role->roles ], [], '... this role does no roles');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar');

};


done_testing;
