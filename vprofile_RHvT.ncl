;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
; vprofile_RHvT.ncl
;
; plots RH profiles from GCM RCE runs vs. temperature
;
; reads txt files that have been produced from a different ncl script
; 
; this script should also be able to plot the profiles in pressure, height, 
; or temperature coordinates.
;
; levi silvers							march 30
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; labels for each of the columns in the incoming txt files:
; omega_d, sigma, hur_tmn, rscs, rlcs, temp_mn, press_mn

array1a=readAsciiTable("profiles_CAM5_295_mn.txt",8,"float",1)
array1b=readAsciiTable("profiles_CAM5_300_mn.txt",8,"float",1)
array1c=readAsciiTable("profiles_CAM5_305_mn.txt",8,"float",1)

array2a=readAsciiTable("profiles_CAM6_295_mn.txt",8,"float",1)
array2b=readAsciiTable("profiles_CAM6_300_mn.txt",8,"float",1)
array2c=readAsciiTable("profiles_CAM6_305_mn.txt",8,"float",1)

array3a=readAsciiTable("profiles_GEOS_295_mn.txt",8,"float",1)
array3b=readAsciiTable("profiles_GEOS_300_mn.txt",8,"float",1)
array3c=readAsciiTable("profiles_GEOS_305_mn.txt",8,"float",1)

array4a=readAsciiTable("profiles_SPCAM_295_mn.txt",8,"float",1)
array4b=readAsciiTable("profiles_SPCAM_300_mn.txt",8,"float",1)
array4c=readAsciiTable("profiles_SPCAM_305_mn.txt",8,"float",1)

array5a=readAsciiTable("profiles_SPXCAM_295_mn.txt",8,"float",1)
array5b=readAsciiTable("profiles_SPXCAM_300_mn.txt",8,"float",1)
array5c=readAsciiTable("profiles_SPXCAM_305_mn.txt",8,"float",1)

array6a=readAsciiTable("profiles_ECHAM_GCM_295_mn.txt",8,"float",1)
array6b=readAsciiTable("profiles_ECHAM_GCM_300_mn.txt",8,"float",1)
array6c=readAsciiTable("profiles_ECHAM_GCM_305_mn.txt",8,"float",1)

array7a=readAsciiTable("profiles_SAM_CRM_295.txt",8,"float",1)
array7b=readAsciiTable("profiles_SAM_CRM_300.txt",8,"float",1)
array7c=readAsciiTable("profiles_SAM_CRM_305.txt",8,"float",1)

;
;array01=asciiread("profiles_CAM5_295_mn.txt",(/30,10/),"float")
  printVarSummary(array1a)
  print("a few variables from array1a: "+array1a(1,2))

vlevs=29; actual vertical dimensions are vlevs+1
hur_1a  =array1a(0:vlevs,2)
hur_1b  =array1b(0:vlevs,2)
hur_1c  =array1c(0:vlevs,2)
t_1a    =array1a(0:vlevs,4)
t_1b    =array1b(0:vlevs,4)
t_1c    =array1c(0:vlevs,4)

vlevs=31;
hur_2a  =array2a(0:vlevs,2)
hur_2b  =array2b(0:vlevs,2)
hur_2c  =array2c(0:vlevs,2)
t_2a    =array2a(0:vlevs,4)
t_2b    =array2b(0:vlevs,4)
t_2c    =array2c(0:vlevs,4)

vlevs=71;
hur_3a  =array3a(0:vlevs,2)
hur_3b  =array3b(0:vlevs,2)
hur_3c  =array3c(0:vlevs,2)
t_3a    =array3a(0:vlevs,4)
t_3b    =array3b(0:vlevs,4)
t_3c    =array3c(0:vlevs,4)

vlevs=25;
hur_4a  =array4a(0:vlevs,2)
hur_4b  =array4b(0:vlevs,2)
hur_4c  =array4c(0:vlevs,2)
t_4a    =array4a(0:vlevs,4)
t_4b    =array4b(0:vlevs,4)
t_4c    =array4c(0:vlevs,4)

vlevs=25;
hur_5a  =array5a(0:vlevs,2)
hur_5b  =array5b(0:vlevs,2)
hur_5c  =array5c(0:vlevs,2)
t_5a    =array5a(0:vlevs,4)
t_5b    =array5b(0:vlevs,4)
t_5c    =array5c(0:vlevs,4)

vlevs=47;  ECHAM
hur_6a  =array6a(0:vlevs,2)
hur_6b  =array6b(0:vlevs,2)
hur_6c  =array6c(0:vlevs,2)
t_6a    =array6a(0:vlevs,4)
t_6b    =array6b(0:vlevs,4)
t_6c    =array6c(0:vlevs,4)

