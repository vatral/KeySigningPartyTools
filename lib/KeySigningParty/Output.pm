package KeySigningParty::Output;
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

has 'list'          => ( is => 'rw', isa => 'KeySigningParty::KeyList' );
has 'visual_hashes' => ( is => 'rw', isa => 'ArrayRef[KeySigningParty::VisualHash]' );

has 'starting_hook' => ( is => 'rw', isa => 'CodeRef' );
has 'progress_hook'   => ( is => 'rw', isa => 'CodeRef' );
has 'finalizing_hook' => ( is => 'rw', isa => 'CodeRef' );

sub generate {
}

1;
