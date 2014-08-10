# -*- mode: perl -*-

use ExtUtils::MakeMaker;

my $perldocjp = ':pserver:anonymous@cvs.sourceforge.jp:/cvsroot/perldocjp';
my $docs = 'docs';

-d $docs or system('cvs', '-d', $perldocjp, 'co', $docs);
system(qw(perl -i.bak ./tools/update.pl JA.pm));

WriteMakefile(
    NAME          => 'POD2::JA',
    VERSION_FROM  => 'JA.pm',
    ABSTRACT_FROM => 'JA.pm',
    AUTHOR        => '<k@obuk.org>',
    clean         => { FILES => "cover_db JA" },
    );
