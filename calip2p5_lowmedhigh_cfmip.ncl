;***********************************************************************************
; calip2p5_lowmedhigh_cfmip.ncl
;***********************************************************************************
;
; plot global cloud fraction for low, med, and high clouds from CALIPSO simulator
;
; the calipso observations are on a 2.5x2.5 degree grid so the model output is 
; interpolated to a 2x2 degree grid before being plotted
;
; figurenumber is a switch that determines which of 3 figures will be output
; figurenumber 3  plots cloud fraction as a function of latitude for 
;                 amipp4k amipfuture and amip
; figurenumber 4  plots cloud fraction as a function of latitude for high, mid, 
;                 and low-level clouds
;
; data from model output via the calipso simulator is accessed with:
; infile1, infile2, and infile3
;
; data from calipso observations is accessed with:
; infile4, infile5, and infile6
;
; levi silvers							jun 2018
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

; path on archive
path_on_archive="/archive/Levi.Silvers/CMIP6/cfmip_clouds/"
; path to data on mac
path_on_mac="/Users/silvers/data/cfmip_clouds/"
;
path_to_data=path_on_mac
;***********************************************************************************

; for 8xdaily data
;path_to8xdaily="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos_8xdaily_alt40/ts/3hr/5yr/"
;infile=path_to8xdaily+"atmos_8xdaily.197901-200812_cltcalipso_tmean.nc"
;infile1=path_to8xdaily+"atmos_8xdaily.197901-200812_cllcalipso_tmean.nc"
;infile2=path_to8xdaily+"atmos_8xdaily.197901-200812_clmcalipso_tmean.nc"
;infile3=path_to8xdaily+"atmos_8xdaily.197901-200812_clhcalipso_tmean.nc"

; for monthly data

; the default experiment to read here should be AM4 amip
expname="AM4 amip" 
;path_tomonth="/archive/Levi.Silvers/data/cfmip_amip/calipso/"
;infile1=path_tomonth+"atmos_cmip.198001-201412.cllcalipso.month.tmn.nc"
;infile2=path_tomonth+"atmos_cmip.198001-201412.clmcalipso.month.tmn.nc"
;infile3=path_tomonth+"atmos_cmip.198001-201412.clhcalipso.month.tmn.nc"
infile1=path_to_data+"atmos_cmip.197901-201412.cllcalipso.nc"
infile2=path_to_data+"atmos_cmip.197901-201412.clmcalipso.nc"
infile3=path_to_data+"atmos_cmip.197901-201412.clhcalipso.nc"
;
;-------------------------------------------------------------------------------------------- 
; the files below are to be used in the case of figurenumber=4
;-------------------------------------------------------------------------------------------- 
title_lg2="amip p4K"
;title_lg2="aqua control"
title_lg3="amip m4K"
title_lg1="am4 amip"
;  aqua control
filetoread_aqh="clhcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aqm="clmcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aql="cllcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
;  aqua control lwoff 
filetoread_aqlw_h="clhcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aqlw_m="clmcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aqlw_l="cllcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
;  aqua p4K
filetoread_aqp4_h="clhcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aqp4_h="clmcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
filetoread_aqp4_h="cllcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"

; amip p4K
filetoread_amp4_h="clhcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amp4_m="clmcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amp4_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
; test amip p4K
;filetoread_amp4_h="clhcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
;filetoread_amp4_m="clmcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
;filetoread_amp4_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
; 
;filetoread_amp4_h="clhcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
;filetoread_amp4_m="clmcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
;filetoread_amp4_l="cllcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
; amip p4K lwoff
filetoread_amp4lw_h="clhcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amp4lw_m="clmcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amp4lw_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
; amip m4K
filetoread_amm4_h="clhcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amm4_m="clmcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
filetoread_amm4_l="cllcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
;-------------------------------------------------------------------------------------------- 

infile_h=path_to_data+filetoread_amm4_h
data_h = addfile(infile_h,"r")
print("infile for test is: "+infile_h)
var_full_h=data_h->$varname3$(:,:,:)
print("dimenstions of test shovels: "+dimsizes(var_full_h))
var_h=dim_avg_n(var_full_h,0)
print("dimenstions of test shovels: "+dimsizes(var_h))
;-------------------------------------------------------------------------------------------- 

path_obs="/Users/silvers/data/SatData/CALIPSO/"

;infile_calobs=path_obs+"from_Greg_Jan2017/MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"
infile_calobs=path_obs+"MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"

modelv="am4.0"

; compute pi
PI=acos(-1.)

; amip data from model
data = addfile(infile1,"r")    ; low clouds
data2 = addfile(infile2,"r")   ; mid level clouds
data3 = addfile(infile3,"r")   ; high clouds
; from obs
data_calobs = addfile(infile_calobs,"r")

print("infile is: "+infile1)
print("infile is: "+infile2)
print("infile is: "+infile3)
print("infile calipso obs is: "+infile_calobs)

;var1 = data->$varname1$(0,:,:)  ; low                               
;var2 = data2->$varname2$(0,:,:)                                
;var3 = data3->$varname3$(0,:,:)                                
var1_full = data->$varname1$(:,:,:)  ; low                               
var1=dim_avg_n(var1_full,0)
var2_full = data2->$varname2$(:,:,:)                                
var2=dim_avg_n(var2_full,0)
var3_full = data3->$varname3$(:,:,:)                                
var3=dim_avg_n(var3_full,0)

var1!0="lat"
var1&lat=var1_full&lat
var1!1="lon"
var1&lon=var1_full&lon
var2!0="lat"
var2&lat=var2_full&lat
var2!1="lon"
var2&lon=var2_full&lon
var3!0="lat"
var3&lat=var3_full&lat
var3!1="lon"
var3&lon=var3_full&lon



