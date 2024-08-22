;***********************************************************************************
; pltWap500_enso.ncl
; 
; plot 2 panel figure showing composite omega500 fields of both 
; el nino and la nina
; 
; levi silvers                                       aug 2024
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin 

datapath="~/data/ERA5/"
;fnino="era5mn_200_850_uv_nino.nc"
;fnina="era5mn_200_850_uv_nina.nc"
fnino="era5_nino_2d.nc"
fnina="era5_nina_2d.nc"

enso = 0; 0 for el nino; 1 for la nina

;if (enso .eq. 0) then
;  print("El Nino phase selected")
  file1=fnino
  ensoPhase = "El Nino"
  ;infile1o=datapath+file1
;else if (enso .eq. 1) then
;  print("La Nina phase selected")
  file2=fnina
  ensoPhase = "La Nina"
  ;infile1=datapath+file1
;end if 
;end if

mtitle = ensoPhase+" vertical pressure velocity at 500hPa"
pltlev = 1; 0 corresponds to 200, 1 to 500, and 2 to 850 hPa

infile1=datapath+file1
infile2=datapath+file2
  print("incoming file is: "+infile1)

f1o=addfile(infile1,"r")
f1a=addfile(infile2,"r")

;scalef=864; converts Pa/s to hPa/day
scalef=1000; converts units if necessary
;scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

lat  = f1a->latitude
lon  = f1a->longitude
time = f1a->time

; time, level, latitude, longitude
; read in the total precipitation (tp), units of meters
winda_w_fll  = f1a->tp(:,:,:)
windo_w_fll  = f1o->tp(:,:,:)
winda_w_full = scalef*short2flt(winda_w_fll)
windo_w_full = scalef*short2flt(windo_w_fll)
;winda_v_fll  = f1a->v(:,:,:,:)
;winda_v_full = scalef*short2flt(winda_v_fll)
; calculate the shear

;nina_spd = sqrt(winda_w_full^2+winda_v_full^2)

aa=dimsizes(winda_w_full)

;nino_shr = new((/aa(2),aa(3)/),typeof(windo_v_full))

winda_u_tmn = dim_avg_n_Wrap(winda_w_full,0)
windo_u_tmn = dim_avg_n_Wrap(windo_w_full,0)

  print("********* summary of omega time averaged field *****")
  printVarSummary(winda_u_tmn)
  printMinMax(winda_u_tmn,False)
  print("****** end of summary of omega time averaged field *****")

;nina_spd_tmn = dim_avg_n_Wrap(nina_spd,0)

;windo_v_tmn = dim_avg_n_Wrap(windo_v_full,0)

; calculate the shear, as the diff of values on 200hPa from 850hPa: 

winda_u_tmn!0="latitude"
winda_u_tmn&latitude=winda_w_fll&latitude
winda_u_tmn!1="longitude"
winda_u_tmn&longitude=winda_w_fll&longitude

windo_u_tmn!0="latitude"
windo_u_tmn&latitude=winda_w_fll&latitude
windo_u_tmn!1="longitude"
windo_u_tmn&longitude=winda_w_fll&longitude

wind_diff = windo_u_tmn - winda_u_tmn

wind_diff!0="latitude"
wind_diff&latitude=winda_w_fll&latitude
wind_diff!1="longitude"
wind_diff&longitude=winda_w_fll&longitude

  print("****************************************************")
  print("****************************************************")

;; create land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat,lon)

;-----------------------------------------
; begin the figure
;-----------------------------------------

  res                   = True


my_levels_omega = (/0,1,2,3,4,5,   \
                   6,7,8,9,10,11,        \
                   12,13,14,15,16,17/); 18
my_levels_anom = (/-9,-8,-7,-6,-5,-4,   \
                   -3,-2,-1,1,2,3,        \
                    4,5,6,7,8,9/); 18
;my_colors_posneg = (/ 50,58,66,74,82,90,      \
;                      98,106,114,144,152,160, \
;                     168,176,184,192,200,208, \
;                     216/); 20 
my_colors_posneg = (/ 0,64,68,72,76,80,84, \
                     88,92,96,100,104,108, \
                     112,116,120,123,126,128/); 19 
my_colors_anom   = (/ 4,11,18,25,32,39,      \
                      46,53,60,0,68,75, \
                     82,89,96,103,110,117, \
                     124/); 19 

wks = gsn_open_wks("png","testPrec")               ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(3,graphic)

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

  res@mpMinLonF            =  0.
  res@mpMaxLonF            = 360.
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = True
  res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine","LineOnly","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine"/)
  res@cnFillMode        = "RasterFill"
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5
  ; plotting only the zero contour line isn't working for some reason. 
  ;res@gsnContourZeroLineThicknessF = 2.5
  ;res@txFontHeightF     = 0.018 

  res@vpKeepAspect    = False
  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .020                               ; font height

  res@tiMainString      = "Total Precipitation during ElNino"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False

  contour_1 = gsn_csm_contour_map(wks,windo_u_tmn(:,:),res)  ; create the plot
  res@tiMainString      = "Total Precipitation during LaNina"
  contour_2 = gsn_csm_contour_map(wks,winda_u_tmn(:,:),res)  ; create the plot
  res@tiMainString      = " "
  res@cnLevels          = my_levels_anom
  res@cnFillColors      = my_colors_anom
  contour_3 = gsn_csm_contour_map(wks,wind_diff(:,:),res)  ; create the plot

  plot(0) = contour_1
  plot(1) = contour_2
  plot(2) = contour_3

  resP                  = True            ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
;  ;resP@lbOrientation     = "vertical"
;  resP@pmLabelBarWidthF  = 0.75             ; make thinner
;  resP@lbLabelFontHeightF= 0.02             ; make thinner
;  resP@lbLabelFontThicknessF = 2.5             ; make thinner
;  resP@pmLabelBarHeightF = 0.15
;  resP@lbBoxLinesOn            = True
;  ;res@lbOrientation           = "Vertical"
;  resP@lbTitleString           = "wind (m/s)"
;  resP@lbTitlePosition         = "Bottom"
;  resP@lbLabelFontHeightF      = 0.013
;  resP@lbTitleFontHeightF      = 0.013
;
;    ;pres@pmLabelBarHeightF = 0.20
;  resP@gsnFrame         = False     ; don't advance panel plot
;
  gsn_panel(wks,plot,(/3,1/),resP)

;-----------------------------------------
end


