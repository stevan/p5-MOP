#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

sub init_foo { 'FOO' }

my $Slot = MOP::Slot->new( name => 'foo', initializer => \&init_foo );
isa_ok($Slot, 'MOP::Slot');

my @METHODS = qw[
    new
    name
    initializer
    origin_stash
    was_aliased_from
];

can_ok($Slot, $_) for @METHODS;

is($Slot->initializer, \&init_foo, '... got the expected initializer');
is($Slot->initializer->(), 'FOO', '... got the expected result from calling initializer');

is($Slot->name, 'foo', '... got the expected result from ->name');
is($Slot->origin_stash, 'main', '... got the expected result from ->origin_stash');

ok($Slot->was_aliased_from('main'), '... the method was aliased from main::');
ok(!$Slot->was_aliased_from('Foo'), '... the method was not aliased from Foo::');

done_testing;


