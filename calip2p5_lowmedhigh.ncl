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

; monthly data from Songmiao
; originally came from:
; /archive/snf/awg/warsaw/c96L33_am4p0u/gfdl.ncrc3-intel-prod-openmp/pp/atmos_cmip/av/monthly_5yr/
expname="c96L33_am4p0r"
;expname="c96L33_am4p0s"
;expname="c96L33_am4p0u"
infile1="/archive/Levi.Silvers/data/songmiao/"+expname+"/atmos_cmip.2000-2004.tmn.nc"
infile2="/archive/Levi.Silvers/data/songmiao/"+expname+"/atmos_cmip.2000-2004.tmn.nc"
infile3="/archive/Levi.Silvers/data/songmiao/"+expname+"/atmos_cmip.2000-2004.tmn.nc"

infile4=path_obs+"calip_2x2xL40_avg_cll/cllcalipso_tmn_20060615_20101215.nc"
infile5=path_obs+"calip_2x2xL40_avg_clm/clmcalipso_tmn_20060615_20101215.nc"
infile6=path_obs+"calip_2x2xL40_avg_clh/clhcalipso_tmn_20060615_20101215.nc"

infile_calobs=path_obs+"from_Greg_Jan2017/MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"

modelv="am4.0"

; compute pi
PI=acos(-1.)

; from model
data = addfile(infile1,"r")
data2 = addfile(infile2,"r")
data3 = addfile(infile3,"r")
; from obs
data4 = addfile(infile4,"r")
data5 = addfile(infile5,"r")
data6 = addfile(infile6,"r")
data_calobs = addfile(infile_calobs,"r")

print("infile for cltcalipso is: "+infile)
print("infile is: "+infile1)
print("infile is: "+infile2)
print("infile is: "+infile3)
print("infile is: "+infile4)
print("infile is: "+infile5)
print("infile is: "+infile6)
print("infile calipso obs is: "+infile_calobs)

var1 = data->$varname1$(0,:,:)                                
var2 = data2->$varname2$(0,:,:)                                
var3 = data3->$varname3$(0,:,:)                                
latitude_model=data->lat(:)

var1@_FillValue = -1.e+30

;; if using older calipso data source...
;var1cal = data4->$varname1$(:,:)                                
;var1calscale=100*var1cal
;var2cal = data5->$varname2$(:,:)                                
;var2calscale=100*var2cal
;var3cal = data6->$varname3$(:,:)                                
;var3calscale=100*var3cal

; if using calipso data between 200701-201612
var1cal = data_calobs->$varname1$(0,:,:)                                
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

print("======================================")
print("low level clouds")
print("raw(bef interp) global mean from simulator "+varname1+" is: "+field1_weighted_ave)
print("raw(aft interp) global mean from simulator "+varname1+" is: "+field1_2p5x2p5_weighted_ave)
print("weighted low level am4 cal sim: "+var1_90x180_weighted_ave)
print("weighted and masked low level am4 cal sim: "+var1_masked_weighted_ave)

print("mid level clouds")
print("raw(bef interp) global mean from simulator "+varname2+" is: "+field2_weighted_ave)
print("raw(aft interp) global mean from simulator "+varname2+" is: "+field2_2p5x2p5_weighted_ave)
print("weighted mid level am4 cal sim: "+var2_90x180_weighted_ave)
print("weighted and masked mid level am4 cal sim: "+var2_masked_weighted_ave)

print("high level clouds")
print("raw global mean of "+varname3+" is: "+field3_weighted_ave)
print("weighted high level am4 cal sim: "+var3_90x180_weighted_ave)
print("weighted and masked high level am4 cal sim: "+var3_masked_weighted_ave)

print("-------------------")
print("weighted low level calipso obs:   "+field4_weighted_ave)
print("weighted mid level calipso obs:   "+field5_weighted_ave)
print("weighted upper level calipso obs: "+field6_weighted_ave)
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

