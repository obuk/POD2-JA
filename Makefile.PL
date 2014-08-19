# -*- mode: perl -*-

use 5.010;
use ExtUtils::MakeMaker;
use File::Spec::Functions;
use File::Path qw(make_path);

my $perldocjp = ':pserver:anonymous@cvs.sourceforge.jp:/cvsroot/perldocjp';
my $docs = 'jprp-docs';
# export POD2JA_SEARCH_DIRS=~/perl5/pod/POD2/JA
-d $docs or system('cvs', '-d', $perldocjp, 'co', $docs);

system(qw(perl -i.bak ./tools/update.pl), "JA.pm");

WriteMakefile(
    NAME          => 'POD2::JA',
    VERSION_FROM  => 'JA.pm',
    ABSTRACT_FROM => 'JA.pm',
    AUTHOR        => '<k@obuk.org>',
    clean         => { FILES => "cover_db JA" },
    );
