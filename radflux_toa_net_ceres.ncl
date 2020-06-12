;---------------------------------------------------------------------
; radflux_toa_net_ceres.ncl
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
; CRE = all sky fluxes - clear sky fluxes
; 
; this script also prints out the global mean values of the fields
; to be plotted
; 
; levi silvers                                            feb 2020 
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

;path="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/annual_5yr/"
;path="/archive/Levi.Silvers/CM4/warsaw_201803/CM4_amip/gfdl.ncrc4-intel16-prod-openmp/pp/"
path="/Users/silvers/data/cfmip_toafluxes/"
;filename=".nc"
filename="atmos_cmip.197901-201412.rlut.nc"
infile1=path+filename
print("infile1 is: "+infile1)
;---------------------------------------------------------------------
; read in netCDF files 
; read in CERES-EBAF data
;path="/archive/Ming.Zhao/backup/readobs_data/"
;path="/archive/Levi.Silvers/data/ceres_ebaf/"
path_obs="/Users/silvers/data/SatData/CERES/"
filename="CERES_EBAF-TOA_Ed2.8_Subset_200003-201607.nc"
filename_4p1="CERES_EBAF_Ed4.1_Subset_200003-201809.nc"
infile_obs=path_obs+filename
infile_obs_4p1=path_obs+filename_4p1
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
ceres_cre =   crs->$varname3$(:,:,:)

print("dims before averaging "+dimsizes(ceres_swcre))
ceres_swcre_tmn=dim_avg_n(ceres_swcre,0)
ceres_lwcre_tmn=dim_avg_n(ceres_lwcre,0)
ceres_cre_tmn  =dim_avg_n(ceres_cre,0)
print("dims after averaging "+dimsizes(ceres_swcre_tmn))

;
  crs_4p1 = addfile(infile_obs_4p1,"r")
varname1="toa_sw_all_mon"
varname2="toa_sw_clr_t_mon"; what is the difference between the clr_t and clr_c vars?
;varname2="toa_sw_clr_c_mon"; what is the difference between the clr_t and clr_c vars?
varname3="toa_lw_all_mon"
varname4="toa_lw_clr_t_mon"
;varname4="toa_lw_clr_c_mon"
ceres_sw_all = crs_4p1->$varname1$(:,:,:)
ceres_sw_clr = crs_4p1->$varname2$(:,:,:)
ceres_lw_all = crs_4p1->$varname3$(:,:,:)
ceres_lw_clr = crs_4p1->$varname4$(:,:,:)

ceres_lw_cre=-ceres_lw_all+ceres_lw_clr
ceres_lw_cre_tmn=dim_avg_n(ceres_lw_cre,0)
ceres_sw_cre=-ceres_sw_all+ceres_sw_clr
ceres_sw_cre_tmn=dim_avg_n(ceres_sw_cre,0)

; ceres data is at a higher resolution (180x360 than) so we need to interpolate CERES to the AM4 grid

var_to_interpolate=ceres_swcre_tmn ; for ceres 2.8
;var_to_interpolate=ceres_sw_cre_tmn ; for ceres 4.1

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

var_to_interpolate=ceres_lwcre_tmn ; for ceres 2.8
;var_to_interpolate=ceres_lw_cre_tmn ; for ceres 4.1

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

printVarSummary(ceres_lwcre_180x288)

; total CRE
ceres_cre_180x288=ceres_lwcre_180x288+ceres_swcre_180x288

ceres_cre_180x288!0="lat"
ceres_cre_180x288&lat=ceres_lwcre_180x288&LAT_am4
ceres_cre_180x288!1="lon"
ceres_cre_180x288&lon=ceres_lwcre_180x288&LON_am4


;---------------------------------------------------------------------
; am4 data read below
;---------------------------------------------------------------------
; olr,olr_clr,swdn_toa,swup_toa,swdn_toa_clr,swup_toa_clr
;varname1="olr" ; this is not the actual var, but should
varname1="rsdt"
varname2="rsut"
varname3="rlutcs"
varname4="rsutcs"
varname5="rlut"
;varname6="sw_cre"
;

