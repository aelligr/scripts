begin
; This ncl scripts can create several plots, depending on input: TOT_PREC, DHAILMAX, DHAILSTD,
; DHAILMEAN, RADAR, TQG.
; The plots have a background of swisstopo.
; The scripts could zoom into a specific area.
  
; input variables should be:	-var	variable to plot
;				-time	time
;				-cas	which case do we take
;				-sett	which settings are taken
;				-zoom	where to zoom, canton Bern or canton Aargau or specify
;				-back	background topo on or off
;				-bord	borders on or off
;				-wat	water on or off
;				-foot	footprint for totprec or not

; Made by aer - Raffael Aellig 10.07.2018
; Update for cases - Raffael Aellig 03.08.2018

;++++++++++++++++++++++++++  INPUT VARIABLES  ++++++++++++++++++++++++++  
; if no variables input, then give'hem some
if (.not. isvar("var") .or. var .eq. "") then
  var="DHAILMAX*"
;  var="REFL_10CM"
;  var="TOT_PREC"
;  var="TQG"
end if
if (.not. isvar("time") .or. time .eq. "") then
  time="2000"
end if
if (.not. isvar("cas") .or. cas .eq. "") then
  cas="150606"
end if
if (.not. isvar("sett") .or. sett .eq. "") then
  sett="case_nolhn"
end if
if (.not. isvar("zoom") .or. zoom .eq. "") then
  zoom="none"
end if


  back="True"


  bord="True"


  wat="True"


  foot="True"


  radar="False"


;++++++++++++++++++++++++++  PREPARE CIRCUMSTANCES  ++++++++++++++++++++++++++
; Prepare Paths
pathsurf = "/project/d91/aelligr/EXP_TST/100/17072106_100/lm_coarse_10min/lfff00000000c.nc"
if (var .eq. "REFL_10CM") then
  tmp = str_split_by_length(cas,2)
  pathfile = "/project/d91/aelligr/radar/MZC/20"+tmp(0)+"/MESH20"+cas+"cosmo1.nc"
  delete(tmp)
else if (radar .eq. "True") then
  pathfile = "/project/d91/aelligr/cosmo_20"+cas+"/output/radar/CPCH_20"+cas+time+"_00060_c1.grib1"
else
  pathfile = "/project/d91/aelligr/cosmo_20"+cas+"/output/"+sett+"/lfff00"+time+"00.grb"
end if
end if

; Prepare for color tables
if (var .eq. "TOT_PREC") then
  ctmap = read_colormap_file("/users/aelligr/ncl_ct_hailcast/precip1h_17lev.ct")
  tmp1 = readAsciiHead("/users/aelligr/ncl_ct_hailcast/precip1h_17lev.ct",4)
  contlev = str_split(tmp1(3)," ")
  minlev = contlev(0)
  tmp2 = dimsizes(contlev)
  maxlev = tmp2-1
  tmp = ctmap(1:tmp2+1,0:3)
  delete(ctmap)
  ctmap = tmp
  delete(tmp)
  delete(tmp1)
  delete(tmp2)
else if (var .eq. "DHAILMAX*" .or. var .eq. "REFL_10CM" .or. var .eq. "TQG") then
  ctmap = read_colormap_file("/users/aelligr/ncl_ct_hailcast/precip_hail_11lev.ct")
  tmp1 = readAsciiHead("/users/aelligr/ncl_ct_hailcast/precip_hail_11lev.ct",4)
  contlev = str_split(tmp1(3)," ")
  minlev = contlev(0)
  tmp2 = dimsizes(contlev)
  maxlev = tmp2-1
  tmp = ctmap(1:tmp2+1,0:3)
  delete(ctmap)
  ctmap = tmp
  delete(tmp)
  delete(tmp1)
  delete(tmp2)
else if (var .eq. "WUPMASK*")
  ctmap = read_colormap_file("/users/aelligr/ncl_ct_hailcast/mask.ct")
  tmp1 = readAsciiHead("/users/aelligr/ncl_ct_hailcast/mask.ct",4)
  contlev = str_split(tmp1(3)," ")
  minlev = contlev(0)
  tmp2 = dimsizes(contlev)
  maxlev = tmp2-1
  tmp = ctmap(0:tmp2,0:3)
  delete(ctmap)
  ctmap = tmp
  delete(tmp)
  delete(tmp1)
  delete(tmp2)
