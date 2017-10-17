package MOP::Util;
# ABSTRACT: For MOP External Use Only

use strict;
use warnings;

use MOP::Role;
use MOP::Internal::Util ();

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

sub GET_META_FOR {
    my ($package) = @_;

    my $meta = MOP::Role->new( $package );
    my $isa  = MOP::Internal::Util::GET_GLOB_SLOT( $meta->stash, 'ISA', 'ARRAY' );

    # without inheritance, we assume it is a role ...
    return $meta
        if not defined $isa
        || (ref $isa eq 'ARRAY' && scalar @$isa == 0);


    # with inheritance, we know it is a class ....
    return MOP::Class->new( $package );
}

sub APPLY_ROLES {
    my ($meta) = @_;

    MOP::Internal::Util::APPLY_ROLES(
        $meta,
        [ $meta->roles ],
        to => $meta->isa('MOP::Class') ? 'class' : 'role'
    );

    # nothing to return ...
    return;
}

sub INHERIT_SLOTS {
    my ($meta) = @_;

    # roles don't inherit, so do nothing ...
    return unless $meta->isa('MOP::Class');

    # otherwise, inherit only the slots from
    # the direct superclasses, this assumes that
    # these superclasses have already done
    # INHERIT_SLOTS themselves.
    foreach my $super ( map { MOP::Role->new( name => $_ ) } $meta->superclasses ) {
        # remember to use all_slots so that it
        # will gives us *all* the slots, including
        # those that are themselves inherited ...
        foreach my $slot ( $super->all_slots ) {
            # we always just alias this anyway ...
            $meta->alias_slot( $slot->name, $slot->initializer )
                unless $meta->has_slot( $slot->name )
                    || $meta->has_slot_alias( $slot->name );
        }
    }

    # nothing to return ...
    return;
}

1;

__END__

=pod

=head1 DESCRIPTION

This is the public API for MOP related utility functions.

=head1 METHODS

=over 4

=item C<GET_META_FOR( $package )>

=item C<APPLY_ROLES( $meta )>

=item C<INHERIT_SLOTS( $meta )>

=back

=cut



