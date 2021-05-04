;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; stab_omegaD_readascii.ncl
;
; read in ascii files from the driver script on casper
; 
; this script should read in data and produce a profile plot 
; named:  "testplot_lapse_c5c6.eps"
;
; this script creates a 2 panel plot showing profiles of RH and the static stability parameter
;
; calculates the height at which radiative cooling equals zero and the height at
; which the difference between the lapse rate and adiabatic lapse rate differ by
; more than a threshold value (gthresh).
;
; levi silvers                                                        mar 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  print("[[[[[[[[[[[[[[[[ within stab_omegaD_readascii.ncl ]]]]]]]]]]]]]]]]")

arr_1a=readAsciiTable("profiles_CAM5_295_mn.txt",8,"float",1)
arr_1b=readAsciiTable("profiles_CAM5_300_mn.txt",8,"float",1)
arr_1c=readAsciiTable("profiles_CAM5_305_mn.txt",8,"float",1)

printVarSummary(arr_1a)
print("arr_1a values are: "+arr_1a(0:29,1))

arr_2a=readAsciiTable("profiles_CAM6_295_mn.txt",8,"float",1)
arr_2b=readAsciiTable("profiles_CAM6_300_mn.txt",8,"float",1)
arr_2c=readAsciiTable("profiles_CAM6_305_mn.txt",8,"float",1)

arr_3a=readAsciiTable("profiles_ECHAM_295_mn.txt",8,"float",1)
arr_3b=readAsciiTable("profiles_ECHAM_300_mn.txt",8,"float",1)
arr_3c=readAsciiTable("profiles_ECHAM_305_mn.txt",8,"float",1)

arr_4a=readAsciiTable("profiles_SAM_295.txt",8,"float",1)
arr_4b=readAsciiTable("profiles_SAM_300.txt",8,"float",1)
arr_4c=readAsciiTable("profiles_SAM_305.txt",8,"float",1)

;print("CAM5 295: 0,1:"+arr_1a(0,1)+"  1,1:"+arr_1a(1,1)+"   2,1:"+arr_1a(2,1)+"   3,1:"+arr_1a(3,1)+"   4,1"+arr_1a(4,1))

; define levels -1 for each model
levsCAM5=29
levsCAM6=31
levsECHAM=46
levsSAM=73
vaxis1a=arr_1a(0:levsCAM5,3) ; CAM5
vaxis2a=arr_2a(0:levsCAM6,3) ; CAM6
vaxis3a=arr_3a(0:levsECHAM,3) ; ECHAM
vaxis4a=arr_4a(0:levsSAM,3) ; SAM

zero_line   =new((/levsCAM6/),float)
rh_a1       =new((/15/),float)
rh_a2       =new((/15/),float)
rh_a3       =new((/15/),float)
rh_b1       =new((/15/),float)
rh_b2       =new((/15/),float)
rh_b3       =new((/15/),float)
;zero_line=arr_1a(0:levsCAM5,0)
zero_line(0:levsCAM5)=0.

