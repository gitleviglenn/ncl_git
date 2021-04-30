;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega_mn_rce.ncl
;
; compute the circulation intensity, mean upward and downward vertical velocity for crms
;
; input: scalef: a scaling factor to convert wa500 from m/s to hPa/day
;
; output: circulation intensity, subsidence fraction, mean upward and downward velocity
;
; output can be computed on the native grid or on a grid composed of 96x96 km2 block or
; of 192x192 km2 blocks.  use the 'make_coarse' switch: 
; make_coarse = True
;
; The values for the circulation intensity and the subsidence fraction don't match those
; from Cronin and Wing, 2017 for SAM.  Why not? The intensity is too large and SF too small.  
;
; These values of SF also don't match those shown in Wing et al., 2020 for SAM RCEMIP.
; in Wing et al., the SF is defined as the area fraction where the daily-average large-scale
; vertical velocity at 500 hPa is directed downward.  The SF is computed over blocks that
; are about 100kmX100km.  
;
; levi silvers                                                    march 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; read input data from calling script:
if (isvar("model")) then
  modelname=model
else 
 modelname="CAM5"
end if
if (isvar("seaST")) then
  SST=seaST
else 
  SST="295"
end if
if (isvar("textfile")) then
  foutname=textfile
else
  foutname="profiles_mn.txt"
end if
if (isvar("chunkdays")) then
  ndays=chunkdays
else
  ndays=5
end if
  print("number of days in each averaging chunks is: "+ndays)
if (isvar("datafreq")) then
  freq=datafreq  ;[time per day] most models this is 1 hr;24 times/day, for IPSL it is 1 day
else
  freq=24
end if
timewindow=ndays*freq

if (isvar("nperiods")) then
  numperiods=nperiods
else
  numperiods=10
end if
  print("number of averaging periods is: "+numperiods)

if (isvar("lasttime")) then
  endtime=lasttime
  print("lasttime var read, endtime is:  "+endtime)
else
  endtime=2399 ; ICON GCM has fewer timesteps that CAM or ECHAM
  print("lasttime var not detected, endtime is:  "+endtime)
end if

timelenght=endtime-timewindow*numperiods
startime  =endtime-timewindow*numperiods+1

print("startime for reading data is: "+startime+" and end time is: "+endtime)
;==========================
; path bases
pch="/glade/scratch/levi/RCEMIP/"

file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wa500.nc"
file_ta        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_ta_avg.nc"
  print("file_om is: "+file_om)
;fa_ta       =addfile(file_ta,"r")
fc_om       =addfile(file_om,"r")
if (omega .lt. 1) then
  wvar_a=fc_om->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_a=fc_om->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

Rd        =287.        ; J/kg K gas constant for dry air

;ta_a=fa_ta->ta_avg(startime:endtime,:)
;z_a =fa_ta->z(:)
;p_a =fa_ta->p(:)
x_orig = fc_om->x
y_orig = fc_om->y

;ta_mn = dim_avg_n(ta_a,0) 
;  print("mean vertical field: first temp: "+ta_mn+" z: "+z_a+" p (hPa): "+p_a+" and density: "+p_a*100/(Rd*ta_mn))

wvar_a=scalef*wvar_a
  print("scaleing by factor: "+scalef)
wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;  printVarSummary(wvar_a)

;-----------------------------------------------
;y_new=fspan(0,384000,5)
;x_new=fspan(0,5952000,63)
;
y_new=fspan(0,384000,3)
x_new=fspan(0,5952000,33)
;  end if
;    print("original y array is: "+y_orig)
;    print("new y array is: "+y_new)
;    print("new x array is: "+x_new)
var_to_interpolate=wvar_a ; incoming CRM data
;  ; var_to_interpolate must have y,x as its two rightmost dimensions...
juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,False)
intvar_out=juljack
  printVarSummary(intvar_out)

;*************************************************************
; parse out the ascending and descending regions and comp SF
;-------------------------------------------------------------
subfrac_array = new((/24,ndays*numperiods,dim_om(1),dim_om(2)/),float)

