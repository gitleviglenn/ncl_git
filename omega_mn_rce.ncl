;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega_mn_rce.ncl
;
; calculate the mean upward omega, mean downward omega, and subsidence frac
;
; only computes statistics for 2D omega related data.  
; does not compute omega_db, stability or lapse rates. 
;
; generalize to chunks?  
;
; normal = 0 can refer to cam5, cam6, or geos
; normal = 1 refers to SP-CAM
;
; variables needed for this script: 
;   2D_psl
;   2D_wap500
;
; across the model ensemble, some variables have different names and/or dimensions: 
; wap500
; zg_avg
;
; data abnormalities: 
;  SP-CAM: 1D_z_avg instead of 1D_zg_avg
;  SP-CAM: appears to not have 2D_tas, or 1D_pa_avg, do we need 2D_tas in this script??
; 
; pressure and surface temperature are needed to compute sigma profiles but we can
; assume the surface temperature to be given.
;
; the 2D data that is needed for this script to work is: wap500, tas, and psl 
;
; /glade/work/kareed/data_analysis/rce_world/omega_pdf.ncl 
;
; output mn omega up, mn omega dn, I, and subsidence fraction to a txt file.
;
; levi silvers                                                          may 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;==========================
; define parameters

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

if (isvar("UKMOfix")) then
  vfix=1
else
  vfix=0
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

  print("data freq not detected, freq is: "+freq)
  print("SST is : "+seaST)

if (isvar("nperiods")) then
  numperiods=nperiods
else
  numperiods=73
end if
  print("number of averaging periods is: "+numperiods)
if (isvar("lasttime")) then
  endtime=lasttime
  print("lasttime var read, endtime is:  "+endtime)
else
  endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
  print("lasttime var not detected, endtime is:  "+endtime)
end if

timelenght=endtime-timewindow*numperiods
startime  =endtime-timewindow*numperiods+1

  print("startime for reading data is: "+startime+" and end time is: "+endtime)

;==========================
; define file locations via paths 

pch="/glade/scratch/levi/RCEMIP/"

; this is a confusing  parameter
normal = notnormal

;*************************************************************
; read variables
;---------------------------------------------------------
if (isvar("CAMGCM")) then
  whichCAM=CAMGCM
  if (CAMGCM .lt. 6) then
    cam="CAM5_GCM/RCE_large"
  else 
    cam="CAM6_GCM/RCE_large"
  end if
  file_om     =pch+cam+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_wap500.nc"
  if (normal .lt. 1) then  ; for non CAM models with 'normal' data files
  end if
else
  file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wap500.nc"
  if (normal .lt. 1) then  ; for non CAM models with 'normal' data files
  else ; something about the model data is abnormal (e.g. z_avg instead of zg_avg)
    if (vfix .lt. 1) then
    else
      file_om      =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wa500.nc"
    end if
  end if
end if

fc_om       =addfile(file_om,"r")

normal = notnormal

  print("OMEGA VALUES IS: "+omega)
if (omega .lt. 1) then
  wvar_a=fc_om->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  if (vfix .lt. 1) then
    wvar_a=fc_om->wa500(startime:endtime,:,:)
  else 
    wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
  end if
else if (omega .lt. 3) then
  wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;==========================
; process vertical velocity
; compute the mean upward and downward omega velocities

; scale vertical velocity
; convert units to hPa/d 
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is 6042 ?!! 

wvar_a=scalef*wvar_a

;----------------------------
if (isvar("RCE_GCM"))
; perform regridding to 1x1 degree lat lon
  print("begin interpolation...")

  var_to_interpolate=wvar_a
  if (isvar("longdimnames")) then
    var_to_interpolate!1="lat"
    var_to_interpolate&lat=wvar_a&latitude
    var_to_interpolate!2="lon"
    var_to_interpolate&lon=wvar_a&longitude
  else
    var_to_interpolate!1="lat"
    var_to_interpolate&lat=wvar_a&lat
    var_to_interpolate!2="lon"
    var_to_interpolate&lon=wvar_a&lon
  end if

  dim_orig=dimsizes(var_to_interpolate)
  nlat=dim_orig(1)
  nlon=dim_orig(2)

  latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
  latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

  opt = False
  NLAT1x1       = 180                               ; RES   = "180x288"
  MLON1x1       = 360
  LAT_out       = latGlobeFo(NLAT1x1, "LAT_out_temp", "latitude" , "degrees_north")
  LON_out       = lonGlobeFo(MLON1x1, "LON_out", "longitude", "degrees_east" )

  interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_out, LAT_out, opt)

  intvar_out=interpolated_var
  intvar_out!0="time"
  intvar_out!1="lat"
  intvar_out!2="lon"