gamma_a1=arr_1a(0:levsCAM5,0)
gamma_a2=arr_1b(0:levsCAM5,0)
gamma_a3=arr_1c(0:levsCAM5,0)
gamma_b1=arr_2a(0:levsCAM6,0)
gamma_b2=arr_2b(0:levsCAM6,0)
gamma_b3=arr_2c(0:levsCAM6,0)
gamma_c1=arr_3a(0:levsECHAM,0)
gamma_c2=arr_3b(0:levsECHAM,0)
gamma_c3=arr_3c(0:levsECHAM,0)
gamma_d1=arr_4a(0:levsSAM,0)
gamma_d2=arr_4b(0:levsSAM,0)
gamma_d3=arr_4c(0:levsSAM,0)
hur_a1=arr_1a(0:levsCAM5,2)
hur_a2=arr_1b(0:levsCAM5,2)
hur_a3=arr_1c(0:levsCAM5,2)
hur_b1=arr_2a(0:levsCAM6,2)
hur_b2=arr_2b(0:levsCAM6,2)
hur_b3=arr_2c(0:levsCAM6,2)
hur_c1=arr_3a(0:levsECHAM,2)
hur_c2=arr_3b(0:levsECHAM,2)
hur_c3=arr_3c(0:levsECHAM,2)
hur_d1=arr_4a(0:levsSAM,2)
hur_d2=arr_4b(0:levsSAM,2)
hur_d3=arr_4c(0:levsSAM,2)
rh_a1=hur_a1(15:levsCAM5)
rh_a2=hur_a2(15:levsCAM5)
rh_a3=hur_a3(15:levsCAM5)
rh_b1=hur_b1(15:levsCAM5)
rh_b2=hur_b2(15:levsCAM5)
rh_b3=hur_b3(15:levsCAM5)
;print("max and min of RH c5 at levsCAM55 are: "+ max(rh_a1)+"/"+min(rh_a1))
;print("max and min of RH c5 at levsCAM60 are: "+ max(rh_a2)+"/"+min(rh_a2))
;print("max and min of RH c5 at levsCAM65 are: "+ max(rh_a3)+"/"+min(rh_a3))
;print("max and min of RH c6 at levsCAM55 are: "+ max(rh_b1)+"/"+min(rh_b1))
;print("max and min of RH c6 at levsCAM60 are: "+ max(rh_b2)+"/"+min(rh_b2))
;print("max and min of RH c6 at levsCAM65 are: "+ max(rh_b3)+"/"+min(rh_b3))
sigma_a1=arr_1a(0:levsCAM5,1)
sigma_a2=arr_1b(0:levsCAM5,1)
sigma_a3=arr_1c(0:levsCAM5,1)
sigma_b1=arr_2a(0:levsCAM6,1)
sigma_b2=arr_2b(0:levsCAM6,1)
sigma_b3=arr_2c(0:levsCAM6,1)
sigma_c1=arr_3a(0:levsECHAM,1)
sigma_c2=arr_3b(0:levsECHAM,1)
sigma_c3=arr_3c(0:levsECHAM,1)
sigma_d1=arr_4a(0:levsSAM,1)
sigma_d2=arr_4b(0:levsSAM,1)
sigma_d3=arr_4c(0:levsSAM,1)
rscs_a1=arr_1a(0:levsCAM5,5)
rscs_a2=arr_1b(0:levsCAM5,5)
rscs_a3=arr_1c(0:levsCAM5,5)
rscs_b1=arr_2a(0:levsCAM6,5)
rscs_b2=arr_2b(0:levsCAM6,5)
rscs_b3=arr_2c(0:levsCAM6,5)
rlcs_a1=arr_1a(0:levsCAM5,6)
rlcs_a2=arr_1b(0:levsCAM5,6)
rlcs_a3=arr_1c(0:levsCAM5,6)
rlcs_b1=arr_2a(0:levsCAM6,6)
rlcs_b2=arr_2b(0:levsCAM6,6)
rlcs_b3=arr_2c(0:levsCAM6,6)
ddiv_a1=arr_1a(0:levsCAM5,7)
ddiv_a2=arr_1b(0:levsCAM5,7)
ddiv_a3=arr_1c(0:levsCAM5,7)
ddiv_b1=arr_2a(0:levsCAM6,7)
ddiv_b2=arr_2b(0:levsCAM6,7)
ddiv_b3=arr_2c(0:levsCAM6,7)

tntr_a1=rlcs_a1+rscs_a1
tntr_a2=rlcs_a2+rscs_a2
tntr_a3=rlcs_a3+rscs_a3
tntr_b1=rlcs_b1+rscs_b1
tntr_b2=rlcs_b2+rscs_b2
tntr_b3=rlcs_b3+rscs_b3

; calculate the diabatic pressure velocity
scale_hPabd = 864 ; converts Pa/s to hPa/d
omega_d_a1=scale_hPabd*tntr_a1/sigma_a1
omega_d_a2=scale_hPabd*tntr_a2/sigma_a2
omega_d_a3=scale_hPabd*tntr_a3/sigma_a3
omega_d_b1=scale_hPabd*tntr_b1/sigma_b1
omega_d_b2=scale_hPabd*tntr_b2/sigma_b2
omega_d_b3=scale_hPabd*tntr_b3/sigma_b3

; scaling factors for the plot: 
scaleR=1.
;scale       = 10000. ; convert static stability to K/100hPa
scale       = 1. ; convert static stability to K/100hPa
scale_gamm  = 1000.  ; convert gamma to K/km
scalep      = 0.01   ; convert to hPa
scalediv    = 1.


