package MOP::Role;
# ABSTRACT: A representation of a role

use strict;
use warnings;

use UNIVERSAL::Object;

use MOP::Method;
use MOP::Slot;

use MOP::Internal::Util;

our $VERSION   = '0.05';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object' };

sub BUILDARGS {
    my $class = shift;
    my %args;

    if ( scalar( @_ ) == 1 ) {
        if ( ref $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                if ( MOP::Internal::Util::IS_STASH_REF( $_[0] ) ) {
                    # if it is a stash, grab the name
                    %args = (
                        name  => MOP::Internal::Util::GET_NAME( $_[0] ),
                        stash => $_[0]
                    );
                }
                else {
                    # just plain old HASH ref ...
                    %args = %{ $_[0] };
                }
            }
        }
        else {
            # assume it is a single package name ...
            %args = ( name => $_[0] );
        }
    }
    else {
        # assume we got key/value pairs ...
        %args = @_;
    }

    die '[ARGS] You must specify a package name'
        unless $args{name};

    die '[ARGS] You must specify a valid package name, not `'.$_[0].'`'
        unless MOP::Internal::Util::IS_VALID_MODULE_NAME( $args{name} );

    return \%args;
}

sub CREATE {
    my ($class, $args) = @_;

    # intiialize the stash ...
    my $stash = $args->{stash};

    # if we have it, otherwise get it ...
    unless ( $stash ) {
        # get a ref to to the stash itself ...
        no strict 'refs';
        $stash = \%{ $args->{name} . '::' };
    }
    # and then a ref to that, because we
    # eventually will need to bless it and
    # we do not want to bless the actual
    # stash because that persists beyond
    # the lifetime of this object, so we
    # bless a ref of a ref then ...
    return \$stash;
}

# stash

sub stash {
    my ($self) = @_;
    return $$self; # returns the direct HASH ref of the stash
}

# identity

sub name {
    my ($self) = @_;
    return MOP::Internal::Util::GET_NAME( $self->stash );
}

sub version {
    my ($self) = @_;
    my $version = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'VERSION', 'SCALAR' );
    return unless $version;
    return $$version;
}

sub authority {
    my ($self) = @_;
    my $authority = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'AUTHORITY', 'SCALAR' );
    return unless $authority;
    return $$authority;
}

# other roles

sub roles {
    my ($self) = @_;
    my $does = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'DOES', 'ARRAY' );
    return unless $does;
    return @$does;
}

sub set_roles {
    my ($self, @roles) = @_;
    die '[ARGS] You must specify at least one role'
        if scalar( @roles ) == 0;
    MOP::Internal::Util::SET_GLOB_SLOT( $self->stash, 'DOES', \@roles );
    return;
}

sub does_role {
    my ($self, $to_test) = @_;

    die '[ARGS] You must specify a role'
        unless $to_test;

    my @roles = $self->roles;

    # no roles, will never match ...
    return 0 unless @roles;

    # try the simple way first ...
    foreach my $role ( @roles ) {
        return 1 if $role eq $to_test;
    }

    # then try the harder way next ...
    foreach my $role ( @roles ) {
        return 1
            if MOP::Role->new( name => $role )
                        ->does_role( $to_test );
    }

    # oh well ...
    return 0;
}

## Methods

# get them all; regular, aliased & required
sub all_methods {
    my $stash = $_[0]->stash;
    my @methods;
    foreach my $candidate ( keys %$stash ) {
        if ( my $code = MOP::Internal::Util::GET_GLOB_SLOT( $stash, $candidate, 'CODE' ) ) {
            push @methods => MOP::Method->new( body => $code );
        }
    }
    return @methods;
}

