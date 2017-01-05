#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

# this comes up in, for instance, Plack::Middleware::wrap

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar' => ( is => 'ro' );

    sub baz ($self, $bar) {
        if (ref($self)) {
            $self->{bar} = $bar;
        }
        else {
            $self = __PACKAGE__->new(bar => $bar);
        }

        return $self->bar;
    }
}

is(Foo->baz('BAR-class'), 'BAR-class');
is(Foo->new->baz('BAR-instance'), 'BAR-instance');

done_testing;
