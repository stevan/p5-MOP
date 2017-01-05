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

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our $IS_CLOSED = 0; # NOTE: this has to be initialized for the MOP::Object::util:: routines to work
}

my $module = MOP::Module->new( name => 'Foo' );
isa_ok($module, 'MOP::Module');

subtest '... testing closing methods' => sub {
    ok(!$module->is_closed, '... the module is not closed');

    $module->set_is_closed(1);
    ok($module->is_closed, '... the module is now closed');
    ok(MOP::Internal::Util::IS_CLASS_CLOSED($module->name), '... the module is now closed');

    $module->set_is_closed(0);
    ok(!$module->is_closed, '... the module is no longer closed');
    ok(!MOP::Internal::Util::IS_CLASS_CLOSED($module->name), '... the module is no longer closed');
};

done_testing;
