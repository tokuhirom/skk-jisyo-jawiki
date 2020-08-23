use strict;
use warnings;
use utf8;

use Test::Base::Less;
use Test::More;
use YAML;

use W;

binmode( STDOUT, ":utf8" );
binmode( STDERR, ":utf8" );

filters {
    expected => [qw/eval/],
};

for my $block (blocks) {
    my $got = W::parse_page($block->input);
    note Dump($got, $block->expected);
    is_deeply($got, $block->expected);
}

done_testing;
     
__DATA__
     
===
--- input
<title>Intel 4004</title>
'''4004'''（よんまるまるよん、と読まれることが多い）は、[[アメリカ合衆国|米国]][[インテル|インテル社]]によって開発された1チップの[[マイクロプロセッサ]]であり、軍用の[[セントラル・エア・デー タ・コンピュータ|MP944]]&lt;ref&gt;[[F-14 (戦闘機)|F-14戦闘機]]用[[セントラル・エア・データ・コンピュータ|Central Air Data Computer]]&lt;/ref&gt;、組み込み用のTI製[[TMS-1000]]等とほぼ同時期 の、世界最初期のマイクロプロセッサのひとつである。周辺ファミリ[[集積回路|IC]]を含めてMCS-4 Micro Computer Set、あるいは略し単にMCS-4とも呼ぶ。
--- expected
[ ]

===
--- input
<title>w3m</title>
'''w3m'''（ダブリューサンエム または ダブリュースリーエム）は
--- expected
[
]

===
--- input
<title>三科</title>
:* '''{{linktext|六根}}'''（ろっこん、{{lang-sa-short|ṣaḍ-indriya}}） - 主観の側の六種の器官{{sfn|櫻部・上山|2006|p=60}}、感官{{sfn|村上|2010|p=233}}のこと。'''{{linktext|六内入処}}'''（ろくないにゅうしょ）とも。
--- expected
[
    ['三科', '六根', 'ろっこん'],
    ['三科', '六内入処', 'ろくないにゅうしょ'],
]

===
--- input
<title>少年画報社</title>
'''株式会社少年画報社'''（しょうねんがほうしゃ、英語表記：Shonen-gahosha Co., Ltd.）は、主に[[漫画]]を出版している[[日本]]の[[出版社]]。
--- expected
[
    ['少年画報社', '少年画報社', 'しょうねんがほうしゃ'],
]
