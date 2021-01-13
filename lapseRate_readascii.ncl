;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; read in ascii files from the driver script on casper
; 
; this script should read in data from various gcms and produce a profile plot 
; that includes data from multiple incoming gcm data streams.  
;
; levi silvers                                                 nov 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

array01=asciiread("out_295_CAM5.txt",(/30,10/),"float")
array02=asciiread("out_300_CAM5.txt",(/30,10/),"float")
array03=asciiread("out_305_CAM5.txt",(/30,10/),"float")

array1=asciiread("out_295_CAM6.txt",(/31,10/),"float")
array2=asciiread("out_300_CAM6.txt",(/31,10/),"float")
array3=asciiread("out_305_CAM6.txt",(/31,10/),"float")

;  printVarSummary(array1)
; gamma_a; gamma_m; sbycp; sigma; hur_tmn; lev_a

print("CAM5 295: 0,1:"+array01(0,1)+"  1,1:"+array01(1,1)+"   2,1:"+array01(2,1)+"   3,1:"+array01(3,1)+"   4,1"+array01(4,1))

vaxis1a=array01(0:29,5)
vaxis2a=array1(0:30,5)

zero_line   =new((/30/),float)
;zero_line=array01(0:29,0)
zero_line(0:29)=0.

gamma_a1=array01(0:29,0)
gamma_a2=array02(0:29,0)
gamma_a3=array03(0:29,0)
gamma_b1=array1(0:30,0)
gamma_b2=array2(0:30,0)
gamma_b3=array3(0:30,0)
gamma_m_a1=array01(0:29,1)
gamma_m_a2=array02(0:29,1)
gamma_m_a3=array03(0:29,1)
gamma_m_b1=array1(0:30,1)
gamma_m_b2=array2(0:30,1)
gamma_m_b3=array3(0:30,1)
hur_a1=array01(0:29,4)
hur_a2=array02(0:29,4)
hur_a3=array03(0:29,4)
hur_b1=array1(0:30,4)
hur_b2=array2(0:30,4)
hur_b3=array3(0:30,4)
sigma_a1=array01(0:29,3)
sigma_a2=array02(0:29,3)
sigma_a3=array03(0:29,3)
sigma_b1=array1(0:30,3)
sigma_b2=array2(0:30,3)
sigma_b3=array3(0:30,3)
rscs_a1=array01(0:29,6)
rscs_a2=array02(0:29,6)
rscs_a3=array03(0:29,6)
rscs_b1=array1(0:30,6)
rscs_b2=array2(0:30,6)
rscs_b3=array3(0:30,6)
rlcs_a1=array01(0:29,7)
rlcs_a2=array02(0:29,7)
rlcs_a3=array03(0:29,7)
rlcs_b1=array1(0:30,7)
rlcs_b2=array2(0:30,7)
rlcs_b3=array3(0:30,7)
ddiv_a1=array01(0:29,8)
ddiv_a2=array02(0:29,8)
ddiv_a3=array03(0:29,8)
ddiv_b1=array1(0:30,8)
ddiv_b2=array2(0:30,8)
ddiv_b3=array3(0:30,8)
thetae_a1=array01(0:29,9)
thetae_a2=array02(0:29,9)
thetae_a3=array03(0:29,9)
thetae_b1=array1(0:30,9)
thetae_b2=array2(0:30,9)
thetae_b3=array3(0:30,9)

tntr_a1=rlcs_a1+rscs_a1
tntr_a2=rlcs_a2+rscs_a2
tntr_a3=rlcs_a3+rscs_a3
tntr_b1=rlcs_b1+rscs_b1
tntr_b2=rlcs_b2+rscs_b2
tntr_b3=rlcs_b3+rscs_b3
;omega_d_a=tntr_a/sigma_a
;omega_d_b=tntr_b/sigma_b

  print("gamma_a1 from CAM5: "+gamma_a1+"pressure from CAM5: "+vaxis1a+" sigma from CAM5: "+sigma_a1)
  print("pressure from CAM6: "+vaxis2a)

;scale       = 10000. ; convert static stability to K/100hPa
scale       = 1. ; convert static stability to K/100hPa
scale_gamm  = 1000.  ; convert gamma to K/km
scalep      = 0.01   ; convert to hPa

  print("values of the a1 equivalent potential temp are: "+thetae_a1)
  print("values of the a2 equivalent potential temp are: "+thetae_a2)

  print("values to plot are: "+scale*array01(0:29,0)+" and hur: "+hur_a1(0:29)+" and the pressure values: "+vaxis1a(0:29))
  print("dimensions are: "+dimsizes(gamma_a1)+" and also: "+dimsizes(vaxis1a))
  print("values of rlcs_a1 are: "+rlcs_a1(0:29)+" and rscs_a: "+hur_a1(0:29)+" and the pressure values: "+vaxis1a(0:29))

; set the upper and lower levels to plot with the y-axis: 
ytop = 100
ybot = 1000 ;450 ; often this is set to 1000.

