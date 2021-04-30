; load necessary libraries
; psi_rh_cond_6pan.ncl

  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-----------------------------------
; define parameters for script:
  figurenumber = 1 ; 1 is defualt for crm resolution, 2 or greater is for gcm res
  crm_grid = 1 ; 1 for 1km, 2 for 2km
  ensind=2 ; should correspond to control run for 25km grid-spacing ; 2 is ctl, 1 is lwoff
  center25string="P25"
  expstring="ctl" ; lwoff or ctl
;  expstring="lwoff" ; lwoff or ctl
; for ensind
; 0: noconv
; 1: lwoff
; 2: control
; 3: lwoff noconv
;-----------------------------------
; name of output file
  fileout="rh_psi_cond"
;-----------------------------------
;  expstring="ctl"
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

  field_press  = data_rh_crm->$var3$(:)

  field_psi_1crm = data_psi_crm->$psi_1km$(:,:)
  field_psi_2crm = data_psi_crm->$psi_2km$(:,:)
print("dimsizes for 1km crm psi data are: "+dimsizes(field_psi_1crm))
print("dimsizes for 2km crm psi data are: "+dimsizes(field_psi_2crm))
  field_rh_1crm  = data_rh_crm->$hur_1km$(:,:)
  field_rh_2crm  = data_rh_crm->$hur_2km$(:,:)
  field_cond1  = data_rh_crm->$cond_1km$(:,:) ; the data_rh_crm file contains more than rh
  field_cond2  = data_rh_crm->$cond_2km$(:,:)

; scale condensate to be g/kg instead of kg/kg
  field_cond=1000*field_cond_raw
  field_cond_1crm=1000*field_cond1
  field_cond_2crm=1000*field_cond2
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
  
  ;my_cond_levels = (/0.5,0.4,0.3,0.2,0.1,0.05,0.01, \
  ;                   0.005, 0.001, 0.0005, \
  ;                   0.0001,0.00005,0.00001 /) ; 13
  my_cond_levels = (/0.5,0.4,0.3,0.2,0.1,0.05,0.01, \
                     0.005, 0.001 /) ; 9
  
  ; previous my_cond_colors = (/0,65,60,55,50,45,40,20,15,12,9,6,4,2/);,
  ;my_cond_colors = (/0,98,90,82,74,66,58,50,42,34,26,18,10,2/);
  my_cond_colors = (/0,129,100,78,67, \
                    56,45,12,7,2/); need 10


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
  my_levels_psi_25 = (/-35*scale_cons,-29*scale_cons, -23*scale_cons, -17*scale_cons, \
                      -11*scale_cons, \
                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons /)
;  my_levels_psi_25 = (/-20*scale_cons,-14*scale_cons, -8*scale_cons, -2*scale_cons, \
;                      4*scale_cons, \
;                      10*scale_cons, 16*scale_cons, 22*scale_cons, 28*scale_cons, \
;                     34*scale_cons,   40*scale_cons,   46*scale_cons,  52*scale_cons /)
end if
end if

  my_levels1_crm = (/1,3,5,7,9, \
                 11,13,15,17,19, \
                 21,23,25,27,29, \
                 31,33,35,37,39, \
                 41,43 /) ; 22
  
  my_colors1 = (/225,209,193, \
                 177,129,97, \
                 81,65,49,33/) ;10 
  
  my_col_psi = (/11,15,18,23,31,\
                 39,47,\
                 55,71,\
                 79,87,91/) ;10 

;----------------------------
; set up the x dimension for each of the grids
; the vertical p dimension is the same for all grids

  rhplot1=field_rh_1crm
  rhplot2=field_rh_2crm
  psiplot1=field_psi_1crm
  psiplot2=field_psi_2crm
  condplot1=field_cond_1crm
  condplot2=field_cond_2crm

  hor_x_1km=ispan(1,4000,1)
  hor_x_2km=ispan(2,4000,2)
  hor_x=ispan(25,4000,25)

print("dimsizes of hor_x are: "+dimsizes(hor_x_1km))
print("dimsizes of rhplot are: "+dimsizes(rhplot1))
print("dimsizes of psiplot are: "+dimsizes(psiplot1))

