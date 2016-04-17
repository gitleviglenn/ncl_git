;============================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;============================================================;
begin
;============================================================;
; rce_ecs_final
;
; ncl script to compute the equilibrium climate sensitivity
; this script also computes the toa and sfc imbalance over 
; the time period given by an internally set averaging period
;
; syntax: nclsh rce_ecs2.ncl -iFile=file1.nc -iFile2=file2.nc -fmn -nwp -accumulated -anom -time= -int= -ave=
;
; or if echam physics where used change the -nwp switch to -echam
;
; time: indicates the length of the time dimension that will be read
; int:  timemin = timelen-int --> this determines the interval over which data is processed
; ave:  interval over which the running mean will be computed
;
; on the mac paths for data are: to_rce/comp_timeseries instead of to_data/nwprce as detailed
; in the gmail emails with subject values for ecs, lambda, and hydrologic sensitivity for....
; 
; levi silvers  		August 2013
;============================================================;

; read in File 1
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")

;; read in File 2
;; open/reference desired file (use addfiles to reference multiple data file)
;if (isvar("iFile2")) then
; infile2 = addfile(iFile2+".nc","r")
;end if

if (.not. isvar("structured")) then
  Model = "unstructured"
else
  Model = "ICOHDC"
end if

; default title is "no title specified"
if (.not. isvar("title")) then
  maintitle = "exp name"
else
  maintitle = title
end if

xaxistitle="time "

if (.not. isvar("time")) then
  timelen=300
else
  timelen=stringtoint(time)
end if

if (.not. isvar("int")) then
  interv=0
else
  interv=stringtoint(int)
end if
timemin=timelen-interv
;timelen=interv
time1 = infile->time(:timelen)                ; time values
;time1=interv
print("length of complete time vector = "+dimsizes(time1))
print("time interv to be analysed equals "+interv)

;aveint=2160 ; timesteps over which running mean will be taken
if (.not. isvar("ave")) then
  aveint=360 ; timesteps over which running mean will be taken
else
  aveint=stringtoint(ave)
end if

print("ave interv used for run mean = "+aveint)
print("ave interv should be less then or equal to interv")
print("the timemin is: "+timemin+" and the time max is: "+timelen)

;tempvar = dimsizes(time1)
;tempvar = dimsizes(interv)
;iend = tempvar(0);-1

; indices for the time loop
istart = 1
iend = interv-1
inc    = 1

hlev=60
outputint = 7200 ; [s]

print("value of hlev is currently "+hlev)

;-------------------------------------------------------------------------
; read variables from File 1
;-------------------------------------------------------------------------
;
print("---------------below is data from file one------------------------------------")
print("------------------------------------------------------------------------------")
 print("file1 is :"+iFile)
print("------------------------------------------------------------------------------")

maintitle1="Atmospheric Energy Budget"

; read in the surface fluxes below----------------------------------------
varname1="accshfl_s"
if (isvar("nwp")) then
  if (isvar("accumulated")) then
    varname1="accshfl_s" ; accumulated value
  else
    varname1="accshfl_s" ; average over outputtimeinterval
  end if 
end if
if (isvar("echam")) then
  varname1="hfss" ; [W/m2] sensible heat flux
end if
ltitle1=varname1
if (.not. isvar("fmn"))
  field1 = infile->$varname1$(timemin:timelen,:)
else
  field1 = infile->$varname1$(timemin:timelen,0,0)
end if
print(varname1+" at tfinal-5: "+field1(0))

varname2="acclhfl_s"
if (isvar("nwp")) then
  if (isvar("accumulated")) then
    varname2="acclhfl_s" ; accumulated value
  else
    varname2="acclhfl_s" ; average over outputtimeinterval
  end if 
end if
if (isvar("echam")) then
  varname2="hfls" ; [W/m2] latent heat flux
end if
ltitle2=varname2
if (.not. isvar("fmn"))
    field2 = infile->$varname2$(timemin:timelen,:)
else
    field2 = infile->$varname2$(timemin:timelen,0,0)
end if

