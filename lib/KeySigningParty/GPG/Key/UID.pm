package KeySigningParty::GPG::Key::UID;
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
use KeySigningParty::Types qw( Hex );
use KeySigningParty::GPG::Key::UID::Signature;

use version; our $VERSION = qv('0.0.3');

has 'parent_key'  => ( is => 'rw', isa => 'KeySigningParty::GPG::Key');

has 'num'         => ( is => 'rw', isa => 'Num' );
has 'id'          => ( is => 'rw', isa => Hex );
has 'text'        => ( is => 'rw', isa => 'Str' );
has 'expired'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'revoked'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'image'       => ( is => 'rw', isa => 'Bool', default => 0);
has 'date'        => ( is => 'rw', isa => 'Str',  default => '' );

has 'certified'   => ( is => 'rw', isa => 'Bool', lazy => 1, builder => '_load_certified');
has 'signatures'  => ( is => 'rw', isa => 'ArrayRef[KeySigningParty::GPG::Key::UID::Signature]', lazy => 1, builder => '_load_sigs');

sub bad {
	my ($self) = @_;
	return $self->expired || $self->revoked;
}

sub good {
	my ($self) = @_;
	return !$self->bad;
}


sub _load_sigs {
	my ($self) = @_;
	# Parent performs signature loading because we get signatures
	# for an entire key at once.
	
	$self->parent_key->_load_sigs;
}

sub _load_certified {
	my ($self) = @_;
	$self->parent_key->_load_sigs;

	# Ugly hack, _load_sigs will set $self->certified to the right value.
	return $self->{certified} if ( exists $self->{certified} );
	return 0;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

KeySigningParty::GPG::Key::UID - [One line description of module's purpose here]


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
