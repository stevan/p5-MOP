#!perl

use strict;
use warnings;

use Test::More;

use Scalar::Util qw[ reftype ];

BEGIN {
    use_ok('mop::util');
    use_ok('mop::util::error');
}

{ 
    my $e = mop::util::error->new(
        from => 'main',
        msg  => 'ERROR!'
    ); 
    isa_ok($e, 'mop::util::error');

    is($e->from, 'main', '... got the expected value of `from`');
    is($e->msg, 'ERROR!', '... got the expected value of `msg`');
}

{
    eval { mop::util::THROW( PANIC => 'PANIC!!!' ) };
    ok($@, '... got an exception');

    my $e = mop::util::CATCH( $@ );
    isa_ok($e, 'mop::util::error::PANIC');
    isa_ok($e, 'mop::util::error');
    isa_ok($e, 'mop::object');   

    is($e->from, 'main', '... got the expected value of `from`');
    like($e->msg, qr/^PANIC!!! at \//, '... got the expected value of `msg`');
}



done_testing;
