;***********************************************************************************
; calip_lowmedhigh.ncl
;***********************************************************************************
;
; plot global cloud fraction for low, med, and high clouds from CALIPSO simulator
;
; the calipso observations are on a 2x2 degree grid so the model output is 
; interpolated to a 2x2 degree grid before being plotted
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

; path to observations from calipso
path_obs="/net2/Levi.Silvers/data_calipso/"
;***********************************************************************************

; for 8xdaily data
path_to8xdaily="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos_8xdaily_alt40/ts/3hr/5yr/"
infile=path_to8xdaily+"atmos_8xdaily.197901-200812_cltcalipso_tmean.nc"
;infile1=path_to8xdaily+"atmos_8xdaily.197901-200812_cllcalipso_tmean.nc"
;infile2=path_to8xdaily+"atmos_8xdaily.197901-200812_clmcalipso_tmean.nc"
;infile3=path_to8xdaily+"atmos_8xdaily.197901-200812_clhcalipso_tmean.nc"

; for monthly data
path_tomonth="/archive/Levi.Silvers/data/cfmip_amip/calipso/"
;infile=path_tomonth+"atmos_8xdaily.197901-200812_cltcalipso_tmean.nc"
infile1=path_tomonth+"atmos_cmip.198001-201412.cllcalipso.month.tmn.nc"
infile2=path_tomonth+"atmos_cmip.198001-201412.clmcalipso.month.tmn.nc"
infile3=path_tomonth+"atmos_cmip.198001-201412.clhcalipso.month.tmn.nc"

infile4=path_obs+"calip_2x2xL40_avg_cll/cllcalipso_tmn_20060615_20101215.nc"
infile5=path_obs+"calip_2x2xL40_avg_clm/clmcalipso_tmn_20060615_20101215.nc"
infile6=path_obs+"calip_2x2xL40_avg_clh/clhcalipso_tmn_20060615_20101215.nc"

modelv="am4.0"

; from model
data = addfile(infile1,"r")
data2 = addfile(infile2,"r")
data3 = addfile(infile3,"r")
; from obs
data4 = addfile(infile4,"r")
data5 = addfile(infile5,"r")
data6 = addfile(infile6,"r")

print("infile for cltcalipso is: "+infile)
print("infile is: "+infile1)
print("infile is: "+infile2)
print("infile is: "+infile3)
print("infile is: "+infile4)
print("infile is: "+infile5)
print("infile is: "+infile6)

var1 = data->$varname1$(0,:,:)                                
var2 = data2->$varname2$(0,:,:)                                
var3 = data3->$varname3$(0,:,:)                                

var1@_FillValue = -1.e+30

var1cal = data4->$varname1$(:,:)                                
var1calscale=100*var1cal
var2cal = data5->$varname2$(:,:)                                
var2calscale=100*var2cal
var3cal = data6->$varname3$(:,:)                                
var3calscale=100*var3cal

var1cal@_FillValue = -1.e+30
var2cal@_FillValue = 1.e+20
var3cal@_FillValue = 1.e+20

;print("max of var1cal: "+max(var1cal))
;print("min of var1cal: "+min(var1cal))
;print("max of var2cal: "+max(var2cal))
;print("min of var2cal: "+min(var2cal))
;print("max of var3cal: "+max(var3cal))
;print("min of var3cal: "+min(var3cal))

var1calscale!0="lat"
var1calscale&lat=var1cal&lat
var1calscale!1="lon"
var1calscale&lon=var1cal&lon

;;======================================
;lat_test  = data4->lat
;;print("wah wah: "+var1calscale&lat)
;rad_test  = 4.0*atan(1.0)/180.0
;;clat_test=cos(var1calscale&lat*rad_test)
;clat_test=cos(lat_test*rad_test)
;print("latitudes: "+lat_test+" and weights: "+clat_test)
;;print("latitudes: "+car1calscale&lat+" and weights: "+clat_test)
;field_weighted_ave_test     = wgt_areaave(var1calscale,clat_test,1.0,0)
;print("3 wgt mean of field_test ="+field_weighted_ave_test)
;;======================================

var2calscale!0="lat"
var2calscale&lat=var1cal&lat
var2calscale!1="lon"
var2calscale&lon=var1cal&lon

var3calscale!0="lat"
var3calscale&lat=var1cal&lat
var3calscale!1="lon"
var3calscale&lon=var1cal&lon

print("======================================")
print("max of var1calscale: "+max(var1calscale))
print("min of var1calscale: "+min(var1calscale))
print("max of var2calscale: "+max(var2calscale))
print("min of var2calscale: "+min(var2calscale))
print("max of var3calscale: "+max(var3calscale))
print("min of var3calscale: "+min(var3calscale))
print("-------------------")

print("maximum minimum of calipso data are: "+max(var1calscale)+"  "+min(var1calscale))

print("======================================")
print("dimensions of model data: "+dimsizes(var1))
print("-------------------")

print("dimensions of calipso data: "+dimsizes(var1calscale))
print("======================================")

