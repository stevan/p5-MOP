#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use MOP;

package Foo {
    use Moxie;

    sub bar;
}

package Gorch {
    use Moxie;

    extends 'MOP::Object';
       with 'Foo';

    our $IS_ABSTRACT; BEGIN {
        $IS_ABSTRACT = 1;
    }
}

package Bar {
    use Moxie;

    extends 'Gorch';
}

{
    my $meta = MOP::Class->new( name => 'Gorch' );
    ok($meta->is_abstract, '... composing a role with still required methods creates an abstract class');
    is_deeply(
        [ map { $_->name } $meta->required_methods ],
        [ 'bar' ],
        '... got the list of expected required methods for Gorch'
    );
    eval { Gorch->new };
    like(
        $@,
        qr/^\[ABSTRACT\] Cannot create an instance of \'Gorch\'\, it is abstract/,
        '... cannot create an instance of Gorch'
    );
}

{
    my $meta = MOP::Class->new( name => 'Bar' );
    ok($meta->is_abstract, '... composing a role with still required methods creates an abstract class');
    is_deeply(
        [ map { $_->name } $meta->required_methods ],
        [ 'bar' ],
        '... got the list of expected required methods for Bar'
    );
    eval { Bar->new };
    like(
        $@,
        qr/^\[ABSTRACT\] Cannot create an instance of \'Bar\'\, it is abstract/,
        '... cannot create an instance of Bar'
    );
}

done_testing;
