package mop::role;

use strict;
use warnings;

use Symbol ();

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
    my $does = mop::internal::util::GET_GLOB_SLOT( $$self, 'DOES', 'ARRAY' );
    return unless $does;
    return @$does;
}

sub set_roles {
    my ($self, @roles) = @_;
    die '[PANIC] Cannot add roles to a package which has been closed'
        if $self->is_closed;
    mop::internal::util::SET_GLOB_SLOT( $$self, 'DOES', \@roles );
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
    return grep { not($_->is_required) && $_->origin_class eq $class } $self->all_methods
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
    my $self  = shift;
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

sub add_required_method {
    my ($self, $name) = @_;
    die "[PANIC] Cannot add a method requirement ($name) to (" . $self->name . ") because it has been closed"
        if $self->is_closed;
    # check if we have a glob already ...
    if ( my $glob = $self->stash->{ $name } ) {
        # and if we have a NULL CV in it, just return 
        return if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $glob );
        # and if we don't and have a CODE slot, we 
        # need to die because this doesn't make sense
        die "[PANIC] Cannot add a required method ($name) when there is a regular method already there"
            if defined *{ $glob }{CODE};
    }
    # if we don't have a stash entry, 
    # then just create one 
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
    my $class = $_[0]->name;
    my $stash = $_[0]->stash;
    my $name  = $_[1];

    # check these two easy cases first ...
    return 0 unless exists $stash->{ $name };
    return 0 if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( $stash->{ $name } );

    # now we grab the CV and make sure it is 
    # local, and return accordingly
    if ( my $code = mop::internal::util::GET_GLOB_SLOT( $stash, $name, 'CODE' ) ) {
        return mop::method->new( body => $code )->origin_class eq $class;
    }

    # if there was no CV, return false.
    return 0;
}


# method get_method       ($self, $name);
# method add_method       ($self, $name, &$body);
# method delete_method    ($self, $name);

# aliased methods

# method alias_method     ($self, $name, &$body);

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


# attributes

# method attributes          ($self);
# method has_attribute       ($self, $name);
# method get_attribute       ($self, $name);
# method add_attribute       ($self, $name, &$initializer);
# method delete_attribute    ($self, $name);
# # aliasing
# method alias_attribute     ($self, $name, &$initializer);
# method has_attribute_alias ($self, $name);

# ...

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

=head2 Required Methods

=over 4

=item C<required_methods>

=item C<requires_method( $name )>

=item C<add_required_method( $name )>

=item C<delete_required_method( $name )>

=back

=head2 Attributes 

=over 4

=item C<attributes>

=item C<has_attribute( $name )>

=item C<get_attribute( $name )>

=item C<add_attribute( $name, &$initializer )>

=item C<delete_attribute( $name )>

=item C<alias_attribute( $name, &$initializer )>

=item C<has_attribute_alias ( $name )>

=back

=head2 Methods

=over 4

=item C<methods>

=item C<has_method( $name )>

=item C<get_method( $name )>

=item C<add_method( $name, &$body )>

=item C<delete_method( $name )>

=item C<alias_method( $name, &$body )>

=item C<has_method_alias( $name )>

=back

=cut