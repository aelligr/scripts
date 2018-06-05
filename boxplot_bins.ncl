begin
; This scripts plots the size of the hailstone at the ground by differentiating by its starting point

; Set data path, case, and settings
sett = "case_lhn12h"
case = "20170531"
filen= "1630hailsize"
path = "/project/d91/aelligr/cosmo_"+case+"/output/"+sett+"/hailsizes/"+filen

; Read in data from the already concatenated data
data = readAsciiTable(path, 4, "float", 0)
data_length = dimsizes(data)
hail_array1 = new(data_length(0)/5,"float")
hail_array2 = new(data_length(0)/5,"float")
hail_array3 = new(data_length(0)/5,"float")
hail_array4 = new(data_length(0)/5,"float")
hail_array5 = new(data_length(0)/5,"float")

; Create arrays for each initial hailsize and sort them
do j = 0,(data_length(0)-1)
  if     ( data(j,2) .eq. 1 ) then
    hail_array1(round((j/5),3)) = data(j,3)*1000
  else if (data(j,2) .eq. 2) then
    hail_array2(round((j/5),3)) = data(j,3)*1000
  else if (data(j,2) .eq. 3) then
    hail_array3(round((j/5),3)) = data(j,3)*1000
  else if (data(j,2) .eq. 4) then
    hail_array4(round((j/5),3)) = data(j,3)*1000
  else if (data(j,2) .eq. 5) then
    hail_array5(round((j/5),3)) = data(j,3)*1000
  end if
  end if
  end if
  end if
  end if
end do
qsort(hail_array1)
qsort(hail_array2)
qsort(hail_array3)
qsort(hail_array4)
qsort(hail_array5)

; calculate boxplots basics
box_array = new((/5,5/),"float")
if ((data_length(0)/5)%4 .eq. 0) then
  k = 0
else if ((data_length(0)/5)%4 .eq. 1) then
  k = 1
else if ((data_length(0)/5)%4 .eq. 2) then
  k = 2
else if ((data_length(0)/5)%4 .eq. 3) then
  k = 3
end if
end if
end if
end if

  box_array(0,0) = hail_array1(0)
  box_array(1,0) = hail_array2(0)
  box_array(2,0) = hail_array3(0)
  box_array(3,0) = hail_array4(0)
  box_array(4,0) = hail_array5(0)

  box_array(0,1) = hail_array1(round(data_length(0)/20,3))
  box_array(1,1) = hail_array2(round(data_length(0)/20,3))
  box_array(2,1) = hail_array3(round(data_length(0)/20,3))
  box_array(3,1) = hail_array4(round(data_length(0)/20,3))
  box_array(4,1) = hail_array5(round(data_length(0)/20,3))

  box_array(0,2) = hail_array1(round(data_length(0)/10,3))
  box_array(1,2) = hail_array2(round(data_length(0)/10,3))
  box_array(2,2) = hail_array3(round(data_length(0)/10,3))
  box_array(3,2) = hail_array4(round(data_length(0)/10,3))
  box_array(4,2) = hail_array5(round(data_length(0)/10,3))

  box_array(0,3) = hail_array1(round(data_length(0)/20*3,3))
  box_array(1,3) = hail_array2(round(data_length(0)/20*3,3))
  box_array(2,3) = hail_array3(round(data_length(0)/20*3,3))
  box_array(3,3) = hail_array4(round(data_length(0)/20*3,3))
  box_array(4,3) = hail_array5(round(data_length(0)/20*3,3))

  box_array(0,4) = hail_array1(data_length(0)/5-1)
  box_array(1,4) = hail_array2(data_length(0)/5-1)
  box_array(2,4) = hail_array3(data_length(0)/5-1)
  box_array(3,4) = hail_array4(data_length(0)/5-1)
  box_array(4,4) = hail_array5(data_length(0)/5-1)

; create boxplot
wks = gsn_open_wks("png",filen+case+sett)
  res            = True                         ; plot mods desired
  res@tmXBLabels = (/"5mm -8C","7.5mm -8C","5mm -13C","7.5mm -13C","10mm -13C"/) ; labels for each box
  res@tiMainString = "End Hailsize distribution of each embryo"
  res@tmXBLabelAngleF = 45.
plt = boxplot(wks, (/1,2,3,4,5/), box_array,False,res,False)
draw(wks)
frame(wks)


end
