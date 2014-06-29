#!perl -T

use Test::More tests => 6;
use File::Spec;

BEGIN {
  use_ok('WavingHands::Archive');
}

is(-f File::Spec->catfile('.', 't', 'data', 'test_full.config') || 0, 1, 'Config file exists (full).');

my $archive3 = new_ok('WavingHands::Archive' => [
    config => File::Spec->catfile('.', 't', 'data', 'test_full.config')
]);

is ($archive3->config, File::Spec->catfile('.', 't', 'data', 'test_full.config'), 'Config file is correct (full).');

is($archive3->initialize(), 1, 'Archive initialized (full).');

is($archive3->destroy(1), 1, 'Archive destroyed including basedir.');
