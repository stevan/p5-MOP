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
- test more varients of role composition

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub foo { 'Foo::foo' }

    package Bar;
    use strict;
    use warnings;    

    sub bar { 'Bar::bar' }

    package FooBar;
    use strict;
    use warnings;

    our @DOES; BEGIN { @DOES = ('Foo', 'Bar') }

    BEGIN { 
        mop::internal::util::APPLY_ROLES(
            mop::role->new( name => __PACKAGE__ ), 
            \@DOES, 
            to => 'role' 
        )
    }

}

subtest '... testing basics' => sub {
    my $role = mop::role->new( name => 'FooBar' );
    isa_ok($role, 'mop::role');

    ok($role->does_role('Foo'), '... we do the Foo role');
    ok($role->does_role('Bar'), '... we do the Bar role');

    ok($role->has_method_alias('foo'), '... we have the foo method aliased');
    ok($role->has_method_alias('bar'), '... we have the bar method aliased');

    my $foo = $role->get_method_alias('foo');
    isa_ok($foo, 'mop::method');

    my $bar = $role->get_method_alias('bar');
    isa_ok($bar, 'mop::method');



};

done_testing;
