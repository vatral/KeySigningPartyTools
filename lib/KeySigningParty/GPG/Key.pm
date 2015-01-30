package KeySigningParty::GPG::Key;
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
use Crypt::GPG;
use KeySigningParty::GPG::Key::UID;
use KeySigningParty::GPG::Key::UID::Signature;
use KeySigningParty::Types qw( ShortID LongID Hex );

use version; our $VERSION = qv('0.0.3');

has 'gpgobj'      => ( is => 'rw', isa => 'KeySigningParty::GPG', weak_ref => 1 );

has 'id'          => ( is => 'rw', isa => LongID, trigger => \&_id_changed);
has 'short_id'    => ( is => 'ro', isa => ShortID, writer => '_set_short_id', default => '00000000');
has 'size'        => ( is => 'rw', isa => 'Int', default => 0 );
has 'type'        => ( is => 'rw', isa => 'Str', default => '' );
has 'uids'        => ( is => 'rw', isa => 'ArrayRef[KeySigningParty::GPG::Key::UID]', default => sub { [ ] });
has 'fingerprint' => ( is => 'rw', isa => Hex, default => '' );


sub name {
	my ($self) = @_;
	return $self->uids->[0]->text;
}

sub certified {
	# We are certified if all IDs are, 
	# and there is at least one certified ID.
	my ($self) = @_;
	my $cert_count = 0;
	foreach my $uid ( @{ $self->uids } ) {
		if ( $uid->certified ) {
			$cert_count++;
		} else {
			return 0;
		}
	}

	return ($cert_count > 0);
}

sub find_uid {
	my ($self, $uid_text) = @_;
	foreach my $uid ( @{ $self->uids} ) {
		if ( $uid->text eq $uid_text ) {
			return $uid;
		}
	}

	return undef;
}

sub has_image {
	my ($self) = @_;
	foreach my $uid ( @{ $self->uids} ) {
		return 1 if ( $uid->image );
	}

	return 0;
}

sub export_image {
	my ($self) = @_;
	my $ret;
	my @data = $self->gpgobj->_run_gpg("--photo-viewer=echo PHOTO:\%I", "--list-options", "show-photos", "--list-keys", $self->id);
	chomp @data;

        foreach my $line (@data) {
                chomp $line;
                if ( $line =~ /^PHOTO:(.*)$/ ) {
                        $ret = $1;
                        last;
                }
        }

        return $ret;
}

sub check_fingerprint {
	my ($self, $fingerprint) = @_;

 	$fingerprint =~ s/\s+//g;
 	$fingerprint = uc($fingerprint);

	return ($fingerprint eq $self->fingerprint);
}

sub _load_sigs {
	my ($self) = @_;
#	confess("Not implemented");
	return if ( $self->{sigs_loaded} );

	my @data = $self->gpgobj->_run_gpg("--with-colons", "--list-sigs", $self->id);
	chomp @data;

	my %cache = map { $_->id => $_ } @{$self->uids};
	my %trusted_cache = map { $_ => 1 } @{$self->gpgobj->fully_trusted_keys};

	my $cur_uid_id;
	my $cur_uid;
	my $sigs = [];
	my $certified = 0;

	foreach my $line (@data) {
		my @parts = split(/:/, $line);
		my $type    = $parts[0];
		my $key_uid = $parts[4];
		my $date    = $parts[5];

		if ( $type eq "pub" || $type eq "uid" || $type eq "uat" ) {
			if ( $cur_uid ) {
				$cur_uid->signatures( $sigs );
				$cur_uid->certified($certified);
			}

			if ( $type eq "pub" ) {
				$cur_uid_id = $key_uid;
			} else {
				$cur_uid_id = $parts[7];
			}

			$sigs = [];
			$cur_uid = $cache{$cur_uid_id};
			$certified = 0;
		}

		if ( $type eq "sig" ) {
			my $sig = KeySigningParty::GPG::Key::UID::Signature->new( id => $key_uid, date => $date );

			if ( exists $trusted_cache{$key_uid} ) {
				$certified = 1;
			}

			push @$sigs, $sig;
		}
	}

	if ( $cur_uid ) {
		$cur_uid->signatures($sigs);
		$cur_uid->certified($certified);
	}

	$self->{sigs_loaded} = 1;
#	confess("I am here");
}

sub _id_changed {
	my ($self, $new, $old) = @_;
	$self->_set_short_id( substr($new, -8));
}




1; # Magic true value required at end of module
__END__
i
=head1 NAME

KeySigningParty::GPG::Key - [One line description of module's purpose here]


=head1 VERSION


=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE 


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