sumx=0.0
;printVarSummary(sumx)
sumw=0.0
kmsg_c=0
do n=0,ny-1
  do m=0,mx-1
    if (.not.ismissing(dummy(n,m))) then
      sumx=sumx+dummy(n,m)*dum_lat(n)
      sumw=sumw+dum_lat(n)
    else
      kmsg_c = kmsg_c +1
;      print("missing value is="+dummy(n,m))
    end if
  end do
end do

xave_b=sumx/sumw
print("xave_b="+xave_b+"            kmsg_c="+kmsg_c)

wgty=conform(dummy,dum_lat,0)
wgtx=conform(dummy,1,-1)

x_ave = sum(dummy*wgty*wgtx)/sum(wgty*wgtx)
print("[A] sum(dummy*wgty*wgtx)/sum(wgty*wgtx)="+x_ave+"          not correct")

WGTX = where(ismissing(dummy),0.0,1.0)
WGTY = where(ismissing(dummy),0.0,wgty)
x_ave = sum(dummy*wgty*wgtx)/sum(WGTX*WGTY)
print("[B] sum(dummy*wgty*wgtx)/sum(WGTY*WGTX)="+x_ave)  

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


figurenumber = 3 ; 1 is default and plots 9 panel figure
                 ; 2 plots the 3 panel figure of zonal means
                 ; 3 plots the 3 panel figure of zonal means with a linear cosine axis
if (figurenumber .lt. 2) then

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot_25")          ; send graphics to ps file
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

  res@tiMainString       = titletop  ; add a title
  res@tiMainFontHeightF  = .01                               ; font height

  res@vpXF             = 0.25                  ; position and sizes
  res@vpYF             = 0.98                  ; for XY plot
  res@vpWidthF         = 0.32
  ;res@vpHeightF        = 0.29
  res@vpHeightF        = 0.32

  contour1 = gsn_csm_contour_map(wks,var3calscale,res)  ; create the plot
  res@tiMainString       = titlemid  ; add a title
  res@vpYF             = 0.68                  ; for XY plot
  contour2 = gsn_csm_contour_map(wks,var2calscale,res)  ; create the plot
  res@tiMainString       = titlelow  ; add a title
  res@vpYF             = 0.38                  ; for XY plot
  contour3 = gsn_csm_contour_map(wks,var1calscale,res)  ; create the plot

  res@vpXF             = 0.62                  ; position and sizes
  res@vpYF             = 0.98                  ; for XY plot
;  res@vpWidthF         = 0.30
;  res@vpHeightF        = 0.27

  res@cnLevels          = my_levels_15posneg
  res@cnFillColors      = my_colors_posneg
  res@tiMainString       = titletop_bias  ; add a title
  contour4 = gsn_csm_contour_map(wks,blah3,res)  ; create the plot
  res@tiMainString       = titlemid_bias  ; add a title
  res@vpYF             = 0.68                  ; for XY plot
  contour5 = gsn_csm_contour_map(wks,blah2,res)  ; create the plot
  res@tiMainString       = titlelow_bias  ; add a title
  res@vpYF             = 0.38                  ; for XY plot
  contour6 = gsn_csm_contour_map(wks,blah1,res)  ; create the plot

