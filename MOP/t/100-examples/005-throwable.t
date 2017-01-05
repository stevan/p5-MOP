#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    eval { require Devel::StackTrace; 1 }
        or ($ENV{RELEASE_TESTING}
            ? die
            : plan skip_all => "This test requires Devel::StackTrace");
    use_ok('MOP');
}

{
    package Throwable;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('MOP::Object') }
    our %HAS; BEGIN {
        %HAS = (
            message     => sub { '' },
            stack_trace => sub {
                Devel::StackTrace->new(
                    skip_frames  => 1,
                    frame_filter => sub {
                        $_[0]->{'caller'}->[3] !~ /^(MOP|UNIVERSAL)\:\:/ &&
                        $_[0]->{'caller'}->[0] !~ /^(MOP|UNIVERSAL)\:\:/
                    }
                )
            }
        )
    }

    sub message     { $_[0]->{message}     }
    sub stack_trace { $_[0]->{stack_trace} }

    sub throw     { die $_[0] }
    sub as_string { $_[0]->{message} . "\n\n" . $_[0]->{stack_trace}->as_string }
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
