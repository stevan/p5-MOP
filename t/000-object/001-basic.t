#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype ];

BEGIN {
    use_ok('mop::object');
}

subtest '... simple mop::object test' => sub {
    my $o = mop::object->new( foo => 'BAR' );
    isa_ok($o, 'mop::object');

    is(reftype $o, 'HASH', '... got the expected default repr type');
    
    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

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

subtest '... simple BUILD test' => sub {
    {
        package Bar; 
        use strict;
        use warnings;
        our @ISA = 'mop::object';

        sub BUILD {
            my $self = shift;
            $self->{foo} = 'BAR';
        }
    }

    my $o = Bar->new;
    isa_ok($o, 'Bar');
    isa_ok($o, 'mop::object');

    is(reftype $o, 'HASH', '... got the expected default repr type');
    
    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

subtest '... complex BUILD test' => sub {
    {
        package Baz; 
        use strict;
        use warnings;
        our @ISA = 'Bar';

        sub BUILD {
            my $self = shift;
            $self->{bar} = 'BAZ';
        }
    }
    
    my $o = Baz->new;
    isa_ok($o, 'Baz');
    isa_ok($o, 'Bar');
    isa_ok($o, 'mop::object');

    is(reftype $o, 'HASH', '... got the expected default repr type');
    
    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');

    ok(exists $o->{bar}, '... got the expected slot');
    is($o->{bar}, 'BAZ', '... the expected slot has the expected value');
};

done_testing;
