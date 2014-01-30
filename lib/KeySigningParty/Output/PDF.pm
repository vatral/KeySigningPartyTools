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
use KeySigningParty::Output::PDF::Element::Header;
use KeySigningParty::Output::PDF::Element::Cover;
extends 'KeySigningParty::Output';

has 'margin'     => ( is => 'rw', isa => 'Num', default => 30 );
has 'padding'    => ( is => 'rw', isa => 'Num', default => 30 );
has 'paper'      => ( is => 'rw', isa => 'Str', default => 'A4' );

sub generate {
	my ($self, $filename) = @_;
	
	my $pdf;
	my $page;
	my ($llx, $lly, $urx, $ury);
	my ($x, $y, $w, $h);
	
	

	
	my $page_info = {};
	my $total_elements = 0;
	
	$self->starting_hook->($self) if ( $self->starting_hook );
	
	
	for(my $draw_elements=0;$draw_elements<2;$draw_elements++) {
		# Loop through the entire dataset twice. On the first go, we calculate
		# how many pages we're going to get, and how many keys are going to fit
		# on each page.
		#
		# On the second go, we draw them.
		$pdf = new PDF::API2( -file => $filename);
 		$pdf->mediabox($self->paper);
		undef $page;
# 		
		#my $draw_elements = ($loop == 1);
		my $line_num = 1;
		my $page_num = 0;
		
		foreach my $ent ( @{$self->list->entries} ) {
			#print ".";

			my $page_elem = new KeySigningParty::Output::PDF::Element::Key( pdf           => $pdf, 
											number        => $line_num, 
											entry         => $ent,
											visual_hashes => $self->visual_hashes);
			
			if ( $page ) {
				if ( ($y - $page_elem->get_height - $self->margin ) < $lly ) {
					undef $page;
				}
			}
			
			if ( !$page ) {
				$page = $pdf->page();
				$page_num++;
				
				if ( !$draw_elements ) {
					$page_info->{$page_num} = {
						first => $ent->number
					};
				}
				
				($llx, $lly, $urx, $ury) = $page->get_mediabox;
				$h = $urx - $llx;
				$w = $ury - $lly;
				$x = $self->margin;
				$y = $ury - $self->margin;
				
				
				#print "\n";
				
				my $hdr = new KeySigningParty::Output::PDF::Element::Header ( pdf           => $pdf,
											page          => $page_num,
											first_number  => ($draw_elements ? $page_info->{$page_num}->{'first'} : 0),
											last_number   => ($draw_elements ? $page_info->{$page_num}->{'last'} : 0));
											
				$hdr->draw($page, $x, $y) if ( $draw_elements );
				$y -= $hdr->get_height;
				
			}

			if ( $draw_elements ) {
				$page_elem->draw($page, $x, $y);
				
				if ( $self->progress_hook ) {
					$self->progress_hook->($self, $page_num, scalar keys %$page_info, $line_num, $total_elements);
				}
			} else {
				$page_info->{$page_num}->{'last'} = $ent->number;
				$total_elements++;
			}
			$line_num++;
			
			$y -= $page_elem->get_height;
					
		}

		if ( $draw_elements ) {
			# Print one last page with fingerprints and other useful things
			#
			$page = $pdf->page();

			($llx, $lly, $urx, $ury) = $page->get_mediabox;
			$h = $urx - $llx;
			$w = $ury - $lly;
			$x = $self->margin;
			$y = $ury - $self->margin;

			
			my $cover = new KeySigningParty::Output::PDF::Element::Cover( pdf     => $pdf,
			                                                              page    => $page,
			                                                              digests => $self->list->digests );

			$cover->draw($page, $x, $y);
		} 
	}
	
	$self->finalizing_hook->($self) if ( $self->finalizing_hook );
	
	$pdf->save();
	$pdf->end();

}

1;
