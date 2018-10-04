; This verification scripts read into the hole month of july and compares the forecast with the 
; measurements of mesh. The output is a skill of how well the forecast performed. The application is
; to compare several summarized grids with its summarized mesh in a footprint.

; What the scritps needs:
;	- paths to the mesh and lfff files
;	- mesh sizes
;	- what do you want to compare: TQG or DHAILMAX
;	- Making Plots?
begin

;++++++++++++++++++++++++++++ DEFINE CIRCUMSTANCES +++++++++++++++
pathforc = "/project/d91/aelligr/footprints/2017/"
pathmesh = "/project/d91/aelligr/radar/MZC/2017/"
pathskill = "/project/d91/aelligr/skill"
pathsurf = "/project/d91/aelligr/EXP_TST/100/17073006_100/lm_coarse_10min/lfff00000000c.nc"

; grid distance to take into account
dist = 10
n_regions = 100000/dist/dist
di = tostring(dist)
no_for_no_mesh = 0
ys_for_no_mesh = 0
no_for_ys_mesh = 0
ys_for_ys_mesh = 0
count = 0

; Plot make and table make
make_plot = "True"

; Season on or off, start and end month
stmo=6
endmo=6

; TQG or DHAILMAX
compa = "TQG"

; Set Threshold
th_mesh = 20
th_tqg = 10
th_dhail = 20

; to name the file
if (compa .eq. "TQG") then
  threshold = tostring(th_tqg)
  thresh = th_tqg
else
  threshold = tostring(th_dhail)
  thresh = th_dhail
end if

;++++++++++++++++++++++++++++ LOOP OVER Season +++++++++++++++++++
do month = stmo,endmo	; loop month
  if (month .eq. 6) then
    mon = "june"
  else if (month .eq. 7) then
    mon = "july"
  else
    mon = "august"
  end if
  end if

; Prepare for missing files
missf = systemfunc("ls "+pathforc+mon+"/20170*")
tmp = dimsizes(missf)
daylist = new(tmp,"string")
delete(tmp)
do l = 0,dimsizes(missf)-1
  tmp1 = str_split(missf(l),"/")
  tmp2 = str_split_by_length(tmp1(6),6)
  tmp3 = str_split_by_length(tmp2(1),2)
  daylist(l) = tmp3(0)
  delete(tmp1)
  delete(tmp2)
  delete(tmp3)
end do
delete(missf)

;++++++++++++++++++++++++++++ LOOP OVER MONTH ++++++++++++++++++++
; Loop in month
 if (month .eq. 6) then
   dend = 30
 else
   dend = 31
 end if
 do d = 15,15
; jump stuff
  if (d .lt. 10) then
    day = "0"+tostring(d)
  else
    day = tostring(d)
  end if
print(day)
 if (any(daylist .eq. day))
   ; go on
 else
   continue
 end if

;++++++++++++++++++++++++++++ READ IN ++++++++++++++++++++++++++++
f = addfile(pathforc+mon+"/20170"+month+day+"footprint.nc", "r")
m = addfile(pathmesh+"MESH20170"+month+day+"cosmo1.nc", "r")

;++++++++++++++++++++++++++++ GET VARIABLES ++++++++++++++++++++++
if (compa .eq. "TQG") then
  dhailmax = f->TQG_foot
else
  dhailmax = f->DHAILMAX_GDS10_SFC
end if
mesh = m->REFL_10CM

;++++++++++++++++++++++++++++ CREATE SKILL +++++++++++++++++++++++
skill = mesh

skill(0,:,:) = -1
do i = 350, 749, dist
  do j = 300, 549, dist
    tmp_mesh = max(mesh(0,j:j+dist-1,i:i+dist-1))
    tmp_forc = max(dhailmax(0,j:j+dist-1,i:i+dist-1))
    if (tmp_mesh .lt. th_mesh .and. tmp_forc .lt. thresh) then
      skill(0,j:j+dist-1,i:i+dist-1) = 3
      no_for_no_mesh = no_for_no_mesh + 1
    else if (tmp_mesh .lt. th_mesh .and. tmp_forc .ge. thresh) then
      skill(0,j:j+dist-1,i:i+dist-1) = 7
      ys_for_no_mesh = ys_for_no_mesh + 1
    else if (tmp_mesh .ge. th_mesh .and. tmp_forc .lt. thresh) then
      skill(0,j:j+dist-1,i:i+dist-1) = 5
      no_for_ys_mesh = no_for_ys_mesh + 1
    else if (tmp_mesh .ge. th_mesh .and. tmp_forc .ge. thresh) then
      skill(0,j:j+dist-1,i:i+dist-1) = 9
      ys_for_ys_mesh = ys_for_ys_mesh + 1
    end if
    end if
    end if
    end if
    delete((/tmp_mesh,tmp_forc/))
  end do ; j
