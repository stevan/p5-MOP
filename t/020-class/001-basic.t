#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Class');
}

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our %HAS;
    BEGIN {
        %HAS = (
            doh => sub { 'doh::doh' }
        )
    };

    sub bar { 'Foo::Bar' }

    package Bar;
    use strict;
    use warnings;

    our %HAS;
    BEGIN { %HAS = ( %Foo::HAS ) };

    sub bobbins;
}

my %cases = (
    '... basic constructor'        => sub { MOP::Class->new( name => 'Foo' )     },
    '... HASH ref constructor'     => sub { MOP::Class->new( { name => 'Foo' } ) },
    '... package name constructor' => sub { MOP::Class->new( 'Foo' )             },
    '... stash ref constructor'    => sub { MOP::Class->new( \%Foo:: )           },
);

foreach my $case ( keys %cases ) {
    subtest $case => sub {
        my $c = $cases{ $case }->();
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [], '... got no superclasses');
        is_deeply($c->mro, [ 'Foo' ], '... got only myself in the mro');

        ok($c->has_method('bar'), '... we have the bar method');
        ok(!$c->has_method('baz'), '... we do not have the baz method');

        ok(!$c->has_method_alias('bar'), '... the bar method is not an alias');
    };
}

subtest '... method alias' => sub {
    my $c = MOP::Class->new( name => 'Foo' );

    ok(!$c->has_method_alias('foobar'), '... the foobar method is not an alias');
    is(scalar $c->aliased_methods(),0,'... there are no aliased methods');

    $c->alias_method('foobar' => sub { 'foobar' });

    ok($c->has_method_alias('foobar'), '... foobar method is now an alias');
    isa_ok($c->get_method_alias('foobar'), 'MOP::Method');
    is(scalar $c->aliased_methods(),1,'... there is now 1 aliased method');

    $c->delete_method_alias('foobar');
    ok(!$c->has_method_alias('foobar'), '... delete_method_alias has removed the foobar alias');
};

subtest '... slots' => sub {
    my $c = MOP::Class->new( name => 'Foo' );

    is(scalar $c->all_slots,1,'... class foo has 1 slot');
    is(scalar $c->slots,1,'... class foo has 1 regular slot');
    is(scalar $c->aliased_slots,0,'... class foo has no aliased slots');

    ok($c->has_slot('doh'), '... class foo has slot doh');
    ok($c->get_slot('doh'), '... class foo can get slot doh');

    my $bar = MOP::Class->new( name => 'Bar' );

    is(scalar $bar->all_slots,1,'... class bar has 1 slot');
    is(scalar $bar->slots,0,'... class bar has 1 regular slot');
    is(scalar $bar->aliased_slots,1,'... class bar has 1 aliased slot');

    ok(!$bar->has_slot('doh'), '... class bar does not have slot doh');
    ok(!$bar->get_slot('doh'), '... class bar can not get the doh attribute');
    ok($bar->has_slot_alias('doh'), '... class bar has slot alias doh');
    ok($bar->get_slot_alias('doh'), '... class bar can get the doh alias');
};

subtest '... required methods' => sub {
    ok(! MOP::Class->new( name => 'Foo' )->requires_method('bar'), '... bar method is not required');
    ok(MOP::Class->new( name => 'Bar' )->requires_method('bobbins'), '... bobbins method is required');
};

done_testing;




