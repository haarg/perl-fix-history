#!perl

use strict;
use warnings;

use Test::More tests => 4957;

my $class;

BEGIN {
    $class = 'Math::BigRat';
    use_ok($class);
}

while (<DATA>) {
    s/#.*$//;                   # remove comments
    s/\s+$//;                   # remove trailing whitespace
    next unless length;         # skip empty lines

    my ($nval, $kval, $nokval) = split /:/;
    my ($n, $k, $got, @got);

    for my $context_is_scalar (0, 1) {
        for my $k_is_scalar (0, 1) {

            my $test = qq|\$n = $class -> new("$nval");|;

            $test .= $k_is_scalar
                     ? qq| \$k = "$kval";|
                     : qq| \$k = $class -> new("$kval");|;

            $test .= $context_is_scalar
                     ? qq| \$got = \$n -> bnok(\$k);|
                     : qq| \@got = \$n -> bnok(\$k);|;

            my $desc = "bnok() in ";
            $desc .= $context_is_scalar ? "scalar context" : "list context";
            $desc .= $k_is_scalar ? " with k as scalar" : " with k as object";

            subtest $desc,
              sub {
                  plan tests => $context_is_scalar ? 7 : 8;

                  eval $test;
                  is($@, "", "'$test' gives emtpy \$\@");

                  if ($context_is_scalar) {

                      # Check output.

                      is(ref($got), $class,
                         "'$test' output arg is a $class");

                      is($got -> bstr(), $nokval,
                         "'$test' output arg has the right value");

                  } else {

                      # Check number of output arguments.

                      cmp_ok(scalar @got, '==', 1,
                             "'$test' gives one output arg");

                      # Check output.

                      is(ref($got[0]), $class,
                         "'$test' output arg is a $class");

                      is($got[0] -> bstr(), $nokval,
                         "'$test' output arg has the right value");
                  }

                  # Check the invocand.

                  is(ref($n), $class,
                     "'$test' invocand is still a $class");

                  is($n -> bstr(), $nokval,
                     "'$test' invocand has the right value");

                  # Check the input argument.

                  if ($k_is_scalar) {

                      is(ref($k), '',
                         "'$test' second input arg is still a scalar");

                      is($k, $kval,
                         "'$test' second input arg is unmodified");

                  } else {

                      is(ref($k), $class,
                         "'$test' second input arg is still a $class");

                      is($k -> bstr(), $kval,
                         "'$test' second input arg is unmodified");
                  }
              };
        }
    }
}

__DATA__

# n and/or k is NaN

NaN:NaN:NaN
NaN:0:NaN
NaN:3:NaN
3:NaN:NaN
NaN:-3:NaN
-3:NaN:NaN

# n = inf

inf:-inf:NaN
inf:-3:0
inf:-2:0
inf:-1:0
inf:0:1
inf:1:inf
inf:2:inf
inf:3:inf
inf:inf:NaN

# n = -inf

-inf:-inf:NaN
-inf:-3:0
-inf:-2:0
-inf:-1:0
-inf:0:1
-inf:1:-inf
-inf:2:inf
-inf:3:-inf
-inf:inf:NaN

# k = inf

-3:inf:NaN
-2:inf:NaN
-1:inf:NaN
0:inf:NaN
1:inf:NaN
2:inf:NaN
3:inf:NaN

# k = -inf

-3:-inf:NaN
-2:-inf:NaN
-1:-inf:NaN
0:-inf:NaN
1:-inf:NaN
2:-inf:NaN
3:-inf:NaN

# n = -15, k = n - 15 ... n + 15

