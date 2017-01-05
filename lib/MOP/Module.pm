package MOP::Module;

use strict;
use warnings;

use MOP::Object;
use MOP::Internal::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'MOP::Object' };

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

1;

__END__

=pod

=head1 NAME

MOP::Module - a more structured `package`

=head1 SYNOPSIS

    my $module = MOP::Module->new( name => 'Foo' );

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

=cut


