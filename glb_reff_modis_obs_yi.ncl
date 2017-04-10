;*************************************************
; glb_reff_modis_obs_yi.ncl
;************************************************
;
;
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

; load observations
;
obs_varnm="Cloud_Particle_Size_Liquid_Mean"
;obs_varnm="Cloud_Particle_Size_Liquid_Uncertainty_in_Mean"
filein_obs1="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.01.C051.V02.nc"
filein_obs2="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.02.C051.V02.nc"
filein_obs3="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.03.C051.V02.nc"
filein_obs4="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.04.C051.V02.nc"
filein_obs5="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.05.C051.V02.nc"
filein_obs6="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.06.C051.V02.nc"
filein_obs7="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.07.C051.V02.nc"
filein_obs8="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.08.C051.V02.nc"
filein_obs9="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.09.C051.V02.nc"
filein_obs10="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.10.C051.V02.nc"
filein_obs11="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.11.C051.V02.nc"
filein_obs12="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.12.C051.V02.nc"

; why can't I get the remapped file to work?
;filein_obs1="/net2/Levi.Silvers/data/modisdata/reff_remap.nc"
;filein_obs1="reff_remap.nc"

; load model data
;
model2="c96L32_am4G12r17_2010climo_A_cosp"
;
infile_modis="/archive/Levi.Silvers/data/"+model2+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
varname="lremodis"
varname2="tclmodis"
scale_mds=1e6

infile_atm="/archive/Levi.Silvers/data/"+model2+"/atmos/atmos.0002-0011.alltmn.nc"

varname_yi="reff_modis"
varname2_yi="reff_modis2"
scale_yi=1.

;
maintitle="what are you doing?"
print("modis infile is: "+infile_modis)
  file_modis= addfile(infile_modis,"r")

print("infile_atm is: "+infile_atm)
  fileatm     = addfile(infile_atm,"r")

; observations
print("infile is: "+filein_obs1)
  file1_obs= addfile(filein_obs1,"r")
  file2_obs= addfile(filein_obs2,"r")
  file_modis_obs= addfile(filein_obs3,"r")
  file4_obs= addfile(filein_obs4,"r")
  file5_obs= addfile(filein_obs5,"r")
  file6_obs= addfile(filein_obs6,"r")
  file7_obs= addfile(filein_obs7,"r")
  file8_obs= addfile(filein_obs8,"r")
  file9_obs= addfile(filein_obs9,"r")
  file10_obs= addfile(filein_obs10,"r")
  file11_obs= addfile(filein_obs11,"r")
  file12_obs= addfile(filein_obs12,"r")
;
  file_modis_re= file_modis->$varname$(0,:,:) 
  file_modis_cf= file_modis->$varname2$(0,:,:) 

  fileatm_var_yi = fileatm->$varname_yi$(0,:,:) 
  fileatm_var2_yi= fileatm->$varname2_yi$(0,:,:) 

; modis obs
  file1_modis= file1_obs->$obs_varnm$(:,:) 
  file2_modis= file2_obs->$obs_varnm$(:,:) 
  file_modis_modis= file_modis_obs->$obs_varnm$(:,:) 
  file4_modis= file4_obs->$obs_varnm$(:,:) 
  file5_modis= file5_obs->$obs_varnm$(:,:) 
  file6_modis= file6_obs->$obs_varnm$(:,:) 
  file7_modis= file7_obs->$obs_varnm$(:,:) 
  file8_modis= file8_obs->$obs_varnm$(:,:) 
  file9_modis= file9_obs->$obs_varnm$(:,:) 
  file10_modis= file10_obs->$obs_varnm$(:,:) 
  file11_modis= file11_obs->$obs_varnm$(:,:) 
  file12_modis= file12_obs->$obs_varnm$(:,:) 
;; 
print("dimensions of lremodis are: "+dimsizes(file1_modis))
;;
;************************************************
; normalize by cloud fraction
modis_reff=scale_mds*file_modis_re/file_modis_cf
print("file_modis_re at point is: "+file_modis_re(45,45))
print("file_modis_cf at point is: "+file_modis_cf(45,45))
print("modis_reff at point is: "+modis_reff(45,45))

