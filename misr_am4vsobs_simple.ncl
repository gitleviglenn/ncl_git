;***********************************************************************************
;misr_am4vsobs_simple.ncl 
;***********************************************************************************
;
; just trying to check the mean values of cloud fraction in as simple a manor as
; possible.  
;
; levi silvers  	                                	june 2020
;***********************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;***********************************************************************************

begin

;

; to speed things up only look in one file from am4...
;filein=systemfunc("ls /Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_*nc")
filein=systemfunc("ls /Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_199701-200212.nc")

to_misr="/Users/silvers/data/SatData/MISR_fromRoj/MISR_CTH_OD_histograms_v7/"

obs_filein=to_misr+"clMISR_obs4MIPs_200003th201911.timemn.nc"

;infile     = addfile(filein,"r")
infile     = addfiles(filein,"r")
obs_infile = addfile(obs_filein,"r")

  print("infile is: "+filein)
  print("observations infile is: "+obs_filein)

;tau=infile->tau(:)
tau=infile[:]->tau(:)
  print("tau =: "+tau)

tau_obs=obs_infile->tau(:)
  print("obs tau =: "+tau_obs)
;
;;;-Reading and processing of data-------------------------------------------
;
varnames="misr_"+ispan(1,16,1)
varname="clmisr"
ob_varname="clMISR"
;
;fields=new((/7,16/),float)
;
; for the observations, the first height and tau entry is for non retrievals
; how does the simulator work?  Is the first row of height values legitimate?
;
;;fields_full     =infile->$varname$(:,:,:,:,:)
fields_full     =infile[:]->$varname$(:,:,:,:,:)
obs_fields_tmn  =obs_infile->$ob_varname$(0,1:7,:,:,:)
;t_full          =obs_infile->$ob_varname$(0,:,:,:,:)
;obs_fields_pnt  =obs_infile->$ob_varname$(0,1,3,:,:)
;;obs_fields_tmn=obs_infile->$ob_varname$(0,:,:,90,90)
;
;;--------------------------------
;; created some arrays that will be needed
;;fields_patch =new((/7,16,180,288/),float)
;fields_patch =new((/7,16,60,288/),float)
;interpolated_var = new((/7,16,180,360/),float)
;fields_point =new((/7,16/),float)
;cf_array     =new((/16,7/),float)
;cf_array_obs =new((/16,7/),float)
;ncr          =dimsizes(fields_point)
;ncr_flip     =dimsizes(cf_array)
;;;---------------------------------------------------------------------
;; do some averaging
;; average over time and decide which geographic region to look at
;; once the geographic region has been selected, compute the spatial average
;
fields_tmn=dim_avg_n(fields_full,0)
;;  printVarSummary(fields_tmn)
  print("dimsizes of fields_tmn are:"+dimsizes(fields_tmn))
  print("dimsizes of obs_fields_tmn are:"+dimsizes(obs_fields_tmn))
;  print("dimsizes of fields_patch are:"+dimsizes(fields_patch))
;
;;fields_patch=fields_tmn
;fields_patch=fields_tmn(:,:,61:120,:)
;;fields_tropics=
;
; global mean without cosine weighting
fields_gmn_a=dim_avg_n(fields_tmn,2)
fields_gmn  =dim_avg_n(fields_gmn_a,2)
;
fields_obs_gmn_a=dim_avg_n(obs_fields_tmn,2)
fields_obs_gmn  =dim_avg_n(fields_obs_gmn_a,2)
  print("=-=-=-=-=-=-=-")
;print("mean of AM4 data: "+fields_gmn)
;print("mean of obs data: "+fields_obs_gmn)
print("dimsizes of fields_gmn are: "+dimsizes(fields_gmn))
print("dimsizes of fields_obs_gmn are: "+dimsizes(fields_obs_gmn))
;  print("=-=-=-=-=-=-=-")
print("sum of total unweighted global am4 data: "+sum(fields_gmn))
print("sum of total unweighted global obs misr data: "+sum(fields_obs_gmn))
dead=fields_gmn(0:6,:)
horse=fields_obs_gmn(0:6,:)
;print("dimsizes of dead are: "+dimsizes(dead))
print("sum below 3km unweighted global am4 data: "+sum(fields_gmn(:,0:6)))
print("sum below 3km unweighted global obs misr data: "+sum(fields_obs_gmn(:,0:6)))
print("sum above 3km unweighted global am4 data: "+sum(fields_gmn(:,7:15)))
print("sum above 3km unweighted global obs misr data: "+sum(fields_obs_gmn(:,7:15)))
;print("sum below 3km unweighted global am4 data: "+sum(dead))
;print("sum below 3km unweighted global obs misr data: "+sum(horse))
  print("=-=-=-=-=-=-=-")
