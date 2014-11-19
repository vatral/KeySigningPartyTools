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

package KeySigningParty::KeySender;
use warnings;
use strict;
use Carp;
use Moose;

has 'from'               => ( is => 'rw', isa => 'Str');
has 'to'                 => ( is => 'rw', isa => 'Str');
has 'cc'                 => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [ ] } );
has 'signed_key'         => ( is => 'rw', isa => 'Str' );

has 'copy_to_self'       => ( is => 'rw', isa => 'Bool', default => 0 );
has 'encrypt_to_self'    => ( is => 'rw', isa => 'Bool', default => 0 );
has 'only_to_self'       => ( is => 'rw', isa => 'Bool', default => 0 );


has 'signed_key_id'      => ( is => 'rw', isa => 'Str', trigger => \&_update );
has 'my_key_id'          => ( is => 'rw', isa => 'Str', trigger => \&_update );
has 'my_name'            => ( is => 'rw', isa => 'Str', trigger => \&_update );

has 'subject'            => ( is => 'ro', isa => 'Str', writer => '_set_subject');
has 'body'               => ( is => 'ro', isa => 'Str', writer => '_set_body');

has 'body_pattern'       => ( is => 'rw', isa => 'Str', builder => '_build_body_pattern', lazy => 1, trigger => \&_update);
has 'subject_pattern'    => ( is => 'rw', isa => 'Str', default => 'Your signed key %SIGNED_KEY_ID%', trigger => \&_update);



sub _build_body_pattern {
	return <<DEFAULT_BODY;
Hello,

I have signed your PGP key (%SIGNED_KEY_ID%) with my key (%MY_KEY_ID%) and attached
it to this email.

You can import the key with:

   gpg --import <file>

Then, don't forget to send it to a keyserver:

   gpg --keyserver pool.sks-keyservers.net --send-key %SIGNED_KEY_ID%

If you have any questions, let me know.

NOTE:
This email was generated by a new program still under development. If something
seems amiss, please report bugs to Vadim Troschinskiy <gpg\@vadim.ws>. 


Regards,
%MY_NAME%
DEFAULT_BODY

};

sub _update {
	my ($self) = @_;
	$self->_update_body;
	$self->_update_subject;
}

sub _update_body {
	my ($self) = @_;
	my $body = $self->_replace_vars( $self->body_pattern );
	$self->_set_body($body);
}

sub _update_subject {
	my ($self) = @_;
	my $subj = $self->_replace_vars( $self->subject_pattern );
	$self->_set_subject($subj);
}

sub _replace_vars {
	my ($self, $text) = @_;
	my $ski = $self->signed_key_id;
	my $mki = $self->my_key_id;
	my $mn  = $self->my_name;

	$text =~ s/%SIGNED_KEY_ID%/$ski/g;
	$text =~ s/%MY_KEY_ID%/$mki/g;
	$text =~ s/%MY_NAME%/$mn/g;
	return $text;
}

sub send {
}

sub as_string {
}


1;
__DATA__
Hello,

I have signed your PGP key (%SIGNED_KEY_ID%) with my key (%MY_KEY_ID%) and attached
it to this email.

You can import the key with:

   gpg --import <file>

Then, don't forget to send it to a keyserver:

   gpg --keyserver pool.sks-keyservers.net --send-key %SIGNED_KEY_ID%

If you have any questions, let me know.

NOTE:
This email was generated by a new program still under development. If something
seems amiss, please report bugs to Vadim Troschinskiy <gpg@vadim.ws>. 


Regards,
%MY_NAME%


 
