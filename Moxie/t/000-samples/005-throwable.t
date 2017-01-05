#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('MOP');
}

BEGIN {
    eval { require Devel::StackTrace; 1 }
        or ($ENV{RELEASE_TESTING}
            ? die
            : plan skip_all => "This test requires Devel::StackTrace");
}

package Throwable {
    use Moxie;

    extends 'MOP::Object';

    has 'message'     => ( is => 'ro', default => sub { '' } );
    has 'stack_trace' => ( is => 'ro', default => sub {
        Devel::StackTrace->new(
            skip_frames  => 1,
            frame_filter => sub {
                $_[0]->{'caller'}->[3] !~ /^MOP\:\:/ &&
                $_[0]->{'caller'}->[0] !~ /^MOP\:\:/
            }
        )
    });

    sub throw     ($self) { die $self }
    sub as_string ($self) { $self->{message} . "\n\n" . $self->{stack_trace}->as_string }
}

my $line = __LINE__;
sub foo { Throwable->new( message => "HELLO" )->throw }
sub bar { foo() }

eval { bar() };
my $e = $@;

ok( $e->isa( 'Throwable' ), '... the exception is a Throwable object' );

is( $e->message, 'HELLO', '... got the exception' );

isa_ok( $e->stack_trace, 'Devel::StackTrace' );

my $file = __FILE__;
$file =~ s/^\.\///;
# for whatever reason, Devel::StackTrace does this internally, which converts
# forward slashes into backslashes on windows
$file = File::Spec->canonpath($file);

my $line1 = $line + 2;
my $line2 = $line + 4;
my $line3 = $line + 4;
like(
    $e->stack_trace->as_string,
    qr[^Trace begun at \Q$file\E line \Q$line1\E
main::bar at \Q$file\E line \Q$line2\E
eval \{\.\.\.\} at \Q$file\E line \Q$line3\E
],
    '... got the exception'
);

done_testing;
