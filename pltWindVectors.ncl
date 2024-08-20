;***********************************************************************************
; pltWindVectors.ncl
;
; Plots wind vectors based on two components of the wind (u,v) at a particular
; pressure level, in this case either 200 hPa or 850 hPa, selected by pltlev. 
; 
; user can choose to plot winds from a composite of years based on either el Nino, 
; or la Nina.   Data is from ERA5, the years used to select el Nina and la Nina were
; chosen by using the relative oceanic nino indec, or RONI.
;
; the u component of the wind is used to color the vectors.  
;
; to do:  figure out how to specify the particular values that are colored and 
; displayed.  this function seems to have limited resources relative to other ncl
; functions.
;
; the initial script borrows heavily from the example scripts of ncl documentation     
;
; levi silvers                                                    aug 2024
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

if (enso .eq. 0) then
  print("El Nino phase selected")
  file1=fnino
  ensoPhase = "El Nino"
  ;infile1o=datapath+file1
else if (enso .eq. 1) then
  print("La Nina phase selected")
  file1=fnina
  ensoPhase = "La Nina"
  ;infile1=datapath+file1
end if 
end if

mtitle = ensoPhase+" wind vectors at 850hPa"
pltlev = 2; 0 corresponds to 200 hPa, 2 to 850 hPa

  
infile1=datapath+file1
  print("incoming file is: "+infile1)

;file1o=fnino
;file1a=fnina

;infile1=datapath+file1o
;infile1a=datapath+file1a

f1a=addfile(infile1,"r")
;f1a=addfile(infile1a,"r")
;  print("incoming fileo is: "+infile1o)
;  print("incoming filea is: "+infile1a)

;scalef=864; converts Pa/s to hPa/day
scalef=1; converts units if necessary
scale2kt=1.94384; converts m/s to knots 1m/s=1.94384 knots

lat  = f1a->latitude
lon  = f1a->longitude
time = f1a->time
lev  = f1a->level

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

;windo_u_fll  = f1o->u(:,:,:,:)
;windo_u_full = scale2kt*short2flt(windo_u_fll)
;windo_v_fll  = f1o->v(:,:,:,:)
;windo_v_full = scale2kt*short2flt(windo_v_fll)

;nino_u_diff = windo_u_full(:,0,:,:) - windo_u_full(:,2,:,:)
;nino_v_diff = windo_v_full(:,0,:,:) - windo_v_full(:,2,:,:)
;nino_spd = sqrt(nino_u_diff^2+nino_v_diff^2)

;nino_spd = sqrt(windo_u_full^2+windo_v_full^2)

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

  printVarSummary(winda_u_tmn)
  printMinMax(winda_u_tmn,False)
  printMinMax(winda_v_tmn,False)
  ;printMinMax(nina_spd_tmn,False)

printVarSummary(nina_spd)
nina_spd_tmn = dim_avg_n_Wrap(nina_spd,0)
;nino_spd_tmn = dim_avg_n_Wrap(nino_spd,0)

;windo_u_tmn = dim_avg_n_Wrap(windo_u_full,0)
;windo_v_tmn = dim_avg_n_Wrap(windo_v_full,0)

; calculate the shear, as the diff of values on 200hPa from 850hPa: 
;nina_shr = nina_spd_tmn;     = nina_spd_tmn(0,:,:)-nina_spd_tmn(2,:,:)
;nino_shr = nino_spd_tmn

  printVarSummary(nina_spd_tmn)
winda_u_tmn!0="level"
winda_u_tmn&level=winda_u_fll&level
winda_u_tmn!1="latitude"
winda_u_tmn&latitude=winda_u_fll&latitude
winda_u_tmn!2="longitude"
winda_u_tmn&longitude=winda_u_fll&longitude

winda_v_tmn!0="level"
winda_v_tmn&level=winda_u_fll&level
winda_v_tmn!1="latitude"
winda_v_tmn&latitude=winda_u_fll&latitude
winda_v_tmn!2="longitude"
winda_v_tmn&longitude=winda_u_fll&longitude

nina_spd_tmn!0="level"
nina_spd_tmn&level=winda_u_fll&level
nina_spd_tmn!1="latitude"
nina_spd_tmn&latitude=winda_u_fll&latitude
nina_spd_tmn!2="longitude"
nina_spd_tmn&longitude=winda_u_fll&longitude

;nino_spd_tmn!0="level"
;nino_spd_tmn&level=winda_u_fll&level
;nino_spd_tmn!1="latitude"
;nino_spd_tmn&latitude=winda_u_fll&latitude
;nino_spd_tmn!2="longitude"
;nino_spd_tmn&longitude=winda_u_fll&longitude

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

;  res                   = True

;my_levels= (/-35.,-30.,-25.,-20.,-15.,-10.,-5.,0,5.,10,15,20,25,30,35/);  
;my_colors= (/58,68,78,88,98,108,118,128,129,139,149,159,169,179,189,199/); ,116,140,152,164,176,188,200/); 16 

;my_levels_omega= (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40/); 21 

wks = gsn_open_wks("png","testvector")               ; send graphics to PNG file
;gsn_define_colormap(wks,"amwg256")

  ;cmap = read_colormap_file("BlAqGrYeOrReVi200")
  cmap = read_colormap_file("amwg256")

  vcres                     = True      ; plot mods desired
  vcres@lbLabelStride       = 2         ; plot every other colar bar label
  vcres@vcRefMagnitudeF         = 5.0              ; make vectors larger
  vcres@vcRefLengthF            = 0.050            ; ref vec length
  vcres@cnLevelSelectionMode  = "ExplicitLevels"
  ;vcres@cnLevels            = my_levels
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017            ; thin out vectors
  vcres@vcLevelPalette      = cmap(6:247,:)

  vcres@tiMainString            = mtitle 

  printVarSummary(winda_u_tmn)
  printVarSummary(winda_v_tmn)

  plot=gsn_csm_vector_scalar_map_ce(wks,winda_u_tmn(pltlev,:,:),winda_v_tmn(pltlev,:,:),winda_u_tmn(pltlev,:,:),vcres)  ; create plot

end 
