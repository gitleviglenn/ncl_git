;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; stability_omegaD.ncl
;
; calculates the static stability and saves it to an array that is written to a txt 
; file.  in addition, the clear sky radiative cooling and RH are read from files and 
; saved to the same txt file.  The radiativer cooling and static stability are then 
; used to compute the diabatically driven vertical velocity in stab_omegaD_readascii.ncl
;
; execution and running: 
;     1. run a driver shell script on casper (e.g. lapseRatedriver.sh)
;     2. within the driver script, call stability_omegaD.ncl
;     3. within the driver script, call a 'readascii.ncl' script that will read the txt 
;        files that have been created by stability_omegaD.ncl
;        
; 
; used with the lapseRatedriver.sh driver script on casper.
;
; calculate domain mean profiles of the: 
; 1. lapse rate    % dT/dp
; 2. moist adiabatic lapse rate  taken from Randall's Text Book
; 3. dry static stability
; 4. dry static stability 'parameter' (pressure derivative of 3.)
;
; CAM5 has 30 vertical levels that follow hybrid-pressure coordinates
; level 1 corresponds to the top of the model
; Most of the GCMs have level 1 at the top of the model except for CNRM and the UKMO
;
; variables needed for this script:  
; 2D vars:  omega/w, ta, psl
; 1D vars:  pa_avg,ta_avg,theta_avg,thetae_avg,hur_avg,hus_avg,zg_avg,tntrscs_avg,tntrlcs_avg 
;
; levi silvers                                                                 mar 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  print("{{{{{{{{{{{{{{ within stability_omegaD.ncl }}}}}}}}}}}}}}")

;==========================
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
if (isvar("CAMGCM")) then
  whichCAM=CAMGCM
end if

;==========================
; set up parameters
if (isvar("chunkdays")) then
  ndays=chunkdays
else
  ndays=5
end if
print("number of days in each averaging chunks is: "+ndays)
if (isvar("datafreq")) then
  freq=datafreq  ;[time per day] for most models this is 1 hr or 24 times per day, for IPSL it is 1 day
  print("data freq read, freq is: "+freq)
else
  freq=24
  print("data freq not detected, freq is: "+freq)
end if

  print("SST is : "+seaST)

timewindow=ndays*freq

;endtime=lasttime
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

startime  =endtime-timewindow*numperiods+1

; physical constants: 
grav      =9.81
Rd        =287.        ; J/kg K gas constant for dry air
Rv        =461.; % J/(kg K) gas constant for water vapor
;latheat  =2.26e6; % J/kg latent heat of vaporization
latheat   =2.52e6; % J/kg latent heat of vaporization
cpd       =1000.       ; J/kg K cp for dry air
epsilon   = Rd/Rv

tsfc      =stringtofloat(SST)

  print("startime is: "+startime+" endtime is: "+endtime)

;==========================
; path bases
path_laptop="/Users/silvers/data/CAM/"
pch="/glade/scratch/levi/RCEMIP/"

path_C5="CAM5_GCM/";RCE_large305/2D/"
path_C6="CAM6_GCM/"

  print("begin adding files...")

