#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP::Method');
    use_ok('MOP::Internal::Util');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    BEGIN {
        MOP::Internal::Util::INSTALL_CODE_ATTRIBUTE_HANDLER(
            __PACKAGE__, qw[
                Bar
                Baz
            ]
        );
    }

    sub foo : Bar { 'Foo::foo' }

    sub bar : Baz;
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

    is_deeply(
        [ $m->get_code_attributes ],
        [ 'Bar' ],
        '... got the attributes we expected'
    );
};

subtest '... simple MOP::Method test' => sub {
    my $m = MOP::Method->new( body => \&Foo::bar );
    isa_ok($m, 'MOP::Object');
    isa_ok($m, 'MOP::Method');

    is($m->name, 'bar', '... got the name we expected');
    is($m->origin_class, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::bar, '... got the body we expected');
    ok($m->is_required, '... the method is required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');

    is_deeply(
        [ $m->get_code_attributes ],
        [ 'Baz' ],
        '... got the attributes we expected'
    );
};

done_testing;
