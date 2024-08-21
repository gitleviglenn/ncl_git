;***********************************************************************************
; wap500_GlobalMap.ncl
;***********************************************************************************
;
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
; levi silvers                                                             dec 2022 
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

datapath="~/code/matlab_scripts/CircDecomposition/"
filename="cesm2_amip_CircDecomp_HC.nc"
;file1="amip_CircDecomp_tot_678.nc"
;file1="cesm2_amip_CircDecomp_tot_678.nc"
;file2="cesm2_amip_CircDecomp_lat_678.nc"
;file3="cesm2_amip_CircDecomp_lon_678.nc"

EarthLike=1; default, EarthLike=1 corresponds to amip and historical

if (EarthLike .eq. 0) then
  ;expn   ="rce"
  ;ntimes ="30"
  ;expn   ="aqua"
  ;ntimes ="120"
  expn   ="mockW"
  ntimes ="30"
  print("plotting non-EarthLike simulations")
else if (EarthLike .eq. 1) then
  ;expn   ="amip"
  ;ntimes ="120"
  expn   ="hist"
  ntimes ="120"
  print("plotting EarthLike simulations")
end if
end if

file1="cesm2_"+expn+"_CircDecomp_tot_mn_"+ntimes+".nc"
file2="cesm2_"+expn+"_CircDecomp_lat_mn_"+ntimes+".nc"
file3="cesm2_"+expn+"_CircDecomp_lon_mn_"+ntimes+".nc"

infile1=datapath+file1
infile2=datapath+file2
infile3=datapath+file3

f1=addfile(infile1,"r")
f2=addfile(infile2,"r")
f3=addfile(infile3,"r")
  print("incoming file is: "+infile1)
  print("incoming file is: "+infile2)
  print("incoming file is: "+infile3)

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts Pa/s to hPa/day

;pressAtLev = f1->plev
;  print(pressAtLev)
lat  = f1->lat
lon  = f1->lon

;; if a time dimension is present: 
;wap_500_full = f1->wap500(:,:,:)
;wap500_tmn = scalef*dim_avg_n_Wrap(wap_500_full,0)

; for 2D input 
wap_500_full = f1->wap500(:,:)
wap500_tmn_1 = scalef*wap_500_full
wap_500_full = f2->wap500(:,:)
wap500_tmn_2 = scalef*wap_500_full
wap_500_full = f3->wap500(:,:)
wap500_tmn_3 = scalef*wap_500_full

  printMinMax(wap500_tmn_1,False)

;  print(pressAtLev)
;  printVarSummary(wap_500_full)
;[time | 780] x [plev | 19] x [lat | 192] x [lon | 288]
; plev = 100000, 92500, 85000, 70000, 60000, 50000, 40000, 30000, 25000,
;    20000, 15000, 10000, 7000, 5000, 3000, 2000, 1000, 500, 100 ;
  printVarSummary(wap500_tmn_1)

; grab the omega at only the 500 hPa surface

;; create land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat,lon)

if (EarthLike .eq. 0) then
  omega500_mask_1=wap500_tmn_1
  omega500_mask_2=wap500_tmn_2
  omega500_mask_3=wap500_tmn_3
else if (EarthLike .eq. 1) then
  ;;; apply land sea mask
  ;; -----first file-----
  omega500_mask_1=mask(wap500_tmn_1,lsm.ge.1,False)  ; apply mask 
  omega500_mask_2=mask(wap500_tmn_2,lsm.ge.1,False)  ; apply mask 
  omega500_mask_3=mask(wap500_tmn_3,lsm.ge.1,False)  ; apply mask 
end if 
end if

printVarSummary(wap500_tmn_1)

omega500_mask_1!0="latitude"
omega500_mask_1&latitude=wap_500_full&lat
omega500_mask_1!1="longitude"
omega500_mask_1&longitude=wap_500_full&lon
omega500_mask_1=nameDim(omega500_mask_1,"latitude","latitude","degrees_north")
omega500_mask_1=nameDim(omega500_mask_1,"longitude","longitude","degrees_east")

omega500_mask_2!0="latitude"
omega500_mask_2&latitude=wap_500_full&lat
omega500_mask_2!1="longitude"
omega500_mask_2&longitude=wap_500_full&lon
omega500_mask_2=nameDim(omega500_mask_2,"latitude","latitude","degrees_north")
omega500_mask_2=nameDim(omega500_mask_2,"longitude","longitude","degrees_east")

