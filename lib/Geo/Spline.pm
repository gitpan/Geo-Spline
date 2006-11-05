package Geo::Spline;

=head1 NAME

Geo::Spline - Calculate geographic locations between GPS fixes.

=head1 SYNOPSIS

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
 my $point=$spline->point(1160449150);
 print "Lon", $pt->{"lat"}, "Lat", $pt->{"lon"}, "\n";
 my $pointlistref=$spline->pointlist(); #default is int(t2-t1+.5)

=head1 DESCRIPTION

This program was developed to be able to calculate the position between two GPS fixes using a 2-dimintional 3rd order polynominal spline.

 f(t)  = A + B(t-t0)  + C(t-t0)^2 + D(t-t0)^3 #position in X and Y
 f'(t) = B + 2C(t-t0) + 3D(t-t0)^2            #velocity in X and Y

I did some simplae Math (for an engineer with a math minor) to come up with these formulas to calculate the unknowns from our knowns.

 A = x0                                     # when (t-t0)=0 in f(t)
 B = v0                                     # when (t-t0)=0 in f'(t)
 C = (x1-A-B(t1-t0)-D(t1-t0)^3)/(t1-t0)^2   # solve for C from f(t)
 C = (v1-B-3D(t1-t0)^2)/2(t1-t0)            # solve for C from f'(t)
 D = (v1(t1-t0)+B(t1-t0)-2x1+2A)/(t1-t0)^3  # equate C=C then solve for D

=cut

use strict;
use vars qw($VERSION);
use constant PI => 2 * atan2(1, 0);
use constant RAD => 180/PI;
use constant earth_polar_circumference_meters_per_degree => 6356752.314245 * PI/180;
use constant earth_equatorial_circumference_meters_per_degree => 6378137 * PI/180;
use constant EPCMPD => earth_polar_circumference_meters_per_degree;
use constant EECMPD => earth_equatorial_circumference_meters_per_degree;

$VERSION = sprintf("%d.%02d", q{Revision: 0.06} =~ /(\d+)\.(\d+)/);

=head1 METHODS

=cut

sub new {
  my $this = shift();
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->initialize(@_);
  return $self;
}

sub initialize {
  my $self = shift();
  $self->{'pt0'}=shift();
  $self->{'pt1'}=shift();
  my $dt=$self->{'pt1'}->{'time'} - $self->{'pt0'}->{'time'};
  die ("Delta time must be greater than zero.") if ($dt<=0);
  my ($A, $B, $C, $D)=$self->ABCD(
     $self->{'pt0'}->{'time'},
     $self->{'pt0'}->{'lat'} * EPCMPD,
     $self->{'pt0'}->{'speed'} * cos($self->{'pt0'}->{'heading'}/RAD),
     $self->{'pt1'}->{'time'},
     $self->{'pt1'}->{'lat'} * EPCMPD,
     $self->{'pt1'}->{'speed'} * cos($self->{'pt1'}->{'heading'}/RAD));
  $self->{'Alat'}=$A;
  $self->{'Blat'}=$B;
  $self->{'Clat'}=$C;
  $self->{'Dlat'}=$D;
  ($A, $B, $C, $D)=$self->ABCD(
     $self->{'pt0'}->{'time'},
     $self->{'pt0'}->{'lon'} * EECMPD,
     $self->{'pt0'}->{'speed'} * sin($self->{'pt0'}->{'heading'}/RAD),
     $self->{'pt1'}->{'time'},
     $self->{'pt1'}->{'lon'} * EECMPD,
     $self->{'pt1'}->{'speed'} * sin($self->{'pt1'}->{'heading'}/RAD));
  $self->{'Alon'}=$A;
  $self->{'Blon'}=$B;
  $self->{'Clon'}=$C;
  $self->{'Dlon'}=$D;
}

sub ABCD {
  my $self = shift();
  my $t0 = shift();
  my $x0 = shift();
  my $v0 = shift();
  my $t1 = shift();
  my $x1 = shift();
  my $v1 = shift();
  #x=f(t)=A+B(t-t0)+C(t-t0)^2+D(t-t0)^3
  #v=f'(t)=B+2C(t-t0)+3D(t-t0)^2
  #A=x0
  #B=v0
  #C=(x1-A-B(t1-t0)-D(t1-t0)^3)/((t1-t0)^2) # from f(t)
  #C=(v1-B-3D(t1-t0)^2)/2(t1-t0)            # from f'(t)
  #D=(v1t+Bt-2x1+2A)/t^3                    # from C=C
  my $A=$x0;
  my $B=$v0;
  #=(C3*(A3-A2)+B6*(A3-A2)-2*B3+2*B5)/(A3-A2)^3 # for Excel
  my $D=($v1*($t1-$t0)+$B*($t1-$t0)-2*$x1+2*$A)/($t1-$t0)**3;
  #=(B3-B5-B6*(A3-A2)-B8*(A3-A2)^3)/(A3-A2)^2   # for Excel
  my $C=($x1-$A-$B*($t1-$t0)-$D*($t1-$t0)**3)/($t1-$t0)**2;
  return($A,$B,$C,$D);
}

sub pointlist {
  my $self=shift();
  my @list=@_;
  @list=@{$self->timelist()} if (scalar(@list)== 0);
  my @points=();
  foreach (@list) {
    push @points, $self->point($_);
  }
  return \@points;
}

sub point {
  my $self=shift();
  my $timereal=shift();
  my @point=();
  my $t=$timereal-$self->{'pt0'}->{'time'};
  my ($Alat, $Blat, $Clat, $Dlat)=($self->{'Alat'}, $self->{'Blat'},$self->{'Clat'},$self->{'Dlat'});
  my ($Alon, $Blon, $Clon, $Dlon)=($self->{'Alon'}, $self->{'Blon'},$self->{'Clon'},$self->{'Dlon'});
  my $lat=$Alat + $Blat * $t + $Clat * $t ** 2 + $Dlat * $t ** 3;
  my $lon=$Alon + $Blon * $t + $Clon * $t ** 2 + $Dlon * $t ** 3;
  my $vlat=$Blat + 2 * $Clat * $t + 3 * $Dlat * $t ** 2;
  my $vlon=$Blon + 2 * $Clon * $t + 3 * $Dlon * $t ** 2;
  my $speed=sqrt($vlat ** 2 + $vlon ** 2);
  my $heading=PI/2 - atan2($vlat,$vlon);
  $heading*=RAD;
  $heading+=360 if ($heading < 0);
  $lat/=EPCMPD;
  $lon/=EECMPD;
  return {time=>$timereal,
          lat=>$lat,
          lon=>$lon,
          speed=>$speed,
          heading=>$heading};
}

sub timelist {
  my $self=shift();
  my $t0=$self->{'pt0'}->{'time'};
  my $t1=$self->{'pt1'}->{'time'};
  my $dt=$t1-$t0;
  my $count=shift() || round($dt);
  my @list;
  foreach(0..$count) {
    my $t=$t0+$dt*($_/$count); 
    push @list, $t;
  }
  return \@list;
}

sub round {
  return int(shift() + 0.5);
}

1;

__END__

=head1 TODO

Integrate a better lat,Lon to meter conversions.

Migrate certain hash reference variables to object methods.

Add a timeref method

=head1 BUGS

=head1 LIMITS

I use a very rough conversion from degrees to meters and then back.  It is accurate for short distances.

=head1 AUTHOR

Michael R. Davis qw/perl michaelrdavis com/

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

Net::GPSD
Math::Spline
