#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my $collector;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    sub collect ($self, $stuff) {
        push @{ $collector } => $stuff;
    }

    sub DEMOLISH ($self) {
        $self->collect( 'Foo' );
    }
}

package Bar {
    use Moxie;

    extends 'Foo';

    sub DEMOLISH ($self) {
        $self->collect( 'Bar' );
    }
}

package Baz {
    use Moxie;

    extends 'Bar';

    sub DEMOLISH ($self) {
        $self->collect( 'Baz' );
    }
}


$collector = [];
Foo->new;
is_deeply($collector, ['Foo'], '... got the expected collection');

$collector = [];
Bar->new;
is_deeply($collector, ['Bar', 'Foo'], '... got the expected collection');

$collector = [];
Baz->new;
is_deeply($collector, ['Baz', 'Bar', 'Foo'], '... got the expected collection');

done_testing;
