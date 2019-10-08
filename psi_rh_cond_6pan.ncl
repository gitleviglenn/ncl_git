; load necessary libraries
; psi_rh_cond_6pan.ncl

  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-----------------------------------
; define parameters for script:
  figurenumber = 2 ; 1 is defualt for crm resolution, 2 or greater is for gcm res
  crm_grid = 1 ; 1 for 1km, 2 for 2km
  ensind=2 ; should correspond to control run for 25km grid-spacing
  expstring="ctl" ; lwoff or ctl
;-----------------------------------
; name of output file
  fileout="rh_psi_cond"
;-----------------------------------
;  expstring="lwoff"
  if (figurenumber .lt. 2) then
    ;expstring="lwoff"
    expstring="ctl"
  end if

;-----------------------------------
; path to data
  path_to_wc="/Users/silvers/data"
  walkcell="/WalkerCell/gauss_d"
  ;file_pre="/c96L33_8x80_nh.19790101"
  file_pre="/19790101"
  file_pre_b="/19800101"
  file_pre_c="/19810101"
  file_pre_d="/19820101"

; locate files for gcm

  in_rh=path_to_wc+walkcell+"/mymy_rh.nc"
  ;in_rh=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_rh.nc"
  ;in_psi=path_to_wc+walkcell+"/mymy_psi.nc"
  in_psi=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_psi_ent0p9.nc"
  in_rh=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_clouds_ctl.nc"
  ;in_cloud=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_clouds_ctl.nc"
print("incoming gcm file is: "+in_rh)
print("incoming gcm file is: "+in_psi)

; locate files for crm

; these files contain data from both 1km and 2km experiments even though they are in 
; the directory for the 1km experiment
  in_rh_crm=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_"+expstring+"_tmn.nc"
  in_psi_crm=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_"+expstring+"_tmn.nc"

  ;in_crm_1km=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_lwoff_tmn.nc"
  ;in_crm_2km=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_lwoff_tmn.nc"

print("incoming crm file is: "+in_rh_crm)
print("incoming crm file is: "+in_psi_crm)

; define variable names
  var1      ="myrh" ; time, grid_y, grid_x
  var2      ="mystream"
  var3      ="pfull"
  psi_1km   ="psi_1km"
  hur_1km   ="hur_1km"
  psi_2km   ="psi_2km"
  hur_2km   ="hur_2km"
  cond_1km  ="tot_condensed_1km"
  cond_2km  ="tot_condensed_2km"
  cond_25km ="tot_condensed"

; read data from the files
  data_rh=addfile(in_rh,"r")
  data_psi=addfile(in_psi,"r")
  data_rh_crm=addfile(in_rh_crm,"r")
  data_psi_crm=addfile(in_psi_crm,"r")

  field_rh   = data_rh->$var1$(:,:,:)
  field_psi  = data_psi->$var2$(:,:,:)
  field_cond_raw = data_rh->$cond_25km$(:,:,:)

  field_cond=1000*field_cond_raw

  field_press  = data_rh_crm->$var3$(:)

  field_psi_1crm = data_psi_crm->$psi_1km$(:,:)
  field_psi_2crm = data_psi_crm->$psi_2km$(:,:)
print("dimsizes for 1km crm psi data are: "+dimsizes(field_psi_1crm))
print("dimsizes for 2km crm psi data are: "+dimsizes(field_psi_2crm))
  field_rh_1crm  = data_rh_crm->$hur_1km$(:,:)
  field_rh_2crm  = data_rh_crm->$hur_2km$(:,:)
  field_cond_1crm  = data_rh_crm->$cond_1km$(:,:) ; the data_rh_crm file contains more than rh
  field_cond_2crm  = data_rh_crm->$cond_2km$(:,:)

;
print("dimsizes of field rh are: "+dimsizes(field_rh))
print("---------------------------------------------")
print("dimsizes of field rh are: "+dimsizes(field_rh))
print("---------------------------------------------")

