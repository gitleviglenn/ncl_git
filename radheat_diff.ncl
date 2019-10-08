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
fileout="myqrad"

; for gcm
in_cloud=path_to_wc+walkcell+"/mymy_clouds.nc"
in_psi=path_to_wc+walkcell+"/mymy_psi.nc"
in_tdt=path_to_wc+walkcell+"/mymy_tdt.nc"
in_crm_tdt=path_to_wc+walkcell+"/c96L33_am4p0_50x2000_nh_2km_wlkr_4K/mymy_crm_tdt.nc"
  print("incoming file is: "+in_cloud)
  print("incoming file is: "+in_tdt)
  print("incoming file is: "+in_crm_tdt)
; for crm
in_rh_crm=path_to_wc+walkcell+"/mymy_cl_crm.nc"
in_psi_crm=path_to_wc+walkcell+"/mymy_psi_crm.nc"
  print("incoming file is: "+in_rh_crm)
  print("incoming file is: "+in_psi_crm)

data_cloud=addfile(in_cloud,"r")
data_tdt=addfile(in_tdt,"r")
data_tdt_crm=addfile(in_crm_tdt,"r")
data_psi=addfile(in_psi,"r")
data_rh_crm=addfile(in_rh_crm,"r")
data_psi_crm=addfile(in_psi_crm,"r")

var1="tdtlw_gcm" ; time, grid_y, grid_x
;var1="tdtconv_gcm" ; time, grid_y, grid_x
;var1="tdtls_gcm" ; time, grid_y, grid_x
;var1="tdt_totcl_gcm" ; conv + ls

var2="mystream"
var3="pfull"
var4="psi_crm"
var5="tdtlw_crm"
var6="tdtsw_gcm" 
var7="tdtsw_crm"
var8="tdtconv_gcm"
var9="tdtls_crm" ; heating due to large scale condensation
;var8="tdt_totcl_gcm" ; conv + ls heating
var10="tdtls_gcm" ; ls heating

field_lw_gcm    = data_tdt->$var1$(:,:,:)
field_sw_gcm    = data_tdt->$var6$(:,:,:)
field_tclh_gcm  = data_tdt->$var8$(:,:,:)
field_tlslh_gcm  = data_tdt->$var10$(:,:,:)
field_psi  = data_psi->$var2$(:,:,:)

field_press  = data_rh_crm->$var3$(:)

field_psi_crm = data_psi_crm->$var4$(:,:)
field_lw_crm  = data_tdt_crm->$var5$(:,:)
field_sw_crm  = data_tdt_crm->$var7$(:,:)
field_ls_crm  = data_tdt_crm->$var9$(:,:)

;
  print("dimsizes of field cloud are: "+dimsizes(field_lw_gcm))
  print("max is: ="+max(field_lw_gcm))
  print("max is: ="+max(field_lw_crm))
  print("---------------------------------------------")
  print("dimsizes of field clodu are: "+dimsizes(field_lw_gcm))
  print("---------------------------------------------")

ensind=0
epsilon1="ent0p5"
mainTitle="Heating Rates (K/d) for CRM(top) and GCM(bot) "+epsilon1

plot_a=field_lw_gcm
plot_d=field_sw_gcm
plot_e=field_tclh_gcm
plot_h=field_lw_gcm+field_sw_gcm
plot_j=field_tlslh_gcm
psiplot=field_psi
hor_x=ispan(25,4000,25)
print("dimsizes of hor_x are: "+dimsizes(hor_x))

plot_b=field_lw_crm
plot_c=field_sw_crm
plot_f=field_ls_crm
plot_g=field_lw_crm+field_sw_crm
psiplot_b=field_psi_crm
hor_x_crm=ispan(2,4000,2)
print("dimsizes of hor_x_crm are: "+dimsizes(hor_x_crm))

plot_a!0="plev"
plot_a&plev=field_press
psiplot!0="plev"
psiplot&plev=field_press
plot_a!1="xdim"
plot_a&xdim=hor_x
psiplot!1="xdim"
psiplot&xdim=hor_x

plot_d!0="plev"
plot_d&plev=field_press
plot_d!1="xdim"
plot_d&xdim=hor_x

plot_e!0="plev"
plot_e&plev=field_press
plot_e!1="xdim"
plot_e&xdim=hor_x