-15:-30:-77558760
-15:-29:40116600
-15:-28:-20058300
-15:-27:9657700
-15:-26:-4457400
-15:-25:1961256
-15:-24:-817190
-15:-23:319770
-15:-22:-116280
-15:-21:38760
-15:-20:-11628
-15:-19:3060
-15:-18:-680
-15:-17:120
-15:-16:-15
-15:-15:1
-15:-14:0
-15:-13:0
-15:-12:0
-15:-11:0
-15:-10:0
-15:-9:0
-15:-8:0
-15:-7:0
-15:-6:0
-15:-5:0
-15:-4:0
-15:-3:0
-15:-2:0
-15:-1:0
-15:0:1
-15:1:-15
-15:2:120
-15:3:-680
-15:4:3060
-15:5:-11628
-15:6:38760
-15:7:-116280
-15:8:319770
-15:9:-817190
-15:10:1961256
-15:11:-4457400
-15:12:9657700
-15:13:-20058300
-15:14:40116600
-15:15:-77558760

# n = -14, k = n - 15 ... n + 15

-14:-29:-37442160
-14:-28:20058300
-14:-27:-10400600
-14:-26:5200300
-14:-25:-2496144
-14:-24:1144066
-14:-23:-497420
-14:-22:203490
-14:-21:-77520
-14:-20:27132
-14:-19:-8568
-14:-18:2380
-14:-17:-560
-14:-16:105
-14:-15:-14
-14:-14:1
-14:-13:0
-14:-12:0
-14:-11:0
-14:-10:0
-14:-9:0
-14:-8:0
-14:-7:0
-14:-6:0
-14:-5:0
-14:-4:0
-14:-3:0
-14:-2:0
-14:-1:0
-14:0:1
-14:1:-14
-14:2:105
-14:3:-560
-14:4:2380
-14:5:-8568
-14:6:27132
-14:7:-77520
-14:8:203490
-14:9:-497420
-14:10:1144066
-14:11:-2496144
-14:12:5200300
-14:13:-10400600
-14:14:20058300
-14:15:-37442160

# n = -13, k = n - 15 ... n + 15

-13:-28:-17383860
-13:-27:9657700
-13:-26:-5200300
-13:-25:2704156
-13:-24:-1352078
-13:-23:646646
-13:-22:-293930
-13:-21:125970
-13:-20:-50388
-13:-19:18564
-13:-18:-6188
-13:-17:1820
-13:-16:-455
-13:-15:91
-13:-14:-13
-13:-13:1
-13:-12:0
-13:-11:0
-13:-10:0
-13:-9:0
-13:-8:0
-13:-7:0
-13:-6:0
-13:-5:0
-13:-4:0
-13:-3:0
-13:-2:0
-13:-1:0
-13:0:1
-13:1:-13
-13:2:91
-13:3:-455
-13:4:1820
-13:5:-6188
-13:6:18564
-13:7:-50388
-13:8:125970
-13:9:-293930
-13:10:646646
-13:11:-1352078
-13:12:2704156
-13:13:-5200300
-13:14:9657700
-13:15:-17383860

# n = -12, k = n - 15 ... n + 15

-12:-27:-7726160
-12:-26:4457400
-12:-25:-2496144
-12:-24:1352078
-12:-23:-705432
-12:-22:352716
-12:-21:-167960
-12:-20:75582
-12:-19:-31824
-12:-18:12376
-12:-17:-4368
-12:-16:1365
-12:-15:-364
-12:-14:78
-12:-13:-12
-12:-12:1
-12:-11:0
-12:-10:0
-12:-9:0
-12:-8:0
-12:-7:0
-12:-6:0
-12:-5:0
-12:-4:0
-12:-3:0
-12:-2:0
-12:-1:0
-12:0:1
-12:1:-12
-12:2:78
-12:3:-364
-12:4:1365
-12:5:-4368
-12:6:12376
-12:7:-31824
-12:8:75582
-12:9:-167960
-12:10:352716
-12:11:-705432
-12:12:1352078
-12:13:-2496144
-12:14:4457400
-12:15:-7726160

# n = -11, k = n - 15 ... n + 15

