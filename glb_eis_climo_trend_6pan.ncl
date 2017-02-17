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
title1="EIS climo AM4"
title2="EIS trend AM4"
title3="EIS climo AM3"
title4="EIS trend AM3"
title5="EIS trend AM2"
title6="EIS trend AM2"
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
;infile1="/home/lgs/c96L32_am4g10r8_cm3_sst_P1.nc"
;infile1="/net2/Levi.Silvers/data/amip_long/datafiles/am4g10r8_trends_early.nc"
;infile1="/home/lgs/am4g10r8_eiscl_trends_test.nc"
;
;infile1="/home/lgs/am4g10r8_eiscl_trends_test.nc"
infile1="/home/lgs/am4g10r8_eiscl_trends_am4_1620.nc"
;infile2="/home/lgs/am3p9_eiscl_trends.nc"
;infile2="/home/lgs/am3p9_eiscl_trends_am3_1620.nc"
infile2="/home/lgs/am3p9_eiscl_trends_am3_1620_tsurf.nc"
infile3="/home/lgs/am2_eiscl_trends_am2.nc"

infile4="/net2/Levi.Silvers/data/amip_long/datafiles/eis_lts_longamip_am4.nc"
infile5="/net2/Levi.Silvers/data/amip_long/datafiles/eis_lts_longamip_am3.nc"
infile5="/home/lgs/eis_lts_longamip_am3_tsurf.nc"
infile6="/net2/Levi.Silvers/data/amip_long/datafiles/eis_lts_longamip_am2.nc"

f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
f2=addfile(infile2,"r")
print("incoming file is: "+infile2)
f3=addfile(infile3,"r")
print("incoming file is: "+infile3)

f4=addfile(infile4,"r")
print("incoming file is: "+infile4)
f5=addfile(infile5,"r")
print("incoming file is: "+infile5)
f6=addfile(infile6,"r")
print("incoming file is: "+infile6)
;
intimes=1259;
intimee=1619;
  lcloud         = f1->lcloud_trend(:,:)    
  cre         = f1->hcloud_trend(:,:)  
  omega       = f1->omega_trend(:,:)     
  eis            = f1->eis_trend(:,:)    
  eis_tr_am3     = f2->eis_trend(:,:)    
  eis_tr_am2     = f3->eis_trend(:,:)    
  eis_climo_am4  = f4->eis_am4ts(intimes:intimee,:,:)
  eis_climo_am3  = f5->eis_am3ts(intimes:intimee,:,:)
  eis_climo_am2  = f6->eis_am2ts(intimes:intimee,:,:)
  tsfc     = f1->tsfc_trend(:,:) 
  lwp      = f1->lwp_trend(:,:) 
;;
;***********************************************************************************
print("dimensions of eis_climo_am4 are: "+dimsizes(eis_climo_am4))
eis_cl_am4=dim_avg_n(eis_climo_am4,0)
;eis_cl_am4=eis_climo_am4(100,:,:)
eis_cl_am4!0="lat"
eis_cl_am4&lat=eis_climo_am4&lat
eis_cl_am4!1="lon"
eis_cl_am4&lon=eis_climo_am4&lon
;
eis_cl_am3=dim_avg_n(eis_climo_am3,0)
eis_cl_am3!0="lat"
eis_cl_am3&lat=eis_climo_am3&lat
eis_cl_am3!1="lon"
eis_cl_am3&lon=eis_climo_am3&lon