;;---------------------------------------------------------------------
; compute lat weights to determine the global mn
;;---------------------------------------------------------------------
lat  = infile[0]->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;;
;;field_wave_am4     = wgt_areaave(fields_tmn,clat,1.0,1)

funny_stuff_h=new((/2,16/),float)
funny_stuff_t=new((/2,7/),float)

i=0
do while(i.le.15)
  fields_one_tau   =fields_tmn(:,i,:,:) ; all tau, one height
  fields_one       =dim_sum_n(fields_one_tau,0)
  filds_gmn_a=dim_avg_n(fields_one,1)
;print("dimsizes of filds_gmn_a are: "+dimsizes(filds_gmn_a))
  filds_gmn  =dim_avg_n(filds_gmn_a,0)
;print("dimsizes of filds_gmn are: "+dimsizes(filds_gmn))
  ;print("dimsizes of fields_one are: "+dimsizes(fields_one))
  field_wave_am4   = wgt_areaave(fields_one,clat,1.0,0)
  print("unweighted average of AM4 data for all tau and height..."+filds_gmn)
  print("weighted average of AM4 data for all tau and height..."+field_wave_am4)
  funny_stuff_h(0,i)=field_wave_am4
  i=i+1
end do

print("#$^@$%&$&^(%^&$%^&^@#$%")
i=0
do while(i.le.6)
  fields_one_ht      =fields_tmn(i,:,:,:) ; all hieghts, one tau
  fields_one_h       =dim_sum_n(fields_one_ht,0)
  filds_gmn_b=dim_avg_n(fields_one_h,1)
  filds_1h_gmn  =dim_avg_n(filds_gmn_b,0)
;print("dimsizes of filds_one_ht are: "+dimsizes(fields_one_ht))
print("dimsizes of filds_one_h are: "+dimsizes(fields_one_h))
;print("dimsizes of filds_gmn_b are: "+dimsizes(filds_gmn_b))
  print("unweighted average of AM4 data for all height and tau..."+filds_1h_gmn)
  field_wave_am4_oneh   = wgt_areaave(fields_one_h,clat,1.0,0)
  print("weighted average of AM4 data for all height and tau..."+field_wave_am4_oneh)
  funny_stuff_t(0,i)=field_wave_am4_oneh
  i=i+1
end do

print("#$^@$%&$Hebrides&^(%^&$%^&^@#$%")
print("total weighted cloud fraction of am4 summing over all heights: "+dim_sum_n(funny_stuff_h,1))
print("#$^@$%&$Hebrides&^(%^&$%^&^@#$%")
print("total weighted cloud fraction of am4 summing over all heights: "+dim_sum_n(funny_stuff_h,0))
print("#$^@$%&$Hebrides&^(%^&$%^&^@#$%")
print("total weighted cloud fraction of am4 summing over all tau: "+dim_sum_n(funny_stuff_t,1))
print("#$^@$%&$&^(%^&$%^&^@#$%")
print("total weighted cloud fraction of am4 summing over all tau: "+dim_sum_n(funny_stuff_t,0))

;fields_one=fields_one_s(:,0,:,:)
;print("dimsizes of fields_one are: "+dimsizes(fields_one))

;field_wave_am4   = wgt_areaave(fields_one,clat,1.0,0)
;print("weighted average of AM4 data for one tau and height..."+field_wave_am4)

;field_wave_am4_nl  = wgt_areaave(fields_tmn_noland,clat,1.0,0)
;;field_wave_misr    = wgt_areaave(obs_fields_tmn,clat,1.0,1)
;field_wave_misr  = wgt_areaave(obs_fields_tmn,clat,1.0,0)

