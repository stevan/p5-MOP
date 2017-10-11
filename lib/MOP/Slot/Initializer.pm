package MOP::Slot::Initializer;
# ABSTRACT: A representation of a class slot initializer

use strict;
use warnings;

use Carp ();

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

use overload '&{}' => 'to_code', fallback => 1;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        default      => sub {},
        required     => sub {},
        builder      => sub {},
        # ... private
        _initializer => sub {},
    )
}

sub BUILD {
    my ($self, $params) = @_;
    ## TODO:
    ## - add consistency checking (no default + required, etc)
    $self->{_initializer} = $self->_generate_initializer( $params->{in_package} );
}

# meta info ...

sub has_default { !! $_[0]->{default}  }
sub is_required { !! $_[0]->{reguired} }
sub is_builder  { !! $_[0]->{builder}  }

sub default  { $_[0]->{default}  }
sub required { $_[0]->{reguired} }
sub builder  { $_[0]->{builder}  }

# coerce to CODE ref ...

sub to_code { $_[0]->{_initializer} }

## ...

sub _generate_initializer {
    my ($self, $is_pkg) = @_;

    my $code;
    if ( my $method = $self->{builder} ) {
        $code = eval 'sub { (shift)->'.$method.'( @_ ) }';
    }
    elsif ( my $message = $self->{required} ) {
        $code = eval 'sub { die \''.$message.'\' }';
    }
    elsif ( $self->{default} ) {
        $code = $self->{default};
    }
    else {
        $code = eval 'sub { undef }';
    }

    MOP::Internal::Util::SET_COMP_STASH_FOR_CV( $code, $is_pkg )if $is_pkg;

    return $code;
}

1;

__END__

=pod

=head1 DESCRIPTION

Initializer objects for the MOP

=head1 CONSTRUCTORS

=over 4

=item C<new( %args )>

=back

=head1 METHODS

=over 4

=item C<to_code>

=back

=cut
