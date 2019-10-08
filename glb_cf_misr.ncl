;***********************************************************************************
; glb_cf_misr.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the misr cosp tool.
;
; example here is for clouds below 3km with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; in general the tau levels in misr are:
; 0.15,0.8,2.45,6.5,16.2,41.5,100.

; the dimensions of clmisr are: 
; clmisr(time, tau, alt16, lat, lon) ;
;
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							oct 2019
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; read in netCDF file
;***********************************************************************************
;dirin="/work/Levi.Silvers/moddata/misr_am4g10r8_taugt0p3/"
dirin="/Users/silvers/data/cfmip_clouds/"
;infile="/archive/Levi.Silvers/awg/ulm_201505/c96L32_am4h6_2000climo_cosp/gfdl.ncrc2-intel-prod-openmp/pp/atmos_month_misr/av/monthly_5yr/atmos_month_misr_mtime_under3km_tau_mn_final.nc"
;infile=dirin+"atmos_month_misr_mtime_under3km_tau_mn_final.nc"
infile=dirin+"clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_199701-200212.nc"
maintitle="MISR cloud fraction over all heights"
  a = addfile(infile,"r")
print("infile is: "+infile)
var2read="clmisr"
;  t = a->misr_7(0,0,:,:)                                
  cfrac_thin = a->$var2read$(:,1:2,0,:,:) ; for thin clouds      
  cfrac = a->$var2read$(:,3:6,:,:,:) ; for thicker clouds      
  cfrac_tmn=dim_avg_n(cfrac,0)
print("dimensions of cfrac_tmn are: "+dimsizes(cfrac_tmn))
  cfrac_tmn_totz=dim_sum_n(cfrac_tmn,1)
  cfrac_tmn_totz_thick=dim_sum_n(cfrac_tmn_totz,0)
  cfrac_plot=cfrac_tmn_totz_thick
print("dimensions of cfrac are: "+dimsizes(cfrac))
print("dimensions of cfrac_tmn_totz are: "+dimsizes(cfrac_tmn_totz))
print("dimensions of cfrac_plot are: "+dimsizes(cfrac_plot))
print("max/min of cfrac is: "+max(cfrac)+"  "+min(cfrac))                         
;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/)
my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/)

  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  ;wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  gsn_define_colormap(wks,"WhBlGrYeRe")


  res                   = True
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
 
; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels1
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = maintitle  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,cfrac_plot,res)  ; create the plot
end

