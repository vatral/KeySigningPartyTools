package KeySigningParty::Output::PDF::Element::Header;
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

has 'page'         => ( is => 'rw', isa => 'Num', default => 0 );
has 'first_number' => ( is => 'rw', isa => 'Num', default => 0 );
has 'last_number'  => ( is => 'rw', isa => 'Num', default => 0 );

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
	

	my $box = $page->gfx;
	# Text coordinates go by the lower left corner. We have to cover that line too,
	# so shift everything one line up
	$box->rect( $x, $y + $self->line_height, $content_width, -$self->line_height );
	$box->fillcolor($self->fillcolor);
	$box->fill;

	$self->_text($page, $x, $y, $self->page . " (" . $self->first_number . " to " . $self->last_number . ")");

}

1;
