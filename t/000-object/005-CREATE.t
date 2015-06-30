#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype blessed ];

BEGIN {
    use_ok('mop::object');
}

=pod

TODO:
- test for some failure conditions where CREATE
  does not behave properly, ex:
    - returning unblessed instance
    - not passing the prototype to next::method
- test using SUPER::CREATE as well
- test inheriting custom CREATE method
    - chaining CREATE methods along inheritance
- test under multiple inheritance
- test with %HAS values

=cut

{
    package Foo; 
    use strict;
    use warnings;
    our @ISA = 'mop::object';

    sub CREATE {
        my ($class, $proto) = @_;
        $proto->{foo} = 'BAR';
        $class->next::method( $proto );
    }
}

subtest '... simple CREATE test' => sub {
    my $o = Foo->new;
    isa_ok($o, 'Foo');
    isa_ok($o, 'mop::object');

    is(blessed $o, 'Foo', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');
    
    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

done_testing;
