#!/bin/bash
# inputs are:	- Which variable
#		- Which hour and minute(format: ####, e.g. 1510)
#		- Which case(e.g. 20170531)
#		- Which settings/direcotry(e.g. nolhn)
# 
# arrange inputs and call plot.ncl
  var="$1"
  time="$2"
  cas="$3"
  direc="$4"

# proof of inputs are given otherwise use default
  if [ -z $var ] ; 	then
    var="TOT_PREC"
  fi
  if [ -z $time ] ; 	then
    time="1500"
  fi
  if [ -z $cas ] ; 	then
    cas="20170531"
  fi
  if [ -z $direc ] ; 	then
    direc="lhn12h"
  fi

# print, what your doing
  echo "Use ncl for variable: "$var" time: " $time " case: " $cas " settings: " $direc

# call ncl for different possbilities
  ncl plot.ncl 'var="'${var}'"' 'time="'${time}'"' 'cas="'${cas}'"' 'direc="'${direc}'"'

# move created file to corresponding folder on project and create if it not existing
#  mkdir -p /project/d91/aelligr/cosmo_$cas/output/plots/$direc/
#  mv "$var$time$cas$direc.png" /project/d91/aelligr/cosmo_$cas/output/plots/$direc/

