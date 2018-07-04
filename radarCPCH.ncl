begin
  
  ; inputs
  ; which hour:
  strhour = 13
  endhour = 20
  case = 20170708
  geogra = "zofingen"  
  
do hour = strhour,endhour
  ; read files
  f = addfile("/project/d91/aelligr/cosmo_"+case+"/output/radar/CPCH_"+case+hour+"00_00060_c1.grib1","r")
  c = addfile("/project/d91/aelligr/cosmo_20170531/output/hailcast/lfff00000000c.nc","r")

  ; get variables
  vari = jmb_getvar(f,"TOT_PREC",False)
  hsurf = jmb_getvar(c,"HSURF",False)

  ; geo-referencing
  jmb_getgrid(c,c,hsurf,False)
  jmb_getgrid(f,c,vari,False)
  
  ; cut to make it smaller and center over Thun
  res = True
  res@mpFillOn = False
  res@gsnTickMarksOn = False
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnMaximize = True 
  res@mpLimitMode = "LatLon"
  if (geogra .eq. "thun") then
    res@mpMinLatF = 46.235
    res@mpMaxLatF = 47.425 
    res@mpMinLonF = 6.630
    res@mpMaxLonF = 8.552
  else
    res@mpMinLatF = 46.599
    res@mpMaxLatF = 47.823 
    res@mpMinLonF = 6.971
    res@mpMaxLonF = 8.961
  res@lbLabelBarOn = False
  end if
  ; plot it
  wks = gsn_open_wks("png","CPCHradar"+case+hour)
  rc = jmb_set_ct(wks, "precip1h_17lev", False)
;  mp = jmb_map(wks, vari, False)
;  cn = jmb_contour(wks, vari, False)
;  r = True
;  r@rank = (/20,3,20/)
;  r@color = (/"blue", "blue", "blue"/)

;  delete(r)


  ; make it with gsn
  ress = True
  ress@mpFillColors = (/"transparent","transparent","transparent","transparent"/)
  ress@mpMinLatF = 46.235
  ress@mpMaxLatF = 47.425 
  ress@mpMinLonF = 6.630
  ress@mpMaxLonF = 8.552
  
  mp = jmb_map(wks, hsurf, res)
  cn = jmb_contour(wks, vari, rc)
  r = True
  r@rank = (/20,3,20/)
  r@color = (/"blue", "blue", "blue"/)
  gg = jmb_geography(wks, cn, "cosmo1_latlon", r)
  plt = jmb_overlays(wks, (/mp,cn/), False)
  delete(r)

end do

end


