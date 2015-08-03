#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('mop::role');
}

=pod

TODO:

=cut

BEGIN {
    package Foo;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';  

    sub foo { 'Foo::foo' }
    sub baz;

    package Bar;
    use strict;
    use warnings;

    our $VERSION   = '0.02';
    our $AUTHORITY = 'cpan:STEVAN';  

    our @DOES = ('Foo');  

    {
        no warnings 'once';
        *foo = \&Foo::foo;
    }

    sub bar { 'Bar::bar' }    
}

subtest '... testing all-methods' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');

    is($role->name, 'Foo', '... got the right name');
    
    my @methods = sort { $a->name cmp $b->name } $role->all_methods;
    is(scalar @methods, 2, '... only got two elements in the list');

    subtest '... testing required method object' => sub {
        isa_ok($methods[0], 'mop::method');
        is($methods[0]->name, 'baz', '... got the expected name');
        ok($methods[0]->is_required, '... the method is required');
        is($methods[0]->origin_class, 'Foo', '... the method is not aliased');
        like(
            exception { $methods[0]->body->() }, 
            qr/^Undefined subroutine \&Foo\:\:baz called/, 
            '... got the expected exception from calling the required sub'
        );
    };

    subtest '... testing non-required method object' => sub {
        isa_ok($methods[1], 'mop::method');
        is($methods[1]->name, 'foo', '... got the expected name');
        ok(!$methods[1]->is_required, '... the method is required');
        is($methods[1]->origin_class, 'Foo', '... the method is not aliased');
        my $result;
        is(exception { $result = $methods[1]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Foo::foo', '... got the expected result');
    };
};

subtest '... testing all-methods (with aliased one)' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    
    is($role->name, 'Bar', '... got the right name');

    my @methods = sort { $a->name cmp $b->name } $role->all_methods;

    is(scalar @methods, 2, '... only got two elements in the list');

    subtest '... testing regular method object' => sub {
        isa_ok($methods[0], 'mop::method');
        is($methods[0]->name, 'bar', '... got the expected name');
        ok(!$methods[0]->is_required, '... the method is required');
        is($methods[0]->origin_class, 'Bar', '... the method is not aliased');
        my $result;
        is(exception { $result = $methods[0]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Bar::bar', '... got the expected result');
    };

    subtest '... testing aliased method object' => sub {
        isa_ok($methods[1], 'mop::method');
        is($methods[1]->name, 'foo', '... got the expected name');
        ok(!$methods[1]->is_required, '... the method is required');
        isnt($methods[1]->origin_class, 'Bar', '... the method is aliased');
        is($methods[1]->origin_class, 'Foo', '... the method is aliased');
        my $result;
        is(exception { $result = $methods[1]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Foo::foo', '... got the expected result');
    };
};

done_testing;