;;;
;; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
;; available non-missing data. 
;
;
;;; mean of tropics without cosine weighting
;;fields_trm_a =dim_avg_n(fields_patch,2)
;;fields_trm_am4   =dim_avg_n(fields_trm_a,2)
;;
;;  ;print("dimsizes of gmn_a are: "+dimsizes(fields_gmn_a))
;;;fields_point=fields_patch(:,:,90,144)
;;  print("=-=-=-=-=-=-=-")
;;  print("dimsizes of fields_trm_am4 for AM4 are: "+dimsizes(fields_trm_am4))
;
;fields_tmn!0          ="tau"
;fields_tmn&tau        =fields_full&tau
;fields_tmn!1          ="alt16"
;fields_tmn&alt16      =fields_full&alt16
;fields_tmn!2          ="lat"
;fields_tmn&lat        =fields_full&lat
;fields_tmn!3          ="lon"
;fields_tmn&lon        =fields_full&lon
;
;;***********************************************************************************
;; interpolate gfdl data to a 180x360 degree grid
;print("Beginning Interpolation")
;
;;var_to_interpolate=cfrac_tmn_totz_thick
;
;var_to_interpolate=fields_tmn
;
;copy_VarCoords(fields_tmn,var_to_interpolate)
;copy_VarCoords(interpolated_var,obs_fields_tmn)
;;copy_VarCoords(fields_tmn_noland,obs_fields_tmn)
;
;;
;dimgfdl=dimsizes(var_to_interpolate)
;print("dims of variable before interpolation: "+dimgfdl)
;;
;nlat=dimgfdl(2)
;nlon=dimgfdl(3)
;;
;nlati=180 ; number of input latitude points(it is the lon points which differ
;;
;latS=tofloat(var_to_interpolate&lat(0))                      ; southern extent of input grid
;latN=tofloat(var_to_interpolate&lat(nlat-1))                 ; northern extent of input grid
;;
;;;print(latS+"  "+latN+"   "+var4cal&lat(1)+"  "+var4cal&lat(89))
;;
;   opt = True
;;
;   NLAT1x1    = 180                               ; RES   = "180x288"
;   MLON1x1    = 360
;   LAT_1x1    = latGlobeFo(NLAT1x1, "LAT_1x1", "latitude" , "degrees_north")
;   LON_1x1    = lonGlobeFo(MLON1x1, "LON_1x1", "longitude", "degrees_east" )
;
;   opt@NLATi       = nlati
;   opt@NLATo       = NLAT1x1
;   LAT_REG_1x1     = LAT_1x1({latS:latN})
;   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_1x1, LAT_REG_1x1, opt)
;
;print("dims of variable after interpolation: "+dimsizes(interpolated_var))
;;***********************************************************************************
;
;fields_tmn_noland=where(obs_fields_tmn.eq.obs_fields_tmn@_FillValue,obs_fields_tmn@_FillValue,interpolated_var)
;
;copy_VarCoords(obs_fields_tmn,fields_tmn_noland)
;
;printVarSummary(obs_fields_tmn)
;printVarSummary(fields_tmn_noland)
;
;;;---------------------------------------------------------------------
;; compute lat weights to determine the global mn
;;;---------------------------------------------------------------------
;lat  = infile[0]->lat
;rad  = 4.0*atan(1.0)/180.0
;clat = cos(lat*rad)
;;;
;;field_wave_am4     = wgt_areaave(fields_tmn,clat,1.0,1)
;field_wave_am4   = wgt_areaave(fields_tmn,clat,1.0,0)
;field_wave_am4_nl  = wgt_areaave(fields_tmn_noland,clat,1.0,0)
;;field_wave_misr    = wgt_areaave(obs_fields_tmn,clat,1.0,1)
;field_wave_misr  = wgt_areaave(obs_fields_tmn,clat,1.0,0)
;;;
;; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
;; available non-missing data. 
;;---------------------------------------------------------------------
;; grab a particular region of the data, and that same regions lat array
;; and use this to create a cosine weighted mean for a non-global region
;
;dom_bot=1
;dom_top=6
;
;fields_pm30    =obs_fields_tmn(:,dom_bot:dom_top,60:119,:)
;fields_am4_pm30=fields_tmn_noland(:,dom_bot:dom_top,60:119,:)
;pm30lat        =clat(60:119)
;
;fields_nh30t60 =obs_fields_tmn(:,dom_bot:dom_top,120:149,:)
;fields_am4_nh30t60 =fields_tmn_noland(:,:dom_bot:dom_top,120:149,:)
;nhlat30to60    =clat(120:149)
;fields_sh30t60 =obs_fields_tmn(:,dom_bot:dom_top,30:59,:)
;fields_am4_sh30t60 =fields_tmn_noland(:,:dom_bot:dom_top,30:59,:)
;shlat30to60    =clat(30:59)
;
;fields_nh30t90 =obs_fields_tmn(:,dom_bot:dom_top,120:179,:)
;fields_am4_nh30t90 =fields_tmn_noland(:,:dom_bot:dom_top,120:179,:)
;nhlat30to90    =clat(120:179)
;fields_sh30t90 =obs_fields_tmn(:,dom_bot:dom_top,0:59,:)
;fields_am4_sh30t90 =fields_tmn_noland(:,dom_bot:dom_top,0:59,:)
;shlat30to90    =clat(0:59)
;
;; computed weighted means
;field_obs_gmn       = wgt_areaave(obs_fields_tmn,clat,1.0,0)
;field_gmn_am4       = wgt_areaave(fields_tmn_noland,clat,1.0,0)
;
;;field_wave_pm30_misr = wgt_areaave(fields_pm30,pm30lat,1.0,0)
;field_obs_pm30       = wgt_areaave(fields_pm30,pm30lat,1.0,0)
;field_am4_pm30       = wgt_areaave(fields_am4_pm30,pm30lat,1.0,0)
;
;field_obs_sh30t90 = wgt_areaave(fields_sh30t90,shlat30to90,1.0,0)
;field_obs_nh30t90 = wgt_areaave(fields_nh30t90,nhlat30to90,1.0,0)
;field_am4_sh30t90 = wgt_areaave(fields_am4_sh30t90,shlat30to90,1.0,0)
;field_am4_nh30t90 = wgt_areaave(fields_am4_nh30t90,nhlat30to90,1.0,0)
;
;field_obs_sh30t60 = wgt_areaave(fields_sh30t60,shlat30to60,1.0,0)
;field_obs_nh30t60 = wgt_areaave(fields_nh30t60,nhlat30to60,1.0,0)
;field_am4_sh30t60 = wgt_areaave(fields_am4_sh30t60,shlat30to60,1.0,0)
;field_am4_nh30t60 = wgt_areaave(fields_am4_nh30t60,nhlat30to60,1.0,0)
;
;; dimensions are 7x16
;print("dimensions of area weighted array are: "+dimsizes(field_obs_pm30))
;;--------------------------------
;;
;;-----------------------------------------------------------------
;; determine which regions will be tabulated.  save the desired 
;; arrays to fields and fields_obs
;;-----------------------------------------------------------------
;; global domain
;;fields     =field_gmn_am4
;;fields_obs =field_obs_gmn
;
;print("sum of global am4 cloud fraction: "+sum(field_gmn_am4))
;print("sum of global misr cloud fraction: "+sum(field_obs_gmn))
;
;; tropics: plus/minus 30
;;fields     =field_am4_pm30
;;fields_obs =field_obs_pm30
;
;print("sum of pm30 am4 cloud fraction: "+sum(field_am4_pm30))
;print("sum of pm30 misr cloud fraction: "+sum(field_obs_pm30))
;
;; higher latitudes
;;fields     =field_am4_nh30t90
;;fields_obs =field_obs_nh30t90
;
;print("sum of NH 30 to 90 am4 cloud fraction: "+sum(field_am4_nh30t90))
;print("sum of NH 30 to 90 misr cloud fraction: "+sum(field_obs_nh30t90))
;
;print("sum of SH 30 to 90 am4 cloud fraction: "+sum(field_am4_sh30t90))
;print("sum of SH 30 to 90 misr cloud fraction: "+sum(field_obs_sh30t90))
;
;; mid-latitudes
;;fields     =field_am4_nh30t60
;;fields_obs =field_obs_nh30t60
;
;print("sum of NH 30 to 60 am4 cloud fraction: "+sum(field_am4_nh30t60))
;print("sum of NH 30 to 60 misr cloud fraction: "+sum(field_obs_nh30t60))
;
;print("sum of SH 30 to 60 am4 cloud fraction: "+sum(field_am4_sh30t60))
;print("sum of SH 30 to 60 misr cloud fraction: "+sum(field_obs_sh30t60))
;
;;;titleRight="MISR SH"
;;;titleLeft ="MISR NH"
;;titleRight="MISR pm 30"
;;titleLeft ="AM4 pm 30"
;;
;;print("sum of tabulated am4 cloud fraction: "+sum(fields))
;;print("sum of tabulated misr cloud fraction: "+sum(fields_obs))
;
;; higher latitudes
;;fields     =field_wave_nh_misr
;;fields_obs =field_wave_sh_misr
;
;;----------------------------------------------------
;; Domain To Plot
;; define which region to tabulate and set titles...
;;----------------------------------------------------
;
;DomainOfInterest=0
;
;if (DomainOfInterest .lt. 1) then  ; default is 0 and plots global
;  print("!!!!! plotting Global mean data !!!!!")
;  fields     = field_gmn_am4
;  fields_obs = field_obs_gmn
;  titleRight="MISR: Global mn"
;  titleLeft ="AM4: Global mn"
;else if (DomainOfInterest .lt. 2) then
;  print("!!!!! plotting Tropical mean data !!!!!")
;  fields     = field_am4_pm30
;  fields_obs = field_obs_pm30
;  titleRight="MISR: 30S to 30N"
;  titleLeft ="AM4: 30S to 30N"
;else if (DomainOfInterest .lt. 3) then
;  print("!!!!! plotting mean data from 30N to 60N !!!!!")
;  fields     = field_am4_nh30t60
;  fields_obs = field_obs_nh30t60
;  titleRight="MISR: 30 to 60 NH"
;  titleLeft ="AM4: 30 to 60 NH"
;else 
;  print("!!!!! plotting mean data from 30S to 60S !!!!!")
;  fields     = field_am4_sh30t60
;  fields_obs = field_obs_sh30t60
;  titleRight="MISR: 30 to 60 SH"
;  titleLeft ="AM4: 30 to 60 SH"
;end if
;end if
;end if
;
;;-----------------------------------------------------------------
;;-----------------------------------------------------------------
;
;; name the dimensions of the newly created arrays
;fields!0="tau"
;cf_array!1="tau"
;
;fields_obs!0="tau"
;cf_array_obs!1="tau"
;
;fields&tau        =fields_full&tau
;cf_array&tau      =fields_full&tau
;fields_obs&tau    =fields_full&tau
;cf_array_obs&tau  =fields_full&tau
;
;fields!1          ="alt16"
;fields_obs!1      ="alt16"
;cf_array!0        ="alt16"
;cf_array_obs!0    ="alt16"
;
;fields&alt16      =fields_full&alt16
;fields_obs&alt16  =fields_full&alt16
;cf_array&alt16    =fields_full&alt16
;cf_array_obs&alt16=fields_full&alt16
;
;cf_array     =fields(alt16|:,tau|:)
;cf_array_obs =fields_obs(alt16|:,tau|:)
;
;cf_array     =cf_array(::-1,:)
;cf_array_obs =cf_array_obs(::-1,:)
;
;;;-----------------------------------------------------------
;;; save data for tables to text_values and text_obs
;;;-----------------------------------------------------------

