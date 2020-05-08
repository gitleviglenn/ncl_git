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

print("begin adding files...")
;timelength=720
timelength=17280
endtime=26279
startime=endtime-timelength+1

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

n5d=ntim/120

;play5a=c5a(0:26279,:,:)
;play6a=c6a(0:26279,:,:)
;;play5b=c5b(0:26279,:,:)
;;play6b=c6b(0:26279,:,:)
;;play5c=c5c(0:26279,:,:)
;;play6c=c6c(0:26279,:,:)
;;printVarSummary(plah)

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

print("!@#$%@%^@#%$")
print("omega up: "+omega_u)
print("omega down: "+omega_d)
print("!@#$%@%^@#%$")
print("omega down for CAM5 300: "+omega_d(1))
print("Circulation Strenght: omega down minus omega up")
print(down_min_up)
print("!@#$%@%^@#%$")

;;---------------------
;; make plots
;;---------------------
;print("begin to make plots")
;
;plot = new(2,"graphic")
;
;pdf_c5a=pdfx(c5a_5dmn,0,False)   
;pdf_c5a_morebins=pdfx(c5a_5dmn,100,False)   
;
;pdf_c6a=pdfx(c6a_5dmn,0,False)   
;pdf_c6a_morebins=pdfx(c6a_5dmn,100,False)   
;
;;printVarSummary(pdf_c5a)
;
;wks = gsn_open_wks("png","testplot")
;
;res                    = True
;res@gsnDraw            = False
;res@gsnFrame           = False
;res@xyLineThicknessF   = 4
;res@tiYAxisString      = "PDF (%)"
;
;res@gsnCenterString    = "default bins"
;res@xyLineColors = "black"
;plot0_a    =  gsn_csm_xy (wks,pdf_c5a@bin_center, pdf_c5a, res)
;res@xyLineColors = "green"
;plot0_b    =  gsn_csm_xy (wks,pdf_c6a@bin_center, pdf_c6a, res)
;overlay(plot0_a,plot0_b)
;plot(0)=plot0_a
;res@gsnCenterString    = "100 bins"
;res@xyLineColors = "black"
;plot1_a    =  gsn_csm_xy (wks,pdf_c5a_morebins@bin_center, pdf_c5a_morebins, res)
;res@xyLineColors = "green"
;plot1_b    =  gsn_csm_xy (wks,pdf_c6a_morebins@bin_center, pdf_c6a_morebins, res)
;overlay(plot1_a,plot1_b)
;plot(1)=plot1_a
;
;resP    = True
;resP@gsnPanelMainString  = "testing distractions"
;gsn_panel(wks,plot,(/1,2/),resP)

end
