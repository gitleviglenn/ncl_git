;******************************************************************************************
;Schematic_misr_am4vsobs.ncl 
;
; script to plot MISR data in satellite view
;
; the figure produced is determined based on the switches 'plot_map'                
;
; levi silvers                                               oct 2020
;******************************************************************************************


;******************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;******************************************************************************************

begin 

plot_map     = True 
;plot_profile = False

;=============input data=========================================================
  ; newer obs data from Roger Marchand:
  to_misr="/Users/silvers/data/SatData/MISR_fromRoj/MISR_CTH_OD_histograms_v7/"

  to_am4="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_200301-200812.nc"


; if looking at all years...
  ;;year="2008"
  obs_filein=to_misr+"clMISR_obs4MIPs_200003th201911.timemn.nc"
  ;maintitle="Years: 2000-2019"
  testmap ="Full_3doms_10lat35_120lon300"
  profname="Full_3doms_10lat35_120lon300_Prof"
;=============input data=========================================================
  
  obs_infile = addfile(obs_filein,"r")
  am4_infile = addfile(to_am4,"r")
  
  tau_obs =obs_infile->tau(:)
  vaxis1  =obs_infile->cth(:)
print("obs tau =: "+tau_obs)
  
  ob_varname="clMISR"
  
  t_full          =obs_infile->$ob_varname$(0,:,:,:,:)

  cl_am4_full         =am4_infile->clmisr(1,:,:,:,:)
;printVarSummary(cl_am4)

  t_full = lonPivot(t_full,0.5)
printVarSummary(t_full)
  t_a    = dim_sum_n_Wrap(t_full,0) ; height, lat,lon 
  t_am4_a= dim_sum_n_Wrap(cl_am4_full,0) ; sum over height
  t_am4_b= dim_sum_n_Wrap(t_am4_a,0) ; sum over tau
;  t_am4_c= dim_sum_n_Wrap(t_am4_b,0) ; sum over alt16
;printVarSummary(t_am4_c)
printVarSummary(t_a)
  t_b    = dim_sum_n_Wrap(t_a,0)
printVarSummary(t_b)
  
  t_b!0="lat"
  t_b!1="lon"
  t_b&lat=t_full&lat
  t_b&lon=t_full&lon

  t_c = new((/180,360/),"float")
  t_c = t_b@missing_value

  copy_VarCoords(t_b,t_c)
;  t_b = lonPivot(t_b,0.5)
;  t_c = lonPivot(t_c,0.5)
;printVarSummary(t_c)
  ;t_c(fd_lat1:fd_lat2,fd_lon1:fd_lon2)=t_b(fd_lat1:fd_lat2,fd_lon1:fd_lon2)
  t_c(:,:)=t_b(:,:)

;;------------------------------------------

; test plotting...
  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
  my_levels1 = (/5,10,20,30,40,50,60,70,80,90/) ; 10
  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11

if (plot_map) then
  ;wks = gsn_open_wks("eps",testmap)          ; send graphics to ps file
  wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
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
  resmap@mpProjection      = "Satellite"       ; choose projection
  resmap@mpCenterLonF      = 290;
  resmap@mpCenterLatF      = 30;
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

;;------------------------------------------
  ;contour = gsn_csm_contour_map(wks,t_c,resmap)  ; create the plot
  contour = gsn_csm_contour_map(wks,t_am4_b,resmap)  ; create the plot
  
  plot = contour
  ;draw(contour)
end if

;=====================

end 
