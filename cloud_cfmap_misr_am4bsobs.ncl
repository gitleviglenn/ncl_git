;================================================;
;cloud_cfmap_misr_am4vsobs.ncl 
;
; Observations:  https://esgf-node.llnl.gov/projects/obs4mips/
; above is a link to a useful website with observations 
;
; produces a map of cloud fraction from either misr observations
; or am4 output from the misr simulator
; cloud fraction is obtained by integrating the cloud top height (km) 
; vs. tau histogram
;
; vertical levels in observational data
; cth = -1, 250, 750, 1250, 1750, 2250, 2750, 3500, 4500, 6000, 8000, 10000,
;    12000, 14000, 16000, 20000 ;
;
; vertical levels in AM4 output:
; alt16 = 0, 250, 750, 1250, 1750, 2250, 2750, 3500, 4500, 6000, 8000, 10000,
;    12000, 14500, 16000, 18000 ;
; These levels are correct as per: http://clipc-services.ceda.ac.uk/dreq/u/dim:alt16.html
;
; still to do: 
; 	cosine weight data for selected geographic regions
;       add all data from AM4, not just first 5 years of amip
;
; levi silvers  		feb 2020
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;

begin

;; open/reference desired file (use addfiles to reference multiple data file)
toptitle="MISR AM4"
xtitle="hieght (km)"
ytitle="optical depth"
;
;;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"

;filein="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_197901-198412.nc"
filein="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_200301-200812.nc"
obs_filein="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_197901-198412.nc"

obs_filein="/Users/silvers/data/SatData/MISR/clMISR/clMISR_obs4MIPS_20000601_20130531_tmn.nc"

infile     = addfile(filein,"r")
obs_infile = addfile(obs_filein,"r")

  print("infile is: "+filein)
  print("observations infile is: "+obs_filein)

tau=infile->tau(:)
  print("tau =: "+tau)

tau_obs=obs_infile->tau(:)
  print("obs tau =: "+tau_obs)
;
;;-Reading and processing of data-------------------------------------------
;

varnames="misr_"+ispan(1,16,1)
varname="clmisr"
ob_varname="clMISR"

fields=new((/7,16/),float)

fields_full     =infile->$varname$(:,:,:,:,:)
obs_fields_tmn  =obs_infile->$ob_varname$(0,1:7,:,:,:)
t_full          =obs_infile->$ob_varname$(0,:,:,:,:)
obs_fields_pnt  =obs_infile->$ob_varname$(0,1,3,:,:)
;obs_fields_tmn=obs_infile->$ob_varname$(0,:,:,90,90)

;;printVarSummary(obs_fields_tmn)
;
;  print("overall max of fields is: "+max(fields_full))
;  print("overall min of fields is: "+min(fields_full))
;  print("overall max of obs fields is: "+max(obs_fields_tmn))
;  print("overall min of obs fields is: "+min(obs_fields_tmn))
;
;;  printVarSummary(fields_full)

;--------------------------------
; created some arrays that will be needed
;fields_patch =new((/7,16,180,288/),float)
fields_patch =new((/7,16,60,288/),float)
interpolated_var = new((/7,16,180,360/),float)
fields_point =new((/7,16/),float)
cf_array     =new((/16,7/),float)
cf_array_obs =new((/16,7/),float)
ncr          =dimsizes(fields_point)
ncr_flip     =dimsizes(cf_array)
;;---------------------------------------------------------------------
; do some averaging
; average over time and decide which geographic region to look at
; once the geographic region has been selected, compute the spatial average

fields_tmn=dim_avg_n(fields_full,0)
;  printVarSummary(fields_tmn)
  print("dimsizes of fields_tmn are:"+dimsizes(fields_tmn))
  print("dimsizes of obs_fields_tmn are:"+dimsizes(obs_fields_tmn))
  print("dimsizes of fields_patch are:"+dimsizes(fields_patch))

;fields_patch=fields_tmn
fields_patch=fields_tmn(:,:,61:120,:)
;fields_tropics=

