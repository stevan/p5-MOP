#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('MOP::Slot');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( foo => sub { 'Foo::foo' } )}
}

subtest '... simple MOP::Slot test' => sub {
    my $a = MOP::Slot->new( name => 'foo', initializer => $Foo::HAS{foo} );
    isa_ok($a, 'MOP::Object');
    isa_ok($a, 'MOP::Slot');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_class, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the slot belongs to Foo');
};

done_testing;
