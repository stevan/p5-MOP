package mop::internal::util;

use strict;
use warnings;

use mop::module;

use Devel::Hook        (); # need this for accessing the UNITCHECK's AV
use Devel::GlobalPhase (); # need this for checking what global phase we are in

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## Class finalization 
## ------------------------------------------------------------------

# NOTE:
# This feature is here simply because we need
# to run the FINALIZE blocks in FIFO order
# and the raw UNITCHECK blocks run in LIFO order
# which can present issues when more then one 
# class/role is in a single compiliation unit
# and the later class/role depends on a former
# class/role to have been finalized.
#
# It is important to note that UNITCHECK, while
# compilation unit specific, is *not* package 
# specific, so we need to manage the per-package
# stuff on our own (see mop::module)
#
# - SL

sub INSTALL_FINALIZATION_RUNNER {
    my $GLOBAL_PHASE = Devel::GlobalPhase::global_phase();
    my $pkg          = shift;
    # NOTE:
    # this check is imperfect, ideally things 
    # will always happen completely at compile 
    # time, for which the ${^GLOBAL_PHASE} check
    # is correct, but this does not work for 
    # code created with eval STRING, in this case ...
    die "[PANIC] To late to install finalization runner for <$pkg>, current-phase: ($GLOBAL_PHASE)" 
        unless $GLOBAL_PHASE eq 'START' 
            # we check the caller, and climb
            # far enough up the stack to work 
            # reasonably correctly for our common
            # use cases (at least the ones we have
            # right now). That said, it is fragile
            # at best and will break if you aren't 
            # that number of stack frames away from 
            # an eval STRING;
            || (caller(3))[3] eq '(eval)';

    push @{ Devel::Hook::_get_unitcheck_array() } => (
        sub { mop::module->new( name => $pkg )->run_all_finalizers }
    );
}

## ------------------------------------------------------------------

1;

__END__




