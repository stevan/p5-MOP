
use v5.20;
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
#    'PREREQ_PM'  => {
#        'Devel::CallParser' => '0',
#        'XSLoader'          => '0',
#    },
#    'clean'              => { 'FILES' => 'callparser1.h' },
    'test'               => { 'TESTS' => 't/*.t t/*/*.t' },
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