;;;;-----------------------------------------------------------------------------
;;; Start the graphics.
;;;;-----------------------------------------------------------------------------
;; lower table
;;;;-----------------------------------------------------------------------------
;;;;-----------------------------------------------------------------------------
;; upper table
;;;;-----------------------------------------------------------------------------

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; block of code to plot maps
; DO NOT DELETE!!!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;if(plot_map) then
;; test plotting...
;  t_a    = dim_sum_n_Wrap(t_full,0)
;  t      = dim_sum_n_Wrap(t_a,0)
;
;  my_levels1 = (/6,12,18,24,30,36,42,48,54,60/) ; 10
;  my_levels1 = (/5,10,20,30,40,50,60,70,80,90/) ; 10
;  my_colors = (/30,37,44,51,58,65,72,79,86,93,100/) ; 11
;
;  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
;  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
;  ;gsn_define_colormap(wks,"WhBlGrYeRe")
;  gsn_define_colormap(wks,"MPL_YlGnBu")
;
;  res                   = True
;  ;res@mpProjection      = "Mollweide"       ; choose projection
;  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
;  res@mpPerimOn         = False             ; turn off box around plot
;  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
;  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
;  res@mpFillOn          = False
;
;; these commands turn off/on the varname and units at top of image
;  res@gsnLeftString = ""
;  res@gsnRightString = ""
;
;  res@cnFillOn          = True              ; color plot desired
;;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
;  res@cnLineLabelsOn    = False             ; turn off contour lines
;  res@cnLevelSelectionMode  = "ExplicitLevels"
;  res@cnLevels          = my_levels1
;  res@cnLinesOn         = False
;  res@cnFillColors      = my_colors
;  res@txFontHeightF     = 0.015
;
;  res@vpXF            = 0.1                 ; make plot bigger
;  res@vpYF            = 0.9
;  res@vpWidthF        = 0.8
;  res@vpHeightF       = 0.8
;
;  res@lbLabelFontHeightF  = 0.015           ; label bar font height
;
;  res@tiMainString       = "maintitle"  ; add a title
;  res@tiMainFontHeightF  = .018                               ; font height
;
;  contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
;end if
;
end
;





