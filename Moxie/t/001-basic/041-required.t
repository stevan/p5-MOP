#!perl

use strict;
use warnings;

use Test::More;

package Foo {
    use Moxie;

    extends 'MOP::Object';

    has 'foo' => (default => sub{ 'DFOO' } );
    has 'bar' => (required => 1);

    sub foo ($self) { $self->{foo} }
    sub bar ($self) { $self->{bar} }
}

{
    my $foo = Foo->new(foo => 'FOO', bar => 'BAR');
    is($foo->foo, 'FOO', 'attribute with default and arg');
    is($foo->bar, 'BAR', 'required attribute with arg');
}

{
    my $foo = Foo->new(bar => 'BAR');
    is($foo->foo, 'DFOO', 'attribute with default and no arg');
    is($foo->bar, 'BAR', 'required attribute with arg');
}

eval { Foo->new };
like( $@,
      qr/^\[MOP\:\:ERROR\] The attribute \'bar\' is required/,
      'missing required attribute throws an exception'
);

# TODO:
# {
#     eval { Foo->new };
#     my $local_file = __FILE__;
#     my $line       = __LINE__ - 2;
#     like(
#         $@,
#         qr/^\[MOP\:\:ERROR\] The attribute \'bar\' is required at $local_file line $line/,
#         'exception should correcly locate the source'
#     );
# }

# TODO:
# eval 'class Bar { has $!baz is required = "DBAZ" })';
# like $@,  qr/in '\$!baz' attribute definition: 'required' trait is incompatible with default value/;

done_testing;
