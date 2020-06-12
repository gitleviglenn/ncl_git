;***********************************************************************************
; cf_misr_vs_am4.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the misr cosp tool.
;
; example here is for clouds with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; in the observations file, there is a -1 value of tau before 0.15
; in general the tau levels in misr are:
; 0.15,0.8,2.45,6.5,16.2,41.5,100.
; but they are usually grouped in the histograms as: 
; 0 0.3 1.3 3.6 9.4 23 60
;
; the dimensions of clmisr are: 
; clmisr(time, tau, alt16, lat, lon) ;
;
; data from gfdl is on a 180x288 grid while observational data from 
; misr is on a 180x360 grid so we need to interpolate the gfdl data to 180x360
;
; the longitude dimensions for the am4 data and the misr observations are not
; lined up with each other.  

; to shift the long dims to start at 0.5 use: lonPivot(cfrac_thin_misr,0.5)
; to flib the latitude dim use:               cfrac_thin_misr(::-1,:)
;
; alt16 = 0, 250, 750, 1250, 1750, 2250, 2750, 3500, 4500, 6000, 
;         8000, 10000, 12000, 14500, 16000, 18000 ;
;
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							nov 2019
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

;
print("infile for am4 data is: "+infile)
print("infile for misr observations is: "+infile_obs)
;

; define variable names to read from files
  var2read="clmisr"
  var_obs="clMISR"

  cfrac_total  = a->$var2read$(:,:,:,:,:) ; for thin clouds (0.3:1.3) 
;
; tau limits
; height limits (recall there are 16 levels)
z_bot=0
z_top=15

print("dimsizes of am4 incoming data is: "+dimsizes(cfrac_total))
  cfrac_thin  = a->$var2read$(:,1:2,z_bot:z_top,:,:) ; for thin clouds (0.3:1.3) 
  cfrac_thick = a->$var2read$(:,3:4,z_bot:z_top,:,:) ; for thicker clouds (3.6:60)      
  cfrac_full  = a->$var2read$(:,:,:,:,:) ; for thin clouds (0.3:1.3) 

;

  cfrac_misr_thin  = m_obs->$var_obs$(0,1:2,z_bot:z_top,:,:) ; for thin clouds      
  cfrac_misr_thick = m_obs->$var_obs$(0,3:5,:,:,:) ; for thicker clouds      
  ;cfrac_misr_thick = m_obs->$var_obs$(0,3:4,z_bot:z_top,:,:) ; for thicker clouds      
  ;cfrac_misr_thick = m_obs->$var_obs$(0,:,z_bot:z_top,:,:) ; for thicker clouds      
;  cfrac_misr_all = m_obs->$var_obs$(:,:,:,:,:) ; for thicker clouds      
;print("dimsizes of full misr obs: "+dimsizes(cfrac_misr_all))
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

print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

print("dimensions of am4 cfrac sum over z time and tau are: "+dimsizes(cfrac_tmn_totz_thin))
print("dimensions of misr cfrac sum over z and tau are: "+dimsizes(cfrac_thin_misr))

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;***********************************************************************************
; reorient the dimensions of the misr observations a bit
;printVarSummary(cfrac_thin_misr)
;cfrac_thin_misr=lonPivot(cfrac_thin_misr,0.5)
;cfrac_thin_misr=cfrac_thin_misr(::-1,:)
;printVarSummary(cfrac_thin_misr)

;***********************************************************************************
; interpolate gfdl data to a 180x360 degree grid
print("Beginning Interpolation")

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
;;***********************************************************************************
;; reassign interpolated variable
;
  printVarSummary(LON_1x1)
  cfrac_plot_am4_thin   = interpolated_var
;  cfrac_plot_am4_thin   = new(2,float)
;  printVarSummary(cfrac_plot_am4_thin)
;  cfrac_plot_am4_thin!0="lat"
;  cfrac_plot_am4_thin&lat=cfrac_thin&lat
;  cfrac_plot_am4_thin!1="lon"
;  cfrac_plot_am4_thin&lat=cfrac_thin&lon
;
;  cfrac_plot_am4_thin   = interpolated_var
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
print("dims of interpolated_var : "+dimsizes(interpolated_var))
print("dims of cfrac_plot_am4_thin: "+dimsizes(cfrac_plot_am4_thin))
print("dims of cfrac_plot_am4_thin after interpolation: "+dimsizes(interpolated_var))
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
;
;
;***********************************************************************************
; interpolate gfdl data to a 180x360 degree grid
print("Beginning Interpolation")

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

