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

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our $IS_CLOSED = 0; # NOTE: this has to be initialized for the mop::object::util:: routines to work
}

my $module = mop::module->new( name => 'Foo' );
isa_ok($module, 'mop::module');

subtest '... testing closing methods' => sub {
    ok(!$module->is_closed, '... the module is not closed');

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');
    ok(mop::internal::util::IS_CLASS_CLOSED($module->name), '... the module is now closed');

    $module->set_is_closed(0);
    ok(!$module->is_closed, '... the module is no longer closed');
    ok(!mop::internal::util::IS_CLASS_CLOSED($module->name), '... the module is no longer closed');
};

subtest '... testing errors after closed' => sub {
    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
    }

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');
    ok(mop::internal::util::IS_CLASS_CLOSED($module->name), '... the module is now closed');

    my $f = sub {};
    like(
        exception { $module->add_finalizer( $f ) },
        qr/^\[CLOSED] Cannot add a finalizer to a package which has been closed/,
        '... unsuccessfully added finalizer'
    );

    {
        my @finalizers = $module->finalizers;
        ok(!(scalar @finalizers), '... no finalizers present');
    }
};

done_testing;
