#!/usr/bin/perl -w


package KeySigningParty::ConfigFile;
use strict;
use warnings;
use Moose;
use Data::Dumper;
use KeySigningParty::GPG;


has 'filename' => ( is => 'rw', isa => 'Str', default => "$ENV{HOME}/.ksp_config" );
has 'data'     => ( is => 'rw', isa => 'HashRef' );

# Use the main program's KeySigningParty::GPG to use the same cache,
# and to automatically get any module settings.
has 'KSPGPG'   => ( is => 'rw', isa => 'KeySigningParty::GPG' );


sub file_exists {
	my ($self) = @_;
	return ( -f $self->filename );
}

sub load {
	my ($self) = @_;
	
	open(my $fh, '<', $self->filename) or die "Can't load config file " . $self->filename . ": $!";
	my $perms = (stat($fh))[2];
	if ( $perms & 0022 ) {
		die "Config file must not be writable by group or others";
	}
	
	local $/;
	undef $/;
	my $data = <$fh>;
	close $fh;
	
	my $ret = eval $data;
	if ( $@ ) {
		die "Failed to read config file: $@";
	}
	
	if (!exists $ret->{secret_keys}) {
		die "No secret key in config file";
	}
	
	if (!ref($ret->{secret_keys})) {
		# Convert to a single element array if not an array,
		# for simplicity afterwards.
		$ret->{secret_keys} = [ $ret->{secret_keys} ];
	}
	
	$self->data($ret);
}


sub generate {
	my ($self) = @_;
	
	if ( $self->file_exists ) {
		die "Refusing to overwrite existing file " . $self->filename . ", please delete it if you are sure, and try again";
	}
	

	my $conf_pattern = $self->_get_pattern();
	my $secr = "[\n";
	my $iden = "";
	my $first_secr = 1;
	
	foreach my $key ( @{$self->KSPGPG->secret_keys} ) {
		$iden .= ",\n\n" unless ($first_secr);
		
		my $key_ids  = $self->KSPGPG->secret_keys_uids->{$key};
		my $orig_text = $key_ids->[0]->{text};
		my $key_text = $orig_text;
		$key_text =~ s/\(.*\)//; # remove annotation
		$key_text =~ s/\s+</ </; # remove extra spaces before email address
		
		my $email = $key_text;
		my $signature = $key_text;
		$signature =~ s/<.*>//;
		$signature =~ s/\s+$//;
		
		$iden .= "\t\t\t# $orig_text\n";
		$iden .= "\t\t\t'$key' => {\n";
		$iden .= "\t\t\t\taddress   => '$email',\n";
		$iden .= "\t\t\t\tsignature => '$signature'\n";
		$iden .= "\t\t\t}";
		
		
		$secr .= "\t\t'$key', ";
		$secr .= "# $orig_text\n";
		
		undef $first_secr;
	}
	$secr .= "\t]";
	
	
	$conf_pattern =~ s/%SECRET_KEYS%/$secr/g;
	$conf_pattern =~ s/%IDENTITIES%/$iden/g;
	
	my $prev_mask = umask(0077);
	open(my $fh, '>', $self->filename) or die "Can't create config file " . $self->filename . ": $!";
	print $fh $conf_pattern;
	close $fh;
	umask($prev_mask);
	
	
}


sub _get_pattern {
	my ($self) = @_;
	
	if (!$self->{pattern}) {
		local $/;
		undef $/;
		$self->{pattern} = <DATA>;
	}
	
	return $self->{pattern};
}


1;

__DATA__

#!/usr/bin/perl
{
	secret_keys => %SECRET_KEYS%,

	'KeySigningParty::KeySender::Email' => {
		identities => {
%IDENTITIES%
		},
		
		# Send a copy to yourself.
		# If encrypt_to_self is not set it won't be readable.
		copy_to_self => 1,

		# Make the mail readable by yourself
		encrypt_to_self => 1,

		# Only sends the mail to yourself, does not record delivery.
		# Used for testing. All other address related options are
		# ignored if this is set.
		only_to_self    => 0,

		# SMTP connection parameters
		smtp_server  => 'localhost',
		port         => 25,
		ssl          => 0
		
	}
};
