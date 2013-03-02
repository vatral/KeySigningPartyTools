use Test::More tests => 7;

BEGIN {
use_ok( 'KeySigningParty' );
use_ok( 'KeySigningParty' );
use_ok( 'KeySigningParty::KeyList' );
use_ok( 'KeySigningParty::KeyList::FOSDEM' );
use_ok( 'KeySigningParty::VisualHash' );
use_ok( 'KeySigningParty::VisualHash::Vash' );
use_ok( 'KeySigningParty::VisualHash::QR' );
}

diag( "Testing KeySigningParty $KeySigningParty::VERSION" );
