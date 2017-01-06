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
    package Bar;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( bar => sub { 'Bar::bar' } ) }

    package Foo;
    use strict;
    use warnings;

    our %HAS; BEGIN { %HAS = ( %Bar::HAS ) }
}

subtest '... simple aliased MOP::Slot test' => sub {
    my $a = MOP::Slot->new( name => 'bar', initializer => $Foo::HAS{bar} );
    isa_ok($a, 'MOP::Slot');

    is($a->name, 'bar', '... got the name we expected');
    is($a->origin_stash, 'Bar', '... got the origin class we expected');
    is($a->initializer, $Foo::HAS{bar}, '... equivalant to the initializer we expected');
    is($a->initializer, $Bar::HAS{bar}, '... equivalant to the initializer we expected');

    ok(!$a->was_aliased_from('Foo'), '... the slot belongs to Foo');
    ok($a->was_aliased_from('Bar'), '... the slot belongs to Foo');
};

done_testing;
