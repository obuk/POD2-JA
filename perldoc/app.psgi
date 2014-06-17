# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=head1 NAME

perldoc/app.psgi - perldoc -L JA web server

=head1 SYNOPSIS

    $ plackup -a perldoc/app.psgi

=cut

use strict;
use warnings;

BEGIN {  # Make a DEBUG constant very first thing...
	unless (defined &DEBUG) {
		if (($ENV{'DEBUG'} || '') =~ m/^(\d+)/) { # untaint
			eval("sub DEBUG () {$1}");
			die "WHAT? Couldn't eval-up a DEBUG constant!? $@" if $@;
		} else {
			*DEBUG = sub () {0};
		}
	}
}

use utf8;
use Encode;
use Pod::Simple::HTML;
use System::Command;

my $app = sub {
	my $env = shift;
	my $css = '/pod2ja.css';

	my $path_info = $env->{PATH_INFO};
	DEBUG and warn "PATH_INFO = $env->{PATH_INFO}\n";

	if ($path_info eq $css) {
		[ 200, [ 'Content-Type'=>'text/css' ], [ &css ], ];
	} else {
		my $p = Pod::Simple::HTML->new;
		$p->output_string(\my $html);

		my $url_scheme = $env->{'psgi.url_scheme'};
		my ($host, $port) = ($env->{SERVER_NAME}, $env->{SERVER_PORT});
		my $script_name = $env->{SCRIPT_NAME};
		DEBUG and warn "SERVER = $url_scheme://$host:$port$script_name\n";
		$p->perldoc_url_prefix('');

		$p->man_url_prefix('/man');
		$p->html_css("$script_name$css");
		$p->no_errata_section(1);
		$p->complain_stderr(1);
		$p->index(1);

		DEBUG and warn "--\n\n";

		$path_info =~ s|^/||;
		local $ENV{LANG} = undef;
		local $ENV{LC_ALL} = undef;
		local $ENV{LC_CTYPE} = "ja_JP.UTF-8";
		my $cmd = System::Command->new(qw(perlfind -L JA -u), $path_info || '-h');
		my ($stdout, $stderr) = ($cmd->stdout, $cmd->stderr);
		binmode $stdout, ":encoding($ENV{LC_CTYPE})";
		my ($out, $err) = (join('', <$stdout>), join('', <$stderr>));
		$cmd->close();
		if ($cmd->exit == 0 && $out) {
			$out =~ /=encoding/ or $out = "=encoding utf8\n\n" . $out;
			$p->parse_string_document($out);
			[ 200, [ 'Content-Type' => 'text/html' ], [ $html ], ];
		} else {
			$err ||= "No documentation found for '$path_info'";
			[ 200, [ 'Content-Type' => 'text/plain' ], [ $err ], ];
		}
	}
};

sub css {
	<< "----";
BODY {
    background: white;
    color: black;
    font-family: times, serif;
    font-size: 10.5pt;
    line-height: 1.6;
    margin: 0;
    padding: 1ex;
}

.pod {
    width: 80%;
    margin: 1ex 10%;
}

.indexgroup {
    float: right;
    width: 30%;
    background-color: #f8f8f8;
    border: solid 1px #d0d0d0;
    border-radius: 5px;
    margin: 1em 0 1em 1em;
    padding: 1ex 1em;
}

.gotoCpan {
    margin: 1ex 1em;
    font-size: 8pt;
}

.searchForm {
    border: solid 1px #d0d0d0;
    border-radius: 5px;
    margin: 1ex;
    padding: 1ex;
    text-align: center;
    white-space: nowrap;
}

.searchInput {
    width: 70%;
}

.searchSubmit {
    vertical-align: 10%;
}

.indexItem1 { margin: 0 0 0 -1.5em; }
.indexItem2 { margin: 0 0 0 -1.5em; }
.indexItem3 { margin: 0 0 0 -1.5em; }

TABLE {
    border-collapse: collapse;
    border-spacing: 0;
    border-width: 0;
    color: inherit;
}

A:link, A:visited {
    background: transparent;
    color: #006699;
}

code, var, samp, kbd, tt {
    font-family: consolas, monospace;
}

/* syntax checking */
code {
    background-color: #f8f8f8;
    border: solid 1px #e8e8e8;
    border-radius: 4px;
    padding: 0.2ex 0.4ex;
    line-height: 1.3;
}

PRE {
    background: #eeeeee;
    border: 1px solid #888888;
    border-radius: 5px;
    color: black;
    font-family: consolas, monospace;
    line-height: 1.3;
    margin: 1em;
    padding: 1em 0;
    white-space: pre;
}

H1 {
    background: transparent;
    color: #006699;
    font-size: x-large;
    font-family: tahoma,sans-serif;
}

H2 {
    background: transparent;
    color: #006699;
    font-size: large;
    font-family: tahoma,sans-serif;
}

.block {
    background: transparent;
}

TD .block {
    color: #006699;
    background: #dddddd;
    padding: 0.2em;
    font-size: large;
}

HR {
    display: none;
}
----
	;
}


$app;
