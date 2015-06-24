#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ blessed ];

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

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';  

    package Bar;
    use strict;
    use warnings;

    our $VERSION   = '0.02';
    our $AUTHORITY = 'cpan:STEVAN';  

    our @DOES = ('Foo');      
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


done_testing;
