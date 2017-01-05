#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

my ($foo, $bar);

package Foo {
    use Moxie;

    extends 'MOP::Object';

    sub foo ($self) { $::foo++ }
}

package Bar {
    use Moxie;

    sub foo ($self) {
        $self->next::method;
        $::bar++;
    }
}

package Baz {
    use Moxie;

    extends 'Foo';
       with 'Bar';
}

TODO: {
    local $TODO = 'next::method does not work unless we rename the method with Sub::Util::subname';
    my $baz = Baz->new;
    ($::foo, $::bar) = (0, 0);
    is(exception { $baz->foo }, undef, '... no exception calling ->foo');
    is($::foo, 1, '... Foo::foo was called (via next::method)');
    is($::bar, 1, '... Bar::foo was called (it was composed into Baz)');
}

done_testing;
