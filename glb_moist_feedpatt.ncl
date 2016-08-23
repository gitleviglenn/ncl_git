;***********************************************************************************
; glb_moist_feedpatt.ncl
;***********************************************************************************
;
; plot global feedback patterns akin to Andrews
; et al. 2014 Fig. 4 but for precip, wvp, lwp, and t_ref
;
; this program generally depends on the output from 
; cdo_cre.s that will create the 
; needed input files.  
; 
; levi silvers                         aug 2016 
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
;;
;fdbk_type1="toaflux_"
title1="precip Response"
;fdbk_type2="nettoa_CRE_"
title2="WVP Response"
;fdbk_type3="olrclr_"
title3="LWP Response"
;fdbk_type4="swclr_"
title4="2m Temp Response"
;fdbk_type5="olr_CRE_"
title5="LW CRE Response"
;fdbk_type6="sw_CRE_"
title6="SW CRE Response"
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
;infile1="/home/lgs/c96L32_am4g10r8_hadsstp1pctco2_climo_feedback.nc"
;infile1="/home/lgs/testout.nc"
infile1="/home/lgs/test_1Pcnticesst_moisture.nc"

f1=addfile(infile1,"r")
print("incoming file is: "+infile1)

;
pscale=86400.*3
  toa         = f1->precip_response(:,:)    
  toa = pscale*toa
  cre         = f1->wvp_response(:,:)  
lwpscale=300.
  lwp         = f1->lwp_response(:,:)     
  lwp=lwpscale*lwp
t_refscale=3.
  t_ref      = f1->t_ref_response(:,:)    
  t_ref=t_refscale*t_ref
  olr_cre     = f1->lw_cre_response(:,:) 
  sw_cre      = f1->sw_cre_response(:,:) 
;;
;***********************************************************************************
;***********************************************************************************
;
print("max of file1 precip feedbck: "+max(toa))
print("min of file1 precip feedbck: "+min(toa))
print("max of file1 wvp feedbck: "+max(cre))
print("min of file1 wvp feedbck: "+min(cre))
print("max of file1 lwp feedbck: "+max(lwp))
print("min of file1 lwp feedbck: "+min(lwp))
print("max of file1 t_ref feedbck: "+max(t_ref))
print("min of file1 t_ref feedbck: "+min(t_ref))
print("max of file1 olr_cre feedbck: "+max(olr_cre))
print("min of file1 olr_cre feedbck: "+min(olr_cre))
print("max of file1 sw_cre feedbck: "+max(sw_cre))
print("min of file1 sw_cre feedbck: "+min(sw_cre))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat  = f1->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
toa_wmn        =wgt_areaave(toa,clat,1.0,1)
cre_wmn        =wgt_areaave(cre,clat,1.0,1)
lwp_wmn    =wgt_areaave(lwp,clat,1.0,1)
t_ref_wmn     =wgt_areaave(t_ref,clat,1.0,1)
olr_cre_wmn    =wgt_areaave(olr_cre,clat,1.0,1)
sw_cre_wmn     =wgt_areaave(sw_cre,clat,1.0,1)
;ctl_tsurf_exp1 =wgt_areaave(ctl_t_surf,clat,1.0,1)
;wrm_tsurf_exp1 =wgt_areaave(wrm_t_surf,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(toa_wmn,2,True))
l_title1=title1+" "+posh
posh=flt2string(decimalPlaces(cre_wmn,2,True))
l_title2=title2+" "+posh
posh=flt2string(decimalPlaces(lwp_wmn,2,True))
l_title3=title3+" "+posh
posh=flt2string(decimalPlaces(t_ref_wmn,2,True))
l_title4=title4+" "+posh
posh=flt2string(decimalPlaces(olr_cre_wmn,2,True))
l_title5=title5+" "+posh
posh=flt2string(decimalPlaces(sw_cre_wmn,2,True))
l_title6=title6+" "+posh
;
print("************************************************")
print("global mean of first net toa rad is: "+toa_wmn)
print("global mean of first net cre is: "+cre_wmn)
print("global mean of first net lwp: "+lwp_wmn)
print("global mean of first net t_ref: "+t_ref_wmn)
print("global mean of first net olr_cre: "+olr_cre_wmn)
print("global mean of first net sw_cre: "+sw_cre_wmn)
print("************************************************")
print("************************************************")
;
;***********************************************************************************
; read in netCDF files for column on right; experiment two
;***********************************************************************************

