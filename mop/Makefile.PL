use strict;
use warnings;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    'NAME'               => 'mop',
    'VERSION'            => '0.01',
    'DISTNAME'           => 'mop',
    'ABSTRACT'           => 'Yet Another Mop Prototype',
    'AUTHOR'             => 'Stevan Little',
    'BUILD_REQUIRES'     => {},
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
    },
    'clean'              => { FILES => 'cover_db/ nytprof/' },
    'test'               => { RECURSIVE_TEST_FILES => 1 },
);

WriteMakefile(%WriteMakefileArgs);
