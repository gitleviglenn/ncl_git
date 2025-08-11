;---------------------------------------------------------------------------------
; somebody that i used to know
; 
; levi                                                                 august 2025
;---------------------------------------------------------------------------------

begin 

; path to ERA5 data
datapath="/Users/C823281551/data/ERA5/"

fileout = "wap_enso_Composite_diff_1990th2024"

; if using only july and january data
;file1=datapath+"era5_u3D_1990th2024_360x180_jul.nc"
;file2=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jan.nc"
;file3=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jul.nc"
;file4=datapath+"era5_v3D_1990th2024_360x180_jul.nc"

; if using the full data set 
file1=datapath+"era5_u3D_1990th2024_360x180.nc"
file2=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180.nc"
file3=datapath+"era5_omega_pv_vort_500hPa_1990th2024_360x180_jul.nc"
file4=datapath+"era5_v3D_1990th2024_360x180.nc"

f1=addfile(file1,"r")
f2=addfile(file2,"r")
f3=addfile(file3,"r")
f4=addfile(file4,"r")

;blahInd = (/5,15,25/)
blahInd = (/0,1,2,3,4,5,6,7,8,9,10,11/)
; Nino (6 months from each of 8 years identified as Nino)
ensoInd = (/18, 19, 20, 21, 22, 23, \
            54, 55, 56, 57, 58, 59, \
            90, 91, 92, 93, 94, 95, \
           150, 151, 152, 153, 154, 155, \
           174, 175, 176, 177, 178, 179, \
           234, 235, 236, 237, 238, 239, \
           306, 307, 308, 309, 310, 311, \
           402, 403, 404, 405, 406, 407 /)
ensoIndWang = (/24,25,26, \
                60,61,62, \
                96,97,98, \
                156,157,158, \
                180,181,182, \
                240,241,242, \
                312,313,314, \
                408,409,410 /)
;; Nina
ensoInd_nina = (/102, 103, 104, 105, 106, 107, \
                 114, 115, 116, 117, 118, 119, \
                 210, 211, 212, 213, 214, 215, \
                 246, 247, 248, 249, 250, 251, \
                 318, 319, 320, 321, 322, 323, \
                 366, 367, 368, 369, 370, 371, \
                 378, 379, 380, 381, 382, 383, \
                 390, 391, 392, 393, 394, 395 /)

  print("incoming file is: "+file1)

; (time, pressure, lat, lon)
wind_u  = f1->u(ensoInd,9,:,:)
wind_v  = f4->v(ensoInd,9,:,:)
wind_u2  = f1->u(ensoInd_nina,9,:,:)
wind_v2  = f4->v(ensoInd_nina,9,:,:)

;wind_u  = f1->u(0:1,9,:,:)
;wind_v  = f4->v(0:1,9,:,:)

;; if using only the july and january data: 
;wap_1   = f2->w(:,0,:,:)
;wap_7   = f3->w(:,0,:,:)

; if using the full data set: 
wap_1   = f2->w(ensoInd,0,:,:)
;wap_7   = f2->w(ensoInd,0,:,:)

;wap_1b    = f2->w(ensoInd_nina,0,:,:)
wap_nina  = f2->w(ensoInd_nina,0,:,:)

p_lev   = f1->pressure_level(:)

  print("******************************************************")
  print("9nth pressure level is: "+p_lev(9))
  print("******************************************************")
  ;print("wap_7 before avg")
  ;printVarSummary(wap_7)
  print("******************************************************")

  print("******************************************************")
wap_1_tmn  = 100.*dim_avg_n_Wrap(wap_1,0)
;wap_7_tmn  = 100.*dim_avg_n_Wrap(wap_7,0)
wap_1b_tmn = 100.*dim_avg_n_Wrap(wap_nina,0)
  ;print("wap_7_tmn before crap")

  print("******************************************************")
  printMinMax(wap_1,False)
  ;printMinMax(wap_7,False)
  print("******************************************************")

  printVarSummary(wind_u)
  print("dimsizes of wind_u is: "+dimsizes(wind_u))
  print("******************************************************")
;  printVarSummary(wap_1)

div  = uv2dvG_Wrap(wind_u,wind_v)
div2 = uv2dvG_Wrap(wind_u2,wind_v2)

