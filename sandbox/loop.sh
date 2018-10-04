#!/bin/bash
# inputs are:	- Which variable
#		- Which hour and minute to start with(format: ####, e.g. 1510)
#		- Which case(e.g. 20170531)
#		- Which settings/direcotry(e.g. nolhn)
#		- Which hour and minute to end with(format: ####, e.g. 1550)
#
# read input variables
  var=$1 #which starting hour
  strtm=$2 #how many 10min file to plot
  cas=$3
  direc=$4
  endtm=$5
  if [ -z $endtm ] ; 	then
    endtm="$strtm"
  fi

# prepare for pre 10 am. and maximum loop
  tmp1=$(echo $strtm | cut -c1-1)
  max=200; i=1

# do loop from strtm to endtm
while [ "$endtm" -ne "$strtm" ]
do
  # do ncl
  ./input_ncl.sh "$var" "$strtm" "$cas" "$direc"

  # 10 min step forward
  if [ "$tmp1" -eq "0" ] ; then		# pre 10 am.
    strtm=$(echo $strtm | cut -c2-4)
    (( strtm += 10 ))			# eg: 0740 -> 0750
    tmp=$(echo $strtm | cut -c2-2)
    if [ "$tmp" -eq "6" ] ; then
      let "strtm = $strtm +40"		# eg: 0860 -> 0900
    fi
    if [ "$strtm" -ge "1000" ] ; then	
      tmp1=1
    else
      strtm="0"$strtm
    fi
  else					# post 10 am.
    (( strtm += 10 ))
    tmp=$(echo $strtm | cut -c3-3)
    if [ "$tmp" -eq "6" ] ; then
      let "strtm = $strtm +40"
    fi
  fi

  # abort proof after maximum loopcycle
  (( i ++ ))
  if [ "$i" -eq "$max" ] ; then
    strtm=$endtm
  fi

done


