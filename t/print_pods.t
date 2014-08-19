# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More;

our $POD2_SEARCH_DIRS;

BEGIN {
	$POD2_SEARCH_DIRS = $ENV{POD2JA_SEARCH_DIRS};
	delete $ENV{POD2JA_SEARCH_DIRS};
	use_ok('POD2::JA', qw(print_pods pod_dirs))
}

use IO::File;
use File::Spec::Functions;

my $dir = pod_dirs();
ok($dir);
unless ($POD2_SEARCH_DIRS) {
	ok(-d $dir, "-d $dir");
}

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

unless ($POD2_SEARCH_DIRS) {
	for (keys %pod) {
		my $f = catfile(split '::' );
		ok(-f catfile($dir, "$f.pod"), "-f $dir/$f.pod");
	}
}

done_testing();
