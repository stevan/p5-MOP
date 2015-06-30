#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::object');
}

=pod

TODO:
- tests for DEMOLISH under multiple-inheritance
- test with %HAS values that need destroying

=cut

my $COLLECTOR;

{
    package Foo;
    use strict;
    use warnings;
    our @ISA = ('mop::object');

    sub collect {
        my ($self, $stuff) = @_;
        push @$COLLECTOR => $stuff;
    }

    sub DEMOLISH {
        $_[0]->collect( 'Foo' );
    }

    package Bar;
    use strict;
    use warnings;
    our @ISA = ('Foo');

    sub DEMOLISH {
        $_[0]->collect( 'Bar' );
    }

    package Baz;
    use strict;
    use warnings;
    our @ISA = ('Bar');

    sub DEMOLISH {
        $_[0]->collect( 'Baz' );
    }
}

subtest '... simple DEMOLISH test' => sub {
    $COLLECTOR = [];
    Foo->new;
    is_deeply($COLLECTOR, ['Foo'], '... got the expected collection');
};

subtest '... complex DEMOLISH test' => sub {
    $COLLECTOR = [];
    Bar->new;
    is_deeply($COLLECTOR, ['Bar', 'Foo'], '... got the expected collection');
};

subtest '... more complex DEMOLISH test' => sub {
    $COLLECTOR = [];
    Baz->new;
    is_deeply($COLLECTOR, ['Baz', 'Bar', 'Foo'], '... got the expected collection');
};

done_testing;