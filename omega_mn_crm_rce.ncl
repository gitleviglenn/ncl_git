;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega_mn_crm_rce.ncl
;
; compute the circulation intensity, mean upward and downward vertical velocity for crms
;
; input: scalef: a scaling factor to convert wa500 from m/s to hPa/day
;
; output: circulation intensity, subsidence fraction, mean upward and downward velocity
;
; Methodology:
; 1. interpolate to GCM like grid 
; 2. create chunked arrays
; 3. sort into ascending and descending regions
; 4. compute mn omega_u, omega_d, circulation intensity, and SF
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
if (isvar("blocks")) then
  blocksize=blocks
else
  blocksize=1
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
make_coarse = True

  print("startime for reading data is: "+startime+" and end time is: "+endtime)
  print("numperiods is: "+numperiods)
  print("timewindow or chunk period (ndays*freq) is: "+timewindow)
  print("startime for reading data: "+startime+" lasttime to read data is: "+endtime)

;==========================
; define file locations via paths 

pch="/glade/scratch/levi/RCEMIP/"

file_om        =pch+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+seaST+"_2D_wa500.nc"
  print("file_om is: "+file_om)
fc_om       =addfile(file_om,"r")
lastx=1983
lasty=127
if (omega .lt. 1) then
  wvar_a=fc_om->wap500(startime:endtime,0:lasty,0:lastx)
else if (omega .lt. 2) then
  if (isvar("ICON_LEMfix")) then
    ;wvar_a=fc_om->wa500(startime:endtime,0,0:lasty,0:lastx)
    wvar_a=fc_om->wa500(startime:endtime,0:lastx,0:lasty)
  else
    wvar_a=fc_om->wa500(startime:endtime,0:lasty,0:lastx)
  end if
else if (omega .lt. 3) then
  wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,0:lasty,0:lastx)
end if 
end if 
end if

  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
  print("max and min of wvar_a are: "+max(wvar_a)+" and "+min(wvar_a))
  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

wvar_a=scalef*wvar_a
  print("scaleing by factor: "+scalef)
;wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;*************************************************************
; 1.  interpolate to GCM like grid
;-------------------------------------------------------------

;
; SAM_CRM:        y X x = 128 X 2048
; ICON_LEM_CRM:   y X x = 2000 X 134 
;

; first method to coarsen the grid of the CRM

if (isvar("UCLAfix")) then
    print("fixing things for UCLA CRM...")
  x_orig = fc_om->xt
  y_orig = fc_om->yt
else if (isvar("ICON_LEMfix")) then
  x_orig = fspan(1500,382500,128)
  y_orig = fspan(1500,5950500,1984)
else
  x_orig = fc_om->x(0:1983)
  y_orig = fc_om->y(0:127)
end if
end if

;  printVarSummary(x_orig)
;  printVarSummary(y_orig)

; GRIDS for the various CRMs...
; UCLA horizontal grid is 128x1984
; ICON LEM CRM horizontal grid is 2000x134
; SCALE hirozontal grid is 128x2048

;; for a grid representing 192x192km2 blocks
if (blocksize .eq. 2) then
     print("!!!!!! Interpolating to a 192km by 192km block size !!!!!!")
   blocksz="192km_"
  if (isvar("ICON_LEMfix")) then
    x_new=fspan(96000,288000,2)
    y_new=fspan(96000,5856000,32)
  else
    y_new=fspan(96000,288000,2)
    x_new=fspan(96000,5856000,32)
  end if
else
  ; 96x96km2 blocks
   blocksz="96km_"
  if (isvar("ICON_LEMfix")) then
    x_new=fspan(48000,336000,4)
    y_new=fspan(48000,5904000,62)
  else
    y_new=fspan(48000,336000,4)
    x_new=fspan(48000,5904000,62)
  end if
end if

; scale for SCALE.  it has the coordinates in km instead of m.  
; ICON LEM CRM has meaningless latitude like coordinates instead of m, although they do appear to be about 3 km apart...
if (isvar("SCALEfix")) then
  scaleaxis=1000.
else
  scaleaxis=1.
end if

y_orig=scaleaxis*y_orig
x_orig=scaleaxis*x_orig

;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
;  print("max and min of wvar_a are: "+max(wvar_a)+" and "+min(wvar_a))
;  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

