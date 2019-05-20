;***********************************************************************************
; glb_trends_6pan.ncl
;***********************************************************************************
;
; branched off from glb_feedback.ncl to include a 3rd column of figures
;
; levi silvers                         may 2017 
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin
;***********************************************************************************
;;
title1="LCC"
;  res@tiMainString       = "LCC ~ 3.7*EIS - 0.9*Tsfc"
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
datapath="/net2/Levi.Silvers/data/amip_long/pp_files/"
period="late"
;

infile1=datapath+"am4_trends_tref_"+period+"_crediff_4ens.nc"
infile2=datapath+"am3_trends_tref_"+period+"_crediff.nc"
infile3=datapath+"am2_trends_tref_"+period+"_crediff.nc"

infile_isccp="/home/lgs/isccp_lcctrend_1983t2005.nc"

f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
f2=addfile(infile2,"r")
print("incoming file is: "+infile2)
f3=addfile(infile3,"r")
print("incoming file is: "+infile3)
f4=addfile(infile_isccp,"r")
print("incoming file is: "+infile_isccp)

; from file 1
  lcloud_f1         = f1->lcloud_trend(:,:)    
  lcloud_f2         = f2->lcloud_trend(:,:)    
  lcloud_f3         = f3->lcloud_trend(:,:)    
  lcloud_isccp      = f4->isccp_cf_trend(:,:)    
;;
;***********************************************************************************
lat_isccp  = f4->lat
lon_isccp  = f4->lon
;; land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat_isccp,lon_isccp)
isccp_tc_lsm=mask(lcloud_isccp,lsm.ge.1,False)

isccp_tc_lsm!0="lat"
isccp_tc_lsm&lat=lcloud_isccp&lat
isccp_tc_lsm!1="lon"
isccp_tc_lsm&lon=lcloud_isccp&lon
;***********************************************************************************
;
lcloud=lcloud_f1
print("max of file1 lcloud feedbck: "+max(lcloud))
print("min of file1 lcloud feedbck: "+min(lcloud))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat  = f1->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
lcloud_wmn        =wgt_areaave(lcloud,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(lcloud_wmn,2,True))
l_title1=title1+" (% per 30 yr)"
;
print("************************************************")
print("global mean of first net lcloud rad is: "+lcloud_wmn)
print("************************************************")
print("************************************************")
;
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
my_levels_pm8= (/-8.,-6.,-4.,-2.,0.,2.,4.,6.,8./)
;my_levels_eis= (/-2.0,-1.5,-1.0,-0.5,0.,0.5,1.0,1.5,2.0/)
my_levels_eis= (/-1.0,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.0/)
;my_levels_omega= (/-0.02,-0.015,-0.010,-0.005,0,0.005,0.01,0.015,0.02/)
my_levels_omega= (/-0.015,-0.010,-0.005,-0.0025,0,0.0025,0.005,0.01,0.015/)
;my_levels_lwp=(/-0.008,-0.006,-0.004,-0.002,0,0.002,0.004,0.006,0.008/)
my_levels_lwp=(/-8.,-6.,-4.,-2.,0,2.,4.,6.,8./)
;my_levels_tsfc=(/-2.0,-1.5,-1.,-0.5,0,0.5,1.0,1.5,2.5/)
my_levels_tsfc= (/-1.0,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.0/)
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
  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file
  ;wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"BlueDarkRed18")
  plot = new(4,graphic)
  ;plot = new(1,graphic)

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
  ;res@txFontHeightF     = 0.018 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.015           ; label bar font height
  ;res@lbLabelBarOn       = False
  res@lbLabelBarOn       = True

  ;res@tiMainString       = maintitle  ; add a title
  res@tiMainFontHeightF  = .023                               ; font height

;;------------------------------------------------------------------------------
;;;;------------------------------------------------------------------------------
;;; use below for LCC/EIS plot 
;;; row 1
  ;res@tiMainString       = l_title1 
  res@tiMainString      = "AM4 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour1 = gsn_csm_contour_map(wks,lcloud_f1,res)  ; create the plot
  plot(0) = contour1

; row 2
  ;res@tiMainString       = l_title2 
  res@tiMainString       = "ISCCP trend (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour4 = gsn_csm_contour_map(wks,isccp_tc_lsm,res)  ; create the plot
  plot(1) = contour4
  plot_isccp = contour4

; row 3
  ;res@tiMainString       = l_title3 
  res@tiMainString      = "AM3 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot(2) = contour7


; row 5
  ;res@tiMainString       = l_title5 
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour13 = gsn_csm_contour_map(wks,lcloud_f3,res)  ; create the plot
  plot(3) = contour13

;;------------------------------------------------------------------------------
;;;------------------------------------------------------------------------------


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/2,2/),resP)
;  gsn_panel(wks,plot_isccp,(/1,1/),resP)

end