;path="/archive/Levi.Silvers/CM4/warsaw_201803/CM4_amip/gfdl.ncrc4-intel16-prod-openmp/pp/"
;filename=".nc"
years="atmos_cmip.197901-201412."
infile1=path+years+varname1+".nc"
infile2=path+years+varname2+".nc"
infile3=path+years+varname3+".nc"
infile4=path+years+varname4+".nc"
infile5=path+years+varname5+".nc"

  a1 = addfile(infile1,"r")
  a2 = addfile(infile2,"r")
  a3 = addfile(infile3,"r")
  a4 = addfile(infile4,"r")
  a5 = addfile(infile5,"r")
month=0
; define values to be positive down
ceres_swcre_tmn=dim_avg_n(ceres_swcre,0)
  field1 = a1->$varname1$(:,:,:)          
  field1_mn = dim_avg_n(field1,0)          
  swdntoa=field1_mn
  field2 = a2->$varname2$(:,:,:)         
  field2_mn = dim_avg_n(field2,0)          
  swuptoa=-field2_mn
  field3 = a3->$varname3$(:,:,:)         
  field3_mn = dim_avg_n(field3,0)          
  olrclr=-field3_mn
  field4 = a4->$varname4$(:,:,:)         
  field4_mn = dim_avg_n(field4,0)          
  swuptoaclr=-field4_mn
  field5 = a5->$varname5$(:,:,:)         
  field5_mn = dim_avg_n(field5,0)          
  olr=-field5_mn
;
print("dimensions of am4 data before average: "+dimsizes(field1))
print("dimensions of am4 data after average: "+dimsizes(field1_mn))

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
lat  = a1->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
field1_weighted_ave     = wgt_areaave(field1_mn,clat,1.0,1)
;t2_weighted_ave     = wgt_areaave(t2,clat,1.0,1)
;temp1_weighted_ave     = wgt_areaave(tempctl,clat,1.0,1)
;temp2_weighted_ave     = wgt_areaave(tempctlpreg,clat,1.0,1)
print("global mean field1 is: "+field1_weighted_ave)
;print("global mean toa rad flux of ctl preg is: "+t2_weighted_ave)
;print("global mean sfc temp of ctl is: "+temp1_weighted_ave)
;print("global mean sfc temp of ctlpreg is: "+temp2_weighted_ave)
;---------------------------------------------------------------------
radfluxtoa_weighted_ave = wgt_areaave(radfluxtoa,clat,1.0,1)
print("global mean net radiation = "+radfluxtoa_weighted_ave)
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


my_levels_11posneg = (/-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10/) ; plots 20 colors (9 nums) 1 less than thought
my_levels_11posneg_b = (/-15,-12,-9,-6,-3,0,3,6,9,12,15/) ; plots 20 colors (9 nums) 1 less than thought
my_colors_13posneg = (/10,20,30,40,50,60,70,80,90,100,150,180,210/) ; 20 colors (21 nums) 1 more than thought
my_colors_13posneg_b = (/10,33,53,73,93,100,150,166,182,198,214,230,246/) ; 20 colors (21 nums) 1 more than thought
;my_levels_20posneg = (/-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9/) ; plots 20 colors (19 nums) 1 less than thought
my_levels_20posneg = (/-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18/) ; plots 20 colors (19 nums) 1 less than thought
my_levels_20posneg_pm85 = (/-85,-75,-65,-55,-45,-35,-25,-15,-5,0,5,15,25,35,45,55,65,75,85/) ; plots 20 colors (19 nums) 1 less than thought
my_colors_20posneg = (/ 10,23,33,43,53,63,73,83,93,103,127,151,161,171,181,191,201,211,221,231,241/) ; 20 colors (21 nums) 1 more than thought

;----------------------------------------------------------------
am4_cre=cre_sw+cre_olr