else
  ctmap = read_colormap_file("/users/aelligr/ncl_ct_hailcast/precip1h_17lev.ct")
  tmp1 = readAsciiHead("/users/aelligr/ncl_ct_hailcast/precip1h_17lev.ct",4)
  contlev = str_split(tmp1(3)," ")
  minlev = contlev(0)
  tmp2 = dimsizes(contlev)
  maxlev = tmp2-1
  tmp = ctmap(1:tmp2,0:3)
  delete(ctmap)
  ctmap = tmp
  delete(tmp)
  delete(tmp1)
  delete(tmp2)
end if
end if
end if


;++++++++++++++++++++++++++  READ IN FILES  ++++++++++++++++++++++++++
f = addfile(pathfile,"r")
c = addfile(pathsurf,"r")


;++++++++++++++++++++++++++  GET VARIABLES  ++++++++++++++++++++++++++
hsurf = jmb_getvar(c,"HSURF",False)
if (var .eq. "REFL_10CM") then
  tmp = jmb_getvar(f,var,False)
  vari = tmp(0,:,:)
  delete(tmp)
else
  vari = jmb_getvar(f,var,False)
end if

;++++++++++++++++++++++++++  MANIPULATE VARIABLES  +++++++++++++++++++++
if (radar .eq. "True") then
  vari@long_name = " Total Precipitation Amount ~C~ Radar based"
  vari@units = "kg m-2 -h"
else if (var .eq. "REFL_10CM") then
  vari@description = " Maximum Expected Severe Hail Size ~C~ Radar based"
  vari@units = "mm"
else if (var .eq. "DHAILMAX*") then
  vari@long_name = " Maximum Size of Hail Diameter ~C~ COSMO-1 Forecast"
  vari@units = "mm"
else if (var .eq. "TQG") then
  vari@long_name = " Total Graupel content ~C~ vertically integrated - TQG ~C~ COSMO-1 Forecast"
end if
end if
end if
end if

;++++++++++++++++++++++++++  POST-PROCESSING  ++++++++++++++++++++++++++
; Post-process for TOT_PREC not footprint
if (foot .eq. "False" .and. var .eq. "TOT_PREC" .and. radar .eq. "False") then
  tmp = stringtointeger(time)-100
  time2 = tostring(tmp)
  tmp2 = strlen(time2)
  if (tmp2 .eq. 3) then
    tmp3 = "0"+time2
    time2 = tmp3
    delete(tmp3)
  end if
  tmp4 = str_split(pathfile,"f")
  g = addfile(tmp4(0)+"fff00"+time2+"00.grb","r")
  delete([/tmp,tmp2/])
  delete(tmp4)

; Get variables from time step before
  tmp1 = jmb_getvar(g,var,False)
  tmp2 = vari - tmp1
  delete(vari)
  vari = (/tmp2/)
  vari@units = "kg m-2 h-1"
  vari@long_name = " Total Precipitation Amount ~C~ COSMO-1 Forecast"
  delete([/tmp1,tmp2/])
end if

;++++++++++++++++++++++++++  GEO-REFERENCING  ++++++++++++++++++++++++++
; Georeference hsurf
latlon = str_split(hsurf@coordinates, " ")
lat2d = c->$latlon(0)$
lon2d = c->$latlon(1)$
lat2d = c->$latlon(1)$
lon2d = c->$latlon(0)$
pole = c->grid_mapping_1
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude
nlat = dimsizes(lat2d(:,0))
nlon = dimsizes(lon2d(0,:))
hsurf@lat2d = lat2d
hsurf@lon2d = lon2d
vari@lat2d = lat2d
vari@lon2d = lon2d

; Make the zoom or do not
if (zoom .eq. "bern") then
  leftlat = 46.000
  leftlon = 6.500
  rightlat= 47.800      
  rightlon= 8.900
else if (zoom .eq. "aargau")
  leftlat = 46.400
  leftlon = 6.200
  rightlat= 47.900
  rightlon= 9.000
else
  leftlat = lat2d(295,345)
  leftlon = lon2d(295,345) 
  rightlat= lat2d(554,754)
  rightlon= lon2d(554,754)
end if
end if

;++++++++++++++++++++++++++  Plotting  ++++++++++++++++++++++++++
; Define file type and open workstation
ptype = "pdf"              ; send graphics to PNG file
if (radar .eq. "True") then
  var = "radar"
end if
wks = gsn_open_wks(ptype,var+cas+time)

; set up resource for variable
res                        = True
res@mpProjection           = "CylindricalEquidistant"
res@mpCenterLonF           = pole_lon + 180.
res@mpCenterLatF           = 90. - pole_lat
res@mpLimitMode            = "Corners"
res@mpLeftCornerLatF       = leftlat
res@mpLeftCornerLonF       = leftlon
res@mpRightCornerLatF      = rightlat
res@mpRightCornerLonF      = rightlon

