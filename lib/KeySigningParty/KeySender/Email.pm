#!/usr/bin/perl -w

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

package KeySigningParty::KeySender::Email;
use warnings;
use strict;
use Moose;
use MIME::Entity;
use Mail::GnuPG;

extends 'KeySigningParty::KeySender';

has 'smtp_server'    => ( is => 'rw', isa => 'Str');
has 'port'           => ( is => 'rw', isa => 'Num');
has 'ssl'            => ( is => 'rw', isa => 'Bool', default => 0 );


sub send {
}

sub as_string {
	my ($self) = @_;
	return $self->_gen_message->as_string;
}

sub _gen_message {
	my ($self) = @_;

	my $top = MIME::Entity->build( From     => $self->from,
	                               To       => $self->to,
	                               Subject  => $self->subject,
	                               Type     => 'multipart/mixed');

	
	$top->attach(Data => $self->body);

	$top->attach(Type     => 'text/plain',
	             Filename => $self->my_key_id . ".asc",
	             Data     => $self->signed_key);



	return $top;
}
1; 
