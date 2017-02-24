;***********************************************************************************
; glb_cf_tclmodis.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the modis cosp tool.
;
; example here is for clouds below 3km with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; note:
; cltisccp(time, lat, lon) = "Total Cloud Fraction as Calculated by the ISCCP Simulator"
; clisccp_1_1(time,lat,lon)="ISCCP CldFrac-tau between 0.0 and 0.3, pr between 1000 and 800hPa" 
;
; should the tclmodis and modis_#_# variables match exactly?  how well should they match
; with the tot_cld_amt variable?
; 
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							nov 2016
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
;varname1="tclmodis" ; MODIS total cloud fraction
;varname1="cltlidarradar"
;varname1="clhcalipso"
;varname1="cllcalipso"
varname1="tot_cld_amt" 
; "lclmodis" ; MODIS total Liquid Cloud Fraction
; "iclmodis" ; MODIS total Ice Cloud Fraction
;varname1="hicldmodis"
; "mdcldmodis"
; "locldmodis"
; "ttaumodis" ; MODIS total optical thickness*cpct
; "ltaumodis" ; MODIS total liquid optical thickness*cpct
; "itaumodis" ; MODIS total ice optical thickness*cpct
;
;***********************************************************************************
;infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/monthly_2yr/atmos.0002-0003.timmean.nc"
;infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/monthly_2yr/atmos.0002-0003.01.nc"

;infile="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_cospx/atmos_month_cospx.0002-0011.all.nc"
infile="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_cospx/atmos_month_cospx.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos/atmos.0002-0011.all.nc"

modelv="am4g12r18"

infile_isccpdata="/net2/Levi.Silvers/data/isccpdata/cltisccp_7yr_tmn.nc"
  ;maintitle_isc="cltisccp obs 2001-2007"
  isccp_data = addfile(infile_isccpdata,"r")
print("infile for isccp data is: "+infile_isccpdata)
  isc_data = isccp_data->cltisccp(0,:,:)                                
  print("dims of isc_data are: "+dimsizes(isc_data))
  tot_cld_suma=sum(isc_data)
  tttt2=where(isc_data.ge.100.,0.0,isc_data)
  tot_cld_suma2=sum(tttt2)
  mean_cld_isc=tot_cld_suma2/10368.
  print("sum of tot_cld_amt: "+tot_cld_suma)
  print("sum2 of tot_cld_amt: "+tot_cld_suma2)
  print("mean of isccp: "+mean_cld_isc)

isc_data!0="lat"
isc_data&lat@units="degrees_north"
isc_data!1="lon"
isc_data&lon@units="degrees_east"
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat_isc  = isccp_data->latitude
lon_isc  = isccp_data->longitude_2
rad_isc  = 4.0*atan(1.0)/180.0
clat_isc = cos(lat_isc*rad_isc)
field1_weighted_ave_isc     = wgt_areaave(isc_data,clat_isc,1.0,1)
print("weighted global mean of isccp data is: "+field1_weighted_ave_isc)
posh_isc=flt2string(decimalPlaces(field1_weighted_ave_isc,2,True))
  isc_tit="cltisccp obs 2001-2007"
maintitle_isc=isc_tit+" glb mean = "+posh_isc
;---------------------------------------------------------------------

  data = addfile(infile,"r")
print("infile is: "+infile)
  ;t = a->tot_cld_amt(0,:,:)                                
  t = data->$varname1$(0,:,:)                                
  tot_cld_sum=sum(t)
  t2=where(t.ge.100.,0.0,t)
  tot_cld_sum2=sum(t2)
  mean_cld=tot_cld_sum/51840.
  mean_cld2=tot_cld_sum2/51840.
  print("sum of tot_cld_amt: "+tot_cld_sum)
  print("sum2 of tot_cld_amt: "+tot_cld_sum2)
  print("unweighted mean of tot_cld_amt: "+mean_cld)
  print("unweighted mean of tot_cld_amt: "+mean_cld2)
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = data->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))
field1_weighted_ave     = wgt_areaave(t,clat,1.0,1)
field1_weighted_ave2     = wgt_areaave(t,clat,1.0,0)
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
print("raw global mean of "+varname1+" is: "+field1_weighted_ave)
print("raw global mean 2 of "+varname1+" is: "+field1_weighted_ave2)
;field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field1_weighted_ave_test)
;
posh=flt2string(decimalPlaces(field1_weighted_ave,2,True))
maintitle=modelv+" "+" 10yrm "+varname1+" = "+posh
;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
;my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/) ; 15
my_levels_def = (/25,30,35,40,45,50,55,60,65,70,75,80,85,90,95/) ; 15
my_colors_def = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16

my_levels_hc = (/18,21,24,27,30,33,36,39,42,45,48,51,54,57,60/) ; 15
my_colors_hc = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16

my_levels1=my_levels_def
my_colors=my_colors_def

  ;wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"matlab_jet")


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
 
; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels1
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = maintitle  ; add a title
  ;res@tiMainString       = maintitle_isc  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
  ;contour = gsn_csm_contour_map(wks,isc_data,res)  ; create the plot
end