;========================================
; print out the difference between the lapse rates, the total radiative cooling.... where does it 
; change sign?
; for sst=295
firstins  = False ; first instance of gamma diff being smaller than threshold (from TOA)
firstinsr = False
gthresh=0.6
do i=5,20
;; for CAM5
  radneg=scaleR*tntr_a1(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis1a(i))
    radneg1=radneg
    radneg1p=scalep*vaxis1a(i)
    firstinsr=True
  end if
end do    ; end cam5
firstins  = False 
firstinsr = False
delete(radneg)
do i=5,20 ; cam6
  radneg=scaleR*tntr_b1(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis2a(i))
    radneg1_c6  =radneg
    radneg1p_c6 =scalep*vaxis2a(i)
    firstinsr=True
  end if
    print("minimum RH is: "+min(hur_a1)+"and RH at level z= "+i+" is: "+hur_a1(i)+" at press lev: "+scalep*vaxis2a(i))
end do ; cam6

; for sst=300
firstins  = False 
firstinsr = False
;delete(gamma_diff)
delete(radneg)
;gamma_diff=gamma_m_a2-gamma_a2
do i=5,20 ; cam5
;  print("C5 Difference between lapse rates: "+scale_gamm*gamma_diff(i)+"  Total radiative cooling:  "+scaleR*tntr_a1(i)+" at press level: "+scalep*vaxis1a(i))
; for CAM5
  radneg=scaleR*tntr_a2(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis1a(i))
    radneg2=radneg
    radneg2p=scalep*vaxis1a(i)
    firstinsr=True
  end if
end do ; end cam5
firstins  = False 
firstinsr = False
;delete(gamma_diff)
delete(radneg)
do i=5,20 ; cam6
;  print("C6 Difference between lapse rates: "+scale_gamm*gamma_diff(i)+"  Total radiative cooling:  "+scaleR*tntr_a2(i)+" at press level: "+scalep*vaxis2a(i))
  radneg=scaleR*tntr_a2(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis1a(i))
    radneg2_c6  =radneg
    radneg2p_c6 =scalep*vaxis1a(i)
    firstinsr=True
  end if
end do ; end cam6

; for sst=305
firstins  = False 
firstinsr = False
delete(radneg)
do i=5,20 ; cam5
  radneg=scaleR*tntr_b3(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis1a(i))
    radneg3=radneg
    radneg3p=scalep*vaxis1a(i)
    firstinsr=True
  end if
end do
firstins  = False 
firstinsr = False
delete(radneg)
do i=5,20 ; cam6
  radneg=scaleR*tntr_b3(i)
  if (radneg .le. 0.0 .and. .not. firstinsr) 
    print("radneg ="+radneg+" at press of="+scalep*vaxis2a(i))
    radneg3_c6=radneg
    radneg3p_c6=scalep*vaxis2a(i)
    firstinsr=True
  end if
end do

print("C5 rad net: "+radneg1+" at press of:"+radneg1p)
print("C5 rad net: "+radneg2+" at press of:"+radneg2p)
print("C5 rad net: "+radneg3+" at press of:"+radneg3p)
print("C6 rad net: "+radneg1_c6+" at press of:"+radneg1p_c6)
print("C6 rad net: "+radneg2_c6+" at press of:"+radneg2p_c6)
print("C6 rad net: "+radneg3_c6+" at press of:"+radneg3p_c6)
;========================================

;  print("values to plot are: "+scale*array01(0:29,0)+" and hur: "+hur_a1(0:29)+" and the pressure values: "+vaxis1a(0:29))
;  print("dimensions are: "+dimsizes(gamma_a1)+" and also: "+dimsizes(vaxis1a))
;  print("values of rlcs_a1 are: "+rlcs_a1(0:29)+" and rscs_a: "+hur_a1(0:29)+" and the pressure values: "+vaxis1a(0:29))

; set the upper and lower levels to plot with the y-axis: 
ytop = 10
ybot = 1000 ;450 ; often this is set to 1000.

thick1=2.
thick2=3.
thick3=4.

