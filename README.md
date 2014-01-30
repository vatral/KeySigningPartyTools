KeySigningPartyTools
====================

Tools for people who attend key signing parties.


List of tools
=============

ksp-makelist: create a better formatted list in PDF format by reading
a FOSDEM key list.

ksp-import-keys: automatically import signatures from a mailbox.
Supports mbox files, IMAP and POP3 servers.

ksp-scanlist: scan QR codes from a list created by ksp-makelist, and
generate a list of keys to sign.

Requirements
============

* Digest::SHA
* Digest::RMD160
* PDF::API2
* Barcode::ZBar
* Moose
* qrencode
* Vash (optional)
* Speech::eSpeak (only for key scanning)

Running
=======

Programs can be run in place, like this:

$ perl ./bin/ksp-makelist


Usage
=======

First, download the FOSDEM key signing party files. Here we setup a separate keyring, to avoid
crowding the main one. This is optional.

$ wget https://ksp.fosdem.org/files/ksp-fosdem2014.txt https://ksp.fosdem.org/files/keyring.asc.bz2
$ bunzip2 keyring.asc.bz2
$ gpg --keyring ~/.gnupg/fosdem2014.gpg --no-default-keyring --import keyring.asc
$ echo "keyring ~/.gnupg/fosdem2014.gpg" >> ~/.gnupg/gpg.conf

Generate a list:

$ bin/ksp-makelist --output fosdem_2014.pdf ksp-fosdem2014.txt

Print it, go to FOSDEM and mark the keys to sign. Then take a black marker, and cover the QR codes
for the keys you are NOT going to sign, to make sure you can't scan them by accident.

Generate a list of keys to sign:

$ bin/ksp-scanlist --output selected_keys.txt ksp-fosdem2014.txt

Hold the printed list in front of a camera, and scan the keys. Close the camera window when done.


