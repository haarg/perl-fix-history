use Unicode::UCD;

use strict;

BEGIN {
    if (ord("A") == 193) {
	print "1..0 # Skip: EBCDIC\n";
	exit 0;
    }
}

use Test;

BEGIN { plan tests => 162 };

use Unicode::UCD 'charinfo';

my $charinfo;

$charinfo = charinfo(0x41);

ok($charinfo->{code},           '0041');
ok($charinfo->{name},           'LATIN CAPITAL LETTER A');
ok($charinfo->{category},       'Lu');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'L');
ok($charinfo->{decomposition},  '');
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      '');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '0061');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Basic Latin');
ok($charinfo->{script},         'Latin');

$charinfo = charinfo(0x100);

ok($charinfo->{code},           '0100');
ok($charinfo->{name},           'LATIN CAPITAL LETTER A WITH MACRON');
ok($charinfo->{category},       'Lu');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'L');
ok($charinfo->{decomposition},  '0041 0304');
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      'LATIN CAPITAL LETTER A MACRON');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '0101');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Latin Extended-A');
ok($charinfo->{script},         'Latin');

# 0x0590 is in the Hebrew block but unused.

$charinfo = charinfo(0x590);

ok($charinfo->{code},          undef);
ok($charinfo->{name},          undef);
ok($charinfo->{category},      undef);
ok($charinfo->{combining},     undef);
ok($charinfo->{bidi},          undef);
ok($charinfo->{decomposition}, undef);
ok($charinfo->{decimal},       undef);
ok($charinfo->{digit},         undef);
ok($charinfo->{numeric},       undef);
ok($charinfo->{mirrored},      undef);
ok($charinfo->{unicode10},     undef);
ok($charinfo->{comment},       undef);
ok($charinfo->{upper},         undef);
ok($charinfo->{lower},         undef);
ok($charinfo->{title},         undef);
ok($charinfo->{block},         undef);
ok($charinfo->{script},        undef);

# 0x05d0 is in the Hebrew block and used.

$charinfo = charinfo(0x5d0);

ok($charinfo->{code},           '05D0');
ok($charinfo->{name},           'HEBREW LETTER ALEF');
ok($charinfo->{category},       'Lo');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'R');
ok($charinfo->{decomposition},  '');
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      '');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Hebrew');
ok($charinfo->{script},         'Hebrew');

# An open syllable in Hangul.

$charinfo = charinfo(0xAC00);

ok($charinfo->{code},           'AC00');
ok($charinfo->{name},           'HANGUL SYLLABLE-AC00');
ok($charinfo->{category},       'Lo');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'L');
ok($charinfo->{decomposition},  undef);
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      '');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Hangul Syllables');
ok($charinfo->{script},         'Hangul');

# A closed syllable in Hangul.

$charinfo = charinfo(0xAE00);

ok($charinfo->{code},           'AE00');
ok($charinfo->{name},           'HANGUL SYLLABLE-AE00');
ok($charinfo->{category},       'Lo');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'L');
ok($charinfo->{decomposition},  undef);
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      '');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Hangul Syllables');
ok($charinfo->{script},         'Hangul');

$charinfo = charinfo(0x1D400);

ok($charinfo->{code},           '1D400');
ok($charinfo->{name},           'MATHEMATICAL BOLD CAPITAL A');
ok($charinfo->{category},       'Lu');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'L');
ok($charinfo->{decomposition},  '<font> 0041');
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      '');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Mathematical Alphanumeric Symbols');
ok($charinfo->{script},         undef);

use Unicode::UCD qw(charblock charscript);

# 0x0590 is in the Hebrew block but unused.

ok(charblock(0x590),          'Hebrew');
ok(charscript(0x590),         undef);

$charinfo = charinfo(0xbe);

ok($charinfo->{code},           '00BE');
ok($charinfo->{name},           'VULGAR FRACTION THREE QUARTERS');
ok($charinfo->{category},       'No');
ok($charinfo->{combining},      '0');
ok($charinfo->{bidi},           'ON');
ok($charinfo->{decomposition},  '<fraction> 0033 2044 0034');
ok($charinfo->{decimal},        '');
ok($charinfo->{digit},          '');
ok($charinfo->{numeric},        '3/4');
ok($charinfo->{mirrored},       'N');
ok($charinfo->{unicode10},      'FRACTION THREE QUARTERS');
ok($charinfo->{comment},        '');
ok($charinfo->{upper},          '');
ok($charinfo->{lower},          '');
ok($charinfo->{title},          '');
ok($charinfo->{block},          'Latin-1 Supplement');
ok($charinfo->{script},         undef);

use Unicode::UCD qw(charblocks charscripts);

my $charblocks = charblocks();

ok(exists $charblocks->{Thai});
ok($charblocks->{Thai}->[0]->[0], hex('0e00'));
ok(!exists $charblocks->{PigLatin});

my $charscripts = charscripts();

ok(exists $charscripts->{Armenian});
ok($charscripts->{Armenian}->[0]->[0], hex('0531'));
ok(!exists $charscripts->{PigLatin});

my $charscript;

$charscript = charscript("12ab");
ok($charscript, 'Ethiopic');

$charscript = charscript("0x12ab");
ok($charscript, 'Ethiopic');

$charscript = charscript("U+12ab");
ok($charscript, 'Ethiopic');

my $ranges;

$ranges = charscript('Ogham');
ok($ranges->[0]->[0], hex('1681'));
ok($ranges->[0]->[1], hex('169a'));

use Unicode::UCD qw(charinrange);

$ranges = charscript('Cherokee');
ok(!charinrange($ranges, "139f"));
ok( charinrange($ranges, "13a0"));
ok( charinrange($ranges, "13f4"));
ok(!charinrange($ranges, "13f5"));

ok(Unicode::UCD::UnicodeVersion, '3.1.1');

use Unicode::UCD qw(compexcl);

ok(!compexcl(0x0100));
ok( compexcl(0x0958));

use Unicode::UCD qw(casefold);

my $casefold;

$casefold = casefold(0x41);

ok($casefold->{code} eq '0041' &&
   $casefold->{status} eq 'C'  &&
   $casefold->{mapping} eq '0061');

$casefold = casefold(0xdf);

ok($casefold->{code} eq '00DF' &&
   $casefold->{status} eq 'F'  &&
   $casefold->{mapping} eq '0073 0073');

ok(!casefold(0x20));

use Unicode::UCD qw(casespec);

my $casespec;

ok(!casespec(0x41));

$casespec = casespec(0xdf);

ok($casespec->{code} eq '00DF' &&
   $casespec->{lower} eq '00DF'  &&
   $casespec->{title} eq '0053 0073'  &&
   $casespec->{upper} eq '0053 0053' &&
   $casespec->{condition} eq undef);

$casespec = casespec(0x307);

ok($casespec->{az}->{code} eq '0307' &&
   $casespec->{az}->{lower} eq ''  &&
   $casespec->{az}->{title} eq '0307'  &&
   $casespec->{az}->{upper} eq '0307' &&
   $casespec->{az}->{condition} eq 'az AFTER_i NOT_MORE_ABOVE');