varthb1="accthb_s" ; surface net thermal radiation acc. since model start
if (isvar("nwp")) then
  if (isvar("accumulated")) then
    varthb1="accthb_s" ; accumulated value
  else
    varthb1="athb_s" ; average over outputtimeinterval
  end if 
end if
if (isvar("echam")) then
  varthb1="rlns" ; [W/m2] lw net flux at surface
end if
ltitle2=varthb1
if (.not. isvar("fmn"))
    fieldthb1 = infile->$varthb1$(timemin:timelen,:)
else
    fieldthb1 = infile->$varthb1$(timemin:timelen,0,0)
end if

;accsob_s
varsob1="accsob_s" ; surface net solar radiation acc. since model start
if (isvar("nwp")) then
  if (isvar("accumulated")) then
    varsob1="accsob_s" ; accumulated value
  else
    varsob1="asob_s" ; average over outputtimeinterval
  end if 
end if
if (isvar("echam")) then
  varsob1="rsns" ;[W/m2] sw net flux at surface
end if
ltitle2=varsob1
if (.not. isvar("fmn"))
  fieldsob1 = infile->$varsob1$(timemin:timelen,:)
else
  fieldsob1 = infile->$varsob1$(timemin:timelen,0,0)
end if

;varname5="prm_swflxtoa"
varname5="rsnt"
if (isvar("nwp")) then
  ;varname5="sob_t" ; instantaneous
  if (isvar("accumulated")) then
    varname5="accsob_t" ; accumulated value
  else
    varname5="asob_t" ; average over outputtimeinterval
  end if 
end if
if (isvar("echam")) then
  varname5="rsnt" ; [W/m2] sw net at TOA
end if
ltitle5=varname5
if (.not. isvar("fmn"))
    field5 = infile->$varname5$(timemin:timelen,:)
else
    field5 = infile->$varname5$(timemin:timelen,0,0)
end if

if (isvar("nwp")) then
  if (.not. isvar("clearsky")) then
    varname5b="accsob_t" ; average over outputtimeinterval
    ltitle5b=varname5
    field5b = infile->$varname5b$(timemin:timelen,0,0)
    field5bsfc = infile->$varname5b$(timemin:timelen,0,0)
  else
    varname5b="trsolclr" ; average over outputtimeinterval
    ltitle5b=varname5b
    field5b = infile->$varname5b$(timemin:timelen,0,0,0)
    field5b=field5b*341
    field5bsfc = infile->$varname5b$(timemin:timelen,hlev,0,0)
    field5bsfc=field5bsfc*341
  end if
end if

; define var6
;varname6="rlnt"
if (isvar("nwp")) then
  ;varname6="lwflxall"
  if (isvar("accumulated")) then
    varname6="accthb_t"
  else
    varname6="athb_t"
  end if
end if
if (isvar("echam")) then
  varname6="rlnt" ; [W/m2] lw net flux at TOA
end if
ltitle6=varname6
if (.not. isvar("fmn"))
  field6 = infile->$varname6$(timemin:timelen,:)
else
  if (isvar("nwp")) then
    ;field6 = infile->$varname6$(0,1,0,0)
    field6 = infile->$varname6$(timemin:timelen,0,0)
  else
    field6 = infile->$varname6$(timemin:timelen,0,0)
  end if
end if

; define var6
;varname6b="prm_lwflxtoa"
if (isvar("nwp")) then
  if (.not. isvar("clearsky")) then
    varname6b=varname6
    field6b = infile->$varname6b$(timemin:timelen,0,0)
    field6bsfc = infile->$varname6b$(timemin:timelen,0,0)
    print("Cuation!  Clear sky fluxes not read, output for clr is meaningless!!!")
  else
    varname6b="lwflxclr"
    field6b = infile->$varname6b$(timemin:timelen,0,0,0)
    field6bsfc = infile->$varname6b$(timemin:timelen,hlev,0,0)
  end if
  ltitle6=varname6b
end if

; read in precip fields to compute hydro. sens.
if (isvar("nwp")) then
  varpgsp     ="rain_gsp"
  varpcon     ="rain_con"
  varptot_avg ="tot_prec_rate_avg"
  fieldpgsp   = infile->$varpgsp$(timemin:timelen,0,0)
  fieldpcon   = infile->$varpcon$(timemin:timelen,0,0)
  fieldpt_avg = infile->$varptot_avg$(timemin:timelen,0,0)
