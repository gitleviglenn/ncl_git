;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; cf_profile_cesm_rcemip.ncl
;
; the purpose of looking at these cloud profiles is for comparison with RCE cloud 
; profiles from CAM5 and CAM6 RCE studies.
;
; plot tropical cloud profiles from the amip and piControl experiments as simulated 
; by the CAM5,CAM6,CESM1, and CESM2 models.
;
; after reading in the 3D cloud fraction data, apply a land-sea mask so that we only
; plot points over oceans. 
;
; levi silvers                                                           feb 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  
path_cmip6="/glade/campaign/collections/cmip/CMIP6/"
tocmip ="/glade/collections/cmip/"
;exp_file_c6="timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/atm/proc/tseries/day_1/"

path_cmip5=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/"

file_lsmask=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/fx/atmos/fx/r0i0p0/files/sftlf_20120614/sftlf_fx_CESM1-CAM5_amip_r0i0p0.nc"

;if (plotAmip) then
  filen5="cl_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
  filen6="cl_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
  ;file_c5_in=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/cl/"+filen5
  file_c5_am=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/cl/"+filen5
  ;file_c6_in=tocmip+"CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  file_c6_am=tocmip+"CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  endtime =239
;else ; picontrol patha
  endtime2=1199
  filen6="cl_Amon_CESM2_piControl_r1i1p1f1_gn_060001-069912.nc"
  exp_file_c5="piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/"
  ;file_c6_in=tocmip+"CMIP6/CMIP/NCAR/CESM2/piControl/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  file_c6_piC=tocmip+"CMIP6/CMIP/NCAR/CESM2/piControl/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  filen5="cl_Amon_CESM1-CAM5_piControl_r1i1p1_031001-031912.nc"
  file_c5_piC =path_cmip5+exp_file_c5+filen5
  ; use addfiles to read multiple files at once...
  c5_picontrol_fils=systemfunc("ls /glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/cl_Amon_CESM1-CAM5_piControl_r1i1p1_02*nc")
  f_test   =addfiles(c5_picontrol_fils,"r")
  ListSetType(f_test,"cat")

f_in_c5_am     =addfile(file_c5_am,"r") ; reads from single file for vert dim creation.
f_in_c5_piC    =addfile(file_c5_piC,"r") ; reads from single file for vert dim creation.

f_in_c6_am     =addfile(file_c6_am,"r")
f_in_c6_piC    =addfile(file_c6_piC,"r")

f_in_lsm =addfile(file_lsmask,"r")

  print("incoming piC for cesm1 file is: "+file_c5_piC)
  print("incoming piC for cesm2 file is: "+file_c6_piC)
  print("incoming amip for cam5 file is: "+file_c5_am)
  print("incoming amip for cam6 file is: "+file_c6_am)

c5_amip_cl     =f_in_c5_am->cl(0:endtime,:,:,:)
c6_amip_cl     =f_in_c6_am->cl(0:endtime,:,:,:)
c5_piC_cl_full      = f_test[:]->cl    ; read 3D cloud fraction
c5_piC_cl      =c5_piC_cl_full(0:endtime2,:,:,:)  
c6_piC_cl      =f_in_c6_piC->cl(0:endtime2,:,:,:)   ; read 3D cloud fraction 

;if (plotAmip) then
  ;c5_cl     =f_in_2->cl(0:endtime,:,:,:)
;  c5_amip_cl     =f_in_2->cl(0:endtime,:,:,:)
;end if

c5_sftlf  =f_in_lsm->sftlf ; land area fraction
;-------------------------------------------------

dims5=dimsizes(c5_amip_cl)
dims6=dimsizes(c6_amip_cl)

;-------------------------------------------------
; calculate the pressure values of at each model level for cesm1

press_lev_5 = new(dims5(1),float)
ps_trop   = new((/24,dims5(3)/),float)

c5_aa  = f_in_c5_am->a ; lev
c5_a   = tofloat(c5_aa)
c5_bb  = f_in_c5_am->b ; lev
c5_b   = tofloat(c5_bb)
c5_p0  = f_in_c5_am->p0 ; constant
c5_ps  = f_in_c5_am->ps ; time, lat, lon

c5_lat = f_in_c5_am->lat

printVarSummary(c5_ps)
;print("latitudes are: "+c5_lat)

c5_ps_tmn = dim_avg_n(c5_ps,0)
ps_trop(:,:) = c5_ps_tmn(84:107,:)
ps_trop_mn_a = dim_avg_n(ps_trop,0)
ps_trop_mn   = dim_avg_n(ps_trop_mn_a,0) 
;printVarSummary(ps_trop)
;; formula = "p = a*p0 + b*ps"
printVarSummary(c5_a)
printVarSummary(c5_p0)
printVarSummary(c5_b)
printVarSummary(ps_trop_mn)
press_lev_5 = (c5_a*c5_p0 + c5_b*ps_trop_mn)/100.  ; convert to hPa

