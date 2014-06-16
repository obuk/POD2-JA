# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=head1 NAME

man2html/app.psgi - man server

=head1 SYNOPSIS

    $ plackup -a app.psgi

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

my $app = sub {
	my $env = shift;

	my $path_info = $env->{PATH_INFO};
	DEBUG and warn "PATH_INFO = $env->{PATH_INFO}\n";

	my $url_scheme = $env->{'psgi.url_scheme'};
	my ($host, $port) = ($env->{SERVER_NAME}, $env->{SERVER_PORT});
	DEBUG and warn "SERVER = $url_scheme://$host:$port\n";
	DEBUG and warn "--\n\n";

	if ($path_info =~ m{^/man(\d\w*)/(.*)}) {
		my ($section, $topic, $TOPIC) = ($1, $2, uc $2);
		local $ENV{LANG} = 'ja_JP.UTF-8'; my $stderr = "/tmp/man$$.err";
		my @man2html = ('man2html');
		push(@man2html, '--nodepage') if $^O eq 'linux';
		(my $manpage = `man $section $topic 2>$stderr | @man2html -`) =~
			s{<B>([^\(<]+)\((\d[^\)<]*)\)</B>}{<a href="/man$2/$1">$&</a>}g;
		$manpage =~ s{(<a href="/man[^/]*/)$TOPIC(">)}{$1$topic$2}g;
		return [ 200, [ 'Content-Type' => 'text/html' ], [ $manpage ] ]
			unless `cat $stderr && rm $stderr` =~ /^No entry for/;
	}

	[ 200, [ 'Content-Type' => 'text/plain' ], [ "No entry for $path_info" ] ];
};

$app;
