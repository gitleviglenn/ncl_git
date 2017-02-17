;***********************************************************************************
; glb_sstfeed_3col.ncl
;***********************************************************************************
;
; plot global feedback patterns akin to Andrews
; et al. 2014 Fig. 4
;
; branched off from glb_feedback.ncl to include a 3rd column of figures
;
; this program generally depends on the output from 
; cdo_cre.s that will create the 
; needed input files.  
; 
; levi silvers                         march 2016 
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; define directories, var names, and periods
; for incoming files
;***********************************************************************************
; 
;; for column on left of figure
;;
title1="low cloud trend"
title2="high cloud trend"
title3="omega on 500 hPa trend"
title4="EIS trend"
title5="surface temp trend"
title6="LWP trend"
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
infile1="/home/lgs/am2_eiscl_trends_am2.nc"
infile2="/home/lgs/am2_eiscl_trends_am2.nc"
infile3="/home/lgs/am2_eiscl_trends_am2.nc"

f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
f2=addfile(infile2,"r")
print("incoming file is: "+infile2)
f3=addfile(infile3,"r")
print("incoming file is: "+infile3)

;
  lwp        = f1->lwp_trend(:,:) 
  lwp2        = f2->lwp_trend(:,:) 
  lwp3        = f3->lwp_trend(:,:) 
  lwp1_trend  = f1->lwp_trend(:,:) 
  lwp2_trend  = f2->lwp_trend(:,:) 
  lwp3_trend  = f3->lwp_trend(:,:) 
;;
;***********************************************************************************
;***********************************************************************************
;
print("max of file1 LWP : "+max(lwp))
print("min of file1 LWP : "+min(lwp))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat  = f1->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;lcloud_wmn        =wgt_areaave(lcloud,clat,1.0,1)
;cre_wmn        =wgt_areaave(cre,clat,1.0,1)
;omega_wmn    =wgt_areaave(omega,clat,1.0,1)
;eis_wmn     =wgt_areaave(eis,clat,1.0,1)
;tsfc_wmn    =wgt_areaave(tsfc,clat,1.0,1)
lwp_wmn     =wgt_areaave(lwp,clat,1.0,1)
;ctl_tsurf_exp1 =wgt_areaave(ctl_t_surf,clat,1.0,1)
;wrm_tsurf_exp1 =wgt_areaave(wrm_t_surf,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(lwp_wmn,2,True))
;l_title6=title6+" "+posh
l_title6=title6+" g m-2 per 30 yr"
;
print("************************************************")
print("global mean of first net lwp: "+lwp_wmn)
print("************************************************")
print("************************************************")
;
; conversions
lwp=1000.*lwp
;;***********************************************************************************
;; create plot
;;***********************************************************************************

;my_levels1 = (/265,270,275,280,284,286,288,290,292,294,296,298,300,302,304/)
my_levels_nettoa = (/-12,-9,-6,-3,0, 3,6,9,12/)
my_levels_netcre = (/-20,-15,-10,-5,0,5,10,15,20/)
my_levels_swcre = (/-30,-20,-10,-5,0,5,10,20,30/)
my_levels_olrcre = my_levels_swcre
my_levels_olrclr = (/-20,-15,-10,-5,0,5,10,15,20/)
my_levels_olr_fdbk= (/-15,-10,-5,-1,0, 1,5,10,15/)
my_levels_swclr= (/-15,-10,-5,-1,0, 1,5,10,15/)
my_levels_swup = (/60,80,100,120,140,160,180,200,220/)
my_levels_simple= (/-4.,-3.,-2.,-1.,0.,1.,2.,3.,4./)
my_levels_eis= (/-2.0,-1.5,-1.0,-0.5,0.,0.5,1.0,1.5,2.0/)
my_levels_omega= (/-0.02,-0.015,-0.010,-0.005,0,0.005,0.01,0.015,0.02/)
;my_levels_lwp=(/-0.008,-0.006,-0.004,-0.002,0,0.002,0.004,0.006,0.008/)
my_levels_lwp=(/-8.,-6.,-4.,-2.,0,2.,4.,6.,8./)
my_levels_tsfc=(/-2.0,-1.5,-1.,-0.5,0,0.5,1.0,1.5,2.5/)
;
my_colors_olr = (/55, 60,  65, 70, 75, 80, 85, 90, 95,100,105/)
my_colors_swup = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
;my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_posneg = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
my_colors_posneg_lwp = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
my_colors_netcre = (/ 7, 2,74,77,80,83,86,89,92,95,100/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)

;************************************************
  wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"BlueDarkRed18")
  plot = new(6,graphic)

  res                   = True
  res@cnLinesOn         = False
  ;res@lbOrientation     = "Vertical"
  res@gsnPaperOrientation = "portrait" 
  res@mpProjection      = "Robinson"       ; choose projection
  ;res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpCenterLonF      = 180.
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  ;res@lbLabelAngleF     = 90
  res@mpFillOn          = False
  res@gsnDraw           = False
  res@gsnFrame          = False
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@gsnMaximize       = True
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  ;res@txFontHeightF     = 0.018 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.015           ; label bar font height
  ;res@lbLabelBarOn       = False
  res@lbLabelBarOn       = True

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .018                               ; font height
  res@tiMainFontHeightF  = .023                               ; font height

; row 1
  res@tiMainString       = l_title6 
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour1 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(0) = contour1

; row 2
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = l_title6 
  contour4 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(1) = contour4

; row 3
  res@tiMainString       = l_title6 
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(2) = contour7

; row 4
  res@tiMainString       = l_title6 
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(3) = contour10

; row 5
  res@tiMainString       = l_title6 
  res@cnLevels          = my_levels_tsfc
  res@cnFillColors      = my_colors_posneg
  contour13 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(4) = contour13

; row 6
  res@tiMainString       = l_title6 
  ;res@lbOrientation            = "Vertical"
  res@cnLevels           = my_levels_lwp
  res@cnFillColors       = my_colors_posneg
  contour16 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(5) = contour16

;  ;respanel = True
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelLabelBar = True                   ; add common colorbar
;  ;resP@txString           = "A common title"     ; old way of setting main title
;  ;resP@gsnPanelFontHeightF  = 0.015           ; label bar font height
;  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
;  ;resP@gsnPanelFigureStrings= (/"a)","b)","c)"/) ; add strings to panel
;  ;resP@amJust   = "TopLeft"
;;  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

  gsn_panel(wks,plot,(/3,2/),resP)

end

