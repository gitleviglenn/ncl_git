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
;dirin1="/archive/Levi.Silvers/sstpatt/am4g5r11_cess_test"
;period="0007-0011"
;expname="/atmos_c96L32_am4g5r11_"
;suf1=period+"_fdbk_am4g5r11_p2Kmctl.nc"
;temp1_ctl="2000climo_t_surf_"+period+".nc"
;temp1_wrm="2000climo_p2K_t_surf_"+period+".nc"
;;
;; for column in the center of figure
;dirin2="/archive/Levi.Silvers/sstpatt/am4_1pc"
;;period2="0061-0065"
;period2="0136-0140"
;expname2="/atmos_AM4OM2F_c96l32_am4g5r11_"
;suf2=period2+"_fdbk_am4g5r11_1pctmctl.nc"
;temp2_ctl="2000climo_t_surf_"+period2+".nc"
;temp2_wrm="2000climo_1pct_t_surf_"+period2+".nc"
;;
fdbk_type1="toaflux_"
title1="Net TOA Response"
fdbk_type2="nettoa_CRE_"
title2="Net TOA CRE Response"
fdbk_type3="olrclr_"
title3="LW clr Response"
fdbk_type4="swclr_"
title4="SW clr Response"
fdbk_type5="olr_CRE_"
title5="LW CRE Response"
fdbk_type6="sw_CRE_"
title6="SW CRE Response"
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
;infile1="/home/lgs/CM2.1U-D4_1PctTo2X_response.nc"
;infile1="/home/lgs/test_1Pcntsst_moisture.nc"
;infile1="/home/lgs/c96L32_am4g10r8_2000climo_p2K_feedback.nc"
;infile1="/home/lgs/am3_sst_hadclimo_p_cmip3_fdbck.nc"
;infile1="/home/lgs/c96L32_am4g10r8_cm3_sst_P1.nc"
infile1="/net2/Levi.Silvers/data/amip_long/datafiles/am4g10r8_trends_early.nc"
;infile1="/net2/Levi.Silvers/data/amip_long/datafiles/am4g10r8_trends_late.nc"

f1=addfile(infile1,"r")
print("incoming file is: "+infile1)

;
  toa         = f1->toa_response(:,:)    
  cre         = f1->toa_cre_response(:,:)  
  olr_clr     = f1->lw_clr_response(:,:)     
  sw_clr      = f1->sw_clr_response(:,:)    
  olr_cre     = f1->lw_cre_response(:,:) 
  sw_cre      = f1->sw_cre_response(:,:) 
;;
;***********************************************************************************
;***********************************************************************************
;
print("max of file1 toaflux feedbck: "+max(toa))
print("min of file1 toaflux feedbck: "+min(toa))
print("max of file1 cre feedbck: "+max(cre))
print("min of file1 cre feedbck: "+min(cre))
print("max of file1 olr_clr feedbck: "+max(olr_clr))
print("min of file1 olr_clr feedbck: "+min(olr_clr))
print("max of file1 swup_toa_clr feedbck: "+max(sw_clr))
print("min of file1 swup_toa_clr feedbck: "+min(sw_clr))
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
olr_clr_wmn    =wgt_areaave(olr_clr,clat,1.0,1)
sw_clr_wmn     =wgt_areaave(sw_clr,clat,1.0,1)
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
posh=flt2string(decimalPlaces(olr_clr_wmn,2,True))
l_title3=title3+" "+posh
posh=flt2string(decimalPlaces(sw_clr_wmn,2,True))
l_title4=title4+" "+posh
posh=flt2string(decimalPlaces(olr_cre_wmn,2,True))
l_title5=title5+" "+posh
posh=flt2string(decimalPlaces(sw_cre_wmn,2,True))
l_title6=title6+" "+posh
;
print("************************************************")
print("global mean of first net toa rad is: "+toa_wmn)
print("global mean of first net cre is: "+cre_wmn)
print("global mean of first net olr_clr: "+olr_clr_wmn)
print("global mean of first net sw_clr: "+sw_clr_wmn)
print("global mean of first net olr_cre: "+olr_cre_wmn)
print("global mean of first net sw_cre: "+sw_cre_wmn)
print("************************************************")
;print("global mean of exp1 ctl t_surf: "+ctl_tsurf_exp1)
;print("global mean of exp1 ctl+warm t_surf: "+wrm_tsurf_exp1)
print("************************************************")
;
;***********************************************************************************
; read in netCDF files for column on right; experiment two
;***********************************************************************************

