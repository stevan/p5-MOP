package Moxie::Util;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## Inheriting required methods

sub INHERIT_REQUIRED_METHODS {
    my ($meta) = @_;
    foreach my $super ( map { MOP::Role->new( name => $_ ) } $meta->superclasses ) {
        foreach my $required_method ( $super->required_methods ) {
            $meta->add_required_method( $required_method->name )
                unless $meta->has_method( $required_method->name );
        }
    }
    $meta->set_is_abstract(1)
        if $meta->required_methods;
    return;
}

## Attribute gathering ...

# NOTE:
# The %HAS variable will cache things much like
# the package stash method/cache works. It will
# be possible to distinguish the local attributes
# from the inherited ones because the default sub
# will have a different stash name.

sub GATHER_ALL_ATTRIBUTES {
    my ($meta) = @_;
    foreach my $super ( map { MOP::Role->new( name => $_ ) } @{ $meta->mro } ) {
        foreach my $attr ( $super->attributes ) {
            $meta->alias_attribute( $attr->name, $attr->initializer )
                unless $meta->has_attribute( $attr->name )
                    || $meta->has_attribute_alias( $attr->name );
        }
    }
    return;
}

1;

__END__
