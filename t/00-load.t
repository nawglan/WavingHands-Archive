#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WavingHands::Archive' );
}

diag( "Testing WavingHands::Archive $WavingHands::Archive::VERSION, Perl $], $^X" );
