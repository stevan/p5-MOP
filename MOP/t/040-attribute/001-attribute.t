#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('MOP::Attribute');
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

subtest '... simple MOP::Attribute test' => sub {
    my $a = MOP::Attribute->new( name => 'foo', initializer => $Foo::HAS{foo} );
    isa_ok($a, 'MOP::Object');
    isa_ok($a, 'MOP::Attribute');

    is($a->name, 'foo', '... got the name we expected');
    is($a->origin_class, 'Foo', '... got the origin class we expected');
    is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

    ok($a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
};

done_testing;
