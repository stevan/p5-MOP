#!perl

use strict;
use warnings;

use Test::More;

package Service {
    use Moxie;

    sub is_locked { 0 }
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
    ok($role->has_method('is_locked'), '... the is_locked method is treated as a proper method because it was composed from a role');
    ok($role->has_method_alias('is_locked'), '... the is_locked method is also an alias, because that is how we install things in roles');
    is_deeply(
        [ map { $_->name } $role->methods ],
        [ 'is_locked' ],
        '... these roles should then show the is_locked method'
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
