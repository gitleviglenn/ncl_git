;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega_mn_rce.ncl
;
; calculate the mean upward omega, mean downward omega, and the diab driven omega
;
; uses ncl function vibeta to compute the vertical integral, or vertical average
;
; read RH profiles, compute sigma profiles
;
; normal = 0 can refer to cam5, cam6, or geos
; normal = 1 refers to SP-CAM
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
; output RH, mn omega up, mn omega dn, diab omega,  sigma, and Q to a txt file.
;
; levi silvers                                                          feb 2021
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
  foutname="nofilename.txt"
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
  print("output txt file name is : "+foutname)

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

; physical constants: 
grav      =9.81
Rd        =287.        ; J/kg K gas constant for dry air
Rv        =461.; % J/(kg K) gas constant for water vapor
;latheat  =2.26e6; % J/kg latent heat of vaporization
latheat   =2.52e6; % J/kg latent heat of vaporization
cpd       =1000.       ; J/kg K cp for dry air
epsilon   = Rd/Rv
tsfc      =stringtofloat(SST) ; surface temperature

;==========================
; path bases
pch="/glade/scratch/levi/RCEMIP/"

  print("begin adding files...")

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
  file_p      =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_pa_avg.nc"
  file_ta     =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_ta_avg.nc"
  file_psl    =pch+cam+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_psl.nc"
  ;file_tas    =pch+cam+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_tas.nc"
  ;file_zg     =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_zg_avg.nc"
  file_hur    =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hur_avg.nc"
  file_tntrscs=pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
  file_tntrlcs=pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
  if (normal .lt. 1) then  ; for non CAM models with 'normal' data files
    file_zg   =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_zg_avg.nc"
  end if
else
  file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wap500.nc"
  file_p         =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_pa_avg.nc"
  file_ta        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_ta_avg.nc"
  file_psl       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_psl.nc"
  ;file_tas       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_tas.nc"
  file_hur       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_hur_avg.nc"
  file_tntrscs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
  file_tntrlcs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
;  if (isvar("notnormal")) then
  ;normal = notnormal
  if (normal .lt. 1) then  ; for non CAM models with 'normal' data files
    file_zg        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_zg_avg.nc"
  else ; something about the model data is abnormal (e.g. z_avg instead of zg_avg)
    ;  if (isvar("SP-CAM")) then  ; notnormal =1 corresponds to SP-CAM 
    file_zg      =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_z_avg.nc"
    ;  end if
  end if
;  end if
end if

  print("file_p is: "+file_p)
fca         =addfile(file_p,"r")
fcb         =addfile(file_ta,"r")
fce         =addfile(file_psl,"r")
;fcf         =addfile(file_tas,"r")
fcg         =addfile(file_zg,"r")
fch         =addfile(file_hur,"r")
fcj         =addfile(file_tntrscs,"r")
fck         =addfile(file_tntrlcs,"r")
fc_om       =addfile(file_om,"r")

;if (isvar("notnormal")) then
  normal = notnormal
  if (normal .lt. 1) then
    if (isvar("messeddims")) then
      press_a     =fca->pa_avg(:)
      zg_a        =fcg->zg(:)  ; GEOS uses zg instead of zg_avg
      press_tmn   =press_a
      zg_tmn      =zg_a
    else
      press_a     =fca->pa_avg(startime:endtime,:)
      zg_a        =fcg->zg_avg(startime:endtime,:)
      press_tmn   =dim_avg_n(press_a,0)
      zg_tmn      =dim_avg_n(zg_a,0)
    end if
  else ; normal =1
;    if (isvar("SP-CAM")) then
      press_a     =fca->pa_avg(startime:endtime,:)
      press_tmn   =dim_avg_n(press_a,0)
;      zg_tmn      =dim_avg_n(zg_a,0)
      zg_a          =fcg->z_avg(:)
      zg_tmn      =zg_a
;    end if
  end if
;end if

temp_a      =fcb->ta_avg(startime:endtime,:)
psl_a       =fce->psl(startime:endtime,:,:)
;tas_a       =fcf->tas(startime:endtime,:,:)
hur_a       =fch->hur_avg(startime:endtime,:)
rscs_a      =fcj->tntrscs_avg(startime:endtime,:)
rlcs_a      =fck->tntrlcs_avg(startime:endtime,:)

if (omega .lt. 1) then
  wvar_a=fc_om->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_a=fc_om->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;==========================
; compute time averages

scaleR = 86400.;

temp_tmn     =dim_avg_n(temp_a,0)
;zg_tmn       =dim_avg_n(zg_a,0)
hur_tmn      =dim_avg_n(hur_a,0)
rscs_tmn     =scaleR*dim_avg_n(rscs_a,0)
rlcs_tmn     =scaleR*dim_avg_n(rlcs_a,0)
;press_tmn    =dim_avg_n(press_a,0)
;press_tmn    =press_a

psl_b        =dim_avg_n(psl_a,0)
psl_c        =dim_avg_n(psl_b,0)
psl_avg      =dim_avg_n(psl_c,0)

;==========================

dims      = dimsizes(temp_a)
lowestlev = dims(1)-1

sbycp     =new((/dims(1)/),float)
sigma     =new((/dims(1)/),float)
omega_db  =new((/dims(1)/),float)
Q_tmn     =new((/dims(1)/),float)
arrayout  =new((/dims(1),6/),float)