else
end if  ; end interpolation loop
  print("interpolation finished")
  ;printVarSummary(intvar_out)
;----------------------------

;*************************************************************
; parse out the ascending and descending regions and comp SF
;-------------------------------------------------------------

omega_u_a      =where((intvar_out .le. 0),intvar_out,intvar_out@_FillValue)
omega_u_a_frac =where((intvar_out .le. 0),1.0,0.0)
omega_d_a      =where((intvar_out .ge. 0),intvar_out,intvar_out@_FillValue)
omega_d_a_frac =where((intvar_out .ge. 0),1.0,0.0)

omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

  ;printVarSummary(omega_u_a)
dim_om=dimsizes(omega_u_a)
  print("first dimension of omega_u_a: "+dim_om(1))
  print("second dimension of omega_u_a: "+dim_om(2))
total_area=dim_om(1)*dim_om(2)
;omega_temp =new((/1,nlat,nlon/),float)
sfrac      =new((/dim_om(0)/),float)
sfrac_up   =new((/dim_om(0)/),float)
do tt=0,dim_om(0)-1
  ;omega_temp(1,:,:)=omega_u_a_frac(tt,:,:)
  omega_temp2=omega_u_a_frac(tt,:,:)
  omega_temp3=omega_d_a_frac(tt,:,:)
  sfrac_up(tt)=sum(omega_temp2)/total_area
  sfrac(tt)=sum(omega_temp3)/total_area
end do
if (scalef .gt. 1000.)
    print("Scale factor larger than 1000!! ")
  sf=dim_avg_n(sfrac,0)
  subsidenceF=1-sf
else
  sf=dim_avg_n(sfrac,0)
  subsidenceF=sf
end if

;subsidenceF=
  print("time averaged subsidence fraction: "+subsidenceF)
  print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" and fraction of ascending air is: "+sfrac_up(10))

;*************************************************************
; compute cosine weighting
;-------------------------------------------------------------
if (CRM .lt. 1)
  lat  = LAT_out
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  
  intvar_u_ave  = wgt_areaave(omega_u_a,clat,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,clat,1.0,0)
    ;printVarSummary(intvar_u_ave)
else;  no weighting for CRM models
  intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
end if
;*************************************************************
; compute circulation intensity 
;-------------------------------------------------------------

; omega up and omega dn
;
omega_up = dim_avg_n(intvar_u_ave,0)
omega_dn = dim_avg_n(intvar_d_ave,0)

circulation_int = omega_dn-omega_up

;-------------------------------------------------------------

  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print(">>>>>>>>>>>>")

;-------------------------------------------------------------

; sfrac_dn is subsidence fraction.  use it to weight the up and down omega
w_up=intvar_u_ave*sfrac_up
w_dn=intvar_d_ave*sfrac_up
wav_up = dim_avg_n(w_up,0)
wav_dn = dim_avg_n(w_dn,0)

  print("weighted sf (w_dn) at 1 time is equal to: "+w_dn(10)+" and weighted w_up is equal to: "+w_up(10))
  print("ave weighted sf is equal to: "+wav_dn+" and weighted wav_up is equal to: "+wav_up)
  print("omega_up is equal to: "+omega_up)

  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print(">>>>>>>>>>>> writing text file")

filenameout    = "mean_omega_vals_"+model+"_"+SST+".txt"
header = (/"CircI, omega_d, omega_u, SF"/)
hlist = [/header/]
foot = (/"========stickittoem==========="/)
flist = [/foot/]
;val_a=(/omega_db_wva/)
val_a=(/circulation_int/)
val_b=(/omega_dn/)
val_c=(/omega_up/)
val_d=(/subsidenceF/)
alist = [/val_a,val_b,val_c,val_d/]
write_table(filenameout,"w",hlist, "%s")
write_table(filenameout,"a",alist, "%9.2f%9.2f%9.2f%9.2f")
write_table(filenameout,"a",flist, "%s")

  print("write a paper numskull")

  print("{{{{{{{{{{{{{{ leaving omega_mn_rce.ncl }}}}}}}}}}}}}}")

end 

