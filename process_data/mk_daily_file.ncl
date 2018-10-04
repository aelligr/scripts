begin

; LOAD DATA
helpfile = addfile("/project/d91/aelligr/radar/MZC/2017/helpfile.nc","w")
f = addfile("/project/d91/aelligr/radar/MZC/2017/V0_MESHS_2017.nc","r")

; THE DO LOOP
do day = 202,243

; GET OUT VARIABLES
varhelp = helpfile->REFL_10CM
var = f->MESHS(:,:,day)
g = new((/1,640,710/),"double")

; SET TO 0 WHERE NO DATA AND CHANGE FORMAT
do i = 0,639
  do j = 0,709
    if (var(i,j) .eq. 255) then
       var(i,j) = 0
     end if
     g(0,639-i,j) = var(i,j)            ; THIS IS DUE TO UPSIDE DOWN OF THE V0_...-FILE
  end do
end do
tmp = doubletofloat(g)
delete(g)
g = tmp
delete(tmp)

; WRITE TO THE APPROPRIATE VARIABLE
helpfile->REFL_10CM = g

; GIVE THE NEW FILE A NEW NAME
system("cp /project/d91/aelligr/radar/MZC/2017/helpfile.nc /project/d91/aelligr/radar/MZC/2017/MESHS"+day)

; CLEAR
delete(varhelp)
delete(var)
delete(g)
delete((/i,j/))

end do
; END DO LOOP

end
