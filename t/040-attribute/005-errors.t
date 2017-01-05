#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Attribute');
}

=pod

TODO:

=cut

subtest '... simple MOP::Attribute error test' => sub {

    like(
        exception { MOP::Attribute->new },
        qr/^\[ARGS\] You must specify an attribute name/,
        '... got the expection we expected'
    );

    like(
        exception { MOP::Attribute->new( name => 'foo' ) },
        qr/^\[ARGS\] You must specify an attribute initializer/,
        '... got the expection we expected'
    );

    like(
        exception { MOP::Attribute->new( name => 'foo', initializer => [] ) },
        qr/^\[ARGS\] The initializer specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

done_testing;
