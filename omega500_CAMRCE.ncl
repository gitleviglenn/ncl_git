;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_CAMRCE.ncl
;
; analyze characteristics of the circulation using omega at 500 hPa
;
; data is from CAM5 GCM RCE experiments and is at hourly frequency over 3 years
; dimensions of omega:	[time | 26281] x [lat | 192] x [lon | 288]
;
; timing: 
; 1 year:         8760 time steps
; 1 30 day month: 720 time steps
; 75 days:        1800 time steps
;
; levi silvers                                                           may 2020
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
file_omega_6_295=path_cheyenne+path_C6+"RCE_large295/2D/CAM6_GCM_RCE_large295_2D_wap500.nc"
file_omega_5_300=path_cheyenne+path_C5+"RCE_large300/2D/CAM5_GCM_RCE_large300_2D_wap500.nc"
file_omega_6_300=path_cheyenne+path_C6+"RCE_large300/2D/CAM6_GCM_RCE_large300_2D_wap500.nc"
file_omega_5_305=path_cheyenne+path_C5+"RCE_large305/2D/CAM5_GCM_RCE_large305_2D_wap500.nc"
file_omega_6_305=path_cheyenne+path_C6+"RCE_large305/2D/CAM6_GCM_RCE_large305_2D_wap500.nc"

print("begin adding files...")
;timelength=24479 ; all but the first 75 days
;timelength=2880 ; 4 months
timelength=8760 ; 1 year 
;timelength=17520 ; 2 years
endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
;echam has 26280
;endtime=26279 ; this is the end time for CAM5 and CAM6
startime=endtime-timelength+1

;; ICON
;filen_test="ICON_GCM-RCE_large_295-2D.wa500.nc"
;file_testmodel=path_cheyenne+"swift.dkrz.de/"+"ICON_GCM/"+filen_test
;;/glade/scratch/levi/RCEMIP/swift.dkrz.de/ICON_GCM/
;print("icon file: "+file_testmodel)
;ficon_295=addfile(file_testmodel,"r")
;ficona=ficon_295->wa500(startime:endtime,:,:,:)
;printVarSummary(ficona)

;;# ECHAM
;filen_test="ECHAM6_GCM-RCE_large_295-2D.wap500.nc"
;file_echam_a=path_cheyenne+"swift.dkrz.de/"+"ECHAM6_GCM/"+filen_test
;print("icon file: "+file_echam_a)
;f_add=addfile(file_echam_a,"r")
;fechama=f_add->wap500(startime:endtime,:,:,:)
;filen_test="ECHAM6_GCM-RCE_large_300-2D.wap500.nc"
;file_echam_b=path_cheyenne+"swift.dkrz.de/"+"ECHAM6_GCM/"+filen_test
;f_add=addfile(file_echam_b,"r")
;fechamb=f_add->wap500(startime:endtime,:,:,:)
;filen_test="ECHAM6_GCM-RCE_large_305-2D.wap500.nc"
;file_echam_c=path_cheyenne+"swift.dkrz.de/"+"ECHAM6_GCM/"+filen_test
;f_add=addfile(file_echam_c,"r")
;fechamc=f_add->wap500(startime:endtime,:,:,:)
;
;printVarSummary(fechama)
;
;; SP-CAM
;filen_test="SP-CAM_RCE_large295_2D_wap500.nc"
;file_spcam_a=path_cheyenne+"swift.dkrz.de/"+"SPCAM/"+filen_test
;f_add=addfile(file_spcam_a,"r")
;fspcama=f_add->wap500(startime:endtime,:,:)
;
;filen_test="SP-CAM_RCE_large300_2D_wap500.nc"
;file_spcam_b=path_cheyenne+"swift.dkrz.de/"+"SPCAM/"+filen_test
;f_add=addfile(file_spcam_b,"r")
;fspcamb=f_add->wap500(startime:endtime,:,:)
;
;filen_test="SP-CAM_RCE_large305_2D_wap500.nc"
;file_spcam_c=path_cheyenne+"swift.dkrz.de/"+"SPCAM/"+filen_test
;f_add=addfile(file_spcam_c,"r")
;fspcamc=f_add->wap500(startime:endtime,:,:)
;print("SP-CAM file: "+file_spcam_c)
;
;printVarSummary(fspcamc)

;filen_test="SP-CAM_RCE_large300_2D_wap500.nc"
;;file_spcam_b=path_cheyenne+"swift.dkrz.de/"+"SPCAM/"+filen_test
;filen_test="SP-CAM_RCE_large305_2D_wap500.nc"
;file_spcam_c=path_cheyenne+"swift.dkrz.de/"+"SPCAM/"+filen_test

