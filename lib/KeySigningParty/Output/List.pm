package KeySigningParty::Output::List;

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

extends 'KeySigningParty::Output';

has 'margin'     => ( is => 'rw', isa => 'Num', default => 30 );
has 'padding'    => ( is => 'rw', isa => 'Num', default => 30 );
has 'paper'      => ( is => 'rw', isa => 'Str', default => 'A4' );

sub generate {
	my ($self, $filename) = @_;
	
	open(my $fh, '>', $filename) or die "Can't open $filename: $!";
	binmode($fh, ":utf8");

	print $fh "\t\tFull list\n";

	
	$self->starting_hook->($self) if ( $self->starting_hook );
	
	my $line_num=0;	
	my $total_elements = scalar @{$self->list->entries};


	foreach my $ent ( @{$self->list->entries} ) {
		print $fh $ent->number . "\t" . $ent->long_id . "\t" . $ent->uids->[0] . "\n";
	

		$line_num++;

		if ( $self->progress_hook ) {
			$self->progress_hook->($self, 1, 1, $line_num, $total_elements);
		}
	}

	$self->finalizing_hook->($self) if ( $self->finalizing_hook );

	close $fh;
	

}

1;
