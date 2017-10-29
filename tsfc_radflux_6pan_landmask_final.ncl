;***********************************************************************************
; tsfc_radflux_6pan_landmask_test.ncl
;***********************************************************************************
;
; plot the trend of surface temperature for period between 1925-1955 and 1975-2005
;
; levi silvers                         june 2017 
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; define directories, var names, and periods
; for incoming files
;***********************************************************************************
; 
;;; for column on left of figure
;;;
;title1="LCC"
;;  res@tiMainString       = "LCC ~ 3.7*EIS - 0.9*Tsfc"
;title2="LCC ~ 3.7*EIS - 0.9*Tsfc"
;title3="EIS ~ T700 - 1.2*Tsfc"
;;  res@tiMainString       = "EIS ~ T700 - 1.2*Tsfc"
;title4="EIS "
;title5="Tsfc "
;title6="T on 700 hPa "
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
datapath="~/data/amip_Long/"
;datapath="/net2/Levi.Silvers/data/amip_long/pp_files/"

infile1=datapath+"am4_trends_tsfc_early_pdown.nc"
;infile2=datapath+"am4_trends_tsfc_19802005_pdown.nc"
infile2=datapath+"am4_trends_tsfc_late_pdown.nc"


f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
f2=addfile(infile2,"r")
print("incoming file is: "+infile2)

; from file 1
  tsfc_f1           = f1->tsurf_trend(:,:) 
  tsfc_f2           = f2->tsurf_trend(:,:) 
;;
  sw_cre_f1         = f1->sw_cre_trend(:,:)
  lw_cre_f1         = f1->lw_cre_trend(:,:)

  sw_cre_f2         = f2->sw_cre_trend(:,:)
  lw_cre_f2         = f2->lw_cre_trend(:,:)
;***********************************************************************************
;***********************************************************************************
;
tsfc=tsfc_f1
tsfc2=tsfc_f2
print("max of file1 tsfc : "+max(tsfc))
print("min of file1 tsfc : "+min(tsfc))
print("max of file2 tsfc : "+max(tsfc2))
print("min of file2 tsfc : "+min(tsfc2))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat  = f1->lat
lon  = f1->lon
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
tsfc_wmn       = wgt_areaave(tsfc,clat,1.0,1)
tsfc_anom      = tsfc-tsfc_wmn
tsfc_anom_wmn  = wgt_areaave(tsfc_anom,clat,1.0,1) ; should be close to zero

tsfc2_wmn      = wgt_areaave(tsfc2,clat,1.0,1)
tsfc2_anom     = tsfc2-tsfc2_wmn
tsfc2_anom_wmn = wgt_areaave(tsfc2_anom,clat,1.0,1) ; should be close to zero
;***********************************************************************************
;;***********************************************************************************
print("************************************************")
print("global mean of first tsfc: "+tsfc_wmn)
print("global mean of first tsfc anom: "+tsfc_anom_wmn)
print("global mean of second tsfc: "+tsfc2_wmn)
print("global mean of second tsfc anom: "+tsfc2_anom_wmn)
print("************************************************")
print("************************************************")
;
;;***********************************************************************************
;; create land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat,lon)

;; apply land sea mask
; -----first file-----
tsfcmask_f1=mask(tsfc_anom,lsm.ge.1,False)  ; apply mask to anomaly
sw_cre_mask_f1=mask(sw_cre_f1,lsm.ge.1,False)  ; apply mask to anomaly
lw_cre_mask_f1=mask(lw_cre_f1,lsm.ge.1,False)  ; apply mask to anomaly

tsfcmask_f1!0="lat"
tsfcmask_f1&lat=tsfc&lat
tsfcmask_f1!1="lon"
tsfcmask_f1&lon=tsfc&lon

sw_cre_mask_f1!0="lat"
sw_cre_mask_f1&lat=tsfc&lat
sw_cre_mask_f1!1="lon"
sw_cre_mask_f1&lon=tsfc&lon

lw_cre_mask_f1!0="lat"
lw_cre_mask_f1&lat=tsfc&lat
lw_cre_mask_f1!1="lon"
lw_cre_mask_f1&lon=tsfc&lon

;

; -----second file-----
tsfcmask_f2=mask(tsfc2_anom,lsm.ge.1,False)
sw_cre_mask_f2=mask(sw_cre_f2,lsm.ge.1,False)  ; apply mask to anomaly
lw_cre_mask_f2=mask(lw_cre_f2,lsm.ge.1,False)  ; apply mask to anomaly

tsfcmask_f2!0="lat"
tsfcmask_f2&lat=tsfc&lat
tsfcmask_f2!1="lon"
tsfcmask_f2&lon=tsfc&lon

sw_cre_mask_f2!0="lat"
sw_cre_mask_f2&lat=tsfc&lat
sw_cre_mask_f2!1="lon"
sw_cre_mask_f2&lon=tsfc&lon

