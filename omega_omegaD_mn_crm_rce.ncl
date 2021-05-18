;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega_omegaD_mn_crm_rce.ncl
;
; currently this only calculates the diabatically driven vertical velocity at 500mb.
;
; compute the circulation intensity, mean upward and downward vertical velocity for crms
;
; input: scalef: a scaling factor to convert wa500 from m/s to hPa/day
;
; output: circulation intensity, subsidence fraction, mean upward and downward velocity
;
; Methodology:
; 1.  interpolate to GCM like grid 
; 2. create chunked arrays
; 3. sort into ascending and descending regions
; 4. compute mn omega_u, omega_d, circulation intensity, and SF
;
; The domain mean profiles have been provided for the RCEMIP MME.  This script
; reads the temp, pressure, and height variables from those profiles: 
;      ta_avg -> 1D
;      pa_avg -> 1D   hPa, first level is at sfc.
;      z_avg  -> 1D
; still needed is the radiative heating, vertical velocity, and mean surface pressure.
;      rlcs -> 1D
;      rscs -> 1D
;      ;psl  -> 2D  --> I think I only need this for models in pressure coordinates..
;
;      wa500 or wap500 -> 2D
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
; levi silvers                                                    may 2021
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

; coarsen the CRM grid for clean comparison with GCMs
;make_coarse = True

if (isvar("blocks")) then
  blocksize=blocks
else
  blocksize=1
end if

  print("startime for reading data is: "+startime+" and end time is: "+endtime)
  print("numperiods is: "+numperiods)
  print("timewindow or chunk period (ndays*freq) is: "+timewindow)
  print("startime for reading data: "+startime+" lasttime to read data is: "+endtime)

;==========================
; define file locations via paths 

pch="/glade/scratch/levi/RCEMIP/"
p2prof=pch+"swift.dkrz.de/mn_profiles/"

; read domain mean profile: 
;file_prof      =p2prof+model+"_large"+seaST+"-profiles.nc"
;  print("profile file to be read is: "+file_prof)
;f_prof      =addfile(file_prof,"r")

file_prof   =p2prof+model+"_large"+seaST+"-profiles.nc"
f_prof      =addfile(file_prof,"r")
if (isvar("UCLAfix")) then
  ; special pressure file for UCLA...
  file_pa   =pch+"swift.dkrz.de/UCLA-CRM/UCLA-CRM_RCE_large295_avg_pa_avg.nc"
  f_pa      =addfile(file_pa,"r")
  pa_a        = f_pa->pa_avg(:,:)      ; Pa
  pa = 0.01*dim_avg_n(pa_a,0)          ; hPa
    print("profile file to be read is: "+file_pa)
else
  ;file_prof   =p2prof+model+"_large"+seaST+"-profiles.nc"
  ;f_prof      =addfile(file_prof,"r")
  pa          = f_prof->pa_avg(:)      ; mb, hPa
    print("profile file to be read is: "+file_prof)
end if
ta    = f_prof->ta_avg(:)      ; K
;pad   = f_prof->pa_avg(:)      ; mb, hPa
;pa    = f_prof->pa_avg(:)      ; mb, hPa
za    = f_prof->z_avg(:)       ; km
za=1000.*za
  print("pa raw: "+pa)
;paf = tofloat(pad)
;  print("pa float: "+paf)

if (fileconglomerate .lt. 1) then   ; should be models other than ECHAM or ICON 
  file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wa500.nc"
  ;file_prof      =pch+"swift.dkrz.de/swift.dkrz.de/"+model+"_large"+seaST+"-profiles.nc"
  file_tntrl     =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrlcs_avg.nc"
  file_tntrs     =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D_tntrscs_avg.nc"
  file_psl       =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_psl.nc"
  
    print("file_om is: "+file_om)
  ;fc_om       =addfile(file_om,"r")
  file_2D      =addfile(file_om,"r")
  ;f_prof      =addfile(file_prof,"r")
  f_rlw       =addfile(file_tntrl,"r")
  f_rsw       =addfile(file_tntrs,"r")
  f_psl       =addfile(file_psl,"r")
  if (omega .lt. 1) then
    wvar_a=file_2D->wap500(startime:endtime,:,:)
  else if (omega .lt. 2) then
    wvar_a=file_2D->wa500(startime:endtime,:,:)
  else if (omega .lt. 3) then
    wvar_a=file_2D->vertical_velocity_500hpa(startime:endtime,:,:)
  end if 
  end if 
  end if
  lw    = f_rlw->tntrlcs_avg(startime:endtime,:) ; K/s
  sw    = f_rsw->tntrscs_avg(startime:endtime,:) ; K/s
  lw_avg       = dim_avg_n(lw,0)
  sw_avg       = dim_avg_n(sw,0)
