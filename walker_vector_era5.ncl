;--------------------------------------------------------------------------
; walker_vector_era5.ncl 
;
; creates a height vs longitude plot with specific humidity as filled 
; contours and the wind plotted as vectors.   vertical dimension is 
; pressure, vertical velocity is the vertical pressure velocity, and the
; data used is from ERA5.  
;
; levi silvers                                                    june 2025
;--------------------------------------------------------------------------

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
;file1=datapath+"era5_u3D_1990th2024_360x180_jan.nc"
;file2=datapath+"era5_wap3D_1990th2024_360x180_jan.nc"
;file3=datapath+"era5_q_1990th2023_360x180_jan.nc"

file1=datapath+"era5_u3D_1990th2024_360x180_jul.nc"
file2=datapath+"era5_wap3D_1990th2024_360x180_jul.nc"
file3=datapath+"era5_q_1990th2023_360x180_jul.nc"

f1=addfile(file1,"r")
f2=addfile(file2,"r")
f3=addfile(file3,"r")

  print("incoming file is: "+file1)

lat1 = 87
lat2 = 93

lat1 = 70 
lat2 = 110

wind_u  = f1->u(:,:,lat1:lat2,:)
wind_w  = f2->w(:,:,lat1:lat2,:)
sphum   = f3->q(:,:,lat1:lat2,:)

u1  = dim_avg_n_Wrap(wind_u,2)
w1  = dim_avg_n_Wrap(wind_w,2)
qh1 = dim_avg_n_Wrap(sphum,2)

u  = dim_avg_n_Wrap(u1,0)
w  = dim_avg_n_Wrap(w1,0)
qh = dim_avg_n_Wrap(qh1,0)

wAve   = avg(wind_w(0,:,:,:))
uAve   = avg(wind_u(0,:,:,:))
scale  = fabs(uAve/wAve)
wscale = -wind_w*scale
wscale2= -w*scale

copy_VarCoords(wind_w, wscale)
copy_VarCoords(w, wscale2)

copy_VarCoords(wind_u, u)
copy_VarCoords(wind_w, w)
copy_VarCoords(sphum, qh)

printVarSummary(wind_u)
printVarSummary(wind_w)
printVarSummary(sphum)

shum_levs = (/0.002,0.004,0.006,0.008,0.01,0.012,0.014,0.016,0.018/)
shum_cols = (/1,60,80,100,120,140,160,180,200,220,240/)

;---Create plot
 wks   = gsn_open_wks ("png", "testvector_jul" )        ; send graphics to PNG file

 res                 = True                     ; plot mods desired
 res@tiMainString    = "Pressure/Height Vector" ; title

 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 ;res@cnFillPalette   = "BlAqGrYeOrReVi200"  ; choose color map
 res@cnFillPalette   = "WhiteBlue"  ; choose color map
 res@cnLevelSelectionMode  = "ExplicitLevels"
 res@cnLevels        = shum_levs
 res@cnFillColors    = shum_cols
 res@cnLinesOn       = False

 res@lbLabelStride   = 2                    ; every other color

 res@trYMinF               = 200
 res@trYMaxF               = 1000
 res@gsnYAxisIrregular2Log = True

 res@vcRefMagnitudeF        = 3.0                ; define vector ref mag
 res@vcRefLengthF           = 0.045              ; define length of vec ref
 res@vcGlyphStyle           = "CurlyVector"      ; turn on curly vectors
 ;res@vcMinDistanceF  = 0.01               ; thin out vectors
 ;res@vcMinDistanceF         = 0.005       ; thin out vectors
 res@vcMinDistanceF         = 0.03       ; thin out vectors
 res@vcLineArrowThicknessF  = 3.0         ; vector thickness
 res@vcMapDirection  = False

;---Draw plot from pole to pole at 170E
; plot  = gsn_csm_pres_hgt_vector(wks,sphum(0,:,{90},:),wind_u(0,:,{90},:),\
;                                wind_w(0,:,{90},:),res )  
; plot  = gsn_csm_pres_hgt_vector(wks,sphum(0,:,:),wind_u(0,:,:),\
;                                wscale(0,:,:),res )  
 plot  = gsn_csm_pres_hgt_vector(wks,qh(:,:),u(:,:),\
                                wscale2(:,:),res )  


end 
