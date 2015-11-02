#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::method');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub foo;
}

subtest '... simple required mop::method test' => sub {
    my $m = mop::method->new( body => \&Foo::foo );
    isa_ok($m, 'mop::object');
    isa_ok($m, 'mop::method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_class, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::foo, '... got the body we expected');
    ok($m->is_required, '... the method is required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');
};

done_testing;
