#!perl -T

use Test::More tests => 37;

use File::Spec;

BEGIN {
  use_ok('WavingHands::Archive');
}

my $archive = new_ok('WavingHands::Archive');

#isa_ok($archive, 'WavingHands::Archive');

is($archive->initialize(
    name => 'test_archive',
    basedir => File::Spec->catdir('.', 't', 'data')
), 1,'Archive initialized.');

# confirm that the archive is initialized correctly
is(-d File::Spec->catdir('.', 't', 'data') || 0, 1,
    'Base directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive') || 0, 1,
    'Archive directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'games') || 0, 1,
    'Games directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'error') || 0, 1,
    'Error directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'logs') || 0, 1,
    'Logs directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'data') || 0, 1,
    'Data directory exists.');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'input') || 0, 1,
    'Input directory exists.');

is($archive->destroy(), 1, 'Archive destroyed (keeping basedir).');
is(-d File::Spec->catdir('.', 't', 'data') || 0, 1,
    'Base directory does exist.');
# ensure that no directory artifacts remain
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive') || 0, 0,
    'Archive directory does not exist.');

is(-f File::Spec->catfile('.', 't', 'data', 'test.config') || 0, 1, 'Config file exists (minimal).');

my $archive2 = new_ok('WavingHands::Archive' => [
    config => File::Spec->catfile('.', 't', 'data', 'test.config')
]);

#isa_ok($archive2, 'WavingHands::Archive');
is ($archive2->config, File::Spec->catfile('.', 't', 'data', 'test.config'), 'Config file is correct (minimal).');

is($archive2->initialize(), 1, 'Archive initialized (minimal).');

# confirm that the archive is initialized correctly
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive') || 0, 1,
    'Base directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name') || 0, 1,
    'Archive directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name', 'games') || 0, 1,
    'Games directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name', 'error') || 0, 1,
    'Error directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name', 'logs') || 0, 1,
    'Logs directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name', 'data') || 0, 1,
    'Data directory exists (minimal).');
is(-d File::Spec->catdir('.', 't', 'data', 'test_archive', 'test_name', 'input') || 0, 1,
    'Input directory exists (minimal).');

is($archive2->destroy(1), 1, 'Archive destroyed including basedir.');

is(-d File::Spec->catdir('.', 't', 'data', 'test_archive') || 0, 0,
    'Base directory does not exist (minimal).');

is(-f File::Spec->catfile('.', 't', 'data', 'test_full.config') || 0, 1, 'Config file exists (full).');

my $archive3 = new_ok('WavingHands::Archive' => [
    config => File::Spec->catfile('.', 't', 'data', 'test_full.config')
]);

#isa_ok($archive3, 'WavingHands::Archive');
is ($archive3->config, File::Spec->catfile('.', 't', 'data', 'test_full.config'), 'Config file is correct (full).');

is($archive3->initialize(), 1, 'Archive initialized (full).');

# confirm that the archive is initialized correctly
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive') || 0, 1,
    'Base directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name') || 0, 1,
    'Archive directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name', 'my_games') || 0, 1,
    'Games directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name', 'my_errors') || 0, 1,
    'Error directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name', 'my_logs') || 0, 1,
    'Logs directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name', 'my_data') || 0, 1,
    'Data directory exists (full).');
is(-d File::Spec->catdir('.', 't', 'data', 'my_archive', 'my_name', 'my_input') || 0, 1,
    'Input directory exists (full).');

# Not destroying this archive.  It will be used by remaining tests.
