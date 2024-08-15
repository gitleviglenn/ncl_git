;***********************************************************************************
; windClimo_GlobalMap.ncl
;***********************************************************************************
;
; plot the magnitude and wind vectors of the 850hPa and 200hPa wind fields for
; either El Nino or La Nina
;
; produces a 2 panel figure of wind shear from ERA5.  wind is shown with filled 
; contours and a solid black contour is used to border the chosen region of the 
; doldrums, often chosen as 1,3, or 5 m/s wind speed.  
; 
; when using ERA5 data, I have had to use the function short2flt to convert the
; data type from short to float.
;
; 
; levi silvers                                                         aug 2024 
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
filename="era5_monthly_1959present_10mWindSpeed.nc"

;EarthLike=1; default, EarthLike=1 corresponds to amip and historical

  ;expn   ="amip"
  ;ntimes ="120"
expn   ="hist"
ntimes ="120"
  print("plotting EarthLike simulations")

;file1=fnino
file1=filename
file1o=fnino
file1a=fnina

infile1=datapath+file1
infile1o=datapath+file1o
infile1a=datapath+file1a

f1=addfile(infile1,"r")
f1o=addfile(infile1o,"r")
f1a=addfile(infile1a,"r")
  print("incoming file is: "+infile1)
  print("incoming fileo is: "+infile1o)
  print("incoming filea is: "+infile1a)

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts units if necessary
scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

;pressAtLev = f1->plev
;  print(pressAtLev)
lat  = f1->latitude
lon  = f1->longitude
time = f1o->time
lev  = f1o->level
print("lev at 0: "+lev(0))
print("lev at 2: "+lev(2))

; time, level, latitude, longitude
winda_u_fll  = f1a->u(:,:,:,:)
  printVarSummary(winda_u_fll)
winda_u_full = scale2kt*short2flt(winda_u_fll)
winda_v_fll  = f1a->v(:,:,:,:)
winda_v_full = scale2kt*short2flt(winda_v_fll)
; calculate the shear
;nina_u_diff = winda_u_full(:,0,:,:) - winda_u_full(:,2,:,:)
;nina_v_diff = winda_v_full(:,0,:,:) - winda_v_full(:,2,:,:)
;nina_spd = sqrt(nina_u_diff^2+nina_v_diff^2)

nina_spd = sqrt(winda_u_full^2+winda_v_full^2)

windo_u_fll  = f1o->u(:,:,:,:)
windo_u_full = scale2kt*short2flt(windo_u_fll)
windo_v_fll  = f1o->v(:,:,:,:)
windo_v_full = scale2kt*short2flt(windo_v_fll)

;nino_u_diff = windo_u_full(:,0,:,:) - windo_u_full(:,2,:,:)
;nino_v_diff = windo_v_full(:,0,:,:) - windo_v_full(:,2,:,:)
;nino_spd = sqrt(nino_u_diff^2+nino_v_diff^2)

nino_spd = sqrt(windo_u_full^2+windo_v_full^2)

aa=dimsizes(winda_u_full)

;nina_shr = new((/aa(2),aa(3)/),typeof(winda_v_full))
;nino_shr = new((/aa(2),aa(3)/),typeof(windo_v_full))
  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  printVarSummary(winda_u_full)
  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  ;print("levels: "+lev)
  ;print("times: "+time)

winda_u_tmn = dim_avg_n_Wrap(winda_u_full,0)
winda_v_tmn = dim_avg_n_Wrap(winda_v_full,0)
;nina_spd_tmn = dim_avg_n_Wrap(nina_spd,0)
;nino_spd_tmn = dim_avg_n_Wrap(nino_spd,0)

  printMinMax(winda_u_tmn,False)
  printMinMax(winda_v_tmn,False)
  ;printMinMax(nina_spd_tmn,False)

printVarSummary(nina_spd)
nina_spd_tmn = dim_avg_n_Wrap(nina_spd,0)
nino_spd_tmn = dim_avg_n_Wrap(nino_spd,0)

windo_u_tmn = dim_avg_n_Wrap(windo_u_full,0)
windo_v_tmn = dim_avg_n_Wrap(windo_v_full,0)

; calculate the shear, as the diff of values on 200hPa from 850hPa: 
;nina_shr = nina_spd_tmn;     = nina_spd_tmn(0,:,:)-nina_spd_tmn(2,:,:)
;nino_shr = nino_spd_tmn

  printVarSummary(nina_spd_tmn)

nina_spd_tmn!0="level"
nina_spd_tmn&level=winda_u_fll&level
nina_spd_tmn!1="latitude"
nina_spd_tmn&latitude=winda_u_fll&latitude
nina_spd_tmn!2="longitude"
nina_spd_tmn&longitude=winda_u_fll&longitude