am4_cre!0="lat"
am4_cre&lat=cre_sw&lat
am4_cre!1="lon"
am4_cre&lon=cre_sw&lon

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


sw_cre_w_ave     = wgt_areaave(cre_sw,clat,1.0,1)
sw_cre_ceres2p8_w_ave     = wgt_areaave(ceres_swcre_tmn,clat,1.0,1)
sw_cre_ceres4p1_w_ave     = wgt_areaave(ceres_sw_cre_tmn,clat,1.0,1)
lw_cre_ceres2p8_w_ave     = wgt_areaave(ceres_lwcre_tmn,clat,1.0,1)
lw_cre_ceres4p1_w_ave     = wgt_areaave(ceres_lw_cre_tmn,clat,1.0,1)
lw_cre_w_ave     = wgt_areaave(cre_olr,clat,1.0,1)

cre_ceres_weighted_ave          = wgt_areaave(ceres_cre_180x288,clat,1.0,1)
cre_am4_weighted_ave            = wgt_areaave(am4_cre,clat,1.0,1)
lwbias_weighted_ave             = wgt_areaave(lw_bias,clat,1.0,1)
swbias_weighted_ave             = wgt_areaave(sw_bias,clat,1.0,1)

print("longwave cre = "+lw_cre_w_ave)
print("ceres 2p8 longwave cre = "+lw_cre_ceres2p8_w_ave)
print("ceres 4p1 longwave cre = "+lw_cre_ceres4p1_w_ave)
print("shortwave cre = "+sw_cre_w_ave)
print("ceres 2p8 shortwave cre = "+sw_cre_ceres2p8_w_ave)
print("ceres 4p2 shortwave cre = "+sw_cre_ceres4p1_w_ave)
print("longwave bias = "+lwbias_weighted_ave)
  lwbias_st=flt2string(decimalPlaces(lwbias_weighted_ave,1,True))
print("shortwave bias = "+swbias_weighted_ave)
  swbias_st=flt2string(decimalPlaces(swbias_weighted_ave,1,True))
print("total ceres cre= "+cre_ceres_weighted_ave)
  cre_ceres_st=flt2string(decimalPlaces(cre_ceres_weighted_ave,1,True))
print("total am4 cre = "+cre_am4_weighted_ave)
  cre_am4_st=flt2string(decimalPlaces(cre_am4_weighted_ave,1,True))

;---------------------------------------------------------------------
  wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file
  ;wks = gsn_open_wks("newpdf","testplot_toa")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")
  plot = new(4,graphic)

  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
  res@mpGridAndLimbOn   = False              ; turn on/off lat/lon lines
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
  res@cnLevels          = my_levels_11posneg
  res@cnFillColors      = my_colors_13posneg
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
  res@tiMainString       = "CERES-EBAF CRE ("+cre_ceres_st+")"
;  contour6 = gsn_csm_contour_map(wks,ceres_lwcre_180x288,res)  ; create the plot
  contour6 = gsn_csm_contour_map(wks,ceres_cre_180x288,res)  ; create the plot
  plot(0) = contour6
  res@gsnFrame         = False
  res@tiMainString       = "AM4.0 CRE ("+cre_am4_st+")"
  ;contour7 = gsn_csm_contour_map(wks,ceres_swcre_180x288,res)  ; create the plot
  contour7 = gsn_csm_contour_map(wks,am4_cre,res)  ; create the plot
  plot(1) = contour7



; cre row
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_11posneg_b
  res@cnFillColors      = my_colors_13posneg_b
  res@tiMainString       = "AM4.0 LW CRE Bias ("+lwbias_st+")"
  contour4 = gsn_csm_contour_map(wks,lw_bias,res)  ; create the plot
  plot(2) = contour4
  res@gsnFrame         = False
  res@tiMainString       = "AM4.0 SW CRE Bias ("+swbias_st+")" 
  contour5 = gsn_csm_contour_map(wks,sw_bias,res)  ; create the plot
  plot(3) = contour5

  respanel = True

  gsn_panel(wks,plot,(/2,2/),respanel)

end

