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

    sub foo;
}

subtest '... simple required MOP::Method test' => sub {
    my $m = MOP::Method->new( body => \&Foo::foo );
    isa_ok($m, 'MOP::Method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_stash, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::foo, '... got the body we expected');
    ok($m->is_required, '... the method is required');

    is($m->fully_qualified_name, 'Foo::foo', '... got the expected fully qualified name');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');
};

done_testing;