ud   = new ( dimsizes(wind_u), typeof(wind_u), wind_u@_FillValue )
vd   = new ( dimsizes(wind_v), typeof(wind_v), wind_v@_FillValue )
ud2  = new ( dimsizes(wind_u), typeof(wind_u), wind_u@_FillValue )
vd2  = new ( dimsizes(wind_v), typeof(wind_v), wind_v@_FillValue )

uvmsg = 1e+36

;sf  = new ( (/nlat,mlon /), float, uvmsg )
sf     = new ( dimsizes(wind_u) , typeof(wind_u), uvmsg )
vpRaw   = new ( dimsizes(wind_u) , typeof(wind_u), uvmsg )
vpRaw2  = new ( dimsizes(wind_u) , typeof(wind_u), uvmsg )
;vp  = new ( (/nlat,mlon /), float, uvmsg )

; compute and scale the velocity potential:
uv2sfvpf(wind_u,wind_v, sf,vpRaw)
uv2sfvpf(wind_u2,wind_v2, sf,vpRaw2)

vp_scale = 1e-6
vp  = vp_scale*vpRaw
vp2 = vp_scale*vpRaw2

velp_tmn  = dim_avg_n_Wrap(vp,0)
velp2_tmn = dim_avg_n_Wrap(vp2,0)

  printMinMax(vp,False)
  printVarSummary(vp)

; compute the divergent velocity components
dv2uvg(div,ud,vd)
dv2uvg(div2,ud2,vd2)

copy_VarCoords(wind_u, ud ) 
copy_VarCoords(wind_u, vd ) 
copy_VarCoords(wind_u, ud2 ) 
copy_VarCoords(wind_u, vd2 ) 

; compute the time average of the divergent wind components
vd_tmn  = dim_avg_n_Wrap(vd,0)
ud_tmn  = dim_avg_n_Wrap(ud,0)
vd2_tmn = dim_avg_n_Wrap(vd2,0)
ud2_tmn = dim_avg_n_Wrap(ud2,0)

ud@long_name  = "Zonal Divergent Wind"
ud@units      = wind_u@units
vd@long_name  = "Meridional Divergent Wind"
vd@units      = wind_v@units

;latitude@units = "degrees_north"
;latitude@long_name = "latitude"

wap_1&lat@units = "degrees_north"
wap_1&lon@units = "degrees_east"

;wap_7_tmn!0="latitude"
;wap_7_tmn&latitude=wap_1&lat
;wap_7_tmn!1="longitude"
;wap_7_tmn&longitude=wap_1&lon
;wap_7_tmn&latitude@units="degrees_north"
;wap_7_tmn&longitude@units="degrees_east"

wap_1_tmn!0="latitude"
wap_1_tmn&latitude=wap_1&lat
wap_1_tmn!1="longitude"
wap_1_tmn&longitude=wap_1&lon
wap_1_tmn&latitude@units="degrees_north"
wap_1_tmn&longitude@units="degrees_east"

wap_1b_tmn!0="latitude"
wap_1b_tmn&latitude=wap_1&lat
wap_1b_tmn!1="longitude"
wap_1b_tmn&longitude=wap_1&lon
wap_1b_tmn&latitude@units="degrees_north"
wap_1b_tmn&longitude@units="degrees_east"

velp_tmn!0="latitude"
velp_tmn&latitude=wap_1&lat
velp_tmn!1="longitude"
velp_tmn&longitude=wap_1&lon
velp_tmn&latitude@units="degrees_north"
velp_tmn&longitude@units="degrees_east"

;*****************************************************************
; compute the composite difference between Nino and Nina events: 
ud_comp   = ud_tmn - ud2_tmn
vd_comp   = vd_tmn - vd2_tmn
velp_comp = velp_tmn - velp2_tmn
wap_comp  = wap_1_tmn - wap_1b_tmn
;copy_VarCoords(wind_u, ud_comp ) 
;copy_VarCoords(wind_v, vd_comp ) 
;copy_VarCoords(wind_u, velp_comp ) 
;copy_VarCoords(wap_1, wap_comp ) 

ud_comp!0="latitude"
ud_comp&latitude=wap_1&lat
ud_comp!1="longitude"
ud_comp&longitude=wap_1&lon
ud_comp&latitude@units="degrees_north"
ud_comp&longitude@units="degrees_east"

vd_comp!0="latitude"
vd_comp&latitude=wap_1&lat
vd_comp!1="longitude"
vd_comp&longitude=wap_1&lon
vd_comp&latitude@units="degrees_north"
vd_comp&longitude@units="degrees_east"

