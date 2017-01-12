#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Slot');
}

=pod

TODO:

=cut

subtest '... simple MOP::Slot error test' => sub {

    like(
        exception { MOP::Slot->new( initializer => sub {}, foo => [] ) },
        qr/^\[ARGS\] You must specify a slot name/,
        '... got the expection we expected'
    );

    like(
        exception { MOP::Slot->new( name => 'foo', foo => [] ) },
        qr/^\[ARGS\] You must specify a slot initializer/,
        '... got the expection we expected'
    );

    like(
        exception { MOP::Slot->new( name => 'foo', initializer => [] ) },
        qr/^\[ARGS\] The initializer specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

done_testing;