plot_h!0="plev"
plot_h&plev=field_press
plot_h!1="xdim"
plot_h&xdim=hor_x

plot_j!0="plev"
plot_j&plev=field_press
plot_j!1="xdim"
plot_j&xdim=hor_x


plot_b!0="plev"
plot_b&plev=field_press
psiplot_b!0="plev"
psiplot_b&plev=field_press
plot_b!1="xdim"
plot_b&xdim=hor_x_crm
psiplot_b!1="xdim"
psiplot_b&xdim=hor_x_crm

plot_c!0="plev"
plot_c&plev=field_press
plot_c!1="xdim"
plot_c&xdim=hor_x_crm

plot_f!0="plev"
plot_f&plev=field_press
plot_f!1="xdim"
plot_f&xdim=hor_x_crm

plot_g!0="plev"
plot_g&plev=field_press
plot_g!1="xdim"
plot_g&xdim=hor_x_crm

qrad_1_gcm = plot_h(:,:,0)
qrad_2_gcm = plot_h(:,:,1)
qrad_3_gcm = plot_h(:,:,2)
qrad_4_gcm = plot_h(:,:,3)
qrad_5_gcm = plot_h(:,:,4)

; take domain average of qrad
qrad_1_dmn=dim_avg_n(qrad_1_gcm,1)
qrad_2_dmn=dim_avg_n(qrad_2_gcm,1)
qrad_3_dmn=dim_avg_n(qrad_3_gcm,1)
qrad_4_dmn=dim_avg_n(qrad_4_gcm,1)
qrad_5_dmn=dim_avg_n(qrad_5_gcm,1)
;print("dimsizes of qrad_1_dmn are: "+dimsizes(qrad_1_dmn))

print("dimsizes of qrad_3_gcm are: "+dimsizes(qrad_3_gcm))
qrad_3m1=qrad_3_gcm-qrad_1_gcm
qrad_3m2=qrad_3_gcm-qrad_2_gcm
qrad_3m4=qrad_3_gcm-qrad_4_gcm
qrad_3m5=qrad_3_gcm-qrad_5_gcm

qrad_3m1!0="plev"
qrad_3m1&plev=field_press
qrad_3m1!1="xdim"
qrad_3m1&xdim=hor_x

qrad_3m2!0="plev"
qrad_3m2&plev=field_press
qrad_3m2!1="xdim"
qrad_3m2&xdim=hor_x

qrad_3m4!0="plev"
qrad_3m4&plev=field_press
qrad_3m4!1="xdim"
qrad_3m4&xdim=hor_x

qrad_3m5!0="plev"
qrad_3m5&plev=field_press
qrad_3m5!1="xdim"
qrad_3m5&xdim=hor_x

;--------------------------------

plot_type="newPDF"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/-5,-4.5,-4,-3.5,-3 \
               -2.5,-2,-1.5,-1,-0.5, \
               0,0.5,1.0,1.5,2, \
               2.5,3.0,4.5,5.0 /); 19

;my_levels_psi = (/-5500,-4500,-3500,-2500,-1500,-500, \
;                   500, 1500, 2500,3500,4500,5500  /) ; 9
my_levels_psi = (/-7500,-6500,-5500,-4500,-3500,-2500,-1500,-500, \
                   500, 1500, 2500,3500,4500,5500,6500,7500  /) 

my_levels1_crm = (/1,3,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,37,39, \
               41,43 /) ; 22

my_colors1 = (/3,5,8,11,14, \
               16,18,21,24,31, \
               35,38,41,44,47, \
               50,53,57,60,63 /); ,\


my_col_psi = (/11,15,18,23,31,\
               39,47,\
               55,71,\
               79,87,91/) ;10 

;gsn_define_colormap(wks,"BlAqGrYeOrRe")

figurenumber = 1 ; 1 is defualt
print("figurenumber is: "+figurenumber)
;; 3 --> 3 month hov of 50x2000
;; 1 --> two panel figure of gcm and crm
;; 2 --> same as 3 
if (figurenumber .lt. 2) then

gsn_define_colormap(wks,"cmp_b2r")

;; start default plots----------------------------------------------------------
 plot = new(6,graphic)

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
 res@vpWidthF          = .5 ; vpWidth and Height control box size
 res@vpHeightF         = .5 ; default for both is 0.6 in NDC units

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
 res@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
 res@tmYLMode     = "Explicit"
 res@tmYLValues   = (/100000,80000,60000,40000,20000,10000/)
 res@tmYLLabels    = (/"1000","800","600","400","200","100"/)
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "Pressure (hPa) "


