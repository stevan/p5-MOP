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

    has 'bar' => (default => sub { 100 });

    sub bar ($self) { $self->{bar} }

    sub has_bar   ($self)     { defined $self->{bar} }
    sub set_bar   ($self, $b) { $self->{bar} = $b    }
    sub init_bar  ($self)     { $self->{bar} = 200   }
    sub clear_bar ($self)     { undef $self->{bar}   }
}

package Foo::Auto {
    use Moxie;

    extends 'MOP::Object';

    has 'bar' => (
        is        => 'ro',
        writer    => 'set_bar',
        predicate => 'has_bar',
        clearer   => 'clear_bar',
        default   => sub { 100 }
    );

    sub init_bar ($self) { $self->{bar} = 200 }
}

foreach my $foo ( Foo->new, Foo::Auto->new ) {
    ok( $foo->isa( 'MOP::Object' ), '... the object is from class MOP::Object' );
    ok( $foo->isa( 'Foo' ) || $foo->isa( 'Foo::Auto' ), '... the object is from class Foo or Foo::Auto' );

    ok($foo->has_bar, '... a bar is set');
    is($foo->bar, 100, '... values are defined');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    is($foo->bar, 200, '... value is initialized by the init_bar method');

    eval { $foo->set_bar(1000) };
    is($@, "", '... set bar without error');
    is($foo->bar, 1000, '... value is set by the set_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, undef, '... values has been cleared');
}

foreach my $foo ( Foo->new( bar => 10 ), Foo::Auto->new( bar => 10 ) ) {
    ok( $foo->isa( 'MOP::Object' ), '... the object is from class MOP::Object' );
    ok( $foo->isa( 'Foo' ) || $foo->isa( 'Foo::Auto' ), '... the object is from class Foo or Foo::Auto' );

    ok($foo->has_bar, '... a bar is set');
    is($foo->bar, 10, '... values are initialized via the constructor');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    ok($foo->has_bar, '... a bar is set');
    is($foo->bar, 200, '... value is initialized by the init_bar method');

    eval { $foo->set_bar(1000) };
    is($@, "", '... set bar without error');
    ok($foo->has_bar, '... a bar is set');
    is($foo->bar, 1000, '... value is set by the set_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is($foo->bar, undef, '... values has been cleared');
}


done_testing;
