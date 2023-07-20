;----------------------------------------------------------------------
; wind10m_streamline_GlobalMap.ncl 
;
; coppied from stream_6.ncl example
; Concepts illustrated:
;   - Drawing streamlines over filled contours on a map
;   - Adding more arrows to streamlines
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin

datapath="~/data/ERA5/"
;filename="era5_monthly_1959present_10mWindSpeed.nc"
filename="era5_monthly_1959to2022.nc"
infile=datapath+filename

  f = addfile(infile,"r")
  sstr = f->si10(100,0,:,:)           ; read in sst data

  ur    = f->u10(100,0,::-1,:)    ; read in example data [2D only here]
  vr    = f->v10(100,0,::-1,:)
  sstr = f->si10(100,0,::-1,:)           ; read in sst data

  u = short2flt(ur)
  v = short2flt(vr)
  sst = short2flt(sstr)

printVarSummary(u)
printVarSummary(sst)

;*************************************************************
; perform regridding to 1x1 degree lat lon or regrid CRM
; models to a coarse gird...
;----------------------------
      print("begin interpolation...")
    var_to_interpolate=u
    var2_to_interpolate=v
      var_to_interpolate!0="lat"
      var_to_interpolate!1="lon"
      var2_to_interpolate!0="lat"
      var2_to_interpolate!1="lon"

    dim_orig=dimsizes(var_to_interpolate)
    nlat=dim_orig(0)
    nlon=dim_orig(1)

    latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
    latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

    opt = False
    NLAT1x1       = 180                               ; RES   = "180x288"
    MLON1x1       = 360
    LAT_out       = latGlobeFo(NLAT1x1, "LAT_out_temp", "latitude" , "degrees_north")
    LON_out       = lonGlobeFo(MLON1x1, "LON_out", "longitude", "degrees_east" )

    interp_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_out, LAT_out, opt)
    interp_var2 = area_conserve_remap_Wrap (var2_to_interpolate&lon, var2_to_interpolate&lat, var2_to_interpolate,LON_out, LAT_out, opt)

    intvar_out=interp_var
    intvar_out2=interp_var2
    ;intvar_out!0="time"
    intvar_out!0="lat"
    intvar_out!1="lon"
    intvar_out2!0="lat"
    intvar_out2!1="lon"
      print("interpolation finished")
;  else  ; case for CRMs
;    print("interpolation to 1x1 degree grid not computed.")
;  end if  ; end interpolation loop
;else ; end interpswitch .eq. 1
;  print("------Warning!  Interpolation not performed.  ICON?------")
;    intvar_out=wvar_a
;end if

;======================================

  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")
  print("max and min of intvar_out are: "+max(intvar_out)+" and "+min(intvar_out))
  print("max and min of intvar_out2 are: "+max(intvar_out2)+" and "+min(intvar_out2))
  print("max and min of u are: "+max(u)+" and "+min(u))
  print("-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-")

;---create plots
  ;wks  = gsn_open_wks("png","stream")           ; send graphics to PNG file
  wks  = gsn_open_wks("eps","stream")           ; send graphics to PNG file
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")  ; choose color map

  res                      = True               ; plot mods desired
;  ;res@cnFillOn             = True               ; turn on color for contours
;  res@cnLinesOn            = False              ; turn off contour lines
;  ;res@mpProjection         = "Mollweide"       ; choose projection
;  res@cnLineLabelsOn       = False              ; turn off contour line labels
;  ;res@gsnSpreadColors      = True               ; use full color map
;  ;res@gsnSpreadColorStart  = 17                 ; start at color 17
;  ;res@gsnSpreadColorEnd    = 200                ; end at color 200
;
;  res@mpLandFillColor       = "gray"            ; set land to be gray
;
;  ;res@mpMinLonF            =  65.               ; select a subregion
;  ;res@mpMaxLonF            =  95.
;  ;res@mpMinLatF            =   5. 
;  ;res@mpMaxLatF            =  25.
;
;  res@lbOrientation            = "Vertical"     ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
;  res@lbLabelStride            = 4
;  res@lbLabelStride            = 4

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  ;res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  ;res@cnMinLevelValF       = 24.0               ; set min contour level
  ;res@cnMaxLevelValF       = 29                 ; set max contour level
  ;res@cnLevelSpacingF      = 0.10               ; set contour spacing

 ; res@stArrowLengthF     = 0.015            ; changes the size of the arrows.
 ; res@stArrowLengthF     = 0.004                    ; size of the arrows.
  ;res@stMinArrowSpacingF = 0.004                    ; arrow spacing.
  ;res@stMinArrowSpacingF = 0.4                    ; arrow spacing.
  ;res@stStepSizeF         = 0.001
  ;res@stMinDistanceF     = 0.03
  res@stMinDistanceF     = 0.02
;  res@stArrowStride      = 30                        ; arrows start every third

  ;plot = gsn_csm_streamline_map_ce(wks,u,v,res)
  ;plot = gsn_csm_streamline_map_ce(wks,intvar_out,intvar_out2,res)
  ;plot = gsn_csm_streamline_contour_map_ce(wks,u,v,sst(:,:),res)
  plot = gsn_csm_streamline_contour_map(wks,u,v,sst(:,:),res)
end

