;============================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;============================================================;
begin
;============================================================;
; radimb_tseries_5mod 
;
; ncl script to compute the equilibrium climate sensitivity
; this script also computes the toa and sfc imbalance over 
; the time period given by an internally set averaging period
;
; syntax: nclsh rce_ecs2.ncl -iFile=file1.nc -iFile2=file2.nc -fmn -nwp -accumulated -anom -time= -int= -ave=
;
; example command:
;rce_ecs_simple.ncl -iFile=to_data/nwprce/comp_timeseries/rce_ecs_20km_768gp_301_010109th310709_fldmn.nc -iFile2=to_data/nwprce/comp_timeseries/rce_ecs_20km_768gp_297_010109th310709_fldmn.nc -fmn -nwp -accumulated -anom -time=2500 -int=2500 -ave=36
;
; or if echam physics where used change the -nwp switch to -echam
;
; time: indicates the length of the time dimension that will be read
; int:  timemin = timelen-int --> this determines the interval over which data is processed
; ave:  interval over which the running mean will be computed
;
; levi silvers  		May 2015
;============================================================;

; read in File 1
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")

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
time1 = infile->time(:timelen)                ; time values
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
if (.not. isvar("fmn"))
    field5 = infile->$varname5$(timemin:timelen,:)
else
    field5 = infile->$varname5$(timemin:timelen,0,0)
end if

if (isvar("nwp")) then
    varname5b="accsob_t" ; average over outputtimeinterval
    ltitle5b=varname5
    field5b = infile->$varname5b$(timemin:timelen,0,0)
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
if (.not. isvar("fmn"))
  field6 = infile->$varname6$(timemin:timelen,:)
else
  if (isvar("nwp")) then
    field6 = infile->$varname6$(timemin:timelen,0,0)
  else
    field6 = infile->$varname6$(timemin:timelen,0,0)
  end if
end if

; define var6
;varname6b="prm_lwflxtoa"
if (isvar("nwp")) then
    varname6b=varname6
    field6 = infile->$varname6b$(timemin:timelen,0,0)
end if

if (isvar("accumulated")) then
  ; compute instantaneous values
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0

; compute instantaneous values from accumulated fields
; note the clear sky fluxes are not accumulated
  do it=istart,iend,inc
    swtao(it-1) = field5(it)-field5(it-1)
    lwtao(it-1) = field6(it)-field6(it-1)
    ; correct for problems related to jumps in accumulated quantities
    tempval=swtao(it-1)
    ;print("value of tempval ="+tempval)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 

; normalize by output interval
  swtao=swtao/outputint
  lwtao=lwtao/outputint

  monthlymean=1
  lastindex=iend-aveint/2

  ; save unfiltered toa_e_off
  swtao1=swtao
  lwtao1=lwtao
  toa_off_raw1=swtao+lwtao

  if(monthlymean .gt. 0) then
    print("file1: computing running monthly mean values...")
    print("number of time steps for running mean is: "+aveint)
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)

  end if
  ; compute the imbalance at toa and sfc for file1 values
  toa_e_off=swtao+lwtao
  print("you stupid little nimrod")
else
  toa_e_off=field5+field6
end if

mntoaimb1=avg(toa_e_off)

print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
print("file1 TOA E imbalance : "+mntoaimb1)

print("------------------End Mean values---------------")

print("---------------below is data from file two------------------------------------")
;delete([/shfl,lhfl,thb_s,sob_s,swtao,swtaoclr,lwtao,lwtaoclr,lwsfcclr,swsfcclr/])
delete([/swtao,lwtao/])
;-------------------------------------------------------------------------
; read variables from File 2
;-------------------------------------------------------------------------
;
delete(infile)
if (isvar("iFile2")) then
 infile = addfile(iFile2+".nc","r")
print("---------------------------------------------------------------------------------------")
print("---------------below is data from file2: "+iFile2+"------------------------------------")
print("---------------------------------------------------------------------------------------")

; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
  
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if

if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtao2=swtao
  lwtao2=lwtao
  toa_off_raw2=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file2: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_off2=swtao+lwtao
else
end if
mntoaimb2=avg(toa_e_off2)

print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file2 TOA E imbalance : "+mntoaimb2)
print("------------------End Mean values---------------")
print("---------------------------------------------------------------------------------------")
delete([/swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_48gp_301_0809th0718_fldmn.nc","r")
print("---------------below is data from file3: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file3: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb3=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file3 TOA E imbalance : "+mntoaimb3)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw48301=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_48gp_297_0809th0718_fldmn.nc","r")
print("---------------below is data from file4: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb4=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file4 TOA E imbalance : "+mntoaimb4)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw48297=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_96gp_301_fldmn_010808th310718.nc","r")
print("---------------below is data from file5: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb5=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file5 TOA E imbalance : "+mntoaimb5)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw96301=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_96gp_297_fldmn_0808th0718.nc","r")
print("---------------below is data from file6: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb6=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file6 TOA E imbalance : "+mntoaimb6)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw96297=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_192gp_301_fldmn_010909th010812.nc","r")
print("---------------below is data from file7: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb7=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file7 TOA E imbalance : "+mntoaimb7)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw192301=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_192gp_297_fldmn_010909th010812.nc","r")
print("---------------below is data from file8: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
mntoaimb8=avg(toa_e_offnew)
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
print("file8 TOA E imbalance : "+mntoaimb8)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw192297=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_384gp_301_fldmn_0909th0810.nc","r")
print("---------------below is data from file9: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
mntoaimb9=avg(toa_e_offnew)
print("file9 TOA E imbalance : "+mntoaimb9)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw384301=toa_off_rawnew

print("---------------------------------------------------------------------------------------")
delete([/toa_off_rawnew,swtaonew,lwtaonew,toa_e_offnew,swtao,lwtao,field3,field4/])
delete(infile)
infile = addfile("to_data/nwprce/comp_timeseries/rce_ecs_20km_384gp_297_fldmn_0909th0810.nc","r")
print("---------------below is data from file10: ----------------------------------------------")
print("---------------------------------------------------------------------------------------")
; read in fluxes from toa-----------------------------------------------
varname3=varname5
if (isvar("nwp")) then
   varname3b=varname3
   field3 = infile->$varname3$(timemin:,0,0)
end if
;varname4="prm_lwflxtoa"
varname4=varname6
if (isvar("nwp")) then
  field4 = infile->$varname4$(timemin:,0,0)
end if
if (isvar("accumulated")) then
  swtao = new((/interv-1/),float)
  lwtao = new((/interv-1/),float)
  swtao = 0.0
  lwtao = 0.0
  ; compute instantaneous values
  do it=istart,iend,inc
    swtao(it-1) = field3(it)-field3(it-1)
    lwtao(it-1) = field4(it)-field4(it-1)
    tempval=swtao(it-1)
    if (it .gt. 2) then
      if (abs(tempval) .gt. 3*abs(swtao(it-1))) then
        print("value of swtao at this index is:"+swtao(it))
        print("CONDITION MET WATCH OUT!") 
        swtao(it) = swtao(it-1)                                                              
        lwtao(it) = lwtao(it-1)
        print("value of swtao at this index is:"+swtao(it))
        print("---------------------------------------------")
      end if
    end if
  end do 
  swtao=swtao/outputint
  lwtao=lwtao/outputint
  ; save unfiltered toa_e_off
  swtaonew=swtao
  lwtaonew=lwtao
  toa_off_rawnew=swtao+lwtao
  if(monthlymean .gt. 0) then
    print("file4: computing running monthly mean values...")
    swtao=runave(swtao,aveint,0)
    lwtao=runave(lwtao,aveint,0)
  end if
  toa_e_offnew=swtao+lwtao
else
end if
print("------------------Mean values---------------")
print("SW toa ="+avg(swtao))
print("LW toa ="+avg(lwtao))
; asob_t-athb_t for TOA E imbalance
mntoaimb10=avg(toa_e_offnew)
print("file10 TOA E imbalance : "+mntoaimb10)
print("------------------End Mean values---------------")
; save the raw rad bud at toa for this file
toa_off_raw384297=toa_off_rawnew

;------- EQUILIBRIUM CLIMATE SENSITIVITY ---------
delT = 4 ; [K] difference in surface temperature between runs
co2forcing = -3.7 ; [W/m^2]
minlam=1.e-5

; to compute the uncertainty we need to compute the autocorrelation of the rad imbalance.  
; this should be done on data that has not yet been filtered or averaged.  

  lambda_raw      = (toa_off_raw1-toa_off_raw2)/delT
  lambda_raw48     = (toa_off_raw48301-toa_off_raw48297)/delT
  lambda_raw96     = (toa_off_raw96301-toa_off_raw96297)/delT
  lambda_raw192     = (toa_off_raw192301-toa_off_raw192297)/delT
  lambda_raw384     = (toa_off_raw384301-toa_off_raw384297)/delT
  lambda_rawmn      = avg((toa_off_raw1-toa_off_raw2)/delT)
  lambda_sw       = (swtao1-swtao2)/delT
  lambda_lw       = (lwtao1-lwtao2)/delT
  lambda_raw_filtered   = where(abs(lambda_raw) .le. minlam, minlam,lambda_raw)
  ecsraw_filtered       = co2forcing/lambda_raw_filtered
  ecsstddev    = stddev(ecsraw_filtered)

print("--------SW------LAMBDA---------LW----------------")
print("max/min of swtao file 1:"+max(swtao1)+"/"+min(swtao1)+" and file 2:"+max(swtao2)+"/"+min(swtao2))
print("max/min of lwtao file 1:"+max(lwtao1)+"/"+min(lwtao1)+" and file 2:"+max(lwtao2)+"/"+min(lwtao2))
print("avg sw lambda="+avg(lambda_sw))
print("avg lw lambda="+avg(lambda_lw))
print("------------------------------------------------")

print("mean of lambda raw = "+avg(lambda_raw))

print("-------------Below: uncertainty of Lambda---------------------")
; first compute the integral of the autocorrelation to judge the number of 
; degrees of freedom (decorrelation scale)

radimb=delT*lambda_raw
print("min of 200M: "+min(radimb))
radimb_f   = where(radimb .le. -100.0, default_fillvalue("float"),radimb)
print("min of 200M: "+min(radimb_f))
print("std of 200M: "+stddev(radimb_f))
radimb48=delT*lambda_raw48
print("min of 34M: "+min(radimb48))
radimb48_f   = where(radimb48 .le. -100.0, default_fillvalue("float"),radimb48)
print("min of 34M: "+min(radimb48_f))
print("std of 34M: "+stddev(radimb48_f))
radimb96=delT*lambda_raw96
print("min of 3M: "+min(radimb96))
radimb96_f   = where(radimb96 .le. -100.0, default_fillvalue("float"),radimb96)
print("min of 3M: "+min(radimb96_f))
print("std of 3M: "+stddev(radimb96_f))
radimb192=delT*lambda_raw192
print("min of 12M: "+min(radimb192))
radimb192_f   = where(radimb192 .le. -100.0, default_fillvalue("float"),radimb192)
print("min of 12M: "+min(radimb192_f))
print("std of 12M: "+stddev(radimb192_f))
radimb384=delT*lambda_raw384
print("min of 50M: "+min(radimb384))
radimb384_f   = where(radimb384 .le. -100.0, default_fillvalue("float"),radimb384)
print("min of 50M: "+min(radimb384_f))
print("std of 50M: "+stddev(radimb384_f))
taylor1 = sum(esacr(radimb,dimsizes(radimb)-2))
testplot=esacr(radimb,dimsizes(radimb))
zerocross=ind(testplot .le. 0.01)
print("first index with values of the autocorrelation lt 0.01: "+zerocross(0))

; create plot of rad imbalances timeseries
timel=2200
plottime=ispan(1,timel+1,1)

wks = gsn_open_wks("ps","gsn_xy")
colors1 = (/"LawnGreen","SteelBlue","GoldenRod","Black","OrangeRed"/)
res                        = True
res@gsnFrame               = False
res@trYMinF = -20.0
res@trYMaxF = 20.0
res@trXMaxF=timel
;  plot=gsn_y(wks,testplot(:1000),res)
res@xyLineColors  = colors1(4)
print("dims of plottime are: "+dimsizes(plottime))
print("dims of radimb are: "+dimsizes(radimb(:timel)))
plot=gsn_csm_xy(wks,plottime,radimb(:timel),res)
print("std of 200M: "+stddev(radimb))
res@xyLineColors  = colors1(0)
plot48=gsn_csm_xy(wks,plottime,radimb48(:timel),res)
print("std of 34M: "+stddev(radimb48))
res@xyLineColors  = colors1(1)
plot96=gsn_csm_xy(wks,plottime,radimb96(:timel),res)
print("std of 3M: "+stddev(radimb96))
res@xyLineColors  = colors1(2)
plot192=gsn_csm_xy(wks,plottime,radimb192(:timel),res)
print("std of 12M: "+stddev(radimb192))
res@xyLineColors  = colors1(3)
radimb384_f   = where(radimb384 .le. -100.0, default_fillvalue("float"),radimb384)
plot384=gsn_csm_xy(wks,plottime,radimb384(:timel),res)
overlay(plot,plot48)
overlay(plot,plot96)
overlay(plot,plot192)
overlay(plot,plot384)

;polyres                   = True                       ; marker resources
;polyres@gsMarkerIndex     = 16                         ; index for circle
;polyres@gsMarkerSizeF     = .02                        ; size 
;polyres@gsLineThicknessF  = 5
;
;dataarr=(/4.67,4.92,5.11,5.20,5.21/)
;hpos=(/710,710,710,710,710/)
;centers = new(5,graphic)
;
;do t=0,4
;  polyres@gsMarkerColor = colors1(t)
;  ;polyres@gsLineColor = colors1(t)
;  print("1 "+hpos(t))
;  print("2 "+dataarr(t))
;  centers(t)   = gsn_add_polymarker(wks,plot0,hpos(t),dataarr(t),polyres)
;  ;error_bar(t) = gsn_add_polyline(wks,plot,(/domsize(t),domsize(t)/),\
;  ;(/dataup(t),datadn(t)/),polyres)
;end do

draw(plot)
frame(wks)

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
print("-------------Above: uncertainty of Lambda---------------------")

  min_lam    = lambda_rawmn-tval_Allan*lambdastddev/sqrt(dimsizes(radimb)/taylor1)
  max_lam    = lambda_rawmn+tval_Allan*lambdastddev/sqrt(dimsizes(radimb)/taylor1)

  ecs_mean   = co2forcing/lambda_rawmn
  ;min_ecs    = co2forcing/(lambda_rawmn-min_lam)
  ;max_ecs    = co2forcing/(lambda_rawmn+max_lam)
  min_ecs    = co2forcing/(min_lam)
  max_ecs    = co2forcing/(max_lam)

print("mean lambda ="+lambda_rawmn+" stddev of "+lambdastddev)
print("min_lam = "+min_lam+" max_lam = "+max_lam)
print(" ecsmean ="+ecs_mean+" stddev of ecs "+ecsstddev)
print("min_ecs = "+min_ecs+" max_ecs = "+max_ecs)

print("-------------------------END----------------------------------")

end if
;;------------------------------------------------------------------------

end