; compute the net clear sky radiative heating of atmosphere
Q_tmn        =rlcs_tmn+rscs_tmn

;==========================
; dry static energy divided by the specific heat of dry air
do z = 0,dims(1)-1
  sbycp(z) = temp_tmn(z)+grav*zg_tmn(z)/(cpd)
end do

;==========================
; static stability parameter (pressure derivative of dry static energy divided by cpd)
do z=1,dims(1)-2
  sigma(z) = ((sbycp(z+1)-sbycp(z-1))/(press_tmn(z+1)-press_tmn(z-1)))
end do
sigma(0)  = sigma(1)
sigma(lowestlev) = ((sbycp(lowestlev-1)-tsfc)/(press_tmn(lowestlev-1)-psl_avg))

; scale the static stability as desired
;sigma=10000*sigma ;   scale to K/100hPa as in Mapes, 2001
sigma=-100000*sigma ; scale to mK/hPa and convert to S from Bony et al

;==========================
; process vertical velocity
; compute the mean upward and downward omega velocities

; scale vertical velocity
; convert units to hPa/d?  
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
;  print("the crm loop doesn't do anything yet")
;  if (isvar("flippeddim")) then  ; ICON LEM
;    x_new=fspan(0,384000,5)
;    y_new=fspan(0,5952000,63)
;  else                           ; SAM
;    y_new=fspan(0,384000,5)
;    x_new=fspan(0,5952000,63)
;  end if
;    print("original y array is: "+y_orig)
;    print("new y array is: "+y_new)
;    print("new x array is: "+x_new)
;  var_to_interpolate=wvar_a ; incoming CRM data
;  ; var_to_interpolate must have y,x as its two rightmost dimensions...
;  juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,False)
;  intvar_out=juljack
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
  ;print("omega_dn is equal to: "+omega_dn)
  ;print("omega_up is equal to: "+omega_up)

circulation_int = omega_dn-omega_up

; sfrac_dn is subsidence fraction.  use it to weight the up and down omega
w_up=intvar_u_ave*sfrac_up
w_dn=intvar_d_ave*sfrac_up
wav_up = dim_avg_n(w_up,0)
wav_dn = dim_avg_n(w_dn,0)

  print("weighted sf (w_dn) at 1 time is equal to: "+w_dn(10)+" and weighted w_up is equal to: "+w_up(10))
  print("ave weighted sf is equal to: "+wav_dn+" and weighted wav_up is equal to: "+wav_up)
  print("omega_up is equal to: "+omega_up)

; diabatically driven omega
; omega_db = Q/sigma
omega_db = scalef*(Q_tmn/sigma)

;opt_avg=(/0, 20000, 60000/) 
;omega_db_wva = wgt_vert_avg_beta(press_tmn, omega_db, psl_avg , 1, opt_avg) 

; compute vertical weighted average over a range in pressure
ptop = 20000.
pbot = 60000.
press_tmn!0  ="lev"
omega_db!0   ="lev"
sigma!0      ="lev"
hur_tmn!0    ="lev"
rscs_tmn!0   ="lev"
rlcs_tmn!0   ="lev"

sigma_wva    = vibeta(press_tmn(lev|::-1), sigma(lev|::-1), 1, psl_avg , pbot, ptop) 
sigma_wva    = sigma_wva/(pbot-ptop); 
omega_db_wva = vibeta(press_tmn(lev|::-1), omega_db(lev|::-1), 1, psl_avg , pbot, ptop) 
omega_db_wva = omega_db_wva/(pbot-ptop); normalize by pressure depth

  print("diabatic omega is: "+omega_db+" and the pressure is :"+press_tmn)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print(">>>>>>>>>>>>")
  print("pressure weighted omega db between "+pbot+" and "+ptop+" is: "+omega_db_wva)
  print("pressure weighted sigma between "+pbot+" and "+ptop+" is: "+sigma_wva)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")

;-----------------------------------------------------
; read omega from file                               ;
; scale omega              			     ;
; interpolate to appropriate grid  --> intvar_out    ;
; A) with intvar_out: 				     ;	
; sort into ascending/descending regions             ;
; compute subsidence fraction			     ;
; cosine weight?				     ;
; compute circulation intensity			     ;
;    -compute average omega_up, omega_dn	     ;
;    -compute difference			     ;
; B) with intvar_out: 				     ;
; reshape for the purpose of averaging over chunks   ;
; compute pdf					     ;
;-----------------------------------------------------

;==========================
; compute the diabatically driven omega

;=====================================
;; what should the dimensions of omega_up be?
  print(" what are the dimensions of output array and omega_db? "+dimsizes(arrayout)+" and "+dimsizes(omega_db))
do z=0,dims(1)-1
  arrayout(z,0)=omega_db(z)
  arrayout(z,1)=sigma(z)
  arrayout(z,2)=hur_tmn(z)
  arrayout(z,3)=rscs_tmn(z)
  arrayout(z,4)=rlcs_tmn(z)
  arrayout(z,5)=press_tmn(z)
end do 
;
;;==========================
;; write out data to a txt file...
option         = True   ; if False then output is sent to standard out
option@fout    = foutname
option@title   = "omega_d, sigma, hur_tmn, rscs, rlcs, press_mn"
write_matrix (arrayout, "6f14.4", option)

  print("write a paper numskull")


end 

