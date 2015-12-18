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
    package Bar;
    use strict;
    use warnings;

    sub foo { 'Bar::foo' }

    package Foo;
    use strict;
    use warnings;

    *foo = \&Bar::foo;
}

subtest '... simple aliased mop::method test' => sub {
    my $m = mop::method->new( body => \&Foo::foo );
    isa_ok($m, 'mop::object');
    isa_ok($m, 'mop::method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_class, 'Bar', '... got the origin class we expected');
    is($m->body, \&Bar::foo, '... got the body we expected');
    ok(!$m->is_required, '... the method is required');

    ok(!$m->was_aliased_from('Foo'), '... the method belongs to Foo');
    ok($m->was_aliased_from('Bar'), '... the method belongs to Foo');
};

done_testing;
