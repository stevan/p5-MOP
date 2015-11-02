#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('mop');
}

sub foo { 'FOO' }

{
    my $Method = mop::method->new( body => \&foo );
    isa_ok($Method, 'mop::method');

    my @METHODS = qw[
        new

        body

        name
        origin_class
        was_aliased_from
    ];

    can_ok($Method, $_) for @METHODS;

    is($Method->body, \&foo, '... got the expected body');
    is($Method->body->(), 'FOO', '... got the expected result from calling body');

    is($Method->name, 'foo', '... got the expected result from ->name');
    is($Method->origin_class, 'main', '... got the expected result from ->origin_class');

    ok($Method->was_aliased_from('main'), '... the method was aliased from main::');
    ok(!$Method->was_aliased_from('Foo'), '... the method was not aliased from Foo::');
}

{
    my $anon   = sub { 'ANON' };
    my $Method = mop::method->new( body => $anon );
    isa_ok($Method, 'mop::method');

    my @METHODS = qw[
        new

        body

        name
        origin_class
        was_aliased_from
    ];

    can_ok($Method, $_) for @METHODS;

    is($Method->body, $anon, '... got the expected body');
    is($Method->body->(), 'ANON', '... got the expected result from calling body');

    is($Method->name, '__ANON__', '... got the expected result from ->name');
    is($Method->origin_class, 'main', '... got the expected result from ->origin_class');

    ok($Method->was_aliased_from('main'), '... the method was aliased from main::');
    ok(!$Method->was_aliased_from('Foo'), '... the method was not aliased from Foo::');
}

done_testing;


