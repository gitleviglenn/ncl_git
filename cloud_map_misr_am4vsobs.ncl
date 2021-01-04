;******************************************************************************************
;cloud_map_misr_am4vsobs.ncl 
;
; script to plot MISR data 
; produces either -global map showing the selected region or
;                 -a CF vs height figure
;
; the figure produced is determined based on the switches 'plot_map' and 'plot_profile'               
;
; levi silvers                                               sep 2020
;******************************************************************************************


;******************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;******************************************************************************************

begin 

plot_map     = False
plot_profile = True


; central pac
;lon1=150
;lon2=270
;lat1=80    ; 0 at NP
;lat2=100   ; 180 at SP

; latitudes to analyze
;fd_lat1=80    ; 0 at NP
;fd_lat2=100   ; 180 at SP
fd_lat1=80    ; 0 at NP        Schwendike et al. 2014 advocate for lat1=80; lat2=125
fd_lat2=125   ; 180 at SP

; full Walker Domain
fd_lon1=120
fd_lon2=300

; Subsidence Region
; lon 240-300 shows a low level peak greater than 15%
sub_lon1=240
sub_lon2=300

;; deep convective region
dc_lon1=120
dc_lon2=180


;=============input data=========================================================
  ; newer obs data from Roger Marchand:
  to_misr="/Users/silvers/data/SatData/MISR_fromRoj/MISR_CTH_OD_histograms_v7/"

; if looking at LaNina years....
  ;;year="LaNina"
  ;obs_filein=to_misr+"clMISR_obs4MIPs_tmn_LaNina.nc"
  ;;maintitle="LaNina Years: 00,07,08,11"
  ;testmap ="LaNina_10lat35_120lon300"
  ;profname="LaNina_10lat35_120lon300_Prof"

; if looking at all years...
  ;;year="2008"
  obs_filein=to_misr+"clMISR_obs4MIPs_200003th201911.timemn.nc"
  ;maintitle="Years: 2000-2019"
  testmap ="Full_3doms_10lat35_120lon300"
  profname="Full_3doms_10lat35_120lon300_Prof"
;=============input data=========================================================
  
  obs_infile = addfile(obs_filein,"r")
  
  tau_obs =obs_infile->tau(:)
  vaxis1  =obs_infile->cth(:)
print("obs tau =: "+tau_obs)
  
  ob_varname="clMISR"
  
  t_full          =obs_infile->$ob_varname$(0,:,:,:,:)
  t_full = lonPivot(t_full,0.5)
printVarSummary(t_full)
  t_a    = dim_sum_n_Wrap(t_full,0) ; height, lat,lon 
printVarSummary(t_a)
  t_b    = dim_sum_n_Wrap(t_a,0)
printVarSummary(t_b)
  
  t_b!0="lat"
  t_b!1="lon"
  t_b&lat=t_full&lat
  t_b&lon=t_full&lon

  t_c = new((/180,360/),"float")
  t_prof = new((/16,180,360/),"float")
  fullDom_prof = new((/16,180,360/),"float")
  dc_Dom_prof = new((/16,180,360/),"float")
  t_c = t_b@missing_value
  t_prof = t_b@missing_value
  fullDom_prof = t_b@missing_value
  dc_Dom_prof = t_b@missing_value
  copy_VarCoords(t_full,t_prof)
  copy_VarCoords(t_full,fullDom_prof)
  copy_VarCoords(t_full,dc_Dom_prof)
  t_prof(:,fd_lat1:fd_lat2,sub_lon1:sub_lon2)             =t_a(:,fd_lat1:fd_lat2,sub_lon1:sub_lon2)  
  fullDom_prof(:,fd_lat1:fd_lat2,fd_lon1:fd_lon2) =t_a(:,fd_lat1:fd_lat2,fd_lon1:fd_lon2)  
  dc_Dom_prof(:,fd_lat1:fd_lat2,dc_lon1:dc_lon2)  =t_a(:,fd_lat1:fd_lat2,dc_lon1:dc_lon2)  

  copy_VarCoords(t_b,t_c)
