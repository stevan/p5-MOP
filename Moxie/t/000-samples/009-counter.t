#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

package Counter {
    use Moxie;

    extends 'MOP::Object';

    use overload (
        '++' => 'inc',
        '--' => 'dec'
    );

    has 'count' => ( is => 'ro', default => sub { 0 } );

    # NOTE:
    # so apparently the overload
    # will pass more values to the
    # subroutines then just the
    # instance, no idea why though
    # it is mostly just garbage.
    # - SL
    sub inc ($self, @) { $self->{count}++ }
    sub dec ($self, @) { $self->{count}-- }
}

my $c = Counter->new;
isa_ok($c, 'Counter');

is($c->count, 0, '... count is 0');

$c++;
is($c->count, 1, '... count is 1');

$c->inc;
is($c->count, 2, '... count is 2');

$c--;
is($c->count, 1, '... count is 1 again');

$c->dec;
is($c->count, 0, '... count is 0 again');

done_testing;
