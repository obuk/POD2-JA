# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

POD2::JA - Use perldoc -L JA

=head1 SYNOPSIS

    $ perldoc POD2::JA::<podname>

    use POD2::JA;
    print_pods();
    print_pod('pod_foo', 'pod_baz', ...); 

    $ perl -MPOD2::JA -e print_pods
    $ perl -MPOD2::JA -e print_pod <podname1> <podname2> ...

=head1 DESCRIPTION

Enjoy pods in Japanese.


=head1 SEE ALSO

L<POD2::IT>


=head1 AUTHOR

KUBO, Koichi <k@obuk.org>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2014 by KUBO Koichi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.

=cut

package POD2::JA;

use 5.010;
use strict;
use vars qw($VERSION);
$VERSION = '0.17';

use base qw(Exporter);
our @EXPORT = qw(print_pod print_pods new pod_dirs);

my $pods = { };

while (<DATA>) {
	chop;
	my ($name, $version) = split(/\s+/);
	next unless $version;
	$pods->{$name} = $version;
}

close DATA;

sub new {
	return __PACKAGE__;
}

sub pod_dirs {
	( my $mod = __PACKAGE__ . '.pm' ) =~ s|::|/|g;
	( my $dir = $INC{$mod} ) =~ s/\.pm\z//;
	return $dir;
}

sub print_pods {
	print_pod(sort keys %$pods);
}

sub print_pod {
	my @args = @_ ? @_ : @ARGV;

	while (@args) {
		(my $pod = shift @args) =~ s/\.pod$//;
		if ( exists $pods->{$pod} ) {
			print "\t'$pod' translated from Perl $pods->{$pod}\n";
		}
		else {
			print "\t'$pod' doesn't yet exists\n";
		}
	}
}

1;

__DATA__
perl	5.16.1
perl5100delta	5.12.1
perl5101delta	5.12.1
perl5120delta	5.12.1
perl5121delta	5.12.1
perl5122delta	5.12.2
perl5123delta	5.12.3
perl5124delta	5.12.4
perl5125delta	5.12.5
perl5142delta	5.14.2
perl5143delta	5.14.3
perl5144delta	5.14.4
perl5160delta	5.16.0
perl5161delta	5.16.1
perl5162delta	5.16.2
perl5163delta	5.16.3
perl5180delta	5.18.0
perl5181delta	5.18.1
perl5182delta	5.18.2
perl5200delta	5.20.0
perl581delta	5.10.0
perl582delta	5.10.0
perl583delta	5.10.0
perl584delta	5.10.0
perl585delta	5.10.0
perl586delta	5.10.0
perl587delta	5.10.0
perl588delta	5.10.0
perl58delta	5.10.0
perlapi	5.12.1
perlapio	5.18.1
perlbook	5.18.1
perlboot	5.14.1
perlbot	5.14.1
perlcall	5.18.1
perlcheat	5.18.1
perlclib	5.18.1
perlcommunity	5.18.1
perlcompile	5.14.1
perld595elta	5.10.0
perldata	5.18.1
perldbmfilter	5.18.1
perldebtut	5.18.1
perldebug	5.18.1
perldelta	5.14.1
perldiag	5.16.1
perldoc	5.12.1
perldsc	5.18.1
perlembed	5.18.1
perlfaq	5.14.1
perlfaq1	5.14.1
perlfaq2	5.14.1
perlfaq3	5.14.1
perlfaq4	5.14.1
perlfaq5	5.14.1
perlfaq6	5.14.1
perlfaq7	5.14.1
perlfaq8	5.14.1
perlfaq9	5.14.1
perlfilter	5.18.1
perlfork	5.18.1
perlform	5.18.1
perlfunc	5.14.1
perlglossary	5.10.0
perlguts	5.12.1
perlhist	5.18.1
perlintro	5.18.1
perlipc	5.18.1
perllexwarn	5.18.1
perllocale	5.18.1
perllol	5.18.1
perlmod	5.18.1
perlmodlib	5.10.0
perlmodstyle	5.18.1
perlmroapi	5.18.1
perlnewmod	5.18.1
perlnumber	5.18.1
perlobj	5.14.1
perlootut	5.18.1
perlop	5.18.1
perlopentut	5.18.1
perlpacktut	5.18.1
perlperf	5.18.1
perlpod	5.18.1
perlpodspec	5.18.1
perlport	5.18.1
perlpragma	5.18.1
perlre	5.12.1
perlrebackslash	5.18.1
perlrecharclass	5.12.1
perlref	5.18.1
perlreftut	5.18.1
perlrequick	5.18.1
perlreref	5.18.1
perlretut	5.18.1
perlrun	5.16.1
perlsec	5.16.1
perlstyle	5.18.1
perlsub	5.18.1
perlsyn	5.18.1
perlthrtut	5.18.1
perltie	5.18.1
perltooc	5.14.1
perltoot	5.14.1
perltrap	5.18.1
perlunicode	5.10.1
perlunifaq	5.18.1
perluniintro	5.18.1
perlunitut	5.18.1
perlutil	5.18.1
perlvar	5.18.1
perlxs	5.18.1
perlxstut	5.18.1
