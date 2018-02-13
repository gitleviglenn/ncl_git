;***********************************************************************************
; calip_lowmedhigh.ncl
;***********************************************************************************
;
; plot global cloud fraction for low, med, and high clouds from CALIPSO simulator
;
; levi silvers							nov 2017
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; read in netCDF file
;***********************************************************************************
; variable to read: 
;varname1="cltlidarradar"
;varname1="tot_cld_amt" 
varname1="cllcalipso"
varname2="clmcalipso"
varname3="clhcalipso"
varname4="cltcalipso"

; path to observations from calipso
;path_obs="/net2/Levi.Silvers/data_calipso/"
path_obs="/Users/silvers/data/SatData/CALIPSO/" ; on macbook
;path_to8xdaily="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos_8xdaily_alt40/ts/3hr/5yr/"
path_to8xdaily="/Users/silvers/data/am4p0/" ; on macbook
;***********************************************************************************
;infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/monthly_2yr/atmos.0002-0003.timmean.nc"

;infile="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos/atmos.0002-0011.all.nc"
infile=path_to8xdaily+"atmos_8xdaily.197901-200812_cltcalipso_tmean.nc"
;infile1=path_to8xdaily+"atmos_8xdaily.197901-200812_cllcalipso_tmean.nc"
;infile2=path_to8xdaily+"atmos_8xdaily.197901-200812_clmcalipso_tmean.nc"
;infile3=path_to8xdaily+"atmos_8xdaily.197901-200812_clhcalipso_tmean.nc"

;infile6=path_obs+"calip_2x2xL40_avg_clh/clhcalipso_tmn_20060615_20101215.nc"

;infile8=path_obs+"calip_2x2xL40_avg_clt/cltcalipso_tmn_20060615_20101215.nc"
infile8=path_obs+"/cltcalipso_tmn_20060615_20101215.nc"
;infile8_new=path_obs+"from_Greg_Jan2017/MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"
infile8_new=path_obs+"/MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"

;infile_isccp="/net2/Levi.Silvers/data/isccpdata/cltisccp_7yr_tmn.nc"
infile_isccp="/Users/silvers/data/SatData/ISCCP/cltisccp_7yr_tmn.nc"

modelv="am4.0"

; from model
data = addfile(infile,"r")
; from obs
data8 = addfile(infile8,"r")
data_cal25 = addfile(infile8_new,"r")

print("infile is: "+infile)
print("infile is: "+infile8)
print("infile is: "+infile8_new)
var4 = data->$varname4$(0,:,:)                                
;  print("dimensions of model data: "+dimsizes(var1))

var4cal = data8->$varname4$(:,:)                                
var4cal25 = data_cal25->$varname4$(0,:,:)                                
var4calscale=100*var4cal
var4cal25scale=100*var4cal25

var4cal@_FillValue = 1.e+20
var4cal25@_FillValue = 1.e+20
;
print("max of var4cal: "+max(var4calscale))
print("min of var4cal: "+min(var4calscale))
print("max of var4cal25: "+max(var4cal25scale))
print("min of var4cal25: "+min(var4cal25scale))

var4calscale!0="lat"
var4calscale&lat=var4cal&lat
var4calscale!1="lon"
var4calscale&lon=var4cal&lon
var4cal25scale!0="lat"
var4cal25scale&lat=var4cal25&latitude
var4cal25scale!1="lon"
var4cal25scale&lon=var4cal25&longitude
;
;------------------------------------------------------------
; the calipso data and am4 data are not on the same grid...

var_to_interpolate=var4

;*************************************************************
; perform conservative remapping of am4 data to 2x2 grid
;*************************************************************

var_to_interpolate!0="lat"
var_to_interpolate&lat=var4&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=var4&lon

dimceres=dimsizes(var_to_interpolate)
print("dims of incoming variable: "+dimceres)
;ntim=dimceres(0)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ
;nlati=90 ; number of input latitude points(it is the lon points which differ


latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid

print(latS+"  "+latN+"   "+var4cal&lat(1)+"  "+var4cal&lat(89))

   opt = True 

   NLAT2x2    = 90                               ; RES   = "180x288"    
   MLON2x2    = 180                              
   LAT_2x2   = latGlobeFo(NLAT2x2, "LAT_2x2", "latitude" , "degrees_north")  
   LON_2x2     = lonGlobeFo(MLON2x2, "LON_2x2", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT2x2
   LAT_REG_2x2     = LAT_2x2({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_2x2, LAT_REG_2x2, opt)
;*************************************************************

var_90x180=interpolated_var
  print("dimensions of interpolated model data: "+dimsizes(var_90x180))

;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = data->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))

field4_weighted_ave     = wgt_areaave(var4,clat,1.0,1)

; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
;print("raw global mean of "+varname1+" is: "+field1_weighted_ave)
;print("raw global mean of "+varname2+" is: "+field2_weighted_ave)
;print("raw global mean of "+varname3+" is: "+field3_weighted_ave)
print("raw global mean of "+varname4+" is: "+field4_weighted_ave)
;field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field1_weighted_ave_test)
;
rad2x2 = 4.0*atan(1.0)/90.0
clat_2x2 = cos(LAT_REG_2x2*rad2x2)
print("dims of NLAT2x2: "+dimsizes(NLAT2x2))
print("dims of LAT_REG_2x2: "+dimsizes(LAT_REG_2x2)+" dims of var_90x180 are: "+dimsizes(var_90x180))
print("dims of clat: "+dimsizes(clat)+" dims of var4 are: "+dimsizes(var4))
;print("clat_2x2: "+LAT_REG_2x2)
;print("And the values of lat are: "+lat)

