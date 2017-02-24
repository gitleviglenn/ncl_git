;***********************************************************************************
; glb_cf_cltisccp_data.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the iscpp cosp tool.
;
; for reference see Marchand et al. 2010 JGR
;
; note:
; cltisccp(time, lat, lon) = "Total Cloud Fraction as Calculated by the ISCCP Simulator"
; clisccp_1_1(time,lat,lon)="ISCCP CldFrac-tau between 0.0 and 0.3, pr between 1000 and 800hPa" 
;
; should the cltisccp and clisccp_#_# variables match exactly?  how well should they match
; with the tot_cld_amt variable?
; 
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							oct 2016
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; read in netCDF file
;***********************************************************************************
dirin="/work/Levi.Silvers/moddata/misr_pp_am4g10r8_taugt0p3/"
infile_isccpdata="/net2/Levi.Silvers/data/isccpdata/cltisccp_7yr_tmn.nc"
  isccp_data = addfile(infile_isccpdata,"r")
print("infile for isccp data is: "+infile_isccpdata)
maintitle="cltisccp obs 2001-2007"
  isc_data_test = isccp_data->cltisccp(0,:,:)                                
  isc_data = isccp_data->cltisccp(0,:,:)                                
  print("dims of isc_data are: "+dimsizes(isc_data))
  tot_cld_sum=sum(isc_data)
  t2=where(isc_data.ge.100.,0.0,isc_data)
  tot_cld_sum2=sum(t2)
  mean_cld=tot_cld_sum2/10368.
  print("sum of tot_cld_amt: "+tot_cld_sum)
  print("sum2 of tot_cld_amt: "+tot_cld_sum2)
  print("mean of tot_cld_amt: "+mean_cld)
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = isccp_data->latitude
lon  = isccp_data->longitude_2
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))
field1_weighted_ave     = wgt_areaave(isc_data,clat,1.0,1)
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
print("weighted global mean of cltisccp is: "+field1_weighted_ave)
;field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
;print("global mean of non missing data "+cltisccp+" at time "+time+" is: "+field1_weighted_ave_test)
;
isc_data!0="latitude"
isc_data&latitude@units="degrees_north"
;isc_data&latitude=isc_data_test&latitude
isc_data!1="lon"
isc_data&lon@units="degrees_east"
;isc_data&lon=isc_data_test&longitude_2
;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/)
my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/)

my_levels1 = (/25,30,35,40,45,50,55,60,65,70,75,80,85,90,95/) ; 15
my_colors = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16

  ;wks = gsn_open_wks("eps","proj")          ; send graphics to ps file
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
  res@tiMainFontHeightF  = .018                               ; font height

  ;contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
  contour = gsn_csm_contour_map(wks,isc_data,res)  ; create the plot
  ;contour = gsn_csm_contour_map(wks,isc_data_test,res)  ; create the plot
end

