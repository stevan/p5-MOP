## ------------------------------------------------------------------
## NOTE:
## ------------------------------------------------------------------
## The end goal is to remove all dependencies, which 
## we can do when we port this to C/XS, but for now 
## we can use stuff from CPAN to get what we need.
## 
## Anything added here should include a comment about 
## how it will ultimately be removed and what it will 
## be replaced with.
##
## - SL
## ------------------------------------------------------------------

## ------------------------------------------------------------------
## Core modules
## ------------------------------------------------------------------

# ... these can all be replaced by XS

requires 'B'            => 0; 
requires 'Symbol'       => 0;
requires 'Scalar::Util' => 0;

## ------------------------------------------------------------------
## mop::internal:: modules
## ------------------------------------------------------------------

# ... these can also be replaced by XS, but maybe a little tricker
# to accomplish this goal

requires 'Devel::Hook'        => 0; # needed to access the UNITCHECK AV
requires 'Devel::GlobalPhase' => 0; # needed to access global phase

## ------------------------------------------------------------------
## Test modules
## ------------------------------------------------------------------

# ... these will not get replaced, except maybe Test::Fatal, but 
# we can wait on that for now.

requires 'Test::More'  => 0;
requires 'Test::Fatal' => 0;

## ------------------------------------------------------------------