print("heck with this: "+dimsizes(var2))
print("heck with this varnew: "+dimsizes(var3))

latitude_model=data->lat(:)

var1@_FillValue = -1.e+30

; if using calipso data between 200701-201612
var1cal = data_calobs->$varname1$(0,:,:) ; low                               
var1calscale=100*var1cal
var2cal = data_calobs->$varname2$(0,:,:)                                
var2calscale=100*var2cal
var3cal = data_calobs->$varname3$(0,:,:)                                
var3calscale=100*var3cal
latitude=data_calobs->latitude(:)
printVarSummary(latitude)

var1cal@_FillValue = 1.e+20
var2cal@_FillValue = 1.e+20
var3cal@_FillValue = 1.e+20

var1calscale!0="lat"
var1calscale&lat=var1cal&latitude
var1calscale!1="lon"
var1calscale&lon=var1cal&longitude

var2calscale!0="lat"
var2calscale&lat=var1cal&latitude
var2calscale!1="lon"
var2calscale&lon=var1cal&longitude

var3calscale!0="lat"
var3calscale&lat=var1cal&latitude
var3calscale!1="lon"
var3calscale&lon=var1cal&longitude

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

printVarSummary(var1cal)
print("======================================")

;------------------------------------------------------------
; the calipso data and am4 data are not on the same grid...

var_to_interpolate=var1
var2_to_interpolate=var2
var3_to_interpolate=var3

;*************************************************************
; perform conservative remapping of am4 data to 2.5x2.5 grid
;*************************************************************

var_to_interpolate!0="lat"
var_to_interpolate&lat=var1&lat
var_to_interpolate!1="lon"
var_to_interpolate&lon=var1&lon

; first set up the grid info
dimceres=dimsizes(var_to_interpolate)
print("dims of incoming variable: "+dimceres)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ
nloni=288

print("lon at 0="+var_to_interpolate&lon(0))
print("lon at "+nlon+"-1="+var_to_interpolate&lon(nlon-1))


latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid
lonE=tofloat(var_to_interpolate&lon(0))                      ; southern extent of input grid
lonW=tofloat(var_to_interpolate&lon(nlon-1))                 ; northern extent of input grid

