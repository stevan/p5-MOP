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
- test deleting method when a class is closed
- test deleting when ...
    - alias method exists
    - regular method exists
- test that deleting the required method does not mess up the glob
    - this will require having @ and % values in the glob, etc.

=cut

{
    package Foo;
    use strict;
    use warnings;   

    sub foo;
}

subtest '... testing deleting method alias' => sub {
    my $Foo = mop::role->new( name => 'Foo' );
    isa_ok($Foo, 'mop::role');
    isa_ok($Foo, 'mop::object');

    ok(!$Foo->has_method('foo'), '... [foo] method to get');
    ok(!$Foo->get_method('foo'), '... [foo] method to get');    

    ok($Foo->requires_method('foo'), '... the [foo] method is not required');
    ok($Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');

    can_ok('Foo', 'foo');

    $Foo->delete_required_method('foo');

    ok(!Foo->can('foo'), '... the [foo] method returns nothing for &can');
    ok(!$Foo->has_method('foo'), '... no [foo] method to get');
    ok(!$Foo->get_method('foo'), '... no [foo] method to get');

    ok(!$Foo->requires_method('foo'), '... the [foo] method is not required');
    ok(!$Foo->get_required_method('foo'), '... the [foo] method is not required');

    ok(!$Foo->get_method_alias('foo'), '... the [foo] method is not an alias');
    ok(!$Foo->has_method_alias('foo'), '... the [foo] method is not an alias');
};

subtest '... testing exception when role is closed' => sub {
    my $Foo = mop::role->new( name => 'Foo' );
    isa_ok($Foo, 'mop::role');
    isa_ok($Foo, 'mop::object');

    is(
        exception { $Foo->set_is_closed(1) },
        undef,
        '... closed class successfully'
    );

    like(
        exception { $Foo->delete_required_method('foo') },
        qr/^\[PANIC\] Cannot delete method requirement \(foo\) from \(Foo\) because it has been closed/,
        '... could not delete a method requirement when the class is closed'
    );
};

done_testing;
