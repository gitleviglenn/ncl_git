;***********************************************************************************
; RH_era5_map.ncl
; 
; ENSO years selected using RONI: 
; 8 warmest seasons designated as El Nino and 8 coolest years as La Nina.
; using this method, the thresholds for the NH are El Nino (0.52C) and La Nina (-0.78C)
; and for the SH they are El Nino (0.55 C) and for La Nina (-0.81C)
;
; The two levels read for RH average should be 850hPa and 700hPa.
; 
; NH:       Calculate for June through November 
; Nino:     1991, 1994, 1997, 2002, 2004, 2009, 2015, 2023
; Neutral:  1990, 1992, 1993, 1995, 1996, 2000, 2001, 2003, 2005, 2006, 2008,
;           2011, 2012, 2013, 2014, 2017, 2018, 2019
; Nina:     1998, 1999, 2007, 2010, 2016, 2020, 2021, 2022
; 
; SH:       Calculate for November through April
; Nino:     1992, 1993, 1995, 1998, 2003, 2010, 2016, 2019
; Neutral:  1990, 1991, 1994, 1996, 1997, 2001, 2002, 2004, 2005, 2007, 2009,
;           2012, 2013, 2014, 2015, 2017, 2020, 2023
; Nina:     1999, 2000, 2008, 2011, 2012, 2018, 2021, 2022
;
; levi silvers                                                     nov 2024
;***********************************************************************************
;
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; load "/glade/work/levi/scripts/nclscripts/lib/trimPNG.ncl"

begin 

datapath="~/data/ERA5/"
f_nino  ="era5_hur_NH_nino.nc"
f_nina  ="era5_hur_NH_nina.nc"

infile_1=datapath+f_nino
infile_2=datapath+f_nina
f1=addfile(infile_1,"r")
f2=addfile(infile_2,"r")

  print("incoming file 1 is: "+infile_1)
  print("incoming file 2 is: "+infile_2)

huro_fll  = f1->r(:,:,:,:)
hura_fll  = f2->r(:,:,:,:)

lev          = f1->pressure_level

  print("level 0 is: "+lev(0))
  print("level 1 is: "+lev(1))

; average the two layers
hur_avg_nino = 0.5*(huro_fll(:,1,:,:) + huro_fll(:,0,:,:))
hur_avg_nina = 0.5*(hura_fll(:,1,:,:) + hura_fll(:,0,:,:))
;u_clim_diff = windb_u_fll(:,1,:,:) - windb_u_fll(:,0,:,:)

; average over time
huro_tmn = dim_avg_n_Wrap(hur_avg_nino,0)
hura_tmn = dim_avg_n_Wrap(hur_avg_nina,0)

; calculate the difference between El Nino and La Nina: 
hur_diff = huro_tmn - hura_tmn

  printVarSummary(huro_tmn)

;u_2024_tmn = dim_avg_n_Wrap(u_2024_diff,0)

huro_tmn!0="latitude"
huro_tmn&latitude=huro_fll&latitude
huro_tmn!1="longitude"
huro_tmn&longitude=huro_fll&longitude

hura_tmn!0="latitude"
hura_tmn&latitude=huro_fll&latitude
hura_tmn!1="longitude"
hura_tmn&longitude=huro_fll&longitude

hur_diff!0="latitude"
hur_diff&latitude=huro_fll&latitude
hur_diff!1="longitude"
hur_diff&longitude=huro_fll&longitude

  printMinMax(hur_diff,False)

;----------------------------------------------------------------------------------------------
; begin figure
; 6
my_levels_mn= (/ 30,33,36,39,42, \
                 45,48,51,54,57, \
                 60,63,66,69,72, \
                 75,78,81,84,87, \ 
                 90/); 21
my_levels_pn= (/ -10,-9,-8,-7,-6, \
                 -5,-4,-3,-2,-1, \
                 0,1,2,3,4, \ 
                 5,6,7,8,9, \
                 10/); ,82,84,86,88, \
                 ;90/); 31
;my_colors_posneg = (/ 20,25,30,35,40,     \
;                      45,50,55,60,65,     \ 
my_colors_posneg = (/ 70,75,80,85,90,     \
                      95,100,105,110,115, \
                      120,125,130,135,140,\
                      145,150,155,160,165,\
                      170,175/); 32 
my_colors_anom     = (/ 12,14,16,18,20,     \
                      22,24,26,28,30, \
                      0,0, \
                      34,36,38,40,42,\
                      44,46,48,50,52 /);,\
                      ;170,175/); 32 
my_colors_anom     = (/ 26,34,42,50,58,     \
                      66,74,82,90,98, \
                      126,127, \
                      146,154,162,170,178,\
                      186,194,202,210,218 /);,\


wtype = "png"

wtype@wkWidth  = 2500  ; increase size of pdf image
wtype@wkHeight = 2500

fout    =  "hur_diff_NinoMinNina"

wks = gsn_open_wks(wtype,fout)          ; send graphics to PNG file

