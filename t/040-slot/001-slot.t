#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Role');
    use_ok('MOP::Slot');
    use_ok('MOP::Slot::Initializer');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

    our %HAS; BEGIN { %HAS = ( foo => sub { 'Foo::foo' } ) }

    package Bar;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

    our %HAS; BEGIN { %HAS = (
        bar => MOP::Slot::Initializer->new(
            default => sub { 'Bar::bar' }
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

subtest '... simple MOP::Slot::Initializer in a slot test' => sub {
    my $slot_init = $Bar::HAS{bar};
    isa_ok($slot_init, 'MOP::Slot::Initializer');

    my $slot = MOP::Role->new('Bar')->get_slot('bar');
    isa_ok($slot, 'MOP::Slot');

    is($slot->name, 'bar', '... got the name we expected');
    is($slot->origin_stash, 'Bar', '... got the origin class we expected');
    is($slot->initializer, $slot_init->to_code, '... got the initializer we expected');

    ok($slot->was_aliased_from('Bar'), '... the slot belongs to Bar');

    my $bar = Bar->new;
    isa_ok($bar, 'Bar');

    is($bar->{bar}, 'Bar::bar', '... the slot initialized correctly');
};

subtest '... trickier MOP::Slot::Initializer in a slot test' => sub {

    my $slot_init = MOP::Slot::Initializer->new(
        in_package => 'Bar',
        required   => 'A `baz` is required'
    );

    $Bar::HAS{baz} = $slot_init;

    my $slot = MOP::Role->new('Bar')->get_slot('baz');
    isa_ok($slot, 'MOP::Slot');

    is($slot->name, 'baz', '... got the name we expected');
    is($slot->origin_stash, 'Bar', '... got the origin class we expected');
    is($slot->initializer, $slot_init->to_code, '... got the initializer we expected');

    ok($slot->was_aliased_from('Bar'), '... the slot belongs to Bar');

    like(
        exception { Bar->new },
        qr/^A \`baz\` is required/,
        '... got the expected required exception'
    );

};

done_testing;
