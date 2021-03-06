package KeySigningParty::KeyList::FOSDEM;
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
use Moose;
use Carp;

use version; our $VERSION = qv('0.0.3');
use KeySigningParty::KeyList::FOSDEM::Entry;
use Fcntl qw(:seek);

extends 'KeySigningParty::KeyList';



# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;


# Module implementation here
sub load {
	my ($self, $filename) = @_;
	
	open(my $fh, "<:encoding(UTF-8)", $filename) or die "Can't read $filename: $!";
	
	my $entry = new KeySigningParty::KeyList::FOSDEM::Entry();
	my $data = "";	
	my $html;
	my $keys_in_file = 0;
	my $keys_in_keyring = 0;
	my %keys_found;

	seek($fh, 0, SEEK_END);
	my $file_length = tell($fh);
	seek($fh, 0, SEEK_SET);

	$self->starting_hook->($self) if ($self->starting_hook);

	while(my $line = <$fh>) {
		$data .= $line;
		chomp $line;
		$html=1 if ( $line =~ /<html>/ );

		if ( $html ) {
			$line =~ s/&gt;/>/g;
			$line =~ s/&lt;/</g;
		}
	
		if ( $line =~ /^-----/ ) {
			if ( $entry->is_complete ) {
				push @{$self->entries}, $entry;
			}
			
			$entry = new KeySigningParty::KeyList::FOSDEM::Entry();
		} elsif ( $line =~ /^(\d+)\s+\[/ ) {
			$entry->number($1);
		} elsif ( $line =~ /^pub   (.*?)$/ ) {
			my $tmp = $1;
			my $keydate;
			my ($keyinfo, $keyid) = split(/\//, $tmp);
			
			($keyid, $keydate) = split(/\s+/, $keyid);

			if ( $keyinfo eq "ed25519" ) {
				# Special handling for ed25519
				# The number is not the key size

				$entry->keytype( $keyinfo );
				$entry->size(0);
			} elsif ( $keyinfo =~ /^(\d+)([[:alpha:]])$/ ) {
				# Old format
				# Example: 4096R

				$entry->size($1);

				if ( $2 eq "R" ) {
					$entry->keytype("RSA");
				} elsif ( $2 eq "D" ) {
					$entry->keytype("DSA");
				} else {
					$entry->keytype($2);
				}

			} elsif ( $keyinfo =~ /^([[:alpha:]]+)(\d+)$/ ) {
				# New format
				# Example: rsa4096
				$entry->keytype(uc($1));
				$entry->size($2);
			}

			$entry->id( $keyid );

			$keys_in_file++;
		} elsif ( $line =~ /Key fingerprint = ([0-9A-F ]+)$/ ) {
			#$data{fingerprint} = $1;
			$entry->fingerprint($1);

			if ( $self->KSPGPG->key_exists( $entry->fingerprint_ns ) ) {
				my $key = $self->KSPGPG->get( $entry->fingerprint_ns );
				if ( $key->has_image ) {
					my $img = $key->export_image;
					$entry->photo($img) if ($img);
				}
			}
		} elsif ( $line =~ /uid (.*?)$/ ) {
			my $uid_entry = { text => $1 };

			if ( $self->KSPGPG->key_exists( $entry->fingerprint_ns ) ) {
				if (!exists $keys_found{ $entry->fingerprint_ns } ) {
					$keys_in_keyring++;
					$keys_found{$entry->fingerprint_ns} = 1;
				}

				my $key = $self->KSPGPG->get( $entry->fingerprint_ns );

				if ( $key->check_fingerprint( $entry->fingerprint_ns ) ) {
					if ( $self->check_uids ) {
						my $uid = $key->find_uid( $uid_entry->{text} );
						if ( $uid ) {
							$uid_entry->{certified} = $uid->certified;
							$uid_entry->{expired}   = $uid->expired;
							$uid_entry->{revoked}   = $uid->revoked;
						}
					}
				} else {
					warn "Found key " . $key->id . " in keyring, but fingerprint didn't match!\n";
					     "Keyring fingerprint: " . $key->fingerprint . "\n" .
					     "List fingerprint   : " . $entry->fingerprint_ns;
				}
			}

			push @{$entry->uids}, $uid_entry;
		}

		if ($self->progress_hook) {
			$self->progress_hook->($self, tell($fh), $file_length, $keys_in_file, $keys_in_keyring);
		}

	}
	
	$self->finalizing_hook->($self) if ($self->finalizing_hook);
	$self->_compute_digests($data);
}

1; # Magic true value required at end of module
__END__

=head1 NAME

KeySigningParty::KeyList::FOSDEM - [One line description of module's purpose here]


=head1 VERSION

This document describes KeySigningParty::KeyList::FOSDEM version 0.0.1


=head1 SYNOPSIS

    use KeySigningParty::KeyList::FOSDEM;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
KeySigningParty::KeyList::FOSDEM requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-keysigningparty-keylist-fosdem@rt.cpan.org>, or through the web interface at
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
