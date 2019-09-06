; load necessary libraries
; psi_rh_contour_3pan.ncl

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-----------------------------------
; define parameters for script:
figurenumber = 2 ; 1 is defualt for crm resolution, 2 or greater is for gcm res
crm_grid = 1 ; 1 for 1km, 2 for 2km
ensind=2
expstring="ctl" ; lwoff or ctl
;-----------------------------------
; name of output file
fileout="rh_psi"
;-----------------------------------
;  expstring="lwoff"
if (figurenumber .lt. 2) then
  ;expstring="lwoff"
  expstring="ctl"
end if
;if (crm_grid .lt. 2) then
;  titstring=" 1 km "
;  psi_1km="psi_1km"
;  var5="hur_1km"
;else
;  titstring=" 2 km"
;  var4="psi_2km"
;  var5="hur_2km"
;end if

;-----------------------------------
; path to data
path_to_wc="/Users/silvers/data"
walkcell="/WalkerCell/gauss_d"
;file_pre="/c96L33_8x80_nh.19790101"
file_pre="/19790101"
file_pre_b="/19800101"
file_pre_c="/19810101"
file_pre_d="/19820101"

; for gcm

in_rh=path_to_wc+walkcell+"/mymy_rh.nc"
;in_rh=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_rh.nc"
;in_psi=path_to_wc+walkcell+"/mymy_psi.nc"
in_psi=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_psi_ent0p9.nc"
in_rh=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_clouds_ctl.nc"
  print("incoming gcm file is: "+in_rh)
  print("incoming gcm file is: "+in_psi)
; for crm
;in_rh_crm=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_rh_crm.nc"
;in_psi_crm=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_psi_crm.nc"
;in_rh_crm=path_to_wc+walkcell+"/c50x2000L33_am4p0_2km_wlkr_4K/mymy_crm_tmn.nc"
;in_psi_crm=path_to_wc+walkcell+"/c50x2000L33_am4p0_2km_wlkr_4K/mymy_crm_tmn.nc"

; these files contain data from both 1km and 2km experiments even though they are in 
; the directory for the 1km experiment
;in_rh_crm=path_to_wc+walkcell+"/c10x4000L33_am4p0_1km_wlkr_4K/mymy_crm_tmn.nc"
;in_psi_crm=path_to_wc+walkcell+"/c10x4000L33_am4p0_1km_wlkr_4K/mymy_crm_tmn.nc"
in_rh_crm=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_"+expstring+"_tmn.nc"
in_psi_crm=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_"+expstring+"_tmn.nc"
  print("incoming crm file is: "+in_rh_crm)
  print("incoming crm file is: "+in_psi_crm)

data_rh=addfile(in_rh,"r")
data_psi=addfile(in_psi,"r")
data_rh_crm=addfile(in_rh_crm,"r")
data_psi_crm=addfile(in_psi_crm,"r")

var1="myrh" ; time, grid_y, grid_x
var2="mystream"
var3="pfull"
;;var4="psi_crm"
;;var5="rh_crm"
psi_1km="psi_1km"
hur_1km="hur_1km"
psi_2km="psi_2km"
hur_2km="hur_2km"

field_rh  = data_rh->$var1$(:,:,:)
field_psi = data_psi->$var2$(:,:,:)

field_press  = data_rh_crm->$var3$(:)

field_psi_1crm = data_psi_crm->$psi_1km$(:,:)
field_psi_2crm = data_psi_crm->$psi_2km$(:,:)
  print("dimsizes for 1km crm psi data are: "+dimsizes(field_psi_1crm))
  print("dimsizes for 2km crm psi data are: "+dimsizes(field_psi_2crm))
field_rh_1crm  = data_rh_crm->$hur_1km$(:,:)
field_rh_2crm  = data_rh_crm->$hur_2km$(:,:)

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

;my_levels1 = (/10,15,20, \
;               25,30,35,40,45, \
;               50,55,60,65,70, \
;               75,80,85,90,95 /) ; 18
;