var_to_interpolate=wvar_a ; incoming CRM data
;var_to_interpolate@_FillValue = default_fillvalue("float")    ; set devault FillValue

  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
  print("max and min of var_to_interpolate are: "+max(var_to_interpolate)+" and "+min(var_to_interpolate))
  print("dimsizes of var_to_interpolate are: "+dimsizes(var_to_interpolate))
  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

option = False
option@critpc = 50
notmissing=num(.not.ismissing(var_to_interpolate))
  print("number of NOT MISSING values are: "+notmissing)
juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,option)
  print("dimsizes of juljack are: "+dimsizes(juljack))
intvar_out=juljack

  print("-----------Variable that will be interpolated----------------")
  printVarSummary(var_to_interpolate)

;----------------
; second method to coarsen the grid of the CRM to something like a GCM
;----------------
;
if (.not.isvar("ICON_LEMfix"))
  lentime = timewindow*numperiods
  if (blocksize .eq. 2) then
    ; parameters for grid blocks of 192km
    block_array = new((/lentime,2,32/),float)
    block=floattointeger(64) ; block size for grid spacing of 192km
    iend = 1 ; for 2048 gridpoints, there are 32 blocks of 64
    jend = 30 ; for 128 gridpoints, there are two blocks of 64
  else   
    ; parameters for grid blocks of 96km
    block_array = new((/lentime,4,64/),float)
    block=floattointeger(32) ; block size for grid spacing of 96km
    iend = 3 ; for 2048 gridpoints, there are 32 blocks of 64
    jend = 61 ; for 128 gridpoints, there are two blocks of 64
  end if
  
    ;printVarSummary(subfrac_a)
    ;print("lentime is :"+lentime)
  do tindex=0,lentime-1
    do i=0,iend
      icounter=i*block
      do j=0,jend
        jcounter=j*block
        ;block_single   =subfrac_a(tindex,icounter:icounter+block-1,jcounter:jcounter+block-1)
        block_single   =var_to_interpolate(tindex,icounter:icounter+block-1,jcounter:jcounter+block-1)
        block_array(tindex,i,j)=avg(block_single)
      end do
    end do
  end do
  print("-----------Variable after being interpolated-----------------")
  printVarSummary(block_array)
  print("sample of block_array: "+block_array(500,:,31))
  print("-------------------------------------------------------------")
end if

;*************************************************************
; 2. reshape arrays to create chunks of days
;-------------------------------------------------------------

; at the moment it looks like data is averaged over daily chunks..

; which variables need to be averaged over chunks?  

; 24 = chunks*frequency
; ndays=chunks
; does ndays*frequency*numperiods = original number of timesteps?
; timewindow = ndays*frequency
; test_array = new((/timewindow,numperiods,dim_om(1),dim_om(2)/),float)

  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
  print("max and min of intvar_out are: "+max(intvar_out)+" and "+min(intvar_out))
  print("max and min of wvar_a are: "+max(wvar_a)+" and "+min(wvar_a))
  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

dim_om1=dimsizes(intvar_out)
dim_om2=dimsizes(wvar_a)

;if (isvar("ICON_LEMfix")) then
;  intvar_ch_a = new((/numperiods,timewindow,dim_om1(2),dim_om1(1)/),float)
;  wvar_ch_a   = new((/numperiods,timewindow,dim_om2(2),dim_om2(1)/),float)
;  intvar_ch_a = reshape(intvar_out,(/numperiods,timewindow,dim_om1(2),dim_om1(1)/))
;  wvar_ch_a   = reshape(wvar_a,(/numperiods,timewindow,dim_om2(2),dim_om2(1)/))
;else
  intvar_ch_a = new((/numperiods,timewindow,dim_om1(1),dim_om1(2)/),float)
  wvar_ch_a   = new((/numperiods,timewindow,dim_om2(1),dim_om2(2)/),float)
  intvar_ch_a =reshape(intvar_out,(/numperiods,timewindow,dim_om1(1),dim_om1(2)/))
  wvar_ch_a   =reshape(wvar_a,(/numperiods,timewindow,dim_om2(1),dim_om2(2)/))
;end if

  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
  print("dimsizes of intvar_ch_a are: "+dimsizes(intvar_ch_a))
  print(" which should be derivable from the dimensions of intvar_out: ")
  print("dimsizes of intvar_out are: "+dimsizes(intvar_out))
  print("max and min of intvar_ch_a are: "+max(intvar_ch_a)+" and "+min(intvar_ch_a))
  print("max and min of wvar_ch_a are: "+max(wvar_ch_a)+" and "+min(wvar_ch_a))
  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

