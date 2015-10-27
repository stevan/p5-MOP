#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('mop::method');
    use_ok('mop::internal::util');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    BEGIN { 
        mop::internal::util::INSTALL_CODE_ATTRIBUTE_HANDLER( 
            __PACKAGE__, qw[
                Bar
            ]
        );
    }
    
    sub foo : Bar { 'Foo::foo' }
}

subtest '... simple mop::method test' => sub {
    my $m = mop::method->new( body => \&Foo::foo );
    isa_ok($m, 'mop::object');
    isa_ok($m, 'mop::method');

    is($m->name, 'foo', '... got the name we expected');
    is($m->origin_class, 'Foo', '... got the origin class we expected');
    is($m->body, \&Foo::foo, '... got the body we expected');
    ok(!$m->is_required, '... the method is not required');

    ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');

    is_deeply(
        $m->get_code_attributes,
        [ 'Bar' ],
        '... got the attributes we expected'
    );
};

done_testing;
