#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('MOP::Class');
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

    package Foo::UNIVERSALObjectBaseClass;
    use strict;
    use warnings;

    our $VERSION   = '0.01';
    our $AUTHORITY = 'cpan:STEVAN';

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

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

    our @ISA; BEGIN { @ISA = ('Foo::WithSuperclass', 'Foo::UNIVERSALObjectBaseClass') }
}

subtest '... testing the superclass methods' => sub {

    {
        my $c = MOP::Class->new( name => 'Foo::NoBaseClass' );
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [], '... got no superclasses');
        is_deeply($c->mro, [ 'Foo::NoBaseClass' ], '... got only myself in the mro');
    }

    {
        my $c = MOP::Class->new( name => 'Foo::UNIVERSALObjectBaseClass' );
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [ 'UNIVERSAL::Object' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::UNIVERSALObjectBaseClass', 'UNIVERSAL::Object' ], '... got the expected things in the mro');
    }

    {
        my $c = MOP::Class->new( name => 'Foo::WithSuperclass' );
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [ 'Foo::NoBaseClass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::WithSuperclass', 'Foo::NoBaseClass' ], '... got the expected things in the mro');
    }

    {
        my $c = MOP::Class->new( name => 'Foo::VeryDerived' );
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [ 'Foo::WithSuperclass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::VeryDerived', 'Foo::WithSuperclass', 'Foo::NoBaseClass' ], '... got the expected things in the mro');
    }

    {
        my $c = MOP::Class->new( name => 'Foo::WithMultiple' );
        isa_ok($c, 'MOP::Class');

        is_deeply([ $c->superclasses ], [ 'Foo::WithSuperclass', 'Foo::UNIVERSALObjectBaseClass' ], '... got the expected superclasses');
        is_deeply($c->mro, [ 'Foo::WithMultiple', 'Foo::WithSuperclass', 'Foo::NoBaseClass', 'Foo::UNIVERSALObjectBaseClass', 'UNIVERSAL::Object' ], '... got the expected things in the mro');
    }

};

done_testing;




