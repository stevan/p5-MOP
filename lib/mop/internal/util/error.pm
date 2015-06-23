package mop::internal::util::error;

use strict;
use warnings;

use mop::object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our (@ISA, %HAS); 

BEGIN { 
    @ISA = 'mop::object'; 
    %HAS = (
        type => sub { 'ERROR' },
        msg  => sub { die '[PANIC] `msg` is required'}
    );
}

sub BUILDARGS {
    my $self = shift; 
    return scalar @_ == 2 
        ? { type => $_[0], msg => $_[1] } 
        : $self->next::method( @_ );
}

sub CREATE {
    my ($class, $proto) = @_;
    foreach my $attr ( keys %HAS ) {
        $proto->{ $attr } = $HAS{ $attr }->()
            if not exists $proto->{ $attr };
    }
    $self->next::method( $proto );
}

sub type { $_[0]->{type} }
sub msg  { $_[0]->{msg}  }

1;

__END__

=pod

=head1 NAME

mop::internal::util::error - internal base error class

=head1 SYNOPSIS

    eval { 
        # ... code
        
        mop::internal::util::THROW( PANIC => 'OH NOES!!!' );
        
        # ... OR
        die mop::internal::util::error->new( PANIC => 'OH NOES!!!' );
        
        # ... OR
        die mop::internal::util::error->new( 
            type => 'PANIC', 
            msg  => 'OH NOES!!!' 
        );

        # ... code 
        1;
    } or do {
        my $e = mop::internal::util::CATCH( $@ );  
        say "Got " . $e->type . " Error: " . $e->msg;
    };

=head1 DESCRIPTION

=cut