package KeySigningParty::GPG;
# Key signing party list generator
# Copyright (C) 2013 Vadim Troshchinskiy <me@vadim.ws>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#   
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use warnings;
use strict;
use Carp;
use Moose;

use version; our $VERSION = qv('0.0.3');
has 'gpg_binary' => ( is => 'rw', isa => 'Str', default => '/usr/bin/gpg' );
has 'keys'       => ( is => 'rw', isa => 'ArrayRef[Str]', builder => '_build_keys', lazy => 1 );
has 'keys_hash'  => ( is => 'rw', isa => 'HashRef[Str]', builder => '_build_keys_hash', lazy => 1);


sub check_fingerprint {
	my ($self, $uid, $fingerprint) = @_;
	my @data = $self->_run_gpg( "--with-colons", "--fingerprint", $uid );
	$fingerprint =~ s/\s+//g;
	$fingerprint = uc($fingerprint);


	if ( !$self->key_exists( $uid ) ) {
		die "Key $uid doesn't exist";
	}

	foreach my $line (@data) {
		my @fields = split(/:/, $line);
		my $type = $fields[0];
		my $fp   = $fields[9];

		if ( $type eq "fpr" && $fp eq $fingerprint ) {
			return 1;
		}
	}

	return;
}


sub key_exists {
	my ($self, $uid) = @_;
	carp "Bad key format: '$uid'" unless ($uid =~ /^[0-9A-F]{16}$/i);
	return exists $self->keys_hash->{$uid};
}

sub get_key_list {
	my ($self) = @_;
	my @data = $self->_run_gpg("--with-colons", "--list-keys");

	my @uids;

	foreach my $line (@data) {

		my @fields = split(/:/, $line);
		my $type = $fields[0];
		my $uid  = $fields[4];

		if ( $type eq "pub" ) {
			die "Bad format for key: '$uid'" unless ($uid =~ /^[0-9A-F]{16}$/i);
			push @uids, $uid;
		}
	}

	return @uids;
}

sub _build_keys {
	my ($self) = @_;
	my @list = $self->get_key_list;
	return \@list;
}

sub _build_keys_hash {
	my ($self) = @_;
	my %ret = map { $_ => 1 } @{$self->keys};
	return \%ret;
}

sub _run_gpg {
	my ($self, @args) = @_;

	open(my $gpg, '-|', $self->gpg_binary, @args) or die "Can't run " . $self->gpg_binary . ": $!";
	my @data = <$gpg>;
	close $gpg;

	chomp @data;
	return @data;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

KeySigningParty::GPG - [One line description of module's purpose here]


=head1 VERSION

This document describes KeySigningParty::GPG version 0.0.1


=head1 SYNOPSIS

    use KeySigningParty::GPG;

    if ( $gpg->key_exists('171CAA4A') ) {
        print "Key exists\n";
        if ( $gpg->check_fingerprint('171CAA4A', '539376F6EAB26F4C4A277365BC2914B4171CAA4A' ) {
            print "Fingerprint ok\n";
        }
    }

=head1 DESCRIPTION

    Auxiliary module for dealing with GPG fingerprint checks, since Crypt::GPG doesn't do it.

=head1 INTERFACE 


=head2 key_exists($key)

Returns a true value if the indicated key exists

=head2 check_fingerprint($key, $fp)

Returns a true value if the indicated key has a matching fingerprint.

Dies if the key doesn't exists. You can call key_exists first to avoid that.

=head2 get_key_list

Returns a list of long GPG uids in the default keyrings.

=head1 DIAGNOSTICS

Dies with "Key $uid doesn't exist" if a nonexistent key is passed as an argument.

=head1 CONFIGURATION AND ENVIRONMENT

KeySigningParty::GPG requires no configuration files or environment variables.


=head1 DEPENDENCIES


Moose

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-keysigningparty-keylist@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Vadim Troshchinskiy  C<< <me@vadim.ws> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, Vadim Troshchinskiy C<< <me@vadim.ws> >>. All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
  
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
