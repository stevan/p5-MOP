package mop::internal::util;

use strict;
use warnings;

use mop::module;

use B                  (); # nasty stuff, all nasty stuff
use Sub::Name          (); # handling some sub stuff
use Symbol             (); # creating the occasional symbol 
use Devel::Hook        (); # need this for accessing the UNITCHECK's AV
use Devel::GlobalPhase (); # need this for checking what global phase we are in

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## ------------------------------------------------------------------
## Basic Glob access
## ------------------------------------------------------------------

sub GET_GLOB_SLOT {
    my ($stash, $name, $slot) = @_;
    # do my best to not autovivify, and 
    # return undef if not
    return unless exists $stash->{ $name };
    # occasionally we need to auto-inflate 
    # the optimized version of a required
    # method, its annoying, but the XS side
    # should not have to care about this so 
    # it can be removed eventually.
    if ( $slot eq 'CODE' && $stash->{ $name } eq "-1" ) {
        B::svref_2object( $stash )->NAME->can( $name );
    }
    # return the reference stored in the glob
    # which might be undef, but that can be 
    # handled by the caller
    return *{ $stash->{ $name } }{ $slot };
}

sub SET_GLOB_SLOT {
    my ($stash, $name, $value_ref) = @_;
    # if the glob doesn't exist, create it
    my $glob = $stash->{ $name } //= Symbol::gensym();
    # then just store the reference in it
    # which should figure out the proper 
    # slot to put thing into without issue
    *{$glob} = $value_ref;
    return;
}

## ------------------------------------------------------------------
## CV/Glob introspection
## ------------------------------------------------------------------

sub DOES_GLOB_HAVE_NULL_CV {    
    my ($glob) = @_;
    # NOTE:
    # If the glob eq -1 that means it may well be a null sub
    # this seems to be some kind of artifact of an optimization 
    # perhaps, I really don't know, it is odd. It should not 
    # need to be dealt with in XS, it seems to be a Perl language
    # level thing.
    # - SL
    return 1 if $glob eq -1;
    # next lets see if we have a CODE slot ...
    if ( my $code = *{ $glob }{CODE} ) {
        # if it is a CV and the ROOT is a NULL op ...
        my $op = B::svref_2object( $code );
        return !! $op->isa('B::CV') && $op->ROOT->isa('B::NULL'); 
    }
    # if we had no CODE slot, it can't be a NULL CV ...
    return 0;
}

sub CREATE_NULL_CV {
    my ($in_pkg, $name) = @_;
    # this just tries to eval the NULL CV into 
    # place, it is ugly, but works for now 
    eval "sub ${in_pkg}::${name}; 1;" or do { die $@ };
    return;
}

sub INSTALL_CV {
    my ($in_pkg, $name, $code, %opts) = @_;

    die "[PANIC] You must specify a boolean value for `set_subname` option"
        if not exists $opts{set_subname};

    no strict 'refs';
    no warnings 'once', 'redefine';

    my $fullname =  $in_pkg.'::'.$name;
    *{$fullname} = $opts{set_subname} ? Sub::Name::subname($fullname, $code) : $code;
}

sub REMOVE_CV_FROM_GLOB {
    my ($stash, $name) = @_;
    # find the glob we are looking for
    # which might not exist, in which 
    # case we do nothing ....
    if ( my $glob = $stash->{ $name } ) {
        # once we find it, extract all the 
        # slots we need, note the missing 
        # CODE slot since we don't need 
        # that in our new glob ... 
        my %to_save;
        foreach my $slot (qw[ SCALAR ARRAY HASH FORMAT IO ]) {
            if ( my $val = *{ $glob }{ $slot } ) {
                $to_save{ $slot } = $val;
            }
        }
        # replace the old glob with a new one ...
        $stash->{ $name } = Symbol::gensym();
        # now go about constructing our new 
        # glob by restoring the other slots
        {
            no strict 'refs';
            no warnings 'once';
            # get the name of the stash, we could have 
            # passed this in, but it is easy to get in 
            # XS, and so we can punt that down the road 
            # for the time being
            my $pkg = B::svref_2object( $stash )->NAME;
            foreach my $type ( keys %to_save ) {
                *{ $pkg . '::' . $name } = $to_save{ $type };
            }
        }
    }
    # ... the end
    return;
}

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




