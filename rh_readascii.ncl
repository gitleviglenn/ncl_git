;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; rh_readascii.ncl
;
; plots RH profiles from GCM RCE runs vs. pressure 
; 
; levi silvers                                          feb 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

array01=asciiread("arrayout_CAM5.txt",(/2,longdim/),"float")
array02=asciiread("arrayout_CAM6.txt",(/2,longdim/),"float")
array03=asciiread("arrayout_SPCAM.txt",(/2,longdim/),"float")
array04=asciiread("arrayout_ECHAM.txt",(/2,longdim/),"float")
;array05=asciiread("arrayout_ICON.txt",(/2,longdim/),"float")
array06=asciiread("arrayout_SPXCAM.txt",(/2,longdim/),"float")
array07=asciiread("arrayout_SAMUNICON.txt",(/2,longdim/),"float")
;array08=asciiread("arrayout_UKMO.txt",(/2,longdim/),"float")
array09=asciiread("arrayout_CNRM.txt",(/2,longdim/),"float")
array10=asciiread("arrayout_GEOS.txt",(/2,longdim/),"float")

colors = (/"chocolate2","aquamarine3","chartreuse3","cyan3","coral3","darkolivegreen4","cornsilk4","palegreen3","paleturquoise3","palevioletred3"/)

;============================================
wks=gsn_open_wks("eps","testplot")
gsn_define_colormap(wks,"CBR_drywet")
plot=new(1,graphic)
;plot=new(5,graphic)

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
  
  overlay(plot1a1,plot4a0)
  overlay(plot4a1,plot4a2)
  overlay(plot4a1,plot4a3)
  overlay(plot4a1,plot4b1)
  overlay(plot4a1,plot4b2)
  overlay(plot4a1,plot4b3)

  plot(0) = plot1a1

end
