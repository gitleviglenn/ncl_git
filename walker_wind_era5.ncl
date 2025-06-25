;***********************************************************************************
; walker_wind_era5.ncl
;***********************************************************************************
;
; following some of the analysis from Wang, 2005, chapter 6. 
;
; desired plots: 
; vertical velocity at 500 mb
; divergent wind at 200 mb
; velocity potential at 200 mb
; vectory plot, vertical cross-section using vertical velocityand divergent wind
;     at several vertical levels. 
;
; vertical pressure levels (12) used by Wang: 
; 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 mb.
;
; to calculate the divergent wind components use: dv2uvg()
; to calculate the divergence use: uv2dvG_Wrap()
; see: https://www.ncl.ucar.edu/Applications/Scripts/wind_1.ncl
;
; to calculate the velocity potential and stream function given u and v on a global 
; grid use: uv2sfvpf()
;
; should probably regrid to 360x180 so the file size is more maneagable.
; something like this: 
; cdo -L remapbil,mygrid -sethalo,-1,-1 era5mon1940toPresent_div_U_V_time.nc era5mon1940toPresent_div_U_V_regrid.nc
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin

; for starters we could use this file: 
file1="/Users/C823281551/data/era5_uv_augsepoct202020212022.nc"

f1=addfile(file1,"r")

  print("incoming file is: "+file1)

wind_u  = f1->u(:,1,:,:)
wind_v  = f1->v(:,1,:,:)

  printVarSummary(wind_u)

div = uv2dvG_Wrap(wind_u,wind_v)

ud  = new ( dimsizes(wind_u), typeof(wind_u), wind_u@_FillValue )
vd  = new ( dimsizes(wind_v), typeof(wind_v), wind_v@_FillValue )

dv2uvg(div,ud,vd)

copy_VarCoords(wind_u, ud ) 
copy_VarCoords(wind_u, vd ) 
ud@long_name  = "Zonal Divergent Wind"
ud@units      = wind_u@units
vd@long_name  = "Meridional Divergent Wind"
vd@units      = wind_v@units


;*************************************************
; plot results
;*************************************************    
  wks  = gsn_open_wks("png","wind")           ; send graphics to PNG file
                                             
  res                 = True
  res@vcRefMagnitudeF = 3.                    ; make vectors larger
  res@vcRefLengthF    = 0.050                 ; reference vector length
  res@vcGlyphStyle    = "CurlyVector"         ; turn on curly vectors
  res@vcMinDistanceF  = 0.012                 ; thin the vectors

  res@gsnLeftString   = "Divergent Wind"
                                              ; plot 1st time step
  plot= gsn_csm_vector_map(wks,ud(0,:,:),vd(0,:,:),res)


end
