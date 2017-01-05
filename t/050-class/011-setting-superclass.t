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

=cut

{
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';
}

subtest '... testing adding superclass successfully' => sub {

    my $c = MOP::Class->new( name => 'Foo' );
    isa_ok($c, 'MOP::Class');

    is_deeply([ $c->superclasses ], [], '... got no superclasses');
    is_deeply($c->mro, [ 'Foo' ], '... got only myself in the mro');

    ok(!Foo->can('new'), '... no `new` method in Foo');

    is(
        exception { $c->set_superclasses('UNIVERSAL::Object') },
        undef,
        '... was able to set the superclass effectively'
    );

    is_deeply([ $c->superclasses ], [ 'UNIVERSAL::Object' ], '... got a superclass now');
    is_deeply($c->mro, [ 'Foo', 'UNIVERSAL::Object' ], '... got more in the mro now');

    ok(Foo->can('new'), '... we now have a `new` method in Foo');

};

done_testing;