end if

  outs=timelen-timemin
print("outs is equal to: "+outs)
print("dims of fieldpcon are: "+dimsizes(fieldpcon))
print("dims of fieldpgsp are: "+dimsizes(fieldpgsp))
  totpreci=(fieldpcon(outs)-fieldpcon(0)+fieldpgsp(outs)-fieldpgsp(0))/(outputint*outs)
totprecf1=totpreci*86400
totprecf1_avg=avg(fieldpt_avg)*86400
print("-----------------------------------------")
print("--------file 1---------------------------")
print("tot precip average ="+totpreci*86400)
print("tot_prec_rate_ave ="+avg(fieldpt_avg)*86400)
print("-----------------------------------------")

if (isvar("accumulated")) then
  ; compute instantaneous values
  shfl = new((/interv-1/),float)
  lhfl = new((/interv-1/),float)
  thb_s = new((/interv-1/),float)
  sob_s = new((/interv-1/),float)
  swtao = new((/interv-1/),float)
  swtaoclr = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  lwtaoclr = new((/interv-1/),float)
  lwsfcclr = new((/interv-1/),float)
  swsfcclr = new((/interv-1/),float)
  shfl = 0.0
  lhfl = 0.0
  thb_s = 0.0
  sob_s = 0.0
  swtao = 0.0
  swtaoclr = 0.0
  lwtao = 0.0
  lwtaoclr = 0.0
  lwsfcclr = 0.0
  swsfcclr = 0.0

;  if (.not. isvar("clearsky")) then
;    lwtaoclr=lwtao
;    swtaoclr=swtao
;  end if

; compute instantaneous values from accumulated fields
; note the clear sky fluxes are not accumulated
  do it=istart,iend,inc
    shfl(it-1) = field1(it)-field1(it-1)
    lhfl(it-1) = field2(it)-field2(it-1)
    thb_s(it-1) = fieldthb1(it)-fieldthb1(it-1)
    sob_s(it-1) = fieldsob1(it)-fieldsob1(it-1)
    swtao(it-1) = field5(it)-field5(it-1)
    swtaoclr(it-1) = field5b(it)
    lwtao(it-1) = field6(it)-field6(it-1)
    lwtaoclr(it-1) = field6b(it)
    lwsfcclr(it-1) = field6bsfc(it)
    swsfcclr(it-1) = field5bsfc(it)
    ; correct for problems related to jumps in accumulated quantities
    tempval=swtao(it-1)
    ;print("value of tempval ="+tempval)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        shfl(it) = shfl(it-1)
        lhfl(it) = lhfl(it-1)
        thb_s(it) = thb_s(it-1)                                                        
        sob_s(it) = sob_s(it-1)                                                        
        swtao(it) = swtao(it-1)                                                              
        swtaoclr(it) = swtaoclr(it-1)
        lwtao(it) = lwtao(it-1)
        lwtaoclr(it) = lwtaoclr(it-1)
        lwsfcclr(it) = lwsfcclr(it-1)                                                                    
        swsfcclr(it) = swsfcclr(it-1)   
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 