;  t_b = lonPivot(t_b,0.5)
;  t_c = lonPivot(t_c,0.5)
;printVarSummary(t_c)
  ;t_c(fd_lat1:fd_lat2,fd_lon1:fd_lon2)=t_b(fd_lat1:fd_lat2,fd_lon1:fd_lon2)
  t_c(:,:)=t_b(:,:)

;------------------------------------------
; compute cosine weighted mean value for the profiles...
lat  = obs_infile->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)

field_obs_gmn           = wgt_areaave(t_prof,clat,1.0,0)
full_field_obs_gmn      = wgt_areaave(fullDom_prof,clat,1.0,0)
dc_field_obs_gmn        = wgt_areaave(dc_Dom_prof,clat,1.0,0)
print("weighted mean values: "+field_obs_gmn)
print("full domain weighted mean values: "+field_obs_gmn)
;
;------------------------------------------

; test plotting...
  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
  my_levels1 = (/5,10,20,30,40,50,60,70,80,90/) ; 10
  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11

if (plot_map) then
  wks = gsn_open_wks("eps",testmap)          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"MPL_YlGnBu")
  
  plot = new(1,graphic)

  resmap                   = True
;  ;resmap@mpProjection      = "Mollweide"       ; choose projection
;  resmap@mpProjection      = "Robinson"       ; choose projection
;  resmap@mpCenterLonF      = 180;
  resmap@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  resmap@mpPerimOn         = False             ; turn off box around plot
  resmap@mpGridLatSpacingF = 30.               ; spacing for lat lines
  resmap@mpGridLonSpacingF = 30.               ; spacing for lon lines
  resmap@mpFillOn          = False

  resmap@mpMinLatF            = -35      ; range to zoom in on
  resmap@mpMaxLatF            =  10.
  resmap@mpMinLonF            =  120.
  resmap@mpMaxLonF            =  300.
  resmap@mpCenterLonF         = 210;
  resmap@mpCenterLatF         = 0;

;; below plots a satellite like view.  it looks good, but is too small for 180 of longitude.
;  resmap@mpProjection      = "Satellite"       ; choose projection
;  resmap@mpCenterLonF      = 210;
;  resmap@mpCenterLatF      = 0;
;  resmap@mpLimitMode       = "LatLon"
;  resmap@mpMinLatF         = -35
;  resmap@mpMaxLatF         = 10
;  resmap@mpMinLonF         = 120
;  resmap@mpMaxLonF         = 300

;   resmap@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
   resmap@tmXBOn                  = False
;   resmap@tmXTMode                = "Explicit"
;   resmap@tmXTValues              = (/"135 E","180","135 W","90 W"/)
   resmap@tmXTOn                  = True
;   resmap@tmXUseBottom            = False
   resmap@tmXTMinorOn             = False
   resmap@tmXTLabelsOn            = True
   resmap@tmXTLabelFontHeightF    = 0.15
   resmap@tmYLLabelFontHeightF    = 0.015


; these commands turn off/on the varname and units at top of image
  resmap@gsnLeftString = ""
  resmap@gsnRightString = ""

  resmap@cnFillOn          = True              ; color plot desired
;  resmap@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  resmap@cnLineLabelsOn    = False             ; turn off contour lines
  resmap@cnLevelSelectionMode  = "ExplicitLevels"
  resmap@cnLevels          = my_levels1
  resmap@cnLinesOn         = False
  resmap@cnFillColors      = my_colors
  resmap@txFontHeightF     = 0.015

  resmap@vpXF            = 0.1                 ; make plot bigger
  resmap@vpYF            = 0.9

  resmap@vpWidthF        = 0.7
  resmap@vpHeightF       = 0.4

  resmap@lbLabelFontHeightF  = 0.015           ; label bar font height
  resmap@lbTitleString       = "%"
  resmap@lbTitlePosition     = "Bottom"
  resmap@lbTitleFontHeightF  = 0.02

  ;resmap@tiMainString       = maintitle  ; add a title
  resmap@tiMainString       = " "; add a title
  resmap@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t_c,resmap)  ; create the plot
  