;*************************************************************
; read variables
;---------------------------------------------------------
if (fileconglomerate .lt. 1) then   ; should be models other than ECHAM or ICON 
  if (isvar("CAMGCM")) then
    whichCAM=CAMGCM
  ;;;; see omega_mn_rce.ncl for reference.  
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
    file_zg     =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_zg_avg.nc"
    file_hur    =pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hur_avg.nc"
    file_tntrscs=pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
    file_tntrlcs=pch+cam+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
    ;fca          =addfile(file_p,"r")
    ;press_a      =fca->pa_avg(startime:endtime,:)
    ;press_tmn    =dim_avg_n(press_a,0)   
  else
  ;  file_testmodel=pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_"+varname+".nc"
    if (VertDimFix .eq. 0) then; default
      file_p         =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_pa_avg.nc"
      file_zg        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_zg_avg.nc"
    end if
    if (VertDimFix .eq. 1) then
        print("no pressure file is being opened")
        print("no zg file is being opened")
    end if
    if (VertDimFix .eq. 2) then ; SP-CAM
      file_p       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_pa_avg.nc"
      file_zg      =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_z_avg.nc"
    end if
    if (omega .lt. 1) then
      omvar="wap500"
    else if (omega .lt. 2) then
      omvar="wa500"
    end if
    end if
    file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_"+omvar+".nc"
    file_ta        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_ta_avg.nc"
    file_psl       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_psl.nc"
    file_hur       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_hur_avg.nc"
    file_tntrscs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
    file_tntrlcs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
  end if
  
  fcb         =addfile(file_ta,"r")
  fce         =addfile(file_psl,"r")
  fch         =addfile(file_hur,"r")
  fcj         =addfile(file_tntrscs,"r")
  fck         =addfile(file_tntrlcs,"r")
  fc_om       =addfile(file_om,"r")

  ; the z variable has at least three different names: zg_avg(CAM5), z_avg(SP-CAM), zg(GEOS), and z(SAM) 
  ; should I organize the models into 3 or so 'types' for which z,p, and sometimes t 
  ; are defined, read, and averaged in particular ways?  
  
  ;----  Dealing with the different ways of writing zg and pa among the models -----;
  if (isvar("VertDimFix")) then
    if (VertDimFix .eq. 0) then
      fcg          =addfile(file_zg,"r")
      fca          =addfile(file_p,"r")
      if (isvar("stupidp")) then
        specialp = stupidp 
        if (specialp .eq. 1) then  ; GEOS has a pressure field with only height, no time
            print("inside stupid and special p loop")
          press_tmn =fca->pa_avg(:)
          zg_tmn    =fcg->zg(:)
        end if
      else ; no stupidp
        zg_a    = fcg->zg_avg(startime:endtime,:)
        zg_tmn  = dim_avg_n(zg_a,0)  
        ;fcg          =addfile(file_zg,"r")
        press_a      =fca->pa_avg(startime:endtime,:)
        press_tmn    =dim_avg_n(press_a,0)  ; CAM uses Pa for p, no conversion
      end if
    end if
    if (VertDimFix .eq. 1) then
        print("probably using SAM.  who are the others?")
      press_tmn    =fcb->p(:)
      press_tmn    = 100.*press_tmn ; SAM uses mb for p, convert to Pa
      zg_tmn       =fcb->z(:)
    end if
    if (VertDimFix .eq. 2) then
      fcg          =addfile(file_zg,"r")
      fca          =addfile(file_p,"r")
      zg_tmn       =fcg->z_avg(:) ; SP-CAM
      press_a      =fca->pa_avg(startime:endtime,:)
      press_tmn    =dim_avg_n(press_a,0)   
    end if
  end if ; end isvar(VertDimFix)
  if (omega .lt. 1) then
    wvar_a=fc_om->wap500(startime:endtime,:,:)
  else if (omega .lt. 2) then
    wvar_a=fc_om->wa500(startime:endtime,:,:)
  else if (omega .lt. 3) then
    wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
  end if 
  end if 
  end if
  ;
  temp_a      =fcb->ta_avg(startime:endtime,:)
  psl_a       =fce->psl(startime:endtime,:,:)
  ;tas_a       =fcf->tas(startime:endtime,:,:)
  hur_a       =fch->hur_avg(startime:endtime,:)
  rscs_a      =fcj->tntrscs_avg(startime:endtime,:)
  rlcs_a      =fck->tntrlcs_avg(startime:endtime,:)
