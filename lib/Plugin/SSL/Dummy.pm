## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
## Here should be placed presentation functions for Dummy plug-in
package HSPC::Plugin::SSL::Dummy;

use strict;

use HSPC::PluginToolkit::General qw(string argparam);
use HSPC::PluginToolkit::HTMLTemplate qw{parse_template};
use HSPC::PluginToolkit::SSL qw(create_unique_name_prefix);

use HSPC::MT::Plugin::SSL::Dummy::Constants;

#### ------ config forms -------------------------------

sub get_config_view {
	my $class = shift; 
	my %arg = (
		config => undef,
		@_
	);
	## $conf is hashref:
	##  { mode => 1|2|3
	##  }
	my $conf = $arg{config};
	
	my $mode = {};
	while (my ($key, $value) = each(%{&SSL_DUMMY_MODE_OPTIONS})) {
		$mode->{$key} = string($value);
	}
	
	my $result = '';
	
	$result .= parse_template(
		name => 'item_view_text.tmpl',
		data => {
			title => string('ssl_dummy_mode'),
			value => $mode->{$conf->{mode}},
		}
	);

	return parse_template(
		name => 'table_view.tmpl',
		data => {
			value => $result,
		}
	);
}

sub get_config_form {
	my $class = shift; 
	my %arg = (
		config => undef,
		@_
	);
	my $conf = $arg{config};
	
	my $mode = [];
	my %options = %{&SSL_DUMMY_MODE_OPTIONS};
	foreach my $key (sort keys %options) {
		push @$mode, [ $key, string($options{$key}) ];
	}
	
	my $html = '';
	$html .= parse_template(
		name => 'item_edit_combo.tmpl',
		data => {
			title => string('ssl_dummy_mode'),
			name => 'mode',
			value => argparam('mode') || $conf->{mode},
			options => $mode,
			no_default => 1,
		}
	);
	
	return $html;
}

sub validate_config_data {
	my $class = shift; 
	my %arg = (
		config => undef,
		@_
	);
	my @errors;
	my $conf = $arg{config};

	my %mand_fields = (
		mode => string('ssl_dummy_mode'),
	);

	foreach my $key (keys %mand_fields){
		if (!$conf->{$key}) {
			push @errors, {
				field => $key,
				message => string(
					'ssl_field_mandatory',
					field => $mand_fields{$key}
				)
			}
		} elsif ($key eq 'mode'
		      && $conf->{$key} != SSL_DUMMY_NO_OP
			  && $conf->{$key} != SSL_DUMMY_FAKE_CERTIFICATE
			  && $conf->{$key} != SSL_DUMMY_SELF_SIGNED_CERTIFICATE) {
			push @errors, {
				field => $key,
				message => string(
					'ssl_field_incorrect',
					field => $mand_fields{$key},
					value => $conf->{$key}
				)
			}
		}

	}
	return {
		is_valid => scalar(@errors) ? 0 : 1,
		error_list => scalar(@errors) ? \@errors : undef
	}
}

sub collect_data {
	my $class = shift; 
	my $config_data = {
		mode => argparam('mode'),
	};

	return $config_data;
}

sub get_help_page {
	my $class = shift;
	my %h = (
		action => undef,
		language => undef,
		config => undef,
		@_
	);
	my $action = $h{action};
	my $language = $h{language};

	my $help_page;
	if($action =~ /^(about|new|view|edit)$/){
		my $tmpl_name = "dummy_ssl_$action.html";
		$help_page = parse_template(
			path => __PACKAGE__ . '::help::' . uc($language),
			name => $tmpl_name
		);
	}

	return $help_page;
}

sub get_contact_types {
	my $class = shift;

	return [];
}

## No contact types means no:
## - get_contact_view
## - get_contact_form
## - validate_contact_form

sub collect_contacts
{
	my $class = shift;

	return {};
}

sub get_ext_attr_view {
	my $class = shift;
	my %h = (
		prefix => undef,
		product => undef,
		plugin_config => undef,

		ext_attr => undef,
		@_
	);

	return '';
}

sub get_ext_attr_form {
	my $class = shift;
	my %h = (
		prefix => undef,
		product => undef,
		plugin_config => undef,

		ext_attr => undef,
		@_
	);

	return '';
}

sub collect_ext_attr
{
	my $class = shift;

	my %h = (
		prefix => undef,
		form_data => undef,
		plugin_config => undef,
		@_
	);

	return {};
}

sub validate_ext_attr_form {
	my $class = shift;
	my %h = (
		prefix => undef,
		product => undef,
		plugin_config => undef,

		ext_attr => undef,
		@_
	);

	return {};
}

1;
