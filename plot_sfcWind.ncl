;****************************************************************************************
; plot_sfcWind.ncl
;****************************************************************************************
; levi silvers                                                        dec 2021
;****************************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin

datapath="~/data/albatross/"

  print("does not exist ")

;infile1=datapath+"sfcWind_Amon_CESM1-CAM5-SE-HR_highres-future_r1i1p1f1_gn_201501-205012.nc"
;infile1=datapath+"sfcWind_Amon_MPI-ESM1-2-XR_hist-1950_r1i1p1f1_gn_198101-198112.nc"
infile1=datapath+"sfcWind_day_MPI-ESM1-2-XR_hist-1950_r1i1p1f1_gn_19810101-19811231.nc"
infile2=datapath+"sfcWind_day_MPI-ESM1-2-XR_highres-future_r1i1p1f1_gn_20500101-20501231.nc"

  print("incoming file is: "+infile1)

day_a = 30
day_b = 180
day_c = 350

f1=addfile(infile1,"r")
f2=addfile(infile2,"r")
wind10m_1 = f1->sfcWind
wind10m_2 = f2->sfcWind
wind10m_2a = f2->sfcWind(day_a,:,:)
wind10m_2b = f2->sfcWind(day_b,:,:)
wind10m_2c = f2->sfcWind(day_c,:,:)
  printVarSummary(wind10m_1)
  printMinMax(wind10m_1,1)
  printMinMax(wind10m_2,1)

convfac=3.6 ; converts m/s to km/hr

  print("********")
wind10m_1981 = dim_avg_n_Wrap(wind10m_1,0)
wind_1981    = convfac*wind10m_1981
  printVarSummary(wind10m_1981)
  print("********")
wind10m_2050 = dim_avg_n_Wrap(wind10m_2,0)
wind_2050    = convfac*wind10m_2050
wind_1day_2050a   = convfac*wind10m_2a
wind_1day_2050b   = convfac*wind10m_2b
wind_1day_2050c   = convfac*wind10m_2c

copy_VarCoords(wind10m_2a,wind_1day_2050a)
copy_VarCoords(wind10m_2b,wind_1day_2050b)
copy_VarCoords(wind10m_2c,wind_1day_2050c)

  printVarSummary(wind10m_2050)

wind_diff = wind_2050-wind_1981
; copy meta data to field for plotting
copy_VarCoords(wind10m_1981,wind_1981)
copy_VarCoords(wind10m_2050,wind_2050)
copy_VarCoords(wind10m_2050,wind_diff)

  printVarSummary(wind_1981)
  printVarSummary(wind_diff)
  print("********")
  print("scaling to km/hr")
  print("********")
  printMinMax(wind_diff,1)


;  my_levels1 = (/1,4,7,10,13,16,19,22,25,28/) ; 10
  my_levels1 = (/2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15/) ; 26
  my_levels_diff = (/-5,-4,-3,-2,-1,1,2,3,4,5/) ; 10
  ;my_colors = (/101,98,95,92,89,86,83,80,77,74,71,68,65,62,59,56,53,50,47,44,41,38,35,32,29,26,23,20/) ; 27
  my_colors = (/129,125,120,115,110,105,100,95,90,85,80,75,70,65,60,55,50,45,40,35,30,25,20,15,10,8,6,3/) ; 27
  my_colors_diff = (/49,65,81,97,113,129,145,161,177,193,209/) ; 11

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"MPL_YlGnBu")
  gsn_define_colormap(wks,"GMT_globe")
plot = new(6,graphic)

  res                      = True
  res_d                    = True
  ;res@mpProjection        = "Mollweide"       ; choose projection
  ;res@mpProjection        = "Robinson"       ; choose projection

  res@gsnPolar             = "SH"       ; choose projection
  res@mpMaxLatF            = -40
  res@mpGridAndLimbOn      = True              ; turn on lat/lon lines
  res@mpPerimOn            = False             ; turn off box around plot
  res@mpGridLatSpacingF    = 5.               ; spacing for lat lines
  res@mpGridLonSpacingF    = 20.               ; spacing for lon lines
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@mpFillOn             = False
  res_d@gsnPolar           = "SH"       ; choose projection
  res_d@mpMaxLatF          = -40
  res_d@mpGridAndLimbOn    = True              ; turn on lat/lon lines
  res_d@mpPerimOn          = False             ; turn off box around plot
  res_d@mpGridLatSpacingF  = 5.               ; spacing for lat lines
  res_d@mpGridLonSpacingF  = 20.               ; spacing for lon lines
  res_d@gsnDraw            = False
  res_d@gsnFrame           = False
  res_d@mpFillOn           = False

; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res_d@gsnLeftString = ""
  res_d@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@txFontHeightF     = 0.015
  res@cnLinesOn         = False
  res@lbLabelFontHeightF  = 0.015           ; label bar font height
  res@tiMainFontHeightF  = .018                               ; font height
  res_d@cnFillOn          = True              ; color plot desired
  res_d@cnLineLabelsOn    = False             ; turn off contour lines
  res_d@cnLevelSelectionMode  = "ExplicitLevels"
  res_d@txFontHeightF     = 0.015
  res_d@cnLinesOn         = False
  res_d@lbLabelFontHeightF  = 0.015           ; label bar font height
  res_d@tiMainFontHeightF  = .018                               ; font height
  
  res@cnLevels          = convfac*my_levels1
  res@cnFillColors      = my_colors

;  res@vpXF            = 0.1                 ; make plot bigger
;  res@vpYF            = 0.9
;  res@vpWidthF        = 0.8
;  res@vpHeightF       = 0.8


  res@tiMainString       = "average over 1981"; add a title
;contour = gsn_csm_contour_map(wks,wind_2050,res)  ; create the plot
  plot(0) = gsn_csm_contour_map(wks,wind_1981,res)  ; create the plot
  res@gsnFrame         = False
  res@tiMainString       = "average over 2050"; add a title
  plot(1) = gsn_csm_contour_map(wks,wind_2050,res)  ; create the plot
  res_d@gsnFrame         = False
  res_d@cnLevels          = my_levels_diff
  res_d@cnFillColors      = my_colors_diff
  res_d@tiMainString       = "diff 2050-1981"; add a title
  plot(2) = gsn_csm_contour_map(wks,wind_diff,res_d)  ; create the plot
  res@gsnFrame         = False
  res@cnLevels          = convfac*my_levels1
  res@cnLinesOn         = False
  res@cnFillColors      = my_colors
  res@tiMainString       = "Day 30 of 2050"; add a title
  plot(3) = gsn_csm_contour_map(wks,wind_1day_2050a,res)  ; create the plot
  res@gsnFrame         = False
  res@tiMainString       = "Day 180 of 2050"; add a title
  plot(4) = gsn_csm_contour_map(wks,wind_1day_2050b,res)  ; create the plot
  res@gsnFrame         = False
  res@tiMainString       = "Day 350 of 2050"; add a title
  plot(5) = gsn_csm_contour_map(wks,wind_1day_2050c,res)  ; create the plot

resP                          = True
resP@gsnPanelMainString = "10m wind, Max Planck Model, HighResMIP, 50km"
resP@gsnFrame                 = False

gsn_panel(wks,plot,(/2,3/),resP)

end 
