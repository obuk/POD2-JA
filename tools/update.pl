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

my $DEBUG = $ENV{DEBUG} || 0;
my %pod;

for (
    glob(join(' ', glob "docs/perl/*")),
    glob("docs/modules/*"),
    glob("module-pod-jp/docs/modules/*"),
    ) {
    /\d+(\.\d+)+(?:-RC\d+)?$/ and my $v = $& or next;
    find(sub {
	if (/\.pod$/) {
	    my $name;
	    if (open my $fd, "<", $_) {
		my $head;
		while (<$fd>) {
		    /^=encoding\s+(\S+)/ and binmode $fd, ":encoding($1)";
		    /^=head1\s+(\S+)/ and $head = $1;
		    next unless $head && $head =~ /^(NAME|名前)$/;
		    /(\S+)\s+-+\s+/ and $name = $1, last;
		}
		close $fd;
	    }
	    if ($name) {
		$name =~ s/B<([^>]+)>/$1/;
		$name = lc($name) if $name =~ /^perl/;
	    }
	    if ($name) {
		if ($name =~ /[<>.]/) {
		    warn "skip $name $File::Find::name\n";
		} else {
		    $name =~ s/-/::/g;
		    $pod{$name}{$v} = $File::Find::name;
		}
	    } else {
		warn "can't parse $File::Find::name\n";
	    }
	}}, $_);
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
for my $x (sort keys %pod) {
    my %v; $v{$_} = version($_) for keys %{$pod{$x}};
    my @v = sort { $v{$a} cmp $v{$b} } keys %{$pod{$x}};
    my $s = $pod{$x}{$v[-1]};
    my $d = join('/', $JA, split('::', "$x.pod"));
    copy_pod($s, $d);
    print "$x\t$v[-1]\n" if $x =~ /^perl/ && $v[-1] =~ /^5\./ || $DEBUG;
    if (@v >= 2) {
	if ($DEBUG >= 2) {
	    print "#\t$_\t$v{$_}\t$pod{$x}{$_}\n" for reverse @v;
	} elsif ($DEBUG) {
	    print "#\t$_\t$pod{$x}{$_}\n" for reverse @v;
	}
    }
}

exit 0;

sub version {
    my $v = shift;
    $v =~ s/\.\d{4,}/join('.', substr($&, 0, 3), substr($&, 3))/e;
    $v =~ s/(\d+)([-._])RC(\d+)/($1 > 0? $1 - 1 : '').$2.'999.'.$3/e;
    join('.', map { sprintf "%4s", $_ } split(/[-._]/, $v));
}

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