my_levels1 = (/10,20, \
               30,40, \
               50,60,70, \
               80,90/) ; 9


;my_levels_psi = (/-5000,-4000,-3000,-2000,-1000,0, \
;                   1000, 2000,3000,4000,5000  /) ; 9
;my_levels_psi = (/-5500,-4500,-3500,-2500,-1500,-500, \
;                   500, 1500, 2500,3500,4500,5500  /) ; 9
;my_levels_psi = (/-55*scale_cons,-45*scale_cons,-35*scale_cons,-25*scale_cons,-15*scale_cons,-5*scale_cons, \
;                   5*scale_cons, 15*scale_cons, 25*scale_cons,35*scale_cons,45*scale_cons,55*scale_cons  /) ; 9

if (figurenumber .ge. 2) then
  scale_cons=1.e-2
  ;my_levels_psi = (/-55*scale_cons,-45*scale_cons,-35*scale_cons,-25*scale_cons, \
  ;                   -15*scale_cons,-5*scale_cons, 5*scale_cons, 15*scale_cons,   \
  ;                    25*scale_cons,35*scale_cons,45*scale_cons,55*scale_cons  /) ; 9
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
;                     15*scale_cons,  20*scale_cons,  25*scale_cons,  30*scale_cons, \
;                     35*scale_cons, 40*scale_cons, 45*scale_cons, 50*scale_cons /) 
;  my_levels_psi_0 = (/-50*scale_cons,-45*scale_cons, -40*scale_cons, -35*scale_cons, \
;                      -30*scale_cons, \
;                     -25*scale_cons, -20*scale_cons, -15*scale_cons, -10*scale_cons, \
;                     -5*scale_cons,   0*scale_cons,   5*scale_cons,  10*scale_cons, \
;                     15*scale_cons,  20*scale_cons,  25*scale_cons,  30*scale_cons, \
;                     35*scale_cons, 40*scale_cons, 45*scale_cons, 50*scale_cons /) 
;; try the levels below for ensind = 2
;  my_levels_psi_25 = (/-65*scale_cons,-59*scale_cons, -53*scale_cons, -47*scale_cons, \
;                      -41*scale_cons, \
;                     -35*scale_cons, -29*scale_cons, -23*scale_cons, -17*scale_cons, \
;                     -11*scale_cons,   -5*scale_cons,   1*scale_cons,  7*scale_cons /)
;  my_levels_psi_2 = (/-35*scale_cons,-29*scale_cons, -23*scale_cons, -17*scale_cons, \
;                      -11*scale_cons, \
;                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
;                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons /)
;  my_levels_psi_1 = (/-29*scale_cons, -23*scale_cons, -17*scale_cons, \
;                      -11*scale_cons, \
;                     -5*scale_cons, 1*scale_cons, 7*scale_cons, 13*scale_cons, \
;                     19*scale_cons,   25*scale_cons,   31*scale_cons,  37*scale_cons, \
;                     43*scale_cons /)
;  my_levels_psi = (/-65*scale_cons, -60*scale_cons, -55*scale_cons, -50*scale_cons, \
;                    -45*scale_cons, -40*scale_cons, -35*scale_cons, -30*scale_cons, \
;                    -25*scale_cons, -20*scale_cons, -15*scale_cons, -10*scale_cons, \
;                     -5*scale_cons,   0*scale_cons,   5*scale_cons,  10*scale_cons, \
;                     15*scale_cons,  20*scale_cons,  25*scale_cons/) 
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

;my_colors1 = (/2,14,20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,128/)

;my_colors1 = (/2,4,8,12,16, \
;               20,40,44,48,54,\
;               60,66,72,78,100,\
;               110,116,122,128/) ;19 

;my_colors1 = (/128,122,116,110, \
;               100,78,72,66,60, \
;               54,48,44,40,20,  \
;               16,12,8,4,2/) ;19 

;my_colors1 = (/88, \
;               72,60, \
;               48,40,32,  \
;               26,18,10,2/) ;19 

