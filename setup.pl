#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use File::Spec::Functions;

for my $infile (@ARGV) {
  open my $in, "<", $infile;
  my $basename = basename($infile, '.pod');
  if ($basename eq 'perldelta') {
    my @v = $infile =~ /\b(5)\.(\d+)\.(\d+)\b/;
    $basename = "perl$v[0]$v[1]$v[2]delta";
  }
  my $outfile = "JA/$basename.pod";
  open my $out, ">:encoding(UTF-8)", $outfile;
  while (<$in>) {
    binmode $in, ":encoding($2)" if s/^(=encoding)\s+(\S+)/$1 utf8/;
    if (/^=head1 +NAME/ ... /^=head1 +DESCRIPTION/) {
      s/\b(perldelta|perlxstut)\b/$basename/gi;
    }
    print $out $_;
  }
  close $out;
  close $in;
}

