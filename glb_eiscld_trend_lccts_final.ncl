;***********************************************************************************
; glb_eiscld_trend_lccts.ncl
;***********************************************************************************
;
; create 3 groups of panels, first the time series, then lcc, then eis, 
; the lcc and eis must have separate colorbars
;
; levi silvers                         aug 2017 
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
datapath="~/data/amip_Long/data_from_2017/"
;datapath="/net2/Levi.Silvers/data/amip_long/pp_files/"
period="late"
;period="early" 
;

infile1=datapath+"am2_trends_tref_late_pdown.nc"
infile2=datapath+"am2_trends_tref_early_pdown.nc"
infile3=datapath+"am3_trends_tref_late_pdown.nc"
infile4=datapath+"am3_trends_tref_early_pdown.nc"
infile5=datapath+"am4_trends_tref_late_pdown.nc"
infile6=datapath+"am4_trends_tref_early_pdown.nc"

;infile1=datapath+"am4_trends_tsfc_late_pdown.nc"
;infile2=datapath+"am4_trends_tsfc_early_pdown.nc"
;infile3=datapath+"am4_trends_tsfc_late_pdown.nc"
;infile4=datapath+"am4_trends_tsfc_early_pdown.nc"
;infile5=datapath+"am4_trends_tsfc_late_pdown.nc"
;infile6=datapath+"am4_trends_tsfc_early_pdown.nc"

infile_eis=datapath+"lcc_mlr_eis_pm60.nc"

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

feis=addfile(infile_eis,"r")
print("incoming file is: "+infile_eis)

; from file 1
  lcloud_f1         = f1->lcloud_trend(:,:)    
  hcloud_f1         = f1->hcloud_trend(:,:)    
  cre_f1            = f1->hcloud_trend(:,:)  
  omega_f1          = f1->omega500_trend(:,:)     
  eis_f1            = f1->eis_trend(:,:)    
  tsfc_f1           = f1->tsurf_trend(:,:) 
  temp700_f1        = f1->temp700_trend(:,:) 
; from file 2
  lcloud_f2         = f2->lcloud_trend(:,:)    
  hcloud_f2         = f2->hcloud_trend(:,:)    
  cre_f2            = f2->hcloud_trend(:,:)  
  omega_f2          = f2->omega500_trend(:,:)     
  ;eis_f2            = f2->eis_trend(:,:)    
  eis_f2            = f2->eis_trend(:,:)    
  tsfc_f2           = f2->tsurf_trend(:,:) 
  temp700_f2        = f2->temp700_trend(:,:) 
; from file 3
  lcloud_f3         = f3->lcloud_trend(:,:)    
  hcloud_f3         = f3->hcloud_trend(:,:)    
  cre_f3            = f3->hcloud_trend(:,:)  
  omega_f3          = f3->omega500_trend(:,:)     
  eis_f3            = f3->eis_trend(:,:)    
  tsfc_f3           = f3->tsurf_trend(:,:) 
  temp700_f3        = f3->temp700_trend(:,:) 
; from file 4
  lcloud_f4         = f4->lcloud_trend(:,:)    
  hcloud_f4         = f4->hcloud_trend(:,:)    
  cre_f4            = f4->hcloud_trend(:,:)  
  omega_f4          = f4->omega500_trend(:,:)     
  eis_f4            = f4->eis_trend(:,:)    
  tsfc_f4           = f4->tsurf_trend(:,:) 
  temp700_f4        = f4->temp700_trend(:,:) 
; from file 5
  lcloud_f5         = f5->lcloud_trend(:,:)    
  hcloud_f5         = f5->hcloud_trend(:,:)    
  cre_f5            = f5->hcloud_trend(:,:)  
  omega_f5          = f5->omega500_trend(:,:)     
  eis_f5            = f5->eis_trend(:,:)    
  tsfc_f5           = f5->tsurf_trend(:,:) 
  temp700_f5        = f5->temp700_trend(:,:) 
; from file 6
  lcloud_f6         = f6->lcloud_trend(:,:)    
  hcloud_f6         = f6->hcloud_trend(:,:)    
  cre_f6            = f6->hcloud_trend(:,:)  
  omega_f6          = f6->omega500_trend(:,:)     
  eis_f6            = f6->eis_trend(:,:)    
  tsfc_f6           = f6->tsurf_trend(:,:) 
  temp700_f6        = f6->temp700_trend(:,:) 
