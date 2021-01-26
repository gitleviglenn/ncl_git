;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; read in ascii files from the driver script on casper
;
; this script should read in data from ascii files that describe pdf's of 
; omega500 from various RCEMIP CRM models. then a figure should be plotted.
;
; levi silvers                                         jan 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

binnum=24
longdim=binnum+4

array01=asciiread("arrayout_SAMCRM_295.txt",(/2,longdim/),"float")
array02=asciiread("arrayout_SAMCRM_300.txt",(/2,longdim/),"float")
array03=asciiread("arrayout_SAMCRM_305.txt",(/2,longdim/),"float")

colors = (/"chocolate2","aquamarine3","chartreuse3","cyan3","coral3","darkolivegreen4","cornsilk4","palegreen3","paleturquoise3","palevioletred3"/)

;*************************************************************
; plot the pdf
;-------------------------------------------------------------
plot = new(1,"graphic")

;
wks = gsn_open_wks("eps","testplot")

res                    = True
res@gsnDraw            = False
res@gsnFrame           = False
res@xyLineThicknessF   = 5.
res@tiYAxisString      = "PDF (%)"
res@tiXAxisString      = "circulation regime (hPa/d)"

res@trXMinF = -150.0
res@trXMaxF = 100.0
res@trYMinF = 0.0
res@trYMaxF = 30.0

;  print("first array is: "+array01)

;res@gsnCenterString    = "default bins"
res@xyLineColors = colors(3)
res@xyDashPattern =  0
res@xyLineThicknessF = 2.
plot0_a    =  gsn_csm_xy (wks,array01(1,0:binnum-1), array01(0,0:binnum-1), res)
res@xyLineColors = colors(3)
res@xyLineThicknessF = 4.
plot0_b    =  gsn_csm_xy (wks,array02(1,0:binnum-1), array02(0,0:binnum-1), res)
res@xyLineColors = colors(3)
res@xyLineThicknessF = 6.
plot0_c    =  gsn_csm_xy (wks,array03(1,0:binnum-1), array03(0,0:binnum-1), res)
;res@xyLineColors = colors(3)
;plot0_d    =  gsn_csm_xy (wks,array04(1,:), array04(0,:), res)
;;res@xyLineColors = colors(4)
;;plot0_e    =  gsn_csm_xy (wks,array05(1,:), array05(0,:), res)
;res@xyLineColors = colors(5)
;plot0_f    =  gsn_csm_xy (wks,array06(1,:), array06(0,:), res)
;res@xyLineColors = colors(6)
;plot0_g    =  gsn_csm_xy (wks,array07(1,:), array07(0,:), res)
;;res@xyLineColors = colors(7)
;;plot0_h    =  gsn_csm_xy (wks,array08(1,:), array09(0,:), res)
;res@xyLineColors = colors(8)
;plot0_i    =  gsn_csm_xy (wks,array09(1,:), array09(0,:), res)
;res@xyLineColors = colors(9)
;plot0_j    =  gsn_csm_xy (wks,array10(1,:), array10(0,:), res)

overlay(plot0_a,plot0_b)
overlay(plot0_a,plot0_c)
plot(0)=plot0_a
;
resP    = True
resP@gsnPanelMainString  = "omega 500 from SAM CRM RCE "
gsn_panel(wks,plot,(/1,1/),resP)




end 

