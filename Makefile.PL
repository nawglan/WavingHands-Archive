use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WavingHands::Archive',
    AUTHOR              => 'Desmond Daignault <nawglan@gmail.com>',
    VERSION_FROM        => 'lib/WavingHands/Archive.pm',
    ABSTRACT_FROM       => 'lib/WavingHands/Archive.pm',
    PERL_MALLOC_OK      => 1,
    PL_FILES            => {},
    PREREQ_FATAL        => 1,
    PREREQ_PM => {
        'File::Path' => 0,
        'File::Spec' => 0,
        'Cwd' => 0,
        'Carp' => 0,
        'mop' => 0,
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
    },
    META_ADD            => {
        no_index => {
            directory => [qw( t/data )],
        },
    },
    META_MERGE          => {
        "meta-spec" => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/nawglan/WavingHands-Archive.git',
                web => 'https://github.com/nawglan/WavingHands-Archive',
            },
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WavingHands::Archive-*' },
);
