;*************************************************
; glb_reff_modis.ncl
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
model1="c96L32_am4G12r18_2010climo_A_cosp"
model2="c96L32_am4G12r17_2010climo_A_cosp"
model3="c96L32_am4G12r16_2010climo_new_cosp"
;
infile1="/archive/Levi.Silvers/data/"+model1+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
infile2="/archive/Levi.Silvers/data/"+model1+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
infile3="/archive/Levi.Silvers/data/"+model2+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
infile4="/archive/Levi.Silvers/data/"+model3+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
varname="lremodis"
varname2="tclmodis"
scale=1e6

;infile1="/archive/Levi.Silvers/data/"+model1+"/atmos/atmos.0002-0011.alltmn.nc"
;infile2="/archive/Levi.Silvers/data/"+model1+"/atmos/atmos.0002-0011.alltmn.nc"
;infile3="/archive/Levi.Silvers/data/"+model2+"/atmos/atmos.0002-0011.alltmn.nc"
;infile4="/archive/Levi.Silvers/data/"+model3+"/atmos/atmos.0002-0011.alltmn.nc"
;varname="reff_modis"
;varname2="reff_modis2"
;scale=1.

;
maintitle="what are you doing?"
print("infile is: "+infile1)
  file1     = addfile(infile1,"r")
print("infile is: "+infile2)
  file2= addfile(infile2,"r")
print("infile is: "+infile3)
  file3= addfile(infile3,"r")
print("infile is: "+infile4)
  file4= addfile(infile4,"r")

; observations
print("infile is: "+filein_obs1)
  file1_obs= addfile(filein_obs1,"r")
  file2_obs= addfile(filein_obs2,"r")
  file3_obs= addfile(filein_obs3,"r")
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
;varname="lremodis"
;varname2="tclmodis"
  file1_re= file1->$varname$(0,:,:) 
  file1_cf= file1->$varname2$(0,:,:) 
  file2_re= file2->$varname$(0,:,:) 
  file2_cf= file2->$varname2$(0,:,:) 
  file3_re= file3->$varname$(0,:,:) 
  file3_cf= file3->$varname2$(0,:,:) 
  file4_re= file4->$varname$(0,:,:) 
  file4_cf= file4->$varname2$(0,:,:) 

; modis obs
  file1_modis= file1_obs->$obs_varnm$(:,:) 
  file2_modis= file2_obs->$obs_varnm$(:,:) 
  file3_modis= file3_obs->$obs_varnm$(:,:) 
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
print("dimensions of lremodis from model are: "+dimsizes(file1_re))
;;
;************************************************
; normalize by cloud fraction
file1_reff=scale*file1_re/file1_cf
file2_reff=scale*file2_re/file2_cf
file3_reff=scale*file3_re/file3_cf
file4_reff=scale*file4_re/file4_cf
print("file1_re is: "+file1_re(45,45))
print("file1_cf is: "+file1_cf(45,45))
print("file1_re/file1_cf is: "+file1_reff(45,45))
print("dimensions of file1_reff are: "+dimsizes(file1_reff))
;************************************************
; compute lat weights to determine the global mn
  lat  = file1->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  f1_ave_weight     =wgt_areaave(file1_re,clat,1.0,1)
  f2_ave_weight     =wgt_areaave(file2_re,clat,1.0,1)
  f3_ave_weight     =wgt_areaave(file3_re,clat,1.0,1)
print("global mean of file1 is: "+f1_ave_weight)
print("global mean of file2 is: "+f2_ave_weight)
print("global mean of file3 is: "+f3_ave_weight)
print("max of obs modis_reff is: "+max(file1_modis))
print("min of obs modis_reff is: "+min(file1_modis))
;print("obs file1_modis at point are: "+file1_modis(:,90))
print("max of file1_reff is: "+max(file1_reff))
print("min of file1_reff is: "+min(file1_reff))
print("max of file3_reff is: "+max(file3_reff))
print("max of file4_reff is: "+max(file4_reff))
;************************************************
;
; compute the yearly mean of the incoming monthly modis data
modis_yr_mn=(file1_modis+file2_modis+file3_modis+file4_modis+\
            file5_modis+file6_modis+file7_modis+file8_modis+\
            file9_modis+file10_modis+file11_modis+file12_modis)/12
; compute the diff between the ctlpreg and ctlp4k
  diff_f2mctl=file2_reff-file1_reff
  ;diff_f2mctl=file2_reff-file1_modis
  f2mctl_weightmn     =wgt_areaave(diff_f2mctl,clat,1.0,1)
print("global mean tsfc of f2 m ctl is: "+f2mctl_weightmn)
  diff_f3mctl=file3_reff-file1_reff
  f3mctl_weightmn     =wgt_areaave(diff_f3mctl,clat,1.0,1)
