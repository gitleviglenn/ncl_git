;***********************************************************************************
; wind10m_GlobalMap.ncl
;***********************************************************************************
;
;
; The comments in the next 25 lines appear to be from a totally different script and 
; are probably garbage.  but i need to go through the script again.  
;
; produces a 2 panel figure of 10m wind from ERA5.  wind is shown with filled 
; contours and a solid black contour is used to border the chosen region of the 
; doldrums, often chosen as 1,3, or 5 m/s wind speed.  
; 
; levi silvers                                                         june 2023 
;***********************************************************************************
; plot a 2d contour plot of omega on the 500 hPa surface
;
; some code was taken from tsfc_radflux_6pan_landmask_final.ncl which also 
; includes the ability to create polygons on the figure
;
; can be used in coordination with matlab scripts:
; use:  1) in the matlab gui specify the array to be written and the 
;       filename.  for example: 
;       v.wap500=omega_lat_678;
;       ncfilename='out1.nc'
; 
;       2) run the newncfile_CircDecomp.m scrit in the matlab gui: newncfile_CircDecomp
;
; for example: 
;   v.wap500=omega_lat_mn;
;   ncfilename='cesm2_amip_CircDecomp_lat_mn.nc';
;   size(omega_lon_mn)
;   newncfile_CircDecomp
;   v.wap500=omega_lon_mn;
;   ncfilename='cesm2_amip_CircDecomp_lon_mn.nc';
;   newncfile_CircDecomp
;   v.wap500=omega_tot_mn;
;   ncfilename='cesm2_amip_CircDecomp_tot_mn.nc';
;
; levi silvers                                                             feb 2023 
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin

;;datapath="/glade/collections/cmip/CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/wap/gn/latest/"
;;filename="wap_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
;datapath="~/data/CAM/CESM2/"
;filename="wap500_monthly_CESM2_amip_r1i1p1f1_gn_19800101-20150101.nc"

datapath="~/data/ERA5/"
filename="era5_monthly_1959present_10mWindSpeed.nc"

;EarthLike=1; default, EarthLike=1 corresponds to amip and historical

  ;expn   ="amip"
  ;ntimes ="120"
expn   ="hist"
ntimes ="120"
  print("plotting EarthLike simulations")

file1=filename

infile1=datapath+file1

f1=addfile(infile1,"r")
  print("incoming file is: "+infile1)

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts Pa/s to hPa/day

;pressAtLev = f1->plev
;  print(pressAtLev)
lat  = f1->latitude
lon  = f1->longitude

; for 2D input 
wind10m_full = f1->si10(:,:,:)
wind10m_test = f1->si10(:,:,:)
wind10m_inst = f1->si10(10,:,:)
wind10m_jan_sh  = f1->si10(0:59:12,:,:)
wind10m_feb_sh  = f1->si10(1:59:12,:,:)
wind10m_jun_sh  = f1->si10(5:59:12,:,:)
wind10m_jul_sh  = f1->si10(6:59:12,:,:)
wind10m_aug_sh  = f1->si10(7:59:12,:,:)
wind10m_dec_sh  = f1->si10(11:59:12,:,:)
  printVarSummary(wind10m_full)
  print("type of wind is: "+typeof(wind10m_test))
wind10m_flt = short2flt(wind10m_test)
wind10m_inst_flt = short2flt(wind10m_inst)
wind10m_jan = short2flt(wind10m_jan_sh)
wind10m_feb = short2flt(wind10m_feb_sh)
wind10m_jun = short2flt(wind10m_jun_sh)
wind10m_jul = short2flt(wind10m_jul_sh)
wind10m_aug = short2flt(wind10m_aug_sh)
wind10m_dec = short2flt(wind10m_dec_sh)
  printVarSummary(wind10m_jan)
  print("type of wind is: "+typeof(wind10m_flt))
wap500_mask = mask(wind10m_test,(wind10m_full .lt. 1000.),True)
wap500_flt_mask = mask(wind10m_flt,(wind10m_flt .lt. 1000.),True)
  print("****************************************************")
  printMinMax(wap500_mask,False)
  print("****************************************************")
  printMinMax(wap500_flt_mask,False)
  print("****************************************************")
