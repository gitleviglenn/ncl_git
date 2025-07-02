;***********************************************************************************
; walker_wind_era5.ncl
;***********************************************************************************
;
; following some of the analysis from Wang, 2005, chapter 6. 
;
; desired plots: 
; vertical velocity at 500 mb
; divergent wind at 200 mb
; velocity potential at 200 mb
; vectory plot, vertical cross-section using vertical velocityand divergent wind
;     at several vertical levels. 
;
; vertical pressure levels (12) used by Wang: 
; 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 mb.
;
; to calculate the divergent wind components use: dv2uvg()
; to calculate the divergence use: uv2dvG_Wrap()
; see: https://www.ncl.ucar.edu/Applications/Scripts/wind_1.ncl
;
; to calculate the velocity potential and stream function given u and v on a global 
; grid use: uv2sfvpf()
;
; should probably regrid to 360x180 so the file size is more maneagable.
; something like this: 
; cdo -L remapbil,mygrid -sethalo,-1,-1 era5mon1940toPresent_div_U_V_time.nc era5mon1940toPresent_div_U_V_regrid.nc
;
;
;; ENSO years selected using RONI:
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
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin

; path to ERA5 data
datapath="/Users/C823281551/data/ERA5/"

; for starters we could use this file: 
;file1="/Users/C823281551/data/era5_uv_augsepoct202020212022.nc"

file1=datapath+"era5_u3D_1990th2024_360x180_jul.nc"
file2=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jan.nc"
file3=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jul.nc"
file4=datapath+"era5_v3D_1990th2024_360x180_jul.nc"

f1=addfile(file1,"r")
f2=addfile(file2,"r")
f3=addfile(file3,"r")
f4=addfile(file4,"r")

  print("incoming file is: "+file1)

wind_u  = f1->u(0:1,9,:,:)
wind_v  = f4->v(0:1,9,:,:)

wap_1   = f2->w(:,0,:,:)
wap_7   = f3->w(:,0,:,:)

p_lev   = f1->pressure_level(:)

  print("******************************************************")
  print("9nth pressure level is: "+p_lev(9))
  print("******************************************************")
  print("wap_7 before avg")
  printVarSummary(wap_7)
  print("******************************************************")

  print("******************************************************")
wap_1_tmn  = 100.*dim_avg_n_Wrap(wap_1,0)
wap_7_tmn  = 100.*dim_avg_n_Wrap(wap_7,0)
  print("wap_7_tmn before crap")

  print("******************************************************")
  printMinMax(wap_1,False)
  printMinMax(wap_7,False)
  print("******************************************************")

  printVarSummary(wind_u)
  print("dimsizes of wind_u is: "+dimsizes(wind_u))
  print("******************************************************")
;  printVarSummary(wap_1)

div = uv2dvG_Wrap(wind_u,wind_v)

ud  = new ( dimsizes(wind_u), typeof(wind_u), wind_u@_FillValue )
vd  = new ( dimsizes(wind_v), typeof(wind_v), wind_v@_FillValue )


uvmsg = 1e+36

;sf  = new ( (/nlat,mlon /), float, uvmsg )
sf     = new ( dimsizes(wind_u) , typeof(wind_u), uvmsg )
vpRaw  = new ( dimsizes(wind_u) , typeof(wind_u), uvmsg )
;vp  = new ( (/nlat,mlon /), float, uvmsg )

uv2sfvpf(wind_u,wind_v, sf,vpRaw)
dv2uvg(div,ud,vd)

vp_scale = 1e-6
vp = vp_scale*vpRaw

velp_tmn = dim_avg_n_Wrap(vp,0)

  printMinMax(vp,False)
  printVarSummary(vp)

copy_VarCoords(wind_u, ud ) 
copy_VarCoords(wind_u, vd ) 
ud@long_name  = "Zonal Divergent Wind"
ud@units      = wind_u@units
vd@long_name  = "Meridional Divergent Wind"
vd@units      = wind_v@units

;latitude@units = "degrees_north"
;latitude@long_name = "latitude"

wap_1&lat@units = "degrees_north"
wap_1&lon@units = "degrees_east"

wap_7_tmn!0="latitude"
wap_7_tmn&latitude=wap_1&lat
wap_7_tmn!1="longitude"
wap_7_tmn&longitude=wap_1&lon
wap_7_tmn&latitude@units="degrees_north"
wap_7_tmn&longitude@units="degrees_east"

wap_1_tmn!0="latitude"
wap_1_tmn&latitude=wap_1&lat
wap_1_tmn!1="longitude"
wap_1_tmn&longitude=wap_1&lon
wap_1_tmn&latitude@units="degrees_north"
wap_1_tmn&longitude@units="degrees_east"

velp_tmn!0="latitude"
velp_tmn&latitude=wap_1&lat
velp_tmn!1="longitude"
velp_tmn&longitude=wap_1&lon
velp_tmn&latitude@units="degrees_north"
velp_tmn&longitude@units="degrees_east"

  print("******************************************************")
  print("wap_7_tmn after crap")
  printVarSummary(wap_7_tmn)

