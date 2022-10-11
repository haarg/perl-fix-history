# Fixing old tags

Various old tags have a parallel history to blead. They should be on the main
line, but due to some mistakes and rewrites, they have diverged. The tags have
already been changed in the past, so it should be acceptable to change them
again to properly fix them.

These tags should be in the history of blead:

  - GitLive-blead
  - perl-5.7.3
  - perl-5.9.0
  - perl-5.9.1
  - perl-5.9.2
  - perl-5.9.3
  - perl-5.9.4
  - perl-5.9.5

These tags should be in the history of maint-5.004:

  - GitLive-maint-5.004
  - perl-5.004_05
  - timinator
  - timinatorII

Also, the `maint-5.004` branch should be fixed, and should have all of the
`perl-5.004_*` tags in its history.

Fixing this requires modifying 7 commits. The replacement commits already
exist in the repository and represent the same changes. They just have
slightly different formatting of the author names, or different emails. The
emails were not intentionally different - they just have been rewritten
differently. The trees they represent is identical.

These are the commits and their replacements:

  - git replace [`7d30fe4839ae753ca83085806b7e44c13cd4b85e`](https://github.com/Perl/perl5/commit/7d30fe4839ae753ca83085806b7e44c13cd4b85e) [`ae90ce57013cdde0bb10fdc1a9173ca8f0973d6c`](https://github.com/Perl/perl5/commit/ae90ce57013cdde0bb10fdc1a9173ca8f0973d6c)
  - git replace [`4a00836e1df4aa33331a91e5c70afb0e81f4ac11`](https://github.com/Perl/perl5/commit/4a00836e1df4aa33331a91e5c70afb0e81f4ac11) [`f9a26a8bc278e3c63fbdba45d0b02bb258cdbc4d`](https://github.com/Perl/perl5/commit/f9a26a8bc278e3c63fbdba45d0b02bb258cdbc4d)
  - git replace [`d9a464030e8e08486d87711a575d5a5696634a73`](https://github.com/Perl/perl5/commit/d9a464030e8e08486d87711a575d5a5696634a73) [`c86e9150ad7a16fbff9ad6e01b9c8c86649cde1b`](https://github.com/Perl/perl5/commit/c86e9150ad7a16fbff9ad6e01b9c8c86649cde1b)
  - git replace [`36806fa22a1cdba78b67e4ac73e00a1e2116c8a6`](https://github.com/Perl/perl5/commit/36806fa22a1cdba78b67e4ac73e00a1e2116c8a6) [`c6601927a584c0fd18d5a6bb3b4c95cff46a2c6a`](https://github.com/Perl/perl5/commit/c6601927a584c0fd18d5a6bb3b4c95cff46a2c6a)
  - git replace [`d29d8e65e2df59accc13187fed511ddf49fb8053`](https://github.com/Perl/perl5/commit/d29d8e65e2df59accc13187fed511ddf49fb8053) [`426affbfcdc1a44b91a25ac2862d4b8ea7a209fd`](https://github.com/Perl/perl5/commit/426affbfcdc1a44b91a25ac2862d4b8ea7a209fd)
  - git replace [`19e345f737f2ce1fb00aa117c7469e01a20da559`](https://github.com/Perl/perl5/commit/19e345f737f2ce1fb00aa117c7469e01a20da559) [`3d036c2b4a16bfabb30adc0a1c9a65f0f7823869`](https://github.com/Perl/perl5/commit/3d036c2b4a16bfabb30adc0a1c9a65f0f7823869)
  - git replace [`bb4c4dc4f8b582cd197e90c49777d0c8c019a470`](https://github.com/Perl/perl5/commit/bb4c4dc4f8b582cd197e90c49777d0c8c019a470) [`d02b64de5f9ba499420a267adddd8f43af075dad`](https://github.com/Perl/perl5/commit/d02b64de5f9ba499420a267adddd8f43af075dad)

## fix-p5

This script will clone the perl 5 repo, set up the replacements, and rewrite
the repo to bake the changes in.

## check-hist

This script will verify that the tags are correctly part of the history of
the appropriate branches.

## Pushing the fixes

Pushing these fixes to the main git repository can be done using one of the
following processes:

### Using the scripts

```
git clone https://github.com/haarg/perl-fix-history.git
cd perl-fix-history
./fix-p5
cd perl5
../check-hist
git push -f origin \
  GitLive-maint-5.004 \
  GitLive-blead \
  perl-5.004_05 \
  perl-5.7.3 \
  perl-5.9.0 \
  perl-5.9.1 \
  perl-5.9.2 \
  perl-5.9.3 \
  perl-5.9.4 \
  perl-5.9.5 \
  timinator \
  timinatorII \
  maint-5.004
```

### Using the fixed content in this repository

```
git clone https://github.com/haarg/perl-fix-history.git
cd perl-fix-history
git push -f git@github.com:Perl/perl5.git \
  GitLive-maint-5.004 \
  GitLive-blead \
  perl-5.004_05 \
  perl-5.7.3 \
  perl-5.9.0 \
  perl-5.9.1 \
  perl-5.9.2 \
  perl-5.9.3 \
  perl-5.9.4 \
  perl-5.9.5 \
  timinator \
  timinatorII \
  maint-5.004
```