;infile2="/home/lgs/CM2.1U-D4_1PctTo2X_response.nc"
;infile2="/home/lgs/c48l24_am2p14_CESSp2k_response.nc"
;infile2="/home/lgs/c96L32_am4g10r8_sst_hadclimo_p_cmip3_fdbck.nc"
;infile2="/home/lgs/c96L32_am4g10r8_cm3_sst_P2.nc"
;infile2="/home/lgs/am3_p2.nc"
infile2="/net2/Levi.Silvers/data/amip_long/datafiles/am2_trends_early.nc"
;infile2="/net2/Levi.Silvers/data/amip_long/datafiles/am2_trends_late.nc"

aa=addfile(infile2,"r")
print("incoming file is: "+infile2)

;
  toa_b         = aa->toa_response(:,:)    
  cre_b         = aa->toa_cre_response(:,:)  
  olr_clr_b     = aa->lw_clr_response(:,:)     
  sw_clr_b      = aa->sw_clr_response(:,:)    
  olr_cre_b     = aa->lw_cre_response(:,:) 
  sw_cre_b      = aa->sw_cre_response(:,:) 
;  ctl_t_surf_b  = aa->t_surf(month,:,:)  
;  wrm_t_surf_b  = aa->t_surf(month,:,:)  
;***********************************************************************************
;***********************************************************************************
;
print("max of file2 olr feedbck: "+max(toa_b))
print("min of file2 olr feedbck: "+min(toa_b))
print("max of file2 cre feedbck: "+max(cre_b))
print("min of file2 cre feedbck: "+min(cre_b))
print("max of file2 olr_clr feedbck: "+max(olr_clr_b))
print("min of file2 olr_clr feedbck: "+min(olr_clr_b))
print("max of file2 swup_toa_clr feedbck: "+max(sw_clr_b))
print("min of file2 swup_toa_clr feedbck: "+min(sw_clr_b))
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
olr_clr_wmn =wgt_areaave(olr_clr_b,clat2,1.0,1)
sw_clr_wmn =wgt_areaave(sw_clr_b,clat2,1.0,1)
olr_cre_wmn =wgt_areaave(olr_cre_b,clat2,1.0,1)
sw_cre_wmn =wgt_areaave(sw_cre_b,clat2,1.0,1)
;ctl_tsurf_exp2 =wgt_areaave(ctl_t_surf_b,clat2,1.0,1)
;wrm_tsurf_exp2 =wgt_areaave(wrm_t_surf_b,clat2,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(toa_wmn,2,True))
c_title1=title1+" "+posh
posh=flt2string(decimalPlaces(cre_wmn,2,True))
c_title2=title2+" "+posh
posh=flt2string(decimalPlaces(olr_clr_wmn,2,True))
c_title3=title3+" "+posh
posh=flt2string(decimalPlaces(sw_clr_wmn,2,True))
c_title4=title4+" "+posh
posh=flt2string(decimalPlaces(olr_cre_wmn,2,True))
c_title5=title5+" "+posh
posh=flt2string(decimalPlaces(sw_cre_wmn,2,True))
c_title6=title6+" "+posh
;
print("************************************************")
print("global mean of second net toa rad is: "+toa_wmn)
print("global mean of second net cre is: "+cre_wmn)
print("global mean of second net olr_clr: "+olr_clr_wmn)
print("global mean of second net sw_clr: "+sw_clr_wmn)
print("global mean of second net olr_cre: "+olr_cre_wmn)
print("global mean of second net sw_cre: "+sw_cre_wmn)
print("************************************************")
;print("global mean of exp2 ctl t_surf: "+ctl_tsurf_exp2)
;print("global mean of exp2 ctl+warm t_surf: "+wrm_tsurf_exp2)
print("************************************************")
;;
;***********************************************************************************
; read in netCDF files for column on right; experiment three
;***********************************************************************************