vlevs=74; SAM CRM 
hur_7a  =array7a(0:vlevs,2)
hur_7b  =array7b(0:vlevs,2)
hur_7c  =array7c(0:vlevs,2)
t_7a    =array7a(0:vlevs,4)
t_7b    =array7b(0:vlevs,4)
t_7c    =array7c(0:vlevs,4)


print("for experiments with SST=295K: ")
print("minimum RH is: "+min(hur_1a(14:29))+" cam5")      ; cam5
print("minimum RH is: "+min(hur_2a(14:31))+" cam6")      ; cam6
print("minimum RH is: "+100*min(hur_3a(40:71))+" geos")  ; GEOS
print("minimum RH is: "+min(hur_4a(14:25))+" sp-cam")    ; SP-CAM
print("minimum RH is: "+min(hur_5a(14:25))+" spx-cam")   ; SPX-CAM
print("minimum RH is: "+min(hur_6a(19:47))+" echam")     ; ECHAM
print("minimum RH is: "+min(hur_7a(45:74))+" sam crm")   ; SAM CRM

print("for experiments with SST=300K: ")
print("minimum RH is: "+min(hur_1b(14:29)))
print("minimum RH is: "+min(hur_2b(14:31)))
print("minimum RH is: "+100*min(hur_3b(40:71)))
print("minimum RH is: "+min(hur_4b(14:25)))
print("minimum RH is: "+min(hur_5b(14:25)))
print("minimum RH is: "+min(hur_6b(19:47))+" echam")     ; ECHAM
print("minimum RH is: "+min(hur_7b(45:74))+" sam crm")   ; SAM CRM

print("for experiments with SST=305K: ")
print("minimum RH is: "+min(hur_1c(14:29)))
print("minimum RH is: "+min(hur_2c(14:31)))
print("minimum RH is: "+100*min(hur_3c(40:71)))
print("minimum RH is: "+min(hur_4c(14:25)))
print("minimum RH is: "+min(hur_5c(14:25)))
print("minimum RH is: "+min(hur_6c(19:47))+" echam")     ; ECHAM
print("minimum RH is: "+min(hur_7c(45:74))+" sam crm")   ; SAM CRM

;
;
;**************************************************************************
;      create plot
;**************************************************************************

wks=gsn_open_wks("eps","testplot")
;gsn_define_colormap(wks,"CBR_drywet")
gsn_define_colormap(wks,"cb_9step")
plot=new(4,graphic)

res                                     = True

  res@gsnDraw          = False
  res@gsnFrame         = False

  res@xyDashPattern          = 0  
  ;res@xyLineColors           = (/"sienna2","sienna1","deepskyblue"/)
  ;res@xyLineThicknesses      = (/2.0,2.0,3.5/)
  ;res@xyExplicitLegendLabels = (/ "we","are","not"/)
  ;res@tiMainString           = "Where are the Anvils?"
;  res@tiYAxisString          = "Pressure (hPa)"
  res@tiXAxisString          = "RH (%)"
  res@tmXBMinorOn          = False

;  res@pmLegendDisplayMode    = "Always"                      ; turn on legend
;  res@pmLegendSide           = "Bottom"                      ; Change location of
;  res@pmLegendParallelPosF   = .2                           ; move units right
;  res@pmLegendOrthogonalPosF = -.48                          ; move units down
;  res@pmLegendWidthF         = 0.12                          ; Change width and
;  res@pmLegendHeightF        = 0.06                           ; height of legend.
;  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .015                          ; label font height

  res@trYReverse             = True     ; reverse the y-axis
  res@trXMaxF                =  100.
  res@trXMinF                =  0.
  res@trYMaxF                =  305
  res@trYMinF                =  190
  res@tmYROn            = False
  res@tmXTOn            = False
  res@tiYAxisString          = "Temperature (K)"
  res@tmYRBorderOn      = False
  res@tmXTBorderOn      = False

;  res@tmYUseLeft             = False
  ;res@tmYRLabelsOn           = True
  res@tmYLLabelsOn           = True
  ;res@tmEqualizeXYSizes      = True
  ;res@tmYRMode               = "Explicit"              ; explicitly set YR tick marks
  ;res@tmYRValues             = (/29.0,26.4,21.6/)                ; set the YR values (in F) where the major tick marks will be

  res@vpWidthF               = 0.3
  res@vpHeightF              = 0.49

  ;res@xyLineColors = "chocolate2"
  res@xyLineColors = 67
  res@xyLineThicknessF  = 1.0
  plot0a = gsn_csm_xy(wks,hur_1a(:),t_1a,res)
  res@xyLineThicknessF  = 2.5
  plot0b = gsn_csm_xy(wks,hur_1b(:),t_1b,res)
  res@xyLineThicknessF  = 4.0
  plot0c = gsn_csm_xy(wks,hur_1c(:),t_1c,res)

  ;res@xyLineColors = "aquamarine3"
  res@xyLineColors = 19
  res@xyLineThicknessF  = 1.0
  plot0d = gsn_csm_xy(wks,hur_2a(:),t_2a,res)
  res@xyLineThicknessF  = 2.5
  plot0e = gsn_csm_xy(wks,hur_2b(:),t_2b,res)
  res@xyLineThicknessF  = 4.0
  plot0f = gsn_csm_xy(wks,hur_2c(:),t_2c,res)
  
