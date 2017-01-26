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
varname1="tclmodis" ; MODIS total cloud fraction
; "lclmodis" ; MODIS total Liquid Cloud Fraction
; "iclmodis" ; MODIS total Ice Cloud Fraction
; "hicldmodis"
; "mdcldmodis"
; "locldmodis"
; "ttaumodis" ; MODIS total optical thickness*cpct
; "ltaumodis" ; MODIS total liquid optical thickness*cpct
; "itaumodis" ; MODIS total ice optical thickness*cpct
;
;varname1="tot_cld_amt" 
;***********************************************************************************
;dirin="/work/Levi.Silvers/moddata/misr_pp_am4g10r8_taugt0p3/"
;dirin="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_2yr/"
;infile=dirin+"atmos_month_cospx.0002-0003.alltmn.nc"
infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_bigout/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_modis/av/monthly_2yr/atmos_month_modis.0002-0003.alltmn.nc"
  data = addfile(infile,"r")
print("infile is: "+infile)
  ;t = a->tot_cld_amt(0,:,:)                                
  t = data->$varname1$(0,:,:)                                
  tot_cld_sum=sum(t)
  t2=where(t.ge.100.,0.0,t)
  tot_cld_sum2=sum(t2)
  mean_cld=tot_cld_sum2/51840.
  print("sum of tot_cld_amt: "+tot_cld_sum)
  print("sum2 of tot_cld_amt: "+tot_cld_sum2)
  print("mean of tot_cld_amt: "+mean_cld)
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = data->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))
field1_weighted_ave     = wgt_areaave(t,clat,1.0,1)
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
print("raw global mean of "+varname1+" is: "+field1_weighted_ave)
;field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field1_weighted_ave_test)
;
posh=flt2string(decimalPlaces(field1_weighted_ave,2,True))
maintitle="tclmodis 2yr mn am4g10r8 glb mn = "+posh
;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/)
my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/)

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  gsn_define_colormap(wks,"WhBlGrYeRe")


  res                   = True
;  res@mpProjection      = "Mollweide"       ; choose projection
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
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
end