eis_cl_am2=dim_avg_n(eis_climo_am2,0)
eis_cl_am2!0="lat"
eis_cl_am2&lat=eis_climo_am2&lat
eis_cl_am2!1="lon"
eis_cl_am2&lon=eis_climo_am2&lon
print("dimensions of eis_cl_am4 are: "+dimsizes(eis_cl_am4))
;***********************************************************************************
;
print("max of file1 lcloud feedbck: "+max(lcloud))
print("min of file1 lcloud feedbck: "+min(lcloud))
print("max of file1 hcloud feedbck: "+max(cre))
print("min of file1 hcloud feedbck: "+min(cre))
print("max of file1 omega feedbck: "+max(omega))
print("min of file1 omega feedbck: "+min(omega))
print("max of file1 swup_toa_clr feedbck: "+max(eis))
print("min of file1 swup_toa_clr feedbck: "+min(eis))
print("max of file1 tsfc : "+max(tsfc))
print("min of file1 tsfc : "+min(tsfc))
print("max of file1 LWP : "+max(lwp))
print("min of file1 LWP : "+min(lwp))
;
;***********************************************************************************
; compute lat weights to determine the global mn
;***********************************************************************************
lat  = f1->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
lcloud_wmn        =wgt_areaave(lcloud,clat,1.0,1)
cre_wmn        =wgt_areaave(cre,clat,1.0,1)
omega_wmn    =wgt_areaave(omega,clat,1.0,1)
eis_wmn     =wgt_areaave(eis,clat,1.0,1)
tsfc_wmn    =wgt_areaave(tsfc,clat,1.0,1)
lwp_wmn     =wgt_areaave(lwp,clat,1.0,1)
;ctl_tsurf_exp1 =wgt_areaave(ctl_t_surf,clat,1.0,1)
;wrm_tsurf_exp1 =wgt_areaave(wrm_t_surf,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(lcloud_wmn,2,True))
;l_title1=title1+" "+posh
l_title1=title1+" K"
posh=flt2string(decimalPlaces(cre_wmn,2,True))
;l_title2=title2+" "+posh
l_title2=title2+" K"
posh=flt2string(decimalPlaces(omega_wmn,2,True))
;l_title3=title3+" "+posh
l_title3=title3+" K"
posh=flt2string(decimalPlaces(eis_wmn,2,True))
;l_title4=title4+" "+posh
l_title4=title4+" K per 30 yr"
posh=flt2string(decimalPlaces(tsfc_wmn,2,True))
;l_title5=title5+" "+posh
l_title5=title5+" K per 30 yr"
posh=flt2string(decimalPlaces(lwp_wmn,2,True))
;l_title6=title6+" "+posh
l_title6=title6+" K per 30 yr"
;
print("************************************************")
print("global mean of first net lcloud rad is: "+lcloud_wmn)
print("global mean of first net cre is: "+cre_wmn)
print("global mean of first net omega: "+omega_wmn)
print("global mean of first net eis: "+eis_wmn)
print("global mean of first net tsfc: "+tsfc_wmn)
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
;my_levels_eis= (/-2.0,-1.5,-1.0,-0.5,0.,0.5,1.0,1.5,2.0/)
my_levels_eis= (/-1.0,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.0/)
my_levels_omega= (/-0.02,-0.015,-0.010,-0.005,0,0.005,0.01,0.015,0.02/)
;my_levels_lwp=(/-0.008,-0.006,-0.004,-0.002,0,0.002,0.004,0.006,0.008/)
my_levels_lwp=(/-8.,-6.,-4.,-2.,0,2.,4.,6.,8./)
my_levels_tsfc=(/-2.0,-1.5,-1.,-0.5,0,0.5,1.0,1.5,2.5/)
my_levels_eisclim= (/-2.,-1.,0.,1.,2.,3.,4.,5.,6./)
;
my_colors_olr = (/55, 60,  65, 70, 75, 80, 85, 90, 95,100,105/)
my_colors_swup = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
;my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_posneg = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
my_colors_posneg_lwp = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
my_colors_netcre = (/ 7, 2,74,77,80,83,86,89,92,95,100/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)
my_colors_eisclim= (/6,8,10,11,13,14,15,16,17,19,1/)

;************************************************
  wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  ;wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
  ;wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
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
  res@cnLevels          = my_levels_eisclim
  res@cnFillColors      = my_colors_eisclim
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
  res@tiMainString       = l_title1 
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour1 = gsn_csm_contour_map(wks,eis_cl_am4,res)  ; create the plot
  plot(0) = contour1

; row 2
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = l_title2 
  contour4 = gsn_csm_contour_map(wks,eis,res)  ; create the plot
  plot(1) = contour4

; row 3
  res@tiMainString       = l_title3 
  res@cnLevels          = my_levels_eisclim
  res@cnFillColors      = my_colors_eisclim
  contour7 = gsn_csm_contour_map(wks,eis_cl_am3,res)  ; create the plot
  plot(2) = contour7

; row 4
  res@tiMainString       = l_title4 
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,eis_tr_am3,res)  ; create the plot
  plot(3) = contour10

; row 5
  res@tiMainString       = l_title5 
  res@cnLevels          = my_levels_eisclim
  res@cnFillColors      = my_colors_eisclim
  contour13 = gsn_csm_contour_map(wks,eis_cl_am2,res)  ; create the plot
  plot(4) = contour13

; row 6
  res@tiMainString       = l_title6 
  ;res@lbOrientation            = "Vertical"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour16 = gsn_csm_contour_map(wks,eis_tr_am2,res)  ; create the plot
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

