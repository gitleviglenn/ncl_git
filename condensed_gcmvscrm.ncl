;; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; name of output file
fileout="mycond"

; variable names
;var1="myclouds" ; time, grid_y, grid_x
;var_liq="tot_liq_amt"
;var_ice="tot_ice_amt"
var_gcm="tot_condensed"
;var2="mystream"
var3="pfull"
;var4="psi_crm"
;var5="rh_crm"
;var6="cl_crm"
;var_test="cld_amt"

model_switch=3 ; default=4, 2km crm
; 5 or above : gcm
; 4 : 2km crm 
; 3 : 1km crm

; 0: noconv, 1: lwoff, 2:control lwcre conv, 3:noconv lwoff
ensind=3

exptype="noconv lwoff"
entval="0p9"

;exp_type="/c8x160L33_am4p0_25km_wlkr_ctl"
;exp_type="/c8x160L33_am4p0_25km_wlkr_ctl_lwoff"
;exptyp=""
;exptyp="_p4K"
exptyp="_lwoff"

exp_name="/c8x160L33_am4p0_25km_wlkr_ent"+entval+exptyp

;------------------------------------------------
; path to data
  path_to_wc="/Users/silvers/data"
  walkcell="/WalkerCell/gauss_d"
  file_pre="/19790101"
  
  ;;in_cloud=path_to_wc+walkcell+exp_type+"/mymy_clouds.nc"
  ;;in_cloud_test=path_to_wc+walkcell+"/mymy_clouds.nc"
  ;;in_cloud=path_to_wc+walkcell+"/c8x160L33_am4p0_25km_wlkr_ent0p9"+"/19790101.atmos_month.nc"
  ;in_cloud=path_to_wc+walkcell+exp_name+"/19790101.atmos_month.nc"
  in_cloud=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_clouds_ctl.nc"
  ;in_psi=path_to_wc+walkcell+"/mymy_psi.nc"
print("incoming gcm file is: "+in_cloud)

  if (model_switch .gt. 4) then ; for gcm
print("---------------------------------------------")
print("model_switch ="+model_switch+" plotting gcm data")
print("---------------------------------------------")
    ;cldplot=field_cloud
    ;psiplot=field_psi
    hor_x=ispan(25,4000,25)
print("dimsizes of hor_x are: "+dimsizes(hor_x))
  else if (model_switch .gt. 3) then ; for 2km crm
print("---------------------------------------------")
print("model_sitch ="+model_switch+" plotting 2km crm data")
print("---------------------------------------------")
    in_crm_2km=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_lwoff_tmn.nc"
print("incoming file is: "+in_crm_2km)
;print("incoming file is: "+in_psi_crm)
    var6="tot_condensed_2km"
    hor_x=ispan(2,4000,2)
    print("dimsizes of hor_x are: "+dimsizes(hor_x))
    ;data_rh_crm=addfile(in_rh_crm,"r")
  else if (model_switch .gt. 2) then ; for 1km crm
print("---------------------------------------------")
print("model_sitch ="+model_switch+" plotting 1km crm data")
print("---------------------------------------------")
    ;in_crm_1km=path_to_wc+walkcell+"/c10x4000L33_am4p0_1km_wlkr_4K/mymy_crm_tmn.nc"
    in_crm_1km=path_to_wc+"/WalkerCell/testing_20181203"+"/mymy_crm_lwoff_tmn.nc"
print("model_sitch ="+model_switch+" plotting 1km crm data")
    var6="tot_condensed_1km"
    hor_x=ispan(1,4000,1)
print("dimsizes of hor_x are: "+dimsizes(hor_x))
    ;data_rh_crm=addfile(in_rh_crm,"r")
  else
print("what are you doing with your model switch?")
  end if
  end if
end if

data_cloud=addfile(in_cloud,"r")
;data_psi=addfile(in_psi,"r")

;field_cloud  = data_cloud->$var1$(:,:,:)
;field_liq= data_cloud->$var_liq$(3:11,:,:,:)
;field_ice= data_cloud->$var_ice$(3:11,:,:,:)
field_totcond= data_cloud->$var_gcm$(:,:,:) ; p,x,ensemble
;field_psi = data_psi->$var2$(:,:,:)