# just the local non-required methods
sub methods {
    my $self  = shift;
    my $class = $self->name;
    my @roles = $self->roles;

    my @methods;
    foreach my $method ( $self->all_methods ) {
        # if the method is required, we don't want it
        next if $method->is_required;

        # if the method is not originally from the
        # class, then we probably don't want it ...
        if ( $method->origin_stash ne $class ) {
            # if our class has roles, then non-local
            # methods *might* be valid, so ...

            # if we don't have roles, then
            # it can't be valid, so we don't
            # want it
            next unless @roles;

            # if we do have roles, but our
            # method was not aliased from one
            # of them, then we don't want it.
            next unless $method->was_aliased_from( @roles );

            # if we are here then we have
            # a non-required method that is
            # not from the local class, it
            # has roles and was aliased from
            # one of them, which means we want
            # to keep it, so we let it fall through
        }

        # if we are here then we have
        # a non-required method that is
        # either from the local class,
        # or is not from a local class,
        # but has fallen through our
        # conditional above.

        push @methods => $method;
    }

    return @methods;
}

# just the non-local non-required methods
sub aliased_methods {
    my $self  = shift;
    my $class = $self->name;
    return grep { (!$_->is_required) && $_->origin_stash ne $class } $self->all_methods
}

# just the required methods (locality be damned)
# NOTE:
# We don't care where are required method comes from
# just that one exists, so aliasing is not part of the
# criteria here.
# - SL
sub required_methods {
    my $self = shift;
    return grep { $_->is_required } $self->all_methods
}

# required methods

# NOTE:
# there is no real heavy need to use the MOP::Method API
# below because 1) it is not needed, and 2) the MOP::Method
# API is really just an information shim, it does not perform
# much in the way of actions. From my point of view, the below
# operations are mostly stash manipulation functions and so
# therefore belong here in the continuim of responsibility/
# ownership.
#
## The only argument that could likely be made is for the
## MOP::Method API to handle creating the NULL CV for the
## add_required_method, but that would require us to pass in
## a MOP::Method instance, which would be silly since we never
## need it anyway.
#
# - SL

sub has_required_method {
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the required method to look for'
        unless $name;

    return 0 unless exists $stash->{ $name };
    return MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );
}

# consistency is a good thing ...
sub requires_method { goto &has_required_method }

sub get_required_method {
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the required method to get'
        unless $name;

    # check these two easy cases first ...
    return unless exists $stash->{ $name };
    return unless MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV ...
    my $method = MOP::Method->new(
        body => MOP::Internal::Util::GET_GLOB_SLOT( $stash, $name, 'CODE' )
    );
    # and make sure it is local, and
    # then return the method ...
    return $method if $method->origin_stash eq $class;
    # or return nothing ...
    return;
}

sub add_required_method {
    my ($self, $name) = @_;

    die '[ARGS] You must specify the name of the required method to add'
        unless $name;

    # if we already have a glob there ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, just return
        return if MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $glob );
        # and if we don't and we have a CODE slot, we
        # need to die because this doesn't make sense
        die "[CONFLICT] Cannot add a required method ($name) when there is a regular method already there"
            if defined *{ $glob }{CODE};
    }

    # if we get here, then we
    # just create a null CV
    MOP::Internal::Util::CREATE_NULL_CV( $self->name, $name );

    return;
}

sub delete_required_method {
    my ($self, $name) = @_;

   die '[ARGS] You must specify the name of the required method to delete'
        unless $name;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we must delete it
            MOP::Internal::Util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
            return;
        }
        else {
            # and if we have a CV slot, but it doesn't have
            # a NULL CV in it, then we need to die because
            # this doesn't make sense
            die "[CONFLICT] Cannot delete a required method ($name) when there is a regular method already there"
                if defined *{ $glob }{CODE};

            # if we have the glob, but no CV slot (NULL or otherwise)
            # we do nothing ...
            return;
        }
    }
    # if there is no stash entry for $name, we do nothing
    return;
}

# methods

sub has_method {
    my $self  = $_[0];
    my $class = $self->name;
    my $stash = $self->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the method to look for'
        unless $name;

    # check these two easy cases first ...
    return 0 unless exists $stash->{ $name };
    return 0 if MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV and make sure it is
    # local, and return accordingly
    if ( my $code = MOP::Internal::Util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = MOP::Method->new( body => $code );
        my @roles  = $self->roles;
        # and make sure it is local, and
        # then return accordingly
        return $method->origin_stash eq $class
            || (@roles && $method->was_aliased_from( @roles ));
    }

    # if there was no CV, return false.
    return 0;
}