; normalize by output interval
  shfl=shfl/outputint
  lhfl=lhfl/outputint
  thb_s=thb_s/outputint
  sob_s=sob_s/outputint
  swtao=swtao/outputint
  lwtao=lwtao/outputint

  monthlymean=1
  lastindex=iend-aveint/2

  print("the lastindex is: "+lastindex)
  print("min of lhfl="+min(lhfl)+"located at "+minind(lhfl))
  print("max of lhfl="+max(lhfl))
  print("min of shfl="+min(shfl)+"located at "+minind(shfl))
  print("max of shfl="+max(shfl))

  ; save unfiltered toa_e_off
  swtao1=swtao
  lwtao1=lwtao
  toa_off_raw1=swtao+lwtao

  if(monthlymean .gt. 0) then
    print("file1: computing running monthly mean values...")
    print("number of time steps for running mean is: "+aveint)
    ;print("dimensions of shfl: "+dimsizes(shfl))
    ;print("dimensions of lhfl: "+dimsizes(lhfl))
    shfl=runave(shfl,aveint,0)
    lhflavg=runave(lhfl,aveint,0)
    thb_s=runave(thb_s,aveint,0)
    sob_s=runave(sob_s,aveint,0)
    swtao=runave(swtao,aveint,0)
    swtaoclr=runave(swtaoclr,aveint,0)
    lwtao=runave(lwtao,aveint,0)
    lwtaoclr=runave(lwtaoclr,aveint,0)
    lwsfcclr=runave(lwsfcclr,aveint,0)
    swsfcclr=runave(swsfcclr,aveint,0)

    ;print("file1 last runmean val lhfl ="+lhfl(lastindex))
    ;print("file1 last runmean val shfl ="+shfl(lastindex))
    ;print("file1 last runmean val thb_s ="+thb_s(lastindex))
    ;print("file1 last runmean val sob_s ="+sob_s(lastindex))
    ;print("file1 last runmean val swtao ="+swtao(lastindex))
    ;print("file1 last runmean val lwtao ="+lwtao(lastindex))
  end if
  ; compute the imbalance at toa and sfc for file1 values
  toa_e_off=swtao+lwtao
  print("you stupid little nimrod")
  toa_e_off_clr=swtaoclr+lwtaoclr
  sfc_e_off=shfl+lhfl+thb_s+sob_s
  mntoaimb1clr=avg(toa_e_off_clr)
  print("mntoaimb1clr="+mntoaimb1clr)
else
  toa_e_off=field5+field6
  sfc_e_off=field1+field2+fieldthb1+fieldsob1
end if

;mntoaimb1=avg(toa_e_off)
;mnsfcimb1=avg(sfc_e_off)
;atmimb=mntoaimb1-mnsfcimb1
;mntoaimb1=toa_e_off(lastindex)
mntoaimb1=avg(toa_e_off)
;mnsfcimb1=sfc_e_off(lastindex)
mnsfcimb1=avg(sfc_e_off)
atmimb=mntoaimb1-mnsfcimb1

lwcrf1=avg(lwtaoclr)-avg(lwtao)
swcrf1=avg(swtaoclr)-avg(swtao)

print("Mean values...")

print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
print("SW sfc sob_s ="+avg(sob_s))
print("LW sfc thb_s ="+avg(thb_s))
print("lhfl ="+avg(lhfl))
print("shfl ="+avg(shfl))
print("file1 TOA E imbalance : "+mntoaimb1)

;print("SW toa clear sky transmissivity : "+field5b(timelen))
;print("SW sfc clear sky transmissivity : "+field5bsfc(timelen))
print("SW clear toa Flux : "+avg(swtaoclr))
print("LW clear toa Flux : "+avg(lwtaoclr))
print("SW clear sfc Flux : "+avg(swsfcclr))
print("LW clear sfc Flux : "+avg(lwsfcclr))
print("file1 TOA clr E imbalance : "+mntoaimb1clr)

; asob_t-athb_t for TOA E imbalance
;print("file1 TOA E imbalance avg: "+avg(mntoaimb1))
;print("file1 SFC E imbalance avg: "+avg(mnsfcimb1))
;print("file1 atmospheric imbalance: "+atmimb)
print("file1 SFC E imbalance : "+mnsfcimb1)
print("file1 atmospheric imbalance: "+atmimb)
print("---------------below is data from file two------------------------------------")
delete([/shfl,lhfl,thb_s,sob_s,swtao,swtaoclr,lwtao,lwtaoclr,lwsfcclr,swsfcclr/])
;-------------------------------------------------------------------------
; read variables from File 2
;-------------------------------------------------------------------------
;
delete(infile)
;; read in File 2
;; open/reference desired file (use addfiles to reference multiple data file)
if (isvar("iFile2")) then
 infile = addfile(iFile2+".nc","r")
print("------------------------------------------------------------------------------")
 print("file2 is :"+iFile2)
print("------------------------------------------------------------------------------")

; read in the sensible and latent heat fluxes below-----------------------
varname7=varname1
ltitle7=varname7
if (.not. isvar("fmn"))
  field7 = infile->$varname7$(timemin:timelen,:)