lw_cre_mask_f2!0="lat"
lw_cre_mask_f2&lat=tsfc&lat
lw_cre_mask_f2!1="lon"
lw_cre_mask_f2&lon=tsfc&lon

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
my_levels_eis= (/-1.0,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.0/)
my_levels_omega= (/-0.015,-0.010,-0.005,-0.0025,0,0.0025,0.005,0.01,0.015/)
my_levels_lwp=(/-8.,-6.,-4.,-2.,0,2.,4.,6.,8./)
my_levels_tsfc= (/-1.0,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.0/)
;
my_colors_olr = (/55, 60,  65, 70, 75, 80, 85, 90, 95,100,105/)
my_colors_swup = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
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
  plot = new(2,graphic)
  plot2 = new(4,graphic)

  res                   = True
  res@cnLinesOn         = False
  ;res@lbOrientation     = "Vertical"
  ;res@gsnPaperOrientation = "portrait" 
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
  ;res@gsnMaximize       = True
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  ;res@txFontHeightF     = 0.018 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title
  res@tiMainFontHeightF  = .023                               ; font height

;;;------------------------------------------------------------------------------
; row 1
  ;res@tiMainString       = l_title1 
  res@tiMainString      = "CMIP6 Tsfc trend 1925-1955 (K per 30 yr)"
  res@cnLevels          = my_levels_tsfc
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  ;res@cnFillPalette     = cmap(10:96,:)
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  ;contour1 = gsn_csm_contour_map(wks,tsfc_f1,res)  ; create the plot
  contour1 = gsn_csm_contour_map(wks,tsfcmask_f1,res)  ; create the plot
  plot(0) = contour1

; row 2
  ;res@tiMainString       = l_title2 
  res@tiMainString       = "CMIP6 Tsfc trend 1975-2005 (K per 30 yr)"
  res@cnLevels          = my_levels_tsfc
  res@cnFillColors      = my_colors_posneg
  contour4 = gsn_csm_contour_map(wks,tsfcmask_f2,res)  ; create the plot
  plot(1) = contour4

;;;------------------------------------------------------------------------------
; row 1
  res@tiMainString       = "AM4 LW CRE trend 1925-1955 (W/m2 per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False
  contour1 = gsn_csm_contour_map(wks,lw_cre_mask_f1,res)  ; create the plot
  plot2(2) = contour1

; row 2
  res@tiMainString      = "AM4 SW CRE trend 1925-1955 (W/m2 per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour4 = gsn_csm_contour_map(wks,sw_cre_mask_f1,res)  ; create the plot
  plot2(0) = contour4

; row 3
  res@tiMainString       = "AM4 LW CRE trend 1975-2005 (W/m2 per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,lw_cre_mask_f2,res)  ; create the plot
  plot2(3) = contour7

; row 4
  res@tiMainString       = "AM4 SW CRE trend 1975-2005 (W/m2 per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,sw_cre_mask_f2,res)  ; create the plot
  plot2(1) = contour10

;;;------------------------------------------------------------------------------

;---Resources for paneling
    pres                   = True              ; modify the panel plot
    pres@gsnPanelMainString= "fyrname"
    pres@gsnPaperOrientation = "portrait" 
    pres@gsnFrame          = False             ; don't advance frame yet
    pres@gsnDraw           = False             ; draw later, in maximize mode
    ;pres@gsnPanelBottom    = 0.33              ; top 2/3 of frame
    ;pres@gsnPanelBottom    = 0.66              ; top 2/3 of frame
    pres@gsnPanelTop        = 0.9
    pres@gsnPanelBottom     = 0.6

    pres@gsnPanelLabelBar  = True              ; add common colorbar
    pres@lbOrientation     = "vertical"
    pres@pmLabelBarWidthF  = 0.075             ; make thinner
    pres@pmLabelBarHeightF = 0.25
    ;pres@pmLabelBarHeightF = 0.20

  panelid1 = gsn_panel_return(wks,plot,(/1,2/),pres)

;---Calculate location for top of difference plots
    bb     = NhlGetBB(panelid1)
    bottom = min(bb(:,1))
    top    = max(bb(:,0))
    height = (top-bottom)/2.     ; Height of one row

;---Panel the diff plots at the bottom
    delete(pres@gsnPanelMainString)
    pres@gsnPanelTop        = 0.6-0.01
    pres@gsnPanelBottom     = 0.05
    ;pres@gsnPanelTop       = bottom-0.01    ; lower 1/3 plus some white space
    ;pres@gsnPanelBottom    = pres@gsnPanelTop - height

    pres@pmLabelBarHeightF = 0.40  

    panelid2 = gsn_panel_return(wks,plot2,(/2,2/),pres)

    maximize_output(wks,True)

  ;resP                  = True                   ; modify the panel plot
  ;resP@gsnFrame         = False                  ; don't advance panel plot

  ;gsn_panel(wks,plot,(/3,2/),resP)

end