;  gnres                   = True
;  gnres@gsFillColor       = "white"
;  gnres@gsLineThicknessF  = 20.0
;  gnres@gsFillOpacityF    = 0.0
;  gnres@gsEdgesOn         = True
;  gnres@gsLineThicknessF  = 4.0

;  ;latbox1=(/-10.,-10.,10.,10.,-10./)
;  ;lonbox1=(/240.,240.,300.,300.,240./)
;  ;latbox1=(/-10.,-10.,10.,10./)
;  ;lonbox1=(/240.,240.,300.,300./)
;  latbox1=(/10.,10.,-10.,-10./)
;  lonbox1=(/240.,240.,300.,300./)
;
;  ;dum1c=gsn_add_polygon(wks, contour, lonbox1, latbox1, gnres)
;  dum1c=gsn_add_polygon(wks, contour, lonbox1, latbox1, gnres)

  plot = contour
  ;draw(contour)
end if

;=====================
if (plot_profile) then
  wks = gsn_open_wks("eps",profname)
  plot = new(1,graphic)

  xtitle = "Cloud Fraction (%)"
  ytitle = "height (km)"

  res                   = True
  res@tiMainString      = " "
  res@gsnDraw           = False
  res@gsnFrame          = False
  res@tmYROn            = False
  res@tmXTOn            = False
  res@tmYRBorderOn      = False
  res@tmXTBorderOn      = False
  res@tiXAxisString     = xtitle
  res@tiYAxisString     = ytitle
  res@vpWidthF          = 0.45
  res@vpHeightF         = 0.45
  res@xyLineThicknessF  = 4.0
  res@trXMinF           = 0.0
  res@trXMaxF           = 20.0
  res@trYMinF           = 0.0
  res@trYMaxF           = 16000.0
    res@xyDashPattern = 0
    plot_obs  = gsn_csm_xy(wks,field_obs_gmn(1:14),vaxis1(1:14)/1000,res)
    res@xyDashPattern = 16 
    plot_fd_obs  = gsn_csm_xy(wks,full_field_obs_gmn(1:14),vaxis1(1:14)/1000,res)
    res@xyDashPattern = 3 
    plot_dc_obs  = gsn_csm_xy(wks,dc_field_obs_gmn(1:14),vaxis1(1:14)/1000,res)
    overlay(plot_obs,plot_fd_obs)
    overlay(plot_obs,plot_dc_obs)
  plot       = plot_obs

  lgres                      = True
  lgres@lgLineColors         = (/"black","black","black"/)
;  lgres@xyLabelMode          = "Custom"
  lgres@xyLineLabelFontHeightF = 0.020                ; font height
  lgres@lgItemType           = "Lines"
  lgres@lgLineLabelsOn       = False             ; turn off line labels
  lgres@lgLabelFontHeightF   = .12
  lgres@vpWidthF             = 0.23        ; width of legend
  lgres@vpHeightF            = 0.20        ; height of legend
  lgres@lgLineThicknessF     = 4.0
  ;lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False 
  lgres@lgDashIndexes          = (/"0","16","3"/)
  lgres@lgPerimOn            = False
 
  legend  = gsn_create_legend (wks, 3, (/"Subsidence","Domain Mean","Deep Convection"/), lgres)

  resP                 = True
  resP@amJust = "TopRight"
  resP@amOrthogonalPosF = -0.5     ; Move legend down more negative moves higher
  resP@amParallelPosF   = 0.4    ; Move legend to right

  annoid = gsn_add_annotation(plot,legend,resP) ; add legend to plot

  respanel   = True
  gsn_panel(wks,plot,(/1,1/),respanel)
end if

;maximize_output(wks,True)

end 