else
  field7 = infile->$varname7$(timemin:timelen,0,0)
end if

varname8=varname2
ltitle8=varname8
if (.not. isvar("fmn"))
  field8 = infile->$varname8$(timemin:timelen,:)
else
  field8 = infile->$varname8$(timemin:timelen,0,0)
end if

varthb2=varthb1 ; surface net thermal radiation acc. since model start
ltitle2=varthb2
if (.not. isvar("fmn"))
    fieldthb2 = infile->$varthb2$(timemin:timelen,:)
else
    fieldthb2 = infile->$varthb2$(timemin:timelen,0,0)
end if

varsob2=varsob1 ; surface net solar radiation acc. since model start
ltitle2=varsob2
if (.not. isvar("fmn"))
    fieldsob2 = infile->$varsob2$(timemin:timelen,:)
else
    fieldsob2 = infile->$varsob2$(timemin:timelen,0,0)
end if

; read in fluxes from toa-----------------------------------------------
varname3=varname5
;if (isvar("nwp")) then
;  ;varname3="sob_t" ; instantaneous
;  if (isvar("accumulated")) then
;    varname3="accsob_t" ; accumulated value
;  else
;    varname3="asob_t" ; average over outputtimeinterval
;  end if 
;end if
ltitle5=varname3
  if (.not. isvar("fmn"))
      field3 = infile->$varname3$(timemin:timelen,:)
  else
      field3 = infile->$varname3$(timemin:timelen,0,0)
  end if
if (isvar("nwp")) then
  if (.not. isvar("clearsky")) then
    varname3b=varname3
    field3 = infile->$varname3$(timemin:timelen,0,0)
    field3b = infile->$varname3b$(timemin:timelen,0,0)
    print("Cuation!  Clear sky fluxes not read, output for clr is meaningless!!!")
  else
    varname3b="trsolclr" ; average over outputtimeinterval
    field3b = infile->$varname3b$(timemin:timelen,0,0,0)
    field3b=341*field3b
  end if
  ltitle3b=varname3b
end if
  
; define var6
;varname4="prm_lwflxtoa"
varname4=varname6
ltitle6=varname4
  if (.not. isvar("fmn"))
    field4 = infile->$varname4$(timemin:timelen,:)
  else
    if (isvar("nwp")) then
      ;field4 = infile->$varname4$(0,1,0,0)
      field4 = infile->$varname4$(timemin:timelen,0,0)
    else
      field4 = infile->$varname4$(timemin:timelen,0,0)
    end if
  end if
if (isvar("nwp")) then
  if (.not. isvar("clearsky")) then
    varname4b=varname4
    field4b = infile->$varname4b$(timemin:timelen,0,0)
  else
    varname4b="lwflxclr"
    field4b = infile->$varname4b$(timemin:timelen,0,0,0)
  end if
  ltitle4=varname4b
end if

; read in precip fields to compute hydro. sens.
if (isvar("nwp")) then
 ; varpgsp     ="rain_gsp"
 ; varpcon     ="rain_con"
 ; varptot_avg ="tot_prec_rate_avg"
  fieldpgsp   = infile->$varpgsp$(timemin:timelen,0,0)
  fieldpcon   = infile->$varpcon$(timemin:timelen,0,0)
  fieldpt_avg = infile->$varptot_avg$(timemin:timelen,0,0)
end if

  outs=timelen-timemin
  totpreci=(fieldpcon(outs)-fieldpcon(0)+fieldpgsp(outs)-fieldpgsp(0))/(outputint*outs)
totprecf2=totpreci*86400
totprecf2_avg=avg(fieldpt_avg)*86400
hydrosens=(totprecf1-totprecf2)/(totprecf1*4.)
hydrosens2=(totprecf1_avg-totprecf2_avg)/(totprecf1*4.)

print("-----------------------------------------")
print("--------file 1---------------------------")
print("tot precip average ="+totprecf1)
print("tot_prec_rate_ave ="+totprecf1_avg)
print("-----------------------------------------")
print("--------file 2---------------------------")
print("tot precip average ="+totprecf2)
print("tot_prec_rate_ave ="+totprecf2_avg)
print("-----------------------------------------")
print("Hydrologic Sensitivity ="+hydrosens)
print("Hydrologic Sensitivity 2 ="+hydrosens2)
print("-----------------------------------------")

