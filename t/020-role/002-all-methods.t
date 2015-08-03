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
        *baz = \&Foo::baz;
    }

    sub bar { 'Bar::bar' }    
}

subtest '... testing all-methods' => sub {
    my $role = mop::role->new( name => 'Foo' );
    isa_ok($role, 'mop::role');

    is($role->name, 'Foo', '... got the right name');
    
    my @all_methods = sort { $a->name cmp $b->name } $role->all_methods;
    is(scalar @all_methods, 2, '... only got two elements in the list');

    my @methods          = sort { $a->name cmp $b->name } $role->methods;
    my @aliased_methods  = sort { $a->name cmp $b->name } $role->aliased_methods;
    my @required_methods = sort { $a->name cmp $b->name } $role->required_methods;

    is(scalar @methods,          1, '... only got one element in the list of regular methods');
    is(scalar @aliased_methods,  0, '... only got zero elements in the list of aliased methods');
    is(scalar @required_methods, 1, '... only got one element in the list of required methods');

    is($required_methods[0]->body, $all_methods[0]->body, '... the required method matches');
    is($methods[0]->body,          $all_methods[1]->body, '... the method matches');
    
    subtest '... testing required method object' => sub {
        isa_ok($all_methods[0], 'mop::method');
        is($all_methods[0]->name, 'baz', '... got the expected name');
        ok($all_methods[0]->is_required, '... the method is required');
        is($all_methods[0]->origin_class, 'Foo', '... the method is not aliased');
        like(
            exception { $all_methods[0]->body->() }, 
            qr/^Undefined subroutine \&Foo\:\:baz called/, 
            '... got the expected exception from calling the required sub'
        );

        ok(!$role->has_method('baz'), '... we do not have a method by this name');
        ok(!$role->has_method_alias('baz'), '... we do not have an aliased method by this name');
        ok($role->requires_method('baz'), '... we do have a required method by this name');
    };

    subtest '... testing non-required method object' => sub {
        isa_ok($all_methods[1], 'mop::method');
        is($all_methods[1]->name, 'foo', '... got the expected name');
        ok(!$all_methods[1]->is_required, '... the method is required');
        is($all_methods[1]->origin_class, 'Foo', '... the method is not aliased');
        my $result;
        is(exception { $result = $all_methods[1]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Foo::foo', '... got the expected result');

        ok($role->has_method('foo'), '... we do have a method by this name');
        ok(!$role->has_method_alias('foo'), '... we do not have an aliased method by this name');
        ok(!$role->requires_method('foo'), '... we do not have a required method by this name');
    };

};

subtest '... testing all-methods (with aliased one)' => sub {
    my $role = mop::role->new( name => 'Bar' );
    isa_ok($role, 'mop::role');
    
    is($role->name, 'Bar', '... got the right name');

    my @all_methods = sort { $a->name cmp $b->name } $role->all_methods;
    is(scalar @all_methods, 3, '... only got two elements in the list');

    my @methods          = sort { $a->name cmp $b->name } $role->methods;
    my @aliased_methods  = sort { $a->name cmp $b->name } $role->aliased_methods;
    my @required_methods = sort { $a->name cmp $b->name } $role->required_methods;

    is(scalar @methods,          1, '... only got one element in the list of regular methods');
    is(scalar @aliased_methods,  1, '... only got one element in the list of aliased methods');
    is(scalar @required_methods, 1, '... only got one element in the list of required methods');

    is($aliased_methods[0]->body,  $all_methods[2]->body, '... the aliased method matches');
    is($required_methods[0]->body, $all_methods[1]->body, '... the aliased method matches');
    is($methods[0]->body,          $all_methods[0]->body, '... the method matches');

    subtest '... testing regular method object' => sub {
        isa_ok($all_methods[0], 'mop::method');
        is($all_methods[0]->name, 'bar', '... got the expected name');
        ok(!$all_methods[0]->is_required, '... the method is required');
        is($all_methods[0]->origin_class, 'Bar', '... the method is not aliased');
        my $result;
        is(exception { $result = $all_methods[0]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Bar::bar', '... got the expected result');

        ok($role->has_method('bar'), '... we do have a method by this name');
        ok(!$role->has_method_alias('bar'), '... we do not have an aliased method by this name');
        ok(!$role->requires_method('bar'), '... we do not have a required method by this name');
    };

    subtest '... testing aliased required method object' => sub {
        isa_ok($all_methods[1], 'mop::method');
        is($all_methods[1]->name, 'baz', '... got the expected name');
        ok($all_methods[1]->is_required, '... the method is required');
        isnt($all_methods[1]->origin_class, 'Bar', '... the method is aliased');
        is($all_methods[1]->origin_class, 'Foo', '... the method is aliased');
        like(
            exception { $all_methods[1]->body->() }, 
            qr/^Undefined subroutine \&Foo\:\:baz called/, 
            '... got the expected exception from calling the required sub'
        );
        
        ok(!$role->has_method('baz'), '... we do not have a method by this name');
        ok(!$role->has_method_alias('baz'), '... we do not have an aliased method by this name');
        ok($role->requires_method('baz'), '... we do have a required method by this name');
    };

    subtest '... testing aliased method object' => sub {
        isa_ok($all_methods[2], 'mop::method');
        is($all_methods[2]->name, 'foo', '... got the expected name');
        ok(!$all_methods[2]->is_required, '... the method is not required');
        isnt($all_methods[2]->origin_class, 'Bar', '... the method is aliased');
        is($all_methods[2]->origin_class, 'Foo', '... the method is aliased');
        my $result;
        is(exception { $result = $all_methods[2]->body->() }, undef, '... got the lack of an exception from calling the regular sub');
        is($result, 'Foo::foo', '... got the expected result');

        ok(!$role->has_method('foo'), '... we do not have a method by this name');
        ok($role->has_method_alias('foo'), '... we do have an aliased method by this name');
        ok(!$role->requires_method('foo'), '... we do not have a required method by this name');
    };
};

done_testing;