make_coarse = True
if (make_coarse) then
    print("using coarse grid")
  omega_u_a      =where((intvar_out .le. 0),intvar_out,intvar_out@_FillValue)
  omega_u_a_frac =where((intvar_out .le. 0),1.0,0.0)
  omega_d_a      =where((intvar_out .ge. 0),intvar_out,intvar_out@_FillValue)
  omega_d_a_frac =where((intvar_out .ge. 0),1.0,0.0)
  subfrac_array  =reshape(intvar_out,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
else
    print("using original grid")
  omega_u_a      =where((wvar_a .le. 0),wvar_a,wvar_a@_FillValue)
  omega_u_a_frac =where((wvar_a .le. 0),1.0,0.0)
  omega_d_a      =where((wvar_a .ge. 0),wvar_a,wvar_a@_FillValue)
  omega_d_a_frac =where((wvar_a .ge. 0),1.0,0.0)
  subfrac_array  =reshape(wvar_a,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
end if

omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
dim_om=dimsizes(omega_u_a)

;subfrac_array = new((/24,ndays*numperiods,dim_om(1),dim_om(2)/),float)
;subfrac_array = reshape(wvar_a,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
;subfrac_array = reshape(intvar_out,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
; take daily average

; compute time averaged subsidence fraction
subfrac_a     = dim_avg_n(subfrac_array,0)

  print(" checking the reshapeing... ")
  print(wvar_a(10,10,10))
  print(subfrac_array(10,0,10,10))
  print(wvar_a(34,10,10))
  print(subfrac_array(10,1,10,10))
  print(" end checking the reshapeing... ")

;----------------
; coarsen the grid of the CRM to something like a GCM
;----------------
;
lentime = ndays*numperiods
;
;; parameters for grid blocks of 192km
;block_array = new((/lentime,2,32/),float)
;block=floattointeger(64) ; block size for grid spacing of 192km
;iend = 1 ; for 2048 gridpoints, there are 32 blocks of 64
;jend = 31 ; for 128 gridpoints, there are two blocks of 64

; parameters for grid blocks of 96km
block_array = new((/lentime,4,64/),float)
block=floattointeger(32) ; block size for grid spacing of 96km
iend = 3 ; for 2048 gridpoints, there are 32 blocks of 64
jend = 63 ; for 128 gridpoints, there are two blocks of 64

; subfrac_a is 3D
do tindex=0,lentime-1
do i=0,iend
  icounter=i*block
  do j=0,jend
    jcounter=j*block
    block_single   =subfrac_a(tindex,icounter:icounter+block-1,jcounter:jcounter+block-1)
    block_array(tindex,i,j)=avg(block_single)
  end do
end do
end do

;----------------

;subfrac_a = dim_avg_n(subfrac_array,0)
  ;subfrac            = where((subfrac_a .le. 0),1.0,0.0)
  subfrac            = where((block_array .le. 0),1.0,0.0)
  subfrac@_FillValue = default_fillvalue("float")    ; set devault FillValue

  ;printVarSummary(omega_d_a)
  ;printVarSummary(subfrac_array)
  printVarSummary(subfrac)
subfrac_b = dim_avg_n(subfrac,1)
  print("dimsizes of subfrac_b are: "+dimsizes(subfrac_b))
subfrac_c = dim_avg_n(subfrac_b,1)
  print("dimsizes of subfrac_c are: "+dimsizes(subfrac_c))
subfrac_d = dim_avg_n(subfrac_c,0)
  printVarSummary(subfrac_c)
  printVarSummary(subfrac_d)
  print("the subsidence fraction ISISISIS: "+subfrac_d)

  print("first dimension of omega_u_a: "+dim_om(1))
  print("second dimension of omega_u_a: "+dim_om(2))

total_area=dim_om(1)*dim_om(2)
;omega_temp =new((/1,nlat,nlon/),float)
sfrac      =new((/dim_om(0)/),float)
sfrac_up   =new((/dim_om(0)/),float)
do tt=0,dim_om(0)-1
  ;omega_temp(1,:,:)=omega_u_a_frac(tt,:,:)
  omega_temp2  =omega_u_a_frac(tt,:,:)
  omega_temp3  =omega_d_a_frac(tt,:,:)
  sfrac_up(tt) =sum(omega_temp2)/total_area
  sfrac(tt)    =sum(omega_temp3)/total_area
end do
  print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" and fraction of ascending air is: "+sfrac_up(10))

;*************************************************************
; compute cosine weighting
;-------------------------------------------------------------
if (CRM .lt. 1)
    print("applying cosine weighted averaging")
  lat  = LAT_out
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  
  intvar_u_ave  = wgt_areaave(omega_u_a,clat,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,clat,1.0,0)
    ;printVarSummary(intvar_u_ave)
else;  no weighting for CRM models
    print("not applying cosine weighted averaging")
  intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
end if
;  print("the crm loop doesn't do anything yet")
;  if (isvar("flippeddim")) then  ; ICON LEM
;    x_new=fspan(0,384000,5)
;    y_new=fspan(0,5952000,63)
;  else                           ; SAM
;y_new=fspan(0,384000,5)
;x_new=fspan(0,5952000,63)
;;  end if
;;    print("original y array is: "+y_orig)
;;    print("new y array is: "+y_new)
;;    print("new x array is: "+x_new)
;var_to_interpolate=wvar_a ; incoming CRM data
;;  ; var_to_interpolate must have y,x as its two rightmost dimensions...
;juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,False)
;intvar_out=juljack
;  printVarSummary(intvar_out)
;*************************************************************
; compute circulation intensity 
;-------------------------------------------------------------

; omega up and omega dn
;
;omega_up = dim_avg_n(intvar_u_ave,0)
;omega_dn = dim_avg_n(intvar_d_ave,0)
omega_up = dim_avg_n(intvar_u_ave,0)
omega_dn = dim_avg_n(intvar_d_ave,0)
  ;print("omega_dn is equal to: "+omega_dn)
  ;print("omega_up is equal to: "+omega_up)

circulation_int = omega_dn-omega_up

;-------------------------------------------------------------

  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print(">>>>>>>>>>>>")

;-------------------------------------------------------------



end