yi_reff=scale_yi*fileatm_var_yi/fileatm_var2_yi
print("yi_reff at point is: "+yi_reff(45,45))
;************************************************
; compute lat weights to determine the global mn
  lat  = file_modis->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  fmod_ave_weight     =wgt_areaave(file_modis_re,clat,1.0,1)
print("global mean of file_modis is: "+fmod_ave_weight)
print("max of obs modis_reff is: "+max(file1_modis))
print("min of obs modis_reff is: "+min(file1_modis))
;print("obs file1_modis at point are: "+file1_modis(:,90))
print("max of modis_reff is: "+max(modis_reff))
print("max of yi_reff is: "+max(yi_reff))
;************************************************
;
; compute the yearly mean of the incoming monthly modis data
modis_yr_mn=(file1_modis+file2_modis+file_modis_modis+file4_modis+\
            file5_modis+file6_modis+file7_modis+file8_modis+\
            file9_modis+file10_modis+file11_modis+file12_modis)/12
modis_yr_mn!0="lat"
modis_yr_mn&lat=file1_modis&lat
modis_yr_mn!1="lon"
modis_yr_mn&lon=file1_modis&lon
modis_reff!0="lat"
modis_reff&lat=file_modis_re&lat
modis_reff!1="lon"
modis_reff&lon=file_modis_re&lon
yi_reff!0="lat"
yi_reff&lat=fileatm&lat
yi_reff!1="lon"
yi_reff&lon=fileatm&lon
;************************************************
; create plot
;************************************************
; create colors to use in contours
;; contour levels
my_levels = (/0.,1.,2.,3.,4.,5.,6.,7.,8.,9.,10./) ;11
my_levels2 = (/0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20./) ;11
my_levels3 = (/5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15./) ;11
my_levels4 = (/10.,11.,12.,13.,14.,15.,16.,17.,18.,19.,20./) ;11
my_colors =  (/20 , 28, 35, 41, 46, 53, 59, 65, 69, 75, 79, 83/)
my_colors2 =  (/20 , 28, 35, 41, 46, 53, 59, 65, 69, 75, 79, 83/)
;my_colors =  (/14 , 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58/)
;my_colors2 =  (/14 , 22, 30, 38, 46, 54, 62, 70, 78, 86, 92, 100/)


my_levels_diff = (/-2.5,-2,-1.5,-1,-0.5, 0, 0.5, 1,1.5, 2,2.5/) ;11
my_colors_diff = (/30,25,20,15,10,5,76,81,86,91,96,100/) ; 12

;************************************************
  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to PNG file
;  gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  plot = new(3,graphic)

  res                   = True
  res@cnLinesOn            = False
  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpCenterLonF      = 180.
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@lbLabelAngleF          = 90
  res@mpFillOn          = False
  res@gsnDraw          = False
  res@gsnFrame         = False
  ;res@gsnMaximize       = True      ; this influences how much of the page is filled
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels4
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015 

;  res@vpXF            = 0.1                 ; make plot bigger
;  res@vpYF            = 0.9         
;  res@vpWidthF        = 0.8
;  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "Modis Cloud Particle Size Liq Mean"; add a title
  res@tiMainFontHeightF  = .018                               ; font height
  ;contour1 = gsn_csm_contour_map(wks,file1_reff,res)  ; create the plot
  ;contour1 = gsn_csm_contour_map(wks,file1_modis,res)  ; create the plot
  contour1 = gsn_csm_contour_map(wks,modis_yr_mn,res)  ; create the plot
  plot(0) = contour1

  res@gsnFrame         = False
  res@tiMainString       = "am4g12r17" 
  res@cnLevels          = my_levels3
  res@cnFillColors      = my_colors
  contour2 = gsn_csm_contour_map(wks,modis_reff,res)  ; create the plot
  plot(1) = contour2

  res@gsnFrame         = False
  res@tiMainString       = "simp sim"
  contour3 = gsn_csm_contour_map(wks,yi_reff,res)  ; create the plot
  plot(2) = contour3

 ; txres               = True
 ; txres@txFontHeightF = 0.03
 ; gsn_text_ndc(wks,"This is a title",0.5,0.95,txres)

  respanel = True

  gsn_panel(wks,plot,(/3,1/),respanel)

end