;;***********************************************************************************
;; reassign interpolated variable
;
  cfrac_plot_am4_thick   = interpolated_var
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
print("dims of cfrac_plot_am4_thick after interpolation: "+dimsizes(cfrac_plot_am4_thick))
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
;
;  cfrac_plot_misr_thin  = cfrac_thin_misr
;  cfrac_plot_misr_thick = cfrac_thick_misr
;;***********************************************************************************
;; reasign meta data
;;***********************************************************************************
;print("dims of cfrac_plot_am4_thin: "+dimsizes(cfrac_plot_am4_thin))
;print("dims of cfrac_misr_thin: "+dimsizes(cfrac_misr_thin))
;  cfrac_plot_am4_thin!0="lat"
;  cfrac_plot_am4_thin&lat=cfrac_misr_thin&lat
;  cfrac_plot_am4_thin!1="lon"
;  cfrac_plot_am4_thin&lon=cfrac_misr_thin&lon
;
;  cfrac_plot_am4_thick!0="lat"
;  cfrac_plot_am4_thick&lat=cfrac_misr_thin&lat
;  cfrac_plot_am4_thick!1="lon"
;  cfrac_plot_am4_thick&lon=cfrac_misr_thin&lon
;
;  cfrac_plot_misr_thin!0="lat"
;  cfrac_plot_misr_thin&lat=cfrac_misr_thin&lat
;  cfrac_plot_misr_thin!1="lon"
;  cfrac_plot_misr_thin&lon=cfrac_misr_thin&lon
;
;  cfrac_plot_misr_thick!0="lat"
;  cfrac_plot_misr_thick&lat=cfrac_misr_thick&lat
;  cfrac_plot_misr_thick!1="lon"
;  cfrac_plot_misr_thick&lon=cfrac_misr_thick&lon
;
; am4
  cfrac_tmn_totz_thin!0="lat"
  cfrac_tmn_totz_thin&lat=cfrac_thin&lat
  cfrac_tmn_totz_thin!1="lon"
  cfrac_tmn_totz_thin&lon=cfrac_thin&lon

  cfrac_tmn_totz_thick!0="lat"
  cfrac_tmn_totz_thick&lat=cfrac_thin&lat
  cfrac_tmn_totz_thick!1="lon"
  cfrac_tmn_totz_thick&lon=cfrac_thin&lon
; misr
;cfrac_thick_misr  cfrac_misr_thin
  cfrac_thin_misr!0="lat"
  cfrac_thin_misr&lat=cfrac_misr_thin&lat
  cfrac_thin_misr!1="lon"
  cfrac_thin_misr&lon=cfrac_misr_thin&lon

  cfrac_thick_misr!0="lat"
  cfrac_thick_misr&lat=cfrac_misr_thick&lat
  cfrac_thick_misr!1="lon"
  cfrac_thick_misr&lon=cfrac_misr_thick&lon
;
;;print("dimensions of cfrac are: "+dimsizes(cfrac))
;;print("dimensions of cfrac_tmn_totz are: "+dimsizes(cfrac_tmn_totz))
;;print("dimensions of cfrac_plot are: "+dimsizes(cfrac_plot))
;;print("dimensions of cfrac_plot_thin are: "+dimsizes(cfrac_plot_thin))
;;print("max/min of cfrac is: "+max(cfrac)+"  "+min(cfrac))                         
;
;***********************************************************************************
; reorient the dimensions of the misr observations a bit
printVarSummary(cfrac_thin_misr)
cfrac_thin_misr=lonPivot(cfrac_thin_misr,0.5)
cfrac_thin_misr=cfrac_thin_misr(::-1,:)
printVarSummary(cfrac_thin_misr)
;;*****************************************
; cfrac_plot_am4_thick
;printVarSummary(cfrac_thick_misr)
;printVarSummary(cfrac_plot_am4_thick)
;print("long misr: "+cfrac_thick_misr->lon+" long am4: "+cfrac_plot_am4_thick->lon)

cfrac_am4_thin_oc=where(cfrac_thin_misr.eq.cfrac_thin_misr@_FillValue,cfrac_thin_misr@_FillValue,cfrac_plot_am4_thin)

cfrac_am4_thick_oc=where(cfrac_thin_misr.eq.cfrac_thin_misr@_FillValue,cfrac_thin_misr@_FillValue,cfrac_plot_am4_thick)

  cfrac_am4_thin_oc!0="lat"
  cfrac_am4_thin_oc&lat=LAT_1x1
  cfrac_am4_thin_oc!1="lon"
  cfrac_am4_thin_oc&lon=LON_1x1

  cfrac_am4_thick_oc!0="lat"
  cfrac_am4_thick_oc&lat=LAT_1x1
  cfrac_am4_thick_oc!1="lon"
  cfrac_am4_thick_oc&lon=LON_1x1
