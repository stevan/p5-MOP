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

    package Bar;
    use strict;
    use warnings;

    our $IS_CLOSED; BEGIN { $IS_CLOSED = 1 }
}

subtest '... testing adding superclass successfully' => sub {

    my $c = MOP::Class->new( name => 'Foo' );
    isa_ok($c, 'MOP::Class');

    is_deeply([ $c->superclasses ], [], '... got no superclasses');
    is_deeply($c->mro, [ 'Foo' ], '... got only myself in the mro');

    ok(!Foo->can('new'), '... no `new` method in Foo');

    is(
        exception { $c->set_superclasses('MOP::Object') },
        undef,
        '... was able to set the superclass effectively'
    );

    is_deeply([ $c->superclasses ], [ 'MOP::Object' ], '... got a superclass now');
    is_deeply($c->mro, [ 'Foo',  'MOP::Object', 'UNIVERSAL::Object' ], '... got more in the mro now');

    ok(Foo->can('new'), '... we now have a `new` method in Foo');

};

subtest '... testing adding superclass un-successfully' => sub {

    my $c = MOP::Class->new( name => 'Bar' );
    isa_ok($c, 'MOP::Class');

    is_deeply([ $c->superclasses ], [], '... got no superclasses');
    is_deeply($c->mro, [ 'Bar' ], '... got only myself in the mro');

    like(
        exception { $c->set_superclasses('MOP::Object') },
        qr/^\[CLOSED\] Cannot add superclasses to a package which has been closed/,
        '... was not able to set the superclass effectively'
    );

    is_deeply([ $c->superclasses ], [], '... still got no superclasses');
    is_deeply($c->mro, [ 'Bar' ], '... still got only myself in the mro');
};

done_testing;




