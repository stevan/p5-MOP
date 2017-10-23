package MOP::Util;
# ABSTRACT: For MOP External Use Only

use strict;
use warnings;

use MOP::Role;
use MOP::Class;
use MOP::Internal::Util ();

our $VERSION   = '0.11';
our $AUTHORITY = 'cpan:STEVAN';

sub get_meta {
    my ($package) = @_;

    return $package->METACLASS->new( $package )
        if $package->can('METACLASS');

    my $meta = MOP::Role->new( $package );
    my $isa  = MOP::Internal::Util::GET_GLOB_SLOT( $meta->stash, 'ISA', 'ARRAY' );

    # without inheritance, we assume it is a role ...
    return $meta
        if not defined $isa
        || (ref $isa eq 'ARRAY' && scalar @$isa == 0);

    # with inheritance, we know it is a class ....
    return MOP::Class->new( $package );
}

sub compose_roles {
    my ($meta) = @_;

    my @roles = $meta->roles;
    MOP::Internal::Util::APPLY_ROLES( $meta, \@roles ) if @roles;
    return;
}

sub inherit_slots {
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

sub defer_until_UNITCHECK {
    my ($cb) = @_;

    MOP::Internal::Util::ADD_UNITCHECK_HOOK( $cb );
    return;
}

1;

__END__

=pod

=head1 DESCRIPTION

This is a public API of MOP related utility functions.

=head1 METHODS

=over 4

=item C<get_meta( $package )>

First this will check to see if C<$package> has a C<METACLASS>
method, and if so, will use it to construct the metaclass and
return it to you.

If no C<METACLASS> method is found, this function will next attempt
to guess the most sensible type of meta object for the C<$package>
supplied.

The test is simple, if there is anything in the C<@ISA> array inside
C<$package>, then it is clearly a class and then this function returns
a L<MOP::Class> instance. However, if there is nothing in C<@ISA> we
conservatively estimate that this is a role and then return a
L<MOP::Role> instance.

In pretty much all cases that matter, a role and a class are entirely
interchangable. The only real difference is that a class has methods
in the MOP for manipulating inheritance relationships (C<@ISA>)and
roles do not.

=item C<compose_roles( $meta )>

This will look to see if the C<$meta> object has any roles stored
in it's C<@DOES> array, if so it will compose the roles together
and apply that result to C<$meta>.

Note, if this is called more than once, the results are undefined.

=item C<inherit_slots( $meta )>

This will look to see if the C<$meta> object is a L<MOP::Class>
instance and if so, will then loop through the direct superclasses
(thouse in the C<@ISA> array of C<$meta>) and alias all the slots
into the C<$meta> namespace.

Note, if this is called more than once, the results are undefined.

=item C<defer_until_UNITCHECK( $cb )>

Given a B<CODE> reference, this will defer the execution
of that C<$cb> until the next available B<UNITCHECK> phase.

Note, it is not receommended to heavily abuse closures here, it
might get messy, might not, better to keep it clean and just not
go there.

=back

=cut



