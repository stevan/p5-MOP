#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

my $Class = MOP::Class->new( name => 'MOP::Class' );
isa_ok($Class, 'MOP::Class');

ok($Class->does_role('MOP::Role'), '... MOP::Class does MOP::Role');

my @METHODS = qw[
    BUILDARGS
    CREATE

    stash

    name
    version
    authority

    roles
        set_roles
        does_role

    superclasses
        set_superclasses
    mro

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
        has_required_method
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

can_ok($Class, $_) for @METHODS;

is($Class->name,      'MOP::Class', '... got the expected value from ->name');
is($Class->version,   $MOP::Class::VERSION, '... got the expected value from ->version');
is($Class->authority, 'cpan:STEVAN', '... got the expected value ->authority');

is_deeply([ $Class->superclasses ], [ 'UNIVERSAL::Object::Immutable' ], '... got the expected value from ->superclasses');
is_deeply($Class->mro, [ 'MOP::Class', 'UNIVERSAL::Object::Immutable', 'UNIVERSAL::Object' ], '... got the expected value from ->mro');

is_deeply([ $Class->roles ], [ 'MOP::Role' ], '... got the expected value from ->roles');

is_deeply([ sort map { $_->name } $Class->all_methods ], [ sort @METHODS ], '... got the expected value from ->methods');

is($Class->get_method('superclasses')->body, \&MOP::Class::superclasses, '... got the expected value from ->get_method');

can_ok($Class, 'superclasses');
is_deeply([ $Class->superclasses ], [ 'UNIVERSAL::Object::Immutable' ], '... got the expected value from ->superclasses (still)');

done_testing;
