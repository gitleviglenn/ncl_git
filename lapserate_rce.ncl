;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; lapserate_rce.ncl
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
ndays=5
freq=24
timewindow=ndays*freq
;endtime=lasttime
numperiods=73
endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
timelenght=endtime-timewindow*numperiods
startime  =endtime-timewindow*numperiods+1

; physical constants: 
grav      =9.81
Rd        =287.        ; J/kg K gas constant for dry air
Rv        =461.; % J/(kg K) gas constant for water vapor
;latheat   =2.26e6; % J/kg latent heat of vaporization
latheat   =2.52e6; % J/kg latent heat of vaporization
cpd       =1000.       ; J/kg K cp for dry air
epsilon   = Rd/Rv

tsfc      =stringtofloat(SST)

  print("startime is: "+startime+" endtime is: "+endtime)

;==========================
; set up paths to files and read files...
path_cheyenne="/glade/scratch/levi/RCEMIP/"

if (isvar("CAMGCM")) then
  path_C5="CAM5_GCM/"
  path_C6="CAM6_GCM/"
  path_CAM=modelname+"_GCM/"
  
  file_p         =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_pa_avg.nc"
  file_ta        =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_ta_avg.nc"
  file_theta     =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_theta_avg.nc"
  file_psl       =path_cheyenne+path_CAM+"RCE_large"+SST+"/2D/"+modelname+"_GCM_RCE_large"+SST+"_2D_psl.nc"
  file_tas       =path_cheyenne+path_CAM+"RCE_large"+SST+"/2D/"+modelname+"_GCM_RCE_large"+SST+"_2D_tas.nc"
  file_zg        =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_zg_avg.nc"
  file_hur       =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_hur_avg.nc"
  file_hus       =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_hur_avg.nc"
  file_tntrscs   =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_tntrscs_avg.nc"
  file_tntrlcs   =path_cheyenne+path_CAM+"RCE_large"+SST+"/1D/"+modelname+"_GCM_RCE_large"+SST+"_1D_tntrlcs_avg.nc"
end if

  print("W$#%^@#$%@#$%^@#$%EW^&&$#%^")
  print("an incoming file is: "+file_tntrscs)
  print("another incoming file should be CAM: "+file_tntrlcs)
  print("W$#%^@#$%@#$%^@#$%EW^&&$#%^")

f_a=addfile(file_theta,"r")
f_b=addfile(file_p,"r")
f_c=addfile(file_ta,"r")
f_d=addfile(file_psl,"r")
f_e=addfile(file_tas,"r")
f_f=addfile(file_zg,"r")
f_g=addfile(file_hur,"r")
f_h=addfile(file_tntrscs,"r")
f_i=addfile(file_tntrlcs,"r")
f_j=addfile(file_hus,"r")

theta_a =f_a->theta_avg(startime:endtime,:)
temp_a  =f_c->ta_avg(startime:endtime,:)
press_a =f_b->pa_avg(startime:endtime,:)
psl_a   =f_d->psl(startime:endtime,:,:)
tas_a   =f_e->tas(startime:endtime,:,:)
zg_a    =f_f->zg_avg(startime:endtime,:)
hur_a   =f_g->hur_avg(startime:endtime,:)
hus_a   =f_j->hur_avg(startime:endtime,:)
rscs_a  =f_h->tntrscs_avg(startime:endtime,:)
rlcs_a  =f_i->tntrlcs_avg(startime:endtime,:)
lev_a   =f_g->lev(:)

dims = dimsizes(temp_a)
;printVarSummary(theta_a)

rho_test  =new((/dims(0),dims(1)/),float)
gamma_a   =new(dims(1),float)
gamma_m   =new((/dims(1)/),float)
dia_div   =new((/dims(1)/),float)
sbycp     =new((/dims(1)/),float)
sigma     =new((/dims(1)/),float)
numer     =new((/dims(1)/),float)
denom     =new((/dims(1)/),float)
estar     =new((/dims(1)/),float)
qstar     =new((/dims(1)/),float)
stasta    =new((/dims(0),dims(1)/),float)
arrayout  =new((/dims(1),9/),float)

  print("dimsizes of gamma_a are: "+dimsizes(gamma_a))

scaleR = 86400.;

; time average of variables: 
theta_tmn    =dim_avg_n(theta_a,0)
temp_tmn     =dim_avg_n(temp_a,0)
zg_tmn       =dim_avg_n(zg_a,0)
hur_tmn      =dim_avg_n(hur_a,0)
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
;sigma=10000*sigma ;   scale to K/100hPa
sigma=-100000*sigma ; scale to mK/hPa and convert to S from Bony et al

;==========================
; save the profiles that are desired to plot in a single array for output to a text file
; gamma_a, gamma_m, sbycp, sigma, levels?  

;==========================
; print variables to std out for debugging
do z=0,dims(1)-1
  print("saturation vapor pressure at z= "+z+" is: "+qstar(z))
  print("temp at z= "+z+" is: "+temp_tmn(z)+" gamma is: "+gamma_a(z)+" press is: "+press_tmn(z)+" rho is: "+rho(z)+" and gamma_m is: "+gamma_m(z)+" num: "+numer(z)+" den: "+denom(z))
  arrayout(z,0)=gamma_a(z)
  arrayout(z,1)=gamma_m(z)
  arrayout(z,2)=sbycp(z)
  arrayout(z,3)=sigma(z)
  arrayout(z,4)=hur_tmn(z)
  arrayout(z,5)=press_tmn(z)
  arrayout(z,6)=rscs_tmn(z)
  arrayout(z,7)=rlcs_tmn(z)
  arrayout(z,8)=dia_div(z)
end do 

;==========================
; write out data to a txt file...
;arrayToWrite   =gamma_m
option         = True   ; if False then output is sent to standard out
option@fout    = foutname
option@title   = "gamma_a, gamma_m, sbycp, sigma, hur_tmn, press, rscs, rlcs, diabdiv"
;write_matrix (arrayout, "7f7.2", option)
write_matrix (arrayout, "9f14.4", option)
       
end
