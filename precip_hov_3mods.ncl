;----------------------------------------------------------------------------------------------
; precip_hov_3mods.ncl 
;
; plot hovmuller diagrams of precipitation.  the particular plot created depends on the value
; of the parameter 'figurenumber'
;
;figurenumber = 1 ; 1 is defualt
; 3 --> 3 month hov of 50x2000
; 1 --> three panel figure of gcm and crm
; 2 --> same as 3 
;
; levi silvers 
;----------------------------------------------------------------------------------------------
;
; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; path to data
path_to_wc="/Users/silvers/data"
walkcell="/WalkerCell/gauss_d"
;file_pre="/c96L33_8x80_nh.19790101"
file_pre="/19790101"
file_pre_b="/19800101"
file_pre_c="/19810101"
file_pre_d="/19820101"

; name of output file
fileout="hov_guass_d"

;infile=path_to_wc+walkcell+"/am4p0_8x160_4K"+file_pre+".atmos_daily.nc"

;infile=path_to_wc+walkcell+"/c96L33_am4p0_8x160_nh_25km_wlkr_4K_b"+file_pre+".atmos_daily.nc"
;infile=path_to_wc+walkcell+"/c96L33_am4p0_8x160_nh_25km_wlkr_4K_ent0p5"+file_pre+".atmos_daily.nc"

; newer experiments and experiment names...
;infile=path_to_wc+walkcell+"/c8x160L33_am4p0_25km_wlkr_ent0p9"+file_pre+".atmos_daily.nc"
infile=path_to_wc+walkcell+"/c8x160L33_am4p0_25km_wlkr_ent0p9_dt20"+file_pre+".atmos_daily.nc"
;infile=path_to_wc+walkcell+"/c8x160L33_am4p0_100km_wlkr_ent0p9"+file_pre+".atmos_daily.nc"

;infile_1km=path_to_wc+walkcell+"/c96L33_am4p0_10x4000_nh_1km_wlkr_4K/atmos_daily_precip_3month.nc"
;infile_1km=path_to_wc+walkcell+"/c96L33_am4p0_10x4000_nh_1km_wlkr_4K/1979.atmos_daily_precip_mon123456.nc"
infile_1km=path_to_wc+walkcell+"/c10x4000L33_am4p0_1km_wlkr_4K/1979.atmos_daily_precip_mon123456.nc"
infile_80=path_to_wc+walkcell+"/c96L33_am4p0_8x160_nh_25km_wlkr_4K_b"+file_pre_b+".atmos_daily.nc"
infile_81=path_to_wc+walkcell+"/c96L33_am4p0_8x160_nh_25km_wlkr_4K_b"+file_pre_c+".atmos_daily.nc"
infile_82=path_to_wc+walkcell+"/c96L33_am4p0_8x160_nh_25km_wlkr_4K_b"+file_pre_d+".atmos_daily.nc"
  print("incoming file is: "+infile)
;infile2=path_to_wc+"/WalkerCell/c96L33_100x1000_nh_crm.19790101.atmos_daily.nc"

; below are paths to the 2km experiments: 
;dirname="/c96L33_am4p0_50x2000_nh_2km_wlkr_4K"
;endfile=".atmos_daily.nc"

;dirname="/c50x2000L33_am4p0_2km_wlkr_4K"
;dirname="/c50x2000L33_am4p0_2km_wlkr_4K_dt5"
dirname="/c100x2000L33_am4p0_2km_wlkr_4K"
endfile=".atmos_daily_precp.nc"
;
file_pre="/19790101"
infile2=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2)
file_pre="/19790201"
infile2b=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2b)
file_pre="/19790301"
infile2c=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2c)
file_pre="/19790401"
infile2d=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2d)
file_pre="/19790501"
infile2e=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2e)
file_pre="/19790601"
infile2f=path_to_wc+walkcell+dirname+file_pre+endfile
  print("incoming file is: "+infile2f)

