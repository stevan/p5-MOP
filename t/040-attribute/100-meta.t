#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

sub init_foo { 'FOO' }

my $Attribute = MOP::Attribute->new( name => 'foo', initializer => \&init_foo );
isa_ok($Attribute, 'MOP::Attribute');

my @METHODS = qw[
    new
    name
    initializer
    origin_class
    was_aliased_from
];

can_ok($Attribute, $_) for @METHODS;

is($Attribute->initializer, \&init_foo, '... got the expected initializer');
is($Attribute->initializer->(), 'FOO', '... got the expected result from calling initializer');

is($Attribute->name, 'foo', '... got the expected result from ->name');
is($Attribute->origin_class, 'main', '... got the expected result from ->origin_class');

ok($Attribute->was_aliased_from('main'), '... the method was aliased from main::');
ok(!$Attribute->was_aliased_from('Foo'), '... the method was not aliased from Foo::');

done_testing;