; for the 25km grid
  rhplot=field_rh
  psiplot=field_psi
  condplot=field_cond

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
  rhplot2!1="xdim"
  rhplot2&xdim=hor_x_2km

  psiplot2!0="plev"
  psiplot2&plev=field_press
  psiplot2!1="xdim"
  psiplot2&xdim=hor_x_2km

  condplot2!0="plev"
  condplot2&plev=field_press
  condplot2!1="xdim"
  condplot2&xdim=hor_x_2km

; for the 1km grid
  rhplot1!0="plev"
  rhplot1&plev=field_press
  rhplot1!1="xdim"
  rhplot1&xdim=hor_x_1km

  psiplot1!0="plev"
  psiplot1&plev=field_press
  psiplot1!1="xdim"
  psiplot1&xdim=hor_x_1km

  condplot1!0="plev"
  condplot1&plev=field_press
  condplot1!1="xdim"
  condplot1&xdim=hor_x_1km

;----------------------------
    ;relwidth = 0.6  ; 0.6 and 0.37 result in golden ratio
    ;relheight= 0.37
    relwidth = 0.22  ; 0.6 and 0.37 result in golden ratio
    relheight= 0.17

;; start default plots----------------------------------------------------------
;  plot = new(6,graphic)
  plot_u = new(3,graphic)
  plot_b = new(3,graphic)
 
  gsn_define_colormap(wks,"amwg256")

; create resource for plot
  res = True     
  res2 = True     
  res3 = True     
 
  res@gsnDraw          = False
  res@gsnFrame         = False

  res@vpWidthF          = relwidth ; vpWidth and Height control box size
  res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  res2@vpWidthF          = relwidth ; vpWidth and Height control box size
  res2@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  res3@vpWidthF          = relwidth ; vpWidth and Height control box size
  res3@vpHeightF         = relheight ; default for both is 0.6 in NDC units

; these values indicate the positioning of the figures 
  figtop=0.90
  figbot=0.67
  figl  =0.10
  figm  =0.35
  figr  =0.60

; set up vertical axis limits
  res@cnInfoLabelOn            = False

txFontSize  = 0.011  ; was 0.015
tiYFontSize = 0.012   ; sets the font height in NDC coordinates for the Y-Axis title
tmYFontSize = 0.010  ; sets the height of the Y-Axis labels in NDC coordinates

  res@txFontHeightF      = txFontSize
  res2@txFontHeightF     = txFontSize
  res3@txFontHeightF     = txFontSize

  res@tiYAxisFontHeightF    = tiYFontSize
  res@tmYLLabelFontHeightF  = tmYFontSize
  res2@tiYAxisFontHeightF   = tiYFontSize
  res2@tmYLLabelFontHeightF = tmYFontSize
  res3@tiYAxisFontHeightF   = tiYFontSize
  res3@tmYLLabelFontHeightF = tmYFontSize

  res@gsnCenterString     = center25string
  res@cnFillOn                 = True 
 ; res@cnFillMode               = "RasterFill"       ; Raster Mode
  res@cnLinesOn                = False
  res@cnLevelSelectionMode = "ExplicitLevels" ; or "ManualLevels"
  res@cnLevels            = my_levels1
  res@cnFillColors        = my_colors1
  res@trYReverse               = True     ; reverse the y-axis
  res@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
  res@cnLineLabelInterval  = 0                   ; label every other line
