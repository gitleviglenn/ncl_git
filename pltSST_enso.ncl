;***********************************************************************************
; pltSST_enso.ncl
; 
; plot 3 panel figure showing composite SST fields of both 
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

fnino="era5_nino_2d.nc"
fnina="era5_nina_2d.nc"

ftmn = "era5_sst_1990th2024_tmn.nc"

  file1=fnino
  ensoPhase = "El Nino"
  ;infile1o=datapath+file1
  file2=fnina
  ensoPhase = "La Nina"
  file3=ftmn
  
mtitle = ensoPhase+" vertical pressure velocity at 500hPa"

infile1=datapath+file1
infile2=datapath+file2
infile3=datapath+file3

  print("incoming file1 is: "+infile1)
  print("incoming file2 is: "+infile2)
  print("incoming file3 is: "+infile3)

f1o=addfile(infile1,"r")
f1a=addfile(infile2,"r")
f3 =addfile(infile3,"r")

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts units if necessary
;scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

lat  = f1a->latitude
lon  = f1a->longitude
time = f1a->time

expn = f3->expver
  print("expn vales: "+expn)

; time, level, latitude, longitude
winda_w_fll  = f1a->sst(:,:,:)
windo_w_fll  = f1o->sst(:,:,:)
sst_tmn      = f3->sst(0,:,:)
winda_w_full = scalef*short2flt(winda_w_fll)
windo_w_full = scalef*short2flt(windo_w_fll)
;sst_tmn_full = scalef*short2flt(sst_tmn)

ssta_tmn = dim_avg_n_Wrap(winda_w_full,0)
ssto_tmn = dim_avg_n_Wrap(windo_w_full,0)

ssta_tmn!0="latitude"
ssta_tmn&latitude=winda_w_fll&latitude
ssta_tmn!1="longitude"
ssta_tmn&longitude=winda_w_fll&longitude

ssto_tmn!0="latitude"
ssto_tmn&latitude=winda_w_fll&latitude
ssto_tmn!1="longitude"
ssto_tmn&longitude=winda_w_fll&longitude

  printVarSummary(ssta_tmn)
  printVarSummary(sst_tmn)

ssta_anom = ssta_tmn - sst_tmn
ssto_anom = ssto_tmn - sst_tmn

sst_anom_diff = ssto_anom - ssta_anom

ssta_anom!0="latitude"
ssta_anom&latitude=winda_w_fll&latitude
ssta_anom!1="longitude"
ssta_anom&longitude=winda_w_fll&longitude

ssto_anom!0="latitude"
ssto_anom&latitude=winda_w_fll&latitude
ssto_anom!1="longitude"
ssto_anom&longitude=winda_w_fll&longitude

sst_anom_diff!0="latitude"
sst_anom_diff&latitude=winda_w_fll&latitude
sst_anom_diff!1="longitude"
sst_anom_diff&longitude=winda_w_fll&longitude

  printMinMax(ssta_anom,False)
;-----------------------------------------
; begin the figure
;-----------------------------------------

  res                   = True

my_levels_omega= (/-1.8,-1.6,-1.4,-1.2,-1,-.8,   \
                   -.6,-0.4,-.2,.2,.4,.6,        \
                    .8,1,1.2,1.4,1.6,1.8/); 18
my_colors_posneg = (/ 124,117,110,103,96, \
                      89,82,75,68,0,      \ 
                      60,53,46,39,32,     \
                      25,18,11,4/)

wks = gsn_open_wks("png","testSST")               ; send graphics to PNG file
  gsn_define_colormap(wks,"MPL_BrBG")
  plot = new(3,graphic)

  res@mpProjection      = "Mollweide"       ; choose projection
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
                            "LineOnly","LineOnly","NoLine","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine"/)
  res@cnFillMode        = "RasterFill"
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5

  res@vpKeepAspect    = False

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .020                               ; font height

  res@tiMainString      = "SST anom for El Nino"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False

  contour_1 = gsn_csm_contour_map(wks,ssto_anom(:,:),res)  ; create the plot
  res@tiMainString      = "SST anom for La Nina"
  contour_2 = gsn_csm_contour_map(wks,ssta_anom(:,:),res)  ; create the plot
  res@tiMainString      = " "
  res@cnLevelFlags      = (/"NoLine","NoLine","NoLine","NoLine", \ 
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine","NoLine","NoLine", \
                            "NoLine","NoLine"/)
  contour_3 = gsn_csm_contour_map(wks,sst_anom_diff(:,:),res)  ; create the plot

  plot(0) = contour_1
  plot(1) = contour_2
  plot(2) = contour_3

  resP                  = True            ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
  gsn_panel(wks,plot,(/3,1/),resP)


end