-11:-26:-3268760
-11:-25:1961256
-11:-24:-1144066
-11:-23:646646
-11:-22:-352716
-11:-21:184756
-11:-20:-92378
-11:-19:43758
-11:-18:-19448
-11:-17:8008
-11:-16:-3003
-11:-15:1001
-11:-14:-286
-11:-13:66
-11:-12:-11
-11:-11:1
-11:-10:0
-11:-9:0
-11:-8:0
-11:-7:0
-11:-6:0
-11:-5:0
-11:-4:0
-11:-3:0
-11:-2:0
-11:-1:0
-11:0:1
-11:1:-11
-11:2:66
-11:3:-286
-11:4:1001
-11:5:-3003
-11:6:8008
-11:7:-19448
-11:8:43758
-11:9:-92378
-11:10:184756
-11:11:-352716
-11:12:646646
-11:13:-1144066
-11:14:1961256
-11:15:-3268760

# n = -10, k = n - 15 ... n + 15

-10:-25:-1307504
-10:-24:817190
-10:-23:-497420
-10:-22:293930
-10:-21:-167960
-10:-20:92378
-10:-19:-48620
-10:-18:24310
-10:-17:-11440
-10:-16:5005
-10:-15:-2002
-10:-14:715
-10:-13:-220
-10:-12:55
-10:-11:-10
-10:-10:1
-10:-9:0
-10:-8:0
-10:-7:0
-10:-6:0
-10:-5:0
-10:-4:0
-10:-3:0
-10:-2:0
-10:-1:0
-10:0:1
-10:1:-10
-10:2:55
-10:3:-220
-10:4:715
-10:5:-2002
-10:6:5005
-10:7:-11440
-10:8:24310
-10:9:-48620
-10:10:92378
-10:11:-167960
-10:12:293930
-10:13:-497420
-10:14:817190
-10:15:-1307504

# n = -9, k = n - 15 ... n + 15

-9:-24:-490314
-9:-23:319770
-9:-22:-203490
-9:-21:125970
-9:-20:-75582
-9:-19:43758
-9:-18:-24310
-9:-17:12870
-9:-16:-6435
-9:-15:3003
-9:-14:-1287
-9:-13:495
-9:-12:-165
-9:-11:45
-9:-10:-9
-9:-9:1
-9:-8:0
-9:-7:0
-9:-6:0
-9:-5:0
-9:-4:0
-9:-3:0
-9:-2:0
-9:-1:0
-9:0:1
-9:1:-9
-9:2:45
-9:3:-165
-9:4:495
-9:5:-1287
-9:6:3003
-9:7:-6435
-9:8:12870
-9:9:-24310
-9:10:43758
-9:11:-75582
-9:12:125970
-9:13:-203490
-9:14:319770
-9:15:-490314

# n = -8, k = n - 15 ... n + 15

-8:-23:-170544
-8:-22:116280
-8:-21:-77520
-8:-20:50388
-8:-19:-31824
-8:-18:19448
-8:-17:-11440
-8:-16:6435
-8:-15:-3432
-8:-14:1716
-8:-13:-792
-8:-12:330
-8:-11:-120
-8:-10:36
-8:-9:-8
-8:-8:1
-8:-7:0
-8:-6:0
-8:-5:0
-8:-4:0
-8:-3:0
-8:-2:0
-8:-1:0
-8:0:1
-8:1:-8
-8:2:36
-8:3:-120
-8:4:330
-8:5:-792
-8:6:1716
-8:7:-3432
-8:8:6435
-8:9:-11440
-8:10:19448
-8:11:-31824
-8:12:50388
-8:13:-77520
-8:14:116280
-8:15:-170544

# n = -7, k = n - 15 ... n + 15

