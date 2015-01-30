#!/usr/bin/perl -w


package KeySigningParty::StatusLine;
use strict;
use warnings;
use Moose;


has 'text'           => ( is => 'rw', isa => 'Str', default => "", trigger => \&update );
has 'twirling_baton' => ( is => 'rw', isa => 'Bool', default => 0 );


sub update {
	my ($self, %opts) = @_;

	$self->{prev_length} = 0 unless (exists $self->{prev_length});
	$self->{count} = 0       unless (exists $self->{count});

	my $text = $self->text;

	if ( $self->twirling_baton && !$opts{no_baton}) {
		my @chars = qw( | / - \ );
		$text .= " " . $chars[ $self->{count}++ % ($#chars + 1)];
	}

	print STDERR "\r" . $text;

	$self->{prev_length} = 0 unless (exists $self->{prev_length});

	if ( length($text) < $self->{prev_length} ) {
		print STDERR " " x ( $self->{prev_length} - length($text) );
		print STDERR "\r" . $text;
	}
 
	$self->{prev_length} = length($text);
}

sub erase {
	my ($self) = @_;

	$self->{prev_length} = 0 unless (exists $self->{prev_length});
	print STDERR "\r" . (" " x $self->{prev_length}) . "\r";
}

sub newline {
	my ($self) = @_;
	$self->update( no_baton => 1 );
	print STDERR "\n";
	$self->{prev_length} = 0;
}

sub message {
	my ($self, $message) = @_;
	$self->erase;
	print "$message\n";
	$self->update;
}

sub error {
	my ($self, $message) = @_;
	$self->erase;
	print STDERR "$message\n";
	$self->update;

}

1;
