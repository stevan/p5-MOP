package mop::module;

use strict;
use warnings;

use B      ();
use Symbol ();

use mop::util;
use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'mop::object' };

sub CREATE {
    my ($class, $args) = @_;
    my $name = $args->{name} 
        || die "[mop::module::PANIC] You must specify a module name";

    mop::util::CONSTRUCT_INSTANCE(       
        bless_into => $class,        
        generator  => sub {
            no strict 'refs';
            # get a ref to to the stash itself ...
            my $stash = \%{ $name . '::' };
            # and then a ref to that, because we 
            # need to bless it and do not want to 
            # bless the actual stash if we can 
            # avoid it.
            return \$stash
        }
    );
}

# stash

sub stash {
    my ($self) = @_;
    return ${ $self } # returns the direct HASH ref of the stash 
}

# identity 

sub name {
    my ($self) = @_;
    B::svref_2object( $self->stash )->NAME
}

sub version {
    my ($self) = @_;
    ${ *{ $self->stash->{'VERSION'} // return }{SCALAR} // return }
}

sub authority {
    my ($self) = @_;
    ${ *{ $self->stash->{'AUTHORITY'} // return }{SCALAR} // return }
}

# closed-ness

sub is_closed {
    my ($self) = @_;
    ${ *{ $self->stash->{'IS_CLOSED'} // return }{SCALAR} // return }
}

# NOTE:
# It should be possible to re-open the class, so we don't need 
# to guard the set_is_closed method ti check if the class has 
# been closed or not. We might at a later point want to change 
# this and make the re-opening more of a deeper internal thing.
# - SL

sub set_is_closed {
    my ($self, $value) = @_;
    *{ $self->stash->{'IS_CLOSED'} ||= Symbol::gensym() } = $value ? \1 : \0;
}

# finalizers

sub finalizers {
    my ($self) = @_;
    @{ *{ $self->stash->{'FINALIZERS'} // return }{ARRAY} // return }
}

sub add_finalizer {
    my ($self, $finalizer) = @_;
    die "[mop::module::PANIC] Cannot add a finalizer to a module which has been closed"
        if $self->is_closed;
    *{ $self->stash->{'FINALIZERS'} ||= Symbol::gensym() } = [ $self->finalizers, $finalizer ];
}

sub run_all_finalizers {
    my ($self) = @_;
    $_->() foreach $self->finalizers
}

1;

__END__