; global mean without cosine weighting
fields_gmn_a=dim_avg_n(fields_tmn,2)
fields_gmn  =dim_avg_n(fields_gmn_a,2)
fields_obs_gmn_a=dim_avg_n(obs_fields_tmn,2)
fields_obs_gmn  =dim_avg_n(fields_obs_gmn_a,2)

; mean of tropics without cosine weighting
fields_trm_a =dim_avg_n(fields_patch,2)
fields_trm_am4   =dim_avg_n(fields_trm_a,2)

  ;print("dimsizes of gmn_a are: "+dimsizes(fields_gmn_a))
;fields_point=fields_patch(:,:,90,144)
  print("=-=-=-=-=-=-=-")
  print("dimsizes of fields_trm_am4 for AM4 are: "+dimsizes(fields_trm_am4))

fields_tmn!0          ="tau"
fields_tmn&tau        =fields_full&tau
fields_tmn!1          ="alt16"
fields_tmn&alt16      =fields_full&alt16
fields_tmn!2          ="lat"
fields_tmn&lat        =fields_full&lat
fields_tmn!3          ="lon"
fields_tmn&lon        =fields_full&lon

printVarSummary(fields_tmn)
;***********************************************************************************
; interpolate gfdl data to a 180x360 degree grid
print("Beginning Interpolation")

var_to_interpolate=fields_tmn

copy_VarCoords(fields_tmn,var_to_interpolate)
copy_VarCoords(interpolated_var,obs_fields_tmn)
;copy_VarCoords(fields_tmn_noland,obs_fields_tmn)

