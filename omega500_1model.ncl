;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_1model.ncl
;
; analysis for 1 model to determine circulation strength.
; the goal is to be able to use this as a script for a driver ncl program
;
; most models have output at hourly frequencies, IPSL outputs on daily frequencies
;
; IPSL has daily output for 630 time steps...  
; most of the other models have around 26000 timesteps
; 
; input should be: 
; model, nlat, nlon, varname, conversion factor
;
; levi silvers                                                          june 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

print("begin adding files...")

; time parameters
;echam has 26280
timelength=8760 ; 1 year has 8760 hours
;startime=endtime-timelength+1

if (isvar("lasttime")) then
  endtime=lasttime
  print("lasttime var read, endtime is:  "+endtime)
else
  endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
;  timelength=8760 ; 1 year has 8760 hours
  print("lasttime var not detected, endtime is:  "+endtime)
end if

if (isvar("timesteps")) then
  startime=endtime-timesteps+1
  timelength=timesteps
  print("timesteps var read, startime is:  "+startime)
else
  startime=endtime-timelength+1
  print("timesteps var not detected, startime is:  "+startime)
end if

; path bases
path_laptop="/Users/silvers/data/CAM/"
path_cheyenne="/glade/scratch/levi/RCEMIP/"

;str_mod="ICON_GCM"
;str_var="wa500"
;model="ECHAM6_GCM"
;varname="wap500"

; the omega switch determines whether wap500 or wa500 is used...

filen_test=model+"_RCE_large295_2D_"+varname+".nc"
file_testmodel=path_cheyenne+"swift.dkrz.de/"+model+"/"+filen_test
print("incoming file: "+file_testmodel)
fin=addfile(file_testmodel,"r")
if (omega .lt. 1) then
  wvar_a=fin->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_a=fin->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_a=fin->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

printVarSummary(wvar_a)

filen_test=model+"_RCE_large300_2D_"+varname+".nc"
file_testmodel=path_cheyenne+"swift.dkrz.de/"+model+"/"+filen_test
fin=addfile(file_testmodel,"r")
if (omega .lt. 1) then
  wvar_b=fin->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_b=fin->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_b=fin->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

filen_test=model+"_RCE_large305_2D_"+varname+".nc"
file_testmodel=path_cheyenne+"swift.dkrz.de/"+model+"/"+filen_test
fin=addfile(file_testmodel,"r")
if (omega .lt. 1) then
  wvar_c=fin->wap500(startime:endtime,:,:)
else if (omega .lt. 2) then
  wvar_c=fin->wa500(startime:endtime,:,:)
else if (omega .lt. 3) then
  wvar_c=fin->vertical_velocity_500hpa(startime:endtime,:,:)
end if 
end if 
end if

; convert units to hPa/d?  
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is ? 

;scalef=864.
wvar_a=scalef*wvar_a
wvar_b=scalef*wvar_b
wvar_c=scalef*wvar_c

ntim=fin->time

; look at 5 day chunks
ndays=5
if (isvar("datafreq")) then
  freq=datafreq  ;[time per day] for most models this is 1 hr or 24 times per day, for IPSL it is 1 day
  print("data freq read, freq is: "+freq)
else
  freq=24
  print("data freq not detected, freq is: "+freq)
end if

timewindow=ndays*freq
;hourchunks=ndays*24
; n5d=ntim/hourchunks

;numperiods=timelength/timewindow
numperiods=timelength/timewindow
print("numperiods ="+numperiods)

; nlat and nlon will be model dependent
; should i write a script that interpolates everything to a common grid 
; before calling this script?

print("nlat is: "+nlat)
print("dimsizes of wvar_a are: "+dimsizes(wvar_a))
print("numperiods is: "+numperiods)
print("timewindow is: "+timewindow)

a_reshape=new((/timewindow,numperiods,nlat,nlon/),float)
b_reshape=new((/timewindow,numperiods,nlat,nlon/),float)
c_reshape=new((/timewindow,numperiods,nlat,nlon/),float)

a_reshape=reshape(wvar_a,(/timewindow,numperiods,nlat,nlon/))
b_reshape=reshape(wvar_b,(/timewindow,numperiods,nlat,nlon/))
c_reshape=reshape(wvar_c,(/timewindow,numperiods,nlat,nlon/))

; this should be the time average
a_reshape_5dmn=dim_avg_n(a_reshape,0)
b_reshape_5dmn=dim_avg_n(b_reshape,0)
c_reshape_5dmn=dim_avg_n(c_reshape,0)

; sort into rising and sinking arrays...
omega_u_a=where((a_reshape_5dmn .le. 0),a_reshape_5dmn,a_reshape_5dmn@_FillValue)
omega_u_b=where((b_reshape_5dmn .le. 0),b_reshape_5dmn,b_reshape_5dmn@_FillValue)
omega_u_c=where((c_reshape_5dmn .le. 0),c_reshape_5dmn,c_reshape_5dmn@_FillValue)

omega_d_a=where((a_reshape_5dmn .ge. 0),a_reshape_5dmn,a_reshape_5dmn@_FillValue)
omega_d_b=where((b_reshape_5dmn .ge. 0),b_reshape_5dmn,b_reshape_5dmn@_FillValue)
omega_d_c=where((c_reshape_5dmn .ge. 0),c_reshape_5dmn,c_reshape_5dmn@_FillValue)

print("dimsizes of omega_u_a are: "+dimsizes(omega_u_a))
print("dimsizes of omega_d_a are: "+dimsizes(omega_d_a))

omega_full_up   =new((/3,numperiods,nlat,nlon/),float)
omega_full_down =new((/3,numperiods,nlat,nlon/),float)
omega_up    =new((/3/),float)
omega_dn    =new((/3/),float)

omega_full_up(0,:,:,:)=omega_u_a
omega_full_up(1,:,:,:)=omega_u_b
omega_full_up(2,:,:,:)=omega_u_c
omega_full_down(0,:,:,:)=omega_d_a
omega_full_down(1,:,:,:)=omega_d_b
omega_full_down(2,:,:,:)=omega_d_c

do i=0,2
  omega_u=omega_full_up(i,:,:,:)
  av_a=dim_avg_n(omega_u,0)
  av_b=dim_avg_n(av_a,0)
  omega_up(i)=dim_avg_n(av_b,0)
  omega_d=omega_full_down(i,:,:,:)
  av_a=dim_avg_n(omega_d,0)
  av_b=dim_avg_n(av_a,0)
  omega_dn(i)=dim_avg_n(av_b,0)
end do

down_min_up=omega_dn-omega_up
down_plu_up=omega_dn+omega_up

print("!@#$%@%^@#%$")
print("omega up: "+omega_up)
print("omega down: "+omega_dn)
print("!@#$%@%^@#%$")
print("omega down for 300K: "+omega_dn(1))
print("Circulation Strength: omega down minus omega up")
print(down_min_up)
print("Circulation Strength: omega down plus omega up")
print(down_plu_up)
print("!@#$%@%^@#%$")


end