;---------------------------------------
; begin code related to creating figure
;---------------------------------------
;plot_type="newPDF"
plot_type="eps"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/10,20, \
               30,40, \
               50,60,70, \
               80,90/) ; 9

my_cond_levels = (/0.5,0.4,0.3,0.2,0.1,0.05,0.01, \
                   0.005, 0.001, 0.0005, \
                   0.0001,0.00005,0.00001 /) ; 13

;my_cond_colors = (/111,115,120,125,147,159, \
;                   171,183,\
;                   195,207,219,\
;                   231,243,255/)  

;my_cond_colors = (/255,243,231,219,207,195,183,171,159,147,125,120,115,111/);111,115,120,125,147,159, \
                   ;171,183,\
                   ;195,207 /),219,\
                   ;231,243,255/)  

my_cond_colors = (/0,65,60,55,50,45,40,20,15,12,9,6,4,2/);,
;my_cond_colors = (/2,10,20,30,40,50,183,171,159,147,125,120,115,111/);





if (figurenumber .ge. 2) then
  scale_cons=1.e-2
  my_levels_psi_2 = (/-65*scale_cons,-59*scale_cons, -53*scale_cons, -47*scale_cons, \
                      -41*scale_cons, \
                     -35*scale_cons, -29*scale_cons, -23*scale_cons, -17*scale_cons, \
                     -11*scale_cons,   -5*scale_cons,   1*scale_cons,  7*scale_cons /)
  my_levels_psi_1 = (/-20*scale_cons,-14*scale_cons, -8*scale_cons, -2*scale_cons, \
                      4*scale_cons, \
                      10*scale_cons, 16*scale_cons, 22*scale_cons, 28*scale_cons, \
                     34*scale_cons,   40*scale_cons,   46*scale_cons,  52*scale_cons /)
  my_levels_psi_0 = (/-35*scale_cons,-29*scale_cons, -23*scale_cons, -17*scale_cons, \
                      -11*scale_cons, \
                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons /)
else
if (figurenumber .lt. 2) then
  scale_cons=1.e-2
  ;scale_cons=1.e11
  ;;my_levels_psi=scale_cons*my_levels_psi
  my_levels_psi_25 = (/-65*scale_cons,-59*scale_cons, -53*scale_cons, -47*scale_cons, \
                      -41*scale_cons, \
                     -35*scale_cons, -29*scale_cons, -23*scale_cons, -17*scale_cons, \
                     -11*scale_cons,   -5*scale_cons,   1*scale_cons,  7*scale_cons /)
  my_levels_psi_2 = (/-35*scale_cons,-29*scale_cons, -23*scale_cons, -17*scale_cons, \
                      -11*scale_cons, \
                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons /)
  my_levels_psi_1 = (/-29*scale_cons, -23*scale_cons, -17*scale_cons, \
                      -11*scale_cons, \
                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons, \
                     43*scale_cons /)
  my_levels_psi_25_lwoff = (/-20*scale_cons,-14*scale_cons, -8*scale_cons, -2*scale_cons, \
                      4*scale_cons, \
                      10*scale_cons, 16*scale_cons, 22*scale_cons, 28*scale_cons, \
                     34*scale_cons,   40*scale_cons,   46*scale_cons,  52*scale_cons /)
end if
end if

my_levels1_crm = (/1,3,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,37,39, \
               41,43 /) ; 22


my_colors1 = (/126, \
               112,98, \
               84,70,56,  \
               42,28,14,2/) ;19 

my_col_psi = (/11,15,18,23,31,\
               39,47,\
               55,71,\
               79,87,91/) ;10 

  rhplot1=field_rh_1crm
  rhplot2=field_rh_2crm
  psiplot1=field_psi_1crm
  psiplot2=field_psi_2crm
  hor_x_1km=ispan(1,4000,1)
  hor_x_2km=ispan(2,4000,2)
print("dimsizes of hor_x are: "+dimsizes(hor_x_1km))
print("dimsizes of rhplot are: "+dimsizes(rhplot1))
print("dimsizes of psiplot are: "+dimsizes(psiplot1))

