package KeySigningParty::Output::PDF::Element;
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

has 'font'       => ( is => 'rw', isa => 'Str', default => 'Courier' );
has 'font_size'  => ( is => 'rw', isa => 'Num', default => 9 );
has 'fillcolor'  => ( is => 'rw', isa => 'Str', default => 'lightgrey' );
has 'textcolor'  => ( is => 'rw', isa => 'Str', default => 'black' );
has 'pdf'        => ( is => 'rw', isa => 'PDF::API2' );
has 'margin'     => ( is => 'rw', isa => 'Num', default => 0 );

sub get_height {
	return 0;
}

sub draw {

}

1;
