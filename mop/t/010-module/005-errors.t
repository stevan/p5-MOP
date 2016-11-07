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

subtest '... simple mop::module error test' => sub {

    like(
        exception { mop::module->new },
        qr/^\[ARGS\] You must specify a package name/,
        '... got the expection we expected'
    );
};

done_testing;
