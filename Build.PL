use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'KeySigningParty',
    license             => 'gpl',
    dist_author         => 'Vadim Troshchinskiy <me@vadim.ws>',
    dist_version_from   => 'lib/KeySigningParty.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'KeySigningParty-*' ],
);

$builder->create_build_script();
