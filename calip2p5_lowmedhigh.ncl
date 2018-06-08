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

infile_calobs=path_obs+"from_Greg_Jan2017/MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"

modelv="am4.0"

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

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot_25")          ; send graphics to ps file
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

