#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('mop');
}

{
    package Counter;
    use strict;
    use warnings;

    use overload (
        '++' => 'inc',
        '--' => 'dec'
    );

    our @ISA; BEGIN { @ISA = ('mop::object') }
    our %HAS; BEGIN {
        %HAS = (
            count => sub { 0 }
        )
    }

    sub count { $_[0]->{count} }

    # NOTE:
    # so apparently the overload
    # will pass more values to the
    # subroutines then just the
    # instance, no idea why though
    # it is mostly just garbage.
    # - SL
    sub inc { $_[0]->{count}++ }
    sub dec { $_[0]->{count}-- }
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
