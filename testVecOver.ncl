; testing vector overlays on a map: 

begin 

; path to ERA5 data
datapath="/Users/C823281551/data/ERA5/"

; for starters we could use this file: 
;file1="/Users/C823281551/data/era5_uv_augsepoct202020212022.nc"

;file1=datapath+"era5_u3D_1990th2024_360x180_jul.nc"
file1=datapath+"era5_u3D_1990th2024_360x180_jan.nc"

;file2=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jan.nc"
;file3=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jul.nc"

;file4=datapath+"era5_v3D_1990th2024_360x180_jul.nc"
file4=datapath+"era5_v3D_1990th2024_360x180_jan.nc"

f1=addfile(file1,"r")
;f2=addfile(file2,"r")
;f3=addfile(file3,"r")
f4=addfile(file4,"r")

  print("incoming file is: "+file1)

wind_u  = f1->u(0:1,9,:,:)
wind_v  = f4->v(0:1,9,:,:)

;wap_1   = f2->w(:,0,:,:)
;wap_7   = f3->w(:,0,:,:)

p_lev   = f1->pressure_level(:)

  print("******************************************************")
  print("9nth pressure level is: "+p_lev(9))
  print("******************************************************")
  ;print("wap_7 before avg")
  ;printVarSummary(wap_7)
  print("******************************************************")

  print("******************************************************")
;wap_1_tmn  = 100.*dim_avg_n_Wrap(wap_1,0)
;wap_7_tmn  = 100.*dim_avg_n_Wrap(wap_7,0)
;  print("wap_7_tmn before crap")

  print("******************************************************")
;  printMinMax(wap_1,False)
;  printMinMax(wap_7,False)
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

;wap_1&lat@units = "degrees_north"
;wap_1&lon@units = "degrees_east"

;wap_7_tmn!0="latitude"
;wap_7_tmn&latitude=wap_1&lat
;wap_7_tmn!1="longitude"
;wap_7_tmn&longitude=wap_1&lon
;wap_7_tmn&latitude@units="degrees_north"
;wap_7_tmn&longitude@units="degrees_east"

;wap_1_tmn!0="latitude"
;wap_1_tmn&latitude=wap_1&lat
;wap_1_tmn!1="longitude"
;wap_1_tmn&longitude=wap_1&lon
;wap_1_tmn&latitude@units="degrees_north"
;wap_1_tmn&longitude@units="degrees_east"

velp_tmn!0="latitude"
velp_tmn&latitude=wind_u&lat
velp_tmn!1="longitude"
velp_tmn&longitude=wind_u&lon
velp_tmn&latitude@units="degrees_north"
velp_tmn&longitude@units="degrees_east"

my_levels_omega= (/-18,-16,-14,-12,-10,    \
                   -8,-6,-4,-2,0,         \
                     2,4,6,8,10,          \
                     12,14,16,18/);         19
;my_levels_omega= (/-50,-40,-30,-20,-15,    \
;                   -10,-5,-3,-1,0,         \
;                     1,3,5,10,15,          \
;                    20,30,40,50/);         19
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
;---Create plot
  wks = gsn_open_wks(wtype,"vector")            ; send graphics to PNG file
  ;cmap = read_colormap_file("BlAqGrYeOrReVi200")  
  gsn_define_colormap(wks,"NCV_blu_red")

  res                      = True               ; plot mods desired

  res@lbLabelFontHeightF  = 0.012           ; label bar font height
  res@lbLabelBarOn       = True; turn off individual label bars
  res@tiMainFontHeightF  = .016                              ; font height
  
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@gsnScalarContour     = True               ; contours desired
  ;res@cnFillPalette        = cmap(17:,:)        ; subset the color map
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg

  ;res@mpLandFillColor      = "black"            ; set land to be gray
  ;res@mpLandFillColor      = "gray"            ; set land to be gray
  ;res@mpMinLonF            =  -180.               ; select a subregion
  ;res@mpMaxLonF            =  180.
  res@mpMinLatF            =   -40. 
  res@mpMaxLatF            =  40.
  res@mpCenterLonF         = 200.

;  res@lbOrientation            = "Vertical"     ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  ;res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  ;res@cnMinLevelValF       = -20.0               ; set min contour level
  ;res@cnMaxLevelValF       = 20.                 ; set max contour level
  ;res@cnLevelSpacingF      = 0.10               ; set contour spacing

  res@vcRefMagnitudeF           = 3.0             ; define vector ref mag
  ;res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefLengthF              = 0.025           ; define length of vec ref
  res@vcMinDistanceF            = 0.03
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
  res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
  res@vcRefAnnoArrowUseVecColor = False           ; don't use vec color for ref

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curly vectors
  ;res@vcLineArrowColor        = "white"           ; change vector color
  res@vcLineArrowColor        = "black"           ; change vector color
  res@vcLineArrowThicknessF   = 8.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

;  plot=gsn_csm_vector_scalar_map_ce(wks,u(ind_uv,:,:),v(ind_uv,:,:),\
;                                    sst(ind_sst,:,:),res)
  plot=gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),\
                                    velp_tmn(:,:),res)

end
