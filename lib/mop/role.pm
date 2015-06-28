package mop::role;

use strict;
use warnings;

use Symbol ();

use mop::object;
use mop::module;

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
    return @{ *{ $self->stash->{'DOES'} // return }{ARRAY} // return }
}

sub set_roles {
    my ($self, @roles) = @_;
    die '[PANIC] Cannot add roles to a package which has been closed'
        if $self->is_closed;
    *{ $self->stash->{'DOES'} //= Symbol::gensym() } = \@roles;
    return;
}

sub does_role {
    my ($self, $role_to_test) = @_;
    # try the simple way first ...
    return 1 if scalar grep { $_ eq $role_to_test } $self->roles;
    # then try the harder way next ...
    return 1 if scalar grep { mop::role->new( name => $_ )->does_role( $role_to_test ) } $self->roles;
    return 0;
}

# abstract-ness

sub is_abstract {
    my ($self) = @_;
    # if you have required methods, you are abstract
    # that is a hard enforced rule here ...
    my $default = scalar $self->required_methods ? 1 : 0;
    # if there is no $IS_ABSTRACT variable, return the 
    # calculated default, but if there is an $IS_ABSTRACT 
    # variable, only allow a true value to override the 
    # calculated default
    return ${ *{ $self->stash->{'IS_ABSTRACT'} // return $default }{SCALAR} // return $default } ? 1 : $default;
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
    return *{ $self->stash->{'IS_ABSTRACT'} //= Symbol::gensym() } = $value ? \1 : \0;
}

# required methods 

sub required_methods {
    my $stash = $_[0]->stash;

    my @required;
    foreach my $candidate ( keys %$stash ) {
        push @required => $candidate
            if mop::internal::util::DOES_GLOB_HAVE_NULL_CV( 
                $stash->{ $candidate } 
            );
    }
    return @required;
}

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
    if ( my $glob = $self->stash->{$name} ) {
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
    if ( my $glob = $self->stash->{$name} ) {
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

# NOTE:
# maybe add these in, not sure if we actually need them.
#
#   method alias_required_method     ($self, $name);
#   method has_required_method_alias ($self, $name);  
# 
# See the comment in __NOTES__.txt for more info.
# - SL

# attributes

# method attributes          ($self);
# method has_attribute       ($self, $name);
# method get_attribute       ($self, $name);
# method add_attribute       ($self, $name, &$initializer);
# method delete_attribute    ($self, $name);
# # aliasing
# method alias_attribute     ($self, $name, &$initializer);
# method has_attribute_alias ($self, $name);

# regular methods

# method methods          ($self);
# method has_method       ($self, $name);
# method get_method       ($self, $name);
# method add_method       ($self, $name, &$body);
# method delete_method    ($self, $name);
# # aliasing
# method alias_method     ($self, $name, &$body);
# method has_method_alias ($self, $name); 

# ...

1;

__END__

=pod

=head1 NAME

mop::role - the metaclass for roles

=head1 SYNPOSIS

=head1 DESCRIPTION

=cut