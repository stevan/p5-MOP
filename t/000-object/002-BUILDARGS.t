#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype ];

BEGIN {
    use_ok('mop::object');
}

subtest '... simple BUILDARGS test' => sub {
    {
        package Foo; 
        use strict;
        use warnings;
        our @ISA = 'mop::object';

        sub BUILDARGS {
            my ($class, $bar) = @_;
            return { foo => $bar }
        }
    }

    my $o = Foo->new( 'BAR' );
    isa_ok($o, 'Foo');
    isa_ok($o, 'mop::object');

    is(reftype $o, 'HASH', '... got the expected default repr type');
    
    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

done_testing;
