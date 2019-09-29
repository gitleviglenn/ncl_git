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
;***********************************************************************************
begin
;***********************************************************************************
; define directories, var names, and periods
; for incoming files
;***********************************************************************************
; 
;; for column on left of figure
;;
title1="LCC"
;  res@tiMainString       = "LCC ~ 3.7*EIS - 0.9*Tsfc"
title2="LCC ~ 3.7*EIS - 0.9*Tsfc"
title3="EIS ~ T700 - 1.2*Tsfc"
;  res@tiMainString       = "EIS ~ T700 - 1.2*Tsfc"
title4="EIS "
title5="Tsfc "
title6="T on 700 hPa "
;***********************************************************************************
;***********************************************************************************
;
;***********************************************************************************
; read in netCDF files for column on left; experiment one 
;***********************************************************************************
;
datapath="/net2/Levi.Silvers/data/amip_long/pp_files/"
period="late"
;period="early" 
;

;infile1="/home/lgs/am2_eiscl_trends_early.nc"
;infile1="/net2/Levi.Silvers/am4_trends_late.nc"
;infile1=datapath+"am4_trends_tref_"+period+"_crediff_4ens.nc"
infile1=datapath+"am2_trends_tref_late_pdown.nc"
infile2=datapath+"am2_trends_tref_early_pdown.nc"

;infile2="/net2/Levi.Silvers/am3_trends_late.nc"
;infile2=datapath+"am3_trends_tref_"+period+"_crediff.nc"
;infile2=datapath+"am3_trends_tsfc_"+period+"_pdown.nc"


f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
f2=addfile(infile2,"r")
print("incoming file is: "+infile2)

; from file 1
  lcloud_f1         = f1->lcloud_trend(:,:)    
  hcloud_f1         = f1->hcloud_trend(:,:)    
  cre_f1            = f1->hcloud_trend(:,:)  
  omega_f1          = f1->omega500_trend(:,:)     
  eis_f1            = f1->eis_trend(:,:)    
  tsfc_f1           = f1->tsurf_trend(:,:) 
  temp700_f1        = f1->temp700_trend(:,:) 
 ; lwp               = f1->lwp_trend(:,:) 
; from file 2
  lcloud_f2         = f2->lcloud_trend(:,:)    
  hcloud_f2         = f2->hcloud_trend(:,:)    
  cre_f2            = f2->hcloud_trend(:,:)  
  omega_f2          = f2->omega500_trend(:,:)     
  eis_f2            = f2->eis_trend(:,:)    
  tsfc_f2           = f2->tsurf_trend(:,:) 
  temp700_f2        = f2->temp700_trend(:,:) 
 ; lwp               = f2->lwp_trend(:,:) 
