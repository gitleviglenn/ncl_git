;*************************************************
; tsurf_patt.ncl
;************************************************
;
;
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
basedir="/archive/Levi.Silvers/sstpatt"
dirin="/archive/Levi.Silvers/sstpatt/am4g9"
expname="/atmos_c96L32_am4g9_1860climo_"
;; define the filenames for the incoming experiments
;;inctl="/archive/Levi.Silvers/sstpatt/am4g9_work/atmos_c96L32_am4g9_1860climo_ctl_t_surf_0002-0006.nc"
;inctl=basedir+"/am4g5r11_cess_test/atmos_c96L32_am4g5r11_2000climo_t_surf_0007-0011.nc"
;;inwarm="/archive/Levi.Silvers/sstpatt/am4g9_work/atmos_c96L32_am4g9_1860climo_ctl_cess_t_surf_0002-0006.nc"
;inwarm=basedir+"/am4g5r11_cess_test/atmos_c96L32_am4g5r11_2000climo_p2K_t_surf_0007-0011.nc"
;;inreg="/archive/Levi.Silvers/sstpatt/am4g9_work/atmos_c96L32_am4g9_1860climo_ctlpreg_t_surf_0002-0006.nc"
;inreg=basedir+"/am4_1pc_test/atmos_AM4OM2F_c96l32_am4g5r11_2000climo_t_surf_0136-0140.nc"
;
in_cntl="/archive/Levi.Silvers/input/AM4OM2F_c96l32_am4g5r11_2000climo_atmos.012101-014012.t_surf_tmn.nc"
;incm4="/archive/Levi.Silvers/input/CM4_warmpatt_yr121t140_dby0.53.nc"
;inam4g6="/archive/Levi.Silvers/input/AM4_warmpatt_yr2t21_t_surf_tmn_dby0.42.nc"
incm4="/archive/Levi.Silvers/input/AM4_warmpatt_yr2t21_t_surf_tmn_dby0.42.nc"
;incm2_1="/archive/Levi.Silvers/input/AM4_warmpatt_yr2t21_t_ref_tmn_dby0.42.nc"
incm2_1="/archive/Levi.Silvers/input/CM2.1_warm_yr61t80_t_surf_tmn_dby0.77.nc"
;
maintitle="what are you doing?"
;print("infile is: "+inctl)
;  ctl_tsurf = addfile(inctl,"r")
;print("infile is: "+inwarm)
;  warm_tsurf  = addfile(inwarm,"r")
;print("infile is: "+inreg)
;  preg_tsurf         = addfile(inreg,"r")
;
  testcnt_t_surf = addfile(in_cntl,"r")
  testing_t_surf = addfile(incm4,"r")
  testing_t_surf2 = addfile(incm2_1,"r")
month=0
;  ctl_t_surf  = ctl_tsurf->t_surf(month,:,:) 
;  warm_t_surf  = warm_tsurf->t_surf(month,:,:) 
;  preg_t_surf  = preg_tsurf->t_surf(month,:,:) 

  t_surf_cntl = testcnt_t_surf->t_surf(month,:,:)
  t_surf_cm4 = testing_t_surf->t_surf(month,:,:)
  t_surf_cm2_1 = testing_t_surf2->t_surf(month,:,:)
  ;t_surf_cm2_1 = testing_t_surf2->t_ref(month,:,:)