;vaxis_5a = press_lev_5(::-1)
vaxis_5a = press_lev_5

;-------------------------------------
; calculate the pressure values of at each model level for cesm2

press_lev_6 = new(dims6(1),float)
ps_trop     = new((/24,dims6(3)/),float)

c6_aa  = f_in_c6_am->a ; lev
c6_a   = tofloat(c6_aa)
c6_bb  = f_in_c6_am->b ; lev
c6_b   = tofloat(c6_bb)
c6_p0  = f_in_c6_am->p0 ; constant
c6_ps  = f_in_c6_am->ps ; time, lat, lon

c6_lat = f_in_c6_am->lat

c6_ps_tmn = dim_avg_n(c6_ps,0)
ps_trop(:,:) = c6_ps_tmn(84:107,:)
ps_trop_mn_a = dim_avg_n(ps_trop,0)
ps_trop_mn   = dim_avg_n(ps_trop_mn_a,0) 
;; formula = "p = a*p0 + b*ps"
press_lev_6 = (c6_a*c6_p0 + c6_b*ps_trop_mn)/100.  ; convert to hPa

vaxis_6a = press_lev_6

binary_lsmask=where(c5_sftlf.gt.0,0.0,1.0)

;c5_cl_noland       =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)
c5_cl_am_pm5trop   =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)
c5_cl_piC_pm5trop  =new((/endtime2+1,dims5(1),dims5(2),dims5(3)/),float)

c5_cl_am_pm5trop   = 9.96921e+36 
c5_cl_piC_pm5trop  = 9.96921e+36 

;c6_cl_am_noland       =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)
c6_cl_am_pm5trop   =new((/endtime+1,dims6(1),dims6(2),dims6(3)/),float)
c6_cl_piC_pm5trop  =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)

;c6_cl_noland@missing_value=c6_piC_cl@missing_value
c6_cl_pm5trop      = 9.96921e+36   ;c6_cl@missing_value
c6_cl_am_pm5trop   = 9.96921e+36   ;c6_cl@missing_value
c6_cl_piC_pm5trop  = 9.96921e+36   ;c6_cl@missing_value

;printVarSummary(c6_cl_pm5trop)

; apply landsea mask...
  print("what in the dickens is going on here? ")
;  print("dimsizes of c5_cl_noland are: "+dimsizes(c5_cl_noland))
;  print("dimsizes of c5_cl are: "+dimsizes(c5_cl))
c5_cl_noland_am  =mask(c5_amip_cl,conform(c5_amip_cl,binary_lsmask,(/2,3/)),0)
c5_cl_noland_piC =mask(c5_piC_cl,conform(c5_piC_cl,binary_lsmask,(/2,3/)),0)
c6_cl_noland_am  =mask(c6_amip_cl,conform(c6_amip_cl,binary_lsmask,(/2,3/)),0)
c6_cl_noland_piC =mask(c6_piC_cl,conform(c6_piC_cl,binary_lsmask,(/2,3/)),0)

printVarSummary(c5_cl_am_pm5trop)
printVarSummary(c5_cl_noland_am)
printVarSummary(c5_cl_piC_pm5trop)
printVarSummary(c5_cl_noland_piC)

; latitudes to analyze
; 96 is the midpoint
;fd_lat1=80    ; 0 at NP
;fd_lat2=100   ; 180 at SP

; set the geographic regions to select
trop_pm5_lat1=90    ; 0 at NP       
trop_pm5_lat2=101   ; 180 at SP

;  print("dimsizes of c5_cl_noland are: "+dimsizes(c5_cl_noland))
c5_cl_am_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)  =c5_cl_noland_am(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)
c5_cl_piC_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287) =c5_cl_noland_piC(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)

c6_cl_am_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)  =c6_cl_noland_am(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)
c6_cl_piC_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287) =c6_cl_noland_piC(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)

c5_cl_noland_tmn       = dim_avg_n(c5_cl_noland_am,0)
c5_cl_am_pm5trop_tmn   = dim_avg_n(c5_cl_am_pm5trop,0)
c5_cl_piC_pm5trop_tmn  = dim_avg_n(c5_cl_piC_pm5trop,0)

;c6_cl_noland_tmn       = dim_avg_n(c6_cl_noland,0)
c6_cl_am_pm5trop_tmn   = dim_avg_n(c6_cl_am_pm5trop,0)
c6_cl_piC_pm5trop_tmn  = dim_avg_n(c6_cl_piC_pm5trop,0)

;  print("dimsizes of c5_cl_noland_tmn are: "+dimsizes(c5_cl_noland_tmn))

