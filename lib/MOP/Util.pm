package MOP::Util;
# ABSTRACT: For MOP External Use Only

use strict;
use warnings;

use MOP::Role;
use MOP::Internal::Util ();

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

sub APPLY_ROLES {
    my ($meta) = @_;
    MOP::Internal::Util::APPLY_ROLES(
        $meta,
        [ $meta->roles ],
        to => $meta->isa('MOP::Class') ? 'class' : 'role'
    );
}

sub INHERIT_SLOTS {
    my ($meta) = @_;
    foreach my $super ( map { MOP::Role->new( name => $_ ) } @{ $meta->mro } ) {
        foreach my $slot ( $super->slots ) {
            $meta->alias_slot( $slot->name, $slot->initializer )
                unless $meta->has_slot( $slot->name )
                    || $meta->has_slot_alias( $slot->name );
        }
    }
}

1;

__END__

=pod

=head1 DESCRIPTION

This is the public API for MOP related utility functions.

=head1 METHODS

=over 4

=item C<APPLY_ROLES( $meta )>

=item C<INHERIT_SLOTS( $meta )>

=back

=cut



