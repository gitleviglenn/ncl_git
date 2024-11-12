;***********************************************************************************
; pltSST_enso.ncl
; 
; plot 3 panel figure showing composite SST fields of 
; el nino, la nina, and diff = nino-nina
; 
; levi silvers                                                            oct 2024
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin 

datapath="~/data/ERA5/"
;fnino="era5mn_200_850_uv_nino.nc"
;fnino="era5_nino_9194970204091523_be4fa3d4b8e5ddcc77aa8e52a7ed5bc3.nc"
fnino="era5_nino_mean2.nc"
;fnina="era5mn_200_850_uv_nina.nc"
;fnina="era5_nina_9899071016202122_64f6f94356ce02dbe75b82e9995d3bfd.nc"
fnina="era5_nina_mean2.nc"

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

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts units if necessary
;scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

lat  = f1a->latitude
lon  = f1a->longitude
;time = f1a->time
;lev  = f1a->level

;  print("lev at 0: "+lev(0))
;  print("lev at 2: "+lev(2))

; time, level, latitude, longitude
winda_w_fll  = f1a->sst(:,:)
windo_w_fll  = f1o->sst(:,:)
winda_w_full = scalef*short2flt(winda_w_fll)-273.15
windo_w_full = scalef*short2flt(windo_w_fll)-273.15
; calculate the shear

;winda_w_full@_FillValue = -999
;windo_w_full@_FillValue = -999

;winda_nan=isnan_ieee(winda_w_full)
;windo_nan=isnan_ieee(windo_w_full)

if (any(isnan_ieee(winda_w_full))) then
    value = 1.e20
    replace_ieeenan (winda_w_full, value, 0)
    winda_w_full@_FillValue = value 
end if
if (any(isnan_ieee(windo_w_full))) then
    value = 1.e20
    replace_ieeenan (windo_w_full, value, 0)
    windo_w_full@_FillValue = value 
end if

winda_w_full@_FillValue = 1.e20
windo_w_full@_FillValue = 1.e20

winda_nan=isnan_ieee(winda_w_full)

;print("~~~~~~~~~~~")
;print(winda_nan)
;print("~~~~~~~~~~~")
;print(windo_nan)
;print("~~~~~~~~~~~")

;nina_spd = sqrt(winda_w_full^2+winda_v_full^2)

aa=dimsizes(winda_w_full)

;nino_shr = new((/aa(2),aa(3)/),typeof(windo_v_full))

;sst_nina_tmn = dim_avg_n_Wrap(winda_w_full,0)
;sst_nino_tmn = dim_avg_n_Wrap(windo_w_full,0)
sst_nina_tmn = winda_w_full
sst_nino_tmn = windo_w_full

sst_diff = sst_nino_tmn - sst_nina_tmn

  print("********* summary of sst time averaged field *****")
  printVarSummary(sst_nina_tmn)
  printMinMax(sst_nina_tmn,False)
  print("****** end of summary of sst time averaged field *****")

;; create land sea mask
a=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata=a->LSMASK
lsm=landsea_mask(lsdata,lat,lon)
printVarSummary(lsm)

sst_nina_tmn_lsm=mask(sst_nina_tmn,lsm.ge.1,False)  ; apply mask to anomaly
sst_nino_tmn_lsm=mask(sst_nino_tmn,lsm.ge.1,False)  ; apply mask to anomaly
sst_diff_lsm=mask(sst_diff,lsm.ge.1,False)  ; apply mask to anomaly
;sw_cre_mask_f1=mask(sw_cre_f1,lsm.ge.1,False)  ; apply mask to anomaly
;lw_cre_mask_f1=mask(lw_cre_f1,lsm.ge.1,False)  ; apply mask to anomaly


sst_nina_tmn_lsm!0="latitude"
sst_nina_tmn_lsm&latitude=winda_w_fll&latitude
sst_nina_tmn_lsm!1="longitude"
sst_nina_tmn_lsm&longitude=winda_w_fll&longitude

sst_diff_lsm!0="latitude"
sst_diff_lsm&latitude=winda_w_fll&latitude
sst_diff_lsm!1="longitude"
sst_diff_lsm&longitude=winda_w_fll&longitude

