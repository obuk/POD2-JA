#!/usr/bin/perl -i.bak

=head1 NAME

update.pl - updates .pod and JA.pm

=head1 SYNOPSIS

    $ update.pl JA.pm

=cut

use strict;
use warnings;

use utf8;
use Encode;
use File::Find;
use File::Basename;
use version;

BEGIN {
    my $debug = $ENV{DEBUG} || 0;
    eval "sub DEBUG { $debug }";
}

my %name_fixes = (perlXStut => 'perlxstut');
my $re_version = qr/\d+\.\d+(?:[._-]\d+)*$/;
my %version;
my %pod;

my @search_dir = split /:/, "docs/perl/*:docs/modules/*";
push @search_dir, split /:/, $ENV{POD2JA_SEARCH_DIRS} || '';

find({ wanted => \&pod_to_put_pod2ja, no_chdir => 1 },
     map { glob $_ } @search_dir);

sub pod_to_put_pod2ja {
    return unless /\.pod$/;
    my ($file, $topdir) = ($_, $File::Find::topdir);
    my ($name, $status) = get_pod_name_status($file);
    my $v = $version{$topdir} ||=
	version->parse($topdir =~ /($re_version)/) ||
	version->parse("0.0");
    if ($file =~ /\/perl/ && $v->normal =~ /^v5\.\d*[13579]\./) {
	$status = 'odd';
    }
    if ($status && $status !~ /complete/) {
	DEBUG and warn "ignore $file; status is $status\n";
    } elsif ($name) {
	$pod{$name}{$file} = $v;
    } else {
	DEBUG and warn "can't get NAME $file\n";
    }
}

sub get_pod_name_status {
    my $file = shift; my ($name, $status); my $head; 
    if (open my $fd, "<", $file) {
	while (<$fd>) {
	    /^=encoding\s+(\S+)/ and binmode($fd, ":encoding($1)");
	    if (/^=head\d\s+(\S+)/) {
		$head = $1 =~ /^(NAME|名前)$/;
	    } elsif ($head && /^(\S+)\s+-+\s+/) {
		(my $x = $1) =~ s/[BC]<([^>]+)>/$1/g; # XXXXX
		if ($x =~ /^[a-zA-Z]\w*((::|-)[a-zA-Z]\w*)*$/) {
		    $name = $name_fixes{$x} || $x;
		} else {
		    DEBUG and warn "skip $x at $file line $..\n";
		}
	    }
	    if (/^=begin\s+meta/ ... /^=end\s+meta/) {
		$status = $1 if /^Status:\s*(\S+)/i;
	    }
	}
    }
    ($name, $status);
}

if (@ARGV) {
    while (<>) {
	/__DATA__/ and last;
	print;
    }
    print "__DATA__\n";
}

my $JA = 'JA';
-d $JA or mkdir $JA;
for my $name (sort keys %pod) {
    my %v = %{$pod{$name}};
    my ($path) = sort { $v{$b} <=> $v{$a} } keys %v;
    copy_pod($path, join('/', $JA, split('::', "$name.pod")));
    if ($name =~ /^perl/ && $v{$path}->normal =~ /^v5\./) {
	# print join("\t", $name, $v{$path}->normal), "\n";
	print join("\t", $name, $v{$path}->stringify), "\n";
    }
}

exit 0;

sub copy_pod {
    my ($s, $d) = @_;
    my $dir = dirname $d;
    -d $dir or mkdirhier($dir);
    open(my $dd, '>', $d) or die "$0: can't open '$d'\n";
    open(my $sd, '<', $s) or die "$0: can't open '$s'\n";
    while (<$sd>) {
	chomp;
	s/^(=encoding\s+)(\S+)/${1}utf8/ and binmode($sd, ":encoding($2)");
	print $dd encode_utf8($_), "\n";
    }
}

sub mkdirhier {
    for (@_) {
	my $dir;
	for (split '/') {
	    $dir .= $_;
	    -d $dir or mkdir $dir;
	    $dir .= '/';
	}
    }
}
