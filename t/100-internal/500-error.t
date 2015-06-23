#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::internal::util');
    use_ok('mop::internal::util::error');
}

subtest '... testing error without type' => sub {
    my $e = mop::internal::util::error->new( msg => 'ERROR!' );
    isa_ok($e, 'mop::internal::util::error');

    is($e->type, 'ERROR', '... got the expected value of `type`');
    is($e->msg, 'ERROR!', '... got the expected value of `msg`');
};

subtest '... testing error with type' => sub {
    my $e = mop::internal::util::error->new( type => 'PANIC', msg => 'PANIC!' );
    isa_ok($e, 'mop::internal::util::error');

    is($e->type, 'PANIC', '... got the expected value of `type`');
    is($e->msg, 'PANIC!', '... got the expected value of `msg`');
};

subtest '... testing error from THROW and CATCH' => sub {
    eval { mop::internal::util::THROW( PANIC => 'PANIC!' ) };
    ok($@, '... got an exception');

    my $e = mop::internal::util::CATCH( $@ );
    isa_ok($e, 'mop::internal::util::error');
    isa_ok($e, 'mop::object');   

    is($e->type, 'PANIC', '... got the expected value of `type`');
    like($e->msg, qr/^PANIC! at \//, '... got the expected value of `msg`');
};

subtest '... testing error from an error' => sub {
    like(
        exception {  mop::internal::util::error->new( type => 'NOTHING' ) },
        qr/\`msg\` is required/,
        '... got the error we expected'
    );
};

done_testing;
