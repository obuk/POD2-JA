# -*- mode: perl -*-

use strict;
use warnings;
use Test::More;
BEGIN { use_ok('POD2::JA', qw(print_pods pod_dirs)) }

use File::Find;
use Encode;

find(\&check_pod_status, grep -d $_, pod_dirs());

sub check_pod_status {
    if (/\.pod$/) {
	for (map /^Status:\s*(\S+)/i, grep /^=begin\s+meta/ ... /^=end\s+meta/,
	     read_file($_, binmode => ':encoding(UTF-8)')) {
	    like($_, qr/^completed?$/, "Status of $File::Find::name");
	}
    }
}

sub read_file {
    my $file = shift; my %o = @_; my @line;
    if (open my $fd, "<:$o{binmode}", $file) {
	@line = <$fd>;
    }
    wantarray? @line : join('', @line);
}

done_testing();