print("dimsizesof gcm tot cond: "+dimsizes(field_totcond))
;print("vert prof of gcm tot cond: "+field_totcond(:,40,2))

  ;field_liq_mn=dim_avg_n(field_liq,0)
  ;field_liq_zmn=dim_avg_n(field_liq_mn,1)
  ;field_ice_mn=dim_avg_n(field_ice,0)
  ;field_ice_zmn=dim_avg_n(field_ice_mn,1)
  ;print("dimsizesofputzoare: "+dimsizes(field_liq_mn))
  ;print("dimsizesofputzo!are: "+dimsizes(field_liq_zmn))


  if (model_switch .gt. 4) then ; for gcm 
print("what must be done?")
    field_press  = data_cloud->$var3$(:)
    ;field_press = 100*field_press
;print("values of pressure are: "+field_press)
  else if (model_switch .gt. 3) then ; for 2km crm 
    data_cld_crm=addfile(in_crm_2km,"r")
    field_cld_crm  = data_cld_crm->$var6$(:,:)
    field_press    = data_cld_crm->$var3$(:)
  else if (model_switch .gt. 2) then ; for 1km crm
    data_cld_crm=addfile(in_crm_1km,"r")
    field_cld_crm  = data_cld_crm->$var6$(:,:)
    field_press= data_cld_crm->$var3$(:)
  ;  print("dimsizes of 1km crm are: "+dimsizes(field_cld_crm_a))
  end if
  end if
  end if

;field_cld_1kmcrm=dim_avg_n(field_cld_crm_test,1)
;field_cld_crm=dim_avg_n(field_cld_crm_test,1)
;print("dimsizes of 1kmcrm test are: "+dimsizes(field_cld_1kmcrm))

;
  print("---------------------------------------------")
  print("---------------------------------------------")
;  print("dimsizes of gcm liq are: "+dimsizes(field_liq_zmn))
;  print("dimsizes of gcm ice are: "+dimsizes(field_ice_zmn))
  ;printVarSummary(field_cloud)
  ;print("max is: ="+max(field_liq(0,32,5,:)))
  ;print("max is: ="+max(field_liq(0,2,5,:)))
  ;print("max is: ="+max(field_cloud(:,:,2)))
  ;print("max is: ="+max(field_cloud(:,:,3)))
  ;print("max is: ="+max(field_cloud(:,:,4)))
if (model_switch .lt. 5) then 
  print("---------------------------------------------")
  print("---------------------------------------------")
  print("dimsizes of crm cloud are: "+dimsizes(field_cld_crm))
  print("max is: ="+max(field_cld_crm))
  print("---------------------------------------------")
  print("---------------------------------------------")
end if

;field_tot_condensate = field_liq_zmn+field_ice_zmn
field_tot_condensate = field_totcond 

;plot_type="newPDF"
plot_type="eps"
wks = gsn_open_wks(plot_type,fileout)

;my_levels1 = (/0.4,0.1,0.06,0.04, \
;               0.03,0.02,0.01,0.001, \
;               0.0001,0.00001,0.00002,0.00003 /)

my_levels1 = (/0.5,0.1,0.05,0.01, \
               0.005, 0.001, 0.0005, \
               0.0001,0.00005,0.00001 /) ; 10

my_levels2 = (/0.4, 0.3 ,0.2,0.1,0.07,0.05, \
               0.02, 0.01, 0.005, 0.001 /) ; 10

my_levels2 = (/0.4, 0.3 ,0.2,0.1,0.07,0.05, \
               0.02, 0.01, 0.001, 0.0001 /) ; 10



;my_colors1 = (/11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99/) ; 23

;my_colors1 = (/111,162,172, \
;               178,202,\
;               208,226,232,\
;               238,250,255/)  ; 11

my_colors1 = (/111,147,159, \
               171,183,\
               195,207,219,\
               231,243,255/)  


;gsn_define_colormap(wks,"BlAqGrYeOrRe")

;figurenumber = 1 ; 1 is defualt
;; 3 --> 3 month hov of 50x2000
;; 1 --> two panel figure of gcm and crm
;; 2 --> same as 3 
;if (figurenumber .lt. 2) then

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
; res@lbLabelAngleF        = 90
 res@cnLevels            = my_levels2
 res@cnFillColors        = my_colors1
; res@cnLinesOn             = False
 res@trYReverse               = True     ;, reverse the y-axis
;res@lbOrientation     = "vertical"
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
 res@tmXBMode     = "Explicit"
 res@tmXBValues   = (/25,1000,2000,3000,4000/)
 ;res2@tmXBLabels   = ""+res2@tmXBValues
 res@tmXBLabels   = (/"1","1000","2000","3000","4000"/)
