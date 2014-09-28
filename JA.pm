# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

POD2::JA - Use perldoc -L JA

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

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
our $VERSION = '0.20';

use POD2::Plus;
our @ISA = qw(POD2::Plus);

sub search_perlfunc_re {
	return 'Alphabetical Listing of Perl Functions';
}

1;

__END__
