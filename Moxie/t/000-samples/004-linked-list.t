#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

package LinkedList {
    use Moxie;

    extends 'MOP::Object';

    has 'head'  => ( is => 'ro' );
    has 'tail'  => ( is => 'ro' );
    has 'count' => ( is => 'ro', default => sub { 0 } );

    sub append ($self, $node) {
        unless($self->{tail}) {
            $self->{tail} = $node;
            $self->{head} = $node;
            $self->{count}++;
            return;
        }
        $self->{tail}->set_next($node);
        $node->set_previous($self->{tail});
        $self->{tail} = $node;
        $self->{count}++;
    }

    sub insert ($self, $index, $node) {
        die "Index ($index) out of bounds"
            if $index < 0 or $index > $self->{count} - 1;

        my $tmp = $self->{head};
        $tmp = $tmp->get_next while($index--);
        $node->set_previous($tmp->get_previous);
        $node->set_next($tmp);
        $tmp->get_previous->set_next($node);
        $tmp->set_previous($node);
        $self->{count}++;
    }

    sub remove ($self, $index) {
        die "Index ($index) out of bounds"
            if $index < 0 or $index > $self->{count} - 1;

        my $tmp = $self->{head};
        $tmp = $tmp->get_next while($index--);
        $tmp->get_previous->set_next($tmp->get_next);
        $tmp->get_next->set_previous($tmp->get_previous);
        $self->{count}--;
        $tmp->detach();
    }

    sub prepend ($self, $node) {
        unless($self->{head}) {
            $self->{tail} = $node;
            $self->{head} = $node;
            $self->{count}++;
            return;
        }
        $self->{head}->set_previous($node);
        $node->set_next($self->{head});
        $self->{head} = $node;
        $self->{count}++;
    }

    sub sum ($self) {
        my $sum = 0;
        my $tmp = $self->{head};
        do { $sum += $tmp->get_value } while($tmp = $tmp->get_next);
        return $sum;
    }
}

package LinkedListNode {
    use Moxie;

    extends 'MOP::Object';

    has 'previous' => ( reader => 'get_previous', writer => 'set_previous' );
    has 'next'     => ( reader => 'get_next',     writer => 'set_next'     );
    has 'value'    => ( reader => 'get_value',    writer => 'set_value'    );

    sub detach { @{ $_[0] }{ 'previous', 'next' } = (undef) x 2; $_[0] }
}

{
    my $ll = LinkedList->new();

    for (0..9) {
        $ll->append(
            LinkedListNode->new(value => $_)
        );
    }

    is($ll->head->get_value, 0, '... head is 0');
    is($ll->tail->get_value, 9, '... tail is 9');
    is($ll->count, 10, '... count is 10');

    $ll->prepend(LinkedListNode->new(value => -1));
    is($ll->count, 11, '... count is now 11');

    $ll->insert(5, LinkedListNode->new(value => 11));
    is($ll->count, 12, '... count is now 12');

    my $node = $ll->remove(8);
    is($ll->count, 11, '... count is 11 again');

    ok(!$node->get_next, '... detached node does not have a next');
    ok(!$node->get_previous, '... detached node does not have a previous');
    is($node->get_value, 6, '... detached node has the right value');
    ok($node->isa('LinkedListNode'), '... node is a LinkedListNode');

    eval { $ll->remove(99) };
    like($@, qr/^Index \(99\) out of bounds/, '... removing out of range produced error');
    eval { $ll->insert(-1, LinkedListNode->new(value => 2)) };
    like($@, qr/^Index \(-1\) out of bounds/, '... inserting out of range produced error');

    is($ll->sum, 49, '... things sum correctly');
}

done_testing;
