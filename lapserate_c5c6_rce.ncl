;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; lapserate_rce.ncl
;
; calculates vertical profiles and equilibrium RCE states and saves them to an 
; array that is written to a txt file
;
; initially only set up to work with CAM5 and CAM6
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
;
; variables needed for this script:  
; 2D vars:  omega/w, ta, psl
; 1D vars:  pa_avg,ta_avg,theta_avg,thetae_avg,hur_avg,hus_avg,zg_avg,tntrscs_avg,tntrlcs_avg 
;
; levi silvers                                                     nov 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

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

;ndtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
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
if (isvar("CAMGCM")) then
  whichCAM=CAMGCM
  if (CAMGCM .lt. 6) then
    file_c5=pch+path_C5+"RCE_large"+seaST+"/2D/CAM5_GCM_RCE_large"+seaST+"_2D_wap500.nc"
    file_p      =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_pa_avg.nc"
    file_ta     =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_ta_avg.nc"
    file_theta  =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_theta_avg.nc"
    file_thetae =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_thetae_avg.nc"
    file_psl    =pch+path_C5+"RCE_large"+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_psl.nc"
    file_tas    =pch+path_C5+"RCE_large"+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_tas.nc"
    file_zg     =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_zg_avg.nc"
    file_hur    =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hur_avg.nc"
    file_hus    =pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hus_avg.nc"
    file_tntrscs=pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
    file_tntrlcs=pch+path_C5+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
    fc5         =addfile(file_c5,"r")
    wvar_a      =fc5->wap500(startime:endtime,:,:)
  else 
    file_c6=pch+path_C6+"RCE_large"+seaST+"/2D/CAM6_GCM_RCE_large"+seaST+"_2D_wap500.nc"
    file_p      =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_pa_avg.nc"
    file_ta     =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_ta_avg.nc"
    file_theta  =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_theta_avg.nc"
    file_thetae =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_thetae_avg.nc"
    file_psl    =pch+path_C6+"RCE_large"+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_psl.nc"
    file_tas    =pch+path_C6+"RCE_large"+seaST+"/2D/"+modelname+"_GCM_RCE_large"+seaST+"_2D_tas.nc"
    file_zg     =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_zg_avg.nc"
    file_hur    =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hur_avg.nc"
    file_hus    =pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_hus_avg.nc"
    file_tntrscs=pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
    file_tntrlcs=pch+path_C6+"RCE_large"+seaST+"/1D/"+modelname+"_GCM_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
    fc6         =addfile(file_c6,"r")
    wvar_a      =fc6->wap500(startime:endtime,:,:)
  end if
else
;  filen_test=model+"_RCE_large"+seaST+"_2D_"+varname+".nc"
  file_testmodel =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_"+varname+".nc"
  file_p         =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_pa_avg.nc"
  file_ta        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_pa_avg.nc"
  file_theta     =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_theta_avg.nc"
  file_thetae    =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_thetae_avg.nc"
  file_psl       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_psl.nc"
  file_tas       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_tas.nc"
  file_zg        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_zg_avg.nc"
  file_hur       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_hur_avg.nc"
  file_hus       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_hus_avg.nc"
  file_tntrscs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
  file_tntrlcs   =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
  fin            =addfile(file_testmodel,"r")
  if (omega .lt. 1) then
    wvar_a=fin->wap500(startime:endtime,:,:)
  else if (omega .lt. 2) then
    wvar_a=fin->wa500(startime:endtime,:,:)
  else if (omega .lt. 3) then
    wvar_a=fin->vertical_velocity_500hpa(startime:endtime,:,:)
  end if 
  end if 
  end if
  ;printVarSummary(wvar_a)
end if

fca         =addfile(file_p,"r")
fcb         =addfile(file_ta,"r")
fcc         =addfile(file_theta,"r")
fcd         =addfile(file_thetae,"r")
fce         =addfile(file_psl,"r")
fcf         =addfile(file_tas,"r")
fcg         =addfile(file_zg,"r")
fch         =addfile(file_hur,"r")
fci         =addfile(file_hus,"r")
fcj         =addfile(file_tntrscs,"r")
fck         =addfile(file_tntrlcs,"r")

press_a     =fca->pa_avg(startime:endtime,:)
temp_a      =fcb->ta_avg(startime:endtime,:)
theta_a     =fcc->theta_avg(startime:endtime,:)
thetae_a    =fcd->thetae_avg(startime:endtime,:)
psl_a       =fce->psl(startime:endtime,:,:)
tas_a       =fcf->tas(startime:endtime,:,:)
zg_a        =fcg->zg_avg(startime:endtime,:)
hur_a       =fch->hur_avg(startime:endtime,:)
hus_a       =fci->hus_avg(startime:endtime,:)
rscs_a      =fcj->tntrscs_avg(startime:endtime,:)
rlcs_a      =fck->tntrlcs_avg(startime:endtime,:)
lev_a       =fch->lev(:)

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;*************************************************************

dims = dimsizes(temp_a)
;printVarSummary(theta_a)

