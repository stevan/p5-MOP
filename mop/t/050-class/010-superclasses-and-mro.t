#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('mop::class');
}

=pod

TODO:

=cut

{
    package Foo::NoBaseClass;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    package Foo::MopObjectBaseClass;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our @ISA; BEGIN { @ISA = ('mop::object') }

    package Foo::WithSuperclass;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our @ISA; BEGIN { @ISA = ('Foo::NoBaseClass') }

    package Foo::VeryDerived;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our @ISA; BEGIN { @ISA = ('Foo::WithSuperclass') }

    package Foo::WithMultiple;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our @ISA; BEGIN { @ISA = ('Foo::WithSuperclass', 'Foo::MopObjectBaseClass') }
}

subtest '... testing the superclass methods' => sub {

    {
        my $c = mop::class->new( name => 'Foo::NoBaseClass' );
        isa_ok($c, 'mop::class');

        is_deeply([ $c->superclasses ], [], '... got no superclasses');
        is_deeply($c->mro, [ 'Foo::NoBaseClass' ], '... got only myself in the mro');
    }

    {
        my $c = mop::class->new( name => 'Foo::MopObjectBaseClass' );
        isa_ok($c, 'mop::class');

        is_deeply([ $c->superclasses ], [ 'mop::object' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::MopObjectBaseClass', 'mop::object' ], '... got the expected things in the mro');
    }

    {
        my $c = mop::class->new( name => 'Foo::WithSuperclass' );
        isa_ok($c, 'mop::class');

        is_deeply([ $c->superclasses ], [ 'Foo::NoBaseClass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::WithSuperclass', 'Foo::NoBaseClass' ], '... got the expected things in the mro');
    }

    {
        my $c = mop::class->new( name => 'Foo::VeryDerived' );
        isa_ok($c, 'mop::class');

        is_deeply([ $c->superclasses ], [ 'Foo::WithSuperclass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::VeryDerived', 'Foo::WithSuperclass', 'Foo::NoBaseClass' ], '... got the expected things in the mro');
    }

    {
        my $c = mop::class->new( name => 'Foo::WithMultiple' );
        isa_ok($c, 'mop::class');

        is_deeply([ $c->superclasses ], [ 'Foo::WithSuperclass', 'Foo::MopObjectBaseClass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::WithMultiple', 'Foo::WithSuperclass', 'Foo::NoBaseClass', 'Foo::MopObjectBaseClass', 'mop::object' ], '... got the expected things in the mro');
    }

};

done_testing;