; below are files from CAM5 and CAM6
fc5_295=addfile(file_omega_5_295,"r")
c5a=fc5_295->wap500(startime:endtime,:,:)
fc6_295=addfile(file_omega_6_295,"r")
c6a=fc6_295->wap500(startime:endtime,:,:)

fc5_300=addfile(file_omega_5_300,"r")
c5b=fc5_300->wap500(startime:endtime,:,:)
fc6_300=addfile(file_omega_6_300,"r")
c6b=fc6_300->wap500(startime:endtime,:,:)
;
fc5_305=addfile(file_omega_5_305,"r")
c5c=fc5_305->wap500(startime:endtime,:,:)
fc6_305=addfile(file_omega_6_305,"r")
c6c=fc6_305->wap500(startime:endtime,:,:)

print("convert to hPa/d")

c5a=864*c5a  ; convert to hPa/d
c6a=864*c6a  ; convert to hPa/d
c5b=864*c5b  ; convert to hPa/d
c6b=864*c6b  ; convert to hPa/d
c5c=864*c5c  ; convert to hPa/d
c6c=864*c6c  ; convert to hPa/d

print("incoming file: "+file_omega_5_295)
print("incoming file: "+file_omega_6_295)

;printVarSummary(c5a)
;printVarSummary(c6a)

ntim=fc5_295->time
;printVarSummary(ntim)

; look at 5 day chunks (for files that have hourly output)
n5d=ntim/120

print("begin to reshape arrays")

numperiods=timelength/120
print("numperiods ="+numperiods)

;c5a_reshape=new((/120,219,192,288/),float)
;c5a_reshape=reshape(play5a,(/120,219,192,288/))
c5a_reshape=new((/120,numperiods,192,288/),float)
c5b_reshape=new((/120,numperiods,192,288/),float)
c5c_reshape=new((/120,numperiods,192,288/),float)
c6c_reshape=new((/120,numperiods,192,288/),float)
c6b_reshape=new((/120,numperiods,192,288/),float)
c6a_reshape=new((/120,numperiods,192,288/),float)

c5a_reshape=reshape(c5a,(/120,numperiods,192,288/))
c5b_reshape=reshape(c5b,(/120,numperiods,192,288/))
c5c_reshape=reshape(c5c,(/120,numperiods,192,288/))
c6a_reshape=reshape(c6a,(/120,numperiods,192,288/))
c6b_reshape=reshape(c6b,(/120,numperiods,192,288/))
c6c_reshape=reshape(c6c,(/120,numperiods,192,288/))

;printVarSummary(c5a_reshape)

;c6a_reshape=new((/120,6,192,288/),float)
;c6a_reshape=reshape(c6a,(/120,6,192,288/))
;printVarSummary(c6a_reshape)

;plah!0     ="time"
;play&time  =c5a&time
;plah!1     ="time1"
;plah!2     ="lat"
;play&lat   =c5a&lat
;plah!3     ="lon"
;play&lon   =c5a&lon
;

print("average arrays")

;???LINES MISSING
c5a_5dmn=dim_avg_n(c5a_reshape,0)
c5b_5dmn=dim_avg_n(c5b_reshape,0)
c5c_5dmn=dim_avg_n(c5c_reshape,0)
c6a_5dmn=dim_avg_n(c6a_reshape,0)
c6b_5dmn=dim_avg_n(c6b_reshape,0)
c6c_5dmn=dim_avg_n(c6c_reshape,0)
;printVarSummary(c5a_5dmn)

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

omega_u_6a=where((c6a_5dmn .le. 0),c6a_5dmn,c6a_5dmn@_FillValue)
omega_d_6a=where((c6a_5dmn .ge. 0),c6a_5dmn,c6a_5dmn@_FillValue)
omega_u_6b=where((c6b_5dmn .le. 0),c6b_5dmn,c6b_5dmn@_FillValue)
omega_d_6b=where((c6b_5dmn .ge. 0),c6b_5dmn,c6b_5dmn@_FillValue)
omega_u_6c=where((c6c_5dmn .le. 0),c6c_5dmn,c6c_5dmn@_FillValue)
omega_d_6c=where((c6c_5dmn .ge. 0),c6c_5dmn,c6c_5dmn@_FillValue)

;omega_u_6_a=dim_avg_n(omega_6_up,0)
;omega_u_6_b=dim_avg_n(omega_u_6_a,0)
;omega_u_6_c=dim_avg_n(omega_u_6_b,0)
;print("mean omega up for CAM6 295 is: "+omega_u_6_c)
;
;omega_d_6_a=dim_avg_n(omega_6_dn,0)
;omega_d_6_b=dim_avg_n(omega_d_6_a,0)
;omega_d_6_c=dim_avg_n(omega_d_6_b,0)
;print("mean omega down for CAM6 295 is: "+omega_d_6_c)

