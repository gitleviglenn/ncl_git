;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; open_file_cesm
;
; just open a file on casper and print out basic info
;
; levi silvers                                                           feb 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  
path_cmip6="/glade/campaign/collections/cmip/CMIP6/"
exp_file_c6="timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/atm/proc/tseries/day_1/"

path_cmip5="/glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/"
exp_file_c5="piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/"
file_c5="cl_Amon_CESM1-CAM5_piControl_r1i1p1_031001-031912.nc"

file_lsmask="/glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/fx/atmos/fx/r0i0p0/files/sftlf_20120614/sftlf_fx_CESM1-CAM5_amip_r0i0p0.nc"

if (isvar("filen")) then
  filename=filen
else 
  filename="b.e21.B1850.f09_g17.CMIP6-piControl.001.cam.h1.TS.16900101-16991231.nc"
end if

; read in monthly data in stead of the raw data on daily frequencies...

;; amip paths
;file_c5_in ="/glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/cl/cl_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
;file_c6_in="/glade/collections/cmip/CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/cl/gn/latest/cl_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"

; picontrol paths
;file_c6_in =path_cmip6+exp_file_c6+filename
file_c6_in="/glade/collections/cmip/CMIP6/CMIP/NCAR/CESM2/piControl/r1i1p1f1/Amon/cl/gn/latest/cl_Amon_CESM2_piControl_r1i1p1f1_gn_060001-069912.nc"

file_c5_in =path_cmip5+exp_file_c5+file_c5
c5_picontrol_fils=systemfunc("ls /glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/cl_Amon_CESM1-CAM5_piControl_r1i1p1_*nc")
f_test   =addfiles(c5_picontrol_fils,"r")
ListSetType(f_test,"cat")


f_in     =addfile(file_c6_in,"r")
f_in_2   =addfile(file_c5_in,"r")
f_in_lsm =addfile(file_lsmask,"r")
  print("incoming file is: "+file_c6_in)
  print("incoming file is: "+file_c5_in)

endtime=119
endtime2=1199
;endtime=139

;c5_test_cl = f_test[:]->cl
;f_in_2 = f_test[:]->cl
c5_cl = f_test[:]->cl
dc5=dimsizes(c5_cl)
endtime=3827
  print("first dimension of dc5 is: "+dc5(0))
;endtime=dc5(0)-1  ; 3828
  print("dc5 are the dimensions of c5_cl: "+dc5)
  printVarSummary(c5_cl)
;c6_cl     =f_in->CLOUD(0:endtime,:,:,:)
;c6_cl     =f_in->CLOUD(:,:,:,:)
c6_cl     =f_in->cl(0:endtime2,:,:,:)
;c5_cl     =f_in_2->cl(0:endtime,:,:,:)
;c5_cl     =f_in_2->cl(:,:,:,:)
c5_sftlf  =f_in_lsm->sftlf ; land area fraction

dims5=dimsizes(c5_cl)
dims6=dimsizes(c6_cl)

;-------------------------------------
; calculate the pressure values of at each model level for cesm1

press_lev_5 = new(dims5(1),float)
ps_trop   = new((/24,dims5(3)/),float)

c5_aa  = f_in_2->a ; lev
c5_a   = tofloat(c5_aa)
c5_bb  = f_in_2->b ; lev
c5_b   = tofloat(c5_bb)
c5_p0  = f_in_2->p0 ; constant
c5_ps  = f_in_2->ps ; time, lat, lon

c5_lat = f_in_2->lat

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

c6_aa  = f_in->a ; lev
c6_a   = tofloat(c6_aa)
c6_bb  = f_in->b ; lev
c6_b   = tofloat(c6_bb)
c6_p0  = f_in->p0 ; constant
c6_ps  = f_in->ps ; time, lat, lon

c6_lat = f_in->lat

c6_ps_tmn = dim_avg_n(c6_ps,0)
ps_trop(:,:) = c6_ps_tmn(84:107,:)
ps_trop_mn_a = dim_avg_n(ps_trop,0)
ps_trop_mn   = dim_avg_n(ps_trop_mn_a,0) 
;; formula = "p = a*p0 + b*ps"
press_lev_6 = (c6_a*c6_p0 + c6_b*ps_trop_mn)/100.  ; convert to hPa

vaxis_6a = press_lev_6

binary_lsmask=where(c5_sftlf.gt.0,0.0,1.0)

c5_cl_noland   =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)
c5_cl_pm30trop =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)
c5_cl_pm10trop =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)
c5_cl_pm5trop  =new((/endtime+1,dims5(1),dims5(2),dims5(3)/),float)

c5_cl_pm30trop = 9.96921e+36 
c5_cl_pm10trop = 9.96921e+36 
c5_cl_pm5trop  = 9.96921e+36 

c6_cl_noland   =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)
c6_cl_pm30trop =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)
c6_cl_pm10trop =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)
c6_cl_pm5trop  =new((/endtime2+1,dims6(1),dims6(2),dims6(3)/),float)

