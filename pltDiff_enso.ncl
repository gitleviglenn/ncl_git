;***********************************************************************************
; pltDiff_enso.ncl
; 
; plot difference figure of composite fields of 
; el nino, la nina, and diff = nino-nina
; 
; levi silvers                                             oct 2024
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin 

datapath="~/data/ERA5/"
fnino="era5mn_200_850_uv_nino.nc"
fnina="era5mn_200_850_uv_nina.nc"

enso = 0; 0 for el nino; 1 for la nina

file1=fnino
ensoPhase = "El Nino"
file2=fnina
ensoPhase = "La Nina"

mtitle = ensoPhase+" vertical pressure velocity at 500hPa"
pltlev = 1; 0 corresponds to 200, 1 to 500, and 2 to 850 hPa

infile1=datapath+file1
infile2=datapath+file2
  print("incoming file is: "+infile1)

f1o=addfile(infile1,"r")
f1a=addfile(infile2,"r")

scalef=864; converts Pa/s to hPa/day
;scalef=1; converts units if necessary
;scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

lat  = f1a->latitude
lon  = f1a->longitude
time = f1a->time
lev  = f1a->level

  print("lev at 0: "+lev(0))
  print("lev at 2: "+lev(2))

; time, level, latitude, longitude
winda_w_fll  = f1a->w(:,:,:,:)
windo_w_fll  = f1o->w(:,:,:,:)
winda_w_full = scalef*short2flt(winda_w_fll)
windo_w_full = scalef*short2flt(windo_w_fll)
winda_v_fll  = f1a->v(:,:,:,:)
winda_v_full = scalef*short2flt(winda_v_fll)
; calculate the shear

nina_spd = sqrt(winda_w_full^2+winda_v_full^2)

aa=dimsizes(winda_w_full)

;nino_shr = new((/aa(2),aa(3)/),typeof(windo_v_full))

winda_u_tmn = dim_avg_n_Wrap(winda_w_full,0)
windo_u_tmn = dim_avg_n_Wrap(windo_w_full,0)

wap500_diff = windo_u_tmn - winda_u_tmn

  print("********* summary of omega time averaged field *****")
  printVarSummary(winda_u_tmn)
  printMinMax(winda_u_tmn,False)
  print("****** end of summary of omega time averaged field *****")

nina_spd_tmn = dim_avg_n_Wrap(nina_spd,0)

;windo_v_tmn = dim_avg_n_Wrap(windo_v_full,0)

; calculate the shear, as the diff of values on 200hPa from 850hPa: 

winda_u_tmn!0="level"
winda_u_tmn&level=winda_w_fll&level
winda_u_tmn!1="latitude"
winda_u_tmn&latitude=winda_w_fll&latitude
winda_u_tmn!2="longitude"
winda_u_tmn&longitude=winda_w_fll&longitude

wap500_diff!0="level"
wap500_diff&level=winda_w_fll&level
wap500_diff!1="latitude"
wap500_diff&latitude=winda_w_fll&latitude
wap500_diff!2="longitude"
wap500_diff&longitude=winda_w_fll&longitude

windo_u_tmn!0="level"
windo_u_tmn&level=winda_w_fll&level
windo_u_tmn!1="latitude"
windo_u_tmn&latitude=winda_w_fll&latitude
windo_u_tmn!2="longitude"
windo_u_tmn&longitude=winda_w_fll&longitude

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


my_levels_omega= (/-50,-40,-35,-30,-25,-20,   \
                   -15,-10,-5,5,10,15,        \
                    20,25,30,35,40,50/); 18
;my_colors_posneg = (/ 50,58,66,74,82,90,      \
;                      98,106,114,144,152,160, \
;                     168,176,184,192,200,208, \
;                     216/); 20 
;my_colors_posneg = (/ 4,11,18,25,32,39,      \
;                      46,53,60,0,68,75, \
;                     82,89,96,103,110,117, \
;                     124/); 19 
my_colors_posneg = (/ 124,117,110,103,96, \
                      89,82,75,68,0,      \ 
                      60,53,46,39,32,     \
                      25,18,11,4/)

wks = gsn_open_wks("png","omegaDiff")               ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(1,graphic)

  ;res@lbOrientation     = "Vertical"
  ;res@gsnPaperOrientation = "portrait" 
  ;res@mpProjection      = "Robinson"       ; choose projection
  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpLimitMode       = "LatLon"
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
  res@mpMinLatF            = -40.
  res@mpMaxLatF            = 40.
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = True
  res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
                            "NoLine","NoLine","NoLine","NoLine", \
                            "LineOnly","LineOnly","NoLine","NoLine", \
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
  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title

  res@tiMainFontHeightF  = .020                    ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False

  res@tiMainString      = " "
  res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine"/)
  contour = gsn_csm_contour_map(wks,wap500_diff(1,:,:),res)  ; create the plot

  plot(0) = contour

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
  resP@lbLabelFontHeightF      = 0.013
  resP@lbTitleFontHeightF      = 0.013
;
;    ;pres@pmLabelBarHeightF = 0.20
;  resP@gsnFrame         = False     ; don't advance panel plot
;
  gsn_panel(wks,plot,(/1,1/),resP)

;-----------------------------------------
end