; light purple 
  res@xyLineColors = 35
  res@xyLineThicknessF  = 1.0
  plot0g = gsn_csm_xy(wks,100*hur_3a(:),t_3a,res)
  res@xyLineThicknessF  = 2.5
  plot0h = gsn_csm_xy(wks,100*hur_3b(:),t_3b,res)
  res@xyLineThicknessF  = 4.0
  plot0i = gsn_csm_xy(wks,100*hur_3c(:),t_3c,res)

; light red
  res@xyLineColors = 51
  res@xyLineThicknessF  = 1.0
  plot0j = gsn_csm_xy(wks,hur_4a(:),t_4a,res)
  res@xyLineThicknessF  = 2.5
  plot0k = gsn_csm_xy(wks,hur_4b(:),t_4b,res)
  res@xyLineThicknessF  = 4.0
  plot0l = gsn_csm_xy(wks,hur_4c(:),t_4c,res)

; dirty yellow
  res@xyLineColors = 60
  res@xyLineThicknessF  = 1.0
  plot0m = gsn_csm_xy(wks,hur_5a(:),t_5a,res)
  res@xyLineThicknessF  = 2.5
  plot0n = gsn_csm_xy(wks,hur_5b(:),t_5b,res)
  res@xyLineThicknessF  = 4.0
  plot0o = gsn_csm_xy(wks,hur_5c(:),t_5c,res)

; pinkish
  res@xyLineColors =44 
  res@xyLineThicknessF  = 1.0
  plot0p = gsn_csm_xy(wks,hur_6a(:),t_6a,res)
  res@xyLineThicknessF  = 2.5
  plot0q = gsn_csm_xy(wks,hur_6b(:),t_6b,res)
  res@xyLineThicknessF  = 4.0
  plot0r = gsn_csm_xy(wks,hur_6c(:),t_6c,res)

; greay
  res@xyLineColors = 77 
  res@xyLineThicknessF  = 1.0
  plot0s = gsn_csm_xy(wks,hur_7a(:),t_7a,res)
  res@xyLineThicknessF  = 2.5
  plot0t = gsn_csm_xy(wks,hur_7b(:),t_7b,res)
  res@xyLineThicknessF  = 4.0
  plot0u = gsn_csm_xy(wks,hur_7c(:),t_7c,res)



  overlay(plot0a,plot0b) 
  overlay(plot0a,plot0c) 

  overlay(plot0a,plot0d) 
  overlay(plot0a,plot0e) 
  overlay(plot0a,plot0f) 

  overlay(plot0a,plot0g) 
  overlay(plot0a,plot0h) 
  overlay(plot0a,plot0i) 

  overlay(plot0a,plot0j) 
  overlay(plot0a,plot0k) 
  overlay(plot0a,plot0l) 

  overlay(plot0a,plot0m) 
  overlay(plot0a,plot0n) 
  overlay(plot0a,plot0o) 

  overlay(plot0a,plot0p) 
  overlay(plot0a,plot0q) 
  overlay(plot0a,plot0r) 

  overlay(plot0a,plot0s) 
  overlay(plot0a,plot0t) 
  overlay(plot0a,plot0u) 

  plot(0) =plot0a

;maintitle="try again bafoon"

  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  lgres@xyLineLabelFontHeightF = 0.015                ; font height
  ;lgres@lgLineColors         = (/"plum3","orangered3","skyblue3","aquamarine3","chocolate2"/)
  ;lgres@lgLineColors         = (/59,50,34,18,66/)
  lgres@lgLineColors         = (/60,51,35,19,67/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .04
  lgres@vpWidthF             = 0.1        ; width of legend
  lgres@vpHeightF            = 0.14        ; height of legend
  lgres@lgPerimOn            = False                         ; turn off box around
  lgres@lgLineThicknessF     = 3.0
;  lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False 
  lgres@lgDashIndexes          = (/"0","0","0","0","0"/)

  title00 ="SPXCAM"
  title ="SPCAM"
  title0="GEOS"
  title1="CAM6"
  title2="CAM5"
  labels = (/title00,title,title0,title1,title2/)
  legend  = gsn_create_legend (wks, 5, labels, lgres)

  amres = True
  amres@amJust = "BottomRight"

  amres@amParallelPosF   = 0.44    ; Move legend to right
  amres@amOrthogonalPosF = 0.2     ; Move legend down

  annoid = gsn_add_annotation(plot(0),legend,amres) ; add legend to plot

respanel = True
;respanel@txString = maintitle

gsn_panel(wks,plot,(/1,1/),respanel)

end





