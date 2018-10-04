begin
; This scripts plots the size of the hailstone at the ground by differentiating by its starting point

; Set data path, case, and settings
sett = "case_lhn15h"
case = "20150606"
filen= "1650hailsize"
path = "/project/d91/aelligr/cosmo_"+case+"/output/"+sett+"/hailsizes/"

; Read in data from the already concatenated data
; add more data to table
data = readAsciiTable(path+filen, 4, "float", 0)

listfiles = systemfunc("ls "+path)
do i = 1,dimsizes(listfiles)-1
  temp1 = readAsciiTable("/project/d91/aelligr/cosmo_"+case+"/output/"+sett+"/hailsizes/"+listfiles(i), 4, "float", 0)
  temp2 = table_attach_rows(data, temp1, 0)
  delete(temp1)
  delete(data)
  data = temp2
  delete(temp2)
end do
delete(i)

data_length = dimsizes(data)
print(data_length)
print(listfiles)
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
  
; write values for boxplot boxes
  box_array = new((/5,5/), "float")
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

; calculate inter-quartile-ranges and Whiskers and outliers
  iqr1 = 1.5*(box_array(0,3) - box_array(0,1))
  iqr2 = 1.5*(box_array(1,3) - box_array(1,1))
  iqr3 = 1.5*(box_array(2,3) - box_array(2,1))
  iqr4 = 1.5*(box_array(3,3) - box_array(3,1))
  iqr5 = 1.5*(box_array(4,3) - box_array(4,1))

outliers = new((/5,data_length(0)/5/), "float")
  do i_1low = 0,data_length(0)/5-1
    if ( hail_array1(i_1low) .le. box_array(0,2)-iqr1 ) then
      outliers(0,i_1low) = hail_array1(i_1low)
      continue
    else
      box_array(0,0) = hail_array1(i_1low)
      break
    end if
  end do


  do i_2low = 0,data_length(0)/5-1
    if ( hail_array2(i_2low) .le. box_array(1,2)-iqr2 ) then
      outliers(1,i_2low) = hail_array2(i_2low)
      continue
    else
      box_array(1,0) = hail_array2(i_2low)
      break
    end if
  end do

  do i_3low = 0,data_length(0)/5-1
    if ( hail_array3(i_3low) .le. box_array(2,2)-iqr3 ) then
      outliers(2,i_3low) = hail_array3(i_3low)
      continue
    else
      box_array(2,0) = hail_array3(i_3low)
      break
    end if
  end do

  do i_4low = 0,data_length(0)/5-1
    if ( hail_array4(i_4low) .le. box_array(3,2)-iqr4 ) then
      outliers(3,i_4low) = hail_array4(i_4low)
      continue
    else
      box_array(3,0) = hail_array4(i_4low)
      break
    end if
  end do

  do i_5low = 0,data_length(0)/5-1
    if ( hail_array5(i_5low) .le. box_array(4,2)-iqr5 ) then
      outliers(4,i_5low) = hail_array5(i_5low)
      continue
    else
      box_array(4,0) = hail_array5(i_5low)
      break
    end if
  end do

  do i_1up = data_length(0)/5-1,0,1
    if ( hail_array1(i_1up) .ge. box_array(0,2)+iqr1 ) then
      outliers(0,i_1up) = hail_array1(i_1up)
      continue
    else
      box_array(0,4) = hail_array1(i_1up)
      break
    end if
  end do

  do i_2up = data_length(0)/5-1,0,1
    if ( hail_array2(i_2up) .ge. box_array(1,2)+iqr2 ) then
      outliers(1,i_2up) = hail_array2(i_2up)
      continue
    else
      box_array(1,4) = hail_array2(i_2up)
      break
    end if
  end do

  do i_3up = data_length(0)/5-1,0,1
    if ( hail_array3(i_3up) .ge. box_array(2,2)+iqr3 ) then
      outliers(2,i_3up) = hail_array3(i_3up)
      continue
    else
      box_array(2,4) = hail_array3(i_3up)
      break
    end if
  end do

  do i_4up = data_length(0)/5-1,0,1
    if ( hail_array4(i_4up) .ge. box_array(3,2)+iqr4 ) then
      outliers(3,i_4up) = hail_array4(i_4up)
      continue
    else
      box_array(3,4) = hail_array4(i_4up)
      break
    end if
  end do

  do i_5up = data_length(0)/5-1,0,1
    if ( hail_array5(i_5up) .ge. box_array(4,2)+iqr5 ) then
      outliers(4,i_5up) = hail_array5(i_5up)
      continue
    else
      box_array(4,4) = hail_array5(i_5up)
      break
    end if
  end do 

; create the outliers

; create boxplot
wks = gsn_open_wks("pdf","boxplots"+filen+case+sett)
  res            = True                         ; plot mods desired
  res@tmXBLabels = (/"5mm -8C","7.5mm -8C","5mm -13C","7.5mm -13C","10mm -13C"/) ; labels for each box
;  res@tiMainString = "End Hailsize distribution of each embryo"
  res@tmXBLabelAngleF = 45.
  res@trYMinF = 0.
  res@trYMaxF = 50.
  res@tiYAxisString = "Hail diameter at the ground [mm]"

plt = boxplot(wks, (/1,2,3,4,5/), box_array,False,res,False)
; draw outliers
  mres               = True                     ; marker mods desired
  mres@gsMarkerColor = "navy blue"              ; change color
  mres@gsMarkerIndex = 4                        ; change style
  mres@gsMarkerSizeF = 10.                      ; change size
  a = dimsizes(outliers)
  dum = new((/a(0),a(1)/),"graphic")
  do i = 0,a(0)-1
    do j = 0,a(1)-1
      if ( ismissing(outliers(i,j)) ) then
        continue
      else
        dum(i,j) = gsn_add_polymarker(wks,plt,i+1,outliers(i,j),mres)
      end if
    end do
  end do
  
draw(wks)
frame(wks)


end