; res@tmXBLabels   = ""+res@tmXBValues
 res@tmYLMode     = "Explicit"
 ;res@tmYLValues   = (/1000,800,600,400,200,100/)
 res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 ;res@tmYLLabels    = (/"100000","80000","60000","40000","20000","10000"/)
 res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 ;res@tmYLLabels   = ""+res@tmYLValues
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "Pressure (hPa) "

  if (model_switch .gt. 4) then ; for gcm
    ;ensind=2
    mainTitle="25km "+exptype
    cldplot=field_tot_condensate
    ;psiplot=field_psi
    res@trXMinF      = 25
  else if (model_switch .gt. 3) then ; for 2km gcm
    mainTitle="CRM 2km"
    cldplot=field_cld_crm
    ;cldplot=field_cld_1kmcrm
    ;psiplot=field_psi_crm
    res@trXMinF      = 2
  else if (model_switch .gt. 2) then ; for 2km gcm
    mainTitle="CRM 1km"
    cldplot=field_cld_crm
    res@trXMinF      = 1
  end if 
  end if 
  end if
  
  ; scale to g/kg
  cldplot=1000*cldplot
print("condensate is scaled!")

print("! dimsizes of cldplot are: "+dimsizes(cldplot))

  cldplot!0="plev"
  cldplot&plev=field_press

;print("field_press = "+field_press)
;print("vert prof of gcm tot cond: "+cldplot(:,40,2))

  if (model_switch .gt. 4) then ; for gcm
    cldplot!1="xdim"
    cldplot&xdim=hor_x
    plot_cld = gsn_csm_contour(wks,cldplot(::-1,::-1,ensind),res)
  else if (model_switch .gt. 3) then ; for 2km gcm
    cldplot!1="xdim"
    cldplot&xdim=hor_x
    plot_cld = gsn_csm_contour(wks,cldplot(:,:),res)
  else if (model_switch .gt. 2) then ; for 1km gcm
    cldplot!1="xdim"
    cldplot&xdim=hor_x
    plot_cld = gsn_csm_contour(wks,cldplot(:,:),res)
  end if 
  end if 
  end if
 
; res2 = True     
; res2@gsnDraw               = False
; res2@gsnFrame              = False
; res2@cnLevels              = my_levels_psi
; res2@cnInfoLabelOn         = False
; res2@cnLevelSelectionMode = "ExplicitLevels"
; res2@cnMonoLineDashPattern = False
; res2@cnLineDashPatterns = (/2,2,2,2,2,2,0,0,0,0,0,0/)
; res2@cnLinesOn             = True
; res2@cnLineLabelsOn        = False
; res2@cnLineThicknessF      = 2
; res2@trYReverse            = True     ; reverse the y-axis
; res2@gsnYAxisIrregular2Log = True    ; Convert Y axis to logarithmic
; res2@trYMaxF      = 100000
; res2@trYMinF      = 10000
; res2@trXMaxF      = 4000
; res2@trXMinF      = 2
; res2@tmXBMode     = "Explicit"
; res2@tmXBValues   = (/25,1000,2000,3000,4000/)
; ;res2@tmXBLabels   = ""+res2@tmXBValues
; res2@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
; ;res2@tmYLMode     = "Explicit"
; ;;res2@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
; ;;res2@tmYLValues   = (/10000,20000,40000,60000,80000,100000/)
; ;;res2@tmYLLabels   = ""+res2@tmYLValues
; res2@vpWidthF          = 2.0 ; vpWidth and Height control box size
; res2@vpHeightF         = 2. ; default for both is 0.6 in NDC units
; res2@lbLabelBarOn      = False
;; these commands turn off/on the varname and units at top of image
; res2@gsnLeftString = ""
; res2@gsnRightString = ""
; res2@tiXAxisString     = " "
; res2@tiYAxisString     = "height "

;if (model_switch .gt. 4) then ; for gcm
;  ;plot_psi = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)
;  ;plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)
;else if (model_switch .lt. 3) then ; for crm
;  ;plot_psi = gsn_csm_contour(wks,psiplot(:,:),res2)
;end if
;end if

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
resP@lbLabelAngleF        = 90
resP@lbLabelFontHeightF      = 0.022

gsn_panel(wks,plot,(/1,1/),resP)

end
