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
isa_ok($Class, 'MOP::Object');

ok($Class->does_role('MOP::Role'), '... MOP::Class does MOP::Role');
ok($Class->does_role('MOP::Module'), '... MOP::Class does MOP::Module');

my @METHODS = qw[
    CREATE

    stash

    name
    version
    authority

    is_closed
        set_is_closed

    is_abstract
        set_is_abstract

    roles
        set_roles
        does_role

    superclasses
        set_superclasses
    mro

    all_attributes
        attributes
            has_attribute
            add_attribute
            get_attribute
            delete_attribute

        aliased_attributes
            has_attribute_alias
            alias_attribute
            get_attribute_alias
            delete_attribute_alias

    finalizers
        has_finalizers
        add_finalizer
        run_all_finalizers

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

can_ok($Class, $_) for @METHODS;

is($Class->name,      'MOP::Class', '... got the expected value from ->name');
is($Class->version,   '0.01', '... got the expected value from ->version');
is($Class->authority, 'cpan:STEVAN', '... got the expected value ->authority');

ok($Class->is_closed,    '... the class has been closed');

is_deeply([ $Class->superclasses ], [ 'MOP::Object' ], '... got the expected value from ->superclasses');
is_deeply($Class->mro, [ 'MOP::Class', 'MOP::Object', 'UNIVERSAL::Object' ], '... got the expected value from ->mro');

is_deeply([ $Class->roles ], [ 'MOP::Role' ], '... got the expected value from ->roles');

is_deeply([ sort map { $_->name } $Class->all_methods ], [ sort @METHODS ], '... got the expected value from ->methods');

is($Class->get_method('superclasses')->body, \&MOP::Class::superclasses, '... got the expected value from ->get_method');

like(
    exception { $Class->add_method('foo' => sub {}) },
    qr/^\[CLOSED\] Cannot add a method \(foo\) to \(MOP\:\:Class\) because it has been closed/,
    '... got the expected exception from ->add_method'
);

like(
    exception { $Class->delete_method('superclasses') },
    qr/^\[CLOSED\] Cannot delete method \(superclasses\) from \(MOP\:\:Class\) because it has been closed/,
    '... got the expected exception from ->delete_method'
);

can_ok($Class, 'superclasses');
is_deeply([ $Class->superclasses ], [ 'MOP::Object' ], '... got the expected value from ->superclasses (still)');

done_testing;