data_25km = addfile(infile,"r")
data_25km_80 = addfile(infile_80,"r")
data_25km_81 = addfile(infile_81,"r")
data_25km_82 = addfile(infile_82,"r")
data_2km  = addfile(infile2,"r")
data_2km_b  = addfile(infile2b,"r")
data_2km_c  = addfile(infile2c,"r")
data_2km_d  = addfile(infile2d,"r")
data_2km_e  = addfile(infile2e,"r")
data_2km_f  = addfile(infile2f,"r")

data_1km = addfile(infile_1km,"r")
  print("incoming file is: "+infile_1km)

var1="precip" ; time, grid_y, grid_x
;var1="prec_conv" ; time, grid_y, grid_x
;var1="prec_ls" ; time, grid_y, grid_x

;field1 = data_25km->$var1$(:,:,:)
field1 = data_25km->$var1$(0:180,:,:)
field1b = data_25km->$var1$(:,:,:)
field1_80 = data_25km_80->$var1$(:,:,:)
field1_81 = data_25km_81->$var1$(:,:,:)
field1_82 = data_25km_82->$var1$(:,:,:)
field2 = data_2km->$var1$(:,:,:)
field2b = data_2km_b->$var1$(:,:,:)
field2c = data_2km_c->$var1$(:,:,:)
field2d = data_2km_d->$var1$(:,:,:)
field2e = data_2km_e->$var1$(:,:,:)
field2f = data_2km_f->$var1$(:,:,:)
field3 = data_1km->$var1$(:,:,:)

p_25_xt=dim_avg_n(field1,1)

p_25full_xt=dim_avg_n(field1b,1)
p_25full_80_xt=dim_avg_n(field1_80,1)
p_25full_81_xt=dim_avg_n(field1_81,1)
p_25full_82_xt=dim_avg_n(field1_82,1)
p_25full_xt_a=array_append_record(p_25full_xt,p_25full_80_xt,0)
p_25full_xt_b=array_append_record(p_25full_xt_a,p_25full_81_xt,0)
p_25full_4_xt=array_append_record(p_25full_xt_b,p_25full_82_xt,0)
p_25full_4yr_xt=86400*p_25full_4_xt

p_2_xt=dim_avg_n(field2,1)

p_2full_a_xt=dim_avg_n(field2,1)
p_2full_b_xt=dim_avg_n(field2b,1)
p_2full_c_xt=dim_avg_n(field2c,1)
p_2full_d_xt=dim_avg_n(field2d,1)
p_2full_e_xt=dim_avg_n(field2e,1)
p_2full_f_xt=dim_avg_n(field2f,1)

p_2full_xt_a=array_append_record(p_2full_a_xt,p_2full_b_xt,0)
p_2full_xt_b=array_append_record(p_2full_xt_a,p_2full_c_xt,0)
p_2full_xt_c=array_append_record(p_2full_xt_b,p_2full_d_xt,0)
p_2full_xt_d=array_append_record(p_2full_xt_c,p_2full_e_xt,0)
p_2full_xt=array_append_record(p_2full_xt_d,p_2full_f_xt,0)

p_1_xt=dim_avg_n(field3,1)

; convert to mm/day
p_25_xt=86400*p_25_xt
p_25full_xt=86400*p_25full_xt
p_2_xt=86400*p_2_xt
p_2full_xt=86400*p_2full_xt
p_1_xt=86400*p_1_xt

p_25_xt!0="time"
p_25full_xt!0="time"
p_2full_xt!0="time"
p_1_xt!0="time"

; set up horizontal dimension with units of km
;rhplot=field_rh
;psiplot=field_psi

hor_x=ispan(25,4000,25)
crm_x=ispan(2,4000,2)
crm_1km_x=ispan(1,4000,1)

p_25_xt!1="xdim"
p_25_xt&xdim=hor_x

p_25full_xt!1="xdim"
p_25full_xt&xdim=hor_x
p_25full_4yr_xt!1="xdim"
p_25full_4yr_xt&xdim=hor_x

p_2full_xt!1="xdim"
p_2full_xt&xdim=crm_x

p_1_xt!1="xdim"
p_1_xt&xdim=crm_1km_x

