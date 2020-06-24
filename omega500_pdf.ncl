;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_pdf.ncl
;
; analyze characteristics of the circulation using omega at 500 hPa
;
; develop to be used with multiple models
;
; for CAM5
; dimensions of omega:	[time | 26281] x [lat | 192] x [lon | 288]
;
; timing: 
; 1 year:         8760 time steps
; 1 30 day month: 720 time steps
; 75 days:        1800 time steps
;
; levi silvers                                                           june 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;-----------------
; time parameters
; initially look at 5 day chunks
ndays=10
if (isvar("datafreq")) then
  freq=datafreq  ;[time per day] for most models this is 1 hr or 24 times per day, for IPSL it is 1 day
  print("data freq read, freq is: "+freq)
else
  freq=24
  print("data freq not detected, freq is: "+freq)
end if

timewindow=ndays*freq

timelength=8760-timewindow ; 1 year has 8760 hours
;startime=endtime-timelength+1

;timewindow=ndays*freq
;hourchunks=ndays*24
; n5d=ntim/hourchunks

numperiods=timelength/timewindow
;print("numperiods ="+numperiods)

print("ndays is: "+ndays)
print("numperiods is: "+numperiods)
print("timewindow of each period (ndays*freq) is: "+timewindow)

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
;-----------------


; path bases
path_laptop="/Users/silvers/data/CAM/"
path_cheyenne="/glade/scratch/levi/RCEMIP/"

path_cheyenne="/glade/scratch/levi/RCEMIP/"
path_C5="CAM5_GCM/";RCE_large305/2D/"

print("begin adding files...")

timelength=8760 ; 1 year 
endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
startime=endtime-timelength+1

if (isvar("CAMGCM")) then

  whichCAM=CAMGCM
  file_omega_5_295=path_cheyenne+path_C5+"RCE_large295/2D/CAM5_GCM_RCE_large295_2D_wap500.nc"
  file_omega_5_300=path_cheyenne+path_C5+"RCE_large300/2D/CAM5_GCM_RCE_large300_2D_wap500.nc"
  file_omega_5_305=path_cheyenne+path_C5+"RCE_large305/2D/CAM5_GCM_RCE_large305_2D_wap500.nc"
  
  print("incoming file should be CAM: "+file_omega_5_295)

  fc5_295=addfile(file_omega_5_295,"r")
  wvar_a=fc5_295->wap500(startime:endtime,:,:)
  
  fc5_300=addfile(file_omega_5_300,"r")
  wvar_b=fc5_300->wap500(startime:endtime,:,:)
  
  fc5_305=addfile(file_omega_5_305,"r")
  wvar_c=fc5_305->wap500(startime:endtime,:,:)

  print("incoming file should be CAM: "+file_omega_5_295)
else
  
  ; for SST = 295K
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
  
  ; for SST = 300K
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
  
  ; for SST = 305K
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

end if

print("convert to hPa/d")

; convert units to hPa/d?  
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is 6042 ?!! 

wvar_a=scalef*wvar_a
wvar_b=scalef*wvar_b
wvar_c=scalef*wvar_c
;;;;


;ntim=fc5_295->time

; look at 5 day chunks (for files that have hourly output)
;n5d=ntim/120

;print("begin to reshape arrays")
;numperiods=timelength/120
;print("numperiods ="+numperiods)

a_reshape=new((/120,numperiods,192,288/),float)
b_reshape=new((/120,numperiods,192,288/),float)
c_reshape=new((/120,numperiods,192,288/),float)

a_reshape=reshape(wvar_a,(/120,numperiods,192,288/))
b_reshape=reshape(wvar_b,(/120,numperiods,192,288/))
c_reshape=reshape(wvar_c,(/120,numperiods,192,288/))

print("average arrays")

a_reshape_tmn=dim_avg_n(a_reshape,0)
b_reshape_tmn=dim_avg_n(b_reshape,0)
c_reshape_tmn=dim_avg_n(c_reshape,0)

print("compute omega up and omega dn")