; top row zonal mean 
 reszm@vpXF           = 0.05                  ; position and sizes
 reszm@vpYF           = 0.92                  ; for XY plot
 reszm@vpWidthF       = 0.13
 reszm@vpHeightF      = 0.20

 reszm@trXMinF = 15
 reszm@trXMaxF = 55
 reszm@xyLineColors="blue"
 plotta=gsn_csm_xy(wks,var3calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyLineColors="black"
 plottb=gsn_csm_xy(wks,var3_90x180_zmn(:),sin(latitude(:)/180*PI),reszm)

 overlay(plotta,plottb)
 plot(0)=plotta

; middle row zonal mean 
 reszm@vpYF           = 0.62                  ; for XY plot

 reszm@trXMinF = 0
 reszm@trXMaxF = 40
 reszm@xyLineColors="blue"
 plotma=gsn_csm_xy(wks,var2calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyLineColors="black"
 plotmb=gsn_csm_xy(wks,var2_90x180_zmn(:),sin(latitude(:)/180*PI),reszm)
; plotmb=gsn_csm_xy(wks,var1_zmn(:),sin(latitude_model(:)/180*PI),res)

 overlay(plotma,plotmb)
 plot(3)=plotma

; bottom row zonal mean 
; reszm@vpYF           = 0.04                  ; for XY plot
 reszm@vpYF           = 0.32                  ; for XY plot

 reszm@trXMinF = 5
 reszm@trXMaxF = 70
 reszm@xyLineColors="blue"
 plotba=gsn_csm_xy(wks,var1calscale_zmn(:),sin(latitude(:)/180*PI),reszm)
 reszm@xyLineColors="black"
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
 wks   = gsn_open_wks ("newPDF","testplot")
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
;end if 
 wks   = gsn_open_wks ("newPDF","testplot")
 plot = new(3,graphic)

  res   = True
 res@tiMainString = "Upper-Level Cloud Fraction"
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
 res@tmXBValues = (/-60,-30,0,30,60/)
 res@tmXBLabels = (/-60,-30,0,30,60/)
 res@tmXBMinorValues =(/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)
 ;res@tmXBValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 ;res@tmXBLabels = (/-60,-30,0,30,60/)
 ;res@tmXBMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)


 res@gsnDraw         = False
 res@gsnFrame         = False
 

 res@trYMinF = 15
 res@trYMaxF = 55
 res@xyLineColors="blue"
 plot0a=gsn_csm_xy(wks,latitude(:),var3calscale_zmn(:),res)
 res@xyLineColors="black"
 plot0b=gsn_csm_xy(wks,latitude(:),var3_90x180_zmn(:),res)
 
 overlay(plot0a,plot0b)
 plot(0)=plot0a

 res@trYMinF = 0
 res@trYMaxF = 40
 res@tiMainString = "Mid-Level Cloud Fraction"
 res@xyLineColors="blue"
 plot1a=gsn_csm_xy(wks,latitude(:),var2calscale_zmn(:),res)
 res@xyLineColors="black"
 plot1b=gsn_csm_xy(wks,latitude(:),var2_90x180_zmn(:),res)

 overlay(plot1a,plot1b)
 plot(1)=plot1a

 ;res@trXMinF = 5
 ;res@trXMaxF = 70
 ;res@tiYAxisString  = "Latitude"
 ;res@tiXAxisString  = "Cloud Fraction [%]"
 ;res@tmXBMode = "Automatic"
 ;res@tmYLMode = "explicit"
 res@trYMinF = 5 
 res@trYMaxF = 70 
 ;res@trXMinF = -90 
 ;res@trXMaxF = 90 
; res@tmXLValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
; res@tmXRValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 ;res@tmXBValues = (/-75,-60,-45,-30,-15,0,15,30,45,60,75/)
 ;res@tmXBValues = (/-60,-30,0,30,60/)
; res@tmXRValues = (/-90,-75,-60,-45,-30,-15,0,15,30,45,60,75,90/)
 ;res@tmXRValues = (/sin(-60./180*PI),sin(-30./180*PI),sin(0.),sin(30./180*PI),sin(60./180*PI)/)
 ;res@tmXLLabels = (/-60,-30,0,30,60/)
 ;res@tmXLLabels = (/-75,-60,-45,-30,-15,0,15,30,45,60,75/)
; res@tmXLMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)
; res@tmXRMinorValues =sin((/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)/180.*PI)
 res@xyLineColors="blue"
 res@tiMainString = "Low-Level Cloud Fraction"
 plot2a=gsn_csm_xy(wks,latitude(:),var1calscale_zmn(:),res)
 ;plot2a=gsn_csm_xy(wks,var1calscale_zmn(:),sin(latitude(:)/180*PI),res)
 res@xyLineColors="black"
 ;plot2b=gsn_csm_xy(wks,sin(latitude(:)/180*PI),var1_90x180_zmn(:),res)
 plot2c=gsn_csm_xy(wks,latitude_model(:),var1_zmn(:),res)
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



    
  print("new figure")
end if
end if 
end if 

print("figurenumber is: "+figurenumber)

end

