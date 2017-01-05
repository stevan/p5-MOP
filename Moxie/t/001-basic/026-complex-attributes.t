#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use MOP;

=pod

...

=cut

package Bar {
    use Moxie;

    extends 'MOP::Object';
}

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar' => ( default => sub { Bar->new } );

    sub bar ($self) { $self->{bar} }

    sub has_bar   ($self)     { defined $self->{bar} }
    sub set_bar   ($self, $b) { $self->{bar} = $b  }
    sub clear_bar ($self)     { undef $self->{bar} }
}

{
    my $foo = Foo->new;
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok($foo->has_bar, '... bar is set as a default');
    ok($foo->bar->isa( 'Bar' ), '... value isa Bar object');

    my $bar = $foo->bar;

    eval { $foo->set_bar( Bar->new ) };
    is($@, "", '... set bar without error');
    ok($foo->has_bar, '... bar is set');
    ok($foo->bar->isa( 'Bar' ), '... value is set by the set_bar method');
    isnt($foo->bar, $bar, '... the new value has been set');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, undef, '... values has been cleared');
}


done_testing;
