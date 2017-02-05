#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('MOP::Method');
}

=pod

TODO:

=cut

{
    package Foo;
    use strict;
    use warnings;

    sub foo { 'Foo::foo' }
}

my %cases = (
    '... key/value constructor' => sub { MOP::Method->new( body => \&Foo::foo )     },
    '... HASH ref constructor'  => sub { MOP::Method->new( { body => \&Foo::foo } ) },
    '... CODE ref constructor'  => sub { MOP::Method->new( \&Foo::foo )             },
);

foreach my $case ( keys %cases ) {
    subtest $case => sub {
        my $m = $cases{ $case }->();
        isa_ok($m, 'MOP::Method');

        is($m->name, 'foo', '... got the name we expected');
        is($m->origin_stash, 'Foo', '... got the origin class we expected');
        is($m->body, \&Foo::foo, '... got the body we expected');
        ok(!$m->is_required, '... the method is not required');

        is($m->fully_qualified_name, 'Foo::foo', '... got the expected fully qualified name');

        ok($m->was_aliased_from('Foo'), '... the method belongs to Foo');
    };
}

done_testing;
