#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::attribute');
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

subtest '... simple mop::attribute test' => sub {
    my $a = mop::attribute->new( name => 'foo', initializer => $Foo::HAS{foo} );
    isa_ok($a, 'mop::object');
    isa_ok($a, 'mop::attribute');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_class, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
};

done_testing;
