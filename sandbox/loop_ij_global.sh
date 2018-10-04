#!/bin/bash
# loop to find out id card and i j for cosmo 1

#strj=404
#endj=432
#stri=505
#endi=546

strj=505
endj=546
stri=404
endi=432
j=$strj
i=$stri

while [ "$j" -ne "$endj" ]
do
  while [ "$i" -ne "$endi" ]
  do
    ./ij_global2local.pl 1158 774 3 64 72 $j $i
    
    (( i ++ ))
  done
  (( j ++ ))
  i=$stri
done