;infile1="/home/lgs/c48l24_am2p14_CESSp2k_response.nc"
;infile1="/home/lgs/c96L32_am4g10r8_2000climo_p2K_feedback.nc"
infile1="/home/lgs/test_1mice_moisture_raw.nc"

aa=addfile(infile1,"r")
print("incoming file is: "+infile1)

;
  toa_b         = aa->precip_response(:,:)    
  toa_b = pscale*toa_b
  cre_b         = aa->wvp_response(:,:)  
  lwp_b         = aa->lwp_response(:,:)     
  lwp_b=lwpscale*lwp_b
  t_ref_b       = aa->t_ref_response(:,:)    
  t_ref_b=t_refscale*t_ref_b
  olr_cre_b     = aa->lw_cre_response(:,:) 
  sw_cre_b      = aa->sw_cre_response(:,:) 
;***********************************************************************************
;***********************************************************************************
;
print("max of file2 precip feedbck: "+max(toa_b))
print("min of file2 precip feedbck: "+min(toa_b))
print("max of file2 wvp feedbck: "+max(cre_b))
print("min of file2 wvp feedbck: "+min(cre_b))
print("max of file2 lwp feedbck: "+max(lwp_b))
print("min of file2 lwp feedbck: "+min(lwp_b))
print("max of file2 swup_toa_clr feedbck: "+max(t_ref_b))
print("min of file2 swup_toa_clr feedbck: "+min(t_ref_b))
print("max of file2 olr_cre feedbck: "+max(olr_cre_b))
print("min of file2 olr_cre feedbck: "+min(olr_cre_b))
print("max of file2 sw_cre feedbck: "+max(sw_cre_b))
print("min of file2 sw_cre feedbck: "+min(sw_cre_b))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat2  = aa->lat
rad  = 4.0*atan(1.0)/180.0
clat2 = cos(lat2*rad)
toa_wmn     =wgt_areaave(toa_b,clat2,1.0,1)
cre_wmn     =wgt_areaave(cre_b,clat2,1.0,1)
lwp_wmn =wgt_areaave(lwp_b,clat2,1.0,1)
t_ref_wmn =wgt_areaave(t_ref_b,clat2,1.0,1)
olr_cre_wmn =wgt_areaave(olr_cre_b,clat2,1.0,1)
sw_cre_wmn =wgt_areaave(sw_cre_b,clat2,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(toa_wmn,2,True))
c_title1=title1+" "+posh
posh=flt2string(decimalPlaces(cre_wmn,2,True))
c_title2=title2+" "+posh
posh=flt2string(decimalPlaces(lwp_wmn,2,True))
c_title3=title3+" "+posh
posh=flt2string(decimalPlaces(t_ref_wmn,2,True))
c_title4=title4+" "+posh
posh=flt2string(decimalPlaces(olr_cre_wmn,2,True))
c_title5=title5+" "+posh
posh=flt2string(decimalPlaces(sw_cre_wmn,2,True))
c_title6=title6+" "+posh
;
print("************************************************")
print("global mean of second net toa rad is: "+toa_wmn)
print("global mean of second net cre is: "+cre_wmn)
print("global mean of second net lwp: "+lwp_wmn)
print("global mean of second net t_ref: "+t_ref_wmn)
print("global mean of second net olr_cre: "+olr_cre_wmn)
print("global mean of second net sw_cre: "+sw_cre_wmn)
print("************************************************")
;;
;***********************************************************************************
;
print("************************************************")
;
;***********************************************************************************
; create plot
;***********************************************************************************

