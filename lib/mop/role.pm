package mop::role;

use strict;
use warnings;

use mop::object;
use mop::module;
use mop::method;

use mop::internal::util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA;  BEGIN { @ISA  = 'mop::object' };
our @DOES; BEGIN { @DOES = 'mop::module' }; # to be composed later ...

BEGIN {
    # FIXME:
    # Poor mans role composition, this will suffice 
    # for now, until I have enough infrastructure to 
    # be able to actually do the composition.
    # - SL

    *CREATE             = \&mop::module::CREATE;

    *stash              = \&mop::module::stash;

    *name               = \&mop::module::name;
    *version            = \&mop::module::version;
    *authority          = \&mop::module::authority;

    *is_closed          = \&mop::module::is_closed;
    *set_is_closed      = \&mop::module::set_is_closed;

    *finalizers         = \&mop::module::finalizers;
    *add_finalizer      = \&mop::module::add_finalizer;
    *run_all_finalizers = \&mop::module::run_all_finalizers;
}

# other roles 

sub roles {
    my ($self) = @_;
    my $does = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'DOES', 'ARRAY' );
    return unless $does;
    return @$does;
}

sub set_roles {
    my ($self, @roles) = @_;
    die '[PANIC] Cannot add roles to a package which has been closed'
        if $self->is_closed;
    mop::internal::util::SET_GLOB_SLOT( $self->stash, 'DOES', \@roles );
    return;
}

sub does_role {
    my ($self, $role_to_test) = @_;
    # FIXME:
    # this is very inefficient, we could jump out
    # early from the two `scalar grep` tests and 
    # potentially save some processing.

    # try the simple way first ...
    return 1 if scalar grep { $_ eq $role_to_test } $self->roles;
    # then try the harder way next ...
    return 1 if scalar grep { mop::role->new( name => $_ )->does_role( $role_to_test ) } $self->roles;
    return 0;
}

# abstract-ness

# NOTE:
# ponder removing the required_methods logic from here
# this is something that could be investigated at the 
# class FINALIZATION time and then the IS_ABSTRACT flag
# is set. We need to do this for inheritance anyway, so
# we might as well handle it them, then we can assume 
# that the package is in a consistent state.
#
# see also: "__NOTES__.txt/Do we want to check abstract-ness via required methods?"
#
# - SL

sub is_abstract {
    my ($self) = @_;
    # if you have required methods, you are abstract
    # that is a hard enforced rule here ...
    my $default = scalar $self->required_methods ? 1 : 0;
    # if there is no $IS_ABSTRACT variable, return the 
    # calculated default, but if there is an $IS_ABSTRACT 
    # variable, only allow a true value to override the 
    # calculated default
    my $is_abstract = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'IS_ABSTRACT', 'SCALAR' );
    return $default unless $is_abstract;
    return $$is_abstract ? 1 : $default;
    # this approach should allow someone to create 
    # an abstract class even if they do not have any
    # required methods, but also keep the strict 
    # checking of required methods as a indicator 
    # of abstract-ness    
    
}

sub set_is_abstract {
    my ($self, $value) = @_;
    die '[PANIC] Cannot set a package to be abstract which has been closed'
        if $self->is_closed;    
    mop::internal::util::SET_GLOB_SLOT( $self->stash, 'IS_ABSTRACT', $value ? \1 : \0 );
    return;
}

## Methods

# get them all; regular, aliased & required
sub all_methods {
    my $stash = $_[0]->stash;
    my @methods;
    foreach my $candidate ( keys %$stash ) {
        if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $candidate, 'CODE' ) ) {
            push @methods => mop::method->new( body => $code );
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
        if ( $method->origin_class ne $class ) {
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
    return grep { not($_->is_required) && $_->origin_class ne $class } $self->all_methods
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
# there is no real heavy need to use the mop::method API
# below because 1) it is not needed, and 2) the mop::method
# API is really just an information shim, it does not perform
# much in the way of actions. From my point of view, the below
# operations are mostly stash manipulation functions and so 
# therefore belong here in the continuim of responsibility/
# ownership.
#
## The only argument that could likely be made is for the 
## mop::method API to handle creating the NULL CV for the 
## add_required_method, but that would require us to pass in 
## a mop::method instance, which would be silly since we never
## need it anyway. 
# 
# - SL

sub requires_method {
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    return 0 unless exists $stash->{ $name };
    return mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );
}

sub get_required_method {
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    # check these two easy cases first ...
    return unless exists $stash->{ $name };
    return unless mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } ); 

    # now we grab the CV ...
    my $method = mop::method->new( 
        body => mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) 
    );
    # and make sure it is local, and 
    # then return the method ...
    return $method if $method->origin_class eq $class;
    # or return nothing ...
    return;
}

sub add_required_method {
    my ($self, $name) = @_;
    die "[PANIC] Cannot add a method requirement ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    # if we already have a glob there ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, just return 
        return if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $glob );
        # and if we don't and we have a CODE slot, we 
        # need to die because this doesn't make sense
        die "[PANIC] Cannot add a required method ($name) when there is a regular method already there"
            if defined *{ $glob }{CODE};
    }

    # if we get here, then we
    # just create a null CV
    mop::internal::util::CREATE_NULL_CV( $self->name, $name );
    
    return;
}

