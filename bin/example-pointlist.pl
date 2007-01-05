#!/usr/bin/perl -w

=head1 NAME

example-pointlist.pl - Geo::Spline example to list a set of points between GPS fixes

=cut

use strict;
use lib qw{./lib ../lib};
use Geo::Spline;

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
my $spline=Geo::Spline->new($p0, $p1);
print "--- 10 points ---\n";
my $point=$spline->pointlist(@{$spline->timelist(10)});
my $i=1;
foreach (@$point) {
  print $i++, ":", $_->{'time'}, ":", $_->{'lat'}, ":", $_->{'lon'}, "\n";
}
print "--- Default number of points ---\n";
my $point=$spline->pointlist();
$i=1;
foreach (@$point) {
  print $i++, ":", $_->{'time'}, ":", $_->{'lat'}, ":", $_->{'lon'}, "\n";
}