;;
;; if lts is the desired variable to plot...
;  eis_f1            = f1->lts_trend(:,:)    
;  eis_f2            = f2->lts_trend(:,:)    
;  eis_f3            = f3->lts_trend(:,:)    
;  eis_f4            = f4->lts_trend(:,:)    
;  eis_f5            = f5->lts_trend(:,:)    
;  eis_f6            = f6->lts_trend(:,:)    
am2_lcc            = feis->am2_lcc_smooth(:)
am3_lcc            = feis->am3_lcc_smooth(:)
am4_lcc            = feis->am4_lcc_smooth(:)
am2_app_lcc            = feis->am2_applcc_smooth(:)
am3_app_lcc            = feis->am3_applcc_smooth(:)
am4_app_lcc            = feis->am4_applcc_smooth(:)
am2_sst_scaled            = feis->am2_sst_scaled(:)
am3_sst_scaled            = feis->am3_sst_scaled(:)
am4_sst_scaled            = feis->am4_sst_scaled(:)
time               = feis->TIME(:) 
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
lat_am2  = f1->lat
lon_am2  = f1->lon
lat_am3  = f3->lat
lon_am3  = f3->lon
lat_am4  = f5->lat
lon_am4  = f5->lon
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
lcloud_wmn        =wgt_areaave(lcloud,clat,1.0,1)
cre_wmn        =wgt_areaave(cre,clat,1.0,1)
omega_wmn    =wgt_areaave(omega,clat,1.0,1)
eis_wmn     =wgt_areaave(eis,clat,1.0,1)
tsfc_wmn    =wgt_areaave(tsfc,clat,1.0,1)
temp700_wmn     =wgt_areaave(temp700,clat,1.0,1)
;***********************************************************************************
;***********************************************************************************
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
; apply land mask

a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm_am2=landsea_mask(lsdata,lat_am2,lon_am2)
lsm_am3=landsea_mask(lsdata,lat_am3,lon_am3)
lsm_am4=landsea_mask(lsdata,lat_am4,lon_am4)

lcloud_f6=mask(lcloud_f6,lsm_am4.ge.1,False)
lcloud_f5=mask(lcloud_f5,lsm_am4.ge.1,False)
hcloud_f6=mask(hcloud_f6,lsm_am4.ge.1,False)
hcloud_f5=mask(hcloud_f5,lsm_am4.ge.1,False)
eis_f6=mask(eis_f6,lsm_am4.ge.1,False)
eis_f5=mask(eis_f5,lsm_am4.ge.1,False)

lcloud_f4=mask(lcloud_f4,lsm_am3.ge.1,False)
lcloud_f3=mask(lcloud_f3,lsm_am3.ge.1,False)
hcloud_f4=mask(hcloud_f4,lsm_am3.ge.1,False)
hcloud_f3=mask(hcloud_f3,lsm_am3.ge.1,False)
eis_f4=mask(eis_f4,lsm_am3.ge.1,False)
eis_f3=mask(eis_f3,lsm_am3.ge.1,False)

lcloud_f2=mask(lcloud_f2,lsm_am2.ge.1,False)
lcloud_f1=mask(lcloud_f1,lsm_am2.ge.1,False)
hcloud_f2=mask(hcloud_f2,lsm_am2.ge.1,False)
hcloud_f1=mask(hcloud_f1,lsm_am2.ge.1,False)
eis_f2=mask(eis_f2,lsm_am2.ge.1,False)
eis_f1=mask(eis_f1,lsm_am2.ge.1,False)


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
  ;wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file
  ;wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"BlueDarkRed18")
  plot1 = new(6,graphic)
  plot2 = new(6,graphic)
  plot3 = new(1,graphic)

  res                   = True
  res@cnLinesOn         = False
  ;res@lbOrientation     = "Vertical"
  res@gsnPaperOrientation = "portrait" 
  res@mpProjection      = "Robinson"       ; choose projection
  ;res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpCenterLonF      = 200.
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
  res@lbLabelBarOn       = False
  ;res@lbLabelBarOn       = True

  ;res@tiMainString       = maintitle  ; add a title
  res@tiMainFontHeightF  = .023                               ; font height

;;;;;------------------------------------------------------------------------------
;;;; use below for LCC/EIS plot 
;;;; row 1  
  res@gsnTickMarksOn     = False

;;;;;------------------------------------------------------------------------------
; next lines are a test for time series plot to add...
am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"
;
length=0.50
;length=0.40
height=0.25
;height=0.15