;;
;***********************************************************************************
;***********************************************************************************
;
lcloud=lcloud_f1
hcloud=hcloud_f1
cre=cre_f1
omega=omega_f1
eis=eis_f1
tsfc=tsfc_f1
temp700=temp700_f1
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
;print("max of file1 LWP : "+max(lwp))
;print("min of file1 LWP : "+min(lwp))
print("max of file1 temp700 : "+max(temp700))
print("min of file1 temp700 : "+min(temp700))
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
;lwp_wmn     =wgt_areaave(lwp,clat,1.0,1)
temp700_wmn     =wgt_areaave(temp700,clat,1.0,1)
;ctl_tsurf_exp1 =wgt_areaave(ctl_t_surf,clat,1.0,1)
;wrm_tsurf_exp1 =wgt_areaave(wrm_t_surf,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
;
posh=flt2string(decimalPlaces(lcloud_wmn,2,True))
;l_title1=title1+" "+posh
l_title1=title1+" (% per 30 yr)"
posh=flt2string(decimalPlaces(cre_wmn,2,True))
;l_title2=title2+" "+posh
l_title2=title2+" (% per 30 yr)"
posh=flt2string(decimalPlaces(omega_wmn,2,True))
;l_title3=title3+" "+posh
l_title3=title3+" (K per 30 yr)"
posh=flt2string(decimalPlaces(eis_wmn,2,True))
;l_title4=title4+" "+posh
l_title4=title4+" (K per 30 yr)"
posh=flt2string(decimalPlaces(tsfc_wmn,2,True))
;l_title5=title5+" "+posh
l_title5=title5+" (K per 30 yr)"
;posh=flt2string(decimalPlaces(lwp_wmn,2,True))
;l_title6=title6+" "+posh
l_title6=title6+" (K per 30 yr)"
;
print("************************************************")
print("global mean of first net lcloud rad is: "+lcloud_wmn)
print("global mean of first net cre is: "+cre_wmn)
print("global mean of first net omega: "+omega_wmn)
print("global mean of first net eis: "+eis_wmn)
print("global mean of first net tsfc: "+tsfc_wmn)
;print("global mean of first net lwp: "+lwp_wmn)
print("************************************************")
print("************************************************")
;
; conversions
;lwp=1000.*lwp
approx_eis=temp700-1.2*tsfc
approx_eis!0="lat"
approx_eis&lat=tsfc&lat
approx_eis!1="lon"
approx_eis&lon=tsfc&lon
;
approx_lcc=3.7*eis-0.9*tsfc
approx_lcc!0="lat"
approx_lcc&lat=tsfc&lat
approx_lcc!1="lon"
approx_lcc&lon=tsfc&lon
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

;;;;;------------------------------------------------------------------------------
;;;; use below for LCC/EIS plot 
;;;; row 1  
  ;res@tiMainString       = l_title1 
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour0 = gsn_csm_contour_map(wks,lcloud_f1,res)  ; create the plot
  plot(0) = contour0

  ;res@tiMainString       = l_title2 
  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour1 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(1) = contour1

  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  res@gsnTickMarksOn     = False
  contour2 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(2) = contour2

; row 2
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour3 = gsn_csm_contour_map(wks,lcloud_f1,res)  ; create the plot
  plot(3) = contour3

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis_
  res@cnFillColors      = my_colors_posneg
  contour4 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(4) = contour4

  res@tiMainString      = "AM2 HCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour5 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(5) = contour5

; row 3
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour6 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot(6) = contour6

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis_
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(7) = contour7

  res@tiMainString      = "AM2 HCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour8 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(8) = contour8

; row 4
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour9 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot(9) = contour9

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis_
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(10) = contour10

  res@tiMainString      = "AM2 HCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour11 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(11) = contour11

; row 5
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour12 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot(12) = contour12

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis_
  res@cnFillColors      = my_colors_posneg
  contour13 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(13) = contour13

  res@tiMainString      = "AM2 HCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour14 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(14) = contour14

; row 6
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour15 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot(15) = contour15

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis_
  res@cnFillColors      = my_colors_posneg
  contour16 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot(16) = contour16

  res@tiMainString      = "AM2 HCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour17 = gsn_csm_contour_map(wks,hcloud_f1,res)  ; create the plot
  plot(17) = contour17


;; row 6
;  ;res@tiMainString       = l_title6 
;  res@tiMainString       = "AM2 EIS (K per 30 yr)"
;  ;res@lbOrientation            = "Vertical"
;  res@cnLevels          = my_levels_eis
;  res@cnFillColors       = my_colors_posneg
;  contour16 = gsn_csm_contour_map(wks,eis_f2,res)  ; create the plot
;  plot(5) = contour16
;
;; row 7
;  ;res@tiMainString       = l_title6 
;  res@tiMainString       = "AM2 HCC (% per 30 yr)"
;  ;res@lbOrientation            = "Vertical"
;  res@cnLevels          = my_levels_simple
;  res@cnFillColors       = my_colors_posneg
;  contour16 = gsn_csm_contour_map(wks,hcloud_f2,res)  ; create the plot
;  plot(6) = contour16
;
;; row 8
;  ;res@tiMainString       = l_title6 
;  res@tiMainString       = "AM2 omega500 (Pa/s per 30 yr)"
;  ;res@lbOrientation            = "Vertical"
;  res@cnLevels          = my_levels_omega
;  res@cnFillColors       = my_colors_posneg
;  contour16 = gsn_csm_contour_map(wks,omega_f2,res)  ; create the plot
;  plot(7) = contour16
;;;------------------------------------------------------------------------------


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/6,3/),resP)

end