;my_colors1 = (/127, \
;               112,97, \
;               82,67,52,  \
;               47,32,17,2/) ;19 

my_colors1 = (/126, \
               112,98, \
               84,70,56,  \
               42,28,14,2/) ;19 

;my_colors1 = (/6,12,18,24,30,\
;               48,54,60,66,72,\
;               80,86,92,98,104,\
;               110,116,122,128/) ;19 

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
  hor_x=ispan(25,4000,25)
  rhplot!0="plev"
  rhplot&plev=field_press
  psiplot!0="plev"
  psiplot&plev=field_press
  rhplot!1="xdim"
  rhplot&xdim=hor_x
  psiplot!1="xdim"
  psiplot&xdim=hor_x

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
 plot = new(3,graphic)

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

;print("dimsizes of hor_x are: "+dimsizes(hor_x))
;print("dimsizes of rhplot are: "+dimsizes(rhplot))
;print("dimsizes of psiplot are: "+dimsizes(psiplot))
;ensind=1 ; lwoff
ensind=2 ; control, convection on, lwon
;ensind=3 ; lwoff noconv
print("max/min of psiplot ensind  is: "+max(psiplot(:,:,ensind))+" and: "+min(psiplot(:,:,ensind)))
print("max/min of psiplot1 is: "+max(psiplot1(:,:))+" and: "+min(psiplot1(:,:)))
print("max/min of psiplot2 is: "+max(psiplot2(:,:))+" and: "+min(psiplot2(:,:)))

 
 res@trXMinF      = 25
 res2@trXMinF      = 25
 res@gsnCenterString     = "P25 "
; testing 
 res2@cnLevels              = my_levels_psi_25
; res2@cnLevels              = my_levels_psi_25_lwoff
  plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
  plot_rh_a = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)
  overlay(plot_rh_a,plot_psi)

  plot(0) = plot_rh_a

  ;print("values from psi are: "+psiplot(12,2000))
 ;res@gsnCenterString     = "P25 eventually"
;  plot_rh = gsn_csm_contour(wks,rhplot1(:,:),res)
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
  ;plot_psi = gsn_csm_contour(wks,psiplot1(:,::-1),res2)
  
  overlay(plot_rh_2,plot_psi_2)
  overlay(plot_rh_3,plot_psi_3)
  ;plot_0 = plot_rh
  ;plot_1 = plot_rh
;  plot(0) = plot_rh
; res@vpXF            =   0.4
; res@vpYF            =   0.55
; res@vpWidthF          = relwidth ; vpWidth and Height control box size
; res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
  plot(1) = plot_rh_3
; res@vpXF            =   0.7
; res@vpYF            =   0.55
; res@vpWidthF          = relwidth ; vpWidth and Height control box size
; res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
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

relwidth = 0.9
relheight= 0.9
 ; res@vpXF            =   0.1
 ; res@vpYF            =   0.75
  res@vpWidthF          = relwidth ; vpWidth and Height control box size
  res@vpHeightF         = relheight ; default for both is 0.6 in NDC units
 ; res2@vpXF            =   0.1
 ; res2@vpYF            =   0.75
 ; res2@vpWidthF          = 0.3 ; vpWidth and Height control box size
 ; res2@vpHeightF         = 0.3 ; default for both is 0.6 in NDC units
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

  ;plot_rh_b = gsn_csm_contour(wks,rhplot(::-1,::-1,0),res)
  res2@cnLevels              = my_levels_psi_0
  plot_psi_b = gsn_csm_contour(wks,psiplot(:,::-1,0),res2)
  plot_rh_b  = gsn_csm_contour(wks,rhplot(::-1,::-1,0),res)
  overlay(plot_rh_b,plot_psi_b)

  plot(2) = plot_rh_b

end if
end if

resP                         = True
resP@txString                = mainTitle
resP@gsnPanelLabelBar        = True
resP@lbLabelFontHeightF      = 0.017

gsn_panel(wks,plot,(/1,3/),resP)

;maximize_output(wks,resP)

print("figurenumber is: "+figurenumber)

end
