#!/usr/bin/perl

# Script: ij_global2local.pl
# Author: Oliver Fuhrer
# Contact: oliver.fuhrer@meteoswiss.ch
# Description: Compute global coordinates from local ij and MPI task

# check arguments and parse them
if ($#ARGV!=6) {
  print "Usage: ij_global2local.pl ie_tot je_tot nboundlines nprocx nprocy i_global j_global\n";
  die "Wrong number of arguments";
}
$ie_tot = $ARGV[0];
$je_tot = $ARGV[1];
$nboundlines = $ARGV[2];
$nprocx = $ARGV[3];
$nprocy = $ARGV[4];
$i_global = $ARGV[5];
$j_global = $ARGV[6];

# only integer arithmetic in this section
{ use integer;

# Number of grid points that have to be distributed in each direction.
# The first nboundlines boundary lines of the total domain are not
# considered.
$nzcompi = $ie_tot - 2*$nboundlines;
$nzcompj = $je_tot - 2*$nboundlines;

# Number of grid points a subdomain gets at least: nzsubi, nzsubj
$nzsubi  = $nzcompi / $nprocx;
$nzsubj  = $nzcompj / $nprocy;

# Determine how many subdomains will get nzsubi (nzix1) and how many will
# get nzsubi+1 (nzix2) grid points: nzix1, nzix2
$nzix2   = $nzcompi - $nprocx * $nzsubi;
$nzix1   = $nprocx - $nzix2;

# Determine how many subdomains will get nzsubj (nzjy1) and how many will
# get nzsubj+1 (nzjy2) grid points
$nzjy2   = $nzcompj - $nprocy * $nzsubj;
$nzjy1   = $nprocy - $nzjy2;

# Determine the distribution of the subdomains with different sizes.
# The ones with more grid points are placed to the interior, the ones
# with less grid points to the boundary of the processor grid.
$nzix2left  = $nzix1 / 2;
#$nzix2right = $nzix1 - $nzix2left;
$nzjy2lower = $nzjy1 / 2;
#$nzjy2upper = $nzjy1 - $nzjy2lower;

# loop over tiles
for ($ix = 0; $ix <= $nprocx-1; $ix++) {
  for ($iy = 0;$iy <= $nprocy-1; $iy++) {

    $nz1d = $ix * $nprocy + $iy;

    $cart_pos[$nz1d] = [ ($ix,$iy) ];

    my @loc_cart_neigh = ();
    if ($ix == 0) {
      $loc_cart_neigh[0] = -1;
      $loc_cart_neigh[2] = ($ix+1) * $nprocy + $iy;
    } elsif ($ix == $nprocx-1) {
      $loc_cart_neigh[0] = ($ix-1) * $nprocy + $iy;
      $loc_cart_neigh[2] = -1;
    } else {
      $loc_cart_neigh[0] = ($ix-1) * $nprocy + $iy;
      $loc_cart_neigh[2] = ($ix+1) * $nprocy + $iy;
    }
    if ($iy == 0) {
      $loc_cart_neigh[1] = $ix * $nprocy + $iy+1;
      $loc_cart_neigh[3] = -1;
    } elsif ($iy == $nprocy-1) {
      $loc_cart_neigh[1] = -1;
      $loc_cart_neigh[3] = $ix * $nprocy + $iy-1;
    } else {
      $loc_cart_neigh[1] = $ix * $nprocy + $iy+1;
      $loc_cart_neigh[3] = $ix * $nprocy + $iy-1;
    }
    $cart_neigh[$nz1d] = [ @loc_cart_neigh ];
 
    my @loc_isubpos = ();
    if ( (0 <= $iy) && ($iy <= $nzjy2lower-1) ) {
      $loc_isubpos[1] =  $iy    *  $nzsubj + $nboundlines + 1;
      $loc_isubpos[3] = ($iy+1) *  $nzsubj + $nboundlines;
    } elsif ( ($nzjy2lower <= $iy) && ($iy <= $nzjy2lower+$nzjy2-1) ) {
      $loc_isubpos[1] =  $iy    * ($nzsubj+1) - $nzjy2lower + $nboundlines + 1;
      $loc_isubpos[3] = ($iy+1) * ($nzsubj+1) - $nzjy2lower + $nboundlines;
    } elsif ( ($nzjy2lower+$nzjy2 <= $iy) && ($iy <= $nprocy-1) ) {
      $loc_isubpos[1] =  $iy    *  $nzsubj + $nzjy2 + $nboundlines + 1;
      $loc_isubpos[3] = ($iy+1) *  $nzsubj + $nzjy2 + $nboundlines;
    }
    if ( (0 <= $ix) && ($ix <= $nzix2left-1) ) {
      $loc_isubpos[0] =  $ix    *  $nzsubi + $nboundlines + 1;
      $loc_isubpos[2] = ($ix+1) *  $nzsubi + $nboundlines;
    } elsif ( ($nzix2left <= $ix) && ($ix <= $nzix2left+$nzix2-1) ) {
      $loc_isubpos[0] =  $ix    * ($nzsubi+1) - $nzix2left + $nboundlines + 1;
      $loc_isubpos[2] = ($ix+1) * ($nzsubi+1) - $nzix2left + $nboundlines;
    } elsif ( ($nzix2left+$nzix2 <= $ix) && ($ix <= $nprocx-1) ) {
      $loc_isubpos[0] =  $ix    *  $nzsubi + $nzix2 + $nboundlines + 1;
      $loc_isubpos[2] = ($ix+1) *  $nzsubi + $nzix2 + $nboundlines;
    }
    $isubpos[$nz1d] = [ @loc_isubpos ];

    $ie[$nz1d] = $isubpos[$nz1d][2] - $isubpos[$nz1d][0] + 1 + 2*$nboundlines;
    $je[$nz1d] = $isubpos[$nz1d][3] - $isubpos[$nz1d][1] + 1 + 2*$nboundlines;

  }
}

# print local locations
for ($nz1d = 0; $nz1d < $nprocx*$nprocy; $nz1d++) {
  @loc_isubpos = @{ $isubpos[$nz1d] };
  if (($i_global >= $loc_isubpos[0]) && 
      ($i_global <= $loc_isubpos[2]) && 
      ($j_global >= $loc_isubpos[1]) && 
      ($j_global <= $loc_isubpos[3]) ) {
    $i = $i_global-$loc_isubpos[0]+$nboundlines+1;
    $j = $j_global-$loc_isubpos[1]+$nboundlines+1;
    printf("   PE      i      j  i_global  j_global\n");
    printf("%5d %6d %6d %9d %9d\n",$nz1d,$i,$j,$i_global,$j_global);
  }
}

}