sst_nino_tmn_lsm!0="latitude"
sst_nino_tmn_lsm&latitude=winda_w_fll&latitude
sst_nino_tmn_lsm!1="longitude"
sst_nino_tmn_lsm&longitude=winda_w_fll&longitude

  print("****************************************************")
  print("****************************************************")

;-----------------------------------------
; begin the figure
;-----------------------------------------

  res                   = True


;my_levels_omega = (/274.,276.,278.,280.,282.,284.,   \
;                   286.,288.,290.,292.,294.,296.,        \
;                    298.,300.,302.,304.,306.,308./); 18
my_levels_omega = (/0.,2.,4.,   \
                   6.,8.,10.,12.,14.,16.,        \
                    18.,20.,22.,24.,26.,28.,30,32,34/); 18
my_levels_pn    = (/-9.,-8.,-7.,-6.,-1.,-0.8,   \
                   -0.6,-0.4,-0.2,0.2,0.4,0.6,        \
                    0.8,1.,1.2,1.4,8.,9./); 18
;my_colors_posneg = (/ 124,117,110,103,96, \  ; MPL_BrBG  2 --> browns, 128 --> greens
;                      89,82,75,68,0,      \ 
;                      60,53,46,39,32,     \
;                      25,18,11,4/)
my_colors_sst    = (/ 0,136,142,148,156, \
                      162,168,174,180,186,      \ 
                      192,198,204,210,216,     \
                      222,228,234,240/)
my_colors_posneg = (/ 30,40,50,60,70, \
                      80,90,100,110,0,      \ 
                      130,140,150,160,170,     \
                      180,190,200,210/)

wks = gsn_open_wks("png","sstDiff")               ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  ;gsn_define_colormap(wks,"MPL_BrBG")
  gsn_define_colormap(wks,"cmocean_balance")  
  plot = new(3,graphic)

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
  res@cnLinesOn         = False 
  ;res@cnLinesOn         = True
  ;res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
  ;                          "NoLine","NoLine","NoLine","NoLine", \
  ;                          "LineOnly","LineOnly","NoLine","NoLine", \
  ;                          "NoLine","NoLine","NoLine","NoLine", \
  ;                          "NoLine","NoLine"/)
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

  res@tiMainString      = "SST El Nino"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_sst
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False

;print("CRAP DATA: "+sst_nina_tmn_lsm(25:60,45:47))
  contour_1 = gsn_csm_contour_map(wks,sst_nino_tmn_lsm(:,:),res)  ; create the plot
  res@tiMainString      = "SST La Nina"
;;  res@tiMainString      = "Vertical velocity at 500hPa LaNina"
  contour_2 = gsn_csm_contour_map(wks,sst_nina_tmn_lsm(:,:),res)  ; create the plot
;;  res@tiMainString      = " "
;;  res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
;;                            "NoLine","NoLine","NoLine","NoLine", \
;;                            "NoLine","NoLine","NoLine","NoLine", \
;;                            "NoLine","NoLine","NoLine","NoLine", \
;;                            "NoLine","NoLine"/)
  res@tiMainString      = "El Nino - La Nina"
  res@cnFillColors      = my_colors_posneg
  res@cnLevels          = my_levels_pn
  contour_3 = gsn_csm_contour_map(wks,sst_diff_lsm(:,:),res)  ; create the plot
;;
  plot(0) = contour_1
  plot(1) = contour_2
  plot(2) = contour_3
;;
  resP                  = True            ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
  resP@lbOrientation     = "vertical"
  ;resP@pmLabelBarWidthF  = 0.75             ; make thinner
  ;resP@lbLabelFontHeightF= 0.02             ; make thinner
  resP@pmLabelBarWidthF  = 0.1             ; make thinner
  resP@lbLabelFontHeightF= 0.02             ; make thinner
  resP@lbLabelFontThicknessF = 2.5             ; make thinner
  resP@pmLabelBarHeightF = 0.45
  resP@lbBoxLinesOn            = True
  ;res@lbOrientation           = "Vertical"
  resP@lbTitleString           = "SST (C)"
;  resP@lbTitlePosition         = "Bottom"
  resP@lbLabelFontHeightF      = 0.013
  resP@lbTitleFontHeightF      = 0.013
;
;    ;pres@pmLabelBarHeightF = 0.20
;  resP@gsnFrame         = False     ; don't advance panel plot
;
  gsn_panel(wks,plot,(/3,1/),resP)

;-----------------------------------------
end


