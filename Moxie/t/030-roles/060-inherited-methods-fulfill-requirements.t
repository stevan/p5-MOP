#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

package Role::Table {
    use Moxie;

    sub query_by_id;
}

package Role::Table::RO {
    use Moxie;

    with 'Role::Table';

    sub count;
    sub select;
}

package Table {
    use Moxie;

    extends 'MOP::Object';
       with 'Role::Table';

    sub query_by_id { 'Table::query_by_id' }
}

package Table::RO {
    use Moxie;

    extends 'Table';
       with 'Role::Table::RO';

    sub count  { 'Table::RO::count' }
    sub select { 'Table::RO::select' }
}

my $t = Table::RO->new;
isa_ok($t, 'Table::RO');

done_testing;
