package KeySigningParty::Output::PDF::Element::Cover;
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
extends 'KeySigningParty::Output::PDF::Element';

has 'digests'  => ( is => 'rw', isa => 'HashRef[Str]', default => sub { { } } );

sub get_height {
	my $self = shift;
	return $self->line_height * 2;
}

sub draw {
	my ( $self, $page, $x, $y ) = @_;
	
	my ($llx, $lly, $urx, $ury) = $page->get_mediabox;
	my $w = $urx - $llx;
	my $h = $ury - $lly;

	my $content_width = $w - ($x*2);

	$self->_text($page, $x, $y, "Digests for the original file:");
	
	foreach my $dig ( sort keys %{ $self->digests } ) {
		my @hexchars = split(//, $self->{digests}->{$dig});
		my $line = "";
		my $count=0;

		$y -= 10;
		foreach my $c ( @hexchars ) {
			$line .= $c;
			$count++;

			if ( ( $count % 4 ) == 0 ) {
				$line .= " ";
			}

			if ( ( $count % 16 ) == 0 ) {
				$line .= " ";
			}

			if ( $count % 32 == 0 || $count == scalar @hexchars ) {
				if ( $count <= 32 ) {
					$self->_text($page, $x, $y, "    $dig: $line");
				} else {
					$self->_text($page, $x, $y, "    " . ( " " x length($dig)) . "  $line");
				}
				$y -= 10;
				$line = "";
			}
		}


	}


}

1;