; Set up colour stuff
res@gsnMaximize            = True             ; maximize plot in frame
res@cnFillOn               = True             ; turn on color 
res@cnFillOpacityF         = 1.0              ; set the opacity
res@cnFillPalette          = ctmap            ; set color map

res@cnLinesOn              = False            ; no contour lines
res@cnLineLabelsOn         = False            ; no contour labels
res@mpDataBaseVersion      = "MediumRes"      ; use finer database
res@mpInlandWaterFillColor = -1               ; use trasnparent for inland water fill
res@mpLandFillColor        = -1               ; use trasnparent for land fill
res@cnMinLevelValF       = minlev          ; contour levels.
res@cnMaxLevelValF       = maxlev
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels             = contlev
res@cnLevelSpacingF      = 5

res@lbLabelBarOn           = True
res@lbOrientation          = "vertical"
;res@pmTickMarkDisplayMode  = "conditional"
;res@gsnAddCyclic           = False
;res@lbLabelFontHeightF     = 0.015
;res@lbLabelAutoStride      = True
res@lbLabelStride          = 1

pl = gsn_csm_contour_map(wks, vari, res) 


;++++++++++++++++++++++++++  Add borders, rivers, lakes, etc.  ++++++++++++++++++++++++++
; Add borders to plot
if (bord .eq. "True") then
  ; Read Ascii borders and process
  z=asciiread("$NCL_COSMOLIB/data/db_ciaII/cosmo1_latlon/"+"bdy-1.txt",-1,"float")
  nz=dimsizes(z)/2
  zz=onedtond(z,(/nz,2/))
  zz@_FillValue=-999.0
  delete(z)
  delete(nz)
  y=zz(:,0)
  x=zz(:,1)
  delete(zz)

  ; Add resources
  rbord=True
  rbord@gsLineColor=1
  rbord@gsLineThicknessF=(/1,1,1/)
  idbord = gsn_add_polyline(wks,pl,x,y,rbord)
  delete(rbord)
  delete(x)
  delete(y)
end if

; Add rivers and lakes to plot
if (wat .eq. "True") then

  ; Add Rivers
  fs = systemfunc("cd $NCL_COSMOLIB/data/db_ciaII/cosmo1_latlon/; ls riv*")
  ; Do loop over the amount of river files
  idriv=new(2000,graphic)
  ni = 0
  do i=0,dimsizes(fs)-1
    ; Read Ascii rivers and process
    z=asciiread("$NCL_COSMOLIB/data/db_ciaII/cosmo1_latlon/"+fs(i),-1,"float")
    nz=dimsizes(z)/2
    zz=onedtond(z,(/nz,2/))
    zz@_FillValue=-999.0
    delete(z)
    delete(nz)
    y=zz(:,0)
    x=zz(:,1)
    delete(zz)

    ; Add resources
    rwat=True
    rwat@gsLineColor=45
    rwat@gsLineThicknessF=(/1,1,1/)
    n=dimsizes(ind(ismissing(x)))
    idriv(ni:ni+n-1)=gsn_add_polyline(wks,pl,x,y,rwat)
    ni = ni + n
    delete(rwat)
    delete(y)
    delete(x)
  end do
  delete(ni)
  delete(fs)

  ; Add Lakes
  fs = systemfunc("cd $NCL_COSMOLIB/data/db_ciaII/cosmo1_latlon/; ls cil*")
  ; Do loop over the amount of river files
  idcil=new(2000,graphic)
  ni = 0
  do i=0,dimsizes(fs)-1
    ; Read Ascii rivers and process
    z=asciiread("$NCL_COSMOLIB/data/db_ciaII/cosmo1_latlon/"+fs(i),-1,"float")
    nz=dimsizes(z)/2
    zz=onedtond(z,(/nz,2/))
    zz@_FillValue=-999.0
    delete(z)
    delete(nz)
    y=zz(:,0)
    x=zz(:,1)
    delete(zz)

    ; Add resources
    rwat=True
    rwat@gsLineColor=55
    rwat@gsLineThicknessF=(/1,1,1/)
    n=dimsizes(ind(ismissing(x)))
    idcil(ni:ni+n-1)=gsn_add_polyline(wks,pl,x,y,rwat)
    ni = ni + n
    delete(rwat)
    delete(y)
    delete(x)
  end do
  delete(ni)
  delete(fs)

end if

draw(pl)

frame(wks)

end
