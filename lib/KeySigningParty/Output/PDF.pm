package KeySigningParty::Output::PDF;
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
use KeySigningParty::KeyList;
use PDF::API2;
use KeySigningParty::Output::PDF::Element::Key;

extends 'KeySigningParty::Output';

has 'margin'     => ( is => 'rw', isa => 'Num', default => 30 );
has 'padding'    => ( is => 'rw', isa => 'Num', default => 30 );
has 'paper'      => ( is => 'rw', isa => 'Str', default => 'A4' );

sub generate {
	my ($self, $filename) = @_;
	
	my $pdf = new PDF::API2( -file => $filename);
	my $page;
	my ($llx, $lly, $urx, $ury);
	my ($x, $y, $w, $h);
	
	$pdf->mediabox($self->paper);

	my $line_num = 1;
	
	foreach my $ent ( @{$self->list->entries} ) {
		print ".";

		my $page_elem = new KeySigningParty::Output::PDF::Element::Key( pdf           => $pdf, 
		                                                                number        => $line_num++, 
		                                                                entry         => $ent,
		                                                                visual_hashes => $self->visual_hashes);
		
		if ( $page ) {
			if ( ($y - $page_elem->get_height - $self->margin ) < $lly ) {
				undef $page;
			}
		}
		
		if ( !$page ) {
			$page = $pdf->page();

			($llx, $lly, $urx, $ury) = $page->get_mediabox;
			$h = $urx - $llx;
			$w = $ury - $lly;
			$x = $self->margin;
			$y = $ury - $self->margin;
			
			print "\n";
		}

		$page_elem->draw($page, $x, $y);
		$y -= $page_elem->get_height;
				
	}
	
	$pdf->save();
	$pdf->end();

}

1;
