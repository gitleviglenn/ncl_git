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
; 1.  interpolate to GCM like grid 
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
if (omega .lt. 1) then
  wvar_a=fc_om->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_a=fc_om->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_a=fc_om->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

wvar_a=scalef*wvar_a
  print("scaleing by factor: "+scalef)
wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;*************************************************************
; 1.  interpolate to GCM like grid
;-------------------------------------------------------------

; first method to coarsen the grid of the CRM

x_orig = fc_om->x
y_orig = fc_om->y

;y_new=fspan(0,384000,5)
;x_new=fspan(0,5952000,63)
;
y_new=fspan(0,384000,3)
x_new=fspan(0,6144000,63)

var_to_interpolate=wvar_a ; incoming CRM data
; var_to_interpolate must have y,x as its two rightmost dimensions...

juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,False)
intvar_out=juljack

  print("-----------Variable that will be interpolated----------------")
  printVarSummary(var_to_interpolate)
  print("-----------Variable after being interpolated-----------------")
  printVarSummary(intvar_out)
  print("-------------------------------------------------------------")

;----------------
; second method to coarsen the grid of the CRM to something like a GCM
;----------------
;
if (make_coarse) then
else
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
  
    printVarSummary(subfrac_a)
    ;print("lentime is :"+lentime)
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
end if ; make_coarse

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

dim_om1=dimsizes(intvar_out)
dim_om2=dimsizes(wvar_a)

;intvar_ch_a = new((/timewindow,numperiods,dim_om1(1),dim_om1(2)/),float)
;wvar_ch_a   = new((/timewindow,numperiods,dim_om2(1),dim_om2(2)/),float)
intvar_ch_a = new((/numperiods,timewindow,dim_om1(1),dim_om1(2)/),float)
wvar_ch_a   = new((/numperiods,timewindow,dim_om2(1),dim_om2(2)/),float)

;intvar_ch_a =reshape(intvar_out,(/timewindow,numperiods,dim_om1(1),dim_om1(2)/))
;wvar_ch_a   =reshape(wvar_a,(/timewindow,numperiods,dim_om2(1),dim_om2(2)/))
intvar_ch_a =reshape(intvar_out,(/numperiods,timewindow,dim_om1(1),dim_om1(2)/))
wvar_ch_a   =reshape(wvar_a,(/numperiods,timewindow,dim_om2(1),dim_om2(2)/))

; take the time average over chunks
intvar_ch_b = dim_avg_n(intvar_ch_a,1)
wvar_ch_b   = dim_avg_n(wvar_ch_a,1)

  printVarSummary(intvar_out)
  printVarSummary(intvar_ch_a)
;  printVarSummary(intvar_ch_b)
;  printVarSummary(wvar_ch_b)

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
  print("... (:,0,2,10) from intvar_out... ")
  print(intvar_ch_a(:,0,2,10))
  print("... (:,1,2,10) from intvar_out... ")
  print(intvar_ch_a(:,1,2,10))
  print("... (0,:,2,10) from intvar_out... ")
  print(intvar_ch_a(0,:,2,10))
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print("... ... ... ... ... ")
  print(" end checking the reshapeing... ")
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

;if (make_coarse) then
;    print("using coarse grid")
;    print("dimsizes of intvar_out are: "+dimsizes(intvar_out))
;  omega_u_a      =where((intvar_out .le. 0),intvar_out,intvar_out@_FillValue)
;  omega_u_a_frac =where((intvar_out .le. 0),1.0,0.0)
;  omega_d_a      =where((intvar_out .ge. 0),intvar_out,intvar_out@_FillValue)
;  omega_d_a_frac =where((intvar_out .ge. 0),1.0,0.0)
;else
;    print("using original grid")
;  omega_u_a      =where((wvar_a .le. 0),wvar_a,wvar_a@_FillValue)
;  omega_u_a_frac =where((wvar_a .le. 0),1.0,0.0)
;  omega_d_a      =where((wvar_a .ge. 0),wvar_a,wvar_a@_FillValue)
;  omega_d_a_frac =where((wvar_a .ge. 0),1.0,0.0)
;end if