else if (fileconglomerate .eq. 1) then
    print("are we reading from ICON or UCLA??")
  ;file_1D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"-RCE_large"+"_"+seaST+"-1D.nc"
  if (isvar("ICON_LEMfix")) then
    file_1D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"-RCE_large"+"_"+seaST+"-1D.nc"
    file_2D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"-RCE_large"+"_"+seaST+"-2D_selectvars.nc"
  else
    file_1D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_1D.nc"
    file_2D_con    =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wa500.nc"
  end if
    print("incoming 1D file is: "+file_1D_con)
    print("incoming 2D file is: "+file_2D_con)
  file_1D = addfile(file_1D_con,"r")
  file_2D = addfile(file_2D_con,"r")
  ;temp_a  = file_1D->ta_avg(startime:endtime,:,0,0)
  if (omega .lt. 1) then
    wvar_a=file_2D->wap500(startime:endtime,:,:)
  else if (omega .lt. 2) then
    if (isvar("ICON_LEMfix")) then
      wvar_a=file_2D->wa500(startime:endtime,0,:,:)
    else ; UCLA case
      wvar_a=file_2D->wa500(startime:endtime,:,:)
    end if
  else if (omega .lt. 3) then
    wvar_a=file_2D->vertical_velocity_500hpa(startime:endtime,:,:)
  end if 
  end if 
  end if

  ;psl_a   = file_2D->psl(startime:endtime,:,:)
  ;hur_a   = file_1D->hur_avg(startime:endtime,:,0,0)
    print("WARNING!! it looks like ECHAM does not have clear sky radiative fluxes!! ")
  if (isvar("ICON_LEMfix")) then
    rscs_a  = file_1D->tntrscs_avg(startime:endtime,:,0,0)
    rlcs_a  = file_1D->tntrlcs_avg(startime:endtime,:,0,0)
  else ; UCLA case
    rscs_a  = file_1D->tntrscs_avg(startime:endtime,:)
    rlcs_a  = file_1D->tntrlcs_avg(startime:endtime,:)
  end if
  lw_avg = dim_avg_n(rlcs_a,0)
  sw_avg = dim_avg_n(rscs_a,0)
end if
end if

wvar_a=scalef*wvar_a
  print("scaleing by factor: "+scalef)
wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

; calculate the static stability profile and the diabatically driven velocity

; calculate net clear sky radiative heating of atmos
grav      =9.81
Rd        =287.        ; J/kg K gas constant for dry air
latheat   =2.52e6; % J/kg latent heat of vaporization
cpd       =1000.       ; J/kg K cp for dry air

tsfc      =stringtofloat(seaST)

Q_tmn = 86400.*(lw_avg+sw_avg); units will be K/day

; the domain mean profiles from RCEMIP are flipped
; relative to the raw data for ICON_LEM_CRM
if (isvar("ICON_LEMfix")) then
  Q_tmn=Q_tmn(::-1)
end if

dims   = dimsizes(za)
beta   = new(dims(0),float)
S_prof = new(dims(0),float)

;  print("dimsizes of ta are: "+dimsizes(ta))
;  print("values of ta at 0 and 73 are: ")
  print("dimsizes of beta are: "+dimsizes(beta))
  print("dims is equal to: "+dims)

printVarSummary(beta)
printVarSummary(ta)
printVarSummary(za)
printVarSummary(pa)
printVarSummary(grav)
printVarSummary(cpd)

; calculate the static stability...
do z=1,dims(0)-2
  ;beta(z)  = (cpd/grav)*((ta(z+1)-ta(z-1))/(pa(z+1)-pa(z-1)))
    print("from calculation of S: "+cpd/grav+": "+ta(z)+" : "+za(z))
  beta(z)  = (cpd/grav)*((ta(z+1)-ta(z-1))/(za(z+1)-za(z-1)))
    print(" beta is: "+beta(z))
  S_prof(z) = (Rd/cpd)*((ta(z)/pa(z))*(1-beta(z)))
end do