;infile3="/home/lgs/c96L32_am4g10r8_cm3_sst_P3.nc"
infile3="/net2/Levi.Silvers/data/amip_long/datafiles/am3p9_trends_early.nc"
;infile3="/net2/Levi.Silvers/data/amip_long/datafiles/am3p9_trends_late.nc"

cc=addfile(infile3,"r")
print("incoming file is: "+infile3)

;
  toa_c         = cc->toa_response(:,:)    
  cre_c         = cc->toa_cre_response(:,:)  
  olr_clr_c     = cc->lw_clr_response(:,:)     
  sw_clr_c      = cc->sw_clr_response(:,:)    
  olr_cre_c     = cc->lw_cre_response(:,:) 
  sw_cre_c      = cc->sw_cre_response(:,:) 
;  ctl_t_surf_c  = cc->t_surf(month,:,:)  
;  wrm_t_surf_c  = cc->t_surf(month,:,:)  
;***********************************************************************************
;***********************************************************************************
;
print("max of file3 olr feedbck: "+max(toa_c))
print("min of file3 olr feedbck: "+min(toa_c))
print("max of file3 cre feedbck: "+max(cre_c))
print("min of file3 cre feedbck: "+min(cre_c))
print("max of file3 olr_clr feedbck: "+max(olr_clr_c))
print("min of file3 olr_clr feedbck: "+min(olr_clr_c))
print("max of file3 swup_toa_clr feedbck: "+max(sw_clr_c))
print("min of file3 swup_toa_clr feedbck: "+min(sw_clr_c))
print("max of file3 olr_cre feedbck: "+max(olr_cre_c))
print("min of file3 olr_cre feedbck: "+min(olr_cre_c))
print("max of file3 sw_cre feedbck: "+max(sw_cre_c))
print("min of file3 sw_cre feedbck: "+min(sw_cre_c))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat2  = cc->lat
rad  = 4.0*atan(1.0)/180.0
clat2 = cos(lat2*rad)
toa_wmn     =wgt_areaave(toa_c,clat2,1.0,1)
cre_wmn     =wgt_areaave(cre_c,clat2,1.0,1)
olr_clr_wmn =wgt_areaave(olr_clr_c,clat2,1.0,1)
sw_clr_wmn =wgt_areaave(sw_clr_c,clat2,1.0,1)
olr_cre_wmn =wgt_areaave(olr_cre_c,clat2,1.0,1)
sw_cre_wmn =wgt_areaave(sw_cre_c,clat2,1.0,1)
;ctl_tsurf_exp2 =wgt_areaave(ctl_t_surf_c,clat2,1.0,1)
;wrm_tsurf_exp2 =wgt_areaave(wrm_t_surf_c,clat2,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(toa_wmn,2,True))
r_title1=title1+" "+posh
posh=flt2string(decimalPlaces(cre_wmn,2,True))
r_title2=title2+" "+posh
posh=flt2string(decimalPlaces(olr_clr_wmn,2,True))
r_title3=title3+" "+posh
posh=flt2string(decimalPlaces(sw_clr_wmn,2,True))
r_title4=title4+" "+posh
posh=flt2string(decimalPlaces(olr_cre_wmn,2,True))
r_title5=title5+" "+posh
posh=flt2string(decimalPlaces(sw_cre_wmn,2,True))
r_title6=title6+" "+posh
;
print("************************************************")
print("global mean of second net toa rad is: "+toa_wmn)
print("global mean of second net cre is: "+cre_wmn)
print("global mean of second net olr_clr: "+olr_clr_wmn)
print("global mean of second net sw_clr: "+sw_clr_wmn)
print("global mean of second net olr_cre: "+olr_cre_wmn)
print("global mean of second net sw_cre: "+sw_cre_wmn)
print("************************************************")
;print("global mean of exp2 ctl t_surf: "+ctl_tsurf_exp2)
;print("global mean of exp2 ctl+warm t_surf: "+wrm_tsurf_exp2)
print("************************************************")
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
;my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_posneg = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
my_colors_netcre = (/ 7, 2,74,77,80,83,86,89,92,95,100/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)

