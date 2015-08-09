#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::attribute');
}

=pod

TODO:

=cut

subtest '... simple mop::attribute error test' => sub {

    like(
        exception { mop::attribute->new },
        qr/^\[MISSING_ARG\] You must specify an attribute name/,
        '... got the expection we expected'
    );

    like(
        exception { mop::attribute->new( name => 'foo' ) },
        qr/^\[MISSING_ARG\] You must specify an attribute initializer/,
        '... got the expection we expected'
    );

    like(
        exception { mop::attribute->new( name => 'foo', initializer => [] ) },
        qr/^\[INVALID_ARG\] The initializer specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

done_testing;
