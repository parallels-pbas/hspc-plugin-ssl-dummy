## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
## Here should be placed MT template functions for Dummy plug-in
package HSPC::MT::Plugin::SSL::Dummy;

use strict;

use HSPC::PluginToolkit::General qw(string log log_debug log_warn escape_string);
use HSPC::PluginToolkit::SSL qw(generate_self_signed);
use HSPC::MT::Plugin::SSL::Dummy::Constants;
use Storable qw(freeze);

use constant MS_IEE_SERVER_SOFTWARE_TYPES => [qw(
	microsoft_iis_4 microsoft_iis_5	microsoft_iis_6 microsoft_iis_7_5
	)];

use constant STATE_IS_REQUIRED => 0;

sub get_title
{
	my $class = shift;
	
	return string('ssl_dummy_plugin_title_uc');
}

sub get_product_list
{
	my $class = shift;
	
	my %h = (
		plugin_config => undef,
		@_
	);

	## Key of product can be used for lookup in i18n
	## (dummy_superssl -> ssl_product_dummy_superssl)
	## 'external' will be sent to API
	return {
		"dummy_superssl" =>
		{ name => string("ssl_product_dummy_superssl"),
		  external => 'Dummy_Super_SSL',
		  periods => [ 1, 2, 5 ],
		  bits => [ 2048 ]},
		"dummy_normalssl" =>
		{ name => string("ssl_product_dummy_normalssl"),
		  external => 'Dummy_Normal_SSL',
		  periods => [1, 2, 3, 5, 10 ],
		  bits => [ 1024, 2048 ]}
	};
}

## Returns 50 * period for any SSL product, 25 * period for renew
sub get_price_list
{
	my $class = shift;

	my %h = (
		product => undef,
		plugin_config => undef,
		@_
	);

	my $products = $class->get_product_list(
		plugin_config => $h{plugin_config},
	);
	if (!$products->{$h{product}}) {
		return undef;
	}

	my $prices = {};
	foreach my $period (@{$products->{$h{product}}->{periods}}) {
		$prices->{$period} = {
			new => $period*50,
			renew => $period*25,
			currency => 'EUR'
		};
	}
	return $prices;
}

sub get_server_software_type_list
{
	my $class = shift;

	my %h = (
		product => undef,
		plugin_config => undef,
		@_
	);

	my $products = $class->get_product_list(
		plugin_config => $h{plugin_config},
	);
	if (!$products->{$h{product}}) {
		return undef;
	}

	my $product = $products->{$h{product}};

	if ($h{product} eq "dummy_superssl") {
		return { map { $_ => string('ssl_'.$_) }
				 qw(apache_mod_ssl microsoft_iis_4 microsoft_iis_5
					microsoft_iis_6) };
	}
	elsif ($h{product} eq "dummy_normalssl") {
		return { map { $_ => string('ssl_'.$_) }
				 qw(apache_mod_ssl microsoft_iis_4 microsoft_iis_5
					microsoft_iis_6 microsoft_iis_7_5) };
	}
}

sub get_approver_email_list
{
	my $class = shift;

	my %h = (
		domain_name => undef,
		plugin_config => undef,
		@_
	);

	return ['admin@'.$h{domain_name},
		    'root@'.$h{domain_name},
		    'postmaster@'.$h{domain_name}
		   ];
}

## Validate CSR data
sub validate_csr_data
{
	my $class = shift;

	my %h = (
		product => undef,
		csr_data => undef,
		plugin_config => undef,
		server_software_type => undef,
		@_
	);

	my $invalid = {};

	$invalid->{country} = string('ssl_validate_error_c')
		unless $h{csr_data}->{country} =~ m/^[A-Z]{2}$/i;

	$invalid->{common_name} = string('ssl_validate_error_cn')
		unless $h{csr_data}->{common_name} =~ m/\./; ## should contain a dot

	if ( &STATE_IS_REQUIRED && !$h{csr_data}->{state} && !$h{csr_data}->{state_alt} ) {
		if (   $h{csr_data}->{country} eq 'US'
			|| $h{csr_data}->{country} eq 'CA' )
		{
			$invalid->{state} = string('ssl_validate_error_st');
		}
		else {
			$invalid->{state_alt} = string('ssl_validate_error_st');
		}
	}
	
	unless ( grep {	$h{server_software_type} eq $_ } @{&MS_IEE_SERVER_SOFTWARE_TYPES}) {
		## Check email
		$invalid->{email} = string('ssl_validate_error_email')
			unless $h{csr_data}->{email};
	}
	
	return $invalid;
}

sub issue_certificate
{
	my $class = shift;

	my %h = (
		domain => undef,
		product => undef,
		period => undef, ## in years
		private_key => undef,
		csr => undef,
		csr_data => undef,
		approver_email => undef,
		software_type => undef,
		ext_attr => undef,
		contact_data => undef,
		plugin_config => undef,
		@_
	);

	my $ext_attr = {};

	## Issue self-signed certificate
	if ($h{plugin_config}->{mode} eq &SSL_DUMMY_SELF_SIGNED_CERTIFICATE) {
		my $certbody = HSPC::PluginToolkit::SSL->generate_self_signed(
			private_key => $h{private_key},
			csr => $h{csr},
			period => $h{period},
		);
		$ext_attr->{certificate_body} = $certbody;
	}

	## Issuing a dummy certificate always succeeds
	return {
		status => 'OK',
		ext_attr => $ext_attr,
	};
}

sub check_available
{
	my $class = shift;

	my %h = (
		ext_attr => undef,
		plugin_config => undef,
		@_
	);

	## Dummy certificates are always available instantly
	return { status => 'OK' };
}

sub fetch_certificate
{
	my $class = shift;

	my %h = (
		ext_attr => undef,
		plugin_config => undef,
		@_
	);

	my $certbody;
	if ($h{plugin_config}->{mode} eq &SSL_DUMMY_NO_OP) {
		$certbody = '';
	}
	elsif ($h{plugin_config}->{mode} eq &SSL_DUMMY_FAKE_CERTIFICATE) {
		$certbody = 'TEST CERTIFICATE';
	}
	elsif ($h{plugin_config}->{mode} eq &SSL_DUMMY_SELF_SIGNED_CERTIFICATE) {
		$certbody = $h{ext_attr}->{certificate_body};
	}
	return { status => 'OK',
			 certbody => $certbody };
}

sub renew_certificate
{
	my $class = shift;

	my %h = (
		domain => undef,
		product => undef,
		period => undef,
		private_key => undef,
		csr => undef,
		csr_data => undef,
		approver_email => undef,
		software_type => undef,
		ext_attr => undef,
		contact_data => undef,
		plugin_config => undef,
		@_
	);

	return { status => 'OK' };
}

1;