print("dimsizes of hor_x are: "+dimsizes(hor_x))

;rhplot=field_rh_crm
;psiplot=field_psi_crm
;crm_x=ispan(2,4000,2)


  print("dimsizes of field1 are: "+dimsizes(field1))
  print("---------------------------------------------")
  print("max of p_25 is: "+max(p_25_xt))
  print("dimsizes of p_25_xt are: "+dimsizes(p_25_xt))
  print("---------------------------------------------")
  print("dimsizes of field2 are: "+dimsizes(field2))
  print("dimsizes of field2b are: "+dimsizes(field2b))
  print("dimsizes of field2c are: "+dimsizes(field2c))
  print("dimsizes of field2 full are: "+dimsizes(p_2full_xt))
  print("---------------------------------------------")
  print("max of p_2 is: "+max(p_2_xt))
  print("dimsizes of p_2_xt are: "+dimsizes(p_2_xt))
  print("dimsizes of field1b are: "+dimsizes(field1b))


plot_type="newPDF"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/1,4,7,10,13, \
               16,19,22,25,28, \
               31,34,37,40,43, \
               46,49,52,55,60/); \
               ;100,105 /)

my_levels1_crm = (/1,3,5,7,9, \
               11,13,15,17,19, \
               21,23,25,27,29, \
               31,33,35,37,39, \
               41,43 /)

;my_colors1 = (/2,14,20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,128/)
;my_colors1 = (/4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23/) ; gui_defaul
;my_colors1 = (/11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79,83,87,91,95,99/) ; 
my_colors1 = (/111,121,124,134,159, \
                166,173,180,186,193, \
                200,205,210,215,220, \
                225,230,235,240,245, \
                255 /);,211,216/) ; 

;gsn_define_colormap(wks,"BlAqGrYeOrRe")
gsn_define_colormap(wks,"amwg256")

figurenumber = 1 ; 1 is defualt
; 3 --> 3 month hov of 50x2000
; 1 --> two panel figure of gcm and crm
; 2 --> same as 3 

;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"NCV_blu_red")
;gsn_define_colormap(wks,"MPL_coolwarm")
;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"BlAqGrYeOrRe")

;; start plots----------------------------------------------------------

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnFillMode               = "RasterFill"       ; Raster Mode
 res@cnLinesOn                = False
 res@trXMaxF      = 4000
 res@trXMinF      = 2
 res@tmXBMode     = "Explicit"
 res@tmXBValues   = (/25,1000,2000,3000,4000/)
 res@tmXBLabels   = (/"0","1000","2000","3000","4000"/)
 res@tiXAxisString     = "km"
 ;res@cnLevelSelectionMode = "ManualLevels"
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
 res@cnLinesOn             = False
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 ;res@vpWidthF          = 2.0 ; vpWidth and Height control box size
 ;res@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units
 res@vpWidthF          = .5 ; vpWidth and Height control box size
 res@vpHeightF         = 0.81 ; default for both is 0.6 in NDC units

 res@lbLabelBarOn      = False

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@tiXAxisString     = " "
 res@tiYAxisString     = "days "

if (figurenumber .lt. 2) then
  plot = new(3,graphic)
  plot(0) = gsn_csm_contour(wks,p_25_xt,res)
  plot(1) = gsn_csm_contour(wks,p_2full_xt,res)
  plot(2) = gsn_csm_contour(wks,p_1_xt,res)
 
  resP                         = True
  resP@txString                = fileout
  resP@gsnPanelLabelBar        = True
  resP@lbLabelFontHeightF      = 0.022
  
  gsn_panel(wks,plot,(/1,3/),resP)
 
else ;--------------------------------------------------------------------------
  plot = new(1,graphic)

  plot(0) = gsn_csm_contour(wks,p_2full_xt,res)

  resP                         = True
  resP@txString                = fileout
  resP@gsnPanelLabelBar        = True
  resP@lbLabelFontHeightF      = 0.022
  
  gsn_panel(wks,plot,(/1,1/),resP)

end if
print("figurenum is: "+figurenumber)

end