wap500_tmn_1 = scalef*dim_avg_n_Wrap(wap500_flt_mask,0)
wap500_tmn_2 = scalef*wind10m_inst_flt
wind10_tmn_jan = scalef*dim_avg_n_Wrap(wind10m_jan,0)
wind10_tmn_feb = scalef*dim_avg_n_Wrap(wind10m_feb,0)
wind10_tmn_jun = scalef*dim_avg_n_Wrap(wind10m_jun,0)
wind10_tmn_jul = scalef*dim_avg_n_Wrap(wind10m_jul,0)
wind10_tmn_aug = scalef*dim_avg_n_Wrap(wind10m_aug,0)
wind10_tmn_dec = scalef*dim_avg_n_Wrap(wind10m_dec,0)
wind10_tmn_djf = (wind10_tmn_jan+wind10_tmn_feb+wind10_tmn_dec)/3
wind10_tmn_jja = (wind10_tmn_jun+wind10_tmn_jul+wind10_tmn_aug)/3
;wap500_tmn_1 = scalef*dim_avg_n_Wrap(wind10m_full,0)
;wap500_tmn_1 = f1->si10(58,:,:)

  printMinMax(wap500_tmn_1,False)

;  print(pressAtLev)
;  printVarSummary(wap_500_full)
;[time | 780] x [plev | 19] x [lat | 192] x [lon | 288]
; plev = 100000, 92500, 85000, 70000, 60000, 50000, 40000, 30000, 25000,
;    20000, 15000, 10000, 7000, 5000, 3000, 2000, 1000, 500, 100 ;

; grab the omega at only the 500 hPa surface


;; create land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat,lon)

  ;;; apply land sea mask
  ;; -----first file-----
  omega500_mask_1=mask(wap500_tmn_1,lsm.ge.1,False)  ; apply mask 
  ;omega500_mask_2=mask(wap500_tmn_2,lsm.ge.1,False)  ; apply mask 
  ;omega500_mask_2=mask(wap500_tmn_2,lsm.ge.1,False)  ; apply mask 
  ;omega500_mask_3=mask(wap500_tmn_3,lsm.ge.1,False)  ; apply mask 

omega500_mask_1!0="latitude"
omega500_mask_1&latitude=wind10m_full&latitude
omega500_mask_1!1="longitude"
omega500_mask_1&longitude=wind10m_full&longitude
omega500_mask_1=nameDim(omega500_mask_1,"latitude","latitude","degrees_north")
omega500_mask_1=nameDim(omega500_mask_1,"longitude","longitude","degrees_east")

aa=dimsizes(wap500_tmn_1)
  print("dimsizes of wap500_tmn_1 are:"+dimsizes(wap500_tmn_1))

omega500_mask_2 = new((/aa(0),aa(1)/),typeof(wap500_tmn_1))
omega500_mask_2!0="latitude"
omega500_mask_2&latitude=wind10m_full&latitude
omega500_mask_2!1="longitude"
omega500_mask_2&longitude=wind10m_full&longitude
omega500_mask_2=nameDim(omega500_mask_2,"latitude","latitude","degrees_north")
omega500_mask_2=nameDim(omega500_mask_2,"longitude","longitude","degrees_east")

wind10_mask_djf = new((/aa(0),aa(1)/),typeof(wap500_tmn_1))
wind10_mask_djf!0="latitude"
wind10_mask_djf&latitude=wind10m_full&latitude
wind10_mask_djf!1="longitude"
wind10_mask_djf&longitude=wind10m_full&longitude
wind10_mask_djf=nameDim(wind10_mask_djf,"latitude","latitude","degrees_north")
wind10_mask_djf=nameDim(wind10_mask_djf,"longitude","longitude","degrees_east")

wind10_mask_jja = new((/aa(0),aa(1)/),typeof(wap500_tmn_1))
wind10_mask_jja!0="latitude"
wind10_mask_jja&latitude=wind10m_full&latitude
wind10_mask_jja!1="longitude"
wind10_mask_jja&longitude=wind10m_full&longitude
wind10_mask_jja=nameDim(wind10_mask_jja,"latitude","latitude","degrees_north")
wind10_mask_jja=nameDim(wind10_mask_jja,"longitude","longitude","degrees_east")

print("dimsizes of wap500_tmn_2 are: "+dimsizes(wap500_tmn_2))
print("dimsizes of omega500_mask_2 are: "+dimsizes(omega500_mask_2))

  omega500_mask_2=mask(wap500_tmn_2,lsm.ge.1,False)  ; apply mask 
  wind10_mask_jja=mask(wind10_tmn_jja,lsm.ge.1,False)  ; apply mask 
  wind10_mask_djf=mask(wind10_tmn_djf,lsm.ge.1,False)  ; apply mask 