; set up the x dimension for each of the grids
; for the 25km grid
  rhplot=field_rh
  psiplot=field_psi
  condplot=field_cond

  hor_x=ispan(25,4000,25)

  rhplot!0="plev"
  rhplot&plev=field_press
  rhplot!1="xdim"
  rhplot&xdim=hor_x
  
  psiplot!0="plev"
  psiplot&plev=field_press
  psiplot!1="xdim"
  psiplot&xdim=hor_x

  condplot!0="plev"
  condplot&plev=field_press
  condplot!1="xdim"
  condplot&xdim=hor_x

; for the 2km grid
  rhplot2!0="plev"
  rhplot2&plev=field_press
  psiplot2!0="plev"
  psiplot2&plev=field_press
  rhplot2!1="xdim"
  rhplot2&xdim=hor_x_2km
  psiplot2!1="xdim"
  psiplot2&xdim=hor_x_2km
; for the 1km grid
  rhplot1!0="plev"
  rhplot1&plev=field_press
  psiplot1!0="plev"
  psiplot1&plev=field_press
  rhplot1!1="xdim"
  rhplot1&xdim=hor_x_1km
  psiplot1!1="xdim"
  psiplot1&xdim=hor_x_1km

;gsn_define_colormap(wks,"BlAqGrYeOrRe")
;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"NCV_blu_red")
gsn_define_colormap(wks,"MPL_coolwarm")
;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"BlAqGrYeOrRe")

; previously used default
;gsn_define_colormap(wks,"MPL_PuBuGn")

;; start default plots----------------------------------------------------------
 plot = new(6,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@txFontHeightF     = 0.015
 res@tiYAxisFontHeightF= 0.02
 res@tmYLLabelFontHeightF = 0.018
 res@gsnCenterString     = "P25"
 res@cnFillOn                 = True 
; res@cnFillMode               = "RasterFill"       ; Raster Mode
 res@cnLinesOn                = False
 res@cnLevelSelectionMode = "ExplicitLevels" ; or "ManualLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
; res@cnLinesOn             = False
 res@trYReverse               = True     ; reverse the y-axis
 res@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 ;res@vpWidthF          = 2.0 ; vpWidth and Height control box size
 ;res@vpHeightF         = 2. ; default for both is 0.6 in NDC units
 res@lbLabelBarOn      = False

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@trYMaxF      = 100000
 res@trYMinF      = 10000
 res@trXMinF      = 2
 res@tmXBMode     = "Explicit"
 res@tmXBValues   = (/2,1000,2000,3000,4000/)
 ;res2@tmXBLabels   = ""+res2@tmXBValues
 res@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
 res@tmYLMode     = "Explicit"
 res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 ;res@tmYLLabels   = ""
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "Pressure (hPa) "

 res2 = True     
 res2@gsnDraw               = False
 res2@gsnFrame              = False
; res2@cnLevels              = my_levels_psi_0
 res2@cnInfoLabelOn         = False
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnMonoLineDashPattern = False
if (figurenumber .lt. 2) then
 ;res2@cnLineDashPatterns = (/2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0/)
 res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
else
 ;res2@cnLineDashPatterns = (/2,2,2,2,2,0,0,0,0,0,0,0/) ; use to plot ensind = 0
 res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/) ; use to plot ensind = 1
; res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/) ; use to plot ensind = 1
end if
  res2@cnLinesOn             = True
  res2@cnLineLabelsOn        = False
  res2@cnLineThicknessF      = 3
  res2@trYReverse            = True     ; reverse the y-axis
  res2@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
  res2@trYMaxF      = 100000
  res2@trYMinF      = 10000
  res2@trXMaxF      = 4000
  res2@trXMinF      = 2
  res2@tmXBMode     = "Explicit"
   if (figurenumber .lt. 2) then
     res2@tmXBValues   = (/2,1000,2000,3000,4000/)
   else
     res2@tmXBValues   = (/25,1000,2000,3000,4000/)
   end if
  ;res2@tmXBLabels   = ""+res2@tmXBValues
  res2@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
  ;res2@vpWidthF          = 2.0 ; vpWidth and Height control box size
  ;res2@vpHeightF         = 2. ; default for both is 0.6 in NDC units
  res2@lbLabelBarOn      = False
 ; these commands turn off/on the varname and units at top of image
  res2@gsnLeftString = ""
  res2@gsnRightString = ""
  res2@tiXAxisString     = " "
  res2@tiYAxisString     = "height "
 
