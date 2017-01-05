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
    package Bar;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( bar => sub { 'Bar::bar' } ) }

    package Foo;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( %Bar::HAS ) }
}

subtest '... simple aliased MOP::Attribute test' => sub {
    my $a = MOP::Attribute->new( name => 'bar', initializer => $Foo::HAS{bar} );
    isa_ok($a, 'MOP::Object');
    isa_ok($a, 'MOP::Attribute');

    is($a->name, 'bar', '... got the name we expected');
    is($a->origin_class, 'Bar', '... got the origin class we expected');
    is($a->initializer, $Foo::HAS{bar}, '... equivalant to the initializer we expected');
    is($a->initializer, $Bar::HAS{bar}, '... equivalant to the initializer we expected');

    ok(!$a->was_aliased_from('Foo'), '... the attribute belongs to Foo');
    ok($a->was_aliased_from('Bar'), '... the attribute belongs to Foo');
};

done_testing;