;print("dimensions of ctl_t_surf: "+dimsizes(ctl_t_surf))
;************************************************
; read in zonal winds
;************************************************
;************************************************
; compute lat weights to determine the global mn
lat_cm4  = testing_t_surf->lat
lat_cm2_1  = testing_t_surf2->lat
rad  = 4.0*atan(1.0)/180.0
clat_cm4 = cos(lat_cm4*rad)
clat_cm2_1 = cos(lat_cm2_1*rad)
print("size of cm4: "+dimsizes(t_surf_cm4)+" and clat_cm4: "+dimsizes(clat_cm4))
print("size of cm2: "+dimsizes(t_surf_cm2_1)+" and clat_cm2_1: "+dimsizes(clat_cm2_1))
ctl_ave_weight_cm4    =wgt_areaave(t_surf_cm4,clat_cm4,1.0,1)
ctl_ave_weight_cm2_1  =wgt_areaave(t_surf_cm2_1,clat_cm2_1,1.0,1)
;warm_ave_weight     =wgt_areaave(warm_t_surf,clat,1.0,1)
;ctlpreg_4xco2_ave_weight     =wgt_areaave(t4,clat,1.0,1)
print("global mean tsfc of cm4 is: "+ctl_ave_weight_cm4)
print("global mean tsfc of cm2_1 is: "+ctl_ave_weight_cm2_1)
;print("global mean tsfc of ctl+reg is: "+ctlpreg_ave_weight)
;print("global mean tsfc of warm is: "+warm_ave_weight)
;************************************************
;; compute the diff between the ctlpreg and ctlp4k
;;tdiff=ctl_t_surf-preg_t_surf
;;tdiffhist=ctl_t_surf-warm_t_surf
;tdiffreg=preg_t_surf-ctl_t_surf
;tdiffhist=warm_t_surf-ctl_t_surf
;;tdiff4co2=in4co2_t_surf-ctl_t_surf
;;tdiff4co2=in4co2_t_surf-preg_t_surf
;tdiffhistmreg=warm_t_surf-preg_t_surf
;print("max of tdiffreg is: "+max(tdiffreg))
;print("min of tdiffreg is: "+min(tdiffreg))
;tdiffreg!0="lat"
;tdiffreg&lat=ctl_t_surf&lat
;tdiffreg!1="lon"
;tdiffreg&lon=ctl_t_surf&lon
;tdiffhist!0="lat"
;tdiffhist&lat=ctl_t_surf&lat
;tdiffhist!1="lon"
;tdiffhist&lon=ctl_t_surf&lon
;preg_t_surf!0="lat"
;preg_t_surf&lat=ctl_t_surf&lat
;preg_t_surf!1="lon"
;preg_t_surf&lon=ctl_t_surf&lon
;tdiffhistmreg!0="lat"
;tdiffhistmreg&lat=ctl_t_surf&lat
;tdiffhistmreg!1="lon"
;tdiffhistmreg&lon=ctl_t_surf&lon
;************************************************
; create plot
;************************************************
; create colors to use in contours
;; contour levels
;my_levels1 = (/268.,270.,272.,274.,276.,278.,280.,282.,284.,286.,288.,290.,292.,294.,296.,298.,300.,302.,304./)
;my_colors =  (/13 ,20 ,25 ,29 , 33, 37, 41,46 ,49 , 53, 59, 65, 69, 75, 79, 83, 87, 92, 96,101/)
; fewer contours
my_levels1 = (/268.,272.,276.,280.,284.,288.,292.,296.,300.,304.,308./)
my_colors =  (/13  ,20  ,25  ,29  ,59  , 65 , 69 , 75 , 83 , 87 , 92,101/)
;
;my_levels_diff = (/-2.25,-2,-1.75,-1.50,-1.25,-1,-.75,-.5,-.25,0 ,.25,.5,.75,1.,1.25,1.50,1.75,2 ,2.25/)
;my_colors_diff = (/   4 , 8,   10, 11,  13,16,   19,22,25,  28, 64,69, 74, 76,79, 84 , 89 , 91 ,96,101/)
; below is for plotting the cool colors below 1 instead of 0 
;my_levels_diff = (/-1.25,-1,-.75,-.5,-.25,0 ,.25,.5,.75,1.,1.25,1.50,1.75,2 ,2.25,2.5,2.75,3.0,3.25/)
;my_colors_diff = (/   4 , 8,   10, 11,  13,16,   19,22,25,  28, 64,69, 74, 76,79, 84 , 89 , 91 ,96,101/)
; fewer contours
my_levels_diff = (/-1.5,-1,-.5,0 ,.5 ,1.,1.50,2 ,2.5,3.0,3.5/)
my_colors_diff = (/ 4 ,  6, 9 ,12, 19,27,68  ,74,79 ,89 ,96 ,101/)
;************************************************
  wks = gsn_open_wks("pdf","testplot")          ; send graphics to PNG file
;  gsn_define_colormap(wks,"gui_default")
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  gsn_define_colormap(wks,"BlAqGrYeOrRe")
  plot = new(3,graphic)

  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@lbLabelAngleF          = 90
  res@mpFillOn          = False
  res@gsnDraw          = False
  res@gsnFrame         = False
  ;res@gsnMaximize       = True
 
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

  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "CM4 Control SST Pattern"; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  ;contour1 = gsn_csm_contour_map(wks,ctl_t_surf,res)  ; create the plot
  contour1 = gsn_csm_contour_map(wks,t_surf_cntl,res)  ; create the plot

  plot(0) = contour1
  res@gsnFrame         = False
  res@tiMainString       = "AM4 SST Pattern"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  ;contour2 = gsn_csm_contour_map(wks,tdiffreg,res)  ; create the plot
  contour2 = gsn_csm_contour_map(wks,t_surf_cm4,res)  ; create the plot
  plot(1) = contour2
  res@gsnFrame         = False
  ;res@tiMainString       = "20 last year patt"
  res@tiMainString       = "CM 2.1 Warming"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  ;contour3 = gsn_csm_contour_map(wks,tdiffhist,res)  ; create the plot
  contour3 = gsn_csm_contour_map(wks,t_surf_cm2_1,res)  ; create the plot
  plot(2) = contour3

  txres               = True
  txres@txFontHeightF = 0.03
  gsn_text_ndc(wks,"This is a title",0.5,0.95,txres)

  respanel = True

  gsn_panel(wks,plot,(/3,1/),respanel)

end