if (figurenumber .lt. 2) then

  titstring=" 1 or 2 km"
  ;mainTitle="Months 2-6:"+titstring+" "+expstring
  ;  mainTitle="Steady State Relative Humidity and Circulation"
  mainTitle = " "  

  relwidth = 0.9
  relheight= 0.9

  ;ensind=1 ; lwoff
  ensind=2 ; control, convection on, lwon
  ;ensind=3 ; lwoff noconv
print("max/min of psiplot ensind  is: "+max(psiplot(:,:,ensind))+" and: "+min(psiplot(:,:,ensind)))
print("max/min of psiplot1 is: "+max(psiplot1(:,:))+" and: "+min(psiplot1(:,:)))
print("max/min of psiplot2 is: "+max(psiplot2(:,:))+" and: "+min(psiplot2(:,:)))

;print("max/min of condplot ensind  is: "+max(condplot(:,:,ensind))+" and: "+min(condplot(:,:,ensind)))

 
  res@trXMinF      = 25
  res2@trXMinF      = 25
  res@gsnCenterString     = "P25 "
  res2@cnLevels              = my_levels_psi_25
  ; res2@cnLevels              = my_levels_psi_25_lwoff
  plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
  plot_rh_a = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)
  overlay(plot_rh_a,plot_psi)

  plot(0) = plot_rh_a

  ;res@gsnCenterString     = "P25 eventually"
  res@gsnCenterString     = "E1 "
  res@trXMinF      = 1
  res2@trXMinF      = 1

  plot_rh_2 = gsn_csm_contour(wks,rhplot1(:,:),res)

  res@gsnCenterString     = "E2 "
  res@trXMinF      = 2
  res2@trXMinF      = 2

  plot_rh_3 = gsn_csm_contour(wks,rhplot2(:,:),res)

  res2@cnLevels              = my_levels_psi_1

  plot_psi_2 = gsn_csm_contour(wks,psiplot1(:,:),res2)

  res2@cnLevels              = my_levels_psi_2

  plot_psi_3 = gsn_csm_contour(wks,psiplot2(:,:),res2)
  
  overlay(plot_rh_2,plot_psi_2)
  overlay(plot_rh_3,plot_psi_3)
  ;plot_0 = plot_rh
  ;plot_1 = plot_rh
  ;plot(0) = plot_rh
; res@vpXF            =   0.4
; res@vpYF            =   0.55
  plot(1) = plot_rh_3
; res@vpXF            =   0.7
; res@vpYF            =   0.55
  plot(2) = plot_rh_2

else ;--------------------------------------------------------------------------
if (figurenumber .ge. 2) then

  ;mainTitle="GCM resolution"
  mainTitle=" "

  res@trXMinF       = 25
  res2@trXMinF      = 25

print("dimsizes of hor_x are: "+dimsizes(hor_x))
print("dimsizes of rhplot are: "+dimsizes(rhplot))
print("dimsizes of psiplot are: "+dimsizes(psiplot))
print("max/min of psiplot ens 0 is: "+max(psiplot(:,:,0))+" and: "+min(psiplot(:,:,0)))
print("max/min of psiplot ens 1 is: "+max(psiplot(:,:,1))+" and: "+min(psiplot(:,:,1)))
print("max/min of psiplot ens 2 is: "+max(psiplot(:,:,2))+" and: "+min(psiplot(:,:,2)))
print("values from psi are: "+psiplot(12,80,ensind))

