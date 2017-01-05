#!perl

use strict;
use warnings;

use Test::More;

package Service {
    use Moxie;

    has 'is_locked' => (default => sub { 0 });
}

package WithClass {
    use Moxie;

    with 'Service';
}

package WithParameters {
    use Moxie;

    with 'Service';
}

package WithDependencies {
    use Moxie;

    with 'Service';
}

foreach my $role (map { MOP::Role->new( name => $_ ) } qw[
    WithClass
    WithParameters
    WithDependencies
]) {
    ok($role->has_attribute('is_locked'), '... the is_locked attribute is treated as a proper attribute because it was composed from a role');
    ok($role->has_attribute_alias('is_locked'), '... the is_locked attribute is also an alias, because that is how we install things in roles');
    is_deeply(
        [ map { $_->name } $role->attributes ],
        [ 'is_locked' ],
        '... these roles should then show the is_locked attribute'
    );
};


{
    local $@;
    eval q[
        package ConstructorInjection {
            use Moxie;

            extends 'MOP::Object';
               with 'WithClass', 'WithParameters', 'WithDependencies';
        }
    ];
    is($@, "", '... this worked');
}

done_testing;