printVarSummary(wap500_tmn_1)

;omega500_mask_2!0="latitude"
;omega500_mask_2&latitude=wind10m_full&latitude
;omega500_mask_2!1="longitude"
;omega500_mask_2&longitude=wind10m_full&longitude
;omega500_mask_2=nameDim(omega500_mask_1,"latitude","latitude","degrees_north")
;omega500_mask_2=nameDim(omega500_mask_1,"longitude","longitude","degrees_east")

  printMinMax(omega500_mask_1,False)

  printVarSummary(omega500_mask_1) 
  
;-----------------------------------------
; begin the figure
;-----------------------------------------

  res                   = True

;my_levels_omega= (/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9/); 19
;my_levels_omega= (/0,3,3.5,4,4.5,5,6,7,8,9,10,11,12,13,14,15/); 16 
my_levels_omega= (/5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15/); 21 
;my_levels_omega= (/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8,9,10,11,12,13,14,15/); 21 
;
; below is the original color scheme
;my_colors_posneg = (/ 2,2,63,75,87,99,111,123,135,147,159,171,183,195,207,219,231/); 22 
res@cnLevelFlags=(/"LineOnly","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine", \
                     "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
my_colors_posneg = (/ 2,26,39,51,63,75,87,99,111,123,135,147,159,171,183,190,200,210,220,230,240,250/); 22 
;my_colors_posneg = (/ 2,13,25,37,49,51,63,75,87,99,111,123,135,147,159,171,183,195,207,219,231,243/); 22 
;                     1,  2, 3, 4,5 , 6 , 7 , 8 , 9 ,10 , 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

  wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteBlue")
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  ;gsn_define_colormap(wks,"NCV_blu_red")
  plot = new(2,graphic)

  ;res@lbOrientation     = "Vertical"
  ;res@gsnPaperOrientation = "portrait" 
  ;res@mpProjection      = "Robinson"       ; choose projection
  res@mpProjection      = "Mollweide"       ; choose projection
  ;res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpCenterLonF      = 200.
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 10.               ; spacing for lat lines
  res@mpGridLonSpacingF = 10.               ; spacing for lon lines
  ;res@lbLabelAngleF     = 90
  res@mpFillOn          = False 
  res@gsnDraw           = False
  res@gsnFrame          = False

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            =  30.
  res@mpMinLonF            =  0.
  res@mpMaxLonF            = 360.
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = True
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ; plotting only the zero contour line isn't working for some reason. 
  ;res@gsnContourZeroLineThicknessF = 2.5
  ;res@txFontHeightF     = 0.018 

  res@vpKeepAspect    = False
  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8
  ;res@vpWidthF        = 0.4
  ;res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .020                               ; font height

  res@tiMainString      = "ERA5 10m Wind JJA"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False


;    print("dimsizes of omega500_mask_1 are: "+dimsizes(omega500_mask_1))
  ;contour_1 = gsn_csm_contour_map(wks,omega500_mask_1,res)  ; create the plot
  contour_1 = gsn_csm_contour_map(wks,wind10_mask_jja,res)  ; create the plot
  res@tiMainString      = "ERA5 10m Wind DJF"
  ;contour_2 = gsn_csm_contour_map(wks,omega500_mask_2,res)  ; create the plot
  contour_2 = gsn_csm_contour_map(wks,wind10_mask_djf,res)  ; create the plot
  res@tiMainString      = " "

  plot(0) = contour_1
  plot(1) = contour_2

  resP                  = True                   ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
  ;resP@lbOrientation     = "vertical"
  resP@pmLabelBarWidthF  = 0.75             ; make thinner
  resP@lbLabelFontHeightF= 0.02             ; make thinner
  resP@lbLabelFontThicknessF = 2.5             ; make thinner
  resP@pmLabelBarHeightF = 0.15
  resP@lbBoxLinesOn            = True
  ;res@lbOrientation           = "Vertical"
  resP@lbTitleString           = "wind (m/s)"
  resP@lbTitlePosition         = "Bottom"
  resP@lbLabelFontHeightF      = 0.013
  resP@lbTitleFontHeightF      = 0.013

    ;pres@pmLabelBarHeightF = 0.20
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/2,1/),resP)

;-----------------------------------------
end
;-----------------------------------------
