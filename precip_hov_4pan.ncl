; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path_to_wc="/Users/silvers/data"
exdir="/WalkerCell/testing_20181203"

fileout="hov_precip"
plottitle="test title tude"
;endtime=1800
endtime=1090
var1="precip" ; time, grid_y, grid_x
dom_x=1 ; 1 is default and corresponds to a domain size of 4000km

hor_x_a=ispan(100,16000,100)
;incoming_a=path_to_wc+exdir+"/c8x160L33_am4p0_100km_wlkr_ent0p9/"+"1979th1983_daily.nc"
incoming_a=path_to_wc+exdir+"/c8x160L33_am4p0_100km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"
hor_x_b=ispan(100,4000,100)
;incoming_b=path_to_wc+exdir+"/c8x40L33_am4p0_100km_wlkr_ent0p9/"+"1979th1983_daily.nc"
incoming_b=path_to_wc+exdir+"/c8x40L33_am4p0_100km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"

hor_x_c=ispan(25,16000,25)
;incoming_c=path_to_wc+exdir+"/c8x640L33_am4p0_25km_wlkr_ent0p9/"+"1979th1983_daily.nc"
incoming_c=path_to_wc+exdir+"/c8x640L33_am4p0_25km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"
hor_x_d=ispan(25,4000,25)
;incoming_d=path_to_wc+exdir+"/c8x160L33_am4p0_25km_wlkr_ent0p9/"+"1979th1983_daily.nc"
incoming_d=path_to_wc+exdir+"/c8x160L33_am4p0_25km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"


infile_new_a=incoming_a
infile_new_b=incoming_b
infile_new_c=incoming_c
infile_new_d=incoming_d

; for incoming_a
data_a = addfile(infile_new_a,"r")
field_a = data_a->$var1$(1:endtime,:,:)
  print("dimsizes of field_a are: "+dimsizes(field_a))
p_ina_xt=dim_avg_n(field_a,1)
p_a_xt=86400*p_ina_xt

p_a_xt!0="time"
p_a_xt!1="xdim"
p_a_xt&xdim=hor_x_a

; for incoming_b
data_b = addfile(infile_new_b,"r")
field_b = data_b->$var1$(1:endtime,:,:)
  print("dimsizes of field_b are: "+dimsizes(field_b))
p_inb_xt=dim_avg_n(field_b,1)
p_b_xt=86400*p_inb_xt

p_b_xt!0="time"
p_b_xt!1="xdim"
p_b_xt&xdim=hor_x_b

; for incoming_c
data_c = addfile(infile_new_c,"r")
field_c = data_c->$var1$(1:endtime,:,:)
  print("dimsizes of field_c are: "+dimsizes(field_c))
p_inc_xt=dim_avg_n(field_c,1)
p_c_xt=86400*p_inc_xt

p_c_xt!0="time"
p_c_xt!1="xdim"
p_c_xt&xdim=hor_x_c

  print("---------------------------------------------")
  print("max of p_c is: "+max(p_c_xt))
  print("dimsizes of p_c_xt are: "+dimsizes(p_c_xt))
  print("---------------------------------------------")

; for incoming_d
data_d = addfile(infile_new_d,"r")
field_d = data_d->$var1$(1:endtime,:,:)
  print("dimsizes of field_d are: "+dimsizes(field_d))
p_ind_xt=dim_avg_n(field_d,1)
p_d_xt=86400*p_ind_xt

p_d_xt!0="time"
p_d_xt!1="xdim"
p_d_xt&xdim=hor_x_d

  print("---------------------------------------------")
  print("max of p_d is: "+max(p_d_xt))
  print("dimsizes of p_d_xt are: "+dimsizes(p_d_xt))
  print("---------------------------------------------")

;---------------------------------------------------------------------------
; make the plot(s)
;---------------------------------------------------------------------------