;*************************************************
; plot results
;*************************************************    
;my_levels_omega= (/-50,-40,-30,-20,-15,    \
;                   -10,-5,-3,-1,0,         \
;                     1,3,5,10,15,          \
;                     20,30,40,50/);         19
my_levels_omega= (/-18,-16,-14,-12,-10,    \
                   -8,-6,-4,-2,0,         \
                     2,4,6,8,10,          \
                     12,14,16,18/);         19
;my_colors_posneg = (/ 42,50,58,66,74,      \
;                      82,90,98,106,114,    \
;                     144,152,160,168,176,  \
;                     184,192,200,208,216/); 20 
my_colors_posneg = (/ 42,50,58,66,74,      \
                      84,94,104,114,129,    \
                     129,139,149,154,159,  \
                     164,169,174,179,184/); 20 

wtype = "png"
wtype@wkWidth   = 2500
wtype@wkHeight  = 2500
wks = gsn_open_wks(wtype,"testplot")          ; send graphics to PNG file

;*************************************************    
; below is the segment that plots the vertical velocity
;*************************************************    
;  wks = gsn_open_wks(wtype,"testplot")          ; send graphics to PNG file
;  ;gsn_define_colormap(wks,"BlueDarkRed18")
;  gsn_define_colormap(wks,"NCV_blu_red")
;  plot = new(2,graphic)
;
;  res                   = True
;  res@cnLinesOn         = False
;
;  ;res@lbOrientation     = "Vertical"
;  ;res@gsnPaperOrientation = "portrait" 
;  ;res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
;  res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
;  res@mpCenterLonF      = 0.
;  ;res@mpCenterLonF      = 200.
;  res@mpPerimOn         = False             ; turn off box around plot
;  res@mpGridLatSpacingF = 20.               ; spacing for lat lines
;  res@mpGridLonSpacingF = 20.               ; spacing for lon lines
;  ;res@lbLabelAngleF     = 90
;  res@mpFillOn          = False 
;  res@gsnDraw           = False
;  res@gsnFrame          = False
; 
;  res@mpLimitMode          = "LatLon"
;  res@mpMinLatF            = -30      ; range to zoom in on
;  res@mpMaxLatF            =  30.
;  res@mpMinLonF            =  0.
;  res@mpMaxLonF            = 360.
;
;  res@gsnLeftString = ""
;  res@gsnRightString = ""
;
;  res@cnFillOn          = True              ; color plot desired
;  ;res@gsnMaximize       = True
;  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
;  ;res@cnLineLabelsOn    = False             ; turn off contour lines
;  ; plotting only the zero contour line isn't working for some reason. 
;  res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","LineOnly", \
;                     "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
;  res@gsnContourZeroLineThicknessF = 2.5
;  res@cnLevelSelectionMode  = "ExplicitLevels"
;  ;res@txFontHeightF     = 0.018 
;
;  res@vpKeepAspect    = False
;  ;res@vpXF            = 0.1                 ; make plot bigger
;  ;res@vpYF            = 0.9         
;  ;res@vpWidthF        = 0.8
;  ;res@vpHeightF       = 0.8
;  ;res@vpWidthF        = 0.4
;  ;res@vpHeightF       = 0.8
;
;  res@lbLabelFontHeightF  = 0.012           ; label bar font height
;  res@lbLabelBarOn       = True; turn off individual label bars
;
;  ;res@tiMainString       = maintitle  ; add a title
;  ;res@tiMainFontHeightF  = .023                               ; font height
;  res@tiMainFontHeightF  = .016                              ; font height
;
;  res@tiMainString      = "Vertical Velocity Jan (hPa/day)"
;  res@cnLevels          = my_levels_omega
;  res@cnFillColors      = my_colors_posneg
;  res@cnFillOn          = True
;
;
;  contour_1 = gsn_csm_contour_map(wks,wap_1_tmn(:,:),res)  ; create the plot
;  res@tiMainString      = "Vertical Velocity Jul (hPa/day)"
;  contour_2 = gsn_csm_contour_map(wks,wap_7_tmn(:,:),res)  ; create the plot
;  res@tiMainString      = "Velocity Potential Jul (hPa/day)"
;  res@mpMinLatF            = -90      ; range to zoom in on
;  res@mpMaxLatF            =  90.
;  contour_3 = gsn_csm_contour_map(wks,velp_tmn(:,:),res)  ; create the plot
;  plot(0) = contour_1
;  plot(1) = contour_2
; ; plot(2) = contour_3
;
;  resP                         = True              ; modify the panel plot
;  resP@gsnFrame                = False
;  res1P                         = True              ; modify the panel plot
;  res1P@gsnFrame                = False
;  gsn_panel(wks,plot,(/2,1/),resP)
;  frame(wks)
;;*************************************************    

