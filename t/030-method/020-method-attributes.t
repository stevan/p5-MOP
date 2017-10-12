#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

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

    sub MODIFY_CODE_ATTRIBUTES { () }
    sub FETCH_CODE_ATTRIBUTES {
        my $code = $_[1];
        return 'Bar'            if $_[1] eq \&foo;
        return 'Baz(test => 1)' if $_[1] eq \&bar;
    }

    sub foo : Bar { 'Foo::foo' }

    sub bar : Baz(test => 1);
}

subtest '... simple MOP::Method test' => sub {
    my $m = MOP::Method->new( body => \&Foo::foo );
    isa_ok($m, 'MOP::Method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_stash, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::foo, '... got the body we expected');
    ok(!$m->is_required, '... the method is not required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');

    is_deeply(
        [ map $_->name, $m->get_code_attributes('Bar') ],
        [ 'Bar' ],
        '... got the attributes we expected'
    );
};

subtest '... simple MOP::Method test' => sub {
    my $m = MOP::Method->new( body => \&Foo::bar );
    isa_ok($m, 'MOP::Method');

    is($m->name, 'bar', '... got the name we expected');
    is($m->origin_stash, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::bar, '... got the body we expected');
    ok($m->is_required, '... the method is required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');

    my ($Baz) = $m->get_code_attributes('Baz');

    is($Baz->name, 'Baz', '... got the attribute name we expected');
    is_deeply($Baz->args, [ 'test', 1 ], '... got the attribute args we expected');
    is($Baz->original, 'Baz(test => 1)', '... got the attribute original we expected');
};

done_testing;
