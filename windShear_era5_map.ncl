;***********************************************************************************
; windShear_era5_Map.ncl
;
; Plot vertical wind shear in the tropical atlantic and Caribbean using ERA5 data.
; A two panel figure is created.   The top panel shows anamolous shear and the 
; bottom panel shows the climatological values.  shear is computed as the difference
; between the 200hPa and 850hPa pressure surfaces.
;
; this script was used to make figures for a few presentations that Phil Klotzbach
; made and for some of the analysis in the November forecast verification document
;
; The anomalies can be computed relative to the climatology (1991-2020) or relative
; to 2020 values.
;
; for some reason, in order for the outline of land to work this needs to be run
; in the base environment like this: 
;
; (base) luft:ncl_git C823281551$ ncl windShear_era5_map.ncl
;
; levi silvers
;***********************************************************************************
;
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; load "/glade/work/levi/scripts/nclscripts/lib/trimPNG.ncl"
;***********************************************************************************
begin

datapath="~/data/ERA5/"
;f_now   ="era5_uv_augsepoct2024.nc"
f_now   ="era5_uv_augsepoct2025.nc"
f_climo ="era5_uv_augsepoct1991th2020.nc"
; u(date (monthly?  3 for 2024.nc), pressure_level (2), latitude (721), longitude (1440)

;fnino="era5mn_200_850_uv_nino.nc"
;fnina="era5mn_200_850_uv_nina.nc"
;u(time (48), level (3), latitude (721), longitude (1440))
; what are teh 48 timesteps?  8 years with 6 months in each year?  

infile_1=datapath+f_now
infile_2=datapath+f_climo
f1=addfile(infile_1,"r")
f2=addfile(infile_2,"r")

  print("incoming file 1 is: "+infile_1)
  print("incoming file 2 is: "+infile_2)

winda_u_fll  = f1->u(:,:,:,:)
winda_v_fll  = f1->v(:,:,:,:)
windb_u_fll  = f2->u(:,:,:,:)
windb_v_fll  = f2->v(:,:,:,:)
windc_u_fll  = f2->u(87:89,:,:,:)
windc_v_fll  = f2->v(87:89,:,:,:)

;  printVarSummary(windc_u_fll)

lev          = f1->pressure_level

  print("level 0 is: "+lev(0))
  print("level 1 is: "+lev(1))

;  printVarSummary(winda_u_fll)
;Dimensions and sizes:	[date | 3] x [pressure_level | 2] x [latitude | 721] x [longitude | 1440]

; compute the vertical shear: 
u_2024_diff = winda_u_fll(:,1,:,:) - winda_u_fll(:,0,:,:)
v_2024_diff = winda_v_fll(:,1,:,:) - winda_v_fll(:,0,:,:)

;;vws = sqrt(u_2024_diff^2+v_2024_diff^2)
;vws = sqrt(u_2024_diff^2)

; climatology
u_clim_diff = windb_u_fll(:,1,:,:) - windb_u_fll(:,0,:,:)
v_clim_diff = windb_v_fll(:,1,:,:) - windb_v_fll(:,0,:,:)

;;vws_cl = sqrt(u_clim_diff^2+v_clim_diff^2)
;vws_cl = sqrt(u_clim_diff^2)

; get the august, september, and october data from 2020: 
u_2020_diff = windc_u_fll(:,1,:,:) - windc_u_fll(:,0,:,:)
v_2020_diff = windc_v_fll(:,1,:,:) - windc_v_fll(:,0,:,:)


; choose whether to plot the total shear or the zonal shear: 
; total shear:
;vws = sqrt(u_2024_diff^2+v_2024_diff^2)
;vws_cl = sqrt(u_clim_diff^2+v_clim_diff^2)
;vws_20 = sqrt(u_2020_diff^2+v_2020_diff^2)
; zonal shear:
vws = sqrt(u_2024_diff^2)
vws_cl = sqrt(u_clim_diff^2)
vws_20 = sqrt(u_2020_diff^2)

  printVarSummary(vws)
  printVarSummary(vws_20)
  printVarSummary(vws_cl) ; vws_cl has more timesteps than vws_20 or vws

vws_24m20 = vws - vws_20

  printVarSummary(vws_24m20)

;  printVarSummary(windb_v_fll)

; average over time
u_2020_tmn = dim_avg_n_Wrap(u_2020_diff,0)
v_2020_tmn = dim_avg_n_Wrap(v_2020_diff,0)

u_2024_tmn = dim_avg_n_Wrap(u_2024_diff,0)
v_2024_tmn = dim_avg_n_Wrap(v_2024_diff,0)

vws_tmn    = dim_avg_n_Wrap(vws,0)
vws_20_tmn = dim_avg_n_Wrap(vws_20,0)
vws_24m20_tmn = dim_avg_n_Wrap(vws_24m20,0)
vws_cl_tmn = dim_avg_n_Wrap(vws_cl,0)

u_clim_tmn = dim_avg_n_Wrap(u_clim_diff,0)
v_clim_tmn = dim_avg_n_Wrap(v_clim_diff,0)

u_2024_tmn!0="latitude"
u_2024_tmn&latitude=winda_u_fll&latitude
u_2024_tmn!1="longitude"
u_2024_tmn&longitude=winda_u_fll&longitude

u_2020_tmn!0="latitude"
u_2020_tmn&latitude=winda_u_fll&latitude
u_2020_tmn!1="longitude"
u_2020_tmn&longitude=winda_u_fll&longitude

u_clim_tmn!0="latitude"
u_clim_tmn&latitude=winda_u_fll&latitude
u_clim_tmn!1="longitude"
u_clim_tmn&longitude=winda_u_fll&longitude

vws_tmn!0="latitude"
vws_tmn&latitude=winda_u_fll&latitude
vws_tmn!1="longitude"
vws_tmn&longitude=winda_u_fll&longitude

vws_cl_tmn!0="latitude"
vws_cl_tmn&latitude=winda_u_fll&latitude
vws_cl_tmn!1="longitude"
vws_cl_tmn&longitude=winda_u_fll&longitude

; vws_anom is the 2024 tmn minus the climatology.   
vws_anom    = vws_tmn - vws_cl_tmn
vws_20_anom = vws_20_tmn - vws_cl_tmn

vws_anom!0="latitude"
vws_anom&latitude=winda_u_fll&latitude
vws_anom!1="longitude"
vws_anom&longitude=winda_u_fll&longitude

vws_20_anom!0="latitude"
vws_20_anom&latitude=winda_u_fll&latitude
vws_20_anom!1="longitude"
vws_20_anom&longitude=winda_u_fll&longitude

vws_24m20_tmn!0="latitude"
vws_24m20_tmn&latitude=winda_u_fll&latitude
vws_24m20_tmn!1="longitude"
vws_24m20_tmn&longitude=winda_u_fll&longitude

;vws_cl!0="latitude"
;vws_cl&latitude=winda_u_fll&latitude
;vws_cl!1="longitude"
;vws_cl&longitude=winda_u_fll&longitude
;

printMinMax(u_2024_tmn,False)
;-----------------------------------------------------------------------------------------

;my_levels_pn= (/-20,-18,-16,-14,-12,   \
;                -10,-8,-6,-4,-2,       \
;                  0,2,4,6,8,           \
;                 10,12,14,16,18,       \
;                 20/); 21 
my_levels_pn= (/-10,-9,-8,-7,-6,   \
                -5,-4,-3,-2,-1,       \
                  0,1,2,3,4,           \
                 5,6,7,8,9,       \
                 10/); 21 
my_levels_pos= (/0,2,4,6,8,   \
                10,12,14,16,18,       \
                  20,22,24,26,28,           \
                 30,32,34,36,38,       \
                 40/); 21 
my_colors_posneg = (/ 20,30,40,50,60,   \ 
                      70,80,90,100,110,  \
                      120, \
                      130,136,146,156,166,   \
                      176,186,196,206,216,   \
                      226/); 22 



wtype = "png"

wtype@wkWidth  = 2500  ; increase size of pdf image
wtype@wkHeight = 2500

fout    =  "vws_Shear_grid_nolineslabels_test_zonal"

wks = gsn_open_wks(wtype,fout)          ; send graphics to PNG file

;  wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteBlue")
  ;gsn_define_colormap(wks,"WhiteYellowOrangeRed")

  gsn_define_colormap(wks,"BlueYellowRed")
  ;gsn_define_colormap(wks,"NCV_blu_red")
  plotA = new(2,graphic)

  res                   = True

  ;res@mpProjection      = "Mollweide"       ; choose projection
  res@mpProjection      = "CylindricalEqualArea"       ; choose projection
  res@mpGridAndLimbOn   = True            ; turn on lat/lon lines
  res@mpCenterLonF      = 200.
  res@mpPerimOn         = True ; turn off box around plot
  res@mpGridLatSpacingF = 20.               ; spacing for lat lines
  res@mpGridLonSpacingF = 20.               ; spacing for lon lines
  res@mpGeophysicalLineThicknessF = 3. 
  ;res@lbLabelAngleF     = 90
  res@mpFillOn          = False 
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@mpLimitMode          = "LatLon"
  ;res@mpMinLatF            = -60      ; range to zoom in on
  ;res@mpMaxLatF            =  60.
  ;res@mpMinLonF            =  0.
  ;res@mpMaxLonF            = 360.
  res@mpMinLatF            = 0      ; range to zoom in on
  res@mpMaxLatF            = 50.
  res@mpMinLonF            = -100.
  res@mpMaxLonF            = 0.
 
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

  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString      = "ERA5 Wind Shr (m/s) 2020 anom"
  res@tiMainString      = "ERA5 Wind Shr (m/s) 2025 anom"
  ;res@tiMainString      = "ERA5 Wind Shr (m/s) anom: 2024-2020"
  res@tiMainFontHeightF  = .016                               ; font height
  ;res@cnLevels          = my_levels_pos
  res@cnLevels          = my_levels_pn
  ;res@cnFillColors      = my_colors_shr
  res@cnFillColors      = my_colors_posneg
  ;res@cnFillOn          = True
  res@gsnTickMarksOn     = False

  ;contour_1 = gsn_csm_contour_map(wks,u_2024_tmn(:,:),res)  ; create the plot
  ;contour_1 = gsn_csm_contour_map(wks,vws_tmn(:,:),res)  ; create the plot
  ;contour_1 = gsn_csm_contour_map(wks,vws_20_anom(:,:),res)  ; create the plot

; vws_anom is what was used in the last years forecast verification 
; vws_anom is the vws anomaly from 2024 relative to the climatology
  contour_1 = gsn_csm_contour_map(wks,vws_anom(:,:),res)  ; create the plot

; vws_24m20 is the vws anomaly from 2024 relative to 2020. 
  ;contour_1 = gsn_csm_contour_map(wks,vws_24m20_tmn(:,:),res)  ; create the plot

  res@tiMainString      = "ERA5 Wind Shr (m/s) Climatology"
  res@cnLevels          = my_levels_pos
  res@cnLineLabelsOn    = True ; turn off contour lines
  contour_2 = gsn_csm_contour_map(wks,vws_cl_tmn(:,:),res)  ; create the plot

  plotA(0) = contour_1
  plotA(1) = contour_2
  
  resP                         = True              ; modify the panel plot
  resP@gsnPanelLabelBar        = True              ; add common colorbar
  resP@lbLabelFontHeightF      = 0.013
  resP@lbTitleFontHeightF      = 0.013
  gsn_panel(wks,plotA,(/2,1/),resP)


;-----------------------------------------
end
;-----------------------------------------