;  res@lbLabelBarOn      = False

  ; these commands turn off/on the varname and units at top of image
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@trYMaxF      = 100000
  res@trYMinF      = 10000
  res@trXMinF      = 2
  res@tmXBMode     = "Explicit"
  res@tmXBValues   = (/2,1000,2000,3000,4000/)
  res@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
  res@tmYLMode     = "Explicit"
  res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
  res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
  res@tiXAxisString     = " "
  res@tiYAxisString     = "Pressure (hPa) "
 
  res2@gsnDraw               = False
  res2@gsnFrame              = False
  ;res2@cnLevels              = my_levels_psi_0
  res2@cnInfoLabelOn         = False
  res2@cnLevelSelectionMode = "ExplicitLevels"
  res2@cnMonoLineDashPattern = False
  if (figurenumber .lt. 2) then
    res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
  else
    ;res2@cnLineDashPatterns = (/2,2,2,2,2,0,0,0,0,0,0,0/) ; use to plot ensind = 0
    res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/) ; use to plot ensind = 1
  end if
  res2@cnLinesOn             = True
  res2@cnLineLabelsOn        = False
  res2@cnLineThicknessF      = 2 ; was 3
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
;  res2@lbLabelBarOn      = False
; these commands turn off/on the varname and units at top of image
  res2@gsnLeftString = ""
  res2@gsnRightString = ""
  res2@tiXAxisString     = " "
  res2@tiYAxisString     = "height "

  ; res2@cnLevels              = my_levels_psi_25_lwoff
  res@vpXF          = figl
  res@vpYF          = figtop
  res2@vpXF         = figl
  res2@vpYF         = figtop

  res@lbBoxLinesOn            = True
  res@lbOrientation           = "Vertical"
  res@lbTitleString           = "%"
  res@lbTitlePosition         = "Bottom"
  res@lbLabelFontHeightF      = 0.013
  res@lbTitleFontHeightF      = 0.013

  res3@lbBoxLinesOn            = True
  res3@lbTitleString           = "g/kg"
  res3@lbTitleFontHeightF      = 0.013
  res3@lbTitlePosition         = "Bottom"
  res3@lbOrientation           = "Vertical"
  res3@lbLabelFontHeightF      = 0.01

  if (figurenumber .lt. 2) then
    titstring=" 1 or 2 km"
    mainTitle = " "  
  
print("max/min of psiplot ensind  is: "+max(psiplot(:,:,ensind))+" and: "+min(psiplot(:,:,ensind)))
print("max/min of psiplot1 is: "+max(psiplot1(:,:))+" and: "+min(psiplot1(:,:)))
print("max/min of psiplot2 is: "+max(psiplot2(:,:))+" and: "+min(psiplot2(:,:)))

    res@trXMinF      = 25
    res2@trXMinF      = 25
    res@gsnCenterString     = center25string
    res2@cnLevels              = my_levels_psi_25
;    ; res2@cnLevels              = my_levels_psi_25_lwoff
;    res@vpXF          = figl
;    res@vpYF          = figtop
;    res2@vpXF         = figl
;    res2@vpYF         = figtop
;
;    res@lbBoxLinesOn            = True
;    res@lbOrientation           = "Vertical"
;    res@lbTitleString           = "%"
;    res@lbTitlePosition         = "Bottom"
;    res@lbLabelFontHeightF      = 0.013
;    res@lbTitleFontHeightF      = 0.013

    res@lbLabelBarOn      = False

    plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
    plot_rh_a = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)

    overlay(plot_rh_a,plot_psi)

    plot_u(0) = plot_rh_a

    res@gsnCenterString     = "E1 "
    res@trXMinF      = 1
    res2@trXMinF      = 1
    res@tiYAxisString     = " "
    res@tmYLLabels    = (/" "," "," "," "," "," "/)
 
    res@lbLabelBarOn      = True
    res@vpXF         = figr
    res@vpYF         = figtop

    plot_rh_2 = gsn_csm_contour(wks,rhplot1(:,:),res)

    res@gsnCenterString     = "E2 "
    res@trXMinF      = 2
    
    res@lbLabelBarOn      = False
    res@vpXF         = figm
    res@vpYF         = figtop
 
    plot_rh_3 = gsn_csm_contour(wks,rhplot2(:,:),res)

    res2@trXMinF      = 2
    res2@cnLevels              = my_levels_psi_1
   

    res@lbLabelBarOn      = True
    res2@vpXF         = figr
    res2@vpYF         = figtop
    plot_psi_2 = gsn_csm_contour(wks,psiplot1(:,:),res2)

    overlay(plot_rh_2,plot_psi_2)

    res@lbLabelBarOn      = False
    res2@vpXF         = figm
    res2@vpYF         = figtop
    res2@cnLevels              = my_levels_psi_2
    plot_psi_3 = gsn_csm_contour(wks,psiplot2(:,:),res2)

    overlay(plot_rh_3,plot_psi_3)
    
    plot_u(1) = plot_rh_3
    plot_u(2) = plot_rh_2

    ; now plot the lower 3 panels with total condensate
    ; set up vertical axis limits

    res3@gsnDraw               = False
    res3@gsnFrame              = False
    res3@cnInfoLabelOn            = False
    ;res3@tmYLLabelFontHeightF = 0.02
    ;res3@tiYAxisFontHeightF= 0.02
    res3@gsnCenterString     = center25string
    res3@cnFillOn                 = True 
    res3@cnLinesOn                = False
    res3@cnLevelSelectionMode = "ExplicitLevels" ; or "ManualLevels"
    res3@trYReverse               = True     ; reverse the y-axis
    res3@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
    res3@cnLineLabelInterval  = 0                   ; label every other line
    res3@gsnLeftString = "" ; turn off/on varname and units at top of image
    res3@gsnRightString = ""
    res3@trYMaxF      = 100000
    res3@trYMinF      = 10000
    res3@trXMinF      = 25
    res3@tmXBMode     = "Explicit"
    res3@tmXBValues   = (/2,1000,2000,3000,4000/)
    res3@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
    res3@tmYLMode     = "Explicit"
    res3@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
    res3@tmYLLabels    = (/"1000","800","600","400","200","100"/)
    res3@tiXAxisString     = "km"
    res3@tiYAxisString     = "Pressure (hPa) "
    res3@cnLevels            = my_cond_levels
    res3@cnFillColors        = my_cond_colors