print("global mean tsfc of f3 m ctl is: "+f3mctl_weightmn)
  diff_f4mctl=file4_reff-file1_reff
  f4mctl_weightmn     =wgt_areaave(diff_f4mctl,clat,1.0,1)
print("global mean tsfc of f4 m ctl is: "+f4mctl_weightmn)
print("max of diff_f3mctl is: "+max(diff_f3mctl))
print("min of diff_f3mctl is: "+min(diff_f3mctl))
modis_yr_mn!0="lat"
modis_yr_mn&lat=file1_modis&lat
modis_yr_mn!1="lon"
modis_yr_mn&lon=file1_modis&lon
;file1_modis!0="lat"
;file1_modis&lat=file1_re&lat
;file1_modis!1="lon"
;file1_modis&lon=file1_re&lon
file1_reff!0="lat"
file1_reff&lat=file1_re&lat
file1_reff!1="lon"
file1_reff&lon=file1_re&lon
diff_f3mctl!0="lat"
diff_f3mctl&lat=file1_re&lat
diff_f3mctl!1="lon"
diff_f3mctl&lon=file1_re&lon
print("max of diff_f4mctl is: "+max(diff_f4mctl))
print("min of diff_f4mctl is: "+min(diff_f4mctl))
diff_f4mctl!0="lat"
diff_f4mctl&lat=file1_re&lat
diff_f4mctl!1="lon"
diff_f4mctl&lon=file1_re&lon
diff_f2mctl!0="lat"
diff_f2mctl&lat=file1_re&lat
diff_f2mctl!1="lon"
diff_f2mctl&lon=file1_re&lon
file3_reff!0="lat"
file3_reff&lat=file1_re&lat
file3_reff!1="lon"
file3_reff&lon=file1_re&lon
;************************************************
; create plot
;************************************************
; create colors to use in contours
;; contour levels
my_levels = (/0.,1.,2.,3.,4.,5.,6.,7.,8.,9.,10./) ;11
my_levels2 = (/0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20./) ;11
my_colors =  (/20 , 28, 35, 41, 46, 53, 59, 65, 69, 75, 79, 83/)
my_colors2 =  (/20 , 28, 35, 41, 46, 53, 59, 65, 69, 75, 79, 83/)
;my_colors =  (/14 , 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58/)
;my_colors2 =  (/14 , 22, 30, 38, 46, 54, 62, 70, 78, 86, 92, 100/)

;; blueish
;my_colors =  (/10 , 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65/)
;my_colors2 =  (/10 , 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120/)
;; rustish
;my_colors =  (/144 , 149, 154, 159, 164, 169, 174, 179, 184, 189, 194, 199/)
;my_colors2 =  (/144 , 154, 164, 174, 184, 194, 204, 214, 224, 234, 244, 254/)

my_levels_diff = (/-2.5,-2,-1.5,-1,-0.5, 0, 0.5, 1,1.5, 2,2.5/) ;11
my_colors_diff = (/30,25,20,15,10,5,76,81,86,91,96,100/) ; 12

;************************************************
  wks = gsn_open_wks("pdf","testplot")          ; send graphics to PNG file
;  gsn_define_colormap(wks,"gui_default")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  ;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  plot = new(4,graphic)

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
  res@gsnMaximize       = True
 
; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels2
  res@cnFillColors      = my_colors2
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "Modis Cloud Particle Size Liq Mean"; add a title
  res@tiMainFontHeightF  = .018                               ; font height
  ;contour1 = gsn_csm_contour_map(wks,file1_reff,res)  ; create the plot
  ;contour1 = gsn_csm_contour_map(wks,file1_modis,res)  ; create the plot
  contour1 = gsn_csm_contour_map(wks,modis_yr_mn,res)  ; create the plot
  plot(0) = contour1

  res@gsnFrame         = False
  res@tiMainString       = "am4g12r18" 
  res@cnLevels          = my_levels
  res@cnFillColors      = my_colors
  contour2 = gsn_csm_contour_map(wks,file1_reff,res)  ; create the plot
  plot(1) = contour2

  res@gsnFrame         = False
  res@tiMainString       = "am4g12r17-am4g12r18"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  contour3 = gsn_csm_contour_map(wks,diff_f3mctl,res)  ; create the plot
  plot(2) = contour3

  res@gsnFrame         = False
  res@tiMainString       = "am4g12r16-am4g12r18"
  res@cnLevels          = my_levels_diff
  res@cnFillColors      = my_colors_diff
  ;contour4 = gsn_csm_contour_map(wks,tdiff4co2,res)  ; create the plot
  contour4 = gsn_csm_contour_map(wks,diff_f4mctl,res)  ; create the plot
  plot(3) = contour4

  txres               = True
  txres@txFontHeightF = 0.03
  gsn_text_ndc(wks,"This is a title",0.5,0.95,txres)

  respanel = True

  gsn_panel(wks,plot,(/2,2/),respanel)

end

