#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Module');
    use_ok('MOP::Internal::Util');
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
        MOP::Internal::Util::INSTALL_FINALIZATION_RUNNER( __PACKAGE__ );

        my $m = MOP::Module->new( name => __PACKAGE__ );
        $m->add_finalizer(sub { $m->set_is_closed(1) });
    }
}

my $module = MOP::Module->new( name => 'Foo' );
isa_ok($module, 'MOP::Module');

subtest '... testing module is closed already' => sub {
    ok($module->is_closed, '... the module is now closed');

    like(
        exception{ $module->add_finalizer( sub {} ) },
        qr/^\[CLOSED] Cannot add a finalizer to a package which has been closed/,
        '... unsuccessfully added finalizer'
    );
};

done_testing;