; boundary conditions
; for SAM, the zero level is nearest the surface 
beta(0)        = (cpd/grav)*((ta(1)-tsfc)/za(1))
;beta(0)        = (cpd/grav)*((ta(1)-tsfc)/(pa(1)-psl_avg))
beta(dims(0)-1)  = beta(dims(0)-1)
S_prof(0)       = (Rd/cpd)*((ta(0)/pa(0))*(1-beta(0)))
S_prof(dims(0)-1) = S_prof(dims(0)-1)

; diabatically driven vertical velocity
omega_db = Q_tmn/S_prof  ; units will be hPa/day

;==========================
; calculate the vertical average of omega_db
; the function vibeta is build to work with pressure coordinates
; for models using height coordinates we need to use something different

; dp = - rho*g*dz = -(p/(RT))g*dz

; bar(omega_db) = int(omega_db)dp/del p = -(g/R)*int(omega_db*(p/T)*dz/del p
; where del p   = pbot-ptop

; for SAM_CRM, z=1 is the level nearest the surface
;delete(massweight)

; initialize
omega_db_int = new((/dims(0)/),float)
massweight   = new((/dims(0)/),float)
omega_db_int@_FillValue = default_fillvalue("float")    ; set devault FillValue
massweight@_FillValue   = default_fillvalue("float")    ; set devault FillValue

;ptop = 200. ; hPa
;pbot = 600.
ptop = 1. ; hPa
pbot = 900.
do z=1,dims(0)-2
  temppa=pa(z)
  if ((pa(z) .lt. pbot) .and. (pa(z) .gt. ptop)) then
      print("pressure at height: "+za(z)+" on level: "+z+" is: "+pa(z))
    massweight(z)  = ((pa(z+1)-pa(z))/(Rd*(ta(z+1)-ta(z))))*(za(z+1)-za(z))
    omega_db_int(z)    = omega_db(z)*massweight(z)
  end if
end do

; sum should ignore missing data
  print("omega_db_int is: "+omega_db_int)
  print("sum of omega_db_int is: "+sum(omega_db_int))
omega_db_wva=grav*sum(omega_db_int)/(pbot-ptop)

  printVarSummary(omega_db)

;omega_db_wva = vibeta(press_tmn(lev|::-1), omega_db(lev|::-1), 1, psl_avg , pbot, ptop) 
;omega_db_wva = omega_db_wva/(pbot-ptop); normalize by pressure depth

  print("diabatic omega is: "+omega_db+" Q_tmn is "+Q_tmn+" press: "+pa)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
;  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
;  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
;  print(">>>>>>>>>>>>")
;  print("avg surface pressure is: "+psl_avg)
  print("pressure weighted omega db between "+pbot+" and "+ptop+" is: "+omega_db_wva)
;  print("pressure weighted sigma between "+pbot+" and "+ptop+" is: "+sigma_wva)
  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")


;;*************************************************************
;; 1.  interpolate to GCM like grid
;;-------------------------------------------------------------
;
;;
;; SAM_CRM:        y X x = 128 X 2048
;; ICON_LEM_CRM:   y X x = 2000 X 134 
;;
;
;; first method to coarsen the grid of the CRM 
;
;if (isvar("UCLAfix")) then
;    print("fixing things for UCLA CRM...")
;  x_orig = fc_om->xt
;  y_orig = fc_om->yt
;else if (isvar("ICON_LEMfix")) then
;  x_orig = fspan(1500,382500,128)
;  y_orig = fspan(1500,5950500,1984)
;else
;  x_orig = fc_om->x(0:1983)
;  y_orig = fc_om->y(0:127)
;end if
;end if
;
;;  printVarSummary(x_orig)
;;  printVarSummary(y_orig)
;
;; GRIDS for the various CRMs...
;; UCLA horizontal grid is 128x1984
;; ICON LEM CRM horizontal grid is 2000x134
;; SCALE hirozontal grid is 128x2048
;
;;; for a grid representing 192x192km2 blocks
;if (blocksize .eq. 2) then
;     print("!!!!!! Interpolating to a 192km by 192km block size !!!!!!")
;   blocksz="192km_"
;  if (isvar("ICON_LEMfix")) then
;    x_new=fspan(96000,288000,2)
;    y_new=fspan(96000,5856000,32)
;  else
;    y_new=fspan(96000,288000,2)
;    x_new=fspan(96000,5856000,32)
;  end if
;else
;  ; 96x96km2 blocks
;   blocksz="96km_"
;  if (isvar("ICON_LEMfix")) then
;    x_new=fspan(48000,336000,4)
;    y_new=fspan(48000,5904000,62)
;  else
;    y_new=fspan(48000,336000,4)
;    x_new=fspan(48000,5904000,62)
;  end if
;end if
;
;; scale for SCALE.  it has the coordinates in km instead of m.  
;; ICON LEM CRM has meaningless latitude like coordinates instead of m, although they do appear to be about 3 km apart...
;if (isvar("SCALEfix")) then
;  scaleaxis=1000.
;else
;  scaleaxis=1.
;end if
;y_orig=scaleaxis*y_orig
;x_orig=scaleaxis*x_orig
;
;;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
;;  print("max and min of wvar_a are: "+max(wvar_a)+" and "+min(wvar_a))
;;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
;
;var_to_interpolate=wvar_a ; incoming CRM data
;;var_to_interpolate@_FillValue = default_fillvalue("float")    ; set devault FillValue
;
;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
;  print("max and min of var_to_interpolate are: "+max(var_to_interpolate)+" and "+min(var_to_interpolate))
;  print("dimsizes of var_to_interpolate are: "+dimsizes(var_to_interpolate))
;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
;
;option = False
;option@critpc = 50
;notmissing=num(.not.ismissing(var_to_interpolate))
;  print("number of NOT MISSING values are: "+notmissing)
;juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,option)
;  print("dimsizes of juljack are: "+dimsizes(juljack))
;intvar_out=juljack
;
;  print("-----------Variable that will be interpolated----------------")
;  printVarSummary(var_to_interpolate)
;
;;----------------
;; second method to coarsen the grid of the CRM to something like a GCM
;;----------------
;;
;if (.not.isvar("ICON_LEMfix"))
;  lentime = timewindow*numperiods
;  if (blocksize .eq. 2) then
;    ; parameters for grid blocks of 192km
;    block_array = new((/lentime,2,32/),float)
;    block=floattointeger(64) ; block size for grid spacing of 192km
;    iend = 1 ; for 2048 gridpoints, there are 32 blocks of 64
;    jend = 30 ; for 128 gridpoints, there are two blocks of 64
;  else
;    ; parameters for grid blocks of 96km
;    block_array = new((/lentime,4,64/),float)
;    block=floattointeger(32) ; block size for grid spacing of 96km
;    iend = 3 ; for 2048 gridpoints, there are 32 blocks of 64
;    jend = 61 ; for 128 gridpoints, there are two blocks of 64
;  end if
;
;    ;printVarSummary(subfrac_a)
;    ;print("lentime is :"+lentime)
;  do tindex=0,lentime-1
;    do i=0,iend
;      icounter=i*block
;      do j=0,jend
;        jcounter=j*block
;        ;block_single   =subfrac_a(tindex,icounter:icounter+block-1,jcounter:jcounter+block-1)
;        block_single   =var_to_interpolate(tindex,icounter:icounter+block-1,jcounter:jcounter+block-1)
;        block_array(tindex,i,j)=avg(block_single)
;      end do
;    end do
;  end do
;  print("-----------Variable after being interpolated-----------------")
;  printVarSummary(block_array)
;  print("sample of block_array: "+block_array(500,:,31))
;  print("-------------------------------------------------------------")
;end if