;    res3@lbBoxLinesOn            = True
;    res3@lbTitleString           = "g/kg"
;    res3@lbTitleFontHeightF      = 0.013
;    res3@lbTitlePosition         = "Bottom"
;    res3@lbOrientation           = "Vertical"
;    res3@lbLabelFontHeightF      = 0.01

    res3@lbLabelBarOn      = False
    res3@vpXF         = figl
    res3@vpYF         = figbot
    plot_cond_0 = gsn_csm_contour(wks,condplot(:,::-1,ensind),res3)

    res3@tiYAxisString     = " "
    res3@tmYLLabels    = (/" "," "," "," "," "," "/)

    res3@gsnCenterString     = "E2 "
    res3@trXMinF             = 2
    res3@vpXF         = figm
    res3@vpYF         = figbot
    plot_cond_1 = gsn_csm_contour(wks,condplot2(:,:),res3)
    res3@gsnCenterString     = "E1 "
    res3@trXMinF             = 1
    res3@lbLabelBarOn      = True
    res3@vpXF         = figr
    res3@vpYF         = figbot
    plot_cond_2 = gsn_csm_contour(wks,condplot1(:,:),res3)

    plot_b(0) = plot_cond_0
    plot_b(1) = plot_cond_1
    plot_b(2) = plot_cond_2
    
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

    res2@cnLevels         = my_levels_psi_2

    res@vpXF          = figl
    res@vpYF          = figtop
    res2@vpXF         = figl
    res2@vpYF         = figtop
    res@lbLabelBarOn      = False

    plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
    plot_rh_a = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)
    overlay(plot_rh_a,plot_psi)

    plot_u(0) = plot_rh_a

    res@tiYAxisString     = " "
    res@gsnCenterString     ="P25 LWCRE-off"
    res@tmYLLabels    = (/" "," "," "," "," "," "/)
    
    res2@cnLevels         = my_levels_psi_1

    res@vpXF          = figm
    res@vpYF          = figtop
    res2@vpXF         = figm
    res2@vpYF         = figtop
    res@lbLabelBarOn      = False

    plot_psi_b = gsn_csm_contour(wks,psiplot(:,::-1,1),res2)
    plot_rh_b  = gsn_csm_contour(wks,rhplot(::-1,::-1,1),res)
    overlay(plot_rh_b,plot_psi_b)

    plot_u(1) = plot_rh_b

    res@tiYAxisString     = " "
    res@gsnCenterString     = "E25 LWCRE-on, Conv-off"
    res@tmYLLabels    = (/" "," "," "," "," "," "/)
    res2@cnLevels              = my_levels_psi_0

    res@vpXF         = figr
    res@vpYF         = figtop
    res2@vpXF         = figr
    res2@vpYF         = figtop
    res@lbLabelBarOn      = True

    plot_psi_b = gsn_csm_contour(wks,psiplot(:,::-1,0),res2)
    plot_rh_b  = gsn_csm_contour(wks,rhplot(::-1,::-1,0),res)
    overlay(plot_rh_b,plot_psi_b)

    plot_u(2) = plot_rh_b

    ; set up vertical axis limits
    res3@gsnDraw               = False
    res3@gsnFrame              = False
    res3@cnInfoLabelOn            = False
    res3@gsnCenterString     = center25string
    res3@cnFillOn                 = True 
    res3@cnLinesOn                = False
    res3@cnLevelSelectionMode = "ExplicitLevels" ; or "ManualLevels"
    res3@trYReverse               = True     ; reverse the y-axis
    res3@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
    res3@cnLineLabelInterval  = 0                   ; label every other line
