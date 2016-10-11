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
basedir="/archive/Levi.Silvers/sstpatt/am4g10/"
;dirin="/archive/Levi.Silvers/sstpatt/am4g9"
;expname="/atmos_c96L32_am4g9_1860climo_"
; define the filenames for the incoming experiments
;infile1=basedir+"/am4g5r11_cess_test/atmos_c96L32_am4g5r11_2000climo_t_surf_0007-0011.nc"
;infile1=basedir+"/c96L32_am4g10r8_2000climo_atmos.000201-001112.t_surf_tmn.nc"
;infile1="/archive/Levi.Silvers/sstpatt/sst.climo.1981-2000.data_tmean_t_surf_remap.nc"
infile1=basedir+"/c96L32_am4g10r8_2000climo_tsurf_tmn.nc"
;infile2=basedir+"/am4g5r11_cess_test/atmos_c96L32_am4g5r11_2000climo_p2K_t_surf_0007-0011.nc"
;infile2=basedir+"c96L32_am4g10r8_2000climo_p2K_atmos.000201-001112.t_surf_tmn.nc"
infile2=basedir+"c96L32_am4g10r8_2000climo_p2K_tsurf_tmn.nc"
;infile3=basedir+"/am4_1pc_test/atmos_AM4OM2F_c96l32_am4g5r11_2000climo_t_surf_0136-0140.nc"
;infile3=basedir+"c96L32_am4g10r8_hadsstp1pctco2_climo_atmos.000201-001112.t_surf_tmn.nc"
infile3=basedir+"c96L32_am4g10r8_had_p_1pctco2_climo_tsurf_tmn.nc"
;infile4=basedir+"/am4_1pc_test/atmos_AM4OM2F_c96l32_am4g5r11_2000climo_1pct_t_surf_0136-0140.nc"
;infile4=basedir+"c96L32_am4g10r8_hadsstp1pctco2_AM4OM2ice_climo_atmos.000201-001112.t_surf_tmn.nc"
infile4=basedir+"c96L32_am4g10r8_had_p_4xCO2_climo_tsurf_tmn.nc"
;
maintitle="what are you doing?"
print("infile is: "+infile1)
  file1_tsurf     = addfile(infile1,"r")
print("infile is: "+infile2)
  file2_tsurf    = addfile(infile2,"r")
print("infile is: "+infile3)
  file3_tsurf    = addfile(infile3,"r")
print("infile is: "+infile4)
  file4_tsurf  = addfile(infile4,"r")
;
month=0
  ctl_t_surf  = file1_tsurf->t_surf(month,:,:) 
  file2_t_surf  = file2_tsurf->t_surf(month,:,:) 
  file3_t_surf  = file3_tsurf->t_surf(month,:,:) 
  file4_t_surf  = file4_tsurf->t_surf(month,:,:) 

;; 
;  ctl_t_surf  = file1_tsurf->t_surf(720:1679,:,:)   
print("dimensions of ctl_t_surf: "+dimsizes(ctl_t_surf))
;;
;************************************************
; read in zonal winds
;************************************************
;************************************************
; compute lat weights to determine the global mn
  lat  = file1_tsurf->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  ctl_ave_weight     =wgt_areaave(ctl_t_surf,clat,1.0,1)
  ctlpreg_ave_weight     =wgt_areaave(file3_t_surf,clat,1.0,1)
  warm_ave_weight     =wgt_areaave(file2_t_surf,clat,1.0,1)
  ;ctlpreg_4xco2_ave_weight     =wgt_areaave(t4,clat,1.0,1)
print("global mean tsfc of ctl is: "+ctl_ave_weight)
print("global mean tsfc of ctl+reg is: "+ctlpreg_ave_weight)
print("global mean tsfc of warm is: "+warm_ave_weight)
;************************************************
; compute the diff between the ctlpreg and ctlp4k
;tdiff=ctl_t_surf-file3_t_surf
  diff_f2mctl=file2_t_surf-ctl_t_surf
  f2mctl_weightmn     =wgt_areaave(diff_f2mctl,clat,1.0,1)
print("global mean tsfc of f2 m ctl is: "+f2mctl_weightmn)
  diff_f3mctl=file3_t_surf-ctl_t_surf
  f3mctl_weightmn     =wgt_areaave(diff_f3mctl,clat,1.0,1)
print("global mean tsfc of f3 m ctl is: "+f3mctl_weightmn)
  diff_f4mctl=file4_t_surf-ctl_t_surf
  f4mctl_weightmn     =wgt_areaave(diff_f4mctl,clat,1.0,1)
print("global mean tsfc of f4 m ctl is: "+f4mctl_weightmn)
  diff_f2mctl=diff_f2mctl/f2mctl_weightmn
  diff_f3mctl=diff_f3mctl/f3mctl_weightmn
  diff_f4mctl=diff_f4mctl/f4mctl_weightmn
