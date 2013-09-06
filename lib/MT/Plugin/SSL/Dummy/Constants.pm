## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
package HSPC::MT::Plugin::SSL::Dummy::Constants;
use strict;

use base qw(Exporter);

use constant SSL_DUMMY_NO_OP => 1;
use constant SSL_DUMMY_FAKE_CERTIFICATE => 2;
use constant SSL_DUMMY_SELF_SIGNED_CERTIFICATE => 3;
use constant SSL_DUMMY_MODE_OPTIONS => {
	&SSL_DUMMY_NO_OP => 'ssl_dummy_mode_no_op',
	&SSL_DUMMY_FAKE_CERTIFICATE => 'ssl_dummy_mode_fake_certificate',
	&SSL_DUMMY_SELF_SIGNED_CERTIFICATE => 'ssl_dummy_mode_self_signed_certificate',
};

use constant SSL_DUMMY_1024_BITS => 1024;
use constant SSL_DUMMY_2048_BITS => 2048;
use constant SSL_DUMMY_4096_BITS => 4096;
use constant SSL_DUMMY_BITS_OPTIONS => {
	&SSL_DUMMY_1024_BITS => 'ssl_dummy_1024_bits',
	&SSL_DUMMY_2048_BITS => 'ssl_dummy_2048_bits',
	&SSL_DUMMY_4096_BITS => 'ssl_dummy_4096_bits',
};

our @EXPORT = qw(
	SSL_DUMMY_NO_OP
	SSL_DUMMY_FAKE_CERTIFICATE
	SSL_DUMMY_SELF_SIGNED_CERTIFICATE
	SSL_DUMMY_MODE_OPTIONS
	SSL_DUMMY_1024_BITS
	SSL_DUMMY_2048_BITS
	SSL_DUMMY_4096_BITS
	SSL_DUMMY_BITS_OPTIONS
);

1;