;  tot_cld_sum=sum(t)
;  t2=where(t.ge.100.,0.0,t)
;  tot_cld_sum2=sum(t2)
;  mean_cld=tot_cld_sum2/51840.
;  print("sum of tot_cld_amt: "+tot_cld_sum)
;  print("sum2 of tot_cld_amt: "+tot_cld_sum2)
;  print("mean of tot_cld_amt: "+mean_cld)
;------------------------------------------------------------
; the calipso data and am4 data are not on the same grid...

var_to_interpolate=var1
var2_to_interpolate=var2
var3_to_interpolate=var3

;*************************************************************
; perform conservative remapping of am4 data to 2x2 grid
;*************************************************************

var_to_interpolate!0="lat"
var_to_interpolate&lat=var1&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=var1&lon

; first set up the grid info
dimceres=dimsizes(var_to_interpolate)
print("dims of incoming variable: "+dimceres)
;ntim=dimceres(0)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ
;nlati=90 ; number of input latitude points(it is the lon points which differ


latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid

print(latS+"  "+latN+"   "+var1cal&lat(1)+"  "+var1cal&lat(89))

   opt = True 

   NLAT2x2    = 90                               ; RES   = "180x288"    
   MLON2x2    = 180                              
   LAT_2x2   = latGlobeFo(NLAT2x2, "LAT_2x2", "latitude" , "degrees_north")  
   LON_2x2     = lonGlobeFo(MLON2x2, "LON_2x2", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLATo       = NLAT2x2
   LAT_REG_2x2     = LAT_2x2({latS:latN})
; now actually do the interpolations
   interpolated_var  = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_2x2, LAT_REG_2x2, opt)
   interpolated_var2 = area_conserve_remap_Wrap (var2_to_interpolate&lon, var2_to_interpolate&lat, var2_to_interpolate,LON_2x2, LAT_REG_2x2, opt)
   interpolated_var3 = area_conserve_remap_Wrap (var3_to_interpolate&lon, var3_to_interpolate&lat, var3_to_interpolate,LON_2x2, LAT_REG_2x2, opt)
;*************************************************************

var1_90x180=interpolated_var
var2_90x180=interpolated_var2
var3_90x180=interpolated_var3

print("dimensions of interpolated model data: "+dimsizes(var1_90x180))
print("======================================")

;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = data->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))

field1_weighted_ave     = wgt_areaave(var1,clat,1.0,0)
field2_weighted_ave     = wgt_areaave(var2,clat,1.0,0)
field3_weighted_ave     = wgt_areaave(var3,clat,1.0,0)

; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
;print("raw global mean of "+varname1+" is: "+field1_weighted_ave)
;print("raw global mean of "+varname2+" is: "+field2_weighted_ave)
;print("raw global mean of "+varname3+" is: "+field3_weighted_ave)
;field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field1_weighted_ave_test)
;
rad2x2 = 4.0*atan(1.0)/90.0
clat_2x2 = cos(LAT_REG_2x2*rad2x2)
print("dims of NLAT2x2: "+dimsizes(NLAT2x2))
print("dims of LAT_REG_2x2: "+dimsizes(LAT_REG_2x2)+" dims of var1_90x180 are: "+dimsizes(var1_90x180))
print("dims of clat: "+dimsizes(clat)+" dims of var1 are: "+dimsizes(var1))
;print("clat_2x2: "+LAT_REG_2x2)
;print("And the values of lat are: "+lat)

print("??????????????????min value of var1_90x180 is: "+min(var1_90x180))
var1_90x180@_FillValue = -9.39863e+29
;var1_90x180@_FillValue = -1.e+30

var1_90x180 = where(var1_90x180.lt.0.0,var1@_FillValue,var1_90x180)
print("??????????????????min value of var1_90x180 is: "+min(var1_90x180))
field1_2x2_weighted_ave  = wgt_areaave(var1_90x180,clat_2x2,1.0,0)
;field1_2x2_weighted_ave  = wgt_areaave(var1_test,clat_2x2,1.0,0)

;---------------------------------------------------------------------
; compute latitude weighted mean values for the 2x2 data both calipso and am4

lat_cobs  = data4->lat
rad_cobs  = 4.0*atan(1.0)/180.0
clat_cobs=cos(lat_cobs*rad_cobs)

; calipso simulator data from am4.0
; low level clouds
var1_90x180_weighted_ave  = wgt_areaave(var1_90x180,clat_cobs,1.0,0)
var1_mask = where(var1calscale.eq.var1calscale@_FillValue,var1calscale@_FillValue,var1_90x180)
var1_masked_weighted_ave  = wgt_areaave(var1_mask,clat_cobs,1.0,0)

; mid level clouds
var2_90x180_weighted_ave  = wgt_areaave(var2_90x180,clat_cobs,1.0,0)
var2_mask = where(var2calscale.eq.var2calscale@_FillValue,var2calscale@_FillValue,var2_90x180)
var2_masked_weighted_ave  = wgt_areaave(var2_mask,clat_cobs,1.0,0)

