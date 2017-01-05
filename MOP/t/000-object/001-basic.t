#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype blessed ];

BEGIN {
    use_ok('MOP::Object');
}

=pod

TODO:
- test calling ->new on an instance
    - test it under inheritance
- test overriding ->new
    - test that it bypasses the CREATE, BUILD, etc.
- do more elaborate tests with %HAS

=cut

{
    package Foo;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('MOP::Object') };
    our %HAS; BEGIN { %HAS = (foo => sub { 'FOO' }) };
}

subtest '... simple MOP::Object test' => sub {
    my $o = MOP::Object->new( foo => 'BAR' );
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'MOP::Object', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(!exists $o->{foo}, '... got the expected lack of a slot');
};

subtest '... simple MOP::Object subclass test' => sub {
    my $o = Foo->new( foo => 'BAR' );
    isa_ok($o, 'Foo');
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'Foo', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

subtest '... simple MOP::Object subclass test w/defaults' => sub {
    my $o = Foo->new;
    isa_ok($o, 'Foo');
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'Foo', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'FOO', '... the expected slot has the expected value');
};

done_testing;