c6_cl_noland@missing_value=c6_cl@missing_value
;c6_cl_pm30trop = c6_cl_noland@missing_value
c6_cl_pm30trop = 9.96921e+36 
c6_cl_pm10trop = 9.96921e+36   ;c6_cl@missing_value
c6_cl_pm5trop  = 9.96921e+36   ;c6_cl@missing_value

printVarSummary(c6_cl_pm5trop)

; apply landsea mask...
c5_cl_noland=mask(c5_cl,conform(c5_cl,binary_lsmask,(/2,3/)),0)
c6_cl_noland=mask(c6_cl,conform(c6_cl,binary_lsmask,(/2,3/)),0)

printVarSummary(c6_cl_noland)

; latitudes to analyze
; 96 is the midpoint
;fd_lat1=80    ; 0 at NP
;fd_lat2=100   ; 180 at SP

trop_pm30_lat1=64    ; 0 at NP       
trop_pm30_lat2=127   ; 180 at SP
trop_pm10_lat1=85    ; 0 at NP       
trop_pm10_lat2=106   ; 180 at SP
trop_pm5_lat1=90    ; 0 at NP       
trop_pm5_lat2=101   ; 180 at SP

  print("dimsizes of c5_cl_pm30trop are: "+dimsizes(c5_cl_pm30trop))
  print("dimsizes of c5_cl_noland are: "+dimsizes(c5_cl_noland))
c5_cl_pm30trop(:,:,trop_pm30_lat1:trop_pm30_lat2,0:287)=c5_cl_noland(:,:,trop_pm30_lat1:trop_pm30_lat2,0:287)
c5_cl_pm10trop(:,:,trop_pm10_lat1:trop_pm10_lat2,0:287)=c5_cl_noland(:,:,trop_pm10_lat1:trop_pm10_lat2,0:287)
c5_cl_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)=c5_cl_noland(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)

c6_cl_pm30trop(:,:,trop_pm30_lat1:trop_pm30_lat2,0:287)=c6_cl_noland(:,:,trop_pm30_lat1:trop_pm30_lat2,0:287)
c6_cl_pm10trop(:,:,trop_pm10_lat1:trop_pm10_lat2,0:287)=c6_cl_noland(:,:,trop_pm10_lat1:trop_pm10_lat2,0:287)
c6_cl_pm5trop(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)=c6_cl_noland(:,:,trop_pm5_lat1:trop_pm5_lat2,0:287)

c5_cl_noland_tmn   = dim_avg_n(c5_cl_noland,0)
c5_cl_pm30trop_tmn = dim_avg_n(c5_cl_pm30trop,0)
c5_cl_pm10trop_tmn = dim_avg_n(c5_cl_pm10trop,0)
c5_cl_pm5trop_tmn  = dim_avg_n(c5_cl_pm5trop,0)

c6_cl_noland_tmn   = dim_avg_n(c6_cl_noland,0)
c6_cl_pm30trop_tmn = dim_avg_n(c6_cl_pm30trop,0)
c6_cl_pm10trop_tmn = dim_avg_n(c6_cl_pm10trop,0)
c6_cl_pm5trop_tmn  = dim_avg_n(c6_cl_pm5trop,0)

  print("dimsizes of c5_cl_pm30trop are: "+dimsizes(c5_cl_pm30trop))
  print("dimsizes of c5_cl_noland_tmn are: "+dimsizes(c5_cl_noland_tmn))

;-------------------------------------
; compute cosine weighted mean value for the profiles...
lat  = f_in->lat
  print("latitudes are: "+lat)
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)

field_c5_gmn   = wgt_areaave(c5_cl_noland_tmn,clat,1.0,0)
field_c5a_gmn   = wgt_areaave(c5_cl_pm30trop_tmn,clat,1.0,0)
field_c5b_gmn   = wgt_areaave(c5_cl_pm10trop_tmn,clat,1.0,0)
field_c5c_gmn   = wgt_areaave(c5_cl_pm5trop_tmn,clat,1.0,0)
field_c6_gmn   = wgt_areaave(c6_cl_noland_tmn,clat,1.0,0)
field_c6a_gmn   = wgt_areaave(c6_cl_pm30trop_tmn,clat,1.0,0)
field_c6b_gmn   = wgt_areaave(c6_cl_pm10trop_tmn,clat,1.0,0)
field_c6c_gmn   = wgt_areaave(c6_cl_pm5trop_tmn,clat,1.0,0)

;field_obs_gmn           = wgt_areaave(t_prof,clat,1.0,0)
;full_field_obs_gmn      = wgt_areaave(fullDom_prof,clat,1.0,0)
;dc_field_obs_gmn        = wgt_areaave(dc_Dom_prof,clat,1.0,0)
;  print("weighted mean values c5: "+field_c5_gmn)
;  printVarSummary(field_c5_gmn)
;  print("weighted mean values c5a: "+field_c5a_gmn)
;  print("weighted mean values c5b: "+field_c5b_gmn)
;  print("weighted mean values c5c: "+field_c5c_gmn)
;  print("full domain weighted mean values: "+field_obs_gmn)