; high level clouds
var3_90x180_weighted_ave  = wgt_areaave(var3_90x180,clat_cobs,1.0,0)
var3_mask = where(var3calscale.eq.var3calscale@_FillValue,var3calscale@_FillValue,var3_90x180)
var3_masked_weighted_ave  = wgt_areaave(var3_mask,clat_cobs,1.0,0)


; calipso
field4_weighted_ave     = wgt_areaave(var1calscale,clat_cobs,1.0,0)
field5_weighted_ave     = wgt_areaave(var2calscale,clat_cobs,1.0,0)
field6_weighted_ave     = wgt_areaave(var3calscale,clat_cobs,1.0,0)

print("======================================")
print("low level clouds")
print("raw global mean of 2x2 "+varname1+" is: "+field1_2x2_weighted_ave)
print("raw global mean of "+varname1+" is: "+field1_weighted_ave)

print("weighted low level am4 cal sim: "+var1_90x180_weighted_ave)
print("weighted and masked low level am4 cal sim: "+var1_masked_weighted_ave)

print("mid level clouds")
print("raw global mean of "+varname2+" is: "+field2_weighted_ave)
print("weighted mid level am4 cal sim: "+var2_90x180_weighted_ave)
print("weighted and masked mid level am4 cal sim: "+var2_masked_weighted_ave)

print("high level clouds")
print("raw global mean of "+varname3+" is: "+field3_weighted_ave)
print("weighted high level am4 cal sim: "+var3_90x180_weighted_ave)
print("weighted and masked high level am4 cal sim: "+var3_masked_weighted_ave)

print("-------------------")
print("weighted low level calipso: "+field4_weighted_ave)
print("weighted mid level calipso: "+field5_weighted_ave)
print("weighted upper level calipso: "+field6_weighted_ave)
print("======================================")
;---------------------------------------------------------------------
;
posh1=flt2string(decimalPlaces(field1_weighted_ave,2,True))
posh2=flt2string(decimalPlaces(field2_weighted_ave,2,True))
posh3=flt2string(decimalPlaces(field3_weighted_ave,2,True))
;maintitle=modelv+" "+" 10yrm "+varname1+" = "+posh
titletop=modelv+" "+varname3+" = "+posh3
titletop_bias="cal - "+modelv+" "+varname3
titlemid=modelv+" "+varname2+" = "+posh2
titlemid_bias="cal - "+modelv+" "+varname2
titlelow=modelv+" "+varname1+" = "+posh1
titlelow_bias="cal - "+modelv+" "+varname1


blah3=var3calscale-var3_90x180
blah2=var2calscale-var2_90x180
; first remap am4 data to 2x2 grid, then subtract it from calipso observations
; observations - model output
blah1=var1calscale-var1_90x180

blah1!0="lat"
blah1&lat=var1cal&lat
blah1!1="lon"
blah1&lon=var1cal&lon

blah2!0="lat"
blah2&lat=var1cal&lat
blah2!1="lon"
blah2&lon=var1cal&lon

blah3!0="lat"
blah3&lat=var1cal&lat
blah3!1="lon"
blah3&lon=var1cal&lon


;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/) ; 15
my_levels_15posneg = (/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; plots 20 colors (19 nums) 1 less than thought
;my_levels1 = (/25,30,35,40,45,50,55,60,65,70,75,80,85,90,95/) ; 15

my_colors_gr = (/65,70,76,80,84,88,92,96,100,104,108,112,116,120,124,128/) ; 16
my_colors = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16
my_colors_rev = (/64,61,58,55,52,49,46,43,40,37,34,30,26,22,18,12/) ; 16 --> low numbers are dark colors
;my_colors_rev = (/64,58,52,46,43,40,37,34,30,26,24,21,18,15,12,9/) ; 16 --> low numbers are dark colors
my_colors_posneg = (/19,25,31,37,43,49,55,61,71,77,83,89,96,102,108,114/) ; 16

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"matlab_jet")
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(6,graphic)


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
  res@cnFillColors      = my_colors_gr
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = titletop  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour1 = gsn_csm_contour_map(wks,var3calscale,res)  ; create the plot
  res@tiMainString       = titlemid  ; add a title
  contour2 = gsn_csm_contour_map(wks,var2calscale,res)  ; create the plot
  res@tiMainString       = titlelow  ; add a title
  contour3 = gsn_csm_contour_map(wks,var1calscale,res)  ; create the plot

  res@cnLevels          = my_levels_15posneg
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = titletop_bias  ; add a title
  contour4 = gsn_csm_contour_map(wks,blah3,res)  ; create the plot
  res@tiMainString       = titlemid_bias  ; add a title
  contour5 = gsn_csm_contour_map(wks,blah2,res)  ; create the plot
  res@tiMainString       = titlelow_bias  ; add a title
  contour6 = gsn_csm_contour_map(wks,blah1,res)  ; create the plot

  plot(0)=contour1
  plot(1)=contour4
  plot(2)=contour2
  plot(3)=contour5
  plot(4)=contour3
  plot(5)=contour6

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/3,2/),resP)

end

