;---------------------------------------------------------------------
; glb_am4_radflux.ncl
;---------------------------------------------------------------------
;
; reads in one data file from one experiment
; and plots a six panel figure of variables
; 
; variables plotted are:   -Net TOA rad flux
;                          -LW clr
;                          -LW CRE
;                          -Net CRE
;                          -SW clr
;                          -SW CRE
; 
; this script also prints out the global mean values of the fields
; to be plotted
; 
; levi silvers                                              oct 20167                    
;---------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;---------------------------------------------------------------------
begin
;---------------------------------------------------------------------
; read in netCDF file
;;---------------------------------------------------------------------
;dirin="/archive/Levi.Silvers/sstpatt/am4_1pc_test"
;;expname="/atmos_c96L32_am4g9_last20yr_warmpatt"
;;expname="/atmos_c96L32_am4g9_1860climo_ctl_qc_test"
;expname="/atmos_AM4OM2F_c96l32_am4g5r11_2000climo_1pct"
;period="0136-0140"
;
;;path_to8xdaily="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos_8xdaily_alt40/ts/3hr/5yr/"

path="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/annual_5yr/"
filename="atmos.2004-2008.ann.nc"
infile1=path+filename
print("infile1 is: "+infile1)
;---------------------------------------------------------------------
; read in netCDF files 
; read in CERES-EBAF data
path="/archive/Ming.Zhao/backup/readobs_data/"
filename="CERES_EBAF-TOA_Ed2.8_Subset_200003-201607.nc"
infile_obs=path+filename
print("infile_obs is: "+infile_obs)
;---------------------------------------------------------------------
; ceres data read below
;---------------------------------------------------------------------
  crs = addfile(infile_obs,"r")
varname1="toa_cre_sw_mon"
varname2="toa_cre_lw_mon"
varname3="toa_cre_net_mon"
ceres_swcre = crs->$varname1$(:,:,:)
ceres_lwcre = crs->$varname2$(:,:,:)

print("dims before averaging "+dimsizes(ceres_swcre))
ceres_swcre_tmn=dim_avg_n(ceres_swcre,0)
ceres_lwcre_tmn=dim_avg_n(ceres_lwcre,0)
print("dims after averaging "+dimsizes(ceres_swcre_tmn))

; ceres data is at a higher resolution (180x360 than) so we need to interpolate CERES to the AM4 grid

var_to_interpolate=ceres_swcre_tmn

;*************************************************************
; perform conservative remapping of ceres data to am4 grid
;*************************************************************

var_to_interpolate!0="lat"
var_to_interpolate&lat=ceres_swcre&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=ceres_swcre&lon

dimceres=dimsizes(var_to_interpolate)
;ntim=dimceres(0)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ

latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

   opt = True 

   NLAT2x2    = 180                               ; RES   = "180x288"    
   MLON2x2    = 288                              
   LAT_am4     = latGlobeFo(NLAT2x2, "LAT_am4", "latitude" , "degrees_north")  
   LON_am4     = lonGlobeFo(MLON2x2, "LON_am4", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT2x2
   LAT_REG_am4     = LAT_am4({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_am4, LAT_REG_am4, opt)
;*************************************************************

ceres_swcre_180x288=interpolated_var

var_to_interpolate=ceres_lwcre_tmn

;*************************************************************
; perform conservative remapping of ceres data to am4 grid
;*************************************************************

var_to_interpolate!0="lat"
var_to_interpolate&lat=ceres_swcre&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=ceres_swcre&lon

dimceres=dimsizes(var_to_interpolate)
;ntim=dimceres(0)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ

latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

   opt = True 

   NLAT2x2    = 180                               ; RES   = "180x288"    
   MLON2x2    = 288                              
   LAT_am4     = latGlobeFo(NLAT2x2, "LAT_am4", "latitude" , "degrees_north")  
   LON_am4     = lonGlobeFo(MLON2x2, "LON_am4", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT2x2
   LAT_REG_am4     = LAT_am4({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_am4, LAT_REG_am4, opt)
;*************************************************************

ceres_lwcre_180x288=interpolated_var

;---------------------------------------------------------------------
; am4 data read below
;---------------------------------------------------------------------
; olr,olr_clr,swdn_toa,swup_toa,swdn_toa_clr,swup_toa_clr
;varname1="olr" ; this is not the actual var, but should
varname1="swdn_toa"
varname2="swup_toa"
varname3="olr_clr"
varname4="swup_toa_clr"
varname5="olr"
;varname6="sw_cre"
;
  aa = addfile(infile1,"r")
month=0
; define values to be positive down
  field1 = aa->$varname1$(month,:,:)          
  swdntoa=field1
  field2 = aa->$varname2$(month,:,:)         
  swuptoa=-field2
  field3 = aa->$varname3$(month,:,:)         
  olrclr=-field3
  field4 = aa->$varname4$(month,:,:)         
  swuptoaclr=-field4
  field5 = aa->$varname5$(month,:,:)         
  olr=-field5
;  field6 = aa->$varname6$(month,:,:)         
;
print("dimensions of am4 data: "+dimsizes(field1))
; toa net radiative flux positive downward
  radfluxtoa=swdntoa+swuptoa+olr
  ;cre_radfluxtoa=radfluxtoa-olrclr-swuptoaclr
  cre_olr=olr-olrclr; positive values indicates clouds are warming climate
  cre_sw=swuptoa-swuptoaclr; pos vals indicate clouds warm climate
  cre_radfluxtoa=olr+swuptoa-olrclr-swuptoaclr

  cre_net=cre_sw+cre_olr;
  clr_net=olrclr+swuptoaclr;

radfluxtoa!0="lat"
radfluxtoa&lat=field1&lat
radfluxtoa!1="lon"
radfluxtoa&lon=field1&lon

cre_radfluxtoa!0="lat"
cre_radfluxtoa&lat=field1&lat
cre_radfluxtoa!1="lon"
cre_radfluxtoa&lon=field1&lon

cre_olr!0="lat"
cre_olr&lat=field1&lat
cre_olr!1="lon"
cre_olr&lon=field1&lon

cre_sw!0="lat"
cre_sw&lat=field1&lat
cre_sw!1="lon"
cre_sw&lon=field1&lon

clr_net!0="lat"
clr_net&lat=field1&lat
clr_net!1="lon"
clr_net&lon=field1&lon

cre_net!0="lat"
cre_net&lat=field1&lat
cre_net!1="lon"
cre_net&lon=field1&lon
;;---------------------------------------------------------------------
; print max and min values
print("infile1 is: "+infile1)
print("max of toaflux is: "+max(field1))
print("min of toaflux is: "+min(field1))
print("max of toaflux CRE is: "+max(field2))
print("min of toaflux CRE is: "+min(field2))
print("max of olr clr is: "+max(olrclr))
print("min of olr clr is: "+min(olrclr))
print("max of olr is: "+max(olr))
print("min of olr is: "+min(olr))
print("max of swup toa clr is: "+max(field4))
print("min of swup toa clr is: "+min(field4))
print("max of olr CRE is: "+max(field5))
print("min of olr CRE is: "+min(field5))
print("max of swdntoa is: "+max(swdntoa))
print("min of swdntoa is: "+min(swdntoa))
print("max of cre_net is: "+max(cre_net))
print("min of cre_net is: "+min(cre_net))
print("max of clr_net is: "+max(clr_net))
print("min of clr_net is: "+min(clr_net))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = aa->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
field1_weighted_ave     = wgt_areaave(field1,clat,1.0,1)
;t2_weighted_ave     = wgt_areaave(t2,clat,1.0,1)
;temp1_weighted_ave     = wgt_areaave(tempctl,clat,1.0,1)
;temp2_weighted_ave     = wgt_areaave(tempctlpreg,clat,1.0,1)
;print("global mean toa rad flux of ctl is: "+t1_weighted_ave)
;print("global mean toa rad flux of ctl preg is: "+t2_weighted_ave)
;print("global mean sfc temp of ctl is: "+temp1_weighted_ave)
;print("global mean sfc temp of ctlpreg is: "+temp2_weighted_ave)
;---------------------------------------------------------------------
;---------------------------------------------------------------------
; create plot
;---------------------------------------------------------------------
; create colors to use in contours
; contour levels
;my_levels1 = (/265,270,275,280,284,286,288,290,292,294,296,298,300,302,304/)
;my_levels_nettoa = (/-120,-90,-60,-30,0, 30,60,90,120/)
my_levels_nettoa = (/-80,-60,-40,-20,0, 20,40,60,80/)
my_levels_posneg = (/-40,-30,-20,-10,0, 10,20,30,40/) ; plots 10 colors
my_levels_netcre = (/5,0,-10,-20,-30,-40,-50,-60,-70/)
my_levels_olrcre = (/5,12,19,26,33,40,47,54,61/)
my_levels_swcre = (/-10,-20,-30,-40,-50,-60,-70,-80,-90/)
my_levels_swclr = (/35,50,65,80,95,110,125,140,155/)
my_levels_lwclr = (/140,160,180,200,220,240,260,280,300/)
;
my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_nettoa = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_olrcre = (/ 9, 2,74,77,80,83,86,89,92,95,100/)
my_colors_netcre = (/ 50,44,38,32,26,20,14,8,2,77,2/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)
my_colors_swclr = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
my_colors_lwclr = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)


my_levels_20posneg = (/-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45/) ; plots 20 colors (19 nums) 1 less than thought
my_levels_20posneg_pm85 = (/-85,-75,-65,-55,-45,-35,-25,-15,-5,0,5,15,25,35,45,55,65,75,85/) ; plots 20 colors (19 nums) 1 less than thought
my_colors_20posneg = (/ 10,23,33,43,53,63,73,83,93,103,127,151,161,171,181,191,201,211,221,231,241/) ; 20 colors (21 nums) 1 more than thought

;---------------------------------------------------------------------
  ;wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
  wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")
  plot = new(4,graphic)

  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpCenterLonF      = 200.
  res@lbLabelAngleF     = 90
  res@mpFillOn          = False
  res@gsnDraw           = False
  res@gsnFrame          = False
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@gsnMaximize       = True
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_20posneg_pm85
  res@cnFillColors      = my_colors_20posneg
  res@txFontHeightF     = 0.015 

  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  ;res@tiMainString       = maintitle  ; add a title
  
  res@tiMainFontHeightF  = .018                               ; font height


; net cre and clear sky row
  res@cnLevelSelectionMode  = "ExplicitLevels"
  ;res@cnLevels          = my_levels_olrcre
  ;res@cnFillColors      = my_colors_olrcre
  res@tiMainString       = "CERES-EBAF lw cre" 
  contour6 = gsn_csm_contour_map(wks,ceres_lwcre_180x288,res)  ; create the plot
  plot(0) = contour6
  res@gsnFrame         = False
  ;res@cnLevels          = my_levels_swcre
  ;res@cnFillColors      = my_colors_swcre
  res@tiMainString       = "CERES-EBAF sw cre" 
  contour7 = gsn_csm_contour_map(wks,ceres_swcre_180x288,res)  ; create the plot
  plot(1) = contour7

lw_bias=cre_olr-ceres_lwcre_180x288

lw_bias!0="lat"
lw_bias&lat=cre_sw&lat
lw_bias!1="lon"
lw_bias&lon=cre_sw&lon

sw_bias=cre_sw-ceres_swcre_180x288

sw_bias!0="lat"
sw_bias&lat=cre_sw&lat
sw_bias!1="lon"
sw_bias&lon=cre_sw&lon


; cre row
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_20posneg
  res@cnFillColors      = my_colors_20posneg
  res@tiMainString       = "AM4.0 LW CRE Bias" 
  contour4 = gsn_csm_contour_map(wks,lw_bias,res)  ; create the plot
  plot(2) = contour4
  res@gsnFrame         = False
  res@cnLevels          = my_levels_20posneg
  res@cnFillColors      = my_colors_20posneg
  res@tiMainString       = "AM4.0 SW CRE Bias" 
  contour5 = gsn_csm_contour_map(wks,sw_bias,res)  ; create the plot
  plot(3) = contour5

  respanel = True

  gsn_panel(wks,plot,(/2,2/),respanel)

end