if (isvar("accumulated")) then
  ; compute instantaneous values
  shfl = new((/interv-1/),float)
  lhfl = new((/interv-1/),float)
  thb_s = new((/interv-1/),float)
  sob_s = new((/interv-1/),float)
  swtao = new((/interv-1/),float)
  swtaoclr = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  lwtaoclr = new((/interv-1/),float)
  swsfcclr = new((/interv-1/),float)
  shfl = 0.0
  lhfl = 0.0
  swtao = 0.0
  swtaoclr = 0.0
  lwtao = 0.0
  lwtaoclr = 0.0
  thb_s = 0.0
  sob_s = 0.0
  swsfcclr = 0.0

  ;if (.not. isvar("clearsky")) then
  ;  lwtaoclr=lwtao
  ;  swtaoclr=swtao
  ;end if

  ; computed instantaneous values
  do it=istart,iend,inc
    shfl(it-1) = field7(it)-field7(it-1)
    lhfl(it-1) = field8(it)-field8(it-1)
    thb_s(it-1) = fieldthb2(it)-fieldthb2(it-1)
    sob_s(it-1) = fieldsob2(it)-fieldsob2(it-1)
    swtao(it-1) = field3(it)-field3(it-1)
    swtaoclr(it-1) = field3b(it)
    lwtao(it-1) = field4(it)-field4(it-1)
    lwtaoclr(it-1) = field4b(it)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        shfl(it) = shfl(it-1)
        lhfl(it) = lhfl(it-1)
        thb_s(it) = thb_s(it-1)                                                        
        sob_s(it) = sob_s(it-1)                                                        
        swtao(it) = swtao(it-1)                                                              
        swtaoclr(it) = swtaoclr(it-1)
        lwtao(it) = lwtao(it-1)
        lwtaoclr(it) = lwtaoclr(it-1)
        lwsfcclr(it) = lwsfcclr(it-1)                                                                    
        swsfcclr(it) = swsfcclr(it-1)   
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  shfl=shfl/outputint
  lhfl=lhfl/outputint
  thb_s=thb_s/outputint
  sob_s=sob_s/outputint
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtao2=swtao
  lwtao2=lwtao
  toa_off_raw2=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file2: computing running monthly mean values...")
    shfl=runave(shfl,aveint,0)
    lhfl=runave(lhfl,aveint,0)
    thb_s=runave(thb_s,aveint,0)
    sob_s=runave(sob_s,aveint,0)
    swtao=runave(swtao,aveint,0)
    swtaoclr=runave(swtaoclr,aveint,0)
    lwtao=runave(lwtao,aveint,0)
    lwtaoclr=runave(lwtaoclr,aveint,0)
    ;print("file2 last runmean val lhfl ="+lhfl(lastindex))
    ;print("file2 last runmean val shfl="+shfl(lastindex))
    ;print("file2 last runmean val thb_s ="+thb_s(lastindex))
    ;print("file2 last runmean val sob_s ="+sob_s(lastindex))
    ;print("file2 last runmean val swtao ="+swtao(lastindex))
    ;print("file2 last runmean val lwtao ="+lwtao(lastindex))
  end if
  toa_e_off2=swtao+lwtao
  toa_e_off2_clr=swtaoclr+lwtaoclr
  sfc_e_off2=shfl+lhfl+thb_s+sob_s
  mntoaimb2clr=avg(toa_e_off2_clr)
else
  toa_e_off2=field3+field4
  sfc_e_off2=field7+field8+fieldthb2+fieldsob2
end if

;mntoaimb2=avg(toa_e_off2)
;mnsfcimb2=avg(sfc_e_off2)
;atmimb=mntoaimb2-mnsfcimb2
;mntoaimb2=toa_e_off2(lastindex)
mntoaimb2=avg(toa_e_off2)
;mnsfcimb2=sfc_e_off2(lastindex)
mnsfcimb2=avg(sfc_e_off2)
atmimb=mntoaimb2-mnsfcimb2

