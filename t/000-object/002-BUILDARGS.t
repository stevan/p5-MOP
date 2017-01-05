#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype blessed ];

BEGIN {
    use_ok('MOP::Object');
}

=pod

TODO:
- test for some failure conditions where BUILDARGS
  does not behave properly
    - returns something other then HASH ref
- test inherited custom BUILDARGS
    - chaining BUILDARGS methods along inheritance
- test under multiple inheritance
- test with %HAS values

=cut

{
    package Foo::NoInheritance;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('MOP::Object') };
    our %HAS; BEGIN { %HAS = (foo => sub { 'FOO' }) };

    sub BUILDARGS {
        my ($class, $bar) = @_;
        return { foo => $bar }
    }

    package Foo::WithInheritance::NextMethod;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('MOP::Object') };
    our %HAS; BEGIN { %HAS = (foo => sub { 'FOO' }) };

    sub BUILDARGS {
        my ($class, $bar) = @_;
        return $class->next::method( foo => $bar )
    }

    package Foo::WithInheritance::SUPER;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('MOP::Object') };
    our %HAS; BEGIN { %HAS = (foo => sub { 'FOO' }) };

    sub BUILDARGS {
        my ($class, $bar) = @_;
        return $class->SUPER::BUILDARGS( foo => $bar )
    }
}

subtest '... simple BUILDARGS test w/out inheritance' => sub {
    my $o = Foo::NoInheritance->new( 'BAR' );
    isa_ok($o, 'Foo::NoInheritance');
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'Foo::NoInheritance', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

subtest '... simple BUILDARGS test w/ inheritance and next::method' => sub {
    my $o = Foo::WithInheritance::NextMethod->new( 'BAR' );
    isa_ok($o, 'Foo::WithInheritance::NextMethod');
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'Foo::WithInheritance::NextMethod', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

subtest '... simple BUILDARGS test w/ inheritance and SUPER' => sub {
    my $o = Foo::WithInheritance::SUPER->new( 'BAR' );
    isa_ok($o, 'Foo::WithInheritance::SUPER');
    isa_ok($o, 'MOP::Object');

    is(blessed $o, 'Foo::WithInheritance::SUPER', '... got the expected class name');
    is(reftype $o, 'HASH', '... got the expected default repr type');

    ok(exists $o->{foo}, '... got the expected slot');
    is($o->{foo}, 'BAR', '... the expected slot has the expected value');
};

done_testing;
