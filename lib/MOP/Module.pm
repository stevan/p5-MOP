package MOP::Module;

use strict;
use warnings;

use MOP::Object;
use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'MOP::Object' };

our $IS_CLOSED; UNITCHECK { $IS_CLOSED = 1 }

sub CREATE {
    my ($class, $args) = @_;
    my $name = $args->{name}
        || die '[ARGS] You must specify a package name';
    my $stash;
    {
        # get a ref to to the stash itself ...
        no strict 'refs';
        $stash = \%{ $name . '::' };
    }
    # and then a ref to that, because we
    # need to bless it and do not want to
    # bless the actual stash if we can
    # avoid it.
    return bless \$stash => $class;
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

# exports

sub export {
    my ($self) = @_;
    my $export = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'EXPORT', 'ARRAY' );
    return unless $export;
    return @$export;
}

sub export_ok {
    my ($self) = @_;
    my $export_ok = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'EXPORT_OK', 'ARRAY' );
    return unless $export_ok;
    return @$export_ok;
}

sub export_tags {
    my ($self) = @_;
    my $export_tags = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'EXPORT_TAGS', 'HASH' );
    return unless $export_tags;
    return %$export_tags;
}

# closed-ness

sub is_closed {
    my ($self) = @_;
    my $is_closed = MOP::Internal::Util::GET_GLOB_SLOT( $self->stash, 'IS_CLOSED', 'SCALAR' );
    return unless $is_closed;
    return $$is_closed;
}

# NOTE:
# It should be possible to re-open the class, so we don't need
# to guard the set_is_closed method ti check if the class has
# been closed or not. We might at a later point want to change
# this and make the re-opening more of a deeper internal thing.
# - SL

sub set_is_closed {
    my ($self, $value) = @_;
    die '[ARGS] You must specify a value to set'
        unless defined $value;
    MOP::Internal::Util::SET_GLOB_SLOT( $self->stash, 'IS_CLOSED', $value ? \1 : \0 );
    return;
}

1;

__END__

=pod

=head1 NAME

MOP::Module - a more structured `package`

=head1 SYNOPSIS

    my $module = MOP::Module->new( name => 'Foo' );

    warn 'Module (' . $module->name . ') has been closed'
        if $module->is_closed;

    UNITCHECK { $module->run_all_finalizers }

=head1 DESCRIPTION

The idea of a module is really just a formalized convention for
using packages. It provides ways to access information (name,
version, authority and exports) as well as adds two concepts.

=over 4

=item C<$VERSION>

=item C<$AUTHORITY>

=item C<@EXPORT>

=item C<@EXPORT_OK>

=item C<%EXPORT_TAGS>

=back

=head2 Closing a module

When a module is closed, it should no longer be altered, this
being Perl we only guarantee this through our own API.

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

=cut