rho_test  =new((/dims(0),dims(1)/),float)
gamma_a   =new(dims(1),float)
gamma_m   =new((/dims(1)/),float)
theta_e   =new((/dims(1)/),float)
thetae_e  =new((/dims(1)/),float)
dia_div   =new((/dims(1)/),float)
sbycp     =new((/dims(1)/),float)
sigma     =new((/dims(1)/),float)
numer     =new((/dims(1)/),float)
denom     =new((/dims(1)/),float)
estar     =new((/dims(1)/),float)
qstar     =new((/dims(1)/),float)
stasta    =new((/dims(0),dims(1)/),float)
arrayout  =new((/dims(1),10/),float)

 ; print("dimsizes of gamma_a are: "+dimsizes(gamma_a))

scaleR = 86400.;

; time average of variables: 
theta_tmn    =dim_avg_n(theta_a,0)
thetae_tmn   =dim_avg_n(thetae_a,0)
temp_tmn     =dim_avg_n(temp_a,0)
zg_tmn       =dim_avg_n(zg_a,0)
hur_tmn      =dim_avg_n(hur_a,0)
hus_tmn      =dim_avg_n(hus_a,0)
rscs_tmn     =scaleR*dim_avg_n(rscs_a,0)
rlcs_tmn     =scaleR*dim_avg_n(rlcs_a,0)
press_tmn    =dim_avg_n(press_a,0)
 
psl_b        =dim_avg_n(psl_a,0)
psl_c        =dim_avg_n(psl_b,0)
psl_avg      =dim_avg_n(psl_c,0)

rho=press_tmn/(temp_tmn*Rd)

lowestlev=dims(1)-1

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
; saturation vapor pressure (should be in Pa)
do z=0,dims(1)-1
  estar(z)   = 611.*exp((latheat/Rv)*(1./273.-1./temp_tmn(z)))
  qstar(z)   = epsilon*estar(z)/press_tmn(z)
end do

;==========================
; moist adiabatic lapse rate
do z=0,dims(1)-1
  numer(z)     = -(grav/cpd)*(1+(latheat*qstar(z)/(Rd*temp_tmn(z))))
  denom(z)     = (1+(qstar(z)*latheat^2)/(cpd*Rv*temp_tmn(z)^2))
  gamma_m(z)   = numer(z)/denom(z)
end do

;==========================
; equivalent potential temperature 
; somem models output thetae...
;do z=0,dims(1)-1
;  theta_e(z)   = theta_tmn(z)*exp((hus_tmn(z)*latheat)/(temp_tmn(z)*cpd))
;end do

;==========================
; compute the radiative heating using clear sky fluxes
qrad=rscs_tmn+rlcs_tmn

do z=1,dims(1)-2
  dia_div(z)=-((qrad(z+1)/sigma(z+1)-qrad(z-1)/sigma(z-1))/(press_tmn(z+1)-press_tmn(z-1)))
end do
dia_div(0)=dia_div(1)
;dia_div(lowestlev) = -((qrad(lowestlev)/sigma(lowestlev)-qrad(lowestlev-1)/sigma(lowestlev-1))/(press_tmn(lowestlev)-psl_avg))
dia_div(lowestlev) = dia_div(lowestlev-1)

;dia_div=100*dia_div

; scale the static stability as desired
;sigma=10000*sigma ;   scale to K/100hPa as in Mapes, 2001
sigma=-100000*sigma ; scale to mK/hPa and convert to S from Bony et al

;==========================
; save the profiles that are desired to plot in a single array for output to a text file
; gamma_a, gamma_m, sbycp, sigma, levels?  

;==========================
; arrayout will contain the lapse rate, the adiabatic lapse rate, the dry static energy, 
; the static stability, relative humidity, pressure, clear sky radiation
; (both shortwave and longwave) and the diabatic divergence.  The diabatically driven 
; velocity can be calculated from (rscs_tmn+rlcs_tmn)/sigma
; 
; not output, omega, thetae, subsidence fraction

do z=0,dims(1)-1
  ;print("saturation vapor pressure at z= "+z+" is: "+qstar(z))
  ;print("temp at z= "+z+" is: "+temp_tmn(z)+" gamma is: "+gamma_a(z)+" press is: "+press_tmn(z)+" rho is: "+rho(z)+" and gamma_m is: "+gamma_m(z)+" num: "+numer(z)+" den: "+denom(z))
  arrayout(z,0)=gamma_a(z)
  arrayout(z,1)=gamma_m(z)
  arrayout(z,2)=sbycp(z)
  arrayout(z,3)=sigma(z)
  arrayout(z,4)=hur_tmn(z)
  arrayout(z,5)=press_tmn(z)
  arrayout(z,6)=rscs_tmn(z)
  arrayout(z,7)=rlcs_tmn(z)
  arrayout(z,8)=dia_div(z)
  arrayout(z,9)=thetae_tmn(z)
end do 

;==========================
; write out data to a txt file...
;arrayToWrite   =gamma_m
option         = True   ; if False then output is sent to standard out
option@fout    = foutname
option@title   = "gamma_a, gamma_m, sbycp, sigma, hur_tmn, press, rscs, rlcs, diabdiv, theta_e"
write_matrix (arrayout, "10f14.4", option)
       
end