;  wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteBlue")
  ;gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  ;gsn_define_colormap(wks,"BlueYellowRed")
  gsn_define_colormap(wks,"MPL_BrBG")
  ;gsn_define_colormap(wks,"NCV_blu_red")
  plotA = new(2,graphic)
  ;plotB = new(1,graphic)

  res                   = True

  res@mpProjection      = "Mollweide"       ; choose projection
  ;res@mpProjection      = "CylindricalEqualArea"       ; choose projection
  ;res@mpProjection      = "Robinson"       ; choose projection
  res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpGridLineThicknessF = 2.
  res@mpCenterLonF      = 0.
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpGeophysicalLineThicknessF = 3. 
  ;res@lbLabelAngleF     = 90
  res@mpFillOn          = False 
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@mpLimitMode          = "LatLon"
  res@mpMinLatF            = -40      ; range to zoom in on
  res@mpMaxLatF            =  40.
  res@mpMinLonF            =  0.
  res@mpMaxLonF            = 360.
  ;res@mpMinLatF            = 0      ; range to zoom in on
  ;res@mpMaxLatF            = 50.
  ;res@mpMinLonF            = -100.
  ;res@mpMaxLonF            = 0.
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False             ; turn off contour lines
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ; plotting only the zero contour line isn't working for some reason. 
  ;res@gsnContourZeroLineThicknessF = 2.5
  ;res@txFontHeightF     = 0.018 

  res@vpKeepAspect    = False

  ;res@lbLabelBarOn          = False  ; turn off individual label bars

  res@tiMainString          = "ERA5 hur (%) Nino"
;  res@tiMainFontHeightF     = .016                               ; font height
  res@cnLevels              = my_levels_mn
  ;res@cnFillColors          = my_colors_shr
  res@cnFillColors          = my_colors_posneg
  res@lbLabelBarOn          = True
  ;res@cnFillOn              = True
  res@gsnTickMarksOn        = False

  ;contour_1 = gsn_csm_contour_map(wks,u_2024_tmn(:,:),res)  ; create the plot
  ;contour_1 = gsn_csm_contour_map(wks,vws_tmn(:,:),res)  ; create the plot
  contour_1 = gsn_csm_contour_map(wks,huro_tmn(:,:),res)  ; create the plot

; second panel
 
  res1                      = True
  res1@cnLevelSelectionMode = "ExplicitLevels"
  ;res1@cnFillPalette        = "BlueWhiteOrangeRed"
  res1@cnFillPalette        = "NEO_div_vegetation_c"
  res1@cnFillColors          = my_colors_anom
  res1@mpProjection      = "Mollweide"       ; choose projection
  ;res1@mpProjection      = "CylindricalEqualArea"       ; choose projection
  ;res1@mpProjection      = "Robinson"       ; choose projection
  res1@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res1@mpGridLineThicknessF = 4.
  res1@mpCenterLonF      = 0.
  res1@mpPerimOn         = False             ; turn off box around plot
  res1@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res1@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res1@mpGeophysicalLineThicknessF = 3. 
  ;res@lbLabelAngleF     = 90
  res1@mpFillOn          = False 
  res1@gsnDraw           = False
  res1@gsnFrame          = False

  res1@mpLimitMode          = "LatLon"
  res1@mpMinLatF            = -40      ; range to zoom in on
  res1@mpMaxLatF            =  40.
  res1@mpMinLonF            =  0.
  res1@mpMaxLonF            = 360.

  res1@cnFillOn          = True              ; color plot desired
  res1@cnMonoLevelFlag   = False
  res1@cnLinesOn         = False
  res1@cnLineLabelsOn    = False             ; turn off contour lines
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res1@cnLevelSelectionMode  = "ExplicitLevels"
  res1@cnLineThicknessF  = 2.5
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
 
; these commands turn off/on the varname and units at top of image
  res1@gsnLeftString = ""
  res1@gsnRightString = ""
  res1@tiMainString          = "ERA5 hur (%) Nino - Nina"
  ;res@cnLevels              = my_levels_pos
  res1@cnLevels              = my_levels_pn
  res1@lbLabelBarOn          = True
  ;res1@cnLineLabelsOn        = True ; turn off contour lines
  contour_2 = gsn_csm_contour_map(wks,hur_diff(:,:),res1)  ; create the plot
  ;contour_2 = gsn_csm_contour_map(wks,hura_tmn(:,:),res1)  ; create the plot

  plotA(0) = contour_1
  plotA(1) = contour_2
  
  resP                         = True              ; modify the panel plot
  resP@gsnFrame                = False
  ;resP@gsnPanelLabelBar        = True              ; add common colorbar
  ;resP@lbLabelFontHeightF      = 0.013
  ;resP@lbTitleFontHeightF      = 0.013

  ;gsn_panel(wks,plotA,(/1,1/),resP)

  res1P                         = True              ; modify the panel plot
  res1P@gsnFrame                = False
  ;res1P@gsnPanelLabelBar        = True              ; add common colorbar
  ;res1P@lbLabelFontHeightF      = 0.013
  ;res1P@lbTitleFontHeightF      = 0.013

  gsn_panel(wks,plotA,(/2,1/),resP)

  frame(wks)


end 

