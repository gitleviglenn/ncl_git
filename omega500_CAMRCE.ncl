;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_CAMRCE.ncl
;
; analyze characteristics of the circulation using omega at 500 hPa
;
; data is from CAM5 GCM RCE experiments and is at hourly frequency over 3 years
; dimensions of omega:	[time | 26281] x [lat | 192] x [lon | 288]
;
; levi silvers                                                           may 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

file_omega_5_295="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large295_2D_wap500.nc"
file_omega_6_295="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large295_2D_wap500.nc"
file_omega_5_300="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large300_2D_wap500.nc"
file_omega_6_300="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large300_2D_wap500.nc"
file_omega_5_305="/Users/silvers/data/CAM/CAM5_GCM_RCE/CAM5_GCM_RCE_large305_2D_wap500.nc"
file_omega_6_305="/Users/silvers/data/CAM/CAM6_GCM_RCE/CAM6_GCM_RCE_large305_2D_wap500.nc"

fc5_295=addfile(file_omega_5_295,"r")
c5a=fc5_295->wap500
fc6_295=addfile(file_omega_5_295,"r")
c6a=fc6_295->wap500

fc5_300=addfile(file_omega_5_300,"r")
c5b=fc5_300->wap500
fc6_300=addfile(file_omega_5_300,"r")
c6b=fc6_300->wap500

fc5_305=addfile(file_omega_5_305,"r")
c5c=fc5_305->wap500
fc6_305=addfile(file_omega_5_305,"r")
c6c=fc6_305->wap500

c5a=864*c5a  ; convert to hPa/d
c6a=864*c6a  ; convert to hPa/d
c5b=864*c5b  ; convert to hPa/d
c6b=864*c6b  ; convert to hPa/d
c5c=864*c5c  ; convert to hPa/d
c6c=864*c6c  ; convert to hPa/d

print("incoming file: "+file_omega_5_305)
print("incoming file: "+file_omega_6_305)

ntim=fc5_305->time
;printVarSummary(ntim)

n5d=ntim/120

play5a=c5a(0:26279,:,:)
play6a=c6a(0:26279,:,:)
play5b=c5b(0:26279,:,:)
play6b=c6b(0:26279,:,:)
play5c=c5c(0:26279,:,:)
play6c=c6c(0:26279,:,:)
;printVarSummary(plah)

c5a_reshape=new((/120,219,192,288/),float)
c5a_reshape=reshape(play5a,(/120,219,192,288/))
printVarSummary(c5a_reshape)

c6a_reshape=new((/120,219,192,288/),float)
c6a_reshape=reshape(play6a,(/120,219,192,288/))
printVarSummary(c6a_reshape)

;plah!0     ="time"
;play&time  =c5a&time
;plah!1     ="time1"
;plah!2     ="lat"
;play&lat   =c5a&lat
;plah!3     ="lon"
;play&lon   =c5a&lon
;

c5a_5dmn=dim_avg_n(c5a_reshape,0)
c6a_5dmn=dim_avg_n(c6a_reshape,0)
printVarSummary(c5a_5dmn)

; where(cond_expr,true,false)
omega_up=where((c5a_5dmn .le. 0),c5a_5dmn,c5a_5dmn@_FillValue)
omega_dn=where((c5a_5dmn .le. 0),c5a_5dmn,c5a_5dmn@_FillValue)

omega_u_a=dim_avg_n(omega_up,0)
print("dimsizes of a are: "+dimsizes(omega_u_a))
omega_u_b=dim_avg_n(omega_u_a,0)
print("dimsizes of b are: "+dimsizes(omega_u_b))
omega_u_c=dim_avg_n(omega_u_c,0)
print("dimsizes of c are: "+dimsizes(omega_u_c))

;---------------------
; make plots
;---------------------

plot = new(2,"graphic")

pdf_c5c=pdfx(c5a_5dmn,0,False)   
pdf_c5c_morebins=pdfx(c5a_5dmn,100,False)   

pdf_c6c=pdfx(c6a_5dmn,0,False)   
pdf_c6c_morebins=pdfx(c6a_5dmn,100,False)   

;printVarSummary(pdf_c5a)

wks = gsn_open_wks("png","testplot")

res                    = True
res@gsnDraw            = False
res@gsnFrame           = False
res@xyLineThicknessF   = 4
res@tiYAxisString      = "PDF (%)"

res@gsnCenterString    = "default bins"
res@xyLineColors = "black"
plot0_a    =  gsn_csm_xy (wks,pdf_c5c@bin_center, pdf_c5c, res)
res@xyLineColors = "green"
plot0_b    =  gsn_csm_xy (wks,pdf_c6c@bin_center, pdf_c6c, res)
overlay(plot0_a,plot0_b)
plot(0)=plot0_a
res@gsnCenterString    = "100 bins"
res@xyLineColors = "black"
plot1_a    =  gsn_csm_xy (wks,pdf_c5c_morebins@bin_center, pdf_c5c_morebins, res)
res@xyLineColors = "green"
plot1_b    =  gsn_csm_xy (wks,pdf_c6c_morebins@bin_center, pdf_c6c_morebins, res)
overlay(plot1_a,plot1_b)
plot(1)=plot1_a

resP    = True
resP@gsnPanelMainString  = "testing distractions"
gsn_panel(wks,plot,(/1,2/),resP)

end
