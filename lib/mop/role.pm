package mop::role;

use strict;
use warnings;

use Symbol ();

use mop::object;
use mop::module;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA;  BEGIN { @ISA  = 'mop::object' };
our @DOES; BEGIN { @DOES = 'mop::module' }; # to be composed later ...

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

sub required_methods { 0 } # Stub for now

# method required_methods          ($self);
# method has_required_method       ($self, $name);
# method get_required_method       ($self, $name);
# method add_required_method       ($self, $name);
# method delete_required_method    ($self, $name);    
# # aliasing
# method alias_required_method     ($self, $name);
# method has_required_method_alias ($self, $name);  

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

1;

__END__

=pod

=head1 NAME

mop::role - the metaclass for roles

=head1 SYNPOSIS

=head1 DESCRIPTION

=cut