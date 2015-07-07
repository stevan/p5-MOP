#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::module');
}

=pod

TODO:
- test the mop::util::IS_CLASS_CLOSED function here as well
    - the two APIs (mop::util & mop-OO) should have 
      the same end result

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';
}

my $module = mop::module->new( name => 'Foo' );
isa_ok($module, 'mop::module');

subtest '... testing closing methods' => sub {
    ok(!$module->is_closed, '... the module is not closed');

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');

    $module->set_is_closed(0);
    ok(!$module->is_closed, '... the module is no longer closed');
};

subtest '... testing errors after closed' => sub {
    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
    }

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');

    my $f = sub {};
    like(
        exception { $module->add_finalizer( $f ) }, 
        qr/^\[PANIC] Cannot add a finalizer to a package which has been closed/, 
        '... unsuccessfully added finalizer'
    );

    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
    }
};

done_testing;