sub delete_required_method {
    my ($self, $name) = @_;
    die "[PANIC] Cannot delete method requirement ($name) from (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we must delete it
            mop::internal::util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
            return;
        }
        else {
            # and if we have a CV slot, but it doesn't have 
            # a NULL CV in it, then we need to die because 
            # this doesn't make sense
            die "[PANIC] Cannot delete a required method ($name) when there is a regular method already there"
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

    # check these two easy cases first ...
    return 0 unless exists $stash->{ $name };
    return 0 if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV and make sure it is 
    # local, and return accordingly
    if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = mop::method->new( body => $code );
        my @roles  = $self->roles;
        # and make sure it is local, and 
        # then return accordingly
        return $method->origin_class eq $class
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

    # check the easy cases first ...
    return unless exists $stash->{ $name };
    return if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV ...
    if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = mop::method->new( body => $code );
        my @roles  = $self->roles;
        # and make sure it is local, and 
        # then return accordingly
        return $method 
            if $method->origin_class eq $class
            || (@roles && $method->was_aliased_from( @roles ));
    }

    # if there was no CV, return false.
    return;
}

sub add_method {
    my ($self, $name, $code) = @_;
    die "[PANIC] Cannot add a method ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;
    
    mop::internal::util::INSTALL_CV( $self->name, $name, $code, set_subname => 1 );
    return;
}

sub delete_method {
    my ($self, $name) = @_;
    die "[PANIC] Cannot delete method ($name) from (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we need to die because this 
            # shouldn't happen, we should only 
            # delete regular methods.
            die "[PANIC] Cannot delete a regular method ($name) when there is a required method already there";
        }
        else {
            # if we don't have a code slot ...
            return unless defined *{ $glob }{CODE};

            # we need to make sure it is local, and 
            # otherwise, error accordingly 
            my $method = mop::method->new( body => *{ $glob }{CODE} );
            my @roles  = $self->roles;

            # if the method has not come from 
            # the local class, we need to see 
            # if it was added from a role 
            if ($method->origin_class ne $self->name) {

                # if it came from a role, then it is 
                # okay to be deleted, but if it didn't
                # then we have an error cause they are 
                # trying to delete an alias using the 
                # regular method method
                unless ( $method->was_aliased_from( @roles ) ) {
                    die "[PANIC] Cannot delete a regular method ($name) when there is an aliased method already there"
                }
            }

            # but if we have a regular method, then we 
            # can just delete the CV from the glob
            mop::internal::util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
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

    # check the easy cases first ...
    return unless exists $stash->{ $name };
    return if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV ...
    if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        my $method = mop::method->new( body => $code );
        # and make sure it is not local, and 
        # then return accordingly
        return $method 
            if $method->origin_class ne $class;
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
    die "[PANIC] Cannot add a method alias ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;
    
    mop::internal::util::INSTALL_CV( $self->name, $name, $code, set_subname => 0 );
    return;
}

sub delete_method_alias {
    my ($self, $name) = @_;
    die "[PANIC] Cannot delete method alias ($name) from (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    # check if we have a stash entry for $name ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, ...
        if ( mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $glob ) ) {
            # then we need to die because this 
            # shouldn't happen, we should only 
            # delete regular methods.
            die "[PANIC] Cannot delete an aliased method ($name) when there is a required method already there";
        }
        else {
            # if we don't have a code slot ...
            return unless defined *{ $glob }{CODE};

            # we need to make sure it is local, and 
            # otherwise, error accordingly 
            my $method = mop::method->new( body => *{ $glob }{CODE} );

            die "[PANIC] Cannot delete an aliased method ($name) when there is a regular method already there"
                if $method->origin_class eq $self->name;

            # but if we have a regular method, then we 
            # can just delete the CV from the glob
            mop::internal::util::REMOVE_CV_FROM_GLOB( $self->stash, $name );
        }
    }
    # if there is no stash entry for $name, we do nothing
    return;
}

sub has_method_alias {
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    # check these two easy cases first ...
    return 0 unless exists $stash->{ $name };
    return 0 if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV and make sure it is 
    # local, and return accordingly
    if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        return mop::method->new( body => $code )->origin_class ne $class;
    }

    # if there was no CV, return false.
    return 0;
}

## Attributes

## FIXME:
## The same problem we had methods needs to be fixed with 
## attributes, just checking the origin_class v. class is 
## not enough, we need to check aliasing as well.
## - SL

# get them all; regular & aliased
sub all_attributes {
    my $self = shift;
    my $has = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );
    return unless $has;
    return map { 
        mop::attribute->new( 
            name        => $_, 
            initializer => $has->{ $_ } 
        ) 
    } keys %$has;
}

