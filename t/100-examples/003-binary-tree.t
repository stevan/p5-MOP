#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('mop');
}

=pod

TODO:

Make the parent a weak-ref ... it is not right now.

=cut

{
    package BinaryTree;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('mop::object') }
    our %HAS; BEGIN {
        %HAS = (
            node   => sub { undef },
            parent => sub { undef },
            left   => sub { undef },
            right  => sub { undef },
        )
    }

    sub node {
        my $self = $_[0];
        $self->{node} = $_[1] if $_[1];
        $self->{node};
    }

    sub parent     {         $_[0]->{parent} }
    sub has_parent { defined $_[0]->{parent} }

    sub left     { $_[0]->{left} //= ref($_[0])->new( parent => $_[0] ) }
    sub has_left { defined $_[0]->{left} }

    sub right     { $_[0]->{right} //= ref($_[0])->new( parent => $_[0] ) }
    sub has_right { defined $_[0]->{right} }
}

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
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('BinaryTree') }
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