; for gcm
plot_gcm = gsn_csm_contour(wks,plot_a(:,:,ensind),res)
plot_sw_gcm = gsn_csm_contour(wks,plot_d(:,:,ensind),res)
plot_tclh_gcm = gsn_csm_contour(wks,plot_e(:,:,ensind),res)
plot_tlslh_gcm = gsn_csm_contour(wks,plot_j(:,:,ensind),res)
plot_qrad_gcm = gsn_csm_contour(wks,plot_h(:,:,ensind),res)

print("dimsizes of qrad_3m1 are: "+dimsizes(qrad_3m1))
plot_qrdiff_3m1=gsn_csm_contour(wks,qrad_3m1,res)
plot_qrdiff_3m2=gsn_csm_contour(wks,qrad_3m2,res)
plot_qrdiff_3m4=gsn_csm_contour(wks,qrad_3m4,res)
plot_qrdiff_3m5=gsn_csm_contour(wks,qrad_3m5,res)

; for crm
; ;plot_rh = gsn_csm_contour(wks,plot_a(:,::-1,ensind),res)
plot_lw_crm = gsn_csm_contour(wks,plot_b(:,:),res)
plot_sw_crm = gsn_csm_contour(wks,plot_c(:,:),res)
plot_ls_crm = gsn_csm_contour(wks,plot_f(:,:),res)
plot_qrad_crm = gsn_csm_contour(wks,plot_g(:,:),res)
 
 res2 = True     
 res2@gsnDraw               = False
 res2@gsnFrame              = False
 res2@cnLevels              = my_levels_psi
 res2@cnInfoLabelOn         = False
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnMonoLineDashPattern = False
 res2@cnLineDashPatterns = (/2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0/)
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
 res2@vpWidthF          = .5 ; vpWidth and Height control box size
 res2@vpHeightF         = .5 ; default for both is 0.6 in NDC units
 res2@lbLabelBarOn      = False
; these commands turn off/on the varname and units at top of image
 res2@gsnLeftString = ""
 res2@gsnRightString = ""
 res2@tiXAxisString     = " "
 res2@tiYAxisString     = "height "

; for gcm 
plot_psi = gsn_csm_contour(wks,psiplot(:,:,ensind),res2)
;;plot_psi = gsn_csm_contour(wks,psiplot(:,::-1,ensind),res2)

; for crm
plot_psi_b = gsn_csm_contour(wks,psiplot_b(:,:),res2)

;overlay(plot_gcm,plot_psi)
;overlay(plot_lw_crm,plot_psi_b)

; 
plot(0) = plot_qrad_crm
plot(1) = plot_qrad_gcm
;plot(2) = plot_qrad_crm
;plot(3) = plot_ls_crm

; 
plot(2) = plot_qrdiff_3m1
plot(3) = plot_qrdiff_3m2
plot(4) = plot_qrdiff_3m4
plot(5) = plot_qrdiff_3m5



resP                         = True
;resP@txString                = "good grief"
resP@txString                = mainTitle
resP@gsnPanelLabelBar        = True
;resP@vpWidthF          = 2.0 ; vpWidth and Height control box size
;resP@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units
;resP@lbLabelFontHeightF      = 0.012
resP@lbLabelFontHeightF      = 0.022

gsn_panel(wks,plot,(/3,2/),resP)
;
else ;--------------------------------------------------------------------------
if (figurenumber .lt. 4) then
    ;wks  = gsn_open_wks(plot_type,"testplot")   	; output using eps
    plot = new(1,graphic)
    res2          = True
    res2@gsnDraw          = False
    res2@gsnFrame         = False
    plot(0)    = gsn_csm_xy (wks,qrad_1_dmn,field_press,res2) 		; create plot    
    ;plot    = gsn_csm_xy (wks,field_press,qrad_1_dmn(:),res) 		; create plot    
    ;plot(0)=plota

    print("dimsizes of qrad_1_dim: "+dimsizes(qrad_1_dmn))
    print("qrad_1_dmn ="+qrad_1_dmn)
    gsn_panel(wks,plot,(/1,1/),res2)
;    psres=True
;    maximize_output(wks,psres)
end if
end if

end
