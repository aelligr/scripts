; This makes a footprint out of the hole days data from FORECAST
begin


;+++++++ DEFINE PATHS +++++++
path = "/project/d91/aelligr/EXP_TST/100/1707"+day+"06_100/lm_coarse_10min/"

;+++++++ CIRCUMSTANCES +++++++
system("cp "+path+"lfff00000000.nc "+path+"201707"+day+"footprint.nc")

;+++++++ READ IN INITIAL FILE +++++++
f = addfile(path+"201707"+day+"footprint.nc","w")
hailfoot = f->CLCH
hailfoot = 0
TQG_foot = f->CLCT
TQG_foot = 0

;+++++++ BEGIN LOOP +++++++
do hour = 0,24,1
  do minu = 0,50,10
    hour_string = tostring(hour)
    minu_string = tostring(minu)
    if (strlen(hour_string) .eq. 1) then
      hour_string = "00"+hour_string
    else
      hour_string = "0"+hour_string
    end if
    if (strlen(minu_string) .eq. 1) then
      minu_string = "0"+minu_string
    end if
    if (hour .eq. 24) then
      hour_string = "100"
      minu = 50
    end if
    g = addfile(path+"lfff0"+hour_string+minu_string+"00.grb","r")
    hailnew = g->DHAILMAX_GDS10_SFC
    TQG_new = g->TQG
    print("hour: "+hour_string+" | min: "+minu_string)
    system("date")

;+++++++ OVERWRITE FILES +++++++
    do x = 0,773
      do y = 0,1157
        if (TQG_new(x,y)*6 .gt. TQG_foot(0,x,y))
          TQG_foot(0,x,y) = (/TQG_new(x,y)*6/)
        end if
        if (hailnew(x,y) .gt. hailfoot(0,x,y)) then
          hailfoot(0,x,y) = (/hailnew(x,y)/)
        end if
      end do
    end do

    delete(g)

;+++++++ END LOOP +++++++
  end do ; min
end do ; hour

;+++++++ WRITING BACK TO NETCDF +++++++
f->CLCH = hailfoot
f->CLCH@units = "mm"
f->CLCH@long_name = "Maximum Hail Diameter"
system("ncrename -h -O -v CLCH,DHAILMAX_GDS10_SFC "+path+"201707"+day+"footprint.nc")
f->CLCT = TQG_foot
f->CLCT@units = "kg m-2"
f->CLCT@long_name = "Total vertical integrated graupel"
system("ncrename -h -O -v CLCT,TQG_foot "+path+"201707"+day+"footprint.nc")
system("sleep 3")
system("mv "+path+"201707"+day+"footprint.nc /project/d91/aelligr/footprints/2017/july/")
print("Finished and moved footprint 201707"+day)

end

