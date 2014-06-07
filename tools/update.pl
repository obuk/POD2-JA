#!/usr/bin/perl -i.bak

=head1 NAME

update.pl - updates .pod and JA.pm

=head1 SYNOPSIS

    $ update.pl JA.pm

=cut

use strict;
use warnings;

use Encode;
use File::Find;

my %pod;

while (<docs/perl/*>) {
    /\d+.\d+\.\d+(?:-RC\d)?$/ and my $v = $& or next;
    find(sub { /([^\/]+)\.pod$/ and $pod{$1}{$v} = $File::Find::name}, $_);
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
for my $x (grep /^perl/, sort keys %pod) {
    my $v = (sort { version($a) cmp version($b) } keys %{$pod{$x}})[-1];
    my $s = $pod{$x}{$v}; my @s = split('/', $s);
    my $d = join('/', $JA, join('/', splice(@s, 3)));
    copy_pod($s, $d);
    print "$x\t$v\n";
}

exit 0;

sub version {
    join('.', map { sprintf "%4s", $_ } split(/[-._]/, shift));
}

sub copy_pod {
    my ($s, $d) = @_;
    open(my $dd, '>', $d) or die "$0: can't open '$d'\n";
    open(my $sd, '<', $s) or die "$0: can't open '$s'\n";
    while (<$sd>) {
	chomp;
	s/^(=encoding\s+)(\S+)/${1}utf8/ and binmode($sd, ":encoding($2)");
	print $dd encode_utf8($_), "\n";
    }
}