;    res3@lbLabelBarOn      = False
    res3@gsnLeftString = "" ; turn off/on varname and units at top of image
    res3@gsnRightString = ""
    res3@trYMaxF      = 100000
    res3@trYMinF      = 10000
    res3@trXMinF      = 25
    res3@tmXBMode     = "Explicit"
    res3@tmXBValues   = (/2,1000,2000,3000,4000/)
    res3@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
    res3@tmYLMode     = "Explicit"
    res3@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
    res3@tmYLLabels    = (/"1000","800","600","400","200","100"/)
    res3@tiXAxisString     = "km"
    res3@tiYAxisString     = "Pressure (hPa) "
    res3@cnLevels            = my_cond_levels
    res3@cnFillColors        = my_cond_colors

    res3@vpXF         = figl
    res3@vpYF         = figbot
    res3@lbLabelBarOn      = False
    plot_cond_2 = gsn_csm_contour(wks,condplot(:,::-1,ensind),res3)

    res3@tiYAxisString     = " "
    res3@tmYLLabels    = (/" "," "," "," "," "," "/)

    res3@gsnCenterString     = " "+center25string+" LWCRE-off"
    res3@vpXF         = figm
    res3@vpYF         = figbot
    res3@lbLabelBarOn      = False
    plot_cond_1 = gsn_csm_contour(wks,condplot(:,::-1,1),res3)
    ;res3@gsnCenterString     = " "+center25string+" LWCRE-on, Conv-off"
    res3@gsnCenterString     = " "+"E25 LWCRE-on, Conv-off"
    res3@lbLabelBarOn      = True
    res3@vpXF         = figr
    res3@vpYF         = figbot
    plot_cond_0 = gsn_csm_contour(wks,condplot(:,::-1,0),res3)

    plot_b(0) = plot_cond_2

    plot_b(1) = plot_cond_1

    plot_b(2) = plot_cond_0
    end if
  end if

;  resT                         = True
;  resT@gsnFrame                = False
;  resT@gsnPanelTop             = 0.90
;  resT@gsnPanelBottom          = 0.45
;  resT@txString                = mainTitle
;  resT@lbBoxLinesOn            = True
;  resT@lbTitleString           = " % "
;  resT@lbTitlePosition         = "Right"
;  resT@gsnPanelLabelBar        = True
;  resT@lbOrientation           = "Vertical"
;  resT@lbLabelFontHeightF      = 0.013
;  
;  resB                         = True
;  resB@gsnFrame                = False
;  resB@gsnPanelTop             = 0.82
;  ;resB@lbLabelAngleF        = 90
;  ;resB@gsnPanelBottom          = 0.45
;  ;resB@txString                = mainTitle
;  resB@lbTitleString           = " g/kg "
;  resB@lbTitlePosition         = "Right"
;  resB@gsnPanelLabelBar        = True
;  resB@lbOrientation           = "Vertical"
;  resB@lbLabelFontHeightF      = 0.01
;
;  resT@gsnPanelDebug         = True
;  resB@gsnPanelDebug         = True

;  gsn_panel(wks,plot_u,(/1,3/),resT)
;  gsn_panel(wks,plot_b,(/1,3/),resB)
 
; if gsn_panel is not being used...
psres  = True
maximize_output(wks,psres) 
 
 
print("figurenumber is: "+figurenumber)

end