;*************************************************    
; below is the segment that plots the velocity
; potential and divergent wind 
;*************************************************    
  ;gsn_define_colormap(wks,"BlueDarkRed18")
  gsn_define_colormap(wks,"NCV_blu_red")
  plot = new(1,graphic)

  res                   = True

  res@lbLabelFontHeightF  = 0.012           ; label bar font height
  res@lbLabelBarOn       = True; turn off individual label bars
  res@tiMainFontHeightF  = .016                              ; font height

  res@cnFillOn              = True              ; color plot desired
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False             ; turn off contour lines
  res@gsnScalarContour      = True               ; contours desired
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = my_levels_omega
  res@cnFillColors          = my_colors_posneg

  ;res@mpLandFillColor      = "black"            ; set land to be gray
  res@mpLandFillColor      = "gray"            ; set land to be gray
  res@mpMinLatF            = -40      ; range to zoom in on
  res@mpMaxLatF            =  40.
  res@mpCenterLonF         = 200.

  ;res@lbOrientation     = "Vertical"
  ;res@gsnPaperOrientation = "portrait" 
  ;res@mpProjection      = "Mollweide"       ; choose projection
  res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  ;res@mpCenterLonF      = 0.
  ;res@mpCenterLonF      = 200.
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 20.               ; spacing for lat lines
  res@mpGridLonSpacingF = 20.               ; spacing for lon lines
  ;res@lbLabelAngleF     = 90
  ;res@mpFillOn          = False   ; default is True.  False won't let continents fill
  res@gsnDraw           = False
  res@gsnFrame          = False
 
  ;res@mpLimitMode          = "LatLon"

  res@gsnLeftString = ""
  res@gsnRightString = ""

  ; plotting only the zero contour line isn't working for some reason. 
  ;res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","LineOnly", \
  ;                   "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
  ;res@gsnContourZeroLineThicknessF = 2.5
  ;res@cnLevelSelectionMode  = "ExplicitLevels"
  ;res@txFontHeightF     = 0.018 

  res@vpKeepAspect    = False

  res@tiMainString      = "Vertical Velocity Jan (hPa/day)"
  ;res@cnLevels          = my_levels_omega
  ;res@cnFillColors      = my_colors_posneg

  res@tiMainString      = "Velocity Potential Jul (hPa/day)"
  res@vcRefMagnitudeF = 4.                    ; make vectors larger
  res@vcRefLengthF    = 0.025                 ; reference vector length
  res@vcMinDistanceF  = 0.03                 ; thin the vectors

  res@vcGlyphStyle            = "CurlyVector"         ; turn on curly vectors
  res@vcLineArrowColor        = "black"           ; change vector color
  res@vcLineArrowThicknessF   = 8.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

;  plot   = gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),\
;                                    velp_tmn(:,:),res)
  plotvp = gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),velp_tmn(:,:),res)  ; create the plot
  ;plotvp = gsn_csm_vector_scalar_map(wks,ud(0,:,:),vd(0,:,:),velp_tmn(:,:),res)  ; create the plot
  plot(0) = plotvp 

;  resvc                 = True
;  resvc@vcRefMagnitudeF = 3.                    ; make vectors larger
;  resvc@vcRefLengthF    = 0.050                 ; reference vector length
;  resvc@vcGlyphStyle    = "CurlyVector"         ; turn on curly vectors
;  resvc@vcMinDistanceF  = 0.012                 ; thin the vectors

;  resvc@gsnLeftString   = "Divergent Wind"
                                              ; plot 1st time step
  ;plotvc = gsn_csm_vector_map(wks,ud(0,:,:),vd(0,:,:),resvc)
  ;plotvc = gsn_csm_vector(wks,ud(0,:,:),vd(0,:,:),resvc)

; overlay the vectors on the contours
  ;overlay(plotvp,plotvc)
  ;overlay(plotvc,plotvp)

  resP                         = True              ; modify the panel plot
  resP@gsnFrame                = False
  res1P                         = True              ; modify the panel plot
  res1P@gsnFrame                = False

  gsn_panel(wks,plot,(/1,1/),resP)
  frame(wks)
;*************************************************    

;  plotvp = gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),velp_tmn(:,:),res)  ; create the plot
;  plot(0) = plotvp 
;
;  resP                         = True              ; modify the panel plot
;  resP@gsnFrame                = False
;  res1P                         = True              ; modify the panel plot
;  res1P@gsnFrame                = False
;
;  gsn_panel(wks,plot,(/1,1/),resP)
;  frame(wks)

;*************************************************    
;  wks  = gsn_open_wks("png","wind")           ; send graphics to PNG file
;                                             
;  res                 = True
;  res@vcRefMagnitudeF = 3.                    ; make vectors larger
;  res@vcRefLengthF    = 0.050                 ; reference vector length
;  res@vcGlyphStyle    = "CurlyVector"         ; turn on curly vectors
;  res@vcMinDistanceF  = 0.012                 ; thin the vectors
;
;  res@gsnLeftString   = "Divergent Wind"
;                                              ; plot 1st time step
;  plot= gsn_csm_vector_map(wks,ud(0,:,:),vd(0,:,:),res)


end