;============================================
wks=gsn_open_wks("eps","testplot")
gsn_define_colormap(wks,"CBR_drywet")
;plot=new(1,graphic)
plot=new(5,graphic)

  res                  = True

  res@gsnDraw          = False
  res@gsnFrame         = False

  res@xyDashPattern          = 0
  ;res@xyLineColors           = (/"sienna2","sienna1","deepskyblue"/)
  ;res@xyLineThicknesses      = (/2.0,2.0,3.5/)
  ;res@xyExplicitLegendLabels = (/ "we","are","not"/)
  ;res@tiMainString           = "Where are the Anvils?"
  res@tiYAxisString          = "Pressure (hPa)"
  res@tiXAxisString          = "K/km"

;  res@pmLegendDisplayMode    = "Always"                      ; turn on legend
;  res@pmLegendSide           = "Bottom"                      ; Change location of
;  res@pmLegendParallelPosF   = .2                           ; move units right
;  res@pmLegendOrthogonalPosF = -.48                          ; move units down
;  res@pmLegendWidthF         = 0.12                          ; Change width and
;  res@pmLegendHeightF        = 0.06                           ; height of legend.
;  res@lgPerimOn              = False                         ; turn off box around
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

;  res@tmYUseLeft             = False
  ;res@tmYRLabelsOn           = True
  res@tmYLLabelsOn           = True
  ;res@tmEqualizeXYSizes      = True
  ;res@tmYRMode               = "Explicit"              ; explicitly set YR tick marks
  ;res@tmYRValues             = (/29.0,26.4,21.6/)                ; set the YR values (in F) where the major tick marks will be

  res@vpWidthF               = 0.35
  res@vpHeightF              = 0.7

;  plot(0)   = gsn_csm_xy(wks,time/365.,avg_ts,res)
  res@xyLineColors = "chocolate2"
  ;res@xyLineThicknessF  = lthick
