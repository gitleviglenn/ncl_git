;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; read in ascii files from the driver script on casper
; 
; this script should read in data from ascii files that describe pdf's of omega500 from various RCEMIP models at a particular temperature.  Then a figure should be made with each of the pdfs plotted. 
;
; levi silvers                                                 jan 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;  numbins+4?
;binnum=48
if (isvar("numberOfbins")) then
  binnum=numberOfbins ; number of bins used with pdfx ncl function
  print("number of bins is:  "+binnum)
else
  binnum=24
  print("number of bins is:  "+binnum)
end if

longdim=binnum+4

array01=asciiread("PDF_arrayout_CAM5_295.txt",(/2,longdim/),"float")
array02=asciiread("PDF_arrayout_CAM6_295.txt",(/2,longdim/),"float")
array03=asciiread("PDF_arrayout_SPCAM_295.txt",(/2,longdim/),"float")
array04=asciiread("PDF_arrayout_ECHAM_295.txt",(/2,longdim/),"float")
;array05=asciiread("PDF_arrayout_ICON.txt",(/2,longdim/),"float")
array06=asciiread("PDF_arrayout_SPXCAM_295.txt",(/2,longdim/),"float")
array07=asciiread("PDF_arrayout_SAM0-UNICON_295.txt",(/2,longdim/),"float")
;array08=asciiread("PDF_arrayout_UKMO.txt",(/2,longdim/),"float")
array09=asciiread("PDF_arrayout_CNRM_295.txt",(/2,longdim/),"float")
array10=asciiread("PDF_arrayout_GEOS_295.txt",(/2,longdim/),"float")
; IPSL
; ICON has corrupted latitudes
; UKMO looks wrong...


  print("************DISTORTION**********************")
  print("dimensions of array are : "+dimsizes(array01))
  print("values of array from CAM5 are: "+array01)
  print("************DISTORTION**********************")

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
res@trXMaxF = 50.0
res@trYMinF = 0.0
res@trYMaxF = 20.0

;  printVarSummary(pdf_a)
;  print("pdf_a values are: "+pdf_a)
;  print("sum of pdf_a? is: "+sum(pdf_a))
;  print("sum of pdf_a bin_center values is: "+sum(pdf_a@bin_center))
;  print("sum of pdf_b? is: "+sum(pdf_b))
;  print("sum of pdf_b? is: "+sum(pdf_c))
;
;res@gsnCenterString    = "default bins"
res@xyLineColors = colors(0)
res@xyDashPattern =  0
res@xyLineThicknessF = 4.
plot0_a    =  gsn_csm_xy (wks,array01(1,:), array01(0,:), res)
res@xyLineColors = colors(1)
;res@xyLineThicknessF = 4.
plot0_b    =  gsn_csm_xy (wks,array02(1,:), array02(0,:), res)
res@xyLineColors = colors(2)
plot0_c    =  gsn_csm_xy (wks,array03(1,:), array03(0,:), res)
res@xyLineColors = colors(3)
plot0_d    =  gsn_csm_xy (wks,array04(1,:), array04(0,:), res)
;res@xyLineColors = colors(4)
;plot0_e    =  gsn_csm_xy (wks,array05(1,:), array05(0,:), res)
res@xyLineColors = colors(5)
plot0_f    =  gsn_csm_xy (wks,array06(1,:), array06(0,:), res)
res@xyLineColors = colors(6)
plot0_g    =  gsn_csm_xy (wks,array07(1,:), array07(0,:), res)
;res@xyLineColors = colors(7)
;plot0_h    =  gsn_csm_xy (wks,array08(1,:), array09(0,:), res)
res@xyLineColors = colors(8)
plot0_i    =  gsn_csm_xy (wks,array09(1,:), array09(0,:), res)
res@xyLineColors = colors(9)
plot0_j    =  gsn_csm_xy (wks,array10(1,:), array10(0,:), res)

overlay(plot0_a,plot0_b)
overlay(plot0_a,plot0_c)
overlay(plot0_a,plot0_d)
;overlay(plot0_a,plot0_e)
overlay(plot0_a,plot0_f)
overlay(plot0_a,plot0_g)
;overlay(plot0_a,plot0_h)
overlay(plot0_a,plot0_i)
overlay(plot0_a,plot0_j)
plot(0)=plot0_a

;
resP    = True
resP@gsnPanelMainString  = "omega 500 from RCE 300K"
gsn_panel(wks,plot,(/1,1/),resP)

end