;
;;***********************************************************************************
;; compute global mean values and biases
  lat  = a->lat ; get latitude from am4 data
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
;

printVarSummary(cfrac_thin_misr)
print("dimensions of the latitude used for weighted mean are: "+dimsizes(lat))
print("dimensions of interpolated am4 data are: "+dimsizes(interpolated_var))
print("dimensions of cfrac_thin_misr data are: "+dimsizes(cfrac_thin_misr))
;print("blah blah blah dimsizes of craf_am4_thin_oc: "+dimsizes(cfrac_am4_thin_oc))
;print("blah blah blah craf_am4_thin_oc: "+cfrac_am4_thin_oc(:,1))
;print("blah blah blah craf_plot_am4_thin: "+cfrac_plot_am4_thin(:,1))
  am4_cfmisr_thin_weighted_ave    = wgt_areaave(cfrac_plot_am4_thin,clat,1.0,1)
  am4_cfmisr_thin_oc_whted_ave    = wgt_areaave(cfrac_am4_thin_oc,clat,1.0,0)
  am4_cfmisr_thick_weighted_ave   = wgt_areaave(cfrac_plot_am4_thick,clat,1.0,1)
  am4_cfmisr_thick_oc_whted_ave   = wgt_areaave(cfrac_am4_thick_oc,clat,1.0,0)
  obs_cfmisr_th_weighted_ave      = wgt_areaave(cfrac_thin_misr,clat,1.0,0)
  obs_cfmisr_tck_weighted_ave     = wgt_areaave(cfrac_thick_misr,clat,1.0,0)
;
print("weighted average of thin cm4 data: "+am4_cfmisr_thin_weighted_ave)
print("weighted average of thin cm4 oc data: "+am4_cfmisr_thin_oc_whted_ave)
print("weighted average of thick cm4 data: "+am4_cfmisr_thick_weighted_ave)
print("weighted average of thick cm4 oc data: "+am4_cfmisr_thick_oc_whted_ave)
print("weighted average of thin misr clouds: "+obs_cfmisr_th_weighted_ave)
print("weighted average of thick misr clouds: "+obs_cfmisr_tck_weighted_ave)
;;***********************************************************************************

;***********************************************************************************
; create plot
;;***********************************************************************************
;; create colors to use in contours
;; contour levels

  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
;  my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/) ; 16
  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
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

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "AM4 MISR sim thick (tau 3.6:23)"; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  ;plot(0) = gsn_csm_contour_map(wks,cfrac_plot_am4_thick,res)  ; create the plot
  ;plot(0) = gsn_csm_contour_map(wks,cfrac_tmn_totz_thick,res)  ; create the plot
  plot(0) = gsn_csm_contour_map(wks,cfrac_am4_thick_oc,res)  ; create the plot
print("dimensions of am4 cfrac sum over z time and tau are: "+dimsizes(cfrac_tmn_totz_thin))
print("dimensions of misr cfrac sum over z and tau are: "+dimsizes(cfrac_thin_misr))


  res@tiMainString       = "AM4 MISR sim thin (tau 0.3:3.6)"; add a title
  ;plot(1) = gsn_csm_contour_map(wks,cfrac_tmn_totz_thin,res)  ; create the plot
  plot(1) = gsn_csm_contour_map(wks,cfrac_am4_thin_oc,res)  ; create the plot
;  am4_cfmisr_thin_oc_whted_ave    = wgt_areaave(cfrac_am4_thin_oc,clat,1.0,0)
  ;plot(2) = gsn_csm_contour_map(wks,cfrac_plot_misr_thick,res)  ; create the plot
  res@tiMainString       = "MISR thick (tau 3.6:23)"; add a title
  plot(2) = gsn_csm_contour_map(wks,cfrac_thick_misr,res)  ; create the plot
  ;plot(3) = gsn_csm_contour_map(wks,cfrac_plot_misr_thin,res)  ; create the plot
  res@tiMainString       = "MISR thin (tau 0.3:3.6)"; add a title
  plot(3) = gsn_csm_contour_map(wks,cfrac_thin_misr,res)  ; create the plot

  resP                         = True
  resP@txString                = " " 
  resP@txString                = "MISR simulator AM4.0"
  resP@gsnPanelLabelBar        = True
  resP@lbLabelFontHeightF      = 0.012

  gsn_panel(wks,plot,(/2,2/),resP)
  ;maximize_output(wks,res)

end