; take the time average over chunks
intvar_ch_b = dim_avg_n(intvar_ch_a,1)
wvar_ch_b   = dim_avg_n(wvar_ch_a,1)

  printVarSummary(intvar_out)
  printVarSummary(intvar_ch_a)

if (isvar("ICON_LEMfix")) then
  print("... ... ... ... ... ")
else
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print(" begin checking the reshapeing... ")
  print(intvar_out(5,2,10))
  print(intvar_ch_a(0,5,2,10))
  print("... ... ... ... ... ")
  print(intvar_out(30,2,10))
  print(intvar_ch_a(1,6,2,10))
  print(intvar_ch_a(1,7,2,10))
  print(intvar_ch_a(1,8,2,10))
  print("... ... ... ... ... ")
  print("... first 125 values ... ")
  print(intvar_out(0:125,2,10))
  print("... (:,0,2,10) from intvar_ch_a... ")
  print(intvar_ch_a(:,0,2,10))
  print("... (:,1,2,10) from intvar_ch_a... ")
  print(intvar_ch_a(:,1,2,10))
  print("... (0,:,2,10) from intvar_ch_a... ")
  print(intvar_ch_a(0,:,2,10))
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print(" end checking the reshapeing... ")
end if
;*************************************************************
; 3. sort into ascending and descending regions 
;-------------------------------------------------------------

if (make_coarse) then
    print("using coarse grid")
    print("dimsizes of intvar_out are: "+dimsizes(intvar_out))
  omega_u_a      =where((intvar_ch_b .le. 0),intvar_ch_b,intvar_ch_b@_FillValue)
  omega_u_a_frac =where((intvar_ch_b .le. 0),1.0,0.0)
  omega_d_a      =where((intvar_ch_b .ge. 0),intvar_ch_b,intvar_ch_b@_FillValue)
  omega_d_a_frac =where((intvar_ch_b .ge. 0),1.0,0.0)
else
    print("using original grid")
  omega_u_a      =where((wvar_ch_b .le. 0),wvar_ch_b,wvar_ch_b@_FillValue)
  omega_u_a_frac =where((wvar_ch_b .le. 0),1.0,0.0)
  omega_d_a      =where((wvar_ch_b .ge. 0),wvar_ch_b,wvar_ch_b@_FillValue)
  omega_d_a_frac =where((wvar_ch_b .ge. 0),1.0,0.0)
end if
omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue


;*************************************************************
; 4. compute mn omega_u, omega_d, circulation intensity, and SF 
;-------------------------------------------------------------

omega_u_b = dim_avg_n(omega_u_a,0)
omega_d_b = dim_avg_n(omega_d_a,0)
omega_u_c = dim_avg_n(omega_u_b,0)
omega_d_c = dim_avg_n(omega_d_b,0)
omega_up   = dim_avg_n(omega_u_c,0)
omega_dn   = dim_avg_n(omega_d_c,0)

circulation_int = omega_dn-omega_up

total_area=dim_om1(1)*dim_om1(2)
sfrac      =new((/dim_om1(0)/),float)
sfrac_up   =new((/dim_om1(0)/),float)
tend=numperiods
  print(" tend is: ")
  print(" dimsizes of omega_u_a_frac are: "+dimsizes(omega_u_a_frac))
do tt=0,tend-1
  omega_temp2  =omega_u_a_frac(tt,:,:)
  omega_temp3  =omega_d_a_frac(tt,:,:)
  sfrac_up(tt) =sum(omega_temp2)/total_area
  sfrac(tt)    =sum(omega_temp3)/total_area
end do
;  print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" frac of ascending air at 1 timestep is: "+sfrac_up(10))

subsidenceF=dim_avg_n(sfrac,0)

if (scalef .gt. 1000.)
    print("Scale factor larger than 1000!! ")
  subsidenceF=1-subsidenceF
else
  ; no need to change subsidenceF
end if


;-------------------------------------------------------------
; print results to standard out

  print("$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^$%^")
  print("omega_dn is equal to: "+omega_dn+" and omega_up is equal to: "+omega_up)
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")
  print(" the subsidence fraction is: "+subsidenceF)
  print(">>>>>>>>>>>>")

;-------------------------------------------------------------

filenameout    = "omega_vals_"+blocksz+ndays+"d_"+model+"_"+SST+".txt"
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

end