else if (fileconglomerate .eq. 1) then
    print("are we reading from ICON or ECHAM???")
  file_1D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"-RCE_large"+"_"+seaST+"-1D.nc"
  file_2D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"-RCE_large"+"_"+seaST+"-2D_selectvars.nc"
    print("incoming 1D file is: "+file_1D_con)
    print("incoming 2D file is: "+file_2D_con)
  file_1D = addfile(file_1D_con,"r")
  file_2D = addfile(file_2D_con,"r")
  temp_a  = file_1D->ta_avg(startime:endtime,:,0,0)
  if (isvar("stupidp")) then
    specialp = stupidp 
    if (specialp .eq. 2) then  ; ICON special case
      press_a = file_1D->p_avg(startime:endtime,:,0,0)
      zg_a    = file_1D->height_avg(:,0,0)
      zg_tmn  = doubletofloat(zg_a)  
      wvar_a  = file_2D->wa500(startime:endtime,0,:,:)
    end if
  else
    press_a = file_1D->pa_avg(startime:endtime,:,0,0)
    zg_a    = file_1D->zg_avg(startime:endtime,:,0,0)
    zg_tmn  = dim_avg_n(zg_a,0)  
    wvar_a  = file_2D->wap500(startime:endtime,0,:,:)
  end if
  ;zg_tmn  = dim_avg_n(zg_a,0)  
  press_tmn = dim_avg_n(press_a,0)  
  psl_a   = file_2D->psl(startime:endtime,:,:)
  hur_a   = file_1D->hur_avg(startime:endtime,:,0,0)
    print("WARNING!! it looks like ECHAM does not have clear sky radiative fluxes!! ")
    print("WARNING!! it looks like ICON does not have clear sky radiative fluxes!! ")
  rscs_a  = file_1D->tntrs_avg(startime:endtime,:,0,0)
  rlcs_a  = file_1D->tntrl_avg(startime:endtime,:,0,0)
  ;wvar_a  = file_2D->wap500(startime:endtime,0,:,:)
end if
end if 

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

dims      = dimsizes(temp_a)

  print("!- check the lowest level, it could have an error because of 'lowestlev'!!!! -!")
lowestlev = dims(1)-1


;*************************************************************
; scale vertical velocity
; convert units to hPa/d?  
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is 6042 ?!! 

wvar_a=scalef*wvar_a

;*************************************************************
; perform regridding to 1x1 degree lat lon or regrid CRM 
; models to a coarse gird...
;----------------------------
;interpswitch = 1; default, perform interpolation, ICON is an exception
if (isvar("interp")) then
  interpswitch = interp 
    print("interpswitch is: "+interpswitch)
else
  interpswitch = 1; default, perform interpolation, ICON is an exception
    print("interpswitch is: "+interpswitch)
end if
if (interpswitch .eq. 1) then  ; perform interpolation
  if (CRM .lt. 1)  ; case for GCMs
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
      print("interpolation finished")
  else  ; case for CRMs
    print("interpolation to 1x1 degree grid not computed.")
  end if  ; end interpolation loop
else ; end interpswitch .eq. 1
  print("------Warning!  Interpolation not performed.  ICON?------")
    intvar_out=wvar_a
end if

;======================================

;dims = dimsizes(temp_a)

rho_test  =new((/dims(0),dims(1)/),float)
gamma_a   =new(dims(1),float)
dia_div   =new((/dims(1)/),float)
sbycp     =new((/dims(1)/),float)
sigma     =new((/dims(1)/),float)
Q_tmn     =new((/dims(1)/),float)
omega_db  =new((/dims(1)/),float)
rscs_tmn  =new((/dims(1)/),float)
rlcs_tmn  =new((/dims(1)/),float)
numer     =new((/dims(1)/),float)
denom     =new((/dims(1)/),float)
stasta    =new((/dims(0),dims(1)/),float)
arrayout  =new((/dims(1),9/),float)

; convert from K/s to K/day
scaleR = 86400.;

; time average of variables: 
temp_tmn     = dim_avg_n(temp_a,0)
;zg_tmn      = dim_avg_n(zg_a,0)
hur_tmn      = dim_avg_n(hur_a,0)
rscs_tmn     = scaleR*dim_avg_n(rscs_a,0)
rlcs_tmn     = scaleR*dim_avg_n(rlcs_a,0)
;press_tmn   = dim_avg_n(press_a,0)
 
psl_b        = dim_avg_n(psl_a,0)
psl_c        = dim_avg_n(psl_b,0)
psl_avg      = dim_avg_n(psl_c,0)

; calculate density
rho=press_tmn/(temp_tmn*Rd)

; calculate net clear sky radiative heating of atmos
Q_tmn = rlcs_tmn+rscs_tmn  ; if scaleR was used, units will be K/day