-7:-22:-54264
-7:-21:38760
-7:-20:-27132
-7:-19:18564
-7:-18:-12376
-7:-17:8008
-7:-16:-5005
-7:-15:3003
-7:-14:-1716
-7:-13:924
-7:-12:-462
-7:-11:210
-7:-10:-84
-7:-9:28
-7:-8:-7
-7:-7:1
-7:-6:0
-7:-5:0
-7:-4:0
-7:-3:0
-7:-2:0
-7:-1:0
-7:0:1
-7:1:-7
-7:2:28
-7:3:-84
-7:4:210
-7:5:-462
-7:6:924
-7:7:-1716
-7:8:3003
-7:9:-5005
-7:10:8008
-7:11:-12376
-7:12:18564
-7:13:-27132
-7:14:38760
-7:15:-54264

# n = -6, k = n - 15 ... n + 15

-6:-21:-15504
-6:-20:11628
-6:-19:-8568
-6:-18:6188
-6:-17:-4368
-6:-16:3003
-6:-15:-2002
-6:-14:1287
-6:-13:-792
-6:-12:462
-6:-11:-252
-6:-10:126
-6:-9:-56
-6:-8:21
-6:-7:-6
-6:-6:1
-6:-5:0
-6:-4:0
-6:-3:0
-6:-2:0
-6:-1:0
-6:0:1
-6:1:-6
-6:2:21
-6:3:-56
-6:4:126
-6:5:-252
-6:6:462
-6:7:-792
-6:8:1287
-6:9:-2002
-6:10:3003
-6:11:-4368
-6:12:6188
-6:13:-8568
-6:14:11628
-6:15:-15504

# n = -5, k = n - 15 ... n + 15

-5:-20:-3876
-5:-19:3060
-5:-18:-2380
-5:-17:1820
-5:-16:-1365
-5:-15:1001
-5:-14:-715
-5:-13:495
-5:-12:-330
-5:-11:210
-5:-10:-126
-5:-9:70
-5:-8:-35
-5:-7:15
-5:-6:-5
-5:-5:1
-5:-4:0
-5:-3:0
-5:-2:0
-5:-1:0
-5:0:1
-5:1:-5
-5:2:15
-5:3:-35
-5:4:70
-5:5:-126
-5:6:210
-5:7:-330
-5:8:495
-5:9:-715
-5:10:1001
-5:11:-1365
-5:12:1820
-5:13:-2380
-5:14:3060
-5:15:-3876

# n = -4, k = n - 15 ... n + 15

-4:-19:-816
-4:-18:680
-4:-17:-560
-4:-16:455
-4:-15:-364
-4:-14:286
-4:-13:-220
-4:-12:165
-4:-11:-120
-4:-10:84
-4:-9:-56
-4:-8:35
-4:-7:-20
-4:-6:10
-4:-5:-4
-4:-4:1
-4:-3:0
-4:-2:0
-4:-1:0
-4:0:1
-4:1:-4
-4:2:10
-4:3:-20
-4:4:35
-4:5:-56
-4:6:84
-4:7:-120
-4:8:165
-4:9:-220
-4:10:286
-4:11:-364
-4:12:455
-4:13:-560
-4:14:680
-4:15:-816

# n = -3, k = n - 15 ... n + 15

-3:-18:-136
-3:-17:120
-3:-16:-105
-3:-15:91
-3:-14:-78
-3:-13:66
-3:-12:-55
-3:-11:45
-3:-10:-36
-3:-9:28
-3:-8:-21
-3:-7:15
-3:-6:-10
-3:-5:6
-3:-4:-3
-3:-3:1
-3:-2:0
-3:-1:0
-3:0:1
-3:1:-3
-3:2:6
-3:3:-10
-3:4:15
-3:5:-21
-3:6:28
-3:7:-36
-3:8:45
-3:9:-55
-3:10:66
-3:11:-78
-3:12:91
-3:13:-105
-3:14:120
-3:15:-136

# n = -2, k = n - 15 ... n + 15