sub get_method {
    my $self  = $_[0];
    my $class = $self->name;
    my $stash = $self->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the method to get'
        unless $name;

    # check the easy cases first ...
    return unless exists $stash->{ $name };
    return if MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV ...
    if ( my $code = MOP::Internal::Util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = MOP::Method->new( body => $code );
        my @roles  = $self->roles;
        # and make sure it is local, and
        # then return accordingly
        return $method
            if $method->origin_stash eq $class
            || (@roles && $method->was_aliased_from( @roles ));
    }

    # if there was no CV, return false.
    return;
}

sub add_method {
    my ($self, $name, $code) = @_;

    die '[ARGS] You must specify the name of the method to add'
        unless $name;

    die '[ARGS] You must specify a CODE reference to add as a method'
        unless $code && ref $code eq 'CODE';

    MOP::Internal::Util::INSTALL_CV( $self->name, $name, $code, set_subname => 1 );
    return;
}

sub delete_method {
    my ($self, $name) = @_;

    die '[ARGS] You must specify the name of the method to delete'
        unless $name;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we need to die because this
            # shouldn't happen, we should only
            # delete regular methods.
            die "[CONFLICT] Cannot delete a regular method ($name) when there is a required method already there";
        }
        else {
            # if we don't have a code slot ...
            return unless defined *{ $glob }{CODE};

            # we need to make sure it is local, and
            # otherwise, error accordingly
            my $method = MOP::Method->new( body => *{ $glob }{CODE} );
            my @roles  = $self->roles;

            # if the method has not come from
            # the local class, we need to see
            # if it was added from a role
            if ($method->origin_stash ne $self->name) {

                # if it came from a role, then it is
                # okay to be deleted, but if it didn't
                # then we have an error cause they are
                # trying to delete an alias using the
                # regular method method
                unless ( @roles && $method->was_aliased_from( @roles ) ) {
                    die "[CONFLICT] Cannot delete a regular method ($name) when there is an aliased method already there"
                }
            }

            # but if we have a regular method, then we
            # can just delete the CV from the glob
            MOP::Internal::Util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
        }
    }
    # if there is no stash entry for $name, we do nothing
    return;
}

# aliased methods

sub get_method_alias {
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the method alias to look for'
        unless $name;

    # check the easy cases first ...
    return unless exists $stash->{ $name };
    return if MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV ...
    if ( my $code = MOP::Internal::Util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = MOP::Method->new( body => $code );
        # and make sure it is not local, and
        # then return accordingly
        return $method
            if $method->origin_stash ne $class;
    }

    # if there was no CV, return false.
    return;
}

# NOTE:
# Should aliasing be aloud even after a class is closed?
# Probably not, but it might not be a bad idea to at
# least discuss in more detail what happens when a class
# is actually closed.
# - SL

sub alias_method {
    my ($self, $name, $code) = @_;

    die '[ARGS] You must specify the name of the method alias to add'
        unless $name;

    die '[ARGS] You must specify a CODE reference to add as a method alias'
        unless $code && ref $code eq 'CODE';

    MOP::Internal::Util::INSTALL_CV( $self->name, $name, $code, set_subname => 0 );
    return;
}

sub delete_method_alias {
    my ($self, $name) = @_;

    die '[ARGS] You must specify the name of the method alias to remove'
        unless $name;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we need to die because this
            # shouldn't happen, we should only
            # delete regular methods.
            die "[CONFLICT] Cannot delete an aliased method ($name) when there is a required method already there";
        }
        else {
            # if we don't have a code slot ...
            return unless defined *{ $glob }{CODE};

            # we need to make sure it is local, and
            # otherwise, error accordingly
            my $method = MOP::Method->new( body => *{ $glob }{CODE} );

            die "[CONFLICT] Cannot delete an aliased method ($name) when there is a regular method already there"
                if $method->origin_stash eq $self->name;

            # but if we have a regular method, then we
            # can just delete the CV from the glob
            MOP::Internal::Util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
        }
    }
    # if there is no stash entry for $name, we do nothing
    return;
}