# just the local attrinites
sub attributes {
    my $self  = shift;
    my $class = $self->name;
    return grep { $_->origin_class eq $class } $self->all_attributes
}

# just the non-local attributes
sub aliased_attributes {
    my $self  = shift;
    my $class = $self->name;
    return grep { $_->origin_class ne $class } $self->all_attributes
}

## regular ...
# method delete_attribute    ($self, $name);

sub has_attribute {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $class = $self->name;
    my $has   = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };
    
    return mop::attribute->new( 
        name        => $name, 
        initializer => $has->{ $name }
    )->origin_class eq $class;
}

sub get_attribute {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $class = $self->name;
    my $has   = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };
    
    my $attribute = mop::attribute->new( 
        name        => $name, 
        initializer => $has->{ $name }
    );

    return $attribute 
        if $attribute->origin_class eq $class;

    return;
}

sub add_attribute {
    my $self        = $_[0]; 
    my $name        = $_[1];    

    die "[PANIC] Cannot add an attribute ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    my $initializer = $_[2];
    my $stash       = $self->stash;
    my $class       = $self->name;
    my $attr        = mop::attribute->new( name => $name, initializer => $initializer );

    die '[PANIC] Attribute is not from local (' . $class . '), it is from (' . $attr->origin_class . ')' 
        if $attr->origin_class ne $class;

    my $has = mop::internal::util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    mop::internal::util::SET_GLOB_SLOT( $stash, 'HAS', $has = {} )
        unless $has;

    $has->{ $name } = $initializer;
    return;
}

sub delete_attribute {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $stash = $self->stash;
    my $class = $self->name;

    die "[PANIC] Cannot delete an attribute ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    my $has = mop::internal::util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    
    return unless $has;
    return unless exists $has->{ $name };

    die "[PANIC] Cannot delete a regular attribute ($name) when there is an aliased attribute already there"
        if mop::attribute->new( 
            name        => $name, 
            initializer => $has->{ $name } 
        )->origin_class ne $class;    

    delete $has->{ $name };

    return;
}

sub has_attribute_alias {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $class = $self->name;
    my $has   = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };
    
    return mop::attribute->new( 
        name        => $name, 
        initializer => $has->{ $name }
    )->origin_class ne $class;
}

sub get_attribute_alias {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $class = $self->name;
    my $has   = mop::internal::util::GET_GLOB_SLOT( $self->stash, 'HAS', 'HASH' );

    return unless $has;
    return unless exists $has->{ $name };
    
    my $attribute = mop::attribute->new( 
        name        => $name, 
        initializer => $has->{ $name }
    );

    return $attribute 
        if $attribute->origin_class ne $class;

    return;
}

sub alias_attribute {
    my $self        = $_[0]; 
    my $name        = $_[1];    

    die "[PANIC] Cannot alias an attribute ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    my $initializer = $_[2];
    my $stash       = $self->stash;
    my $class       = $self->name;
    my $attr        = mop::attribute->new( name => $name, initializer => $initializer );

    die '[PANIC] Attribute is from the local class (' . $class . '), it should be from a different class' 
        if $attr->origin_class eq $class;

    my $has = mop::internal::util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    mop::internal::util::SET_GLOB_SLOT( $stash, 'HAS', $has = {} )
        unless $has;

    $has->{ $name } = $initializer;
    return;
}

sub delete_attribute_alias {
    my $self  = $_[0]; 
    my $name  = $_[1];    
    my $stash = $self->stash;
    my $class = $self->name;

    die "[PANIC] Cannot delete an attribute alias ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;

    my $has = mop::internal::util::GET_GLOB_SLOT( $stash, 'HAS', 'HASH' );
    
    return unless $has;
    return unless exists $has->{ $name };

    die "[PANIC] Cannot delete an attribute alias ($name) when there is an regular attribute already there"
        if mop::attribute->new( 
            name        => $name, 
            initializer => $has->{ $name } 
        )->origin_class eq $class;    

    delete $has->{ $name };

    return;
}

1;

__END__

=pod

=head1 NAME

mop::role - the metaclass for roles

=head1 SYNPOSIS

=head1 DESCRIPTION

=head1 METHODS

This module I<does> the L<mop::module> package, which means
that it also has all the methods from that package as well.

=head2 Role Relationships

=over 4

=item C<roles>

=item C<set_roles( @roles )>

=item C<does_role( $role )>

=back

=head2 Abstractness

=over 4

=item C<is_abstract>

=item C<set_is_abstract( $value )>

=back

=head2 Attributes 

=over 4

=item C<all_attributes>

=item C<attributes>

=item C<has_attribute( $name )>

=item C<get_attribute( $name )>

=item C<add_attribute( $name, &$initializer )>

=item C<delete_attribute( $name )>

=item C<aliased_attributes>

=item C<alias_attribute( $name, &$initializer )>

=item C<has_attribute_alias ( $name )>

=item C<get_attribute_alias ( $name )>

=item C<delete_attribute_alias ( $name )>

=back

=head2 Required Methods

=over 4

=item C<required_methods>

=item C<requires_method( $name )>

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