;my_levels1 = (/265,270,275,280,284,286,288,290,292,294,296,298,300,302,304/)
my_levels_nettoa = (/-12,-9,-6,-3,0, 3,6,9,12/)
my_levels_netcre = (/-20,-15,-10,-5,0,5,10,15,20/)
my_levels_swcre = (/-30,-20,-10,-5,0,5,10,20,30/)
my_levels_olrcre = my_levels_swcre
my_levels_olrclr = (/-20,-15,-10,-5,0,5,10,15,20/)
my_levels_olr_fdbk= (/-15,-10,-5,-1,0, 1,5,10,15/)
my_levels_swclr= (/-15,-10,-5,-1,0, 1,5,10,15/)
my_levels_swup = (/60,80,100,120,140,160,180,200,220/)
my_levels_simple= (/-4,-3,-2,-1,0,1,2,3,4/)
;
my_colors_olr = (/55, 60,  65, 70, 75, 80, 85, 90, 95,100,105/)
my_colors_swup = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_netcre = (/ 7, 2,74,77,80,83,86,89,92,95,100/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)

;************************************************
  wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  plot = new(12,graphic)

  res                   = True
  res@cnLinesOn         = False
  ;res@lbOrientation     = "Vertical"
  res@gsnPaperOrientation = "portrait" 
  res@mpProjection      = "Robinson"       ; choose projection
  res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
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
  res@lbLabelBarOn       = False

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .018                               ; font height
  res@tiMainFontHeightF  = .023                               ; font height

; row 1
  res@tiMainString       = l_title1 
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour1 = gsn_csm_contour_map(wks,toa,res)  ; create the plot
  plot(0) = contour1
  res@gsnFrame         = False
  res@tiMainString       = c_title1
  contour2 = gsn_csm_contour_map(wks,toa_b,res)  ; create the plot
  plot(1) = contour2
;  plot(2) = contour3

; row 2
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = l_title2 
  contour4 = gsn_csm_contour_map(wks,cre,res)  ; create the plot
  plot(2) = contour4
  res@gsnFrame         = False
  res@tiMainString       = c_title2 
  contour5 = gsn_csm_contour_map(wks,cre_b,res)  ; create the plot
  plot(3) = contour5

; row 3
  res@tiMainString       = l_title3 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,lwp,res)  ; create the plot
  plot(4) = contour7
  res@gsnFrame         = False
  res@tiMainString       = c_title3 
  contour8 = gsn_csm_contour_map(wks,lwp_b,res)  ; create the plot
  plot(5) = contour8

; row 4
  res@tiMainString       = l_title4 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,t_ref,res)  ; create the plot
  plot(6) = contour10
  res@gsnFrame         = False
  res@tiMainString       = c_title4 
  contour11 = gsn_csm_contour_map(wks,t_ref_b,res)  ; create the plot
  plot(7) = contour11

; row 5
  res@tiMainString       = l_title5 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour13 = gsn_csm_contour_map(wks,olr_cre,res)  ; create the plot
  plot(8) = contour13
  res@gsnFrame         = False
  res@tiMainString       = c_title5 
  contour14 = gsn_csm_contour_map(wks,olr_cre_b,res)  ; create the plot
  plot(9) = contour14

; row 6
  res@tiMainString       = l_title6 
  ;res@lbOrientation            = "Vertical"
  res@cnLevels           = my_levels_simple
  res@cnFillColors       = my_colors_posneg
  contour16 = gsn_csm_contour_map(wks,sw_cre,res)  ; create the plot
  plot(10) = contour16
  res@gsnFrame         = False
  res@tiMainString       = c_title6 
  contour17 = gsn_csm_contour_map(wks,sw_cre_b,res)  ; create the plot
  plot(11) = contour17

  ;respanel = True
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  ;resP@txString           = "A common title"     ; old way of setting main title
  ;resP@gsnPanelFontHeightF  = 0.015           ; label bar font height
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  ;resP@gsnPanelFigureStrings= (/"a)","b)","c)"/) ; add strings to panel
  ;resP@amJust   = "TopLeft"
;  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

  gsn_panel(wks,plot,(/6,2/),resP)

end

