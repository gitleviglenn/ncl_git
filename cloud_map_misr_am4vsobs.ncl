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

plot_map     = True
plot_profile = False 

  ; newer obs data from Roger Marchand:
  to_misr="/Users/silvers/data/SatData/MISR_fromRoj/MISR_CTH_OD_histograms_v7/"
  obs_filein=to_misr+"clMISR_obs4MIPs_200003th201911.timemn.nc"
  
  obs_infile = addfile(obs_filein,"r")
  
  tau_obs =obs_infile->tau(:)
  vaxis1  =obs_infile->cth(:)
print("obs tau =: "+tau_obs)
  
  ob_varname="clMISR"
  
  t_full          =obs_infile->$ob_varname$(0,:,:,:,:)
  t_full = lonPivot(t_full,0.5)
;printVarSummary(t_full)
  t_a    = dim_sum_n_Wrap(t_full,0) ; height, lat,lon 
  t_b    = dim_sum_n_Wrap(t_a,0)
  
  t_b!0="lat"
  t_b!1="lon"
  t_b&lat=t_full&lat
  t_b&lon=t_full&lon

  t_c = new((/180,360/),"float")
  t_prof = new((/16,180,360/),"float")
  t_c = t_b@missing_value
  t_prof = t_b@missing_value
  copy_VarCoords(t_full,t_prof)
  t_prof(:,80:125,120:300)=t_a(:,80:125,120:300)  

  copy_VarCoords(t_b,t_c)
;  t_b = lonPivot(t_b,0.5)
;  t_c = lonPivot(t_c,0.5)
;printVarSummary(t_c)
  t_c(80:125,120:300)=t_b(80:125,120:300)

;------------------------------------------
; compute cosine weighted mean value for the profiles...
lat  = obs_infile->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)

field_obs_gmn           = wgt_areaave(t_prof,clat,1.0,0)
print("weighted mean values: "+field_obs_gmn)
;
;------------------------------------------

; test plotting...
  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
  my_levels1 = (/5,10,20,30,40,50,60,70,80,90/) ; 10
  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11

if (plot_map) then
  wks = gsn_open_wks("eps","testmap")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"MPL_YlGnBu")

  resmap                   = True
  ;resmap@mpProjection      = "Mollweide"       ; choose projection
  resmap@mpProjection      = "Robinson"       ; choose projection
  resmap@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  resmap@mpPerimOn         = False             ; turn off box around plot
  resmap@mpGridLatSpacingF = 30.               ; spacing for lat lines
  resmap@mpGridLonSpacingF = 30.               ; spacing for lon lines
  resmap@mpFillOn          = False

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
  resmap@mpCenterLonF      = 180;

  resmap@vpXF            = 0.1                 ; make plot bigger
  resmap@vpYF            = 0.9
  resmap@vpWidthF        = 0.8
  resmap@vpHeightF       = 0.8

  resmap@lbLabelFontHeightF  = 0.015           ; label bar font height

  resmap@tiMainString       = "maintitle"  ; add a title
  resmap@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t_c,resmap)  ; create the plot
end if

;=====================
if (plot_profile) then
  wks = gsn_open_wks("eps","lostplot")
  plot = new(1,graphic)

  xtitle = "Cloud Fraction (%)"
  ytitle = "height (km)"

  res                   = True
  res@tiMainString      = "Profile of Cloud Fraction"
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
  res@xyLineThicknessF  = 2.0
  res@trXMinF           = 0.0
  res@trXMaxF           = 15.0
  res@trYMinF           = 0.0
  res@trYMaxF           = 16000.0
;    res@xyDashPattern = 16 
;    plot_am4  = gsn_csm_xy(wks,blabichra(:),vaxis1(:)/1000,res)
    res@xyDashPattern = 0
    plot_obs  = gsn_csm_xy(wks,field_obs_gmn(1:14),vaxis1(1:14)/1000,res)
  plot       = plot_obs
  respanel   = True
  gsn_panel(wks,plot,(/1,1/),respanel)
end if

end 
