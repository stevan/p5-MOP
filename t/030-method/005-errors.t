#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::method');
}

=pod

TODO:

=cut

subtest '... simple mop::method error test' => sub {

    like(
        exception { mop::method->new },
        qr/^\[MISSING_ARG\] You must specify a method body/,
        '... got the expection we expected'
    );

    like(
        exception { mop::method->new( body => [] ) },
        qr/^\[INVALID_ARG\] The body specified must be a CODE reference/,
        '... got the expection we expected'
    );
};

subtest '... odd cases' => sub {

    my $m = bless \(my $x = []) => 'mop::method'; # create a "wrong" instance
    ok(!$m->is_required, '... and this is not a required method');
};

done_testing;