end do ; i

delete(f)
delete(m)
delete(dhailmax)
delete(mesh)

 count = count + 1
 print(count)
 end do ; d
 d = d - 1

print("no_for_no_mesh: "+no_for_no_mesh)
print("ys_for_no_mesh: "+ys_for_no_mesh)
print("no_for_ys_mesh: "+no_for_ys_mesh)
print("ys_for_ys_mesh: "+ys_for_ys_mesh)

delete(daylist)
end do ; month
month = month - 1

;++++++++++++++++++++++++++++ READ IN SURFACE +++++++++++++++++++
s = addfile(pathsurf,"r")
hsurf = jmb_getvar(s,"HSURF",False)

;++++++++++++++++++++++++++++ CHANGE SKILL ATTRIBUTES +++++++++++
skill@data        = "Radar and forecast"
skill@description = compa+" of Forecast compared with MESHS ~C~"+day+".0"+month+".2017"
skill@units       = ""


;++++++++++++++++++++++++++++ COLOR TABLE +++++++++++++++++++++++
ctmap = read_colormap_file("/users/aelligr/ncl_ct_hailcast/skilltable.ct")
tmp1 = readAsciiHead("/users/aelligr/ncl_ct_hailcast/skilltable.ct",5)
contlev = str_split(tmp1(4)," ")
minlev = contlev(0)
tmp2 = dimsizes(contlev)
maxlev = tmp2-1
delete(tmp1)
delete(tmp2)


;++++++++++++++++++++++++++  GEO-REFERENCING  ++++++++++++++++++++++++++
; Georeference hsurf
latlon = str_split(hsurf@coordinates, " ")
lat2d = s->$latlon(0)$
lon2d = s->$latlon(1)$
lat2d = s->$latlon(1)$
lon2d = s->$latlon(0)$
pole = s->grid_mapping_1
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude
nlat = dimsizes(lat2d(:,0))
nlon = dimsizes(lon2d(0,:))
hsurf@lat2d = lat2d
hsurf@lon2d = lon2d
skill@lat2d = lat2d
skill@lon2d = lon2d

leftlat = lat2d(295,345)
leftlon = lon2d(295,345) 
rightlat= lat2d(554,754)
rightlon= lon2d(554,754)

if (make_plot .eq. "True") then

;++++++++++++++++++++++++++  Plotting  ++++++++++++++++++++++++++
; Define file type and open workstation
ptype = "pdf"              ; send graphics to PNG file
wks = gsn_open_wks(ptype,"season"+compa+"_20170"+month+day+"_"+di+"_"+threshold)

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
res@cnLevelSpacingF      = 1

res@lbLabelBarOn         = False

pl = gsn_csm_contour_map(wks, skill(0,:,:), res) 

;++++++++++++++++++++++++++  Add borders, rivers, lakes, etc.  ++++++++++++++++++++++++++
; Add borders to plot

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


; Add rivers and lakes to plot

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
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  txres               = True
  txres@txFontHeightF = 0.02

  txres@txFontColor   = "Grey"
  txres@txJust        = "CenterLeft"
  gsn_text_ndc(wks,"Expected Hail size < "+th_dhail+" mm     MESHS < "+th_mesh+" mm",0.01,0.125,txres) 

  txres@txFontColor   = "Red"
  txres@txJust        = "CenterLeft"
  gsn_text_ndc(wks,"Expected Hail size < "+th_dhail+" mm     MESHS > "+th_mesh+" mm",0.01,0.1,txres) 

  txres@txFontColor   = "Blue"
  txres@txJust        = "CenterLeft"
  gsn_text_ndc(wks,"Expected Hail size > "+th_dhail+" mm     MESHS < "+th_mesh+" mm",0.01,0.075,txres) 

  txres@txFontColor   = "Green"
  txres@txJust        = "CenterLeft"
  gsn_text_ndc(wks,"Expected Hail size > "+th_dhail+" mm     MESHS > "+th_mesh+" mm",0.01,0.05,txres)


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

draw(pl)

frame(wks)

end if

end