lwcrf2=avg(lwtaoclr)-avg(lwtao)
swcrf2=avg(swtaoclr)-avg(swtao)

print("Mean values...")
print("lhfl ="+avg(lhfl))
print("shfl ="+avg(shfl))
print("LW sfc ="+avg(thb_s))
print("SW sfc ="+avg(sob_s))
;print("SW clear sky transmissivity at timelen: "+field3b(timelen))
print("SW clear sky Flux : "+avg(field3b))
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
print("LW clear sky Flux : "+avg(field4b))
print("LW clear sky Flux : "+avg(field4b))

; asob_t-athb_t for TOA E imbalance
print("file2 TOA E imbalance : "+mntoaimb2)
print("file2 TOA E clear sky imbalance : "+mntoaimb2clr)
print("file2 SFC E imbalance : "+mnsfcimb2)
print("file2 atmospheric imbalance: "+atmimb)

  ; compute the equilibrium climate sensitivity
  delT = 4 ; [K] difference in surface temperature between runs
  co2forcing = -3.7 ; [W/m^2]

; to compute the uncertainty we need to compute the autocorrelation of the rad imbalance.  
; this should be done on data that has not yet been filtered or averaged.  

  lambdarnmean    = (mntoaimb1-mntoaimb2)/delT
  lambdarnmeanclr = (mntoaimb1clr-mntoaimb2clr)/delT
  lambda_tseries  = (toa_e_off-toa_e_off2)/delT
  lambda_raw      = (toa_off_raw1-toa_off_raw2)/delT
  lambda_rawmn    = avg((toa_off_raw1-toa_off_raw2)/delT)
print("--------SW------LAMBDA---------LW----------------")
print("max/min of swtao 1:"+max(swtao1)+"/"+min(swtao1)+" and 2:"+max(swtao2)+"/"+min(swtao2))
print("max/min of lwtao 1:"+max(lwtao1)+"/"+min(lwtao1)+" and 2:"+max(lwtao2)+"/"+min(lwtao2))
  lambda_sw       = (swtao1-swtao2)/delT
  lambda_lw       = (lwtao1-lwtao2)/delT
print("avg sw lambda="+avg(lambda_sw))
print("avg lw lambda="+avg(lambda_lw))
print("------------------------------------------------")

; threshold value for comptations of lambda
minlam=-0.037
;print("lambda raw = "+lambda_raw)
print("max lambda raw = "+max(lambda_raw))
print("min lambda raw = "+min(lambda_raw))
print("mean of lambda raw = "+avg(lambda_raw))
lambda_raw= where(lambda_raw .le. -100., default_fillvalue("float"),lambda_raw)
print("mean of lambda tseries rnmn = "+avg(lambda_tseries))
print("min of lambda_raw "+min(abs(lambda_raw)))
print("std of lambda_raw "+stddev(lambda_raw))
;print("min of lambda_raw_f "+min(abs(lambda_raw_f)))
;print("std of lambda_raw_f "+stddev(lambda_raw_f))
;print("lambda_raw: "+lambda_raw)

  ecsrnmean    = co2forcing/lambdarnmean
  ecsrnmeanclr = co2forcing/lambdarnmeanclr
  ecsraw       = co2forcing/avg(lambda_raw)
  ecsstddev= stddev(ecsraw)
print("unfiltered ecs ="+ecsraw)
;  ecs_tseries  = co2forcing/lambda_tseries
  ;lambda_raw   = where(lambda_raw .ne. 0.0, lambda_raw,0.01)
print("min of lambda_raw "+min(abs(lambda_raw)))
  lambda_raw_filtered   = where(lambda_raw .ge. minlam, minlam,lambda_raw)
  lambda_rawmn_filtered = avg(lambda_raw_filtered)
print("min of lambda_raw_filtered "+min(lambda_raw_filtered))
print("max of lambda_raw_filtered "+max(lambda_raw_filtered))
  ecs_filtered          = co2forcing/lambda_raw_filtered
  ecsmn_filtered        = avg(ecs_filtered)
