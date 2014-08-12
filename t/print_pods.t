# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More;
BEGIN { use_ok('POD2::JA', qw(print_pods pod_dirs)) }
use IO::File;
use File::Basename;

my $dir = pod_dirs();
ok(-d $dir, "-d $dir");

my %pod;

my @unexpected;

{
	local *STDOUT = IO::File->new_tmpfile;
	print_pods();
	seek STDOUT, 0, 0;
	while (<STDOUT>) {
		if (/^\s+'(\S+)' translated from Perl (\S+)$/) {
			$pod{$1} = $2;
		} elsif (/^\s+'(\S+)' doesn\'t yet exists$/) {
			;
		} else {
			push(@unexpected, $_);
		}
	}
}

ok(@unexpected == 0);

for (keys %pod) {
	(my $f = $_) =~ s/::/\//g;
	ok(-f "$dir/$f.pod", "-f $dir/$f.pod");
}

diag($_) for (grep { !($pod{$_} && $pod{$_} =~ /^v?5\./) }
			  map basename($_, '.pod'), glob "$dir/perl*.pod");

done_testing();
