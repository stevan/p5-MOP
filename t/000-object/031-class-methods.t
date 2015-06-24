#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('mop::object');
}

=pod

This just tests that instance methods called 
as class methods behave as we expect, which 
is to say, they croak about strings not being
hash refs.

If in the future we decide to improve on the
handling of this error we can test it here, 
but this serves as our baseline.

=cut

{
    package Foo;
    use strict;
    use warnings;
    our @ISA = ('mop::object');

    sub bar {
        my ($self, $x) = @_;
        $self->{bar} = $x if $x;
        $self->{bar} + 1;
    }
}

eval { Foo->bar(10) };
like(
    $@,
    qr/^Can\'t use string \(\"Foo\"\) as a HASH ref while \"strict refs\" in use/,
    '... got the error we expected'
);

eval { Foo->bar() };
like(
    $@,
    qr/^Can\'t use string \(\"Foo\"\) as a HASH ref while \"strict refs\" in use/,
    '... got the error we expected'
);

my $foo = Foo->new;
isa_ok($foo, 'Foo');
isa_ok($foo, 'mop::object');
{
    my $result = eval { $foo->bar(10) };
    is($@, "", '... did not die');
    is($result, 11, '... and the method worked');
    is($foo->bar, 11, '... and the attribute assignment worked');
}

done_testing;