;-------
;;  print("values of c5_sftlf are: "+c5_sftlf(96,:))
;;  print("values of c6_cl are: "+c6_cl(0,15,96,:))
;  print("values of c5_cl_noland are: "+c5_cl_noland(0,15,96,:))
;  print("values of c5_cl_noland are: "+c5_cl_noland(:,15,96,144))
;  print("values of c5_cl_pm5trop_tmn are: "+c5_cl_pm5trop_tmn(:,1,144))
;  print("values of c5_cl_pm5trop_tmn are: "+c5_cl_pm5trop_tmn(15,1,:))
;  print("values of c6_cl_noland are: "+c6_cl_noland(0,15,96,:))
;  print("values of c6_cl_noland are: "+c6_cl_noland(:,15,96,144))

;**************************************************************************
;      create plot
;**************************************************************************

wks=gsn_open_wks("eps","testplot")
gsn_define_colormap(wks,"CBR_drywet")
plot=new(1,graphic)

res                                     = True

  res@gsnDraw          = False
  res@gsnFrame         = False

  res@xyDashPattern          = 0
;
;
  res@tiYAxisString          = ""
  res@tiXAxisString          = "Cloud Fraction"
  res@tiYAxisString          = "Pressure (hPa)"
  res@trXMaxF                =  0.45
  res@trXMinF                =  0.0
  res@trYMaxF                =  1000.0
  res@trYMinF                =  10.0
  res@trYReverse             = True     ; reverse the y-axis
;
  res@xyLineColors = "chocolate2"
  res@xyLineThicknessF  = 4.0
    print("max of c5 cl fract is: "+max(field_c5_gmn))
    print("c5 cl fract is: "+field_c5_gmn)
    print("vaxis_5a is: "+vaxis_5a)
  plot1 = gsn_csm_xy(wks,field_c5_gmn(:),vaxis_5a,res)
;  res@xyLineThicknessF  = 2.0
  res@xyDashPattern = 2
  plot1a = gsn_csm_xy(wks,field_c5a_gmn(:),vaxis_5a,res)
;  res@xyLineThicknessF  = 3.0
  res@xyDashPattern = 1
  plot1b = gsn_csm_xy(wks,field_c5b_gmn(:),vaxis_5a,res)
;  res@xyLineThicknessF  = 4.0
  res@xyDashPattern = 0
  plot1c = gsn_csm_xy(wks,field_c5c_gmn(:),vaxis_5a,res)
;
  res@xyLineColors = "aquamarine3"
  res@xyLineThicknessF  = 4.0
    print("-----------")
    print("max of c6 cl fract is: "+max(field_c6_gmn))
    print("c6 cl fract is: "+field_c6_gmn)
    print("vaxis_6a is: "+vaxis_6a)
  scale_c6_cl=0.01
  res@xyDashPattern = 0
  plot2  = gsn_csm_xy(wks,scale_c6_cl*field_c6_gmn(:),vaxis_6a,res)
;  res@xyLineThicknessF  = 2.0
  res@xyDashPattern = 2
  plot2a = gsn_csm_xy(wks,scale_c6_cl*field_c6a_gmn(:),vaxis_6a,res)
;  res@xyLineThicknessF  = 3.0
  res@xyDashPattern = 1
  plot2b = gsn_csm_xy(wks,scale_c6_cl*field_c6b_gmn(:),vaxis_6a,res)
;  res@xyLineThicknessF  = 4.0
  res@xyDashPattern = 0
  plot2c = gsn_csm_xy(wks,scale_c6_cl*field_c6c_gmn(:),vaxis_6a,res)
;;
;; for global mean
;overlay(plot1,plot2)
;plot(0) =plot1
; for tropical domains
;;overlay(plot1a,plot2)
;;overlay(plot1a,plot1a)
overlay(plot1a,plot1b)
overlay(plot1a,plot1c)
overlay(plot1a,plot2a)
overlay(plot1a,plot2b)
overlay(plot1a,plot2c)
plot(0) =plot1a
;;;

;
;;maintitle="try again bafoon"
;
  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  lgres@xyLineLabelFontHeightF = 0.015                ; font height
  lgres@lgLineColors         = (/"aquamarine3","chocolate2"/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .06
  lgres@vpWidthF             = 0.2        ; width of legend
  lgres@vpHeightF            = 0.18        ; height of legend
  lgres@lgPerimOn            = False                         ; turn off box around
  lgres@lgLineThicknessF     = 3.0
;;  lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False
  lgres@lgDashIndexes          = (/"0","0"/)
;
  title1="CAM6"
  title2="CAM5"
  labels = (/title1,title2/)
  legend  = gsn_create_legend (wks, 2, labels, lgres)

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