-2:-17:-16
-2:-16:15
-2:-15:-14
-2:-14:13
-2:-13:-12
-2:-12:11
-2:-11:-10
-2:-10:9
-2:-9:-8
-2:-8:7
-2:-7:-6
-2:-6:5
-2:-5:-4
-2:-4:3
-2:-3:-2
-2:-2:1
-2:-1:0
-2:0:1
-2:1:-2
-2:2:3
-2:3:-4
-2:4:5
-2:5:-6
-2:6:7
-2:7:-8
-2:8:9
-2:9:-10
-2:10:11
-2:11:-12
-2:12:13
-2:13:-14
-2:14:15
-2:15:-16

# n = -1, k = n - 15 ... n + 15

-1:-16:-1
-1:-15:1
-1:-14:-1
-1:-13:1
-1:-12:-1
-1:-11:1
-1:-10:-1
-1:-9:1
-1:-8:-1
-1:-7:1
-1:-6:-1
-1:-5:1
-1:-4:-1
-1:-3:1
-1:-2:-1
-1:-1:1
-1:0:1
-1:1:-1
-1:2:1
-1:3:-1
-1:4:1
-1:5:-1
-1:6:1
-1:7:-1
-1:8:1
-1:9:-1
-1:10:1
-1:11:-1
-1:12:1
-1:13:-1
-1:14:1
-1:15:-1

# n = 0, k = n - 15 ... n + 15

0:-15:0
0:-14:0
0:-13:0
0:-12:0
0:-11:0
0:-10:0
0:-9:0
0:-8:0
0:-7:0
0:-6:0
0:-5:0
0:-4:0
0:-3:0
0:-2:0
0:-1:0
0:0:1
0:1:0
0:2:0
0:3:0
0:4:0
0:5:0
0:6:0
0:7:0
0:8:0
0:9:0
0:10:0
0:11:0
0:12:0
0:13:0
0:14:0
0:15:0

# n = 1, k = n - 15 ... n + 15

1:-15:0
1:-14:0
1:-13:0
1:-12:0
1:-11:0
1:-10:0
1:-9:0
1:-8:0
1:-7:0
1:-6:0
1:-5:0
1:-4:0
1:-3:0
1:-2:0
1:-1:0
1:0:1
1:1:1
1:2:0
1:3:0
1:4:0
1:5:0
1:6:0
1:7:0
1:8:0
1:9:0
1:10:0
1:11:0
1:12:0
1:13:0
1:14:0
1:15:0
1:16:0

# n = 2, k = n - 15 ... n + 15

2:-15:0
2:-14:0
2:-13:0
2:-12:0
2:-11:0
2:-10:0
2:-9:0
2:-8:0
2:-7:0
2:-6:0
2:-5:0
2:-4:0
2:-3:0
2:-2:0
2:-1:0
2:0:1
2:1:2
2:2:1
2:3:0
2:4:0
2:5:0
2:6:0
2:7:0
2:8:0
2:9:0
2:10:0
2:11:0
2:12:0
2:13:0
2:14:0
2:15:0
2:16:0
2:17:0

# n = 3, k = n - 15 ... n + 15

3:-15:0
3:-14:0
3:-13:0
3:-12:0
3:-11:0
3:-10:0
3:-9:0
3:-8:0
3:-7:0
3:-6:0
3:-5:0
3:-4:0
3:-3:0
3:-2:0
3:-1:0
3:0:1
3:1:3
3:2:3
3:3:1
3:4:0
3:5:0
3:6:0
3:7:0
3:8:0
3:9:0
3:10:0
3:11:0
3:12:0
3:13:0
3:14:0
3:15:0
3:16:0
3:17:0
3:18:0

# n = 4, k = n - 15 ... n + 15

4:-15:0
4:-14:0
4:-13:0
4:-12:0
4:-11:0
4:-10:0
4:-9:0
4:-8:0
4:-7:0
4:-6:0
4:-5:0
4:-4:0
4:-3:0
4:-2:0
4:-1:0
4:0:1
4:1:4
4:2:6
4:3:4
4:4:1
4:5:0
4:6:0
4:7:0
4:8:0
4:9:0
4:10:0
4:11:0
4:12:0
4:13:0
4:14:0
4:15:0
4:16:0
4:17:0
4:18:0
4:19:0

