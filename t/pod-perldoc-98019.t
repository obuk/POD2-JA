# -*- mode: perl -*-

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(utf8)';
use Test::More;
BEGIN { use_ok('POD2::JA') }

#  perldoc -L JA -u -f 'scalar'    # ok
#  perldoc -L JA -u -a 'SvPV'      # ok
#  perldoc -L JA -u -v '$_'        # not ok
#  perldoc -L JA -u -f 'qq'        # not ok
#  perldoc -L JA -u -q 'perl'      # not ok

for my $t (
    { run => [ qw(perldoc -L ja -u -f scalar) ],
      expected => qr/EXPR を強制的にスカラコンテキストで解釈/ },
    { run => [ qw(perldoc -L ja -u -a SvPV) ],
      expected => qr/SV の文字列化形式を返します。/ },
    { run => [ qw(perldoc -L ja -u -v $_) ],
      expected => qr/デフォルトの入力とパターン検索のスペース/ },
    { run => [ qw(perldoc -L ja -u -f qq) ],
      expected => qr/ダブルクォートされた、リテラル文字列です/ },
    { run => [ qw(perldoc -L ja -u -q perl) ],
      expected => qr/Perl は Larry Wall と数多い協力者によって/ },
    ) {
    open my $fd, "-|:encoding(utf8)", @{$t->{run}};
    my @match = grep(/$t->{expected}/, <$fd>);
    ok(@match + 0, "@{$t->{run}}");
}

done_testing();