print(latS+"  "+latN+"   "+var1cal&latitude(1)+"  "+var1cal&latitude(71))

   opt = True 

   NLAT2p5x2p5    = 72                               ; RES   = "180x288"    
   MLON2p5x2p5    = 144                             
   LAT_2p5x2p5   = latGlobeFo(NLAT2p5x2p5, "LAT_2p5x2p5", "latitude" , "degrees_north")  
   LON_2p5x2p5     = lonGlobeFo(MLON2p5x2p5, "LON_2p5x2p5", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLONi       = nloni 
   opt@NLATo       = NLAT2p5x2p5
   opt@NLONo       = MLON2p5x2p5
   LAT_REG_2p5x2p5     = LAT_2p5x2p5({latS:latN})
   LON_REG_2p5x2p5     = LON_2p5x2p5({lonE:lonW})
; now actually do the interpolations
   interpolated_var  = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var2 = area_conserve_remap_Wrap (var2_to_interpolate&lon, var2_to_interpolate&lat, var2_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var3 = area_conserve_remap_Wrap (var3_to_interpolate&lon, var3_to_interpolate&lat, var3_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
;*************************************************************

var1_90x180=interpolated_var
var2_90x180=interpolated_var2
var3_90x180=interpolated_var3

var1_90x180!0="lat"
var1_90x180&lat=var1cal&latitude
var1_90x180!1="lon"
var1_90x180&lon=var1cal&longitude

var2_90x180!0="lat"
var2_90x180&lat=var1cal&latitude
var2_90x180!1="lon"
var2_90x180&lon=var1cal&longitude

var3_90x180!0="lat"
var3_90x180&lat=var1cal&latitude
var3_90x180!1="lon"
var3_90x180&lon=var1cal&longitude

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
;
  rad2p5x2p5 = 4.0*atan(1.0)/180.0
  clat_2p5x2p5 = cos(LAT_REG_2p5x2p5*rad2p5x2p5)
print("dims of NLAT2p5x2p5: "+dimsizes(NLAT2p5x2p5))
print("dims of LAT_REG_2p5x2p5: "+dimsizes(LAT_REG_2p5x2p5)+" dims of var1_90x180 are: "+dimsizes(var1_90x180))
print("dims of clat: "+dimsizes(clat)+" dims of var1 are: "+dimsizes(var1))
;print("clat_2p5x2p5: "+LAT_REG_2p5x2p5)
;print("And the values of lat are: "+lat)

print("??????????????????min value of var1_90x180 is: "+min(var1_90x180))
  var1_90x180@_FillValue = -9.39863e+29

  var1_90x180 = where(var1_90x180.lt.0.0,var1@_FillValue,var1_90x180)
print("??????????????????min value of var1_90x180 is: "+min(var1_90x180))
  field1_2p5x2p5_weighted_ave  = wgt_areaave(var1_90x180,clat_2p5x2p5,1.0,0)
  field2_2p5x2p5_weighted_ave  = wgt_areaave(var2_90x180,clat_2p5x2p5,1.0,0)
  field3_2p5x2p5_weighted_ave  = wgt_areaave(var3_90x180,clat_2p5x2p5,1.0,0)
  ;field1_2p5x2p5_weighted_ave  = wgt_areaave(var1_test,clat_2p5x2p5,1.0,0)

;---------------------------------------------------------------------
; compute latitude weighted mean values for the 2p5x2p5 data both calipso and am4

lat_cobs  = data_calobs->latitude
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


; calipso observations
field4_weighted_ave     = wgt_areaave(var1calscale,clat_cobs,1.0,0)
field5_weighted_ave     = wgt_areaave(var2calscale,clat_cobs,1.0,0)
field6_weighted_ave     = wgt_areaave(var3calscale,clat_cobs,1.0,0)

; compute biases
lcf_bias=field1_weighted_ave-field4_weighted_ave
mcf_bias=field2_weighted_ave-field5_weighted_ave
hcf_bias=field3_weighted_ave-field6_weighted_ave

print("======================================")
print("low level clouds")
print("raw(bef interp) global mean from simulator "+varname1+" is: "+field1_weighted_ave)
print("raw(aft interp) global mean from simulator "+varname1+" is: "+field1_2p5x2p5_weighted_ave)
print("weighted low level am4 cal sim: "+var1_90x180_weighted_ave)
print("weighted and masked low level am4 cal sim: "+var1_masked_weighted_ave)
print("low level cloud fraction bias: "+lcf_bias)

print("mid level clouds")
print("raw(bef interp) global mean from simulator "+varname2+" is: "+field2_weighted_ave)
print("raw(aft interp) global mean from simulator "+varname2+" is: "+field2_2p5x2p5_weighted_ave)
print("weighted mid level am4 cal sim: "+var2_90x180_weighted_ave)
print("weighted and masked mid level am4 cal sim: "+var2_masked_weighted_ave)
print("mid level cloud fraction bias: "+mcf_bias)

print("high level clouds")
print("raw global mean of "+varname3+" is: "+field3_weighted_ave)
print("weighted high level am4 cal sim: "+var3_90x180_weighted_ave)
print("weighted and masked high level am4 cal sim: "+var3_masked_weighted_ave)
print("high level cloud fraction bias: "+hcf_bias)

print("-------------------")
print("weighted low level calipso obs:   "+field4_weighted_ave)
print("weighted mid level calipso obs:   "+field5_weighted_ave)
print("weighted upper level calipso obs: "+field6_weighted_ave)
print("======================================")
;---------------------------------------------------------------------
;
;---------------------------------------------------------------------
; create strings from the global mean values of cloud fraction
;---------------------------------------------------------------------
posh1=flt2string(decimalPlaces(field1_weighted_ave,1,True))
obs_cal_lcf_wmn=flt2string(decimalPlaces(field4_weighted_ave,1,True))
lowcf_bias=flt2string(decimalPlaces(lcf_bias,1,True))
posh2=flt2string(decimalPlaces(field2_weighted_ave,1,True))
obs_cal_mcf_wmn=flt2string(decimalPlaces(field5_weighted_ave,1,True))
midcf_bias=flt2string(decimalPlaces(mcf_bias,1,True))
posh3=flt2string(decimalPlaces(field3_weighted_ave,1,True)) ; high clouds
obs_cal_hcf_wmn=flt2string(decimalPlaces(field6_weighted_ave,1,True))
highcf_bias=flt2string(decimalPlaces(hcf_bias,1,True))
;maintitle=modelv+" "+" 10yrm "+varname1+" = "+posh
titletop=modelv+" "+varname3+" = "+posh3
titletop_calobs="CAL "+" "+obs_cal_hcf_wmn
titletop_bias="cal - "+modelv+" "+varname3
titlemid=modelv+" "+varname2+" = "+posh2
titlemid_calobs="CAL "+" "+obs_cal_mcf_wmn
;titlemid_bias="cal - "+modelv+" "+varname2
titlemid_bias="cal - "+modelv+" "+varname2
titlelow=modelv+" "+varname1+" = "+posh1
titlelow_calobs="CAL "+" "+obs_cal_lcf_wmn
titlelow_bias="cal - "+modelv+" "+varname1

; compute zonal mean 
var3calscale_zmn=dim_avg_n(var3calscale,1)
var2calscale_zmn=dim_avg_n(var2calscale,1)
var1calscale_zmn=dim_avg_n(var1calscale,1)
;printVarSummary(var3calscale_zmn)

var3_90x180_zmn=dim_avg_n(var3_90x180,1)
var2_90x180_zmn=dim_avg_n(var2_90x180,1)
var1_90x180_zmn=dim_avg_n(var1_90x180,1)

var1_zmn=dim_avg_n(var1,1)

; compute the bias between simulator and observations
; observations - simulator (model)
print("dimsizes of var3calscale ="+dimsizes(var3calscale)+"  dimsizes of var3_90x180 ="+dimsizes(var3_90x180))
blah3=var3calscale-var3_90x180
blah2=var2calscale-var2_90x180
blah1=var1calscale-var1_90x180

; for some reason the longitudes for one of the data sets was shifted by half, this corrects it.
do n=0,71
  do m=0,143
      if (m .lt. 72) then ; should 0:71
        blah3(n,m+72)=var3calscale(n,m+72)-var3_90x180(n,m)
        blah2(n,m+72)=var2calscale(n,m+72)-var2_90x180(n,m)
        blah1(n,m+72)=var1calscale(n,m+72)-var1_90x180(n,m)
    else ; should begin at 72 and end at 143
        blah3(n,m-72)=var3calscale(n,m-72)-var3_90x180(n,m)
        blah2(n,m-72)=var2calscale(n,m-72)-var2_90x180(n,m)
        blah1(n,m-72)=var1calscale(n,m-72)-var1_90x180(n,m)
    end if
  end do
end do

blah1!0="lat"
blah1&lat=var1cal&latitude
blah1!1="lon"
blah1&lon=var1cal&longitude

blah2!0="lat"
blah2&lat=var1cal&latitude
blah2!1="lon"
blah2&lon=var1cal&longitude

blah3!0="lat"
blah3&lat=var1cal&latitude
blah3!1="lon"
blah3&lon=var1cal&longitude

bias_ave_blah1     = wgt_areaave(blah1,clat_cobs,1.0,0)
kmsg_a=num(ismissing(blah1))
print("bias_ave_blah1="+bias_ave_blah1+"    kmsg_a="+kmsg_a)

print("======================================")
print("average of blah1: "+bias_ave_blah1)
print("======================================")
print("fill values?"+blah1@_FillValue)
blah1@_FillValue=4.82843e+27
print("fill values?"+blah1@_FillValue)
bias_ave_blah1     = wgt_areaave(blah1,clat_cobs,1.0,0)
print("bias_ave_blah1="+bias_ave_blah1+"    kmsg_a="+kmsg_a)
print("dimsizes of blah1: "+dimsizes(blah1))
mx=144
ny=72
dummy=new((/ny,mx/),float)
;dum_lat=new((/ny/),float)
dummy=blah1
;printVarSummary(dummy)
;printVarSummary(blah1)
;printVarSummary(clat_cobs)
dum_lat=dble2flt(clat_cobs)
;printVarSummary(dum_lat)
xave_a=wgt_areaave(dummy,clat_cobs,1.0,0)
kmsg_b=num(ismissing(dummy))
;print("xave_a="+xave_a+"    kmsg_b="+kmsg_b)

print("is FillValue defined here?")
nmsg=num(ismissing(dummy))
print("num of missing values in dummy="+nmsg)
print("fill value of dummy is: "+dummy@FillValue)
print("is FillValue defined here?")
dummy@FillValue=4.82843e+27
print("fill value of dummy is: "+dummy@FillValue)
print("is FillValue defined here?")

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


figurenumber = 1 ; 1 is default and plots 9 panel figure
                 ; 2 plots the 3 panel figure of zonal means
                 ; 3 plots the 3 panel figure of zonal means with a linear cosine axis
                 ; 4 plots the 3 panel figure of zonal means with a linear cosine axis
if (figurenumber .lt. 2) then

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("newPDF","testplot_25")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"matlab_jet")
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(9,graphic)

; res are the resources for the global plots
; reszm are the resources for the zonal mean plots 

  res                   = True
  reszm   = True

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

 reszm@gsnDraw           = False
 reszm@gsnFrame          = False
 reszm@tiXAxisString  = "Cloud Fraction [%]"
 reszm@tiYAxisFont    = 21
 reszm@tiYAxisFontHeightF = 0.01 
 reszm@tiYAxisString  = "Latitude"
 reszm@tiXAxisFont    = 21
 reszm@tiXAxisFontHeightF = 0.01
 reszm@vpWidthF          = 0.2 
 reszm@vpHeightF         = 0.4 
 reszm@tmYLLabelFontHeightF = 0.01 
 reszm@tmXBLabelFontHeightF = 0.01 
 reszm@tmXBMode = "Automatic"
 reszm@tmYLMode = "explicit"
 reszm@trYMinF = -1 
 reszm@trYMaxF = 1
 reszm@tmYLValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 reszm@tmYRValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 reszm@tmYLLabels = (/-60,-30,0,30,60/)
 reszm@tmYLMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)
 reszm@tmYRMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)

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

  res@lbLabelFontHeightF  = 0.01           ; label bar font height

  res@tiMainString       = titletop_calobs  ; add a title
  res@tiMainFontHeightF  = .01                               ; font height

  res@vpXF             = 0.25                  ; position and sizes
  res@vpYF             = 0.98                  ; for XY plot
  res@vpWidthF         = 0.32
  ;res@vpHeightF        = 0.29
  res@vpHeightF        = 0.32

  contour1 = gsn_csm_contour_map(wks,var3calscale,res)  ; create the plot
  res@tiMainString       = titlemid_calobs  ; add a title
  res@vpYF             = 0.68                  ; for XY plot
  contour2 = gsn_csm_contour_map(wks,var2calscale,res)  ; create the plot
  res@tiMainString       = titlelow_calobs  ; add a title
  res@vpYF             = 0.38                  ; for XY plot
  contour3 = gsn_csm_contour_map(wks,var1calscale,res)  ; create the plot

  res@vpXF             = 0.62                  ; position and sizes
  res@vpYF             = 0.98                  ; for XY plot
