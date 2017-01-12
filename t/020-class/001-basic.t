#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Class');
}

=pod

TODO:
- test method aliases
- test slots
- test required methods

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    sub bar { 'Foo::Bar' }
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

done_testing;




