package mop::module;

use strict;
use warnings;

use B      ();
use Symbol ();

use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'mop::object' };

sub CREATE {
    my ($class, $args) = @_;
    my $name = $args->{name} 
        || die '[MISSING_ARG] You must specify a package name';
    {
        no strict 'refs';
        # get a ref to to the stash itself ...
        my $stash = \%{ $name . '::' };
        # and then a ref to that, because we 
        # need to bless it and do not want to 
        # bless the actual stash if we can 
        # avoid it.
        return bless \$stash => $class;
    }
}

# stash

sub stash {
    my ($self) = @_;
    return $$self; # returns the direct HASH ref of the stash 
}

# identity 

sub name {
    my ($self) = @_;
    return B::svref_2object( $$self )->NAME
}

sub version {
    my ($self) = @_;
    return ${ *{ $$self->{'VERSION'} // return }{SCALAR} // return }
}

sub authority {
    my ($self) = @_;
    return ${ *{ $$self->{'AUTHORITY'} // return }{SCALAR} // return }
}

# closed-ness

sub is_closed {
    my ($self) = @_;
    return ${ *{ $$self->{'IS_CLOSED'} // return }{SCALAR} // return }
}

# NOTE:
# It should be possible to re-open the class, so we don't need 
# to guard the set_is_closed method ti check if the class has 
# been closed or not. We might at a later point want to change 
# this and make the re-opening more of a deeper internal thing.
# - SL

sub set_is_closed {
    my ($self, $value) = @_;
    return *{ $$self->{'IS_CLOSED'} //= Symbol::gensym() } = $value ? \1 : \0;
}

# finalizers

sub finalizers {
    my ($self) = @_;
    return @{ *{ $$self->{'FINALIZERS'} // return }{ARRAY} // return }
}

sub add_finalizer {
    my ($self, $finalizer) = @_;
    die '[PANIC] Cannot add a finalizer to a package which has been closed'
        if $self->is_closed;
    *{ $$self->{'FINALIZERS'} //= Symbol::gensym() } = [ $self->finalizers, $finalizer ];
    return;
}

sub run_all_finalizers {
    my ($self) = @_;
    $_->() foreach $self->finalizers;
    return;
}

1;

__END__

=pod

=head1 NAME

mop::module - a more structured `package`

=head1 SYNOPSIS

    my $module = mop::module->new( name => 'Foo' );

    warn 'Module (' . $module->name . ') has been closed'
        if $module->is_closed;

    $module->add_finalizer(sub { ... });

    UNITCHECK { $module->run_all_finalizers }

=head1 DESCRIPTION

The idea of a module is really just a formalized convention for 
using packages. It provides ways to access information (name, 
version, authority) as well  as adds two concepts.

=head2 Closing a module

When a module is closed, it should no longer be altered, this 
being Perl we only guarantee this through our own API.

=head2 Finalization hooks

These are simply callbacks that are associated with a module and 
are expected to be called at UNITCHECK time. The callbacks are 
run in FIFO order, but no attempt is made by the mop to govern 
the module loading order. 

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

=head2 Closing

=over 4

=item C<is_closed>

=item C<set_is_closed( $value )>

=back

=head2 Finalization

=over 4

=item C<finalizers>

=item C<add_finalizer( &$finalizer )>

=item C<run_all_finalizers>

=back

=cut


