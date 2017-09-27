package MOP::Slot::Initializer;
# ABSTRACT: A representation of a class slot initializer

use strict;
use warnings;

use Carp ();

use UNIVERSAL::Object;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

use overload '&{}' => 'to_code', fallback => 1;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        meta     => sub { die 'A class/role `meta` instance is required' },
        name     => sub { die 'A slot `name` is required' },
        # ...
        default  => sub {},
        required => sub {},
        builder  => sub {},
        # private ...
        _initializer => sub {},
    )
}

sub BUILD {
    my ($self, $params) = @_;
    ## TODO:
    ## - add consistency checking (no default + required, etc)
    ## - add type checking/coercion as needed
}

sub to_code {
    my ($self) = @_;

    # short curcuit the optimal case ...
    return $self->{_initializer} if $self->{_initializer};

    my $meta = $self->{meta};
    my $name = $self->{name};

    ## FIXME:
    ## The eval-into-package thing below is not great
    ## and can likely be done in a much better way.
    ## - SL

    #warn sprintf "Generating initializer for slot(%s) in class(%s)", $name, $meta->name;

    if ( my $method = $self->{builder} ) {
        return $self->{_initializer} ||= eval 'package '.$meta->name.'; sub { (shift)->'.$method.'( @_ ) }';
    }
    elsif ( $self->{required} ) {
        return $self->{_initializer} ||= eval 'package '.$meta->name.'; sub { die "A `'.$name.'` value is required" }';
    }
    elsif ( $self->{default} ) {
        return $self->{_initializer} ||= $self->{default};
    }
    else {
        return $self->{_initializer} ||= eval 'package '.$meta->name.'; sub { undef }';
    }
}

1;

__END__

=pod

=head1 DESCRIPTION

Slots in the MOP World (sung to the tune of "Spirits in the
Material World" by the Police), more details later ...

=head1 CONSTRUCTORS

=over 4

=item C<new( name => $name, initializer => $initializer )>

=item C<new( $name, $initializer )>

=back

=head1 METHODS

=over 4

=item C<name>

=item C<initializer>

=item C<origin_stash>

=item C<was_aliased_from>

=back

=cut