res4                   = True
res4@trXMinF           = 1875
res4@trXMaxF           = 2000
res4@tiYAxisFontHeightF = 0.012
res4@tiYAxisString    = "Anomalous LCC (%)"
;res4@tiXAxisString    = "Year"
res4@tiXAxisString    = ""
res4@tmYROn            = False
res4@tmXTOn            = False
res4@tmXTBorderOn      = False
res4@tmYRBorderOn      = False
res4@gsnDraw           = False ; default: T
res4@gsnFrame          = False ; default: T

res4@xyLineThicknessF   = 2.0
res4@trYMinF           = -0.4
res4@trYMaxF           = 0.4

res4@vpWidthF          = length
res4@vpHeightF         = height

;res4@vpWidthF          = .81
;res4@vpHeightF         = .5
;res4@vpWidthF          = .95
;res4@vpHeightF         = .3

res4@xyLineColors  = am2line
res4@xyLineThicknessF   = 3.0
am2_lcc_cloud   = gsn_csm_xy(wks,time,am2_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am2_alcc_cloud  = gsn_csm_xy(wks,time,am2_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am2_sst         = gsn_csm_xy(wks,time,am2_sst_scaled(:),res4) ; create filled xy plot
res4@xyLineColors  = am3line
res4@xyLineThicknessF   = 3.0
res4@xyDashPattern = 0
am3_lcc_cloud   = gsn_csm_xy(wks,time,am3_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am3_alcc_cloud  = gsn_csm_xy(wks,time,am3_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am3_sst         = gsn_csm_xy(wks,time,am3_sst_scaled(:),res4) ; create filled xy plot
res4@xyLineColors  = am4line
res4@xyLineThicknessF   = 3.0
res4@xyDashPattern = 0
am4_lcc_cloud   = gsn_csm_xy(wks,time,am4_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am4_alcc_cloud  = gsn_csm_xy(wks,time,am4_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am4_sst         = gsn_csm_xy(wks,time,am4_sst_scaled(:),res4) ; create filled xy plot

overlay(am2_lcc_cloud,am2_alcc_cloud)
overlay(am2_lcc_cloud,am2_sst)
overlay(am2_lcc_cloud,am3_lcc_cloud)
overlay(am2_lcc_cloud,am3_alcc_cloud)
overlay(am2_lcc_cloud,am3_sst)
overlay(am2_lcc_cloud,am4_lcc_cloud)
overlay(am2_lcc_cloud,am4_alcc_cloud)
overlay(am2_lcc_cloud,am4_sst)

ltitle3="  GFDL AM4.0"
ltitle2="  GFDL AM3"
ltitle1="  GFDL AM2.1"
lthick=3.0

colors1 = (/am2line,am3line,am4line/) 

; crap for the legend
lgres                      = True
lgres@xyLabelMode            = "Custom"
lgres@xyLineLabelFontHeightF = 0.015                ; font height
lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2)/)
lgres@lgItemType           = "Lines"
;lgres@lgLabelFontHeightF   = .10
lgres@lgLabelFontHeightF   = .08
lgres@vpWidthF             = 0.12        ; width of legend
;lgres@vpHeightF            = 0.18        ; height of legend
lgres@vpHeightF            = 0.1        ; height of legend
lgres@lgLineThicknessF     = lthick
lgres@lgPerimThicknessF    = 2.0
lgres@lgMonoDashIndex      = False
lgres@lgDashIndexes          = (/"0","0","0"/)
lgres@lgPerimOn            = False


labels = (/ltitle1,ltitle2,ltitle3/)
legend  = gsn_create_legend (wks, 3, labels, lgres)
amres = True
amres@amJust = "BottomRight"
;amres@amJust = "TopRight"
amres@amParallelPosF   = 0.44    ; Move legend to right
;amres@amOrthogonalPosF = 0.47     ; Move legend down
amres@amOrthogonalPosF = -0.05     ; Move legend down

annoid = gsn_add_annotation(am2_lcc_cloud,legend,amres) ; add legend to plot

plot3(0) = am2_lcc_cloud

;;;;;------------------------------------------------------------------------------

  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour0 = gsn_csm_contour_map(wks,lcloud_f2,res)  ; create the plot
  plot1(0) = contour0

  res@tiMainString      = "AM3 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour1 = gsn_csm_contour_map(wks,lcloud_f4,res)  ; create the plot
  plot1(1) = contour1

  res@tiMainString      = "AM4 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  ;res@mpMajorLatSpacingF  = 45
  contour2 = gsn_csm_contour_map(wks,lcloud_f6,res)  ; create the plot
  plot1(2) = contour2

; row 2
  res@tiMainString      = "AM2 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
;  res@lbLabelBarOn       = True
  contour6 = gsn_csm_contour_map(wks,lcloud_f1,res)  ; create the plot
  plot1(3) = contour6

  res@tiMainString      = "AM3 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour7 = gsn_csm_contour_map(wks,lcloud_f3,res)  ; create the plot
  plot1(4) = contour7

  res@tiMainString      = "AM4 LCC (% per 30 yr)"
  res@cnLevels          = my_levels_simple
  res@cnFillColors      = my_colors_posneg
  contour8 = gsn_csm_contour_map(wks,lcloud_f5,res)  ; create the plot
  plot1(5) = contour8

; row 3

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour3 = gsn_csm_contour_map(wks,eis_f2,res)  ; create the plot
  plot2(0) = contour3

  res@tiMainString       = "AM3 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour4 = gsn_csm_contour_map(wks,eis_f4,res)  ; create the plot
  plot2(1) = contour4

  res@tiMainString       = "AM4 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour5 = gsn_csm_contour_map(wks,eis_f6,res)  ; create the plot
  plot2(2) = contour5

; row 4

  res@tiMainString       = "AM2 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour9 = gsn_csm_contour_map(wks,eis_f1,res)  ; create the plot
  plot2(3) = contour9

  res@tiMainString       = "AM3 EIS (K per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour10 = gsn_csm_contour_map(wks,eis_f3,res)  ; create the plot
  plot2(4) = contour10

  res@tiMainString      = "AM4 EIS (% per 30 yr)"
  res@cnLevels          = my_levels_eis
  res@cnFillColors      = my_colors_posneg
  contour11 = gsn_csm_contour_map(wks,eis_f5,res)  ; create the plot
  plot2(5) = contour11


;;;------------------------------------------------------------------------------

;---Resources for paneling
    pres                   = True              ; modify the panel plot
    pres@gsnPanelMainString= "fyrname"
    pres@gsnPaperOrientation = "portrait" 
    pres@gsnFrame          = False             ; don't advance frame yet
    pres@gsnDraw           = False             ; draw later, in maximize mode
    pres@gsnPanelTop        = 0.95
    ;pres@gsnPanelBottom     = 0.70
    pres@gsnPanelBottom     = 0.65

    pres@gsnPanelLabelBar  = True              ; add common colorbar
    pres@lbOrientation     = "vertical"
    pres@pmLabelBarWidthF  = 0.075             ; make thinner
    pres@pmLabelBarHeightF = 0.25

    pres@gsnPanelFigureStrings=(/"a)"/)
    pres@amJust="TopLeft"

  ;panelid0 = gsn_panel_return(wks,plot3,(/1,1/),pres)
  panelid1 = gsn_panel_return(wks,plot1,(/2,3/),pres)

    ;pres@gsnPanelTop        = 0.77
    ;pres@gsnPanelBottom     = 0.41
    pres@gsnPanelTop        = 0.65
    pres@gsnPanelBottom     = 0.35

    pres@gsnPanelFigureStrings=(/""/)

  ;panelid1 = gsn_panel_return(wks,plot1,(/2,3/),pres)
  panelid2 = gsn_panel_return(wks,plot2,(/2,3/),pres)

;---Calculate location for top of difference plots
    bb     = NhlGetBB(panelid1)
    bottom = min(bb(:,1))
    top    = max(bb(:,0))
    height = (top-bottom)/2.     ; Height of one row

;---Panel the diff plots at the bottom
    delete(pres@gsnPanelMainString)
    ;pres@gsnPanelTop        = 0.41
    pres@gsnPanelTop        = 0.30
    pres@gsnPanelBottom     = 0.05

    pres@pmLabelBarHeightF = 0.25  
;    pres@gsnPanelFigureStrings=(/"a)","b)"/)
;    pres@amJust="TopLeft"
    pres@gsnPanelFigureStrings=(/"b)"/)
    pres@amJust="TopLeft"

  ;panelid2 = gsn_panel_return(wks,plot2,(/2,3/),pres)
  panelid0 = gsn_panel_return(wks,plot3,(/1,1/),pres)

  maximize_output(wks,True)

end