;  res@vpWidthF         = 0.30
;  res@vpHeightF        = 0.27

  res@cnLevels          = my_levels_15posneg
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = "CAL-AM4.0 = "+highcf_bias ; add a title
  contour4 = gsn_csm_contour_map(wks,blah3,res)  ; create the plot
  res@tiMainString       = "CAL-AM4.0 = "+midcf_bias; add a title
  res@vpYF             = 0.68                  ; for XY plot
  contour5 = gsn_csm_contour_map(wks,blah2,res)  ; create the plot
  res@tiMainString       = "CAL-AM4.0 = "+lowcf_bias  ; add a title
  res@vpYF             = 0.38                  ; for XY plot
  contour6 = gsn_csm_contour_map(wks,blah1,res)  ; create the plot

; top row zonal mean 
 reszm@vpXF           = 0.05                  ; position and sizes
 reszm@vpYF           = 0.92                  ; for XY plot
 reszm@vpWidthF       = 0.13
 reszm@vpHeightF      = 0.20

 reszm@trXMinF = 15
 reszm@trXMaxF = 55
 reszm@xyDashPattern=16
 reszm@xyDashPattern=0
 reszm@xyLineColors="black"
 plotta=gsn_csm_xy(wks,var3calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyDashPattern=16
 plottb=gsn_csm_xy(wks,var3_90x180_zmn(:),sin(latitude(:)/180*PI),reszm)

 overlay(plotta,plottb)
 plot(0)=plotta

; middle row zonal mean 
 reszm@vpYF           = 0.62                  ; for XY plot

 reszm@trXMinF = 0
 reszm@trXMaxF = 40
 reszm@xyDashPattern=0
 reszm@xyLineColors="black"
 plotma=gsn_csm_xy(wks,var2calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyDashPattern=16
 plotmb=gsn_csm_xy(wks,var2_90x180_zmn(:),sin(latitude(:)/180*PI),reszm)
; plotmb=gsn_csm_xy(wks,var1_zmn(:),sin(latitude_model(:)/180*PI),res)

 overlay(plotma,plotmb)
 plot(3)=plotma

; bottom row zonal mean 
; reszm@vpYF           = 0.04                  ; for XY plot
 reszm@vpYF           = 0.32                  ; for XY plot

 reszm@trXMinF = 5
 reszm@trXMaxF = 70
 reszm@xyDashPattern=0
 plotba=gsn_csm_xy(wks,var1calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyDashPattern=16
; plot0b=gsn_csm_xy(wks,var1_90x180_zmn(:),sin(latitude(:)/180*PI),reszm)
 plotbb=gsn_csm_xy(wks,var1_zmn(:),sin(latitude_model(:)/180*PI),reszm)
 
 overlay(plotba,plotbb)
; plot(6)=plotba

; top row
  plot(0)=plotta
  plot(1)=contour1
  plot(2)=contour4
; middle row
  plot(3)=plotma
  plot(4)=contour2
  plot(5)=contour5
; bottom row
  plot(6)=plotba
  plot(7)=contour3
  plot(8)=contour6

psres=True
maximize_output(wks,psres) ; calls draw and frame
;  resP                  = True                   ; modify the panel plot
;  resP@gsnFrame         = False                  ; don't advance panel plot
;
;  gsn_panel(wks,plot,(/3,3/),resP)
else if (figurenumber .lt. 3) then
;end if 
; wks   = gsn_open_wks ("newPDF","testplot")
 wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
 plot = new(3,graphic)

  res   = True
 res@tiMainString = "Upper-Level Cloud Fraction"
 ;res@tiMainString = "d" 
 res@tiMainFont = 21
 res@tiMainFontHeightF = 0.02
 res@tiYAxisString  = "Cloud Fraction [%]"
 res@tiYAxisFont    = 21
 res@tiYAxisFontHeightF = 0.02 
 res@tiXAxisString  = "Latitude"
 res@tiXAxisFont    = 21
 res@tiXAxisFontHeightF = 0.02

 ;res@tiMainOffsetYF = -0.018
 ;res@tiMainOffsetXF = -0.17

 res@vpWidthF          = 0.5 
 res@vpHeightF         = 0.5 

 res@tmYLLabelFontHeightF = 0.02 
 res@tmXBLabelFontHeightF = 0.02 

 res@tmXBMode = "explicit"
 res@tmXBValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 res@tmXBLabels = (/-60,-30,0,30,60/)
 res@tmXBMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)


 res@gsnDraw         = False
 res@gsnFrame         = False
 

 res@trYMinF = 15
 res@trYMaxF = 55
 ;plot(0)=gsn_csm_xy(wks,sin(lat(:)/180*PI),lat_swdn_toa_clr(:,:)-lat_swdn_sfc_clr(:,:),res)
 res@xyLineColors="blue"
 plot0a=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var3calscale_zmn(:),res)
 res@xyLineColors="black"
 plot0b=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var3_90x180_zmn(:),res)
 
 overlay(plot0a,plot0b)
 plot(0)=plot0a

 res@trYMinF = 0
 res@trYMaxF = 40
 res@tiMainString = "Mid-Level Cloud Fraction"
 res@xyLineColors="blue"
 plot1a=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var2calscale_zmn(:),res)
 res@xyLineColors="black"
 plot1b=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var2_90x180_zmn(:),res)

 overlay(plot1a,plot1b)
 plot(1)=plot1a

 ;res@trXMinF = 5
 ;res@trXMaxF = 70
 ;res@tiYAxisString  = "Latitude"
 ;res@tiXAxisString  = "Cloud Fraction [%]"
 ;res@tmXBMode = "Automatic"
 ;res@tmYLMode = "explicit"
 ;res@trYMinF = -1 
 ;res@trYMaxF = 1
 res@trYMinF = 5 
 res@trYMaxF = 70 
 res@tmXLValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 res@tmXRValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 res@tmXLLabels = (/-60,-30,0,30,60/)
 res@tmXLMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)
 res@tmXRMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)
 res@xyLineColors="blue"
 res@tiMainString = "Low-Level Cloud Fraction"
 plot2a=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var1calscale_zmn(:),res)
 ;plot2a=gsn_csm_xy(wks,var1calscale_zmn(:),sin(latitude(:)/180*PI),res)
 res@xyLineColors="black"
 ;plot2b=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var1_90x180_zmn(:),res)
 plot2c=gsn_csm_xy(wks,sin(latitude_model(:)/180*PI),var1_zmn(:),res)
 ;plot2c=gsn_csm_xy(wks,var1_zmn(:),sin(latitude_model(:)/180*PI),res)

 
 ;overlay(plot2a,plot2b)
 overlay(plot2a,plot2c)
 plot(2)=plot2a