;
dimgfdl=dimsizes(var_to_interpolate)
print("dims of variable before interpolation: "+dimgfdl)
;
nlat=dimgfdl(2)
nlon=dimgfdl(3)
;
nlati=180 ; number of input latitude points(it is the lon points which differ
;
latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid
;
   opt = True
;
   NLAT1x1    = 180                               ; RES   = "180x288"
   MLON1x1    = 360
   LAT_1x1    = latGlobeFo(NLAT1x1, "LAT_1x1", "latitude" , "degrees_north")
   LON_1x1    = lonGlobeFo(MLON1x1, "LON_1x1", "longitude", "degrees_east" )

   opt@NLATi       = nlati
   opt@NLATo       = NLAT1x1
   LAT_REG_1x1     = LAT_1x1({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_1x1, LAT_REG_1x1, opt)

print("dims of variable after interpolation: "+dimsizes(interpolated_var))
;***********************************************************************************

; reorient the latitude and longitude orientation of am4 data to match that from misr:
interpolated_var=interpolated_var(:,:,::-1,:)
;interpolated_var=lonPivot(interpolated_var,0.5)  --> I don't think lonPivot works for neg values

obs_fields_tmn=lonPivot(obs_fields_tmn,0.5)

;printVarSummary(interpolated_var)

; mask out the land
fields_tmn_noland=where(obs_fields_tmn.eq.obs_fields_tmn@_FillValue,obs_fields_tmn@_FillValue,interpolated_var)

copy_VarCoords(obs_fields_tmn,fields_tmn_noland)

;printVarSummary(fields_tmn_noland)

;print("dimsizes of fields_tmn_noland: "+dimsizes(fields_tmn_noland))
;toplot=fields_tmn_noland
;print("dimsizes of toplot: "+dimsizes(toplot))

;print(" do we have dims defined for obs_fields_tmn? ") ;--> yes
;printVarSummary(obs_fields_tmn)

;print(" copying metadata to toplot ")
;copy_VarCoords(obs_fields_tmn,toplot)
;
; integrate over ctp and tau for misr obs
obs_fields_tmn_a=dim_sum_n_Wrap(obs_fields_tmn,0)
obs_fields_tmn_b=dim_sum_n_Wrap(obs_fields_tmn_a,0)

; integrate over ctp and tau for interpolated am4
int_fields_a=dim_sum_n_Wrap(interpolated_var,0)
int_fields_b=dim_sum_n_Wrap(int_fields_a,0)

; integrate over ctp and tau for interpolated am4 after land is removed
int_fields_noland_a=dim_sum_n_Wrap(fields_tmn_noland,0)
int_fields_noland_b=dim_sum_n_Wrap(int_fields_noland_a,0)

;;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = infile->lat
olat  = obs_infile->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
oclat = cos(olat*rad)
;  print("(((((((((((((")
;  print("dimsizes of clat are: "+dimsizes(clat))
;;  print(clat)
;  print(")))))))))))))")
;  print("dimsizes of fields_gmn are: "+dimsizes(fields_tmn))
;;
field_wave_obs        = wgt_areaave(obs_fields_tmn_b,oclat,1.0,0)
field_wave_am4        = wgt_areaave(int_fields_b,clat,1.0,0)
field_wave_am4_noland = wgt_areaave(int_fields_noland_b,clat,1.0,0)
;;
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
  print("(***************")
  print("global mean of misr is: "+field_wave_obs)
  print("global mean of am4 is: "+field_wave_am4)
  print("global mean of am4 with no land is: "+field_wave_am4_noland)
  print("***************)")
;---------------------------------------------------------------------
;--------------------------------
;
;fields=fields_point

; try a patch for observations
delete(fields_trm_a)
delete(fields_patch)
fields_patch =new((/7,16,60,360/),float)
fields_patch=obs_fields_tmn(:,:,61:120,:)
; mean of tropics without cosine weighting
fields_trm_a =dim_avg_n(fields_patch,2)
fields_trm_misr   =dim_avg_n(fields_trm_a,2)
  print("dimsizes of trm for obs are: "+dimsizes(fields_trm_misr))
  print("=-=-=-=-=-=-=-")

;--------------------------------
; determine which regions will be tabulated.  save the desired 
; arrays to fields and fields_obs
;fields=fields_gmn
;fields_obs=fields_obs_gmn
fields=fields_trm_am4
fields_obs=fields_trm_misr
  print("dimsizes of fields are:"+dimsizes(fields))
  ;print(fields(:,10))
  ;printVarSummary(fields_obs)
;--------------------------------


; name the dimensions of the newly created arrays
fields!0="tau"
cf_array!1="tau"

fields_obs!0="tau"
cf_array_obs!1="tau"

fields&tau        =fields_full&tau
cf_array&tau      =fields_full&tau
fields_obs&tau    =fields_full&tau
cf_array_obs&tau  =fields_full&tau

fields!1          ="alt16"
fields_obs!1      ="alt16"
cf_array!0        ="alt16"
cf_array_obs!0    ="alt16"

fields&alt16      =fields_full&alt16
fields_obs&alt16  =fields_full&alt16
cf_array&alt16    =fields_full&alt16
cf_array_obs&alt16=fields_full&alt16

;  print("--------- old fields --------")
;  printVarSummary(fields)
;  printVarSummary(fields_obs)

cf_array     =fields(alt16|:,tau|:)
cf_array_obs =fields_obs(alt16|:,tau|:)

;  print("--------- cf array 1----------")
;  printVarSummary(cf_array)
;  print("--------- cf array 2----------")
cf_array     =cf_array(::-1,:)
cf_array_obs =cf_array_obs(::-1,:)
;  printVarSummary(cf_array)
;  print("-----------------------------")




;  t_a    = dim_sum_n_Wrap(t_full,0)
;  t      = dim_sum_n_Wrap(t_a,0)
;
  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
  my_levels1 = (/5,10,20,30,40,50,60,70,80,90/) ; 10
  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"MPL_YlGnBu")

  res                   = True
  ;res@mpProjection      = "Mollweide"       ; choose projection
  res@mpProjection      = "Robinson"       ; choose projection
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
  res@cnLinesOn         = False
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "AM4 land"  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

;  contour = gsn_csm_contour_map(wks,obs_fields_tmn_b,res)  ; create the plot
  contour = gsn_csm_contour_map(wks,int_fields_b,res)  ; create the plot
;  contour = gsn_csm_contour_map(wks,int_fields_noland_b,res)  ; create the plot



end























