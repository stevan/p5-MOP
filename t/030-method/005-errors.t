#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Method');
}

=pod

TODO:

=cut

subtest '... simple MOP::Method error test' => sub {

    like(
        exception { MOP::Method->new },
        qr/^\[ARGS\] You must specify a method body/,
        '... got the expection we expected'
    );

    like(
        exception { MOP::Method->new( body => [] ) },
        qr/^\[ARGS\] The body specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

done_testing;
