#!perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'bar';

    sub bar ($self, $x = undef) {
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
{
    my $result = eval { $foo->bar(10) };
    is($@, "", '... did not die');
    is($result, 11, '... and the method worked');
    is($foo->bar, 11, '... and the attribute assignment worked');
}

done_testing;