velp_comp!0="latitude"
velp_comp&latitude=wap_1&lat
velp_comp!1="longitude"
velp_comp&longitude=wap_1&lon
velp_comp&latitude@units="degrees_north"
velp_comp&longitude@units="degrees_east"

wap_comp!0="latitude"
wap_comp&latitude=wap_1&lat
wap_comp!1="longitude"
wap_comp&longitude=wap_1&lon
wap_comp&latitude@units="degrees_north"
wap_comp&longitude@units="degrees_east"

;*****************************************************************

;  print("******************************************************")
;  print("wap_7_tmn after crap")
;  printVarSummary(wap_7_tmn)

;*************************************************
; plot results
;*************************************************    
;my_levels_omega      = (/-50,-40,-30,-20,-15,    \
;                         -10,-5,-3,-1,0,         \
;                          1,3,5,10,15,          \
;                          20,30,40,50/);         19
my_levels_omega      = (/-17,-14,-11,-8,-5,    \
                         -4,-3,-2,-1,0,         \
                          1,2,3,4,5,          \
                          8,11,14,17/);         19
my_levels_omega_anom = (/-9,-8,-7,-6,-5,    \
                         -4,-3,-2,-1,0,         \
                           1,2,3,4,5,          \
                          6,7,8,9/);         19
my_levels_vp = (/-18,-16,-14,-12,-10,    \
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

wks = gsn_open_wks(wtype,fileout)          ; send graphics to PNG file

;;*************************************************    
;; below is the segment that plots the velocity
;; potential and divergent wind 
;;*************************************************    
;  ;gsn_define_colormap(wks,"BlueDarkRed18")
  gsn_define_colormap(wks,"NCV_blu_red")
  plot = new(3,graphic)

  res                   = True
;
  res@lbLabelFontHeightF  = 0.012           ; label bar font height
  res@lbLabelBarOn       = True; turn off individual label bars
  res@tiMainFontHeightF  = .016                              ; font height
;
  res@cnFillOn              = True              ; color plot desired
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False             ; turn off contour lines
  ;res@gsnScalarContour      = True               ; contours desired
  res@cnLevelSelectionMode  = "ExplicitLevels"
  ;res@cnLevels              = my_levels_vp
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
  res@cnLevels          = my_levels_omega
  ;res@cnFillColors      = my_colors_posneg

  ;res@tiMainString      = "Composite Velocity Potential (hPa/day) and Divergent Wind"
  ;res@vcRefMagnitudeF = 4.                    ; make vectors larger
  ;res@vcRefLengthF    = 0.025                 ; reference vector length
  ;res@vcMinDistanceF  = 0.03                 ; thin the vectors

  ;res@vcGlyphStyle            = "CurlyVector"         ; turn on curly vectors
  ;res@vcLineArrowColor        = "black"           ; change vector color
  ;res@vcLineArrowThicknessF   = 8.0               ; change vector thickness
  ;res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

;;  plot   = gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),\
;;                                    velp_tmn(:,:),res)
  ;plotvp = gsn_csm_vector_scalar_map_ce(wks,ud(0,:,:),vd(0,:,:),velp_tmn(:,:),res)  ; create the plot

  ;plotvp = gsn_csm_vector_scalar_map_ce(wks,ud_tmn(:,:),vd_tmn(:,:),velp_tmn(:,:),res)  ; create the plot

  ;plotvp = gsn_csm_vector_scalar_map(wks,ud(0,:,:),vd(0,:,:),velp_tmn(:,:),res)  ; create the plot
  res@tiMainString      = "Vertical Velocity during El Nino (hPa/day)"
  plot_wap = gsn_csm_contour_map(wks,wap_1_tmn(:,:),res)  ; create the plot
  plot(0) = plot_wap
  res@tiMainString      = "Vertical Velocity during La Nina (hPa/day)"
  plot_wap = gsn_csm_contour_map(wks,wap_1b_tmn(:,:),res)  ; create the plot
  plot(1) = plot_wap
  res@tiMainString      = "Composite Vertical Velocity: Nino-Nina (hPa/day)"
  plot_wap = gsn_csm_contour_map(wks,wap_comp(:,:),res)  ; create the plot

  plot(2) = plot_wap

  resP                         = True              ; modify the panel plot
  resP@gsnFrame                = False
  res1P                         = True              ; modify the panel plot
  res1P@gsnFrame                = False

  gsn_panel(wks,plot,(/3,1/),resP)
  frame(wks)

end



