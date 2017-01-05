#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

=pod

TODO:

Make the parent a weak-ref ... it is not right now.

=cut


package BinaryTree {
    use Moxie;

    extends 'MOP::Object';

    has 'node'   => ( is => 'rw' );
    has 'parent' => ( is => 'ro', predicate => 'has_parent' );
    has 'left'   => ( predicate => 'has_left'  );
    has 'right'  => ( predicate => 'has_right' );

    sub left  ($self) { $self->{left}  //= ref($self)->new( parent => $self ) }
    sub right ($self) { $self->{right} //= ref($self)->new( parent => $self ) }
}

#my $parent_attr = MOP::meta('BinaryTree')->get_attribute('$!parent');

{
    my $t = BinaryTree->new;
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');

    ok($t->left->has_parent, '... left has a parent');
    is($t->left->parent, $t, '... and it is us');

    #ok($parent_attr->is_data_in_slot_weak_for($t->left), '... the value is weakened');

    ok($t->right->has_parent, '... right has a parent');
    is($t->right->parent, $t, '... and it is us');

    #ok($parent_attr->is_data_in_slot_weak_for($t->right), '... the value is weakened');
}

package MyBinaryTree {
    use Moxie;

    extends 'BinaryTree';
}

{
    my $t = MyBinaryTree->new;
    ok($t->isa('MyBinaryTree'), '... this is a MyBinaryTree object');
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');
}

done_testing;