;var3calscale_zmn=dim_avg_n(var3calscale,1)

; draw panel with white space added
 resP                 = True
 resP@gsnPanelYWhiteSpacePercent = 5
 resP@gsnPanelXWhiteSpacePercent = 5
 gsn_panel(wks,plot,(/2,2/),resP)

  print("blabichra")
else if (figurenumber .lt. 4) then
; ------------------------------------------------------------------------------------
;
; read in additional dta from other experiments

expname="amip-p4K"
;title_lg2="amip p4K"
;filetoread_amp4_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile1a_l=path_to_data+filetoread_amp4_l
infile1a_m=path_to_data+filetoread_amp4_m
infile1a_h=path_to_data+filetoread_amp4_h
;infile1a="/archive/Oar.Gfdl.Mgrp-account/CMIP6/CM4/CFMIP/warsaw_201803/amip-p4K-a/gfdl.ncrc4-intel-prod-openmp/pp/atmos_cmip/av/monthly_36yr/atmos_cmip.1979-2014.tmn2.nc"

;expname="amip-future4K"
expname="amip-m4K"
;title_lg3="amip future4K"
;title_lg3="amip m4K"
;filetoread_amm4_h
infile1b_l=path_to_data+filetoread_amm4_l
infile1b_m=path_to_data+filetoread_amm4_m
infile1b_h=path_to_data+filetoread_amm4_h
;infile1b="/archive/Oar.Gfdl.Mgrp-account/CMIP6/CM4/CFMIP/warsaw_201803/CM4_amip_future4K/gfdl.ncrc4-intel-prod-openmp/pp/atmos_cmip/av/monthly_36yr/atmos_cmip.1979-2014.tmn2.nc"