sub has_method_alias {
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    die '[ARGS] You must specify the name of the method alias to look for'
        unless $name;

    # check these two easy cases first ...
    return 0 unless exists $stash->{ $name };
    return 0 if MOP::Internal::Util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV and make sure it is
    # local, and return accordingly
    if ( my $code = MOP::Internal::Util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        return MOP::Method->new( body => $code )->origin_stash ne $class;
    }

    # if there was no CV, return false.
    return 0;
}

## Slots

## FIXME:
## The same problem we had methods needs to be fixed with
## slots, just checking the origin_stash v. class is
## not enough, we need to check aliasing as well.
## - SL

# get them all; regular & aliased
sub all_slots {
    my $self = shift;
    my $has = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );
    return unless $has;
    return map {
        MOP::Slot->new(
            name        => $_,
            initializer => $has->{ $_ }
        )
    } keys %$has;
}

# just the local slots
sub slots {
    my $self  = shift;
    my $class = $self->name;
    my @roles = $self->roles;
    return grep {
        $_->origin_stash eq $class
            ||
        (@roles && $_->was_aliased_from( @roles ))
    } $self->all_slots
}

# just the non-local slots
sub aliased_slots {
    my $self  = shift;
    my $class = $self->name;
    return grep { $_->origin_stash ne $class } $self->all_slots
}

## regular ...

sub has_slot {
    my $self  = $_[0];
    my $name  = $_[1];
    my $class = $self->name;
    my $has   = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    die '[ARGS] You must specify the name of the slot to look for'
        unless $name;

    return unless $has;
    return unless exists $has->{ $name };

    my @roles = $self->roles;
    my $slot  = MOP::Slot->new(
        name        => $name,
        initializer => $has->{ $name }
    );

    return $slot->origin_stash eq $class
        || (@roles && $slot->was_aliased_from( @roles ));
}

sub get_slot {
    my $self  = $_[0];
    my $name  = $_[1];
    my $class = $self->name;
    my $has   = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    die '[ARGS] You must specify the name of the slot to get'
        unless $name;

    return unless $has;
    return unless exists $has->{ $name };

    my @roles = $self->roles;
    my $slot  = MOP::Slot->new(
        name        => $name,
        initializer => $has->{ $name }
    );

    return $slot
        if $slot->origin_stash eq $class
        || (@roles && $slot->was_aliased_from( @roles ));

    return;
}

sub add_slot {
    my $self        = $_[0];
    my $name        = $_[1];
    my $initializer = $_[2];

    die '[ARGS] You must specify the name of the slot to add'
        unless $name;

    die '[ARGS] You must specify an initializer CODE reference to associate with the slot'
        unless $initializer && ref $initializer eq 'CODE';

    my $stash = $self->stash;
    my $class = $self->name;
    my $slot  = MOP::Slot->new( name => $name, initializer => $initializer );

    die '[ERROR] Slot is not from local (' . $class . '), it is from (' . $slot->origin_stash . ')'
        if $slot->origin_stash ne $class;

    my $has = MOP::Internal::Util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    MOP::Internal::Util::SET_GLOB_SLOT( $stash, 'HAS', $has = {} )
        unless $has;

    $has->{ $name } = $initializer;
    return;
}

sub delete_slot {
    my $self  = $_[0];
    my $name  = $_[1];
    my $stash = $self->stash;
    my $class = $self->name;

    die '[ARGS] You must specify the name of the slot to delete'
        unless $name;

    my $has = MOP::Internal::Util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };

    die "[CONFLICT] Cannot delete a regular slot ($name) when there is an aliased slot already there"
        if MOP::Slot->new(
            name        => $name,
            initializer => $has->{ $name }
        )->origin_stash ne $class;

    delete $has->{ $name };

    return;
}

