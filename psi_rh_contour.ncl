; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-----------------------------------
; define parameters for script:
figurenumber = 1 ; 1 is defualt for crm resolution, 2 or greater is for gcm res
crm_grid = 2 ; 1 for 1km, 2 for 2km
ensind=2
expstring="ctl" ; lwoff or ctl
;-----------------------------------
; name of output file
fileout="myrh"
;-----------------------------------
;  expstring="lwoff"
;if (figurenumber .lt. 2) then
;  expstring="lwoff"
;  ;expstring="ctl"
;end if
if (crm_grid .lt. 2) then
  titstring=" 1 km "
  var4="psi_1km"
  var5="hur_1km"
else
  titstring=" 2 km"
  var4="psi_2km"
  var5="hur_2km"
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
;var4="psi_1km"
;var5="hur_1km"
;;var4="psi_2km"
;;var5="hur_2km"

field_rh  = data_rh->$var1$(:,:,:)
field_psi = data_psi->$var2$(:,:,:)

field_press  = data_rh_crm->$var3$(:)

field_psi_crm = data_psi_crm->$var4$(:,:)
  print("dimsizes for crm psi data are: "+dimsizes(field_psi_crm))
field_rh_crm  = data_rh_crm->$var5$(:,:)

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

my_levels1 = (/10,15,20, \
               25,30,35,40,45, \
               50,55,60,65,70, \
               75,80,85,90,95 /) ; 18


;my_levels_psi = (/-5000,-4000,-3000,-2000,-1000,0, \
;                   1000, 2000,3000,4000,5000  /) ; 9
;my_levels_psi = (/-5500,-4500,-3500,-2500,-1500,-500, \
;                   500, 1500, 2500,3500,4500,5500  /) ; 9
;my_levels_psi = (/-55*scale_cons,-45*scale_cons,-35*scale_cons,-25*scale_cons,-15*scale_cons,-5*scale_cons, \
;                   5*scale_cons, 15*scale_cons, 25*scale_cons,35*scale_cons,45*scale_cons,55*scale_cons  /) ; 9

if (figurenumber .ge. 2) then
  scale_cons=1.e-2
  ;my_levels_psi = (/-55*scale_cons,-45*scale_cons,-35*scale_cons,-25*scale_cons,-15*scale_cons,-5*scale_cons, \
  ;                   5*scale_cons, 15*scale_cons, 25*scale_cons,35*scale_cons,45*scale_cons,55*scale_cons  /) ; 9
; use levels below to plot ensind = 0
;  my_levels_psi = (/-30*scale_cons,-25*scale_cons,-20*scale_cons,-15*scale_cons,-10*scale_cons,-5*scale_cons, \
;                     0*scale_cons, 5*scale_cons, 10*scale_cons, 15*scale_cons,20*scale_cons,25*scale_cons,30*scale_cons  /) ; 9
; try the levels below for ensind = 2
  my_levels_psi = (/-65*scale_cons, -60*scale_cons, -55*scale_cons, -50*scale_cons, \
                    -45*scale_cons, -40*scale_cons, -35*scale_cons, -30*scale_cons, \
                    -25*scale_cons, -20*scale_cons, -15*scale_cons, -10*scale_cons, \
                     -5*scale_cons,   0*scale_cons,   5*scale_cons,  10*scale_cons, \
                     15*scale_cons,  20*scale_cons,  25*scale_cons/) 
;;  my_levels_psi = (/-65*scale_cons,  -55*scale_cons, \
;;                    -45*scale_cons, -35*scale_cons, \
;;                    -25*scale_cons, -15*scale_cons, \
;;                     -5*scale_cons,  5*scale_cons, \
;;                     15*scale_cons, 25*scale_cons/) 
;; try the levels below for ensind = 3
;  my_levels_psi = (/-45*scale_cons, -40*scale_cons, -35*scale_cons, -30*scale_cons, \
;                    -25*scale_cons, -20*scale_cons, -15*scale_cons, -10*scale_cons, \
;                     -5*scale_cons,   0*scale_cons,   5*scale_cons,  10*scale_cons, \
;                     15*scale_cons,  20*scale_cons,  25*scale_cons,  30*scale_cons, \
;                     35*scale_cons/) 
else
if (figurenumber .lt. 2) then
  scale_cons=1.e-2
  ;scale_cons=1.e11
  my_levels_psi = (/-40*scale_cons,-35*scale_cons,-30*scale_cons,-25*scale_cons, \
                    -20*scale_cons,-15*scale_cons,-10*scale_cons,-5*scale_cons, \
                    -1*scale_cons,1*scale_cons, \
                     5*scale_cons, 10*scale_cons, 15*scale_cons,20*scale_cons, \
                     25*scale_cons,30*scale_cons,35*scale_cons,40*scale_cons  /) ; 
  ;;my_levels_psi=scale_cons*my_levels_psi
end if
end if

print("my_levels_psi: "+my_levels_psi)

my_levels1_crm = (/1,3,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,37,39, \
               41,43 /) ; 22

;my_colors1 = (/2,14,20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,128/)
;my_colors1 = (/4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23/) ; gui_defaul

;my_colors1 = (/11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99/) ; 23
my_colors1 = (/2,4,8,12,16, \
               20,40,44,48,54,\
               60,66,72,78,100,\
               110,116,122,128/) ;19 

;my_colors1 = (/6,12,18,24,30,\
;               48,54,60,66,72,\
;               80,86,92,98,104,\
;               110,116,122,128/) ;19 

my_col_psi = (/11,15,18,23,31,\
               39,47,\
               55,71,\
               79,87,91/) ;10 

