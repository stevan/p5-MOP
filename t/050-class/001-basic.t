#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::class');
}

=pod

TODO:
- test method aliases
- test attributes
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

subtest '... testing class' => sub {

    my $c = mop::class->new( name => 'Foo' );
    isa_ok($c, 'mop::class');

    is_deeply([ $c->superclasses ], [], '... got no superclasses');
    is_deeply($c->mro, [ 'Foo' ], '... got only myself in the mro');

    ok($c->has_method('bar'), '... we have the bar method');
    ok(!$c->has_method('baz'), '... we do not have the baz method');

    ok(!$c->has_method_alias('bar'), '... the bar method is not an alias');
};

done_testing;




