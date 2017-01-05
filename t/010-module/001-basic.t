#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('MOP::Module');
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

    our $VERSION = '0.02';

    package Baz;
    use strict;
    use warnings;
}

subtest '... testing identity methods' => sub {
    my $module = MOP::Module->new( name => 'Foo' );
    isa_ok($module, 'MOP::Module');

    ok(!blessed(\%Foo::), '... check that the stash did not get blessed');

    is($module->name,      'Foo',         '... got the expected name');
    is($module->version,   '0.01',        '... got the expected version');
    is($module->authority, 'cpan:STEVAN', '... got the expected authority');
};

subtest '... testing identity methods w/ AUTHORITY missing' => sub {
    my $module = MOP::Module->new( name => 'Bar' );
    isa_ok($module, 'MOP::Module');

    ok(!blessed(\%Bar::), '... check that the stash did not get blessed');

    is($module->name,      'Bar',  '... got the expected name');
    is($module->version,   '0.02', '... got the expected version');
    is($module->authority, undef,  '... got the expected authority');
};

subtest '... testing identity methods w/ VERSION & AUTHORITY missing' => sub {
    my $module = MOP::Module->new( name => 'Baz' );
    isa_ok($module, 'MOP::Module');

    ok(!blessed(\%Baz::), '... check that the stash did not get blessed');

    is($module->name,      'Baz', '... got the expected name');
    is($module->version,   undef, '... got the expected version');
    is($module->authority, undef, '... got the expected authority');
};

done_testing;
