#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'collector' => ( default => sub { [] } );

    sub collector { $_[0]->{collector} };

    sub collect ($self, $stuff) {
        push @{ $_[0]->{collector} } => $stuff;
    }

    sub BUILD ($self, $params) {
        $self->collect( 'Foo' );
    }
}

package Bar {
    use Moxie;

    extends 'Foo';

    sub BUILD ($self, $params) {
        $self->collect( 'Bar' );
    }
}

package Baz {
    use Moxie;

    extends 'Bar';

    sub BUILD ($self, $params) {
        $self->collect( 'Baz' );
    }
}

my $foo = Foo->new;
is_deeply($foo->collector, ['Foo'], '... got the expected collection');

{
    my $foo2 = Foo->new;
    isnt( $foo->collector, $foo2->collector, '... we have two different array refs' );
}

my $bar = Bar->new;
is_deeply($bar->collector, ['Foo', 'Bar'], '... got the expected collection');
isnt( $foo->collector, $bar->collector, '... we have two different array refs' );

my $baz = Baz->new;
is_deeply($baz->collector, ['Foo', 'Bar', 'Baz'], '... got the expected collection');
isnt( $foo->collector, $baz->collector, '... we have two different array refs' );
isnt( $bar->collector, $baz->collector, '... we have two different array refs' );

done_testing;
