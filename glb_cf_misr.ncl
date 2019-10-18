;***********************************************************************************
; glb_cf_misr.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the misr cosp tool.
;
; example here is for clouds below 3km with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; in general the tau levels in misr are:
; 0.15,0.8,2.45,6.5,16.2,41.5,100.

; the dimensions of clmisr are: 
; clmisr(time, tau, alt16, lat, lon) ;
;
; data from gfdl is on a 180x288 grid while observational data from 
; misr is on a 180x360 grid so we need to interpolate the gfdl data to 180x360
;
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							oct 2019
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************************************************
begin
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; read in netCDF files
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ;dirin="/work/Levi.Silvers/moddata/misr_am4g10r8_taugt0p3/"
  dirin="/Users/silvers/data/cfmip_clouds/"
  ;infile=dirin+"atmos_month_misr_mtime_under3km_tau_mn_final.nc"
  infile=dirin+"clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_199701-200212.nc"
  infile_obs="/Users/silvers/data/obs/clMISR_obs4MIPS_20000601_20130531_tmn.nc"
  maintitle_top="MISR cloud fraction for thick clouds"
  maintitle_bot="MISR cloud fraction for thin clouds"
  a = addfile(infile,"r")
  m_obs = addfile(infile_obs,"r")

; for the moment don't worry about this part, it just slows ncl down.
;  ;fils = systemfunc ("ls "+dirin+"clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_*.nc")
;  fils = systemfunc ("ls "+dirin+"clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_199*.nc")
;  b = addfiles(fils,"r")
;
print("infile for am4 data is: "+infile)
print("infile for misr observations is: "+infile_obs)
;

; define variable names to read from files
  var2read="clmisr"
  var_obs="clMISR"

;  cfrac_tot  = b[:]->clmisr
;  ;cfrac_tot  = b->$var2read$(:,:,:,:,:)  
;
  cfrac_thin  = a->$var2read$(:,1:2,:,:,:) ; for thin clouds      
  cfrac_thick = a->$var2read$(:,3:6,:,:,:) ; for thicker clouds      
;
;  cfrac_tot_tmn=dim_avg_n(cfrac_tot,0)

  cfrac_misr_thin  = m_obs->$var_obs$(0,1:2,:,:,:) ; for thin clouds      
  cfrac_misr_thick = m_obs->$var_obs$(0,3:6,:,:,:) ; for thicker clouds      

;print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
;print("dimensions of cfrac_tot are: "+dimsizes(cfrac_tot))
;print("dimensions of cfrac_tot_tmn are: "+dimsizes(cfrac_tot_tmn))
;  cfrac_tot_thin  = cfrac_tot(:,1:2,:,:,:) ; for thin clouds      
;  cfrac_tot_thick = cfrac_tot(:,3:6,:,:,:) ; for thick clouds      
;  
;print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; compute averages and sums

; am4 data
  cfrac_thick_tmn       =dim_avg_n(cfrac_thick,0)
  cfrac_thin_tmn        =dim_avg_n(cfrac_thin,0)

  cfrac_tmn_totz        =dim_sum_n(cfrac_thick_tmn,1)
  cfrac_tmn_totz_thick  =dim_sum_n(cfrac_tmn_totz,0)
  cfrac_thin_tmn_totz   =dim_sum_n(cfrac_thin_tmn,1)
  cfrac_tmn_totz_thin   =dim_sum_n(cfrac_thin_tmn_totz,0)

; misr observations
  cfrac_thin_misr_totz  =dim_sum_n(cfrac_misr_thin,1)
  cfrac_thick_misr_totz =dim_sum_n(cfrac_misr_thick,1)
  cfrac_thin_misr       =dim_sum_n(cfrac_thin_misr_totz,0)
  cfrac_thick_misr      =dim_sum_n(cfrac_thick_misr_totz,0)

;print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
;print("dimensions of cfrac_thin are: "+dimsizes(cfrac_thin))
;print("dimensions of cfrac_tmn are: "+dimsizes(cfrac_tmn))
;print("dimensions of misr cfrac are: "+dimsizes(cfrac_misr_thin))

print("dimensions of am4 cfrac sum over z time and tau are: "+dimsizes(cfrac_tmn_totz_thin))
print("dimensions of misr cfrac sum over z and tau are: "+dimsizes(cfrac_thin_misr))

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;***********************************************************************************
; interpolate gfdl data to a 180x360 degree grid

var_to_interpolate=cfrac_tmn_totz_thin

var_to_interpolate!0="lat"
var_to_interpolate&lat=cfrac_thin&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=cfrac_thin&lon

dimgfdl=dimsizes(var_to_interpolate)
print("dims of variable before interpolation: "+dimgfdl)

nlat=dimgfdl(0)
nlon=dimgfdl(1)

