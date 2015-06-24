#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::module');
    use_ok('mop::internal::util');
}

=pod

TODO:
- test this with inheritance
    - and with multiple inheritance

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    BEGIN { 
        mop::internal::util::INSTALL_FINALIZATION_RUNNER( __PACKAGE__ );

        my $m = mop::module->new( name => __PACKAGE__ );
        $m->add_finalizer(sub { $m->set_is_closed(1) });
    }
}

my $module = mop::module->new( name => 'Foo' );
isa_ok($module, 'mop::module');

subtest '... testing module is closed already' => sub {
    ok($module->is_closed, '... the module is now closed');

    like(
        exception{ $module->add_finalizer( sub {} ) }, 
        qr/^\[PANIC] Cannot add a finalizer to a module which has been closed/, 
        '... unsuccessfully added finalizer'
    );
};

done_testing;
