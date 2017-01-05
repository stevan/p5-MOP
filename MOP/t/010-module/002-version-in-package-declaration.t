#!perl

use strict;
use warnings;

use Test::More (
    $^V lt v5.12
        ? (skip_all => 'This test only works for v5.12 and above')
        : ()
);

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('MOP::Module');
}

=pod

TODO:
- ???

=cut

{
    package Foo 0.01;
    use strict;
    use warnings;

    our $AUTHORITY = 'cpan:STEVAN';
}

subtest '... testing identity methods' => sub {
    my $module = MOP::Module->new( name => 'Foo' );
    isa_ok($module, 'MOP::Module');
    isa_ok($module, 'MOP::Object');

    ok(!blessed(\%Foo::), '... check that the stash did not get blessed');

    is($module->name,      'Foo',         '... got the expected name');
    is($module->version,   '0.01',        '... got the expected version');
    is($module->authority, 'cpan:STEVAN', '... got the expected authority');
};

done_testing;