; what about surface pressure? 
;press_tmn(dims(1))=101480.0  ; define surface pressure as in Wing et al., 2018, page 798
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

;=========================
; diabatically driven omega  
; converte from Pa/day to hPa/day
omega_db = (1./100.)*Q_tmn/sigma
  print("debugging: first omega_db: "+omega_db+" then Q_tmn: "+Q_tmn+" and then sigma: "+sigma)


;==========================
; lapse rate of temperature
do z = 1,dims(1)-2
  gamma_a(z) = -grav*rho(z)*((temp_tmn(z+1)-temp_tmn(z-1))/(press_tmn(z+1)-press_tmn(z-1)))
end do
; bc for top of model
gamma_a(0)   = gamma_a(1)
; bc for surface
gamma_a(lowestlev)  = -grav*rho(lowestlev)*((temp_tmn(lowestlev)-tsfc)/(press_tmn(lowestlev)-psl_avg))

;==========================
; compute the diabatically driven divergence
do z=1,dims(1)-2
  dia_div(z)=-((Q_tmn(z+1)/sigma(z+1)-Q_tmn(z-1)/sigma(z-1))/(press_tmn(z+1)-press_tmn(z-1)))
end do
dia_div(0)=dia_div(1)
dia_div(lowestlev) = dia_div(lowestlev-1)

; scale the static stability as desired
;sigma=10000*sigma ;   scale to K/100hPa as in Mapes, 2001
sigma=-100000*sigma ; scale to mK/hPa and convert to S from Bony et al, 2016

;=========================
; compute the circulation intensity
; compute cosine weighting

if (CRM .lt. 1)
  omega_u_a      =where((intvar_out .le. 0),intvar_out,intvar_out@_FillValue)
  omega_u_a_frac =where((intvar_out .le. 0),1.0,0.0)
  omega_d_a      =where((intvar_out .ge. 0),intvar_out,intvar_out@_FillValue)
  omega_d_a_frac =where((intvar_out .ge. 0),1.0,0.0)
else
  omega_u_a      =where((wvar_a .le. 0),wvar_a,wvar_a@_FillValue)
  omega_u_a_frac =where((wvar_a .le. 0),1.0,0.0)
  omega_d_a      =where((wvar_a .ge. 0),wvar_a,wvar_a@_FillValue)
  omega_d_a_frac =where((wvar_a .ge. 0),1.0,0.0)
end if

omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

dim_om=dimsizes(omega_u_a)

; compute subsidence fraction
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
subsidenceF=dim_avg_n(sfrac,0)
  ;print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" and fraction of ascending air is: "+sfrac_up(10))
  print("subs frac is: "+dim_avg_n(sfrac,0)+" and fraction of ascending air is: "+dim_avg_n(sfrac_up,0))


;-------------------------------------------------------------
if (CRM .lt. 1)
  if (interpswitch .eq. 1) then  ; perform interpolation
      print("applying cosine weighted averaging")
    lat  = LAT_out
    rad  = 4.0*atan(1.0)/180.0
    clat = cos(lat*rad)
    
    intvar_u_ave  = wgt_areaave(omega_u_a,clat,1.0,0)
    intvar_d_ave  = wgt_areaave(omega_d_a,clat,1.0,0)
      ;printVarSummary(intvar_u_ave)
  else
      print("not applying cosine weighted averaging")
    intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
    intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
  end if  
else;  no weighting for CRM models
    print("not applying cosine weighted averaging")
  intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
end if

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

gamma_a!0    ="lev"
sigma!0      ="lev"
omega_db!0   ="lev"
hur_tmn!0    ="lev"
press_tmn!0  ="lev"
temp_tmn!0   ="lev"
rscs_tmn!0   ="lev"
rlcs_tmn!0   ="lev"
dia_div!0    ="lev"

;temp_tmn!0   ="lev"
;omega_db!0   ="lev"

; reverse the vertical dimension so that the lowest layers are at the bottom of plot
;fields=fields(::-1,:)
print("dimsizes of sigma are: "+dimsizes(sigma))