;; use 1 day chunks
; we shouldn't have to reshape here if step 2 is correct....
;omega_u_b     = new((/24,ndays*numperiods,dim_om(1),dim_om(2)/),float)
;omega_d_b     = new((/24,ndays*numperiods,dim_om(1),dim_om(2)/),float)
;subfrac_array = new((/24,ndays*numperiods,dim_om(1),dim_om(2)/),float)
;
;omega_u_b =reshape(omega_u_a,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
;omega_d_b =reshape(omega_d_a,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))

;if (make_coarse) then
;    print("using coarse grid")
;  subfrac_array  =reshape(intvar_out,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
;  ; haven't test line below...
;  ;subfrac_array  =reshape(block_array,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
;else
;    print("using original grid")
;  subfrac_array  =reshape(wvar_a,(/24,ndays*numperiods,dim_om(1),dim_om(2)/))
;end if

;; compute time average over first day subsidence fraction
;subfrac_a     = dim_avg_n(subfrac_array,0)
;omega_u_c     = dim_avg_n(omega_u_b,0)
;omega_d_c     = dim_avg_n(omega_d_b,0)

;  printVarSummary(omega_u_a)
;  printVarSummary(omega_u_b)
;  printVarSummary(omega_u_c)
;  print(wvar_a(10,10,10))
;  print(subfrac_array(10,0,10,10))
;  print(wvar_a(34,10,10))
;  print(subfrac_array(10,1,10,10))
;  print(" end checking the reshapeing... ")

;*************************************************************
; 4. compute mn omega_u, omega_d, circulation intensity, and SF 
;-------------------------------------------------------------

;omega_up = dim_avg_n(intvar_u_ave,0)
;omega_dn = dim_avg_n(intvar_d_ave,0)
;printVarSummary(omega_u_a)
;omega_up = dim_avg_n(omega_u_a,0)
;omega_dn = dim_avg_n(omega_d_a,0)

omega_u_b = dim_avg_n(omega_u_a,0)
omega_d_b = dim_avg_n(omega_d_a,0)
omega_u_c = dim_avg_n(omega_u_b,0)
omega_d_c = dim_avg_n(omega_d_b,0)
omega_up   = dim_avg_n(omega_u_c,0)
omega_dn   = dim_avg_n(omega_d_c,0)

circulation_int = omega_dn-omega_up

;if (make_coarse) then
;  subfrac            = where((subfrac_a .le. 0),1.0,0.0)
;else
;  subfrac            = where((block_array .le. 0),1.0,0.0)
;end if

;subfrac         = where((subfrac_array .le. 0),1.0,0.0)
;subfrac@_FillValue = default_fillvalue("float")    ; set devault FillValue

;  printVarSummary(subfrac)
;subfrac_b = dim_avg_n(subfrac,1)
;  print("dimsizes of subfrac_b are: "+dimsizes(subfrac_b))
;subfrac_c = dim_avg_n(subfrac_b,1)
;  print("dimsizes of subfrac_c are: "+dimsizes(subfrac_c))
;subfrac_d = dim_avg_n(subfrac_c,0)
;;  printVarSummary(subfrac_c)
;;  printVarSummary(subfrac_d)
;  print("the subsidence fraction ISISISIS: "+subfrac_d)

total_area=dim_om1(1)*dim_om1(2)
;omega_temp =new((/1,nlat,nlon/),float)
sfrac      =new((/dim_om1(0)/),float)
sfrac_up   =new((/dim_om1(0)/),float)
tend=numperiods
  print(" tend is: ")
  print(" dimsizes of omega_u_a_frac are: "+dimsizes(omega_u_a_frac))
do tt=0,tend-1
  ;omega_temp(1,:,:)=omega_u_a_frac(tt,:,:)
  omega_temp2  =omega_u_a_frac(tt,:,:)
  omega_temp3  =omega_d_a_frac(tt,:,:)
  sfrac_up(tt) =sum(omega_temp2)/total_area
  sfrac(tt)    =sum(omega_temp3)/total_area
end do
  print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" frac of ascending air at 1 timestep is: "+sfrac_up(10))

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

filenameout    = "mean_omega_vals_"+ndays+"d_"+model+"_"+SST+".txt"
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
