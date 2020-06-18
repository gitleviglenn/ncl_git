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

path_laptop="/Users/silvers/data/CAM/"
path_C5_lt="CAM5_GCM_RCE/"
path_C6_lt="CAM6_GCM_RCE/"

path_cheyenne="/glade/scratch/levi/RCEMIP/"
path_C5="CAM5_GCM/";RCE_large305/2D/"
path_C6="CAM6_GCM/";RCE_large305/2D/"

;file_omega_5_295="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large295_2D_wap500.nc"
;file_omega_6_295="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large295_2D_wap500.nc"
;file_omega_5_300="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large300_2D_wap500.nc"
;file_omega_6_300="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large300_2D_wap500.nc"
;file_omega_5_305="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large305_2D_wap500.nc"
;file_omega_6_305="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large305_2D_wap500.nc"

file_omega_5_295=path_cheyenne+path_C5+"RCE_large295/2D/CAM5_GCM_RCE_large295_2D_wap500.nc"
file_omega_5_300=path_cheyenne+path_C5+"RCE_large300/2D/CAM5_GCM_RCE_large300_2D_wap500.nc"
file_omega_5_305=path_cheyenne+path_C5+"RCE_large305/2D/CAM5_GCM_RCE_large305_2D_wap500.nc"

print("begin adding files...")
;timelength=24479 ; all but the first 75 days
;timelength=2880 ; 4 months
timelength=8760 ; 1 year 
;timelength=17520 ; 2 years
endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
;echam has 26280
;endtime=26279 ; this is the end time for CAM5 and CAM6
startime=endtime-timelength+1

; below are files from CAM5 and CAM6
fc5_295=addfile(file_omega_5_295,"r")
c5a=fc5_295->wap500(startime:endtime,:,:)

fc5_300=addfile(file_omega_5_300,"r")
c5b=fc5_300->wap500(startime:endtime,:,:)
;
fc5_305=addfile(file_omega_5_305,"r")
c5c=fc5_305->wap500(startime:endtime,:,:)

print("convert to hPa/d")

c5a=864*c5a  ; convert to hPa/d
c5b=864*c5b  ; convert to hPa/d
c5c=864*c5c  ; convert to hPa/d

print("incoming file: "+file_omega_5_295)
;print("incoming file: "+file_omega_6_295)

ntim=fc5_295->time

; look at 5 day chunks (for files that have hourly output)
n5d=ntim/120

print("begin to reshape arrays")

numperiods=timelength/120
print("numperiods ="+numperiods)

c5a_reshape=new((/120,numperiods,192,288/),float)
c5b_reshape=new((/120,numperiods,192,288/),float)
c5c_reshape=new((/120,numperiods,192,288/),float)

c5a_reshape=reshape(c5a,(/120,numperiods,192,288/))
c5b_reshape=reshape(c5b,(/120,numperiods,192,288/))
c5c_reshape=reshape(c5c,(/120,numperiods,192,288/))

;printVarSummary(c5a_reshape)

;c6a_reshape=new((/120,6,192,288/),float)
;c6a_reshape=reshape(c6a,(/120,6,192,288/))
;printVarSummary(c6a_reshape)

print("average arrays")

c5a_5dmn=dim_avg_n(c5a_reshape,0)
c5b_5dmn=dim_avg_n(c5b_reshape,0)
c5c_5dmn=dim_avg_n(c5c_reshape,0)

print("compute omega up and omega dn")

; where(cond_expr,true,false)
omega_u_5a=where((c5a_5dmn .le. 0),c5a_5dmn,c5a_5dmn@_FillValue)
omega_d_5a=where((c5a_5dmn .ge. 0),c5a_5dmn,c5a_5dmn@_FillValue)
omega_u_5b=where((c5b_5dmn .le. 0),c5b_5dmn,c5b_5dmn@_FillValue)
omega_d_5b=where((c5b_5dmn .ge. 0),c5b_5dmn,c5b_5dmn@_FillValue)
omega_u_5c=where((c5c_5dmn .le. 0),c5c_5dmn,c5c_5dmn@_FillValue)
omega_d_5c=where((c5c_5dmn .ge. 0),c5c_5dmn,c5c_5dmn@_FillValue)

;omega_u_a=dim_avg_n(omega_up,0)
;;print("dimsizes of a are: "+dimsizes(omega_u_a))
;omega_u_b=dim_avg_n(omega_u_a,0)
;;print("dimsizes of b are: "+dimsizes(omega_u_b))
;omega_u_c=dim_avg_n(omega_u_b,0)
;;print("dimsizes of c are: "+dimsizes(omega_u_c))
;print("mean omega up for CAM5 295 is: "+omega_u_c)
;omega_u_c5_295=omega_u_c

;omega_d_a=dim_avg_n(omega_dn,0)
;omega_d_b=dim_avg_n(omega_d_a,0)
;omega_d_c=dim_avg_n(omega_d_b,0)
;print("mean omega down for CAM5 295 is: "+omega_d_c)

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

pdf_a=pdfx(c5a_5dmn,50,False)
pdf_b=pdfx(c5b_5dmn,50,False)
pdf_c=pdfx(c5c_5dmn,50,False)
;pdf_c5a_morebins=pdfx(c5a_5dmn,50,False)
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