nlati=180 ; number of input latitude points(it is the lon points which differ

latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid

;print(latS+"  "+latN+"   "+var4cal&lat(1)+"  "+var4cal&lat(89))

   opt = True 

   NLAT1x1    = 180                               ; RES   = "180x288"    
   MLON1x1    = 360                              
   LAT_1x1    = latGlobeFo(NLAT1x1, "LAT_1x1", "latitude" , "degrees_north")  
   LON_1x1    = lonGlobeFo(MLON1x1, "LON_1x1", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT1x1
   LAT_REG_1x1     = LAT_1x1({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_1x1, LAT_REG_1x1, opt)

print("dims of variable after interpolation: "+dimsizes(interpolated_var))
;***********************************************************************************
; reassign interpolated variable
  cfrac_plot_am4_thin   = interpolated_var
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
print("dims of cfrac_plot_am4_thin after interpolation: "+dimsizes(interpolated_var))
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")


;***********************************************************************************
; interpolate gfdl data to a 180x360 degree grid

var_to_interpolate=cfrac_tmn_totz_thick

var_to_interpolate!0="lat"
var_to_interpolate&lat=cfrac_thin&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=cfrac_thin&lon

dimgfdl=dimsizes(var_to_interpolate)
print("dims of variable before interpolation: "+dimgfdl)

nlat=dimgfdl(0)
nlon=dimgfdl(1)

nlati=180 ; number of input latitude points(it is the lon points which differ

latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid

;print(latS+"  "+latN+"   "+var4cal&lat(1)+"  "+var4cal&lat(89))

   opt = True 

   NLAT1x1    = 180                               ; RES   = "180x288"    
   MLON1x1    = 360                              
   LAT_1x1    = latGlobeFo(NLAT1x1, "LAT_1x1", "latitude" , "degrees_north")  
   LON_1x1    = lonGlobeFo(MLON1x1, "LON_1x1", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT1x1
   LAT_REG_1x1     = LAT_1x1({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_1x1, LAT_REG_1x1, opt)

print("dims of variable after interpolation: "+dimsizes(interpolated_var))

;***********************************************************************************
; reassign interpolated variable

  cfrac_plot_am4_thick  = interpolated_var
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
print("dims of cfrac_plot_am4_thick after interpolation: "+dimsizes(cfrac_plot_am4_thick))
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

  cfrac_plot_misr_thin  = cfrac_thin_misr
  cfrac_plot_misr_thick = cfrac_thick_misr
;***********************************************************************************
; reasign meta data
;***********************************************************************************
print("dims of cfrac_plot_am4_thin: "+dimsizes(cfrac_plot_am4_thin))
print("dims of cfrac_misr_thin: "+dimsizes(cfrac_misr_thin))
  cfrac_plot_am4_thin!0="lat"
  cfrac_plot_am4_thin&lat=cfrac_misr_thin&lat
  cfrac_plot_am4_thin!1="lon"
  cfrac_plot_am4_thin&lon=cfrac_misr_thin&lon

  cfrac_plot_am4_thick!0="lat"
  cfrac_plot_am4_thick&lat=cfrac_misr_thin&lat
  cfrac_plot_am4_thick!1="lon"
  cfrac_plot_am4_thick&lon=cfrac_misr_thin&lon

  cfrac_plot_misr_thin!0="lat"
  cfrac_plot_misr_thin&lat=cfrac_misr_thin&lat
  cfrac_plot_misr_thin!1="lon"
  cfrac_plot_misr_thin&lon=cfrac_misr_thin&lon

  cfrac_plot_misr_thick!0="lat"
  cfrac_plot_misr_thick&lat=cfrac_misr_thick&lat
  cfrac_plot_misr_thick!1="lon"
  cfrac_plot_misr_thick&lon=cfrac_misr_thick&lon

;print("dimensions of cfrac are: "+dimsizes(cfrac))
;print("dimensions of cfrac_tmn_totz are: "+dimsizes(cfrac_tmn_totz))
;print("dimensions of cfrac_plot are: "+dimsizes(cfrac_plot))
;print("dimensions of cfrac_plot_thin are: "+dimsizes(cfrac_plot_thin))
;print("max/min of cfrac is: "+max(cfrac)+"  "+min(cfrac))                         

;***********************************************************************************
; compute global mean values and biases
  lat  = a->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)

  am4_cfmisr_weighted_ave     = wgt_areaave(interpolated_var,clat,1.0,1)
  obs_cfmisr_th_weighted_ave     = wgt_areaave(cfrac_thin_misr,clat,1.0,1)
  obs_cfmisr_tck_weighted_ave     = wgt_areaave(cfrac_thick_misr,clat,1.0,1)

print("weighted average of cm4 data: "+am4_cfmisr_weighted_ave)
print("weighted average of thin misr clouds: "+obs_cfmisr_th_weighted_ave)
print("weighted average of thick misr clouds: "+obs_cfmisr_tck_weighted_ave)
;***********************************************************************************


;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels

  my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/)
  my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/)

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"MPL_YlGnBu")
  plot = new(4,graphic)

  res                   = True

  res@gsnDraw          = False
  res@gsnFrame         = False

  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  ;res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpGridAndLimbOn   = False; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels1
  res@cnLinesOn         = False
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015 

  res@lbLabelBarOn      = False

  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = maintitle_top  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

;  res@vpXF      = 0.15
;  res@vpYF      = 0.94
;  res@vpWidthF  = 0.4
;  res@vpHeightF = 0.4

  plot(0) = gsn_csm_contour_map(wks,cfrac_plot_am4_thick,res)  ; create the plot

  res@tiMainString       = maintitle_bot  ; add a title
;  res@vpXF      = 0.15
;  res@vpYF      = 0.5
;  res@vpWidthF  = 0.4
;  res@vpHeightF = 0.4

  plot(1) = gsn_csm_contour_map(wks,cfrac_plot_am4_thin,res)  ; create the plot
  plot(2) = gsn_csm_contour_map(wks,cfrac_plot_misr_thick,res)  ; create the plot
  plot(3) = gsn_csm_contour_map(wks,cfrac_plot_misr_thin,res)  ; create the plot

  resP                         = True
  resP@txString                = " " 
  resP@txString                = "MISR simulator AM4.0"
  resP@gsnPanelLabelBar        = True
  resP@lbLabelFontHeightF      = 0.012

  gsn_panel(wks,plot,(/2,2/),resP)
  ;maximize_output(wks,res)

end

