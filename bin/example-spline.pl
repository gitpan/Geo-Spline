#!/usr/bin/perl -w

=head1 NAME

example-spline.pl

=cut

use strict;
use lib qw{lib};
use lib qw{../lib};

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
my $point=$spline->list(); #default count is int(t2-t1+.5)
foreach (@$point) {
  print $_->{'lat'}, ":", $_->{'lon'}, "\n";
}