;title_lg2="amip p4K"
;title_lg3="amip m4K"
;title_lg1="am4 amip"

data_1a_l = addfile(infile1a_l,"r")
data_1a_m = addfile(infile1a_m,"r")
data_1a_h = addfile(infile1a_h,"r")
data_1b_l = addfile(infile1b_l,"r")
data_1b_m = addfile(infile1b_m,"r")
data_1b_h = addfile(infile1b_h,"r")

print("what is this file name>? "+infile1a_m)

var1a_full = data_1a_l->$varname1$(:,:,:) ; low                               
var1a=dim_avg_n(var1a_full,0)
var1b_full = data_1b_l->$varname1$(:,:,:)                                
var1b=dim_avg_n(var1b_full,0)
var2a_full = data_1a_m->$varname2$(:,:,:) ; mid                               
var2a=dim_avg_n(var2a_full,0)
var2b_full = data_1b_m->$varname2$(:,:,:)                                
var2b=dim_avg_n(var2b_full,0)
var3a_full = data_1a_h->$varname3$(:,:,:)                                
var3a=dim_avg_n(var3a_full,0)
var3b_full = data_1b_h->$varname3$(:,:,:) ; high                               
var3b=dim_avg_n(var3b_full,0)

print("dimsizes of var1a are: "+dimsizes(var1a))

; the dimensions appear to get overwritten when the dim_avg_n function is used
var1a!0="lat"
var1a&lat=var1a_full&lat
var1a!1="lon"
var1a&lon=var1a_full&lon

var1b!0="lat"
var1b&lat=var1b_full&lat
var1b!1="lon"
var1b&lon=var1b_full&lon

var2a!0="lat"
var2a&lat=var2a_full&lat
var2a!1="lon"
var2a&lon=var2a_full&lon

var2b!0="lat"
var2b&lat=var2b_full&lat
var2b!1="lon"
var2b&lon=var2b_full&lon

var3a!0="lat"
var3a&lat=var3a_full&lat
var3a!1="lon"
var3a&lon=var3a_full&lon

var3b!0="lat"
var3b&lat=var3b_full&lat
var3b!1="lon"
var3b&lon=var3b_full&lon


latitude_model=data_1a_m->lat(:)

; the interpolated low-level cloud amount has problematic values where the surface
; is encountered, for zonal means, just use the uniterpolated values... 
var1s_zmn=dim_avg_n(var1a,1)
var1u_zmn=dim_avg_n(var1b,1)
;*************************************************************
;*************************************************************
var1_to_interpolate=var1a
var2_to_interpolate=var2a
var3_to_interpolate=var3a
var1b_to_interpolate=var1b
var2b_to_interpolate=var2b
var3b_to_interpolate=var3b


;*************************************************************
; perform conservative remapping of am4 data to 2.5x2.5 grid
;*************************************************************

var1_to_interpolate!0="lat"
var1_to_interpolate&lat=var1&lat
var1_to_interpolate!1="lon"
var1_to_interpolate&lon=var1&lon

; first set up the grid info
dimceres=dimsizes(var1_to_interpolate)
print("dims of incoming variable: "+dimceres)
nlat=dimceres(0)
nlon=dimceres(1)

