#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP::Class');
}

=pod

TODO:
- test constructors with data
    - for both Point and Point3D
- test some meta info

=cut

{
    package Point;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
    our %HAS; BEGIN {
        %HAS = (
            x => sub { 0 },
            y => sub { 0 },
        )
    }

    sub x { $_[0]->{x} }
    sub y { $_[0]->{y} }

    sub set_x {
        my ($self, $x) = @_;
        $self->{x} = $x;
    }

    sub set_y {
        my ($self, $y) = @_;
        $self->{y} = $y;
    }

    sub clear {
        my ($self) = @_;
        @{ $self }{'x', 'y'} = (0, 0);
    }

    sub pack {
        my ($self) = @_;
        +{ x => $self->x, y => $self->y }
    }
}

# ... subclass it ...

{
    package Point3D;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('Point') }
    our %HAS; BEGIN { %HAS = (%Point::HAS, z => sub { 0 } ) }

    sub z { $_[0]->{z} }

    sub set_z {
        my ($self, $z) = @_;
        $self->{z} = $z;
    }

    sub clear {
        my ($self) = @_;
        my $data = $self->next::method;
        $self->{'z'} = 0;
    }

    sub pack {
        my ($self) = @_;
        my $data = $self->next::method;
        $data->{z} = $self->{z};
        $data;
    }

}

## Test an instance
subtest '... test an instance of Point' => sub {
    my $p = Point->new;
    isa_ok($p, 'Point');

    is_deeply(
        mro::get_linear_isa('Point'),
        [ 'Point', 'UNIVERSAL::Object' ],
        '... got the expected linear isa'
    );

    is $p->x, 0, '... got the default value for x';
    is $p->y, 0, '... got the default value for y';

    $p->set_x(10);
    is $p->x, 10, '... got the right value for x';

    $p->set_y(320);
    is $p->y, 320, '... got the right value for y';

    is_deeply $p->pack, { x => 10, y => 320 }, '... got the right value from pack';
};

## Test the instance
subtest '... test an instance of Point3D' => sub {
    my $p3d = Point3D->new();
    isa_ok($p3d, 'Point3D');
    isa_ok($p3d, 'Point');

    is_deeply(
        mro::get_linear_isa('Point3D'),
        [ 'Point3D', 'Point', 'UNIVERSAL::Object' ],
        '... got the expected linear isa'
    );

    is $p3d->z, 0, '... got the default value for z';

    $p3d->set_x(10);
    is $p3d->x, 10, '... got the right value for x';

    $p3d->set_y(320);
    is $p3d->y, 320, '... got the right value for y';

    $p3d->set_z(30);
    is $p3d->z, 30, '... got the right value for z';

    is_deeply $p3d->pack, { x => 10, y => 320, z => 30 }, '... got the right value from pack';
};

subtest '... meta test' => sub {

    my @MOP_object_methods = qw[
        new BUILDARGS CREATE DESTROY
    ];

    my @Point_methods = qw[
        x set_x
        y set_y
        pack
        clear
    ];

    my @Point3D_methods = qw[
        z set_z
        clear
    ];

    subtest '... test Point' => sub {

        my $Point = MOP::Class->new( name => 'Point' );
        isa_ok($Point, 'MOP::Class');

        is_deeply($Point->mro, [ 'Point', 'UNIVERSAL::Object' ], '... got the expected mro');
        is_deeply([ $Point->superclasses ], [ 'UNIVERSAL::Object' ], '... got the expected superclasses');

        foreach ( @Point_methods ) {
            ok($Point->has_method( $_ ), '... Point has method ' . $_);

            my $m = $Point->get_method( $_ );
            isa_ok($m, 'MOP::Method');
            is($m->name, $_, '... got the right method name (' . $_ . ')');
            ok(!$m->is_required, '... the ' . $_ . ' method is not a required method');
            is($m->origin_stash, 'Point', '... the ' . $_ . ' method was defined in Point class')
        }

        ok(Point->can( $_ ), '... Point can call method ' . $_)
            foreach @MOP_object_methods, @Point_methods;

    };

};

done_testing;


