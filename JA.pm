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

to borrow the formatter from L<Pod::PerldocJp>.

    $ export PERLDOC='-L ja -M Pod::PerldocJp::ToText'
    $ perldoc perldoc
    $ perldoc perldocjp

you can get along with other programs (e.g. L<cpandoc|Pod::Cpandoc>,
L<perlfind|App::perlfind>)

=head1 DESCRIPTION

Enjoy pods in Japanese.


=head1 SEE ALSO

L<POD2::IT>

L<Pod::PerldocJp>


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
our $VERSION = '0.19';

use Exporter;
our @EXPORT_OK = qw(print_pod print_pods search_perlfunc_re new pod_dirs);

use File::Spec ();
use POD2::Base;
our @ISA = qw( Exporter POD2::Base );
our $RE_VERSION = qr/\d+\.\d+(?:[._-]\d+)*$/;

my $pods = { };

{
	my $version = version->parse($]);
	while (<DATA>) {
		chop;
		my ($name, @version) = split /\s+/;
		next unless @version = grep version->parse($_) <= $version, @version;
		$pods->{$name} = $version[0];
	}
	close DATA;
}

my $pod2ja;

sub new {
	my $class = @_ && (ref $_[0] || $_[0] eq __PACKAGE__)?
		shift : __PACKAGE__;
	my $self = $class->SUPER::new(@_);
	unless ($self->{inc}) {
		if (my @inc = split(':', $ENV{POD2JA_SEARCH_DIRS} || '')) {
			s/^~/$ENV{HOME}/ for @inc;
			$self->{inc} = \@inc;
		}
	}
	$pod2ja = $self;
}

sub _new {
	$pod2ja ||= __PACKAGE__->new;
}

sub pod_dirs {
	my $self = shift || _new();
    my @candidates = $self->SUPER::pod_dirs(@_);
	unless (@candidates) {
		@candidates = map {
			grep /$RE_VERSION/, glob File::Spec->catdir($_, '*')
		} $self->_lib_dirs;
	}
	( my $mod = __PACKAGE__ . '.pm' ) =~ s|::|/|g;
	( my $dir = $INC{$mod} ) =~ s/\.pm\z//;
	push @candidates, $dir;
	wantarray? @candidates : $candidates[0];
}

sub search_perlfunc_re { # makes 'perldoc -f' work
	return 'Alphabetical Listing of Perl Functions';
}

sub pod_info {
	$pods;
}

sub print_pods {
	(shift || _new())->SUPER::print_pods(@_);
}

sub print_pod {
	(shift || _new())->SUPER::print_pod(@_);
}

1;

__DATA__