sub has_slot_alias {
    my $self  = $_[0];
    my $name  = $_[1];
    my $class = $self->name;
    my $has   = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    die '[ARGS] You must specify the name of the slot alias to look for'
        unless $name;

    return unless $has;
    return unless exists $has->{ $name };

    return MOP::Slot->new(
        name        => $name,
        initializer => $has->{ $name }
    )->origin_stash ne $class;
}

sub get_slot_alias {
    my $self  = $_[0];
    my $name  = $_[1];
    my $class = $self->name;
    my $has   = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    die '[ARGS] You must specify the name of the slot alias to get'
        unless $name;

    return unless $has;
    return unless exists $has->{ $name };

    my $slot = MOP::Slot->new(
        name        => $name,
        initializer => $has->{ $name }
    );

    return $slot
        if $slot->origin_stash ne $class;

    return;
}

sub alias_slot {
    my $self        = $_[0];
    my $name        = $_[1];
    my $initializer = $_[2];

    die '[ARGS] You must specify the name of the slot alias to add'
        unless $name;

    die '[ARGS] You must specify an initializer CODE reference to associate with the slot alias'
        unless $initializer && ref $initializer eq 'CODE';

    my $stash = $self->stash;
    my $class = $self->name;
    my $slot  = MOP::Slot->new( name => $name, initializer => $initializer );

    die '[CONFLICT] Slot is from the local class (' . $class . '), it should be from a different class'
        if $slot->origin_stash eq $class;

    my $has = MOP::Internal::Util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    MOP::Internal::Util::SET_GLOB_SLOT( $stash, 'HAS', $has = {} )
        unless $has;

    $has->{ $name } = $initializer;
    return;
}

sub delete_slot_alias {
    my $self  = $_[0];
    my $name  = $_[1];
    my $stash = $self->stash;
    my $class = $self->name;

    die '[ARGS] You must specify the name of the slot alias to delete'
        unless $name;

    my $has = MOP::Internal::Util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };

    die "[CONFLICT] Cannot delete an slot alias ($name) when there is an regular slot already there"
        if MOP::Slot->new(
            name        => $name,
            initializer => $has->{ $name }
        )->origin_stash eq $class;

    delete $has->{ $name };

    return;
}

1;

__END__

=pod

=head1 DESCRIPTION

A role is simply a package which I<may> have methods, I<may> have slot
defintions, and I<may> consume other roles.

=head1 CONSTRUCTORS

=over 4

=item C<new( name => $package_name )>

=item C<new( $package_name )>

=item C<new( \%package_stash )>

=back

=head1 METHODS

=over 4

=item C<stash>

=back

=head2 Identity

=over 4

=item C<name>

=item C<version>

=item C<authority>

=back

=head2 Role Relationships

=over 4

=item C<roles>

=item C<set_roles( @roles )>

=item C<does_role( $role )>

=back

=head2 Slots

=over 4

=item C<all_slots>

=item C<slots>

=item C<has_slot( $name )>

=item C<get_slot( $name )>

=item C<add_slot( $name, &$initializer )>

=item C<delete_slot( $name )>

=item C<aliased_slots>

=item C<alias_slot( $name, &$initializer )>

=item C<has_slot_alias ( $name )>

=item C<get_slot_alias ( $name )>

=item C<delete_slot_alias ( $name )>

=back

=head2 Required Methods

=over 4

=item C<required_methods>

=item C<requires_method( $name )>

=item C<has_required_method( $name )>

=item C<get_required_method( $name )>

=item C<add_required_method( $name )>

=item C<delete_required_method( $name )>

=back

=head2 Methods

=over 4

=item C<all_methods>

=item C<methods>

=item C<has_method( $name )>

=item C<get_method( $name )>

=item C<add_method( $name, &$code )>

=item C<delete_method( $name )>

=item C<aliased_methods>

=item C<alias_method( $name, &$code )>

=item C<has_method_alias( $name )>

=item C<get_method_alias( $name )>

=item C<delete_method_alias( $name )>

=back

=cut
