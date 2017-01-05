#!/usr/bin/perl -w

use v5.20;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

BEGIN {

    package Eq {
        use Moxie;

        sub equal_to;

        sub not_equal_to ($self, $other) {
            not $self->equal_to($other);
        }
    }

    package Comparable {
        use Moxie;

        with 'Eq';

        sub compare;

        sub equal_to ($self, $other) {
            $self->compare($other) == 0;
        }

        sub greater_than ($self, $other)  {
            $self->compare($other) == 1;
        }

        sub less_than  ($self, $other) {
            $self->compare($other) == -1;
        }

        sub greater_than_or_equal_to ($self, $other)  {
            $self->greater_than($other) || $self->equal_to($other);
        }

        sub less_than_or_equal_to ($self, $other)  {
            $self->less_than($other) || $self->equal_to($other);
        }
    }

    package Printable {
        use Moxie;

        sub to_string;
    }

    package US::Currency {
        use Moxie;

        extends 'MOP::Object';
           with 'Comparable', 'Printable';

        has amount => ( default => sub { 0 } );

        sub compare ($self, $other) {
            $self->{amount} <=> $other->{amount};
        }

        sub to_string ($self) {
            sprintf '$%0.2f USD' => $self->{amount};
        }
    }

}

my $Eq         = MOP::Role->new( name => 'Eq' );
my $Comparable = MOP::Role->new( name => 'Comparable');
my $USCurrency = MOP::Class->new( name => 'US::Currency');

ok($Comparable->does_role( 'Eq' ), '... Comparable does the Eq role');

ok($USCurrency->does_role( 'Eq' ), '... US::Currency does Eq');
ok($USCurrency->does_role( 'Comparable' ), '... US::Currency does Comparable');
ok($USCurrency->does_role( 'Printable' ), '... US::Currency does Printable');

ok($Eq->requires_method('equal_to'), '... EQ::equal_to is a stub method');
ok(!$Eq->requires_method('not_equal_to'), '... EQ::not_equal_to is NOT a stub method');

{
    my $dollar = US::Currency->new( amount => 10 );
    ok($dollar->isa( 'US::Currency' ), '... the dollar is a US::Currency instance');
    ok($dollar->DOES( 'Eq' ), '... the dollar does the Eq role');
    ok($dollar->DOES( 'Comparable' ), '... the dollar does the Comparable role');
    ok($dollar->DOES( 'Printable' ), '... the dollar does the Printable role');

    can_ok($dollar, 'equal_to');
    can_ok($dollar, 'not_equal_to');

    can_ok($dollar, 'greater_than');
    can_ok($dollar, 'greater_than_or_equal_to');
    can_ok($dollar, 'less_than');
    can_ok($dollar, 'less_than_or_equal_to');

    can_ok($dollar, 'compare');
    can_ok($dollar, 'to_string');

    is($dollar->to_string, '$10.00 USD', '... got the right to_string value');

    ok($dollar->equal_to( $dollar ), '... we are equal to ourselves');
    ok(!$dollar->not_equal_to( $dollar ), '... we are not not equal to ourselves');

    ok(US::Currency->new( amount => 20 )->greater_than( $dollar ), '... 20 is greater than 10');
    ok(!US::Currency->new( amount => 2 )->greater_than( $dollar ), '... 2 is not greater than 10');

    ok(!US::Currency->new( amount => 10 )->greater_than( $dollar ), '... 10 is not greater than 10');
    ok(US::Currency->new( amount => 10 )->greater_than_or_equal_to( $dollar ), '... 10 is greater than or equal to 10');
}

{
    my $dollar = US::Currency->new;
    ok($dollar->isa( 'US::Currency' ), '... the dollar is a US::Currency instance');

    is($dollar->to_string, '$0.00 USD', '... got the right to_string value');
}

done_testing;


