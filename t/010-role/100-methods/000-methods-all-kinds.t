#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw[ blessed ];

BEGIN {
    use_ok('MOP::Role');
}

=pod

TODO:
- break up this test (it has too much going on in it)

=cut

BEGIN {
    package Foo;
    use strict;
    use warnings;

    sub foo { 'Foo::foo' }
    sub baz;

    package Bar;
    use strict;
    use warnings;

    our @DOES = ('Foo');

    {
        no warnings 'once';
        *foo = \&Foo::foo;
        *baz = \&Foo::baz;
    }

    sub bar { 'Bar::bar' }
}

subtest '... testing all-methods' => sub {
    my $role = MOP::Role->new( name => 'Foo' );
    isa_ok($role, 'MOP::Role');

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

    subtest '... testing required method object (Foo::baz)' => sub {

        my @m = ($all_methods[0]);
        is(scalar @m, 1, '... got one method to check');
        push @m => $role->get_required_method('baz');
        is(scalar @m, 2, '... got two methods to check');

        foreach my $m ( @m ) {
            isa_ok($m, 'MOP::Method');
            is($m->name, 'baz', '... got the expected name');
            ok($m->is_required, '... the method is required');
            is($m->origin_stash, 'Foo', '... the method is not aliased');
            like(
                exception { $m->body->() },
                qr/^Undefined subroutine \&Foo\:\:baz called/,
                '... got the expected exception from calling the required sub'
            );
        }

        ok(!$role->has_method('baz'), '... we do not have a method by this name');
        ok(!$role->get_method('baz'), '... we do not have a method by this name');
        ok(!$role->has_method_alias('baz'), '... we do not have an aliased method by this name');
        ok($role->requires_method('baz'), '... we do have a required method by this name');
    };

    subtest '... testing non-required method object (Foo::foo)' => sub {

        my @m = ($all_methods[1]);
        is(scalar @m, 1, '... got one method to check');
        push @m => $role->get_method('foo');
        is(scalar @m, 2, '... got two methods to check');

        foreach my $m ( @m ) {
            isa_ok($m, 'MOP::Method');
            is($m->name, 'foo', '... got the expected name');
            ok(!$m->is_required, '... the method is required');
            is($m->origin_stash, 'Foo', '... the method is not aliased');
            my $result;
            is(exception { $result = $m->body->() }, undef, '... got the lack of an exception from calling the regular sub');
            is($result, 'Foo::foo', '... got the expected result');
        }

        ok($role->has_method('foo'), '... we do have a method by this name');
        ok(!$role->has_method_alias('foo'), '... we do not have an aliased method by this name');
        ok(!$role->requires_method('foo'), '... we do not have a required method by this name');
        ok(!$role->get_required_method('foo'), '... we do not have a required method by this name')
    };

};

subtest '... testing all-methods (with aliased one)' => sub {
    my $role = MOP::Role->new( name => 'Bar' );
    isa_ok($role, 'MOP::Role');

    is($role->name, 'Bar', '... got the right name');

    my @all_methods = sort { $a->name cmp $b->name } $role->all_methods;
    is(scalar @all_methods, 3, '... only got two elements in the list');

    my @methods          = sort { $a->name cmp $b->name } $role->methods;
    my @aliased_methods  = sort { $a->name cmp $b->name } $role->aliased_methods;
    my @required_methods = sort { $a->name cmp $b->name } $role->required_methods;

    is(scalar @methods,          2, '... only got one element in the list of regular methods');
    is(scalar @aliased_methods,  1, '... only got one element in the list of aliased methods');
    is(scalar @required_methods, 1, '... only got one element in the list of required methods');

    is($aliased_methods[0]->body,  $all_methods[2]->body, '... the aliased method matches');
    is($required_methods[0]->body, $all_methods[1]->body, '... the aliased method matches');
    is($methods[0]->body,          $all_methods[0]->body, '... the method matches');

    subtest '... testing regular method object (Bar::bar)' => sub {

        my @m = ($all_methods[0]);
        is(scalar @m, 1, '... got one method to check');
        push @m => $role->get_method('bar');
        is(scalar @m, 2, '... got two methods to check');

        foreach my $m ( @m ) {
            isa_ok($m, 'MOP::Method');
            is($m->name, 'bar', '... got the expected name');
            ok(!$m->is_required, '... the method is required');
            is($m->origin_stash, 'Bar', '... the method is not aliased');
            my $result;
            is(exception { $result = $m->body->() }, undef, '... got the lack of an exception from calling the regular sub');
            is($result, 'Bar::bar', '... got the expected result');
        }

        ok($role->has_method('bar'), '... we do have a method by this name');
        ok(!$role->has_method_alias('bar'), '... we do not have an aliased method by this name');
        ok(!$role->requires_method('bar'), '... we do not have a required method by this name');
        ok(!$role->get_required_method('bar'), '... we do not have a required method by this name');
    };

    subtest '... testing aliased required method object (Bar::baz)' => sub {

        my @m = ($all_methods[1]);
        is(scalar @m, 1, '... got one method to check');

        foreach my $m ( @m ) {
            isa_ok($m, 'MOP::Method');
            is($m->name, 'baz', '... got the expected name');
            ok($m->is_required, '... the method is required');
            isnt($m->origin_stash, 'Bar', '... the method is aliased');
            is($m->origin_stash, 'Foo', '... the method is aliased');
            like(
                exception { $m->body->() },
                qr/^Undefined subroutine \&Foo\:\:baz called/,
                '... got the expected exception from calling the required sub'
            );
        }

        ok(!$role->has_method('baz'), '... we do not have a method by this name');
        ok(!$role->get_method('baz'), '... we do not have a method by this name');
        ok(!$role->has_method_alias('baz'), '... we do not have an aliased method by this name');
        ok($role->requires_method('baz'), '... we do have a required method by this name');
        ok(!$role->get_required_method('baz'), '... we do NOT have a required method by this name in the locak class');
    };

    subtest '... testing aliased method object (Bar::foo)' => sub {

        my @m = ($all_methods[2]);
        is(scalar @m, 1, '... got one method to check');

        foreach my $m ( @m ) {
            isa_ok($m, 'MOP::Method');
            is($m->name, 'foo', '... got the expected name');
            ok(!$m->is_required, '... the method is not required');
            isnt($m->origin_stash, 'Bar', '... the method is aliased');
            is($m->origin_stash, 'Foo', '... the method is aliased');
            my $result;
            is(exception { $result = $m->body->() }, undef, '... got the lack of an exception from calling the regular sub');
            is($result, 'Foo::foo', '... got the expected result');
        }

        ok($role->has_method('foo'), '... we do not have a method by this name');
        ok($role->get_method('foo'), '... we do not have a method by this name');
        ok($role->has_method_alias('foo'), '... we do have an aliased method by this name');
        ok(!$role->requires_method('foo'), '... we do not have a required method by this name');
        ok(!$role->get_required_method('foo'), '... we do not have a required method by this name');
    };
};

done_testing;
