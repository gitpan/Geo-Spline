#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: base.t,v 0.1 2006/02/21 eserte Exp $
# Author: Michael R. Davis
#

=head1 Test Examples

base.t has good examples concerning how to use this module

=cut

use strict;
use lib q{lib};
use lib q{../lib};
use constant NEAR_DEFAULT => 7;

sub near {
  my $x=shift();
  my $y=shift();
  my $p=shift()||NEAR_DEFAULT;
  if (($x-$y)/$y < 10**-$p) {
    return 1;
  } else {
    return 0;
  }
}

sub dms2dd {
  my $d=shift();
  my $m=shift();
  my $s=shift();
  my $dir=shift()||'N';
  my $val=$d+($m+$s/60)/60;
  if ($dir eq 'W' or $dir eq 'S') {
    return -$val;
  } else {
    return $val;
  }
}

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "1..0 # tests only works with installed Test module\n";
	exit;
    }
}

BEGIN { plan tests => 7 }

# just check that all modules can be compiled
ok(eval {require Geo::Spline; 1}, 1, $@);

my $p0={time=>1160449100.67,
        lat=>39.197807,
        lon=>-77.263510,
        speed=>31.124,
        heading=>144.8300};
my $p1={time=>1160449225.66,
        lat=>39.167718,
        lon=>-77.242278,
        speed=>30.615,
        heading=>150.5300};
my $o=Geo::Spline->new($p0, $p1);
ok(ref $o, "Geo::Spline");

my $point=$o->time(1160449150);
ok(near $point->{'lat'}, 39.1861322117117);
ok(near $point->{'lon'}, -77.2548824212532);
ok(near $point->{'speed'}, 33.6486345147946);
ok(near $point->{'heading'}, 142.982403679421);

my $list=$o->list();
my @list=@$list;
ok($#list,126);
