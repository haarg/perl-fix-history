#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  $| = 1;
  # to locate the testing files
  my $location = $0; $location =~ s/upgrade.t//i;
  if ($ENV{PERL_CORE})
    {
    @INC = qw(../t/lib);                # testing with the core distribution
    }
  unshift @INC, '../lib';       # for testing manually
  if (-d 't')
    {
    chdir 't';
    require File::Spec;
    unshift @INC, File::Spec->catdir(File::Spec->updir, $location);
    }
  else
    {
    unshift @INC, $location;
    }
  print "# INC = @INC\n";

   plan tests => 1990
    + 2;			# our own tests
  }

use Math::BigInt upgrade => 'Math::BigFloat';
use Math::BigFloat;

use vars qw ($scale $class $try $x $y $f @args $ans $ans1 $ans1_str $setup
             $ECL $CL);
$class = "Math::BigInt";
$CL = "Math::BigInt::Calc";
$ECL = "Math::BigFloat";

ok (Math::BigInt->upgrade(),'Math::BigFloat');
ok (Math::BigInt->downgrade()||'','');

require 'upgrade.inc';	# all tests here for sharing
