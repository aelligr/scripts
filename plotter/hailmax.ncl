begin

; Plot the maximum hailsize for a certain 10 min timestep
; Use as Input:	- case (eg. 20170531)
;		- sett (eg. case_lhn12h)
;		- time (eg. 1650)

; Proof for available variables
if (.not. isvar("case")) then
  case = "20170708"
end if
if (.not. isvar("sett")) then
  sett = "case_lhn12h"
end if
if (.not. isvar("time")) then
  time = "1450"
end if

; load data
c = addfile("/project/d91/aelligr/cosmo_20170531/output/hailcast/lfff00000000c.nc","r")
data = readAsciiTable("/project/d91/aelligr/cosmo_"+case+"/output/"+sett+"/hailsizes/"+time+"hailsize", 4, "float", 0)

; Get out variables from constant file hsurf 
hsurf = jmb_getvar(c,"HSURF",False)

; Create field from data and add values to field for geo-referencing and use it
; for the hailsize (I did not know how to geo-reference this field of hail, so
; I just overwrite hsurf
field = new((/774,1158/),"float")
field(:,:) = 0
i = 0
n = dimsizes(data)
do while(i.lt.n(0))
  field(floattointeger(data(i,1)),floattointeger(data(i,0))) = data(i,3)
  i = i + 1
end do

; Update hsurf
field@_FillValue = -999
hsurf@_FillValue = -999
hsurf@name = "HAILSIZE"
hsurf@long_name = "Maximum Hail size on the ground"
hsurf@units = "mm"
hsurf@initial_time = case+" 00"
hsurf@valid_time = case+" "+time
fcst = stringtointeger(time)
hsurf@forecast_time = fcst
hsurf@forecast_time_units = "hhmm"
hsurf(:,:) = 0
i = 0
j = 0
do i = 350,800
  do j = 350,700
    if (field(j,i) .gt. hsurf(j,i)*1000) then
      hsurf(j,i) = field(j,i)*1000
    end if
  end do
end do
jmb_getgrid(c,c,hsurf,False)

; Plot this "hsurf"-hailsize
wks = gsn_open_wks("png",case+sett+time+"MaxHailsize")

  ; cut to make it smaller and center over Thun
  res = True
  res@mpFillOn = False
  res@gsnTickMarksOn = False
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnMaximize = True 
  res@mpLimitMode = "LatLon"
  res@mpMinLatF = 46.599
  res@mpMaxLatF = 47.823 
  res@mpMinLonF = 6.971
  res@mpMaxLonF = 8.961
  lnres = True

  ; Forward
  rc = jmb_set_ct(wks, "precip_lom_inst_15lev", False)
  mp = jmb_map(wks, hsurf, res)
  cn = jmb_contour(wks, hsurf, rc)
  r = True
  r@rank = (/20,3,20/)
  r@color = (/"blue", "blue", "blue"/)
  gg = jmb_geography(wks, cn, "cosmo1_latlon", r)
  plt = jmb_overlays(wks, (/mp,cn/), False)
  delete(r)

end