thick1=2.
thick2=3.
thick3=4.
  res@xyLineThicknessF       = thick1
  res@tiMainString           = "Lapse Rate"
  res@tiMainFontHeightF      = 0.035
  res@xyLineThicknessF       = thick1
  plot0a1 = gsn_csm_xy(wks,-scale_gamm*gamma_a1(0:29),scalep*vaxis1a(0:29),res)
  plot0a1_m = gsn_csm_xy(wks,-scale_gamm*gamma_m_a1(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick2
  plot0a2 = gsn_csm_xy(wks,-scale_gamm*(gamma_a2(0:29))-1,scalep*vaxis1a(0:29),res)
  plot0a2_m = gsn_csm_xy(wks,-scale_gamm*(gamma_m_a2(0:29))-1,scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick3
  plot0a3 = gsn_csm_xy(wks,-scale_gamm*(gamma_a3(0:29))-2,scalep*vaxis1a(0:29),res)
  plot0a3_m = gsn_csm_xy(wks,-scale_gamm*(gamma_m_a3(0:29))-2,scalep*vaxis1a(0:29),res)
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF       = thick1
  plot0b1 = gsn_csm_xy(wks,-scale_gamm*gamma_b1(0:30),scalep*vaxis2a(0:30),res)
  plot0b1_m = gsn_csm_xy(wks,-scale_gamm*gamma_m_b1(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick2
  plot0b2 = gsn_csm_xy(wks,-scale_gamm*(gamma_b2(0:30))-1,scalep*vaxis2a(0:30),res)
  plot0b2_m = gsn_csm_xy(wks,-scale_gamm*(gamma_m_b2(0:30))-1,scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick3
  plot0b3 = gsn_csm_xy(wks,-scale_gamm*(gamma_b3(0:30))-2,scalep*vaxis2a(0:30),res)
  plot0b3_m = gsn_csm_xy(wks,-scale_gamm*(gamma_m_b3(0:30))-2,scalep*vaxis2a(0:30),res)

  res@trXMaxF                =  100.0
  res@trXMinF                =  0.0
  res@tiXAxisString          = "%"
  res@tiMainString           = "Relative Humidity"
  res@tmXBMode     = "Automatic"
  res@xyLineColors = "chocolate2"
  res@xyLineThicknessF       = thick1
  plot1a1 = gsn_csm_xy(wks,hur_a1(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick2
  plot1a2 = gsn_csm_xy(wks,hur_a2(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick3
  plot1a3 = gsn_csm_xy(wks,hur_a3(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF       = thick1
  plot1b1 = gsn_csm_xy(wks,hur_b1(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick2 
  plot1b2 = gsn_csm_xy(wks,hur_b2(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick3
  plot1b3 = gsn_csm_xy(wks,hur_b3(0:30),scalep*vaxis2a(0:30),res)

  ;res@trXMaxF                =  0.0
  ;res@trXMinF                =  -10.0
  ;res@tiXAxisString          = "K/100hPa"
  res@trXMaxF                =  120.0
  res@trXMinF                =  -10.0
  res@tiXAxisString          = "mK/hPa"
  res@tiMainString           = "Static Stab Par"
  res@xyLineColors = "chocolate2"
  res@xyLineThicknessF       = thick1
  plot2a1 = gsn_csm_xy(wks,scale*sigma_a1(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick2 
  plot2a2 = gsn_csm_xy(wks,scale*sigma_a2(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick3 
  plot2a3 = gsn_csm_xy(wks,scale*sigma_a3(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF       = thick1
  plot2b1 = gsn_csm_xy(wks,scale*sigma_b1(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick2 
  plot2b2 = gsn_csm_xy(wks,scale*sigma_b2(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick3
  plot2b3 = gsn_csm_xy(wks,scale*sigma_b3(0:30),scalep*vaxis2a(0:30),res)

 

scalediv=1.
 
  res@trXMaxF                =  0.5
  res@trXMinF                =  -1.75
  res@tiXAxisString          = "K/s"
  res@tiMainString           = "tnt rad"
  res@xyLineColors = "chocolate2"
  scaleR=1.
  res@xyLineColors = "black"
  res@xyLineThicknessF       = thick1
  plot3a0 = gsn_csm_xy(wks,zero_line(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "chocolate2"
  plot3a1 = gsn_csm_xy(wks,scaleR*tntr_a1(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "chocolate2"
  res@xyLineThicknessF       = thick2
  plot3a2 = gsn_csm_xy(wks,scaleR*tntr_a2(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick3
  plot3a3 = gsn_csm_xy(wks,scaleR*tntr_a3(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF       = thick1
  plot3b1 = gsn_csm_xy(wks,scaleR*tntr_b1(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick2
  plot3b2 = gsn_csm_xy(wks,scaleR*tntr_b2(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick3
  plot3b3 = gsn_csm_xy(wks,scaleR*tntr_b3(0:30),scalep*vaxis2a(0:30),res)

  res@trXMaxF                =  0.2
  res@trXMinF                =  -0.5
  res@tiXAxisString          = "Div/d"
  res@tiMainString           = "Diab Div"
  res@xyLineColors = "chocolate2"
  print("ddiv values are: "+ddiv_a1(0:29))
  res@xyLineThicknessF       = thick1
  res@xyLineColors = "black"
  plot4a0 = gsn_csm_xy(wks,zero_line(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "chocolate2"
  plot4a1 = gsn_csm_xy(wks,scalediv*ddiv_a1(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick2
  plot4a2 = gsn_csm_xy(wks,scalediv*ddiv_a2(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineThicknessF       = thick3
  plot4a3 = gsn_csm_xy(wks,scalediv*ddiv_a3(0:29),scalep*vaxis1a(0:29),res)
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF       = thick1
  plot4b1 = gsn_csm_xy(wks,scalediv*ddiv_b1(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick2
  plot4b2 = gsn_csm_xy(wks,scalediv*ddiv_b2(0:30),scalep*vaxis2a(0:30),res)
  res@xyLineThicknessF       = thick3
  plot4b3 = gsn_csm_xy(wks,scalediv*ddiv_b3(0:30),scalep*vaxis2a(0:30),res)

  overlay(plot0a1,plot0a2)
  overlay(plot0a1,plot0a3)
  overlay(plot0a1,plot0b1)
  overlay(plot0a1,plot0b2)
  overlay(plot0a1,plot0b3)
  overlay(plot0a1,plot0a1_m)
  overlay(plot0a1,plot0a2_m)
  overlay(plot0a1,plot0a3_m)
  overlay(plot0a1,plot0b1_m)
  overlay(plot0a1,plot0b2_m)
  overlay(plot0a1,plot0b3_m)

  overlay(plot1a1,plot1a2)
  overlay(plot1a1,plot1a3)
  overlay(plot1a1,plot1b1)
  overlay(plot1a1,plot1b2)
  overlay(plot1a1,plot1b3)

  overlay(plot2a1,plot2a2)
  overlay(plot2a1,plot2a3)
  overlay(plot2a1,plot2b1)
  overlay(plot2a1,plot2b2)
  overlay(plot2a1,plot2b3)

  overlay(plot3a1,plot3a0)
  overlay(plot3a1,plot3a2)
  overlay(plot3a1,plot3a3)
  overlay(plot3a1,plot3b1)
  overlay(plot3a1,plot3b2)
  overlay(plot3a1,plot3b3)

  overlay(plot4a1,plot4a0)
  overlay(plot4a1,plot4a2)
  overlay(plot4a1,plot4a3)
  overlay(plot4a1,plot4b1)
  overlay(plot4a1,plot4b2)
  overlay(plot4a1,plot4b3)

  plot(0) = plot1a1
  plot(1) = plot0a1
  plot(2) = plot2a1
  plot(3) = plot3a1
  plot(4) = plot4a1

  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  lgres@xyLineLabelFontHeightF = 0.015                ; font height
  lgres@lgLineColors         = (/"aquamarine3","chocolate2"/)
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
;respanel@txString = maintitle

;gsn_panel(wks,plot,(/1,1/),respanel)
gsn_panel(wks,plot,(/1,5/),respanel)

end 
