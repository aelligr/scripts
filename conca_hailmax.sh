#!/bin/bash
# This scripts concatenate the outloopfiles together to get files of max_hailsize with coords and
# named with timesstep.
# As example of one line:
# i:	j:	size:
# 432	586	0.009812
# read input variables

#########################################
#		IMPORTANT		#
# 	Change paths before using       #
#########################################

# Set Paths here and define environment
path="/project/d91/aelligr/cosmo_20170708/output/case_lhn12h/"
files=$path"outloop*"
# cut the strings into substring in a loop and fill in a document
for I in $files
do
  # Cut strings to get right position etc.
  tmp=$(echo $I | cut -d'p' -f 4)		# take out file
  numb_stone=$(echo $tmp | cut -c16-17)		# which stone
  j_local=$(echo $tmp | cut -c13-15)		# local j position
  i_local=$(echo $tmp | cut -c10-12)		# local i position
  my_cart=$(echo $tmp | cut -c6-9)		# my_cart_id
  timestep=$(echo $tmp | cut -c1-5)		# timestep

  # Local coordinates to global cordinates
  # Need of file: ij_local2global.pl
  coords=$(./ij_local2global.pl 1158 774 3 64 72 $my_cart $i_local $j_local)
  i_global=$(echo $coords | cut -d ' ' -f 9)
  j_global=$(echo $coords | cut -d ' ' -f 10)

  # Extract hailsize at ground
  tail=$(tail -1 $I)
  max_size=$(echo $tail | cut -d ' ' -f 2)
  
  # Calculate time and create file if it does not exist
  timestep=$((10#$timestep))
  hour=$(($timestep/360))
  minute=$((($timestep/10-($hour*36))*10/6))
  if [ ${#minute} == 1 ] ; then
    minute=$minute'0'
  fi
  touch $hour$minute'hailsize'

  # Write into file
  echo $i_global $j_global $numb_stone $max_size >> $hour$minute'hailsize'
done

mv *hailsize $path""/hailsizes/
