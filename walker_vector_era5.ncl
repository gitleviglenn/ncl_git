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

file1=datapath+"era5_u3D_1990th2024_360x180.nc"
file2=datapath+"era5_wap3D_1990th2024_360x180.nc"
file3=datapath+"era5_q_1990th2024_360x180.nc"

f1=addfile(file1,"r")
f2=addfile(file2,"r")
f3=addfile(file3,"r")

  print("incoming file is: "+file1)
;fileout="overturningCirc_nina_pm20"
fileout="overturningCirc_nina_tropics_WangIndices"
  print("output figure file is: "+fileout)

; deep tropics
;lat1 = 87
;lat2 = 93

; 10-20 degrees north
;lat1 = 100 
;lat2 = 110

; 20S to 20N
lat1 = 70 
lat2 = 110

; time indices
;-----------------------------------------------------------
; these indices correspond to the definition used by Phil 
;; and I in our work that focuses on the N Atl TC season:
;ensoInd = (/18, 19, 20, 21, 22, 23, \
;            54, 55, 56, 57, 58, 59, \
;            90, 91, 92, 93, 94, 95, \
;            150, 151, 152, 153, 154, 155, \
;            174, 175, 176, 177, 178, 179, \
;            234, 235, 236, 237, 238, 239, \
;            306, 307, 308, 309, 310, 311, \
;            402, 403, 404, 405, 406, 407 /)
;;; Nina
;ensoInd_nina = (/102, 103, 104, 105, 106, 107, \
;                 114, 115, 116, 117, 118, 119, \
;                 210, 211, 212, 213, 214, 215, \
;                 246, 247, 248, 249, 250, 251, \
;                 318, 319, 320, 321, 322, 323, \
;                 366, 367, 368, 369, 370, 371, \
;                 378, 379, 380, 381, 382, 383, \
;                 390, 391, 392, 393, 394, 395 /)
;-----------------------------------------------------------
; these indices correspond to the definition that Wang used: 
; corresonds to November, December, and January
;ensoIndW = (/23,24,25, \
ensoInd = (/23,24,25, \
             59,60,61, \
             95,96,97, \
             155,156,157, \
             179,180,181, \
             239,240,241, \
             311,312,313, \
             407,408,409 /)
;; Nina
;ensoIndW_nina = (/107,108,109, \
ensoInd_nina = (/107,108,109, \
                  119,120,121, \
                  215,216,217, \
                  251,252,253, \
                  323,324,325, \
                  371,372,373, \
                  383,384,385, \
                  395,396,397 /)
;-----------------------------------------------------------

; first set of data (El Nino): 
wind_u  = f1->u(ensoInd,:,lat1:lat2,:)
wind_w  = f2->w(ensoInd,:,lat1:lat2,:)
sphum   = f3->q(ensoInd,:,lat1:lat2,:)

u1  = dim_avg_n_Wrap(wind_u,2)
w1  = dim_avg_n_Wrap(wind_w,2)
qh1 = dim_avg_n_Wrap(sphum,2)

u  = dim_avg_n_Wrap(u1,0)
w  = dim_avg_n_Wrap(w1,0)
qh = dim_avg_n_Wrap(qh1,0)

wAve   = avg(wind_w(0,:,:,:))
uAve   = avg(wind_u(0,:,:,:))
scale  = fabs(uAve/wAve)
;wscale = -wind_w*scale
scale = 100.
wscale = -w*scale
print("scaling factor 1 is: "+scale)

;-----------------
; second set of data (La Nina): 

;lat1 = 100 
;lat2 = 110 

wind_u_b  = f1->u(ensoInd_nina,:,lat1:lat2,:)
wind_w_b  = f2->w(ensoInd_nina,:,lat1:lat2,:)
sphum_b   = f3->q(ensoInd_nina,:,lat1:lat2,:)

u1b  = dim_avg_n_Wrap(wind_u_b,2)
w1b  = dim_avg_n_Wrap(wind_w_b,2)
qh1b = dim_avg_n_Wrap(sphum_b,2)

u_b  = dim_avg_n_Wrap(u1b,0)
w_b  = dim_avg_n_Wrap(w1b,0)
qh_b = dim_avg_n_Wrap(qh1b,0)

wscale_b = -w_b*scale

;print("dimsizes of u: "+dimsizes(u_b))
;print("dimsizes of w: "+dimsizes(w_b))
;print("dimsizes of qh: "+dimsizes(qh_b))

;wAve_b   = avg(wind_w(0,:,:,:))
;uAve_b   = avg(wind_u(0,:,:,:))
;scale_b  = fabs(uAve_b/wAve_b)
;wscaleb = -wind_w*scale
;wscale_b= -w_b*scale

;-----------------
; compute differences
; Nino - Nina
;u_diff  = u - u_b
;w_diff  = wscale - wscale_b
;qh_diff = qh - qh_b
; Nina - Nino
u_diff  = u_b - u
w_diff  = wscale_b - wscale
qh_diff = qh_b - qh

print("dimsizes of u: "+dimsizes(u_diff))
print("dimsizes of w: "+dimsizes(w_diff))
print("dimsizes of qh: "+dimsizes(qh_diff))

;---------------------------------------

;copy_VarCoords(wind_w, wscale)
copy_VarCoords(w, wscale)
copy_VarCoords(w, wscale_b)
;copy_VarCoords(w, w_diff)
copy_VarCoords(wscale, w_diff)

copy_VarCoords(wind_u, u)
;copy_VarCoords(wind_w, w)
copy_VarCoords(sphum, qh)

copy_VarCoords(wind_u, u_b)
;copy_VarCoords(wind_w, w_b)
copy_VarCoords(sphum, qh_b)

copy_VarCoords(u_b, u_diff)
;copy_VarCoords(wind_w, w_diff)
;copy_VarCoords(sphum, qh_diff)
copy_VarCoords(qh_b, qh_diff)

;printVarSummary(wind_u)
;printVarSummary(wind_w)
printVarSummary(qh_b)
printVarSummary(qh_diff)

shum_levs = (/0.002,0.004,0.006,0.008,0.01,0.012,0.014,0.016,0.018/)
;shum_levs_diff = (/0.00073,0.00076,0.0008,0.00083,0.00086,0.001,0.0013,0.0016,0.002/)
shum_cols = (/1,60,80,100,120,140,160,180,200,220,240/)
;
shum_levs_diff = (/-0.0001,-0.00005,-0.00001,-0.000005,0.0,0.000005,0.00001,0.00005,0.0001/); 9
;shum_levs_diff = (/-0.0001,-0.00005,-0.00001,-0.000005,-0.000001,0.0,0.000001,0.000005,0.00001,0.00005,0.0001/); 11 
;shum_levs_diff = (/-0.00005,-0.00001,-0.000005,-0.000001,0.000001,0.000005,0.00001,0.00005/); 8 
;shum_cols_diff = (/2,3,4,5,6,7,8,9,10,11,12/); 11 
;shum_cols_diff = (/3,4,5,6,7,8,9,10,11/); 9 
;shum_cols_diff = (/2,3,4,5,6,7,8,9,10/); 9 
;shum_cols_diff = (/16,15,14,13,12,11,10,9,8,7/); 10 
;shum_cols_diff = (/7,8,9,10,11,12,13,14,15,16/); 10 

; worked
;shum_cols_diff = (/2,3,4,5,6,7,8,9,10,11/); 10 

shum_cols_diff = (/215,195,175,155,114,114,75,55,35,15/); 10 

wtype = "png"
wtype@wkWidth   = 2500
wtype@wkHeight  = 2500

;---Create plot
 wks   = gsn_open_wks (wtype, fileout )        ; send graphics to PNG file
 plot = new(3,graphic)

 res                 = True                     ; plot mods desired
 ;res@tiMainString    = "Pressure/Height Vector" ; title

 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 ;res@cnFillPalette   = "BlAqGrYeOrReVi200"  ; choose color map
 res@cnFillPalette   = "WhiteBlue"  ; choose color map
 res@cnLevelSelectionMode  = "ExplicitLevels"
 res@cnLevels        = shum_levs
 res@cnFillColors    = shum_cols
 res@cnLinesOn       = False

 res@lbLabelStride   = 2                    ; every other color

 res@gsnFrame              = False
 res@gsnDraw               = False

 res@trYMinF               = 150
 res@trYMaxF               = 1000
 res@gsnYAxisIrregular2Log = True

 res@vcRefMagnitudeF        = 3.0                ; define vector ref mag
 res@vcRefLengthF           = 0.045              ; define length of vec ref
 res@vcGlyphStyle           = "CurlyVector"      ; turn on curly vectors
 ;res@vcMinDistanceF  = 0.01               ; thin out vectors
 ;res@vcMinDistanceF         = 0.005       ; thin out vectors
 res@vcMinDistanceF         = 0.03       ; thin out vectors
 res@vcLineArrowThicknessF  = 5.0         ; vector thickness
 res@vcMapDirection  = False


print("******************************************************")
  printMinMax(qh_b,False)      
  printMinMax(qh_diff,False)      
print("******************************************************") 
;---Draw plot from pole to pole at 170E
; plot  = gsn_csm_pres_hgt_vector(wks,sphum(0,:,{90},:),wind_u(0,:,{90},:),\
;                                wind_w(0,:,{90},:),res )  
; plot  = gsn_csm_pres_hgt_vector(wks,sphum(0,:,:),wind_u(0,:,:),\
;                                wscale(0,:,:),res )  
 res@tiMainString    = "El Nino" ; title
 plot(0)  = gsn_csm_pres_hgt_vector(wks,qh(:,:),u(:,:),\
                                wscale(:,:),res )  
 res@tiMainString    = "La Nina" ; title
 plot(1)  = gsn_csm_pres_hgt_vector(wks,qh_b(:,:),u_b(:,:),\
                                wscale_b(:,:),res )  
 ;plot(2)  = gsn_csm_pres_hgt_vector(wks,qh_diff(:,:),u_diff(:,:),\
                                ;w_diff(:,:),res )  
 res2                 = True                     ; plot mods desired
 ;res2@tiMainString    = "Nino - Nina" ; title
 res2@tiMainString    = "Nina - Nino" ; title

 res2@cnLineLabelsOn  = False                ; turn off line labels
 res2@cnFillOn        = True                 ; turn on color fill
 res2@cnLevelSelectionMode  = "ExplicitLevels"
 res2@cnLinesOn       = False

 res2@lbLabelStride   = 2                    ; every other color

 res2@gsnFrame              = False
 res2@gsnDraw               = False

 res2@trYMinF               = 150
 res2@trYMaxF               = 1000
 res2@gsnYAxisIrregular2Log = True

 res2@vcRefMagnitudeF        = 3.0                ; define vector ref mag
 res2@vcRefLengthF           = 0.045              ; define length of vec ref
 res2@vcGlyphStyle           = "CurlyVector"      ; turn on curly vectors
 res2@vcMinDistanceF         = 0.03       ; thin out vectors
 res2@vcLineArrowThicknessF  = 5.0         ; vector thickness
 res2@vcMapDirection  = False

 ;res2@cnFillPalette   = "BrownBlue12"
 ;res2@cnFillPalette   = "temp_diff_18lev"
 res2@cnFillPalette   = "BlueWhiteOrangeRed"
 res2@cnLevels        = shum_levs_diff
 res2@cnFillColors    = shum_cols_diff
 plot(2)  = gsn_csm_pres_hgt_vector(wks,qh_diff(:,:),u_diff(:,:),\
                                w_diff(:,:),res2 )  

resP                         = True              ; modify the panel plot
  resP@gsnFrame                = False
  gsn_panel(wks,plot,(/2,2/),resP)
  frame(wks)


end 