# n = 5, k = n - 15 ... n + 15

5:-15:0
5:-14:0
5:-13:0
5:-12:0
5:-11:0
5:-10:0
5:-9:0
5:-8:0
5:-7:0
5:-6:0
5:-5:0
5:-4:0
5:-3:0
5:-2:0
5:-1:0
5:0:1
5:1:5
5:2:10
5:3:10
5:4:5
5:5:1
5:6:0
5:7:0
5:8:0
5:9:0
5:10:0
5:11:0
5:12:0
5:13:0
5:14:0
5:15:0
5:16:0
5:17:0
5:18:0
5:19:0
5:20:0

# n = 6, k = n - 15 ... n + 15

6:-15:0
6:-14:0
6:-13:0
6:-12:0
6:-11:0
6:-10:0
6:-9:0
6:-8:0
6:-7:0
6:-6:0
6:-5:0
6:-4:0
6:-3:0
6:-2:0
6:-1:0
6:0:1
6:1:6
6:2:15
6:3:20
6:4:15
6:5:6
6:6:1
6:7:0
6:8:0
6:9:0
6:10:0
6:11:0
6:12:0
6:13:0
6:14:0
6:15:0
6:16:0
6:17:0
6:18:0
6:19:0
6:20:0
6:21:0

# n = 7, k = n - 15 ... n + 15

7:-15:0
7:-14:0
7:-13:0
7:-12:0
7:-11:0
7:-10:0
7:-9:0
7:-8:0
7:-7:0
7:-6:0
7:-5:0
7:-4:0
7:-3:0
7:-2:0
7:-1:0
7:0:1
7:1:7
7:2:21
7:3:35
7:4:35
7:5:21
7:6:7
7:7:1
7:8:0
7:9:0
7:10:0
7:11:0
7:12:0
7:13:0
7:14:0
7:15:0
7:16:0
7:17:0
7:18:0
7:19:0
7:20:0
7:21:0
7:22:0

# n = 8, k = n - 15 ... n + 15

8:-15:0
8:-14:0
8:-13:0
8:-12:0
8:-11:0
8:-10:0
8:-9:0
8:-8:0
8:-7:0
8:-6:0
8:-5:0
8:-4:0
8:-3:0
8:-2:0
8:-1:0
8:0:1
8:1:8
8:2:28
8:3:56
8:4:70
8:5:56
8:6:28
8:7:8
8:8:1
8:9:0
8:10:0
8:11:0
8:12:0
8:13:0
8:14:0
8:15:0
8:16:0
8:17:0
8:18:0
8:19:0
8:20:0
8:21:0
8:22:0
8:23:0

# n = 9, k = n - 15 ... n + 15

9:-15:0
9:-14:0
9:-13:0
9:-12:0
9:-11:0
9:-10:0
9:-9:0
9:-8:0
9:-7:0
9:-6:0
9:-5:0
9:-4:0
9:-3:0
9:-2:0
9:-1:0
9:0:1
9:1:9
9:2:36
9:3:84
9:4:126
9:5:126
9:6:84
9:7:36
9:8:9
9:9:1
9:10:0
9:11:0
9:12:0
9:13:0
9:14:0
9:15:0
9:16:0
9:17:0
9:18:0
9:19:0
9:20:0
9:21:0
9:22:0
9:23:0
9:24:0

# n = 10, k = n - 15 ... n + 15

10:-15:0
10:-14:0
10:-13:0
10:-12:0
10:-11:0
10:-10:0
10:-9:0
10:-8:0
10:-7:0
10:-6:0
10:-5:0
10:-4:0
10:-3:0
10:-2:0
10:-1:0
10:0:1
10:1:10
10:2:45
10:3:120
10:4:210
10:5:252
10:6:210
10:7:120
10:8:45
10:9:10
10:10:1
10:11:0
10:12:0
10:13:0
10:14:0
10:15:0
10:16:0
10:17:0
10:18:0
10:19:0
10:20:0
10:21:0
10:22:0
10:23:0
10:24:0
10:25:0

