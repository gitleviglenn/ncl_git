;---------------------------------------------------------------------
; glb_radflux.ncl
;---------------------------------------------------------------------
;
; reads in data files from one experiment
; and plots a six panel figure of variables
; 
; variables plotted are:   -Net TOA rad flux
;                          -LW clr
;                          -LW CRE
;                          -Net CRE
;                          -SW clr
;                          -SW CRE
; 
; this program generally depends on the output from 
; cdo_pp_sstpat.s that will create the 
; needed input files.  
;
; this script also prints out the global mean values of the fields
; to be plotted
; 
; levi silvers                                         march 2016                    
;---------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;---------------------------------------------------------------------
begin
;---------------------------------------------------------------------
; read in netCDF file
;---------------------------------------------------------------------
dirin="/archive/Levi.Silvers/sstpatt/am4_1pc_test"
;expname="/atmos_c96L32_am4g9_last20yr_warmpatt"
;expname="/atmos_c96L32_am4g9_1860climo_ctl_qc_test"
expname="/atmos_AM4OM2F_c96l32_am4g5r11_2000climo_1pct"
period="0136-0140"

;path_to8xdaily="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos_8xdaily_alt40/ts/3hr/5yr/"

;path="/archive/Levi.Silvers/awg/warsaw/c96L33_am4p0_cmip6Diag_cosp_sep1/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/annual_5yr/"
;filename="atmos.2004-2008.ann.nc"
;infile=path+filename
;---------------------------------------------------------------------
; read in netCDF files 
;---------------------------------------------------------------------
;
; olr,olr_clr,swdn_toa,swup_toa,swdn_toa_clr,swup_toa_clr
;varname1="olr" ; this is not the actual var, but should
tempvarname="t_surf"
pre1="_"
infile1=dirin+expname+pre1+"toaflux_"+period+".nc"
;varname1="swdn_toa"
varname1="toaflux"
infile2=dirin+expname+pre1+"toaflux_CRE_"+period+".nc"
print("infile2 is: "+infile2)
;varname2="olr_clr"
varname2="toaflux_cre"
infile3=dirin+expname+pre1+"olr_clr_"+period+".nc"
varname3="olr_clr"
infile4=dirin+expname+pre1+"swup_toa_clr_"+period+".nc"
varname4="swup_toa_clr"
infile5=dirin+expname+pre1+"olr_CRE_"+period+".nc"
;varname5="olr_clr"
varname5="olr_cre"
infile6=dirin+expname+pre1+"sw_CRE_"+period+".nc"
;varname6="swup_toa_clr"
varname6="sw_cre"
;
;infile2=dirin+expname+iifile2
temp1=dirin+expname+pre1+"t_surf_"+period+".nc"
;temp2=dirin+expname+pre2+"t_surf.nc"
print("incoming temperature file is: "+temp1)
  aa = addfile(infile1,"r")
  ab = addfile(infile2,"r")
  ac = addfile(infile3,"r")
  ad = addfile(infile4,"r")
  ae = addfile(infile5,"r")
  af = addfile(infile6,"r")
  atemp =addfile(temp1,"r") 
;  btemp =addfile(temp2,"r") 
print("infile1 is: "+infile1)
month=0
  field1 = aa->$varname1$(month,:,:)          
  field2 = ab->$varname2$(month,:,:)         
  field3 = ac->$varname3$(month,:,:)         
  field4 = ad->$varname4$(month,:,:)         
  field5 = ae->$varname5$(month,:,:)         
  field6 = af->$varname6$(month,:,:)         
  tempctl = atemp->$tempvarname$(month,:,:)          
