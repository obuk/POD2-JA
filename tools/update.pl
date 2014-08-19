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
use File::Spec::Functions;
use File::Path qw(make_path);
use version;

BEGIN {
    my $debug = $ENV{DEBUG} || 0;
    eval "sub DEBUG { $debug }";
}

use Getopt::Long qw(:config no_ignore_case);
use File::Spec::Functions;

my $pod2ja_default_dir = 'JA';
my %search_dir = ();
my @pod_dir = ();

my $perl_default_dir = catdir qw(jprp-docs perl);
my $modules_default_dir = catdir qw(jprp-docs modules);

GetOptions(
    "perl-dir=s" => \%search_dir,
    "module-dir=s" => \@pod_dir,
    ) or die <<"----";
usage: $0 --perl-dir $perl_default_dir=~/perl5/pod/POD2/POD2/JA
    --module-dir=$modules_default_dir
----
    ;

unless (@pod_dir || %search_dir) {
    if (my $dir = $ENV{POD2JA_SEARCH_DIRS}) {
	%search_dir = ($perl_default_dir => $dir);
    } else {
	push @pod_dir, $perl_default_dir;
    }
    # push @pod_dir, $modules_default_dir;
}

my %name_fixes = (perlXStut => 'perlxstut');
my $re_version = qr/\d+\.\d+(?:[._-]\d+)*$/;
my %version;
my %pod;

if (@ARGV) {
    while (<>) {
	/__DATA__/ and last;
	print;
    }
    print "__DATA__\n";
}

# mkdirhier($pod2ja_default_dir);
for my $find_dir (keys %search_dir) {
    setup_pod(find_dir => $find_dir, pod_dir => $search_dir{$find_dir},
	      search_dir => 1);
}

setup_pod(find_dir => $_) for @pod_dir;

exit 0;

sub setup_pod {
    my %cf = @_; %pod = ();
    (my $JA = $cf{pod_dir} || $pod2ja_default_dir) =~ s/^~/$ENV{HOME}/;
    # warn $cf{find_dir}, "\n";
    find({ wanted => \&check_pod, no_chdir => 1 },
	 map { glob catdir($_, '*') } $cf{find_dir});
    # -d $JA or mkdir $JA;
    for my $name (sort keys %pod) {
	my %v = %{$pod{$name}};
	my @v;
	if ($cf{search_dir}) {
	    while (my ($s, $v) = each %v) {
		my $d = catfile $JA, $v->stringify, split('::', "$name.pod");
		copy_pod($s, $d);
	    }
	    @v = sort { $b <=> $a } values %v;
	} else {
	    my ($path) = sort { $v{$b} <=> $v{$a} } keys %v;
	    copy_pod($path, catfile $JA, split('::', "$name.pod"));
	    @v = ($v{$path});
	}
	if ($name =~ /^perl/ && $v[0]->normal =~ /^v5\./) {
	    print join("\t", $name, map $_->stringify, @v), "\n";
	}
    }
}

sub check_pod {
    return unless /\.pod$/;
    my ($file, $topdir) = ($_, $File::Find::topdir);
    my ($name, $status) = get_pod_name_status($file);
    my $v = $version{$topdir} ||= version->parse($topdir =~ /($re_version)/);
    if ($file =~ /\/perl/ && $v && $v->normal =~ /^v5\.\d*[13579]\./) {
	$status = 'odd';
    }
    if ($status && $status !~ /complete/) {
	DEBUG and warn "ignore $file; status is $status\n";
    } elsif ($name) {
	$pod{$name}{$file} = $v if $v;
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

sub copy_pod {
    my ($s, $d) = @_;
    my $dir = dirname $d;
    -d $dir or make_path($dir);
    open(my $dd, '>', $d) or die "$0: can't open '$d'\n";
    open(my $sd, '<', $s) or die "$0: can't open '$s'\n";
    while (<$sd>) {
	chomp;
	s/^(=encoding\s+)(\S+)/${1}utf8/ and binmode($sd, ":encoding($2)");
	print $dd encode_utf8($_), "\n";
    }
}
