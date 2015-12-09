#!perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('mop');
}

=pod

This totally doesn't use the mop much, but
I thought it was a fun use of given/when

=cut

my (@WARNINGS, @FATALS);
sub my_warn { push @WARNINGS => join "" => @_ }
sub my_die  { push @FATALS   => join "" => @_ }

package Logger {
    use v5.20;
    use Moxie;

    extends 'mop::object';

    sub log ( $self, $level, $msg ) {
        no if $] >= 5.017011, warnings => 'experimental::smartmatch';
        given ( $level ) {
            when ( 'info'  ) { ::my_warn( '[info] ',    $msg ) }
            when ( 'warn'  ) { ::my_warn( '[warning] ', $msg ) }
            when ( 'error' ) { ::my_warn( '[error] ',   $msg ) }
            when ( 'fatal' ) { ::my_die(  '[fatal] ',   $msg ) }
            default {
                die "bad logging level: $level"
            }
        }
    }
}

package MyLogger {
    use v5.20;
    use Moxie;

    extends 'Logger';

    sub log ( $self, $level, $msg ) {
        no if $] >= 5.017011, warnings => 'experimental::smartmatch';
        given ( $level ) {
            when ( 'info'  ) { ::my_warn( '<info> ', $msg ) }
            default {
                $self->next::method( $level, $msg );
            }
        }
    }
}

my $l = MyLogger->new;
$l->log(info => 'hey');
$l->log(warn => 'hey');

is_deeply(
    \@WARNINGS,
    [ '<info> hey', '[warning] hey' ],
    '... got the expected output'
);


done_testing;
