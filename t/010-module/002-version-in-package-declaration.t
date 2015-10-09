#!perl

use strict;
use warnings;

use Test::More skip_all => $^V lt v5.12;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('mop::module');
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
    my $module = mop::module->new( name => 'Foo' );
    isa_ok($module, 'mop::module');
    isa_ok($module, 'mop::object');

    ok(!blessed(\%Foo::), '... check that the stash did not get blessed');

    is($module->name,      'Foo',         '... got the expected name');
    is($module->version,   '0.01',        '... got the expected version');
    is($module->authority, 'cpan:STEVAN', '... got the expected authority');
};

done_testing;
