package KeySigningParty::Output::PDF::Element::Key;
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
use PDF::API2;

use version; our $VERSION = qv('0.0.3');
extends 'KeySigningParty::Output::PDF::Element';

has 'number'      => ( is => 'rw', isa => 'Num', default => 0 );
has 'entry'       => ( is => 'rw', isa => 'KeySigningParty::KeyList::Entry' );
has 'num_width'   => ( is => 'ro', isa => 'Num', default => 40 );
has 'uid_width'   => ( is => 'ro', isa => 'Num', default => 120 );
has 'image_size'  => ( is => 'ro', isa => 'Num', default => 40 );
has 'visual_hashes' => ( is => 'rw', isa => 'ArrayRef[KeySigningParty::VisualHash]' );


sub get_height {
	my $self = shift;
	my $ret = $self->line_height + (scalar( @{$self->entry->uids} ) * $self->line_height );
	
	if ( $ret < $self->image_size + $self->line_height ) {
		# If there's no room for the image, make some
		$ret = $self->image_size + $self->line_height 
	}
	
	return $ret;
}

sub draw {
	my ( $self, $page, $x, $y ) = @_;
	
	my ($llx, $lly, $urx, $ury) = $page->get_mediabox;
	my $w = $urx - $llx;
	my $h = $ury - $lly;

	my $content_width = $w - ($x*2);
	
	if ( $self->number % 2 ) {
		my $box = $page->gfx;
		# Text coordinates go by the lower left corner. We have to cover that line too,
		# so shift everything one line up
		$box->rect( $x, $y + $self->line_height, $content_width, -$self->get_height );
		$box->fillcolor($self->fillcolor);
		$box->fill;
	}

	my $font = $self->pdf->corefont( $self->font );
	
	# Key ID and fingerprint
	$self->_text($page, $x, $y, $self->entry->number);
	$self->_text($page, $x+$self->num_width, $y, $self->entry->size . $self->entry->keytype . "/" . $self->entry->id);
	$self->_text($page, $x+$self->num_width+$self->uid_width, $y, $self->entry->fingerprint . " [ ] Fingerprint OK");
	$self->_text($page, $x+$self->num_width+$self->uid_width, $y-10, (" " x length($self->entry->fingerprint)) . " [ ] ID OK"); # FIXME: UGLY!!

	# UIDs
	my $saved_y = $y;
	foreach my $uid ( @{ $self->entry->uids } ) {
		$y -= 10;
		my $mark = "";

		if ( $uid->{revoked} ) {
			$mark = "REV";
		} elsif ( $uid->{expired} ) {
			$mark = "EXP";
		} elsif ( $uid->{certified} ) {
			$mark = "[X]";
		} else {
			$mark = "[ ]";
		}

		$self->_text($page, $x+$self->num_width, $y, $mark . " " . $uid->{text});
	}
	$y = $saved_y;

	
	# Visual hashes
	my $hash_count = 1;
	foreach my $vhash ( @{$self->visual_hashes} ) {
		my $file    = $vhash->get_image( $self->entry );
		
		my $img     = $self->pdf->image_png($file);
		my $img_gfx = $page->gfx();
		$img_gfx->image( $img, 
		                 $x + $content_width - ($self->image_size * $hash_count) - (5 * ($hash_count-1)),
		                 $y - $self->image_size + $self->line_height,
		                 $self->image_size,
		                 $self->image_size);
		                 
		$hash_count++;
	}
	
	# Photo if there are any
	if ( my $photo_file = $self->entry->get_photo_image ) {
		my $photo_img = $self->pdf->image_jpeg( $photo_file );
		my $photo_gfx = $page->gfx();
		
		$photo_gfx->image( $photo_img, $x, $y - $self->image_size, $self->image_size, $self->image_size);
	}
	
	
}

1;
