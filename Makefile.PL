## ----------------------------------------------
## NOTE:
## ----------------------------------------------
## This is just a temp version for now so that I 
## can get some Devel::Cover stats on the test 
## suite, it will need to include the deps in the 
## cpanfile as well as handle any C/XS stuff. For 
## now it is best to just punt on doing anything
## useful in here.
## - SL
## ----------------------------------------------

use strict;
use warnings;
use ExtUtils::MakeMaker 6.30;

my %WriteMakefileArgs = (
    'NAME'               => 'mop',
    'VERSION'            => '0.01',    
    'DISTNAME'           => 'mop',      
    'ABSTRACT'           => ' Yet Another Mop Prototype',
    'AUTHOR'             => 'Stevan Little',
    'BUILD_REQUIRES'     => {},
    'CONFIGURE_REQUIRES' => {
#        'Devel::CallParser' => '0',
        'ExtUtils::MakeMaker' => '6.30'
    },
#    'INC'                => '-Isrc/c',
    'EXE_FILES'          => [],
    'LICENSE'            => 'perl',
    'NORECURS'           => 1,
    'PREREQ_PM'  => {
        # core ....
        'B'                  => 0, 
        'Symbol'             => 0,
        'Scalar::Util'       => 0,
        
        # things to be replaced 
        # by XS at some point
        'Devel::Hook'        => 0, # needed to access the UNITCHECK AV
        'Devel::GlobalPhase' => 0, # needed to access global phase
        'Sub::Name'          => 0, # needed to set names to anon subs

        # tests ..
        'Test::More'         => 0,
        'Test::Fatal'        => 0,        

        # gonna need these later ...
#        'Devel::CallParser' => '0',
#        'XSLoader'          => '0',
    },
    'clean'              => { FILES => 'cover_db/' }, # callparser1.h' },
    'test'               => { RECURSIVE_TEST_FILES => 1 },
);

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

#use File::Spec::Functions 'abs2rel';
#use Devel::CallParser 'callparser1_h', 'callparser_linkable';
#open my $fh, '>', 'callparser1.h' or die "Couldn't write to callparser1.h";
#$fh->print(callparser1_h);
#my @linkable = map { abs2rel($_) } callparser_linkable;
#unshift @linkable, '$(BASEEXT)$(OBJ_EXT)' if @linkable;
#$WriteMakefileArgs{OBJECT} = join(' ', @linkable) if @linkable;

WriteMakefile(%WriteMakefileArgs);
