begin
  
  ; input variables should be:	-var	variable to plot
  ;				-time	time
  ;				-cas	which case do we take
  ;				-direc	which settings are taken

  ; if no variables input, then give'hem some
  if (.not. isvar("var")) then
    var="TQG"
  end if
  if (.not. isvar("time")) then
    time="1800"
  end if
  if (.not. isvar("cas")) then
    cas="20150606"
  end if
  if (.not. isvar("direc")) then
    direc="case_lhn15h"
  end if

  ; read files, special name for case 20150606 radar
  f = addfile("/project/d91/aelligr/cosmo_"+cas+"/output/"+direc+"/lfff00"+time+"00.grb","r")
  c = addfile("/project/d91/aelligr/cosmo_20170531/output/case_nolhn/lfff00000000c.nc","r")    

  ; proof if TOT_PREC, then initialise post-process
  if (var .eq. "TOT_PREC" .or. var .eq. "GRAU_GSP") then
    tmp = stringtointeger(time)-100
    time2 = tostring(tmp)

    tmp2 = strlen(time2)
    if (tmp2 .eq. 3) then
      tmp3 = "0"+time2
      time2 = tmp3
      delete(tmp3)
    end if

    delete([/tmp,tmp2/])
    g = addfile("/project/d91/aelligr/cosmo_"+cas+"/output/"+direc+"/lfff00"+time2+"00.grb","r")
  end if

  ; get variables and proof if RADAR and post-process if TOT_PREC
  hsurf = jmb_getvar(c,"HSURF",False)
  if (var .eq. "RADAR") then
    vari = jmb_getvar(f,"TOT_REC",False)
  else
    vari = jmb_getvar(f,var,False)
  end if
  if (var .eq. "TOT_PREC" .or. var .eq. "GRAU_GSP") then
    tmp1 = jmb_getvar(g,var,False)
    tmp2 = vari - tmp1
    vari = (/tmp2/)
    vari@units = "kg m-2 h-1"
    delete([/tmp1,tmp2/])
  end if
  
  ; geo-referencing
  jmb_getgrid(c,c,hsurf,False)
  jmb_getgrid(f,c,vari,False)

  ; cut to make it smaller and center over Thun or Rothrist
  if (cas .eq. "20170531" .or. cas .eq. "20150606") then
    res = True
    res@mpFillOn = False
    res@gsnTickMarksOn = False
    res@gsnDraw = False
    res@gsnFrame = False
    res@gsnMaximize = True 
    res@mpLimitMode = "LatLon"
    res@mpMinLatF = 46.235
    res@mpMaxLatF = 47.425 
    res@mpMinLonF = 6.630
    res@mpMaxLonF = 8.552
    lnres = True
  else
    res = True
    res@gsnAttachBorderOn = False
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
  end if
  ; post-process radar
  if (var .eq. "RADAR") then
    tmp1 = str_split_by_length(time,2)
    minu = stringtointeger(time1)/5
    tmp2(:,:) = vari(minu,:,:)
    vari = (/tmp2/)
    delete([/tmp1,tmp2/])
  end if

  ; which plot depending on which dimension should be done
  if (var .eq. "TOT_PREC" .or. var .eq. "WUPMASK*" .or. \
      var .eq. "RADAR"    .or. var .eq. "DHAILMAX*" .or. \
      var .eq. "DHAILAVE*".or. var .eq. "DHAILSTD*" .or. \
      var .eq. "TQG")	then

   ; set coulour tables
    
   ; plot it
    wks = gsn_open_wks("png",var+time+cas+direc)
    if (var .eq. "TOT_PREC" .or. var .eq. "RADAR") then
      rc = jmb_set_ct(wks, "precip1h_17lev", False)
    else if (var .eq. "WUPMASK*") then
      rc = jmb_set_ct(wks, "precip1h_17lev", False)
    else if (var .eq. "DHAILMAX*" .or. \
	     var .eq. "DHAILAVE*" .or. \
	     var .eq. "DHAILSTD*" ) then
      rc = jmb_set_ct(wks, "precip_hail_9lev", False)
    else if (var .eq. "TQG" ) then
      rc = jmb_set_ct(wks, "precip_lom_inst_15lev", False)
    end if
    end if
    end if
    end if
    mp = jmb_map(wks, hsurf, res)
    cn = jmb_contour(wks, vari, rc)
    r = True
    r@rank = (/20,3,20/)
    r@color = (/"blue", "blue", "blue"/)
    gg = jmb_geography(wks, cn, "cosmo1_latlon", r)
    delete(r)
    plt = jmb_overlays(wks, (/mp,cn/), False)
  end if

  ;if (var .eq. "W" .or. var .eq. "T")

end