;  tempctlpreg = btemp->$tempvarname$(month,:,:)         
;
;;---------------------------------------------------------------------
; print max and min values
print("infile1 is: "+infile1)
print("max of toaflux is: "+max(field1))
print("min of toaflux is: "+min(field1))
print("infile2 is: "+infile2)
print("max of toaflux CRE is: "+max(field2))
print("min of toaflux CRE is: "+min(field2))
print("infile3 is: "+infile3)
print("max of olr clr is: "+max(field3))
print("min of olr clr is: "+min(field3))
print("infile4 is: "+infile4)
print("max of swup toa clr is: "+max(field4))
print("min of swup toa clr is: "+min(field4))
print("infile5 is: "+infile5)
print("max of olr CRE is: "+max(field5))
print("min of olr CRE is: "+min(field5))
print("infile6 is: "+infile6)
print("max of sw CRE is: "+max(field6))
print("min of sw CRE is: "+min(field6))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = aa->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
field1_weighted_ave     = wgt_areaave(field1,clat,1.0,1)
;t2_weighted_ave     = wgt_areaave(t2,clat,1.0,1)
temp1_weighted_ave     = wgt_areaave(tempctl,clat,1.0,1)
;temp2_weighted_ave     = wgt_areaave(tempctlpreg,clat,1.0,1)
;print("global mean toa rad flux of ctl is: "+t1_weighted_ave)
;print("global mean toa rad flux of ctl preg is: "+t2_weighted_ave)
print("global mean sfc temp of ctl is: "+temp1_weighted_ave)
;print("global mean sfc temp of ctlpreg is: "+temp2_weighted_ave)
;---------------------------------------------------------------------
;---------------------------------------------------------------------
; create plot
;---------------------------------------------------------------------
; create colors to use in contours
; contour levels
;my_levels1 = (/265,270,275,280,284,286,288,290,292,294,296,298,300,302,304/)
;my_levels_nettoa = (/-120,-90,-60,-30,0, 30,60,90,120/)
my_levels_nettoa = (/-80,-60,-40,-20,0, 20,40,60,80/)
my_levels_netcre = (/5,0,-10,-20,-30,-40,-50,-60,-70/)
my_levels_olrcre = (/5,12,19,26,33,40,47,54,61/)
my_levels_swcre = (/-10,-20,-30,-40,-50,-60,-70,-80,-90/)
my_levels_swclr = (/35,50,65,80,95,110,125,140,155/)
my_levels_lwclr = (/140,160,180,200,220,240,260,280,300/)
;
my_colors_posneg = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_nettoa = (/ 34, 24,19,14,4,76,80,85,90,95,100/)
my_colors_olrcre = (/ 9, 2,74,77,80,83,86,89,92,95,100/)
my_colors_netcre = (/ 50,44,38,32,26,20,14,8,2,77,2/)
my_colors_swcre = (/ 56,50,44,38,32,26,20,14,8,2,2/)
my_colors_swclr = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)
my_colors_lwclr = (/35,40, 45, 50, 55, 60, 65, 70, 75,80,85/)

;---------------------------------------------------------------------
  wks = gsn_open_wks("ps","testplot")          ; send graphics to PNG file
  ;gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  plot = new(6,graphic)

  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@lbLabelAngleF          = 90
  res@mpFillOn          = False
  res@gsnDraw          = False
  res@gsnFrame         = False
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
  res@gsnMaximize       = True
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_nettoa
  res@cnFillColors      = my_colors_posneg
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  ;res@tiMainString       = maintitle  ; add a title
  
  res@tiMainFontHeightF  = .018                               ; font height

; top row 
  res@tiMainString       = "Net TOA Flux" 
  res@lbOrientation            = "Vertical"
  res@lbLabelAngleF            = 0
  ;res@gsnPaperOrientation = "portrait" 
  res@mpGridAndLimbOn    = False
  ;res@mpMajorLatSpacingF  = 45
  res@gsnTickMarksOn     = False
  contour0 = gsn_csm_contour_map(wks,field1,res)  ; create the plot
  plot(0) = contour0
  res@gsnFrame         = False
  res@cnLevels          = my_levels_netcre
  res@cnFillColors      = my_colors_netcre
  res@tiMainString       = "Net CRE" 
  contour1 = gsn_csm_contour_map(wks,field2,res)  ; create the plot
  plot(1) = contour1

; middle row
  res@cnLevels          = my_levels_lwclr
  res@cnFillColors      = my_colors_lwclr
  res@tiMainString       = "LW clr" 
  contour2 = gsn_csm_contour_map(wks,field3,res)  ; create the plot
  plot(2) = contour2
  res@gsnFrame         = False
  res@cnLevels          = my_levels_swclr
  res@cnFillColors      = my_colors_swclr
  res@tiMainString       = "SW clr " 
  contour3 = gsn_csm_contour_map(wks,field4,res)  ; create the plot
  plot(3) = contour3

; bottom row
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels_olrcre
  res@cnFillColors      = my_colors_olrcre
  res@tiMainString       = "LW CRE" 
  contour4 = gsn_csm_contour_map(wks,field5,res)  ; create the plot
  plot(4) = contour4
  res@gsnFrame         = False
  res@cnLevels          = my_levels_swcre
  res@cnFillColors      = my_colors_swcre
  res@tiMainString       = "SW CRE" 
  contour5 = gsn_csm_contour_map(wks,field6,res)  ; create the plot
  plot(5) = contour5

  respanel = True

  gsn_panel(wks,plot,(/3,2/),respanel)

end

