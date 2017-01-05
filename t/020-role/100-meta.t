#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

my $Role = MOP::Role->new( name => 'MOP::Role' );
isa_ok($Role, 'MOP::Role');

ok($Role->does_role('MOP::Module'), '... MOP::Role does MOP::Module');

my @METHODS = qw[
    CREATE

    stash

    name
    version
    authority

    is_abstract
        set_is_abstract

    roles
        set_roles
        does_role

    all_slots
        slots
            has_slot
            add_slot
            get_slot
            delete_slot

        aliased_slots
            has_slot_alias
            alias_slot
            get_slot_alias
            delete_slot_alias

    required_methods
        requires_method
        add_required_method
        get_required_method
        delete_required_method

    all_methods
        methods
            has_method
            add_method
            get_method
            delete_method

        aliased_methods
            has_method_alias
            alias_method
            get_method_alias
            delete_method_alias
];

can_ok($Role, $_) for @METHODS;

is($Role->name,      'MOP::Role', '... got the expected value from ->name');
is($Role->version,   '0.01', '... got the expected value from ->version');
is($Role->authority, 'cpan:STEVAN', '... got the expected value ->authority');

is_deeply([ sort map { $_->name } $Role->methods ], [ sort @METHODS ], '... got the expected value from ->methods');

is($Role->get_method('name')->body, \&MOP::Role::name, '... got the expected value from ->get_method');

done_testing;