# n = 11, k = n - 15 ... n + 15

11:-15:0
11:-14:0
11:-13:0
11:-12:0
11:-11:0
11:-10:0
11:-9:0
11:-8:0
11:-7:0
11:-6:0
11:-5:0
11:-4:0
11:-3:0
11:-2:0
11:-1:0
11:0:1
11:1:11
11:2:55
11:3:165
11:4:330
11:5:462
11:6:462
11:7:330
11:8:165
11:9:55
11:10:11
11:11:1
11:12:0
11:13:0
11:14:0
11:15:0
11:16:0
11:17:0
11:18:0
11:19:0
11:20:0
11:21:0
11:22:0
11:23:0
11:24:0
11:25:0
11:26:0

# n = 12, k = n - 15 ... n + 15

12:-15:0
12:-14:0
12:-13:0
12:-12:0
12:-11:0
12:-10:0
12:-9:0
12:-8:0
12:-7:0
12:-6:0
12:-5:0
12:-4:0
12:-3:0
12:-2:0
12:-1:0
12:0:1
12:1:12
12:2:66
12:3:220
12:4:495
12:5:792
12:6:924
12:7:792
12:8:495
12:9:220
12:10:66
12:11:12
12:12:1
12:13:0
12:14:0
12:15:0
12:16:0
12:17:0
12:18:0
12:19:0
12:20:0
12:21:0
12:22:0
12:23:0
12:24:0
12:25:0
12:26:0
12:27:0

# n = 13, k = n - 15 ... n + 15

13:-15:0
13:-14:0
13:-13:0
13:-12:0
13:-11:0
13:-10:0
13:-9:0
13:-8:0
13:-7:0
13:-6:0
13:-5:0
13:-4:0
13:-3:0
13:-2:0
13:-1:0
13:0:1
13:1:13
13:2:78
13:3:286
13:4:715
13:5:1287
13:6:1716
13:7:1716
13:8:1287
13:9:715
13:10:286
13:11:78
13:12:13
13:13:1
13:14:0
13:15:0
13:16:0
13:17:0
13:18:0
13:19:0
13:20:0
13:21:0
13:22:0
13:23:0
13:24:0
13:25:0
13:26:0
13:27:0
13:28:0

# n = 14, k = n - 15 ... n + 15

14:-15:0
14:-14:0
14:-13:0
14:-12:0
14:-11:0
14:-10:0
14:-9:0
14:-8:0
14:-7:0
14:-6:0
14:-5:0
14:-4:0
14:-3:0
14:-2:0
14:-1:0
14:0:1
14:1:14
14:2:91
14:3:364
14:4:1001
14:5:2002
14:6:3003
14:7:3432
14:8:3003
14:9:2002
14:10:1001
14:11:364
14:12:91
14:13:14
14:14:1
14:15:0
14:16:0
14:17:0
14:18:0
14:19:0
14:20:0
14:21:0
14:22:0
14:23:0
14:24:0
14:25:0
14:26:0
14:27:0
14:28:0
14:29:0

# n = 15, k = n - 15 ... n + 15

15:-15:0
15:-14:0
15:-13:0
15:-12:0
15:-11:0
15:-10:0
15:-9:0
15:-8:0
15:-7:0
15:-6:0
15:-5:0
15:-4:0
15:-3:0
15:-2:0
15:-1:0
15:0:1
15:1:15
15:2:105
15:3:455
15:4:1365
15:5:3003
15:6:5005
15:7:6435
15:8:6435
15:9:5005
15:10:3003
15:11:1365
15:12:455
15:13:105
15:14:15
15:15:1
15:16:0
15:17:0
15:18:0
15:19:0
15:20:0
15:21:0
15:22:0
15:23:0
15:24:0
15:25:0
15:26:0
15:27:0
15:28:0
15:29:0
15:30:0
