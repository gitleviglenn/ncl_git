; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


infile="/Users/silvers/data/WalkerCell/c96L33_8x80_nh.19790101.atmos_daily.nc"
  print("incoming file is: "+infile)
infile2="/Users/silvers/data/WalkerCell/c96L33_100x1000_nh_crm.19790101.atmos_daily.nc"
  print("incoming file is: "+infile2)

data_25km = addfile(infile,"r")
data_2km = addfile(infile2,"r")

var1="precip" ; time, grid_y, grid_x

;field1 = data_25km->$var1$(:,:,:)
field1 = data_25km->$var1$(0:60,:,:)
field1b = data_25km->$var1$(:,:,:)
field2 = data_2km->$var1$(:,:,:)

p_25_xt=dim_avg_n(field1,1)
p_25full_xt=dim_avg_n(field1b,1)
p_2_xt=dim_avg_n(field2,1)

p_25_xt=86400*p_25_xt
p_25full_xt=86400*p_25full_xt
p_2_xt=86400*p_2_xt

  print("dimsizes of field1 are: "+dimsizes(field1))
  print("max of p_25 is: "+max(p_25_xt))
  print("dimsizes of p_25_xt are: "+dimsizes(p_25_xt))
  print("max of p_2 is: "+max(p_2_xt))


plot_type="newPDF"
wks = gsn_open_wks(plot_type,"testplot")
;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"NCV_blu_red")
;gsn_define_colormap(wks,"MPL_coolwarm")
;gsn_define_colormap(wks,"gui_default")
gsn_define_colormap(wks,"BlAqGrYeOrRe")

  my_levels1 = (/1,5,10,15,20, \
               25,30,35,40,45, \
               50,55,60,65,70,75,80,85,90,95,100,105 /)

  ;my_colors1 = (/2,14,20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,128/)
;  my_colors1 = (/4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23/) ; gui_defaul
  my_colors1 = (/11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99/) ; 

;; start default plots----------------------------------------------------------
 plot = new(2,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnFillMode               = "RasterFill"       ; Raster Mode
 res@cnLinesOn                = False
 ;res@cnLevelSelectionMode = "ManualLevels"
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
 res@cnLinesOn             = False
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 res@vpWidthF          = 2.0 ; vpWidth and Height control box size
 res@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units

 res@lbLabelBarOn      = False

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@tiXAxisString     = " "
 res@tiYAxisString     = "days "

 plot(0) = gsn_csm_contour(wks,p_25_xt,res)
 plot(1) = gsn_csm_contour(wks,p_2_xt,res)

resP                         = True
resP@txString                = "good grief"
resP@gsnPanelLabelBar        = True
;resP@lbLabelFontHeightF      = 0.012
resP@lbLabelFontHeightF      = 0.022

gsn_panel(wks,plot,(/2,1/),resP)

;; plot second figure option--------------------------------------------------------
; plot = new(1,graphic)
;
;; create resource for plot
; res = True     
;
; res@gsnDraw          = False
; res@gsnFrame         = False
;
;; set up vertical axis limits
; res@cnInfoLabelOn            = False
; res@cnFillOn                 = True 
; ;res@cnFillMode               = "RasterFill"       ; Raster Mode
; res@cnLinesOn                = False
; ;res@cnLevelSelectionMode = "ManualLevels"
; res@cnLevelSelectionMode = "ExplicitLevels"
; res@cnLevels            = my_levels1
; res@cnFillColors        = my_colors1
; res@cnLinesOn             = False
;; res@cnMinLevelValF       = 0.
;; res@cnMaxLevelValF       = 70.
; res@cnLineLabelInterval  = 0                   ; label every other line
;; res@cnLevelSpacingF      = 5.0
; res@vpWidthF          = .50 ; vpWidth and Height control box size
; res@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units
;
; res@lbLabelBarOn      = False
;
;; these commands turn off/on the varname and units at top of image
; res@gsnLeftString = ""
; res@gsnRightString = ""
; res@tiXAxisString     = " "
; res@tiYAxisString     = "days "
;
; plot(0) = gsn_csm_contour(wks,p_25full_xt,res)
;
;resP                         = True
;resP@txString                = "good grief"
;resP@gsnPanelLabelBar        = True
;resP@lbLabelFontHeightF      = 0.012
;
;gsn_panel(wks,plot,(/1,1/),resP)

end