; where(cond_expr,true,false)
omega_u_5a=where((a_reshape_tmn .le. 0),a_reshape_tmn,a_reshape_tmn@_FillValue)
omega_d_5a=where((a_reshape_tmn .ge. 0),a_reshape_tmn,a_reshape_tmn@_FillValue)
omega_u_5b=where((b_reshape_tmn .le. 0),b_reshape_tmn,b_reshape_tmn@_FillValue)
omega_d_5b=where((b_reshape_tmn .ge. 0),b_reshape_tmn,b_reshape_tmn@_FillValue)
omega_u_5c=where((c_reshape_tmn .le. 0),c_reshape_tmn,c_reshape_tmn@_FillValue)
omega_d_5c=where((c_reshape_tmn .ge. 0),c_reshape_tmn,c_reshape_tmn@_FillValue)

omega_up   =new((/3,numperiods,192,288/),float)
omega_down =new((/3,numperiods,192,288/),float)
omega_u    =new((/3/),float)
omega_d    =new((/3/),float)

omega_up(0,:,:,:)=omega_u_5a
omega_up(1,:,:,:)=omega_u_5b
omega_up(2,:,:,:)=omega_u_5c

omega_down(0,:,:,:)=omega_d_5a
omega_down(1,:,:,:)=omega_d_5b
omega_down(2,:,:,:)=omega_d_5c

blue=omega_down(1,:,:,:)

;print("dimsizes of omega_down are: "+dimsizes(omega_down))
;print("dimsizes of blue are: "+dimsizes(blue))

do i=0,2
  omega_dn= omega_down(i,:,:,:)
  av_a=dim_avg_n(omega_dn,0)
  av_b=dim_avg_n(av_a,0)
  omega_d(i)=dim_avg_n(av_b,0)
  omega_uu= omega_up(i,:,:,:)
  av_a=dim_avg_n(omega_uu,0)
  av_b=dim_avg_n(av_a,0)
  omega_u(i)=dim_avg_n(av_b,0)
end do

down_min_up=omega_d-omega_u
down_plu_up=omega_d+omega_u

print("!@#$%@%^@#%$")
print("omega up: "+omega_u)
print("omega down: "+omega_d)
print("!@#$%@%^@#%$")
print("omega down for CAM5 300: "+omega_d(1))
print("Circulation Strength: omega down minus omega up")
print(down_min_up)
print("Circulation Strength: omega down plus omega up")
print(down_plu_up)
print("!@#$%@%^@#%$")

;;---------------------
;; make plots
;;---------------------
print("begin to make plots")

plot = new(1,"graphic")

pdf_a=pdfx(a_reshape_tmn,50,False)
pdf_b=pdfx(b_reshape_tmn,50,False)
pdf_c=pdfx(c_reshape_tmn,50,False)
;
  colors = (/"chocolate2","aquamarine3"/)

;
wks = gsn_open_wks("eps","testplot")

res                    = True
res@gsnDraw            = False
res@gsnFrame           = False
res@xyLineThicknessF   = 5.
res@tiYAxisString      = "PDF (%)"
res@tiXAxisString      = "circulation regime (hPa/d)"

res@trXMinF = -150.0
res@trXMaxF = 50.0
res@trYMinF = 0.0
res@trYMaxF = 20.0

printVarSummary(pdf_a)
print("pdf_a values are: "+pdf_a)
print("sum of pdf_a? is: "+sum(pdf_a))
print("sum of pdf_a bin_center values is: "+sum(pdf_a@bin_center))
print("sum of pdf_b? is: "+sum(pdf_b))
print("sum of pdf_b? is: "+sum(pdf_c))

;pdf_array=pdf_a

;res@gsnCenterString    = "default bins"
res@xyLineColors = colors(0)
res@xyDashPattern =  0
res@xyLineThicknessF = 2.
plot0_a    =  gsn_csm_xy (wks,pdf_a@bin_center, pdf_a, res)
res@xyLineColors = colors(0)
;res@xyDashPattern =  3
res@xyLineThicknessF = 4.
plot0_b    =  gsn_csm_xy (wks,pdf_b@bin_center, pdf_b, res)
res@xyLineColors = colors(0)
;res@xyDashPattern =  16
res@xyLineThicknessF = 6.
plot0_c    =  gsn_csm_xy (wks,pdf_c@bin_center, pdf_c, res)
overlay(plot0_a,plot0_b)
overlay(plot0_a,plot0_c)
plot(0)=plot0_a

;
resP    = True
resP@gsnPanelMainString  = "Circulation Regime over last year"
gsn_panel(wks,plot,(/1,1/),resP)

end