;tdiff4co2=file4_t_surf-ctl_t_surf
;tdiff4co2=file4_t_surf-file3_t_surf
;tdiffhistmreg=file2_t_surf-file3_t_surf
print("max of diff_f3mctl is: "+max(diff_f3mctl))
print("min of diff_f3mctl is: "+min(diff_f3mctl))
diff_f3mctl!0="lat"
diff_f3mctl&lat=ctl_t_surf&lat
diff_f3mctl!1="lon"
diff_f3mctl&lon=ctl_t_surf&lon
print("max of diff_f4mctl is: "+max(diff_f4mctl))
print("min of diff_f4mctl is: "+min(diff_f4mctl))
diff_f4mctl!0="lat"
diff_f4mctl&lat=ctl_t_surf&lat
diff_f4mctl!1="lon"
diff_f4mctl&lon=ctl_t_surf&lon
diff_f2mctl!0="lat"
diff_f2mctl&lat=ctl_t_surf&lat
diff_f2mctl!1="lon"
diff_f2mctl&lon=ctl_t_surf&lon
file3_t_surf!0="lat"
file3_t_surf&lat=ctl_t_surf&lat
file3_t_surf!1="lon"
file3_t_surf&lon=ctl_t_surf&lon
;tdiffhistmreg&lat=ctl_t_surf&lat
;tdiffhistmreg!1="lon"
;tdiffhistmreg&lon=ctl_t_surf&lon
;************************************************
; create plot
;************************************************
; create colors to use in contours
;; contour levels
my_levels1 = (/265.,270.,275.,280.,284.,286.,288.,290.,292.,294.,296.,298.,300.,302.,304./)
my_colors =  (/20 , 28, 35, 41, 46, 53, 59, 65, 69, 75, 79, 83, 87, 92, 96,101/)
;;my_levels_diff = (/-5,-4,-3,-2,-1, 0, 1, 2, 3, 4, 5/)
;;my_colors_diff = (/20,28,35,41,46,53,59,65,69,75,79,83/)
;my_levels_diff = (/-6,-5,-4,-3,-2,-1,-0.5, 0, 0.5, 1, 2, 3, 4, 5,6/)
;my_colors_diff = (/28,41,44,47,53,59,65,69,73,77,81,85,89,93,97,101/)
my_levels_diff = (/-0.5, 0, 0.5, 1,1.5, 2,2.5, 3,3.5, 4/)
my_colors_diff = (/47,53,59,65,73,77,81,85,89,93,101/)
;;my_colors = (/101,97,95,91,85,79,75,69,65,59,53,46,41,35,28,25/)

;************************************************
  wks = gsn_open_wks("pdf","testplot")          ; send graphics to PNG file
;  gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  plot = new(4,graphic)

  res1                   = True
  res1@cnLinesOn            = False
  res1@mpProjection      = "Robinson"       ; choose projection
  res1@mpProjection      = "Orthographic"       ; choose projection
;  res1@mpProjection      = "Mollweide"       ; choose projection
  res1@mpCenterLonF      = 180.
  res1@mpCenterLatF      = -90.
  res1@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res1@mpPerimOn         = False             ; turn off box around plot
  res1@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res1@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res1@lbLabelAngleF          = 90
  res1@mpFillOn          = False
  res1@gsnDraw          = False
  res1@gsnFrame         = False
  res1@gsnMaximize       = True
 
; these commands turn off/on the varname and units at top of image
  res1@gsnLeftString = ""
  res1@gsnRightString = ""

  res1@cnFillOn          = True              ; color plot desired
;  res1@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res1@cnLineLabelsOn    = False             ; turn off contour lines
  res1@cnLevelSelectionMode  = "ExplicitLevels"
  res1@cnLevels          = my_levels1
  res1@cnFillColors      = my_colors
  res1@txFontHeightF     = 0.015 

  res1@vpXF            = 0.1                 ; make plot bigger
  res1@vpYF            = 0.9         
  res1@vpWidthF        = 0.8
  res1@vpHeightF       = 0.8

  res1@lbLabelFontHeightF  = 0.015           ; label bar font height

  res1@tiMainString       = "Hadley Center SST climo yr mean"; add a title
  res1@tiMainFontHeightF  = .018                               ; font height
  contour1 = gsn_csm_contour_map(wks,ctl_t_surf,res1)  ; create the plot
  plot(0) = contour1


; define resources for the other three plots...
  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
  res@mpProjection      = "Orthographic"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpCenterLatF      = -90.
  res@mpCenterLonF      = 180.
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@lbLabelAngleF          = 90
  res@mpFillOn          = False
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize       = True
  res@gsnFrame         = False
  res@gsnMaximize       = True
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  res@txFontHeightF     = 0.015 


  res@tiMainString       = "Had SST p2K anom" 
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  contour2 = gsn_csm_contour_map(wks,diff_f2mctl,res)  ; create the plot
  plot(1) = contour2

  res@gsnFrame         = False
  ;res@tiMainString       = "20 last year patt"
  res@tiMainString       = "1pct CO2 reg patt anom"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  contour3 = gsn_csm_contour_map(wks,diff_f3mctl,res)  ; create the plot
  plot(2) = contour3

  res@gsnFrame         = False
  ;res@tiMainString       = "warm - reg"
  res@tiMainString       = "4xCO2 reg patt anom"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  ;contour4 = gsn_csm_contour_map(wks,tdiff4co2,res)  ; create the plot
  contour4 = gsn_csm_contour_map(wks,diff_f4mctl,res)  ; create the plot
  plot(3) = contour4

  txres               = True
  txres@txFontHeightF = 0.03
  gsn_text_ndc(wks,"This is a title",0.5,0.95,txres)

  respanel = True

  gsn_panel(wks,plot,(/2,2/),respanel)

end