nino_spd_tmn!0="level"
nino_spd_tmn&level=winda_u_fll&level
nino_spd_tmn!1="latitude"
nino_spd_tmn&latitude=winda_u_fll&latitude
nino_spd_tmn!2="longitude"
nino_spd_tmn&longitude=winda_u_fll&longitude

;nina_shr!0="latitude"
;nina_shr&latitude=winda_u_fll&latitude
;nina_shr!1="longitude"
;nina_shr&longitude=winda_u_fll&longitude

;nino_shr!0="latitude"
;nino_shr&latitude=winda_u_fll&latitude
;nino_shr!1="longitude"
;nino_shr&longitude=winda_u_fll&longitude

  ;print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  ;printVarSummary(nina_shr)
  ;printMinMax(nina_shr,False)
  ;print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

  ;printMinMax(wap500_tmn_1,False)
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

;my_levels_omega= (/-35.,-30.,-25.,-20.,-15.,-10.,-8.,-6.,-4.,-2.,0,2.,4.,6,8,10,15,20,25,30,35/); 21 

my_levels_omega= (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40/); 21 
my_levels_omega= (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,35,40,45,50,55/); 21 

; below is the original color scheme
;my_colors_posneg = (/ 2,2,63,75,87,99,111,123,135,147,159,171,183,195,207,219,231/); 22 

res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine",   \
                   "NoLine","NoLine","LineOnly","NoLine","NoLine", \
                   "NoLine","NoLine","NoLine","NoLine","NoLine",   \
                   "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)

;my_colors_posneg = (/ 3,15,27,39,51,63,75,87,99,111,123,135,147,159,171,183,190,200,210,220,230,240/); 22 

my_colors_posneg = (/ 2,7,10,15,20,28,30,38,46,56,66,76,86,96,106,116,140,152,164,176,188,200/); 22 


;my_colors_posneg = (/ 2,13,25,37,49,51,63,75,87,99,111,123,135,147,159,171,183,195,207,219,231,243/); 22 
;                     1,  2, 3, 4,5 , 6 , 7 , 8 , 9 ,10 , 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

  wks = gsn_open_wks("pdf","testclimoplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"WhiteBlue")
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  ;gsn_define_colormap(wks,"BlueYellowRed")
  ;gsn_define_colormap(wks,"NCV_blu_red")
  plot = new(2,graphic)

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

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            =  30.
  res@mpMinLonF            =  0.
  res@mpMaxLonF            = 360.
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = True
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ;res@gsnMaximize       = True
  ;res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5
  ;res@cnLineLabelsOn    = False             ; turn off contour lines
  ; plotting only the zero contour line isn't working for some reason. 
  ;res@gsnContourZeroLineThicknessF = 2.5
  ;res@txFontHeightF     = 0.018 

  res@vpKeepAspect    = False
  ;res@vpXF            = 0.1                 ; make plot bigger
  ;res@vpYF            = 0.9         
  ;res@vpWidthF        = 0.8
  ;res@vpHeightF       = 0.8
  ;res@vpWidthF        = 0.4
  ;res@vpHeightF       = 0.8

  ;res@lbLabelFontHeightF  = 0.018           ; label bar font height
  res@lbLabelBarOn       = False  ; turn off individual label bars

  ;res@tiMainString       = maintitle  ; add a title
  ;res@tiMainFontHeightF  = .020                               ; font height

  res@tiMainString      = "ERA5 Wind at 200 hPa"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False


  ;contour_1 = gsn_csm_contour_map(wks,wind10_mask_jja,res)  ; create the plot
  contour_1 = gsn_csm_contour_map(wks,nino_spd_tmn(0,:,:),res)  ; create the plot
  res@tiMainString      = "ERA5 Wind at level 850 hPa"
  contour_2 = gsn_csm_contour_map(wks,nino_spd_tmn(2,:,:),res)  ; create the plot
  res@tiMainString      = " "

  plot(0) = contour_1
  plot(1) = contour_2

  resP                  = True                   ; modify the panel plot
  resP@gsnPanelLabelBar  = True              ; add common colorbar
  ;resP@lbOrientation     = "vertical"
  resP@pmLabelBarWidthF  = 0.75             ; make thinner
  resP@lbLabelFontHeightF= 0.02             ; make thinner
  resP@lbLabelFontThicknessF = 2.5             ; make thinner
  resP@pmLabelBarHeightF = 0.15
  resP@lbBoxLinesOn            = True
  ;res@lbOrientation           = "Vertical"
  resP@lbTitleString           = "wind (m/s)"
  resP@lbTitlePosition         = "Bottom"
  resP@lbLabelFontHeightF      = 0.013
  resP@lbTitleFontHeightF      = 0.013

    ;pres@pmLabelBarHeightF = 0.20
  resP@gsnFrame         = False                  ; don't advance panel plot

  gsn_panel(wks,plot,(/2,1/),resP)

;-----------------------------------------
end
;-----------------------------------------
