;***********************************************************************************
; lccts_1panel.ncl
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
datapath="~/data/amip_Long/"
;datapath="/net2/Levi.Silvers/data/amip_long/pp_files/"
period="late"
;period="early" 
;


infile_eis=datapath+"lcc_mlr_eis_pm60.nc"
infile_eis=datapath+"lcc_mlr_eis_pm30.nc"


feis=addfile(infile_eis,"r")
print("incoming file is: "+infile_eis)

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

;;************************************************
  ;wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file
  gsn_define_colormap(wks,"BlueDarkRed18")
  plot3 = new(1,graphic)
;
;
;;;;;------------------------------------------------------------------------------
; next lines are a test for time series plot to add...
am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"
;
length=0.50
height=0.25

res4                   = True
res4@trXMinF           = 1875
res4@trXMaxF           = 2000
res4@tiYAxisFontHeightF = 0.012
res4@tiYAxisString    = "Anomalous LCC (%)"
res4@tiXAxisString    = "Year"
res4@tmYROn            = False
res4@tmXTOn            = False
res4@tmXTBorderOn      = False
res4@tmYRBorderOn      = False
res4@gsnDraw           = True; default: T
res4@gsnFrame          = False; default: T

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
lgres@lgLabelFontHeightF   = .08
lgres@vpWidthF             = 0.12        ; width of legend
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

plot3 = am2_lcc_cloud

;;;;;;------------------------------------------------------------------------------

maximize_output(wks,True) ; needed to print legend
;frame(wks)

end