nlati=180 ; number of input latitude points(it is the lon points which differ
nloni=288

print("lon at 0="+var1_to_interpolate&lon(0))
print("lon at "+nlon+"-1="+var1_to_interpolate&lon(nlon-1))


latS=tofloat(var1_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var1_to_interpolate&lat(nlat-1))                 ; northern extent of input grid
lonE=tofloat(var1_to_interpolate&lon(0))                      ; southern extent of input grid
lonW=tofloat(var1_to_interpolate&lon(nlon-1))                 ; northern extent of input grid

print(latS+"  "+latN+"   "+var1cal&latitude(1)+"  "+var1cal&latitude(71))

   opt = True 

   NLAT2p5x2p5    = 72                               ; RES   = "180x288"    
   MLON2p5x2p5    = 144                             
   LAT_2p5x2p5   = latGlobeFo(NLAT2p5x2p5, "LAT_2p5x2p5", "latitude" , "degrees_north")  
   LON_2p5x2p5     = lonGlobeFo(MLON2p5x2p5, "LON_2p5x2p5", "longitude", "degrees_east" ) 

   opt@NLATi       = nlati 
   opt@NLONi       = nloni 
   opt@NLATo       = NLAT2p5x2p5
   opt@NLONo       = MLON2p5x2p5
   LAT_REG_2p5x2p5     = LAT_2p5x2p5({latS:latN})
   LON_REG_2p5x2p5     = LON_2p5x2p5({lonE:lonW})
; now actually do the interpolations
   interpolated_var1 = area_conserve_remap_Wrap (var1_to_interpolate&lon, var1_to_interpolate&lat, var1_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var2 = area_conserve_remap_Wrap (var2_to_interpolate&lon, var2_to_interpolate&lat, var2_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var3 = area_conserve_remap_Wrap (var3_to_interpolate&lon, var3_to_interpolate&lat, var3_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)

   interpolated_var1b = area_conserve_remap_Wrap (var1b_to_interpolate&lon, var1b_to_interpolate&lat, var1b_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var2b = area_conserve_remap_Wrap (var2b_to_interpolate&lon, var2b_to_interpolate&lat, var2b_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
   interpolated_var3b = area_conserve_remap_Wrap (var3b_to_interpolate&lon, var3b_to_interpolate&lat, var3b_to_interpolate,LON_REG_2p5x2p5, LAT_REG_2p5x2p5, opt)
;*************************************************************


var1s_90x180=interpolated_var1
var2s_90x180=interpolated_var2
var3s_90x180=interpolated_var3

var1s_90x180!0="lat"
var1s_90x180&lat=var1cal&latitude
var1s_90x180!1="lon"
var1s_90x180&lon=var1cal&longitude

var2s_90x180!0="lat"
var2s_90x180&lat=var1cal&latitude
var2s_90x180!1="lon"
var2s_90x180&lon=var1cal&longitude

var3s_90x180!0="lat"
var3s_90x180&lat=var1cal&latitude
var3s_90x180!1="lon"
var3s_90x180&lon=var1cal&longitude

var1u_90x180=interpolated_var1b
var2u_90x180=interpolated_var2b
var3u_90x180=interpolated_var3b

var1u_90x180!0="lat"
var1u_90x180&lat=var1cal&latitude
var1u_90x180!1="lon"
var1u_90x180&lon=var1cal&longitude

var2u_90x180!0="lat"
var2u_90x180&lat=var1cal&latitude
var2u_90x180!1="lon"
var2u_90x180&lon=var1cal&longitude

var3u_90x180!0="lat"
var3u_90x180&lat=var1cal&latitude
var3u_90x180!1="lon"
var3u_90x180&lon=var1cal&longitude

print("dimensions of interpolated model data: "+dimsizes(var1_90x180))
print("======================================")
;*************************************************************
;*************************************************************

; compute zonal mean 
var3u_90x180_zmn=dim_avg_n(var3u_90x180,1)
var2u_90x180_zmn=dim_avg_n(var2u_90x180,1)
var1u_90x180_zmn=dim_avg_n(var1u_90x180,1)
var3s_90x180_zmn=dim_avg_n(var3s_90x180,1)
var2s_90x180_zmn=dim_avg_n(var2s_90x180,1)
var1s_90x180_zmn=dim_avg_n(var1s_90x180,1)


;*************************************************************
 ;wks   = gsn_open_wks ("newPDF","testplot")
 wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
 plot = new(3,graphic)

; resources for the panels, and the legend
 res                        = True
 lgres                      = True

 fontsize=0.03

 res@tiMainString = "Upper-Level Cloud Fraction"
 res@tiMainFont = 21
 res@tiMainFontHeightF = fontsize
 res@tiYAxisString  = "Cloud Fraction [%]"
 res@tiYAxisFont    = 21
 res@tiYAxisFontHeightF = fontsize 
 res@tiXAxisString  = "Latitude"
 res@tiXAxisFont    = 21
 res@tiXAxisFontHeightF = fontsize

 res@vpWidthF          = 1.2 
 res@vpHeightF         = 0.5 

 res@tmYLLabelFontHeightF = fontsize 
 res@tmXBLabelFontHeightF = fontsize

 lthick=3.0
 res@xyLineThicknessF     = lthick
 res@tmXBMode = "explicit"
 res@tmXBValues = (/-60,-30,0,30,60/)
 res@tmXBLabels = (/-60,-30,0,30,60/)
 res@tmXBMinorValues =(/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)

; here is where the colors, line styles, and string names are defined 
; colors = (/"LawnGreen","SteelBlue","GoldenRod","Black"/);,"OrangeRed"/) 
 ;colors = (/"black","darkgoldenrod","darkolivegreen3","chocolate"/) 
 colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue"/) 
 lgres@lgLineColors  = (/colors(1),colors(2),colors(3),colors(0)/)
 lgres@lgDashIndexes = (/"0","0","0","0"/)
 labels = (/title_lg1,title_lg2,title_lg3,"Observations"/) ; bottom to top
 ; the plotting order is: observations,r,s,u ; top to bottom

 res@gsnDraw         = False
 res@gsnFrame         = False

plotbias=1 ; default is to not plot the bias
var3s_bias=var3s_90x180_zmn-var3_90x180_zmn
var3u_bias=var3u_90x180_zmn-var3_90x180_zmn
zero3_bias=var3_90x180_zmn-var3_90x180_zmn

if (plotbias .gt. 0) then
 res@trYMinF = -10 
 res@trYMaxF = 10 
 res@xyLineColors=colors(0)
 plot0a=gsn_csm_xy(wks,latitude(:),var3calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 plot0b=gsn_csm_xy(wks,latitude(:),zero3_bias(:),res)
 res@xyLineColors=colors(2)
 plot0c=gsn_csm_xy(wks,latitude(:),var3s_bias(:),res)
 res@xyLineColors=colors(3)
 plot0d=gsn_csm_xy(wks,latitude(:),var3u_bias(:),res)
else
 res@trYMinF = 15
 res@trYMaxF = 55
 res@xyLineColors=colors(0)
 plot0a=gsn_csm_xy(wks,latitude(:),var3calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 plot0b=gsn_csm_xy(wks,latitude(:),var3_90x180_zmn(:),res)
 res@xyLineColors=colors(2)
 plot0c=gsn_csm_xy(wks,latitude(:),var3s_90x180_zmn(:),res)
 res@xyLineColors=colors(3)
 plot0d=gsn_csm_xy(wks,latitude(:),var3u_90x180_zmn(:),res)
end if 
 overlay(plot0a,plot0b)
 overlay(plot0a,plot0c)
 overlay(plot0a,plot0d)
 plot(0)=plot0a

var2s_bias=var2s_90x180_zmn-var2_90x180_zmn
var2u_bias=var2u_90x180_zmn-var2_90x180_zmn
zero2_bias=var2_90x180_zmn-var2_90x180_zmn

if (plotbias .gt. 0) then
 res@trYMinF = -10
 res@trYMaxF = 10
 res@tiMainString = "Mid-Level Cloud Fraction"
 res@xyLineColors=colors(0)
 plot1a=gsn_csm_xy(wks,latitude(:),var2calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 plot1b=gsn_csm_xy(wks,latitude(:),zero2_bias(:),res)
 res@xyLineColors=colors(2)
 plot1c=gsn_csm_xy(wks,latitude(:),var2s_bias(:),res)
 res@xyLineColors=colors(3)
 plot1d=gsn_csm_xy(wks,latitude(:),var2u_bias(:),res)
else
 res@trYMinF = 0
 res@trYMaxF = 40
 res@tiMainString = "Mid-Level Cloud Fraction"
 res@xyLineColors=colors(0)
 plot1a=gsn_csm_xy(wks,latitude(:),var2calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 plot1b=gsn_csm_xy(wks,latitude(:),var2_90x180_zmn(:),res)
 res@xyLineColors=colors(2)
 plot1c=gsn_csm_xy(wks,latitude(:),var2s_90x180_zmn(:),res)
 res@xyLineColors=colors(3)
 plot1d=gsn_csm_xy(wks,latitude(:),var2u_90x180_zmn(:),res)
end if

 overlay(plot1a,plot1b)
 overlay(plot1a,plot1c)
 overlay(plot1a,plot1d)
 plot(1)=plot1a

var1s_bias=var1s_zmn-var1_zmn
var1u_bias=var1u_zmn-var1_zmn
zero1_bias=var1_zmn-var1_zmn

if (plotbias .gt. 0) then
 res@trYMinF = -10 
 res@trYMaxF = 10 
 res@xyLineColors=colors(0)
 res@tiMainString = "Low-Level Cloud Fraction"
 plot2a=gsn_csm_xy(wks,latitude(:),var1calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 res@xyDashPattern="0"
 plot2c=gsn_csm_xy(wks,latitude_model(:),zero1_bias(:),res)
 res@xyLineColors=colors(2)
 res@xyDashPattern="0"
 plot2d=gsn_csm_xy(wks,latitude_model(:),var1s_bias(:),res)
 res@xyLineColors=colors(3)
 res@xyDashPattern="0"
 plot2e=gsn_csm_xy(wks,latitude_model(:),var1u_bias(:),res)
else
 res@trYMinF = 5 
 res@trYMaxF = 70 
 res@xyLineColors=colors(0)
 res@tiMainString = "Low-Level Cloud Fraction"
 plot2a=gsn_csm_xy(wks,latitude(:),var1calscale_zmn(:),res)
 res@xyLineColors=colors(1)
 res@xyDashPattern="0"
 plot2c=gsn_csm_xy(wks,latitude_model(:),var1_zmn(:),res)
 res@xyLineColors=colors(2)
 res@xyDashPattern="0"
 plot2d=gsn_csm_xy(wks,latitude_model(:),var1s_zmn(:),res)
 res@xyLineColors=colors(3)
 res@xyDashPattern="0"
 plot2e=gsn_csm_xy(wks,latitude_model(:),var1u_zmn(:),res)
end if

 overlay(plot2a,plot2c)
 overlay(plot2a,plot2d)
 overlay(plot2a,plot2e)
 plot(2)=plot2a

;       add a legend

 lgres                      = True
 lgres@xyLabelMode            = "Custom"
 lgres@xyLineLabelFontHeightF = 0.020                ; font height
 ;lgres@lgLineColors         = (/"black","darkgoldenrod","darkolivegreen3","chocolate"/)
 lgres@lgItemType           = "Lines"
 lgres@lgLabelFontHeightF   = .07
 lgres@vpWidthF             = 0.3        ; width of legend
 lgres@vpHeightF            = 0.20        ; height of legend
 lgres@lgLineThicknessF     = lthick
 lgres@lgPerimThicknessF    = 2.0
 lgres@lgMonoDashIndex      = False 
 ;lgres@lgDashIndexes          = (/"0","0","0","0"/)
 lgres@lgPerimOn            = False

; draw panel with white space added
 ;labels = (/"string1","string2","string3","string4"/)
 legend  = gsn_create_legend (wks, 4, labels, lgres)
 resP                 = True
 resP@amJust = "BottomRight"
 ;resP@amParallelPosF   = 0.42    ; Move legend to right
 resP@amParallelPosF   = -0.12    ; Move legend to right
 resP@amOrthogonalPosF = -0.12     ; Move legend down

 annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot

 gsn_panel(wks,plot,(/3,1/),resP)

  print("new figure")
end if
end if 
end if 

print("figurenumber is: "+figurenumber)

end

