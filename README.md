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

Running
=======

Programs can be run in place, like this:

  perl ./bin/ksp-makelist


