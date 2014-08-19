# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More;
BEGIN {	use_ok('POD2::JA', qw(pod_dirs)) }
use File::Find;
use File::Spec::Functions;

{
	local $ENV{POD2JA_SEARCH_DIRS} = catdir qw(jprp-docs perl);
	my $tr = POD2::JA->new;
	my @dir = $tr->pod_dirs();
	cmp_ok(scalar @dir, '>=', 1) || diag explain [@dir];
	my %x; find sub { $x{$File::Find::dir}++ if /^perl.*\.pod$/ },
	grep -d $_, @dir;
	ok(scalar (grep /$ENV{POD2JA_SEARCH_DIRS}/, keys %x) > 0);
}

{
	local $ENV{POD2JA_SEARCH_DIRS};
	my $tr = POD2::JA->new;
	my @dir = $tr->pod_dirs();
	cmp_ok(scalar @dir, '>=', 1) || diag explain [@dir];
}

done_testing();
