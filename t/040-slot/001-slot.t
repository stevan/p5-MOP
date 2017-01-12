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

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

    our %HAS; BEGIN { %HAS = ( foo => sub { 'Foo::foo' } )}

    package Bar;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

    our %HAS; BEGIN { %HAS = (
        bar => MOP::Slot->new(
            name        => 'bar',
            initializer => sub { 'Bar::bar' }
        )
    )}
}

my %cases = (
    '... key/value constructor'  => sub { MOP::Slot->new( name => 'foo', initializer => $Foo::HAS{foo} )     },
    '... HASH ref constructor'   => sub { MOP::Slot->new( { name => 'foo', initializer => $Foo::HAS{foo} } ) },
    '... hash entry constructor' => sub { MOP::Slot->new( foo => $Foo::HAS{foo} )                            },
);

foreach my $case ( keys %cases ) {
    subtest $case => sub {
        my $a = $cases{ $case }->();
        isa_ok($a, 'MOP::Slot');

        is($a->name, 'foo', '... got the name we expected');
        is($a->origin_stash, 'Foo', '... got the origin class we expected');
        is($a->initializer, $Foo::HAS{foo}, '... got the initializer we expected');

        ok($a->was_aliased_from('Foo'), '... the slot belongs to Foo');

        my $foo = Foo->new;
        isa_ok($foo, 'Foo');

        is($foo->{foo}, 'Foo::foo', '... the slot initialized correctly');
    };
}

subtest '... simple MOP::Slot in a slot test' => sub {
    my $a = $Bar::HAS{bar};
    isa_ok($a, 'MOP::Slot');

    is($a->name, 'bar', '... got the name we expected');
    is($a->origin_stash, 'Bar', '... got the origin class we expected');
    is($a->initializer, $Bar::HAS{bar}->initializer, '... got the initializer we expected');

    ok($a->was_aliased_from('Bar'), '... the slot belongs to Bar');

    my $bar = Bar->new;
    isa_ok($bar, 'Bar');

    is($bar->{bar}, 'Bar::bar', '... the slot initialized correctly');

};

done_testing;
