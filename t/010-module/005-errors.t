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

subtest '... simple MOP::Module error test' => sub {

    like(
        exception { MOP::Module->new },
        qr/^\[ARGS\] You must specify a package name/,
        '... got the expection we expected'
    );
};

done_testing;