;*************************************************************
; 2. reshape arrays to create chunks of days
;-------------------------------------------------------------

;*************************************************************
; 3. sort into ascending and descending regions 
;-------------------------------------------------------------

;*************************************************************
; 4. compute mn omega_u, omega_d, circulation intensity, and SF 
;-------------------------------------------------------------



;;-------------------------------------------------------------
;; print results to standard out
;
;  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
;  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
;  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
;  print(" the subsidence fraction is: "+subsidenceF)
;  print(">>>>>>>>>>>>")
;
;;-------------------------------------------------------------
;
;filenameout    = "mean_omega2_vals_"+ndays+"d_"+model+"_"+SST+".txt"
;header = (/"omega_db, CircI, omega_d, omega_u, SF"/)
;hlist = [/header/]
;foot = (/"========stickittoem==========="/)
;flist = [/foot/]
;val_a=(/omega_db_wva/)
;val_b=(/circulation_int/)
;val_c=(/omega_dn/)
;val_d=(/omega_up/)
;val_e=(/subsidenceF/)
;alist = [/val_a,val_b,val_c,val_d,val_e/]
;write_table(filenameout,"w",hlist, "%s")
;write_table(filenameout,"a",alist, "%9.2f%9.2f%9.2f%9.2f%9.2f")
;write_table(filenameout,"a",flist, "%s")
;
;  print("write a paper numskull")

end
