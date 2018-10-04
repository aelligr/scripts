#!/bin/bash

module load ncl/6.2.1 
module load nco/4.6.2-gmvolf-17.02
source ~/.nclrc_hailcast
for day in 01 02 05 07 08 09 10 11 12 14 18 19 20 21 22 23 24 25 26 27 28 29 30 31
do
  ncl footprint.ncl 'day="'${day}'"'
done
