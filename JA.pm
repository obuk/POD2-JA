# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

POD2::JA - Japanese translation of Perl core documentation

=head1 SYNOPSIS

=head1 AUTHOR

KUBO, Koichi <k@obuk.org>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2014 by KUBO Koichi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.

=cut

package POD2::JA;

use 5.006;
use strict;
our $VERSION = '0.22';

use POD2::Base;
our @ISA = qw(POD2::Base);

sub search_perlfunc_re {
	return 'Alphabetical Listing of Perl Functions';
}

1;