omega_up   =new((/6,numperiods,192,288/),float)
omega_down =new((/6,numperiods,192,288/),float)
omega_u    =new((/6/),float)
omega_d    =new((/6/),float)


omega_up(0,:,:,:)=omega_u_5a
omega_up(1,:,:,:)=omega_u_5b
omega_up(2,:,:,:)=omega_u_5c
omega_up(3,:,:,:)=omega_u_6a
omega_up(4,:,:,:)=omega_u_6b
omega_up(5,:,:,:)=omega_u_6c

omega_down(0,:,:,:)=omega_d_5a
omega_down(1,:,:,:)=omega_d_5b
omega_down(2,:,:,:)=omega_d_5c
omega_down(3,:,:,:)=omega_d_6a
omega_down(4,:,:,:)=omega_d_6b
omega_down(5,:,:,:)=omega_d_6c

blue=omega_down(1,:,:,:)

;print("dimsizes of omega_down are: "+dimsizes(omega_down))
;print("dimsizes of blue are: "+dimsizes(blue))

do i=0,5
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

pdf_c5a=pdfx(c5a_5dmn,50,False)
pdf_c5b=pdfx(c5b_5dmn,50,False)
pdf_c5c=pdfx(c5c_5dmn,50,False)
pdf_c5a_morebins=pdfx(c5a_5dmn,50,False)
;
pdf_c6a=pdfx(c6a_5dmn,50,False)
pdf_c6b=pdfx(c6b_5dmn,50,False)
pdf_c6c=pdfx(c6c_5dmn,50,False)
pdf_c6a_morebins=pdfx(c6a_5dmn,50,False)
;
; colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3","red"/)
  ;colors = (/"black","orangered","orangered3","orangered4"/)
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
res@trXMaxF = 75.0
res@trYMinF = 0.0
res@trYMaxF = 20.0

res@tmXTOn              = False
res@tmXTBorderOn        = False
res@tmYROn              = False
res@tmYRBorderOn        = False
res@vpWidthF            = 0.9
res@vpHeightF           = 0.5
;res@vpXF                = .9
;res@vpYF                =.45
;res@gsnCenterString    = "default bins"
res@xyLineColors = colors(0)
res@xyDashPattern =  0
res@xyLineThicknessF = 2.
plot0_a    =  gsn_csm_xy (wks,pdf_c5a@bin_center, pdf_c5a, res)
res@xyLineColors = colors(0)
;res@xyDashPattern =  3
res@xyLineThicknessF = 4.
plot0_b    =  gsn_csm_xy (wks,pdf_c5b@bin_center, pdf_c5b, res)
res@xyLineColors = colors(0)
;res@xyDashPattern =  16
res@xyLineThicknessF = 6.
plot0_c    =  gsn_csm_xy (wks,pdf_c5c@bin_center, pdf_c5c, res)
res@xyLineColors = colors(1)
;res@xyDashPattern = 0 
res@xyLineThicknessF = 2.
plot0_d    =  gsn_csm_xy (wks,pdf_c6a@bin_center, pdf_c6a, res)
res@xyLineColors = colors(1)
;res@xyDashPattern = 3 
res@xyLineThicknessF = 4.
plot0_e    =  gsn_csm_xy (wks,pdf_c6b@bin_center, pdf_c6b, res)
res@xyLineColors = colors(1)
;res@xyDashPattern =  16
res@xyLineThicknessF = 6.
plot0_f    =  gsn_csm_xy (wks,pdf_c6c@bin_center, pdf_c6c, res)
overlay(plot0_a,plot0_b)
overlay(plot0_a,plot0_c)
overlay(plot0_a,plot0_d)
overlay(plot0_a,plot0_e)
overlay(plot0_a,plot0_f)
plot(0)=plot0_a

;res@gsnCenterString    = "50 bins"
;res@xyLineColors = "black"
;plot1_a    =  gsn_csm_xy (wks,pdf_c5a_morebins@bin_center, pdf_c5a_morebins, res)
;res@xyLineColors = "green"
;plot1_b    =  gsn_csm_xy (wks,pdf_c6a_morebins@bin_center, pdf_c6a_morebins, res)
;overlay(plot1_a,plot1_b)
;plot(1)=plot1_a
;
resP    = True
resP@gsnPanelMainString  = "Circulation Regime over last year"
gsn_panel(wks,plot,(/1,1/),resP)

end