print("ecsmn_filtered = avg(co2forcing/lambda_raw_filtered) = "+ecsmn_filtered)  
print("co2forcing/avg(lambda_raw_filtered) = "+co2forcing/lambda_rawmn_filtered)
  ecsstddev_filtered = stddev(ecs_filtered)
;print("ecs = "+ecs)
;print("max of mn ecs: "+max(ecs_tseries)+" min of mn ecs: "+min(ecs_tseries))
;print("dimensions of ecs tseries are: "+dimsizes(ecs_tseries))
;print("last mn lambda = "+lambdarnmean)
;print("runmean ecs = "+ecsrnmean)
;print("runmean ecs clear sky = "+ecsrnmeanclr)

; i am not sure if the signs are correct (according to Soden, positive values
; of crf should have a heating effect on the climate)
; cloud radiative forcing
;lwcrf=(lwcrf2-lwcrf1)/4.
;swcrf=(swcrf2-swcrf1)/4.
lwcrf=(lwcrf1-lwcrf2)/4. ; should be the crf for 301 - crf for 297
swcrf=(swcrf1-swcrf2)/4.

; cloud radiative forcing for first and second files
; see Soden et al. 2004

crf1=lwcrf1-swcrf1
crf2=lwcrf2-swcrf2

print("lwcrf is: "+lwcrf)
print("swcrf is: "+swcrf)
print("crf1 = lwcrf1 - swcrf1: "+lwcrf1+" - "+swcrf1+" = "+crf1)
print("crf2 = lwcrf2 - swcrf2: "+lwcrf2+" - "+swcrf2+" = "+crf2)

print("what? "+(crf1-crf2)/4.)

print("--------------------------------------------------------------")

; compute the uncertainty of ECS
; first compute the integral of the autocorrelation to judge the number of 
; degrees of freedom (decorrelation scale)

  radimb=delT*lambda_raw
print("min of 50M: "+min(radimb))
radimb_f   = where(radimb .le. -100.0, default_fillvalue("float"),radimb)
print("min of 50M: "+min(radimb_f))
print("std of 50M: "+stddev(radimb_f))
radimb=radimb_f
  taylor1 = sum(esacr(radimb,dimsizes(radimb)-2))
testplot=esacr(radimb,dimsizes(radimb))
zerocross=ind(testplot .le. 0.01)
print("first index with values of the autocorrelation lt 0.01: "+zerocross(0))
wks = gsn_open_wks("ps","gsn_xy")
  res                        = True
  res@gsnFrame               = True
  plot=gsn_y(wks,testplot(:2000),res)
draw(plot)
print("taylor1 = "+taylor1)
print("dims of radimb are "+dimsizes(radimb))

; 99 percent confidence means p=0.995 in single-sided t-test:

  siglvl     = 0.95
; why must i add a negative sign below (neg autocorr?)?
  taylor1=252
print("!!! taylor1 value manually fixed!!!")
  tval_Allan  = cdft_t(siglvl,abs(dimsizes(radimb)/(taylor1))-2)

; compute the standard deviation of the feedback parameter
  lambdastddev = stddev(lambda_raw)

print("tval is "+tval_Allan)
print("error is ="+tval_Allan*lambdastddev)
  min_lam    = lambda_rawmn-tval_Allan*lambdastddev/sqrt(dimsizes(radimb)/taylor1)
  max_lam    = lambda_rawmn+tval_Allan*lambdastddev/sqrt(dimsizes(radimb)/taylor1)

print("mean lambda ="+lambda_rawmn+" stddev of "+lambdastddev)
print("min_lam = "+min_lam+" max_lam = "+max_lam)

  ecs_mean   = co2forcing/lambda_rawmn
  ;min_ecs    = co2forcing/(lambda_rawmn-min_lam)
  ;max_ecs    = co2forcing/(lambda_rawmn+max_lam)
  min_ecs    = co2forcing/(min_lam)
  max_ecs    = co2forcing/(max_lam)

print(" ecsmean ="+ecs_mean+" stddev of ecs "+ecsstddev)
print("min_ecs = "+min_ecs+" max_ecs = "+max_ecs)

print("-------------------------END----------------------------------")

end if

;;------------------------------------------------------------------------

end






