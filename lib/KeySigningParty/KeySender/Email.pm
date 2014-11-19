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
use Email::Sender::Simple qw(sendmail);


extends 'KeySigningParty::KeySender';

has 'smtp_server'    => ( is => 'rw', isa => 'Str');
has 'port'           => ( is => 'rw', isa => 'Num', default => 25);
has 'ssl'            => ( is => 'rw', isa => 'Bool', default => 0 );


sub send {
	my ($self) = @_;
	my $mail = $self->_gen_message;

	sendmail($mail);
}

sub as_string {
	my ($self) = @_;
	return $self->_gen_message->as_string;
}

sub _gen_message {
	my ($self) = @_;

	my $cc = $self->cc;
	my $to = $self->to;
	my $subj = $self->subject;

	if ( $self->copy_to_self ) {
		push $cc, $self->from;
	}

	if ( $self->only_to_self ) {
		$to   = $self->from;
		$subj = "[TEST] " . $subj;
		$cc   = [];
	}

	my $top = MIME::Entity->build( From     => $self->from,
	                               To       => $to,
	                               Cc       => $cc,
	                               Subject  => $subj,
	                               Type     => 'multipart/mixed');

	
	$top->attach(Data => $self->body);

	$top->attach(Type     => 'text/plain',
	             Filename => $self->my_key_id . ".asc",
	             Data     => $self->signed_key);



	my $mg = Mail::GnuPG->new( key       => $self->my_key_id,
	                           use_agent => 1 );

	my @encrypt_to = ($self->to);
	if ( $self->encrypt_to_self ) {
		push @encrypt_to, $self->my_key_id;
	}

	if (my $ret = ($mg->mime_signencrypt( $top, @encrypt_to) )) {
		die "Failed to sign and encrypt.\n".
		    "GPG code:   $ret\n",
		    "GPG errors: " . join("\n", @{$mg->{last_message}}) . "\n".
		    "GPG output: " . join("\n", @{$mg->{plaintext}}) . "\n";
	}

	return $top;
}
1; 