;gsn_define_colormap(wks,"BlAqGrYeOrRe")


;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"NCV_blu_red")
gsn_define_colormap(wks,"MPL_coolwarm")
;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"BlAqGrYeOrRe")

; previously used default
;gsn_define_colormap(wks,"MPL_PuBuGn")

;; start default plots----------------------------------------------------------
 plot = new(1,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
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
 res@vpWidthF          = 2.0 ; vpWidth and Height control box size
 res@vpHeightF         = 2. ; default for both is 0.6 in NDC units
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
; res@tmXBValues   = (/0,1000,2000,3000,4000/)
; res@tmXBLabels   = ""+res@tmXBValues
 res@tmYLMode     = "Explicit"
 res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 ;res@tmYLValues   = (/100,200,400,600,800,1000/) res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 ;res@tmYLLabels   = ""+res@tmYLValues
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "Pressure (hPa) "

;;rhplot=field_rh
;;psiplot=field_psi
;;hor_x=ispan(25,4000,25)
;
;rhplot!0="plev"
;rhplot&plev=field_press
;psiplot!0="plev"
;psiplot&plev=field_press
;rhplot!1="xdim"
;rhplot&xdim=hor_x
;psiplot!1="xdim"
;psiplot&xdim=hor_x

 ;plot_rh = gsn_csm_contour(wks,rhplot(:,:,ensind),res)
 ;plot_rh = gsn_csm_contour(wks,rhplot(:,:),res)
 ;plot_rh = gsn_csm_contour(wks,rhplot(:,::-1,ensind),res)
 ;plot_rh = gsn_csm_contour(wks,rhplot(:,::-1),res)
 
 res2 = True     
 res2@gsnDraw               = False
 res2@gsnFrame              = False
 res2@cnLevels              = my_levels_psi
 res2@cnInfoLabelOn         = False
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnMonoLineDashPattern = False
if (figurenumber .lt. 2) then
 res2@cnLineDashPatterns = (/2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0/)
else
 ;res2@cnLineDashPatterns = (/2,2,2,2,2,0,0,0,0,0,0,0/) ; use to plot ensind = 0
 ;res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0/) ; use to plot ensind = 1
 res2@cnLineDashPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/) ; use to plot ensind = 1
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
 ;;res2@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 ;;res2@tmYLValues   = (/10000,20000,40000,60000,80000,100000/)
 ;;res2@tmYLLabels   = ""+res2@tmYLValues
 res2@vpWidthF          = 2.0 ; vpWidth and Height control box size
 res2@vpHeightF         = 2. ; default for both is 0.6 in NDC units
 res2@lbLabelBarOn      = False
; these commands turn off/on the varname and units at top of image
 res2@gsnLeftString = ""
 res2@gsnRightString = ""
 res2@tiXAxisString     = " "
 res2@tiYAxisString     = "height "
 
if (figurenumber .lt. 2) then

  mainTitle="Months 2-6:"+titstring+" "+expstring
  
  rhplot=field_rh_crm
  psiplot=field_psi_crm
  if (crm_grid .lt. 2) then
    hor_x=ispan(1,4000,1)
  else
    hor_x=ispan(2,4000,2)
  end if
  print("dimsizes of hor_x are: "+dimsizes(hor_x))
  print("dimsizes of rhplot are: "+dimsizes(rhplot))
  print("dimsizes of psiplot are: "+dimsizes(psiplot))
  
  rhplot!0="plev"
  rhplot&plev=field_press
  psiplot!0="plev"
  psiplot&plev=field_press
  rhplot!1="xdim"
  rhplot&xdim=hor_x
  psiplot!1="xdim"
  psiplot&xdim=hor_x
  
  ;print("values from psi are: "+psiplot(12,2000))
  plot_rh = gsn_csm_contour(wks,rhplot(:,:),res)
  plot_psi = gsn_csm_contour(wks,psiplot(:,:),res2)
  ;plot_psi = gsn_csm_contour(wks,psiplot(:,::-1),res2)
  
  overlay(plot_rh,plot_psi)
  plot(0) = plot_rh

else ;--------------------------------------------------------------------------
if (figurenumber .ge. 2) then

  mainTitle="GCM resolution"

  res@trXMinF       = 25
  res2@trXMinF      = 25


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

print("dimsizes of hor_x are: "+dimsizes(hor_x))
print("dimsizes of rhplot are: "+dimsizes(rhplot))
print("dimsizes of psiplot are: "+dimsizes(psiplot))
print("max of psiplot is: "+max(psiplot(:,:,ensind))+" and min is: "+min(psiplot(:,:,ensind)))
print("values from psi are: "+psiplot(12,80,ensind))
  ;plot_rh = gsn_csm_contour(wks,rhplot(:,:,ensind),res)
  plot_rh = gsn_csm_contour(wks,rhplot(::-1,::-1,ensind),res)
  ;plot_psi = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)
  plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
  overlay(plot_rh,plot_psi)
  plot(0) = plot_rh
  ;plot(0) = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)
  ;plot(0) = gsn_csm_contour(wks,rhplot(:,:,ensind),res)
;  gsn_panel(wks,plot,(/1,1/),resP)
end if
end if

resP                         = True
resP@txString                = mainTitle
resP@gsnPanelLabelBar        = True
;resP@vpWidthF          = 2.0 ; vpWidth and Height control box size
;resP@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units
;resP@lbLabelFontHeightF      = 0.012
resP@lbLabelFontHeightF      = 0.022

gsn_panel(wks,plot,(/1,1/),resP)

print("figurenumber is: "+figurenumber)

end
