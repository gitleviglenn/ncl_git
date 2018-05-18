; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; path to data
path_to_wc="/Users/silvers/data"
walkcell="/WalkerCell/gauss_d"
file_pre="/19790101"

; name of output file
fileout="mycloud"

; for gcm
in_cloud=path_to_wc+walkcell+"/mymy_clouds.nc"
in_psi=path_to_wc+walkcell+"/mymy_psi.nc"
  print("incoming file is: "+in_cloud)
  print("incoming file is: "+in_psi)
; for crm
in_rh_crm=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_rh_crm.nc"
in_cld_crm=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_cl_crm.nc"
in_psi_crm=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_psi_crm.nc"
  print("incoming file is: "+in_rh_crm)
  print("incoming file is: "+in_psi_crm)

data_cloud=addfile(in_cloud,"r")
data_psi=addfile(in_psi,"r")
data_rh_crm=addfile(in_rh_crm,"r")
data_cld_crm=addfile(in_cld_crm,"r")
data_psi_crm=addfile(in_psi_crm,"r")

var1="myclouds" ; time, grid_y, grid_x
var2="mystream"
var3="pfull"
var4="psi_crm"
var5="rh_crm"
var6="cl_crm"

field_cloud  = data_cloud->$var1$(:,:,:)
field_psi = data_psi->$var2$(:,:,:)

field_press  = data_rh_crm->$var3$(:)

field_psi_crm = data_psi_crm->$var4$(:,:)
field_rh_crm  = data_rh_crm->$var5$(:,:)
field_cld_crm  = data_cld_crm->$var6$(:,:)

;
  print("dimsizes of field cloud are: "+dimsizes(field_cloud))
  print("max is: ="+max(field_cloud))
  print("---------------------------------------------")
  print("dimsizes of field clodu are: "+dimsizes(field_cloud))
  print("---------------------------------------------")


plot_type="newPDF"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/2,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,38 /) ; 18

;my_levels_psi = (/-5000,-4000,-3000,-2000,-1000,0, \
;                   1000, 2000,3000,4000,5000  /) ; 9
my_levels_psi = (/-5500,-4500,-3500,-2500,-1500,-500, \
                   500, 1500, 2500,3500,4500,5500  /) ; 9

my_levels1_crm = (/1,3,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,37,39, \
               41,43 /) ; 22

;my_colors1 = (/2,14,20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,128/)
;my_colors1 = (/4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23/) ; gui_defaul

;my_colors1 = (/11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99/) ; 23
;my_colors1 = (/2,4,8,12,16, \
;               20,40,44,48,54,\
;               60,66,72,78,100,\
;               110,116,122,128/) ;19 
my_colors1 = (/111,130,162,167,172, \
               178,184,190,196,202,\
               208,214,220,226,232,\
               238,244,250,255/) ;19 


my_col_psi = (/11,15,18,23,31,\
               39,47,\
               55,71,\
               79,87,91/) ;10 

;gsn_define_colormap(wks,"BlAqGrYeOrRe")

figurenumber = 1 ; 1 is defualt
;; 3 --> 3 month hov of 50x2000
;; 1 --> two panel figure of gcm and crm
;; 2 --> same as 3 
if (figurenumber .lt. 2) then

;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"NCV_blu_red")
;gsn_define_colormap(wks,"MPL_coolwarm")
;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"BlAqGrYeOrRe")
gsn_define_colormap(wks,"amwg256")

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
 ;res@cnLevelSelectionMode = "ManualLevels"
 res@cnLevelSelectionMode = "ExplicitLevels"
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
 res@trXMaxF      = 4000
 res@trXMinF      = 2
 res@tmXBMode     = "Explicit"
 res@tmXBValues   = (/25,1000,2000,3000,4000/)
 ;res2@tmXBLabels   = ""+res2@tmXBValues
 res@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
; res@tmXBMode     = "Explicit"
; res@tmXBValues   = (/0,1000,2000,3000,4000/)
; res@tmXBLabels   = ""+res@tmXBValues
 res@tmYLMode     = "Explicit"
 res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 ;res@tmYLValues   = (/100,200,400,600,800,1000/)
 res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 ;res@tmYLLabels   = ""+res@tmYLValues
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "Pressure (hPa) "

ensind=2
mainTitle="ent0p9"

;; for gcm
;cldplot=field_cloud
;psiplot=field_psi
;hor_x=ispan(25,4000,25)
;print("dimsizes of hor_x are: "+dimsizes(hor_x))

; for crm
cldplot=field_cld_crm
psiplot=field_psi_crm
hor_x=ispan(2,4000,2)
print("dimsizes of hor_x are: "+dimsizes(hor_x))

cldplot!0="plev"
cldplot&plev=field_press
psiplot!0="plev"
psiplot&plev=field_press
cldplot!1="xdim"
cldplot&xdim=hor_x
psiplot!1="xdim"
psiplot&xdim=hor_x

; for gcm
;plot_cld = gsn_csm_contour(wks,cldplot(:,:,ensind),res)

plot_cld = gsn_csm_contour(wks,cldplot(:,:),res)
 
 res2 = True     
 res2@gsnDraw               = False
 res2@gsnFrame              = False
 res2@cnLevels              = my_levels_psi
 res2@cnInfoLabelOn         = False
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnMonoLineDashPattern = False
 res2@cnLineDashPatterns = (/2,2,2,2,2,2,0,0,0,0,0,0/)
 res2@cnLinesOn             = True
 res2@cnLineLabelsOn        = False
 res2@cnLineThicknessF      = 2
 res2@trYReverse            = True     ; reverse the y-axis
 res2@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
 res2@trYMaxF      = 100000
 res2@trYMinF      = 10000
 res2@trXMaxF      = 4000
 res2@trXMinF      = 2
 res2@tmXBMode     = "Explicit"
 res2@tmXBValues   = (/25,1000,2000,3000,4000/)
 ;res2@tmXBLabels   = ""+res2@tmXBValues
 res2@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
 ;res2@tmYLMode     = "Explicit"
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

; for gcm 
;plot_psi = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)
;;plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)

; for crm
plot_psi = gsn_csm_contour(wks,psiplot(:,:),res2)

; use this overlay command if you want the streamfunction overlayed on the 
; cloud fraction
;overlay(plot_rh,plot_psi)

plot(0) = plot_cld
;plot(1) = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)


resP                         = True
;resP@txString                = "good grief"
resP@txString                = mainTitle
resP@gsnPanelLabelBar        = True
;resP@vpWidthF          = 2.0 ; vpWidth and Height control box size
;resP@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units
;resP@lbLabelFontHeightF      = 0.012
resP@lbLabelFontHeightF      = 0.022

gsn_panel(wks,plot,(/1,1/),resP)
;
;else ;--------------------------------------------------------------------------
;if (figurenumber .lt. 4) then
;end if
;if (figurenumber .gt. 4) then
;end if
end if

end