;plot_type="newPDF"
plot_type="eps"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/1,5,10,15,20, \
               25,30,35,40,45, \
               50,55,60,65,70, \
               75,80,85,90,95/); \
               ;100,105 /)

my_colors1 = (/111,121,124,134,159, \
                166,173,180,186,193, \
                200,205,210,215,220, \
                225,230,235,240,245, \
                255 /);,211,216/) ; 

gsn_define_colormap(wks,"amwg256")
;plot = new(1,graphic)

; create resource for plot
 res                  = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnFillMode               = "RasterFill"       ; Raster Mode
 res@cnLinesOn                = False
 ;res@cnLevelSelectionMode = "ManualLevels"
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
 res@cnLinesOn             = False
 res@trXMinF      = 2
; res@tmYLLabelsOn = False
 res@tmYROn       = False
 res@tmXTOn       = False
 res@tmXBMode     = "Explicit"
 ;res@tmXBValues   = (/25,1000,2000,3000,4000/)
; res@tmXBLabelAngleF   = 90
 res@tmYLLabelAngleF   = 90
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 res@lbLabelBarOn      = False

; bottom left
 res@vpXF            =   0.15
 res@vpYF            =   0.5
 res@vpWidthF          = 0.4 ; vpWidth and Height control box size
 res@vpHeightF         = 0.4 ; default for both is 0.6 in NDC units

 res@trXMaxF      = 16000
 res@tmXTOn       = True
 res@tmXBValues   = (/5,4000,8000,12000,16000/)
 res@tmXTValues   = (/5,4000,8000,12000,16000/)
 res@tmXBLabels   = (/"","4000 ","8000 ","12000 ",""/)

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "days "

 plot0 = gsn_csm_contour(wks,p_a_xt,res)

; top left
 res@trXMaxF      = 16000
 res@tmXBValues   = (/5,4000,8000,12000,16000/)
 res@tmXTValues   = (/5,4000,8000,12000,16000/)
 res@tmXBLabels   = (/""," "," "," ",""/)
 res@tiXAxisString     = " "
 res@tiYAxisString     = "days "
 res@vpXF            =   0.15
 res@vpYF            =   0.94
 res@vpWidthF          = 0.4 ; vpWidth and Height control box size
 res@vpHeightF         = 0.4 ; default for both is 0.6 in NDC units

 plot1 = gsn_csm_contour(wks,p_c_xt,res)

; bottom right
  res@trXMaxF      = 4000
  res@tmXBValues   = (/5,1000,2000,3000,4000/)
  res@tmXTValues   = (/5,1000,2000,3000,4000/)
  res@tmXBLabels   = (/"","1000 "," ","3000 ",""/)
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "  "
 res@vpXF            =   0.6
 res@vpYF            =   0.5
 res@vpWidthF          = 0.11 ; vpWidth and Height control box size
 res@vpHeightF         = 0.4 ; default for both is 0.6 in NDC units
 res@tiYAxisString     = " "

 plot2 = gsn_csm_contour(wks,p_b_xt,res)

; top right
  res@trXMaxF      = 4000
  res@tmXBValues   = (/5,1000,2000,3000,4000/)
  res@tmXTValues   = (/5,1000,2000,3000,4000/)
  ;res@tmXBLabels   = (/"","1000 "," ","3000 ",""/)
  res@tmXBLabels   = (/""," "," "," ",""/)
 res@tiXAxisString     = " "
 res@tiYAxisString     = "  "
 res@vpXF            =   0.6
 res@vpYF            =   0.94
 res@vpWidthF          = 0.11 ; vpWidth and Height control box size
 res@vpHeightF         = 0.4 ; default for both is 0.6 in NDC units

 plot3 = gsn_csm_contour(wks,p_d_xt,res)


resP                         = True
resP@txString                = " " 
;resP@txString                = "good grief"
resP@txString                = plottitle
resP@gsnPanelLabelBar        = True
resP@lbLabelFontHeightF      = 0.012

maximize_output(wks,resP)





end