print("max/min of condplot ensind  is: "+max(condplot(:,:,ensind))+" and: "+min(condplot(:,:,ensind)))

  relwidth = 0.5
  relheight= 0.5

  res@vpWidthF          = relwidth ; vpWidth and Height control box size
  res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  res2@cnLevels         = my_levels_psi_2
  res@txFontHeightF     = 0.02
  res2@txFontHeightF     = 0.02

  plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
  plot_rh_a = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)
  overlay(plot_rh_a,plot_psi)

  plot(0) = plot_rh_a

  ; res@vpXF            =   0.42
  ; res@vpYF            =   0.55
  res@vpWidthF          = relwidth ; vpWidth and Height control box size
  res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  res@tiYAxisString     = " "
  res@gsnCenterString     = "E25 LWCRE off"
  res@tmYLLabels    = (/" "," "," "," "," "," "/)
  
  res2@cnLevels         = my_levels_psi_1

  plot_psi_b = gsn_csm_contour(wks,psiplot(:,::-1,1),res2)
  plot_rh_b  = gsn_csm_contour(wks,rhplot(::-1,::-1,1),res)
  overlay(plot_rh_b,plot_psi_b)

  plot(1) = plot_rh_b

 ; res@vpXF            =   0.9
 ; res@vpYF            =   0.55
  res@vpWidthF          = relwidth ; vpWidth and Height control box size
  res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  res@tiYAxisString     = " "
  res@gsnCenterString     = "E25 LWCRE on, Conv off"
  res@tmYLLabels    = (/" "," "," "," "," "," "/)
  res2@cnLevels              = my_levels_psi_0

  plot_psi_b = gsn_csm_contour(wks,psiplot(:,::-1,0),res2)
  plot_rh_b  = gsn_csm_contour(wks,rhplot(::-1,::-1,0),res)
  overlay(plot_rh_b,plot_psi_b)

  plot(2) = plot_rh_b

; set up vertical axis limits
 res2@cnInfoLabelOn            = False
 res2@txFontHeightF     = 0.015
 res2@tiYAxisFontHeightF= 0.02
 res2@tmYLLabelFontHeightF = 0.018
 res2@gsnCenterString     = "P25"
 res2@vpWidthF          = relwidth ; vpWidth and Height control box size
 res2@vpHeightF         = relheight ; default for both is 0.6 in NDC units
 res2@cnFillOn                 = True 
 res2@cnLinesOn                = False
 res2@cnLevelSelectionMode = "ExplicitLevels" ; or "ManualLevels"
 res2@trYReverse               = True     ; reverse the y-axis
 res2@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
 res2@cnLineLabelInterval  = 0                   ; label every other line
 res2@lbLabelBarOn      = False

; these commands turn off/on the varname and units at top of image
 res2@gsnLeftString = ""
 res2@gsnRightString = ""
 res2@trYMaxF      = 100000
 res2@trYMinF      = 10000
 res2@trXMinF      = 2
 res2@tmXBMode     = "Explicit"
 res2@tmXBValues   = (/2,1000,2000,3000,4000/)
 res2@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
 res2@tmYLMode     = "Explicit"
 res2@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 res2@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 res2@tiXAxisString     = "km"
 res2@tiYAxisString     = "Pressure (hPa) "

  res2@cnLevels            = my_cond_levels
  res2@cnFillColors        = my_cond_colors
  plot_cond_2 = gsn_csm_contour(wks,condplot(:,::-1,ensind),res2)
  res2@tiYAxisString     = " "
  res2@tmYLLabels    = (/" "," "," "," "," "," "/)
  plot_cond_1 = gsn_csm_contour(wks,condplot(:,::-1,1),res2)
  plot_cond_0 = gsn_csm_contour(wks,condplot(:,::-1,0),res2)
  plot(3) = plot_cond_2
  plot(4) = plot_cond_1
  plot(5) = plot_cond_0

end if
end if

resP                         = True
resP@txString                = mainTitle
resP@gsnPanelLabelBar        = True
resP@lbLabelFontHeightF      = 0.017

gsn_panel(wks,plot,(/2,3/),resP)

print("figurenumber is: "+figurenumber)

end