; it seems like this should not be here, but it also doesn't seem to 
; fix the problem with omega_db
if (isvar("VertDimFix")) then 
  if (VertDimFix .eq. 1) then  ; SAM-CRM
    gamma_a    =gamma_a(::-1)
    sigma      =sigma(::-1)
    hur_tmn    =hur_tmn(::-1)
    press_tmn  =press_tmn(::-1)
    temp_tmn   =temp_tmn(::-1)
    rscs_tmn   =rscs_tmn(::-1)
    rlcs_tmn   =rlcs_tmn(::-1)
    dia_div    =dia_div(::-1)
  end if
end if


;==========================
; calculate the vertical average of omega_db
ptop = 20000.
pbot = 60000.

sigma_wva    = vibeta(press_tmn(lev|::-1), sigma(lev|::-1), 1, psl_avg , pbot, ptop) 
sigma_wva    = sigma_wva/(pbot-ptop); 
omega_db_wva = vibeta(press_tmn(lev|::-1), omega_db(lev|::-1), 1, psl_avg , pbot, ptop) 
omega_db_wva = omega_db_wva/(pbot-ptop); normalize by pressure depth

  print("diabatic omega is: "+omega_db+" Q_tmn is "+Q_tmn+" and the pressure is :"+press_tmn)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print(">>>>>>>>>>>>")
  print("avg surface pressure is: "+psl_avg)
  print("pressure weighted omega db between "+pbot+" and "+ptop+" is: "+omega_db_wva)
  print("pressure weighted sigma between "+pbot+" and "+ptop+" is: "+sigma_wva)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")


;==========================
; arrayout will contain the lapse rate, the adiabatic lapse rate, the dry static energy, 
; the static stability, relative humidity, pressure, clear sky radiation
; (both shortwave and longwave) and the diabatic divergence.  The diabatically driven 
; velocity can be calculated from (rscs_tmn+rlcs_tmn)/sigma
; 
; not output, omega, thetae, subsidence fraction

;==========================

do z=0,dims(1)-1
  ;print("temp at z= "+z+" is: "+temp_tmn(z)+" gamma is: "+gamma_a(z)+" press is: "+press_tmn(z)+" rho is: "+rho(z)+" and gamma_m is: "+gamma_m(z)+" num: "+numer(z)+" den: "+denom(z))
  arrayout(z,0)=gamma_a(z)
  arrayout(z,1)=dia_div(z)
  arrayout(z,2)=omega_db(z)
  arrayout(z,3)=sigma(z)
  arrayout(z,4)=hur_tmn(z)
  arrayout(z,5)=rscs_tmn(z)
  arrayout(z,6)=rlcs_tmn(z)
  arrayout(z,7)=temp_tmn(z)
  arrayout(z,8)=press_tmn(z)
end do 

;==========================
; write out data to a txt file...
  print(">>>>>>>>>>>> writing first text file")

option         = True   ; if False then output is sent to standard out
option@fout    = foutname
;option@title   = "gamma, sigma, hur_tmn, press, temp, rscs, rlcs, diabdiv"
option@title   = "gamma_a, diabdiv, omega_d, sigma, hur_tmn, rscs, rlcs, temp, press"
write_matrix (arrayout, "9f14.4", option)

; write out mean values to txt file...
  print(">>>>>>>>>>>> writing second text file")
filenameout    = "mean_vals_A_"+model+"_"+SST+".txt"
;write_matrix (mnvalout, "4f14.4", option)
header = (/"omega_d, CircI, omega_d, omega_u, SF"/)
hlist = [/header/]
foot = (/"========stickittoem==========="/)
flist = [/foot/]
val_a=(/omega_db_wva/)
val_b=(/circulation_int/)
val_c=(/omega_dn/)
val_d=(/omega_up/)
val_e=(/subsidenceF/)
alist = [/val_a,val_b,val_c,val_d,val_e/]
write_table(filenameout,"w",hlist, "%s")
write_table(filenameout,"a",alist, "%9.2f%9.2f%9.2f%9.2f%9.2f")
write_table(filenameout,"a",flist, "%s")

  print("write a paper numskull")

  print("{{{{{{{{{{{{{{ leaving stability_omegaD.ncl }}}}}}}}}}}}}}")
       
end

