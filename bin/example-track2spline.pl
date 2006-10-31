#!/usr/bin/perl -w

=head1 NAME

example-track2spline.pl

=cut

use strict;
use lib qw{lib};
use lib qw{../lib};

use Geo::Spline;

my $p0=undef();
while (<>) {
#1|trackfactor|66|1999.28374387446|440.442374284396||1160437512.38|40.319898|-79.679785||29.658|149.0500|
  print $_;
  chomp;
  my @data=split(/\|/, $_);
  my $p1={time=>$data[6],
          lat=>$data[7],
          lon=>$data[8],
          speed=>$data[10],
          heading=>$data[11]};
  if (defined($p0)) {
    if ($p1->{'time'} > $p0->{'time'}) {
      my $spline=Geo::Spline->new($p0, $p1);
      my $list=$spline->list(); #[{},{}]
      foreach (@$list) {
        print join("|", 0, "spline", "", "", "", "", $_->{'time'},
                        $_->{'lat'}, $_->{'lon'}, "", $_->{'speed'}, $_->{'heading'}), "\n";
      }
    }
  }  
  $p0=$p1;
}
