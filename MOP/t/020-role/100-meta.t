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
isa_ok($Role, 'MOP::Object');

ok($Role->does_role('MOP::Module'), '... MOP::Role does MOP::Module');

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

can_ok($Role, $_) for @METHODS;

is($Role->name,      'MOP::Role', '... got the expected value from ->name');
is($Role->version,   '0.01', '... got the expected value from ->version');
is($Role->authority, 'cpan:STEVAN', '... got the expected value ->authority');

ok($Role->is_closed,    '... the role has been closed');

is_deeply([ sort map { $_->name } $Role->methods ], [ sort @METHODS ], '... got the expected value from ->methods');

is($Role->get_method('name')->body, \&MOP::Role::name, '... got the expected value from ->get_method');

like(
    exception { $Role->add_method('foo' => sub {}) },
    qr/^\[CLOSED\] Cannot add a method \(foo\) to \(MOP\:\:Role\) because it has been closed/,
    '... got the expected exception from ->add_method'
);

like(
    exception { $Role->delete_method('name') },
    qr/^\[CLOSED\] Cannot delete method \(name\) from \(MOP\:\:Role\) because it has been closed/,
    '... got the expected exception from ->delete_method'
);

can_ok($Role, 'name');
is($Role->name, 'MOP::Role', '... got the expected value from ->name');

{
    $Role->set_is_closed(0);

    is(
        exception { $Role->add_method('foo' => sub { 'FOO' }) },
        undef,
        '... got no exception from ->add_method'
    );

    can_ok($Role, 'foo');
    is($Role->foo, 'FOO', '... got the expected value from ->foo');

    is(
        exception { $Role->delete_method('foo') },
        undef,
        '... got the expected exception from ->delete_method'
    );

    ok(!$Role->can('foo'), '... removed the ->foo method');

    $Role->set_is_closed(1);
}

like(
    exception { $Role->add_method('foo' => sub {}) },
    qr/^\[CLOSED\] Cannot add a method \(foo\) to \(MOP\:\:Role\) because it has been closed/,
    '... got the expected exception from ->add_method'
);

like(
    exception { $Role->delete_method('name') },
    qr/^\[CLOSED\] Cannot delete method \(name\) from \(MOP\:\:Role\) because it has been closed/,
    '... got the expected exception from ->delete_method'
);

can_ok($Role, 'name');
is($Role->name, 'MOP::Role', '... got the expected value from ->name');

done_testing;