;************************************************
  wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"BlueDarkRed18")
  plot = new(18,graphic)

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
  res@gsnFrame         = False
  res@tiMainString       = r_title1
  contour3 = gsn_csm_contour_map(wks,toa_c,res)  ; create the plot
  plot(2) = contour3

; row 2
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = l_title2 
  contour4 = gsn_csm_contour_map(wks,cre,res)  ; create the plot
  plot(3) = contour4
  res@gsnFrame         = False
  res@tiMainString       = c_title2 
  contour5 = gsn_csm_contour_map(wks,cre_b,res)  ; create the plot
  plot(4) = contour5
  res@gsnFrame         = False
  res@tiMainString       = r_title2
  contour6 = gsn_csm_contour_map(wks,cre_c,res)  ; create the plot
  plot(5) = contour6

; row 3
  res@tiMainString       = l_title3 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,olr_clr,res)  ; create the plot
  plot(6) = contour7
  res@gsnFrame         = False
  res@tiMainString       = c_title3 
  contour8 = gsn_csm_contour_map(wks,olr_clr_b,res)  ; create the plot
  plot(7) = contour8
  res@gsnFrame         = False
  res@tiMainString       = r_title3
  contour9 = gsn_csm_contour_map(wks,olr_clr_c,res)  ; create the plot
  plot(8) = contour9

; row 4
  res@tiMainString       = l_title4 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,sw_clr,res)  ; create the plot
  plot(9) = contour10
  res@gsnFrame         = False
  res@tiMainString       = c_title4 
  contour11 = gsn_csm_contour_map(wks,sw_clr_b,res)  ; create the plot
  plot(10) = contour11
  res@gsnFrame         = False
  res@tiMainString       = r_title4
  contour12 = gsn_csm_contour_map(wks,sw_clr_c,res)  ; create the plot
  plot(11) = contour12

; row 5
  res@tiMainString       = l_title5 
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour13 = gsn_csm_contour_map(wks,olr_cre,res)  ; create the plot
  plot(12) = contour13
  res@gsnFrame         = False
  res@tiMainString       = c_title5 
  contour14 = gsn_csm_contour_map(wks,olr_cre_b,res)  ; create the plot
  plot(13) = contour14
  res@gsnFrame         = False
  res@tiMainString       = r_title5
  contour15 = gsn_csm_contour_map(wks,olr_cre_c,res)  ; create the plot
  plot(14) = contour15

; row 6
  res@tiMainString       = l_title6 
  ;res@lbOrientation            = "Vertical"
  res@cnLevels           = my_levels_simple
  res@cnFillColors       = my_colors_posneg
  contour16 = gsn_csm_contour_map(wks,sw_cre,res)  ; create the plot
  plot(15) = contour16
  res@gsnFrame         = False
  res@tiMainString       = c_title6 
  contour17 = gsn_csm_contour_map(wks,sw_cre_b,res)  ; create the plot
  plot(16) = contour17
  res@gsnFrame         = False
  res@tiMainString       = r_title6 
  contour18 = gsn_csm_contour_map(wks,sw_cre_c,res)  ; create the plot
  plot(17) = contour18

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

  gsn_panel(wks,plot,(/6,3/),resP)

end

