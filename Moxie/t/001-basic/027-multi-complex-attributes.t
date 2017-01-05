#!perl

use strict;
use warnings;

use Test::More;

=pod

...

=cut

package Bar {
    use Moxie;

    extends 'MOP::Object';
}

package Baz {
    use Moxie;

    extends 'MOP::Object';
}

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar' => ( default => sub { Bar->new } );
    has 'baz' => ( default => sub { Baz->new } );

    sub bar ($self) { $self->{bar} }
    sub has_bar ($self)      { defined $self->{bar} }
    sub set_bar ($self, $b) { $self->{bar} = $b  }
    sub clear_bar ($self)    { undef $self->{bar} }

    sub baz ($self) { $self->{baz} }
    sub has_baz ($self)      { defined $self->{baz} }
    sub set_baz ($self, $b) { $self->{baz} = $b  }
    sub clear_baz ($self)    { undef $self->{baz} }

}

{
    my $foo = Foo->new;
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok($foo->has_bar, '... bar is set as a default');
    ok($foo->bar->isa( 'Bar' ), '... value isa Bar object');

    ok($foo->has_baz, '... baz is set as a default');
    ok($foo->baz->isa( 'Baz' ), '... value isa Baz object');

    my $bar = $foo->bar;
    my $baz = $foo->baz;

    #diag $bar;
    #diag $baz;

    eval { $foo->set_bar( Bar->new ) };
    is($@, "", '... set bar without error');
    ok($foo->has_bar, '... bar is set');
    ok($foo->bar->isa( 'Bar' ), '... value is set by the set_bar method');
    isnt($foo->bar, $bar, '... the new value has been set');

    eval { $foo->set_baz( Baz->new ) };
    is($@, "", '... set baz without error');
    ok($foo->has_baz, '... baz is set');
    ok($foo->baz->isa( 'Baz' ), '... value is set by the set_baz method');
    isnt($foo->baz, $baz, '... the new value has been set');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, undef, '... values has been cleared');

    eval { $foo->clear_baz };
    is($@, "", '... set baz without error');
    ok(!$foo->has_baz, '... no baz is set');
    is($foo->baz, undef, '... values has been cleared');
}


done_testing;
