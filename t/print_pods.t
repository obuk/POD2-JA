# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More tests => 237;
BEGIN { use_ok('POD2::JA', qw(print_pods)) }
use File::Basename;

my $t = dirname($0);
my %pod;

{
	local *STDOUT;
	my $tmp = "$t/../test.tmp";
	open(STDOUT, ">$tmp");
	print_pods();
	close(STDOUT);
	open(FILE, "<$tmp");
	while (<FILE>) {
		/^\s+'(\w+)' translated from Perl (\S+)/;
		$pod{$1} = $2;
	}
	close(FILE);
	unlink($tmp);
}

for (keys %pod) {
	ok(-f "$t/../JA/$_.pod", "-f $_.pod");
}

for (map { (split('/'))[-1] } glob("$t/../JA/*.pod")) {
	/\w+/;
	my $f = $&;
	ok($pod{$f}, "print_pod($f)");
}