;-------------------------------------
; compute cosine weighted mean value for the profiles...
lat  = f_in_c6_am->lat
  print("latitudes are: "+lat)
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)

;field_c5_gmn      = wgt_areaave(c5_cl_noland_tmn,clat,1.0,0)
field_am_c5_gmn   = wgt_areaave(c5_cl_am_pm5trop_tmn,clat,1.0,0)
field_piC_c5_gmn  = wgt_areaave(c5_cl_piC_pm5trop_tmn,clat,1.0,0)
;field_c6_gmn      = wgt_areaave(c6_cl_noland_tmn,clat,1.0,0)
field_am_c6_gmn   = wgt_areaave(c6_cl_am_pm5trop_tmn,clat,1.0,0)
field_piC_c6_gmn  = wgt_areaave(c6_cl_piC_pm5trop_tmn,clat,1.0,0)

;**************************************************************************
;      create plot
;**************************************************************************

wks=gsn_open_wks("eps","testplot")
gsn_define_colormap(wks,"CBR_drywet")
plot=new(1,graphic)

res                        = True

res@gsnDraw                = False
res@gsnFrame               = False

res@vpWidthF               = 0.3         
res@vpHeightF              = 0.5        
res@xyDashPattern          = 0
res@tiYAxisString          = ""
res@tiXAxisString          = "Cloud Fraction"
res@tiYAxisString          = "Pressure (hPa)"
res@trXMaxF                =  0.6
res@trXMinF                =  0.0
res@trYMaxF                =  1000.0
res@trYMinF                =  10.0
res@trYReverse             = True     ; reverse the y-axis
;res@xyLineColors = "chocolate2"
res@xyLineThicknessF  = 4.0
res@xyDashPattern = 2
;  plot1a = gsn_csm_xy(wks,field_c5a_gmn(:),vaxis_5a,res)
;
;res@xyLineColors = "aquamarine3"
res@xyLineThicknessF  = 4.0
;    print("-----------")
;    print("max of c6 cl fract is: "+max(field_c6_gmn))
;    print("c6 cl fract is: "+field_c6_gmn)
;    print("vaxis_6a is: "+vaxis_6a)
scale_c6_cl=0.01
res@xyDashPattern = 0
res@xyLineColors = "chocolate2"
  plot2  = gsn_csm_xy(wks,field_am_c5_gmn(:),vaxis_5a,res)
res@xyDashPattern = 0
res@xyLineColors = "aquamarine3"
  plot2a = gsn_csm_xy(wks,scale_c6_cl*field_am_c6_gmn(:),vaxis_6a,res)
res@xyDashPattern = 1
res@xyLineColors = "chocolate2"
  plot2b = gsn_csm_xy(wks,field_piC_c5_gmn(:),vaxis_5a,res)
res@xyDashPattern = 1
res@xyLineColors = "aquamarine3"
  plot2c = gsn_csm_xy(wks,scale_c6_cl*field_piC_c6_gmn(:),vaxis_6a,res)
;;
;; for global mean
;plot(0) =plot1
; for tropical domains
overlay(plot2,plot2a)
overlay(plot2,plot2b)
overlay(plot2,plot2c)
plot(0) =plot2
;;;

;
;;maintitle="try again bafoon"
;
  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  lgres@xyLineLabelFontHeightF = 0.012                ; font height
  lgres@lgLineColors         = (/"aquamarine3","chocolate2","aquamarine3","chocolate2"/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .06
  lgres@vpWidthF             = 0.15        ; width of legend
  lgres@vpHeightF            = 0.13        ; height of legend
  lgres@lgPerimOn            = False                         ; turn off box around
  lgres@lgLineThicknessF     = 3.0
  lgres@lgMonoDashIndex      = False
  lgres@lgDashIndexes          = (/"0","0","1","1"/)
;
;if (plotAmip) then
  title1="CAM6" ; amip"
  title2="CAM5" ; amip"
;  title3="+/-30"
;  title4="+/-10"
;  title5="+/-5"
;else
  title3="CESM2" ; piControl"
  title4="CESM1" ; piControl"
;  title3="+/-30"
;  title4="+/-10"
;  title5="+/-5"
;end if
  labels = (/title1,title2,title3,title4/)
  legend  = gsn_create_legend (wks, 4, labels, lgres)

  amres = True
  amres@amJust = "BottomRight"

  amres@amParallelPosF   = 0.44    ; Move legend to right
  ;amres@amParallelPosF   = 0.05    ; Move legend to right
  amres@amOrthogonalPosF = 0.47     ; Move legend down

  annoid = gsn_add_annotation(plot(0),legend,amres) ; add legend to plot

respanel = True
;respanel@txString = maintitle

gsn_panel(wks,plot,(/1,1/),respanel)

end



