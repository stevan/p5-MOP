#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

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
}

my $module = MOP::Module->new( name => 'Foo' );
isa_ok($module, 'MOP::Module');

subtest '... testing finalizer methods' => sub {
    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
        ok(!$module->has_finalizers, '... we have no finalizers');
    }

    my $f1 = sub {};
    is(exception{ $module->add_finalizer( $f1 ) }, undef, '... successfully added finalizer');

    {
        my @finalizers = $module->finalizers;
        ok((scalar @finalizers), '... got finalizers now');
        is(scalar @finalizers, 1, '... got one finalizer');
        is($finalizers[0], $f1, '... and it is the CODE ref we expected');

        ok($module->has_finalizers, '... we have finalizers');
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
        qr/^\[CLOSED] Cannot add a finalizer to a package which has been closed/,
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
