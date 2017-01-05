#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('MOP::Method');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub foo { 'Foo::foo' }
}

subtest '... simple MOP::Method test' => sub {
    my $m = MOP::Method->new( body => \&Foo::foo );
    isa_ok($m, 'MOP::Object');
    isa_ok($m, 'MOP::Method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_class, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::foo, '... got the body we expected');
    ok(!$m->is_required, '... the method is not required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');
};

done_testing;
