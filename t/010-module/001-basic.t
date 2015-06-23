#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::module');
}

{
    package Foo;

    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    sub bar { 'Foo::bar' }
}

my $module = mop::module->new( name => 'Foo' );
isa_ok($module, 'mop::module');

subtest '... testing identity methods' => sub {
    is($module->name,      'Foo',         '... got the expected name');
    is($module->version,   '0.01',        '... got the expected version');
    is($module->authority, 'cpan:STEVAN', '... got the expected authority');
};

subtest '... testing closing methods' => sub {
    ok(!$module->is_closed, '... the module is not closed');

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');

    $module->set_is_closed(0);
    ok(!$module->is_closed, '... the module is no longer closed');
};

subtest '... testing finalizer methods' => sub {
    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
    }

    my $f1 = sub {};
    is(exception{ $module->add_finalizer( $f1 ) }, undef, '... successfully added finalizer');

    {
        my @finalizers = $module->finalizers;
        ok((scalar @finalizers), '... got finalizers now');
        is(scalar @finalizers, 1, '... got one finalizer');
        is($finalizers[0], $f1, '... and it is the CODE ref we expected');
    }

    my $f2 = sub {};
    is(exception{ $module->add_finalizer( $f2 ) }, undef, '... successfully added finalizer');

    {
        my @finalizers = $module->finalizers;
        ok((scalar @finalizers), '... got finalizers now');
        is(scalar @finalizers, 2, '... got two finalizers');
        is($finalizers[0], $f1, '... and it is the CODE ref we expected');
        is($finalizers[1], $f2, '... and it is the CODE ref we expected');
    }
};

subtest '... testing errors after closed' => sub {
        $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');

    my $f3 = sub {};
    like(
        exception{ $module->add_finalizer( $f3 ) }, 
        qr/^\[PANIC\@mop\:\:module\] Cannot add a finalizer to a module which has been closed/, 
        '... unsuccessfully added finalizer'
    );

    {
        my @finalizers = $module->finalizers;
        ok((scalar @finalizers), '... got finalizers now');
        is(scalar @finalizers, 2, '... got two finalizers still');
        isnt($finalizers[0], $f3, '... and it is not the CODE ref we expected');
        isnt($finalizers[1], $f3, '... and it is not the CODE ref we expected');
    }
};

done_testing;
