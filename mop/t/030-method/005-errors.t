#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::method');
}

=pod

TODO:

=cut

subtest '... simple mop::method error test' => sub {

    like(
        exception { mop::method->new },
        qr/^\[ARGS\] You must specify a method body/,
        '... got the expection we expected'
    );

    like(
        exception { mop::method->new( body => [] ) },
        qr/^\[ARGS\] The body specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

done_testing;