field_2x2_weighted_ave  = wgt_areaave(var_90x180,clat_2x2,1.0,1)

print("raw global mean of 2x2 "+varname1+" is: "+field_2x2_weighted_ave)
;---------------------------------------------------------------------
; compute latitude weighted mean values for the 2x2 data both calipso and am4

lat_cobs  = data8->lat
rad_cobs  = 4.0*atan(1.0)/180.0
clat_cobs=cos(lat_cobs*rad_cobs)

; calipso simulator data from am4.0
; low level clouds
var_90x180_weighted_ave  = wgt_areaave(var_90x180,clat_cobs,1.0,0)
var_mask = where(var4calscale.eq.var4calscale@_FillValue,var4calscale@_FillValue,var_90x180)
var_masked_weighted_ave  = wgt_areaave(var_mask,clat_cobs,1.0,0)
print("weighted low level am4 cal sim: "+var_90x180_weighted_ave)
print("weighted and masked low level am4 cal sim: "+var_masked_weighted_ave)

; model minus calipso
am4tcl_bias=var_mask-var4calscale
am4tcl_bias!0="lat"
am4tcl_bias&lat=var4cal&lat
am4tcl_bias!1="lon"
am4tcl_bias&lon=var4cal&lon
;

; calipso
field8_weighted_ave     = wgt_areaave(var4calscale,clat_cobs,1.0,0)
print("weighted total cloud cover calipso: "+field8_weighted_ave)
;---------------------------------------------------------------------
;
posh_am4clt=flt2string(decimalPlaces(field4_weighted_ave,2,True))
posh4=flt2string(decimalPlaces(field8_weighted_ave,2,True))
;maintitle=modelv+" "+" 10yrm "+varname1+" = "+posh
titletotcl="CALIPSO "+varname4+" = "+posh4
titletotcl_am4="AM4.0"+varname4+" = "+posh_am4clt



;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/) ; 15
my_levels_15posneg = (/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; plots 20 colors (19 nums) 1 less than thought
;my_levels1 = (/25,30,35,40,45,50,55,60,65,70,75,80,85,90,95/) ; 15
my_colors = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16
;my_colors_rev = (/64,61,58,55,52,49,46,43,40,37,34,30,26,22,18,12/) ; 16 --> low numbers are dark colors
my_colors_rev = (/64,58,52,46,43,40,37,34,30,26,24,21,18,15,12,9/) ; 16 --> low numbers are dark colors
my_colors_green = (/66,70,74,78,82,86,90,94,98,102,106,110,114,118,122,128/) ; 16 --> low numbers are dark colors
my_colors_posneg = (/19,25,31,37,43,49,55,61,71,77,83,89,96,102,108,114/) ; 16

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"matlab_jet")
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(4,graphic)


  res                   = True
  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@cnLinesOn         = False
  res@mpCenterLonF      = 180.
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
  res@gsnDraw           = False
  res@gsnFrame          = False
 
; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels1
  res@cnFillColors      = my_colors_green
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = titletotcl  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour1 = gsn_csm_contour_map(wks,var4calscale,res)  ; create the plot
  res@tiMainString       = titletotcl  ; add a title
  contour2 = gsn_csm_contour_map(wks,var4calscale,res)  ; create the plot
  res@tiMainString       = titletotcl_am4  ; add a title
  contour3 = gsn_csm_contour_map(wks,var_90x180,res)  ; create the plot
  res@cnLevels          = my_levels_15posneg
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = "AM4.0 - CALIPSO"; add a title
  contour4 = gsn_csm_contour_map(wks,am4tcl_bias,res)  ; create the plot

  plot(0)=contour1
  plot(1)=contour2
  plot(2)=contour3
  plot(3)=contour4

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/2,2/),resP)

end