;============================================
wks=gsn_open_wks("eps","testplot_rh_sigma")
;gsn_define_colormap(wks,"CBR_drywet")
gsn_define_colormap(wks,"cb_9step")
plot=new(3,graphic)

  res                  = True

  res@gsnDraw          = False
  res@gsnFrame         = False

  res@xyDashPattern          = 0
  res@tiYAxisString          = "Pressure (hPa)"
  res@tiXAxisString          = "K/km"
  res@lgLabelFontHeightF     = .015                          ; label font height

  res@trYReverse             = True     ; reverse the y-axis
  res@tmXBMode     = "Explicit"
  res@tmXBLabels   = (/"","","","","8",""/)
  res@trXMaxF                =  10.0
  res@trXMinF                =  0.0
  res@trYMaxF                =  ybot
  res@trYMinF                =  ytop
  res@tmYROn            = False
  res@tmXTOn            = False
  res@tmYRBorderOn      = False
  res@tmXTBorderOn      = False
  res@tmYLLabelsOn           = True

  res@vpWidthF               = 0.35
  res@vpHeightF              = 0.7

; plot the relative humidity

  res@trXMaxF                =  100.0
  res@trXMinF                =  0.0
  res@tiXAxisString          = "%"
  res@tiMainString           = "Relative Humidity"
  res@tiMainFontHeightF      = 0.03
  res@tmXBMode     = "Automatic"
  ;res@xyLineColors = "chocolate2"
  res@xyLineColors = 67
  res@xyLineThicknessF       = thick1
  plot1a1 = gsn_csm_xy(wks,hur_a1(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick2
  plot1a2 = gsn_csm_xy(wks,hur_a2(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick3
  plot1a3 = gsn_csm_xy(wks,hur_a3(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  ;res@xyLineColors = "aquamarine3"
  res@xyLineColors = 19
  res@xyLineThicknessF       = thick1
  plot1b1 = gsn_csm_xy(wks,hur_b1(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick2 
  plot1b2 = gsn_csm_xy(wks,hur_b2(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick3
  plot1b3 = gsn_csm_xy(wks,hur_b3(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineColors = 44
  res@xyLineThicknessF       = thick1
  plot1c1 = gsn_csm_xy(wks,hur_c1(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick2 
  plot1c2 = gsn_csm_xy(wks,hur_c2(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick3
  plot1c3 = gsn_csm_xy(wks,hur_c3(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineColors = 77
  res@xyLineThicknessF       = thick1
  plot1d1 = gsn_csm_xy(wks,hur_d1(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick2 
  plot1d2 = gsn_csm_xy(wks,hur_d2(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick3
  plot1d3 = gsn_csm_xy(wks,hur_d3(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)

; plot the static stability parameter

  res@trXMaxF                =  120.0
  res@trXMinF                =  -10.0
  res@tiXAxisString          = "mK/hPa"
  res@tiMainString           = "Static Stab Par"
  ;res@xyLineColors = "chocolate2"
  res@xyLineColors = 67
  res@xyLineThicknessF       = thick1
  plot2a1 = gsn_csm_xy(wks,scale*sigma_a1(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick2 
  plot2a2 = gsn_csm_xy(wks,scale*sigma_a2(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick3 
  plot2a3 = gsn_csm_xy(wks,scale*sigma_a3(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  ;res@xyLineColors = "aquamarine3"
  res@xyLineColors = 19
  res@xyLineThicknessF       = thick1
  plot2b1 = gsn_csm_xy(wks,scale*sigma_b1(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick2 
  plot2b2 = gsn_csm_xy(wks,scale*sigma_b2(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick3
  plot2b3 = gsn_csm_xy(wks,scale*sigma_b3(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  ;res@xyLineColors = "blue"
  res@xyLineColors = 44
  res@xyLineThicknessF       = thick1
  plot2c1 = gsn_csm_xy(wks,scale*sigma_c1(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick2 
  plot2c2 = gsn_csm_xy(wks,scale*sigma_c2(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick3
  plot2c3 = gsn_csm_xy(wks,scale*sigma_c3(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  ;res@xyLineColors = "black"
  res@xyLineColors = 77
  res@xyLineThicknessF       = thick1
  plot2d1 = gsn_csm_xy(wks,scale*sigma_d1(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick2 
  plot2d2 = gsn_csm_xy(wks,scale*sigma_d2(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick3
  plot2d3 = gsn_csm_xy(wks,scale*sigma_d3(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)

; plot the lapse rate

  res@xyDashPattern          = 0
  res@tiYAxisString          = "Pressure (hPa)"
  res@tiXAxisString          = "K/km"
  res@lgLabelFontHeightF     = .015                          ; label font height

  res@trYReverse             = True     ; reverse the y-axis
  res@tmXBMode     = "Explicit"
  res@tmXBLabels   = (/"","","","","8",""/)
  res@trXMaxF                =  10.0
  res@trXMinF                =  0.0
  res@trYMaxF                =  ybot
  res@trYMinF                =  ytop
  res@tmYROn            = False
  res@tmXTOn            = False
  res@tmYRBorderOn      = False
  res@tmXTBorderOn      = False
  res@tmYLLabelsOn           = True

  res@vpWidthF               = 0.35
  res@vpHeightF              = 0.7

;  plot(0)   = gsn_csm_xy(wks,time/365.,avg_ts,res)
  ;res@xyLineColors = "chocolate2"
  res@xyLineColors = 67
  res@xyLineThicknessF       = thick1
  res@tiMainString           = "Lapse Rate"
  res@xyLineThicknessF       = thick1
  plot3a1 = gsn_csm_xy(wks,-scale_gamm*gamma_a1(0:levsCAM5),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick2
  plot3a2 = gsn_csm_xy(wks,-scale_gamm*(gamma_a2(0:levsCAM5)),scalep*vaxis1a(0:levsCAM5),res)
  res@xyLineThicknessF       = thick3
  plot3a3 = gsn_csm_xy(wks,-scale_gamm*(gamma_a3(0:levsCAM5)),scalep*vaxis1a(0:levsCAM5),res)
  ;res@xyLineColors = "aquamarine3"
  res@xyLineColors = 19
  res@xyLineThicknessF       = thick1
  plot3b1 = gsn_csm_xy(wks,-scale_gamm*gamma_b1(0:levsCAM6),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick2
  plot3b2 = gsn_csm_xy(wks,-scale_gamm*(gamma_b2(0:levsCAM6)),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineThicknessF       = thick3
  plot3b3 = gsn_csm_xy(wks,-scale_gamm*(gamma_b3(0:levsCAM6)),scalep*vaxis2a(0:levsCAM6),res)
  res@xyLineColors = 44
  res@xyLineThicknessF       = thick1
  plot3c1 = gsn_csm_xy(wks,-scale_gamm*gamma_c1(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick2
  plot3c2 = gsn_csm_xy(wks,-scale_gamm*gamma_c2(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineThicknessF       = thick3
  plot3c3 = gsn_csm_xy(wks,-scale_gamm*gamma_c3(0:levsECHAM),scalep*vaxis3a(0:levsECHAM),res)
  res@xyLineColors = 77
  res@xyLineThicknessF       = thick1
  plot3d1 = gsn_csm_xy(wks,-scale_gamm*gamma_d1(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick2
  plot3d2 = gsn_csm_xy(wks,-scale_gamm*gamma_d2(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)
  res@xyLineThicknessF       = thick3
  plot3d3 = gsn_csm_xy(wks,-scale_gamm*gamma_d3(0:levsSAM),scalep*vaxis4a(0:levsSAM),res)


;; relative humidity
;; 295
;  overlay(plot1a1,plot1b1)
;  overlay(plot1a1,plot1c1)
;  overlay(plot1a1,plot1d1)
;; 300
;  overlay(plot1a1,plot1a2)
;  overlay(plot1a1,plot1b2)
;  overlay(plot1a1,plot1c2)
;  overlay(plot1a1,plot1d2)
;; 305
;  overlay(plot1a1,plot1a3)
;  overlay(plot1a1,plot1b3)
;  overlay(plot1a1,plot1c3)
;  overlay(plot1a1,plot1d3)
;
;; static stability
;; 295
;  overlay(plot2a1,plot2b1)
;  overlay(plot2a1,plot2c1)
;  overlay(plot2a1,plot2d1)
;; 300
;  overlay(plot2a1,plot2a2)
;  overlay(plot2a1,plot2b2)
;  overlay(plot2a1,plot2c2)
;  overlay(plot2a1,plot2d2)
;; 305
;  overlay(plot2a1,plot2a3)
;  overlay(plot2a1,plot2b3)
;  overlay(plot2a1,plot2c3)
;  overlay(plot2a1,plot2d3)
;
;; lapse rate
;; 295
;  overlay(plot3a1,plot3b1)
;  overlay(plot3a1,plot3c1)
;  overlay(plot3a1,plot3d1)
;; 300
;  overlay(plot3a1,plot3a2)
;  overlay(plot3a1,plot3b2)
;  overlay(plot3a1,plot3c2)
;  overlay(plot3a1,plot3d2)
;; 305
;  overlay(plot3a1,plot3a3)
;  overlay(plot3a1,plot3b3)
;  overlay(plot3a1,plot3c3)
;  overlay(plot3a1,plot3d3)
;
;  plot(0) = plot1a1
;  plot(1) = plot2a1
;  plot(2) = plot3a1
;;; end plot everything

;; if plotting only 295
  overlay(plot1a1,plot1b1)
  overlay(plot1a1,plot1c1)
  overlay(plot1a1,plot1d1)

  overlay(plot2a1,plot2b1)
  overlay(plot2a1,plot2c1)
  overlay(plot2a1,plot2d1)

  overlay(plot3a1,plot3b1)
  overlay(plot3a1,plot3c1)
  overlay(plot3a1,plot3d1)
  plot(0) = plot1a1
  plot(1) = plot2a1
  plot(2) = plot3a1
;; end plot only 295K

;; if plotting only 300
;  overlay(plot1a2,plot1b2)
;  overlay(plot1a2,plot1c2)
;  overlay(plot1a2,plot1d2)
;
;  overlay(plot2a2,plot2b2)
;  overlay(plot2a2,plot2c2)
;  overlay(plot2a2,plot2d2)
;
;  overlay(plot3a2,plot3b2)
;  overlay(plot3a2,plot3c2)
;  overlay(plot3a2,plot3d2)
;
;  plot(0) = plot1a2
;  plot(1) = plot2a2
;  plot(2) = plot3a2
;; end plot only 300K

;; if plotting only 305
;  overlay(plot1a3,plot1b3)
;  overlay(plot1a3,plot1c3)
;  overlay(plot1a3,plot1d3)
;
;  overlay(plot2a3,plot2b3)
;  overlay(plot2a3,plot2c3)
;  overlay(plot2a3,plot2d3)
;
;  overlay(plot3a3,plot3b3)
;  overlay(plot3a3,plot3c3)
;  overlay(plot3a3,plot3d3)
;
;  plot(0) = plot1a3
;  plot(1) = plot2a3
;  plot(2) = plot3a3
;; end plot only 305K everything

  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  lgres@xyLineLabelFontHeightF = 0.015                ; font height
  ;lgres@lgLineColors         = (/"aquamarine3","chocolate2"/)
  lgres@lgLineColors         = (/19,67/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .06
  lgres@vpWidthF             = 0.2        ; width of legend
  lgres@vpHeightF            = 0.18        ; height of legend
  lgres@lgPerimOn            = False                         ; turn off box around
  lgres@lgLineThicknessF     = 3.0
;  lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False
  lgres@lgDashIndexes          = (/"0","0"/)

  title1="CAM6"
  title2="CAM5"
  labels = (/title1,title2/)
  legend  = gsn_create_legend (wks, 2, labels, lgres)

  amres = True
  amres@amJust = "BottomRight"

;  amres@amParallelPosF   = 0.44    ; Move legend to right
  amres@amOrthogonalPosF = 0.49     ; Move legend down
  amres@amParallelPosF   = 0.1    ; Move legend to right
  ;amres@amOrthogonalPosF = 0.     ; Move legend down

  annoid = gsn_add_annotation(plot(0),legend,amres) ; add legend to plot

respanel = True

gsn_panel(wks,plot,(/1,3/),respanel)

  print("[[[[[[[[[[[[[[[[ leaving stab_omegaD_readascii.ncl ]]]]]]]]]]]]]]]]")

end 