omega500_mask_3!0="latitude"
omega500_mask_3&latitude=wap_500_full&lat
omega500_mask_3!1="longitude"
omega500_mask_3&longitude=wap_500_full&lon
omega500_mask_3=nameDim(omega500_mask_3,"latitude","latitude","degrees_north")
omega500_mask_3=nameDim(omega500_mask_3,"longitude","longitude","degrees_east")

  printVarSummary(omega500_mask_1) 
  
;-----------------------------------------
; begin the figure
;-----------------------------------------

;my_levels_omega= (/-40,-35,-30,-25,-20,-15,-10,-5,-1,0,1,5,10,15,20,25,30,35,40/); 19 this was the original
;my_levels_omega= (/-17,-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15,17/); 19
my_levels_omega= (/-50,-40,-30,-20,-15,-10,-5,-3,-1,0,1,3,5,10,15,20,30,40,50/); 19
;
;res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","LineOnly", \
;                   "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
;my_colors_posneg = (/ 2, 4,6,8,10,11,13,15,17,19,1/)
;my_colors_posneg = (/ 67,74,81,88,95,102,109,116,123,129,130,139,146,153,160,167,174,181,188,195/); 20 
; below is the original color scheme
;my_colors_posneg = (/ 50,58,66,74,82,90,98,106,114,129,130,144,152,160,168,176,184,192,200,208/); 20 
my_colors_posneg = (/ 42,50,58,66,74,82,90,98,106,114,144,152,160,168,176,184,192,200,208,216/); 20 
;                     1,  2, 3, 4,5 , 6 , 7 , 8 , 9 ,10 , 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

  wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"BlueDarkRed18")
  gsn_define_colormap(wks,"NCV_blu_red")
  plot = new(3,graphic)

  res                   = True
  res@cnLinesOn         = False
if (EarthLike .eq. 0) then
  res@gsnDraw           = False
  res@gsnFrame          = False
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.133
else if (EarthLike .eq. 1) then
  ;res@lbOrientation     = "Vertical"
  ;res@gsnPaperOrientation = "portrait" 
  ;res@mpProjection      = "Robinson"       ; choose projection
  ;res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpCenterLonF      = 200.
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 10.               ; spacing for lat lines
  res@mpGridLonSpacingF = 10.               ; spacing for lon lines
  ;res@lbLabelAngleF     = 90
  res@mpFillOn          = False 
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@mpMinLatF            = -30      ; range to zoom in on
  res@mpMaxLatF            =  30.
  res@mpMinLonF            =  0.
  res@mpMaxLonF            = 360.
end if 
end if
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ; plotting only the zero contour line isn't working for some reason. 
  res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","LineOnly", \
                     "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
  res@gsnContourZeroLineThicknessF = 2.5
  res@cnLevelSelectionMode  = "ExplicitLevels"
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
  res@tiMainFontHeightF  = .023                               ; font height

  res@tiMainString      = "Decomposition of Vertical Pressure Velocity (hPa/day)"
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False

if (EarthLike .eq. 0) then
; for the RCE, MockWalker, and Aqua cases, don't plot the continents
    print("dimsizes of omega500_mask_1 are: "+dimsizes(omega500_mask_1))
  contour_1 = gsn_csm_contour(wks,omega500_mask_1(68:124,:),res)  ; create the plot
  res@tiMainString      = " "
  contour_2 = gsn_csm_contour(wks,omega500_mask_2(68:124,:),res)  ; create the plot
  contour_3 = gsn_csm_contour(wks,omega500_mask_3(68:124,:),res)  ; create the plot
else if (EarthLike .eq. 1) then
; for the amip and historical cases, plot the continents
  contour_1 = gsn_csm_contour_map(wks,omega500_mask_1,res)  ; create the plot
  res@tiMainString      = " "
  contour_2 = gsn_csm_contour_map(wks,omega500_mask_2,res)  ; create the plot
  contour_3 = gsn_csm_contour_map(wks,omega500_mask_3,res)  ; create the plot
end if 
end if

  plot(0) = contour_1
  plot(1) = contour_2
  plot(2) = contour_3

  resP                  = True                   ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
  ;resP@lbOrientation     = "vertical"
  resP@pmLabelBarWidthF  = 0.75             ; make thinner
  resP@lbLabelFontHeightF= 0.02             ; make thinner
  resP@lbLabelFontThicknessF = 2.5             ; make thinner
  resP@pmLabelBarHeightF = 0.15
    ;pres@pmLabelBarHeightF = 0.20
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/3,1/),resP)

;-----------------------------------------
end
;-----------------------------------------
