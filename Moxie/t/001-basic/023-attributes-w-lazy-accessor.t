#!perl

use strict;
use warnings;

use Test::More;

=pod

...

=cut

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar';

    sub bar ($self, $b = undef) {
        $self->{bar} = $b if $b;
        $self->{bar} //= 333;
    }

    sub has_bar   ($self) { defined $self->{bar} }
    sub init_bar  ($self) { $self->{bar} = 200   }
    sub clear_bar ($self) { undef $self->{bar}   }
}

{
    my $foo = Foo->new;
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, 333, '... values are defined');

    ok($foo->has_bar, '... bar is now set');
    eval { $foo->bar(1000) };
    is($@, "", '... set bar without error');
    is($foo->bar, 1000, '... value is set by the set_bar method');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    is($foo->bar, 200, '... value is initialized by the init_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, 333, '... lazy value is recalculated');
}

{
    my $foo = Foo->new( bar => 10 );
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok($foo->has_bar, '... bar is set');
    is($foo->bar, 10, '... values are initialized via the constructor');

    eval { $foo->bar(1000) };
    is($@, "", '... set bar without error');
    is($foo->bar, 1000, '... value is set by the set_bar method');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    is($foo->bar, 200, '... value is initialized by the init_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, 333, '... lazy value is recalculated');
}


done_testing;
