#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype blessed ];

BEGIN {
    use_ok('mop::object');
}

=pod

TODO:
- tests for BUILD under multiple-inheritance
- tests where BUILD alters the instance
    - test this under inheritance
- test with %HAS values

=cut

{
    package Foo;
    use strict;
    use warnings;
    our @ISA = ('mop::object');

    sub CREATE {
        my ($class, $proto) = @_;
        $proto->{collector} = [];
        $class->next::method( $proto );
    }

    sub BUILD {
        $_[0]->collect( 'Foo' );
    }

    sub collector { $_[0]->{collector} };

    sub collect {
        my ($self, $stuff) = @_;
        push @{ $self->{collector} } => $stuff;
    }    

    package Bar;
    use strict;
    use warnings;
    our @ISA = ('Foo');

    sub BUILD {
        $_[0]->collect( 'Bar' );
    }

    package Baz;
    use strict;
    use warnings;
    our @ISA = ('Bar');

    sub BUILD {
        $_[0]->collect( 'Baz' );
    }
}

my $foo = Foo->new;
my $bar = Bar->new;
my $baz = Baz->new;

subtest '... simple BUILD test' => sub {
    isa_ok($foo, 'Foo');
    isa_ok($foo, 'mop::object');

    is(blessed $foo, 'Foo', '... got the expected class name');
    is(reftype $foo, 'HASH', '... got the expected default repr type');
    
    is_deeply($foo->collector, ['Foo'], '... got the expected collection');

    subtest '... making sure BUILD creates new values' => sub {
        my $foo2 = Foo->new;
        isnt( $foo->collector, $foo2->collector, '... we have two different array refs' );
    };
};

subtest '... complex BUILD test' => sub {
    isa_ok($bar, 'Bar');
    isa_ok($bar, 'Foo');
    isa_ok($bar, 'mop::object');

    is(blessed $bar, 'Bar', '... got the expected class name');
    is(reftype $bar, 'HASH', '... got the expected default repr type');

    is_deeply($bar->collector, ['Foo', 'Bar'], '... got the expected collection');

    subtest '... making sure BUILD creates new values' => sub {
        isnt( $foo->collector, $bar->collector, '... we have two different array refs' );    
    };
};

subtest '... more complex BUILD test' => sub {
    isa_ok($baz, 'Baz');
    isa_ok($baz, 'Bar');
    isa_ok($baz, 'Foo');
    isa_ok($baz, 'mop::object');

    is(blessed $baz, 'Baz', '... got the expected class name');
    is(reftype $baz, 'HASH', '... got the expected default repr type');

    is_deeply($baz->collector, ['Foo', 'Bar', 'Baz'], '... got the expected collection');

    subtest '... making sure BUILD creates new values' => sub {
        isnt( $foo->collector, $baz->collector, '... we have two different array refs' );
        isnt( $bar->collector, $baz->collector, '... we have two different array refs' );
    };
};

done_testing;
