#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('MOP::Role');
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

my %cases = (
    '... basic constructor'        => sub { MOP::Role->new( name => 'Foo' )     },
    '... HASH ref constructor'     => sub { MOP::Role->new( { name => 'Foo' } ) },
    '... package name constructor' => sub { MOP::Role->new( 'Foo' )             },
    '... stash ref constructor'    => sub { MOP::Role->new( \%Foo:: )           },
);

foreach my $case ( keys %cases ) {
    subtest $case => sub {
        my $role = $cases{ $case }->();
        isa_ok($role, 'MOP::Role');

        ok(!blessed(\%Foo::), '... check that the stash did not get blessed');

        is($role->name,      'Foo',         '... got the expected name');
        is($role->version,   '0.01',        '... got the expected version');
        is($role->authority, 'cpan:STEVAN', '... got the expected authority');

        is_deeply([ $role->roles ], [], '... this role does no roles');

        ok(!$role->does_role('Bar'), '... we do not do the role Bar');
    };
}

subtest '... testing simple role relationships' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    ok(!blessed(\%Bar::), '... check that the stash did not get blessed');

    is($role->name,      'Bar',         '... got the expected name');
    is($role->version,   '0.02',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    is_deeply([ $role->roles ], ['Foo'], '... this role does no roles');

    ok($role->does_role('Foo'), '... we do the role Foo');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar (ourselves)');
};

subtest '... testing setting roles' => sub {
    my $role = MOP::Role->new( name => 'Baz' );
    isa_ok($role, 'MOP::Role');

    ok(!blessed(\%Baz::), '... check that the stash did not get blessed');

    is($role->name,      'Baz',         '... got the expected name');
    is($role->version,   '0.03',        '... got the expected version');
    is($role->authority, 'cpan:STEVAN', '... got the expected authority');

    is_deeply([ $role->roles ], [], '... this role does no roles');
    ok(!$role->does_role('Bar'), '... we do not do the role Bar');

    is(exception { $role->set_roles('Bar') }, undef, '... set the roles correctly');

    is_deeply([ $role->roles ], ['Bar'], '... this role does one role now');
    ok($role->does_role('Bar'), '... we do the role Bar');
    ok($role->does_role('Foo'), '... we do the role Foo (via Bar)');
};

done_testing;
