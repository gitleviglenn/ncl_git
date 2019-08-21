; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path_to_wc="/Users/silvers/data"
exdir="/WalkerCell/testing_20181203"

fileout="hov_precip"
;plottitle="25km lwoff"
;plottitle="100km "
plottitle="25km "

; set parameters for switches
model_type=2 ; 2 is default and corresponds to plotting gcm data
dom_x=1 ; 1 is default and corresponds to a domain size of 4000km

; define the incoming data
if (model_type .gt. 1) then ; for gcm...
  if (dom_x .gt. 1) then ; domain size is 16000km in x
    ;hor_x=ispan(100,16000,100)
    ;incoming=path_to_wc+exdir+"/c8x160L33_am4p0_100km_wlkr_ent0p9_noconv_lwoff/"+"1979th1983_daily.nc"
    ;incoming=path_to_wc+exdir+"/c8x160L33_am4p0_100km_wlkr_ent0p9/"+"1979th1983_daily.nc"
    ;incoming=path_to_wc+exdir+"/c8x160L33_am4p0_100km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"
    ;
    hor_x=ispan(25,16000,25)
    incoming=path_to_wc+exdir+"/c8x640L33_am4p0_25km_wlkr_ent0p9/"+"1979th1983_daily.nc"
    ;incoming=path_to_wc+exdir+"/c8x640L33_am4p0_25km_wlkr_ent0p9_lwoff/"+"1979th1983_daily.nc"
  else  ; domain size is 4000km in x
    hor_x=ispan(25,4000,25)
    incoming=path_to_wc+exdir+"/c8x160L33_am4p0_25km_wlkr_ent0p9_noconv/"+"1979th1983_daily.nc"
    ;incoming=path_to_wc+exdir+"/c8x160L33_am4p0_25km_wlkr_ent0p9/"+"1979th1983_daily.nc"
    ;
    ;hor_x=ispan(100,4000,100)
    ;incoming=path_to_wc+exdir+"/c8x40L33_am4p0_100km_wlkr_ent0p9/"+"1979th1983_daily.nc"
  end if
else ; for crm...
  ;incoming=path_to_wc+"/WalkerCell/testing_20181203/c10x4000L33_am4p0_1km_wlkr_4K_lwoff/"+"1979.6mn.atmos_daily_selvars.nc"
  ;incoming=path_to_wc+"/WalkerCell/testing_20181203/c10x4000L33_am4p0_1km_wlkr_4K/"+"1979.6mn.atmos_daily_selvars.nc"
  incoming=path_to_wc+"/WalkerCell/testing_20181203/c50x2000L33_am4p0_2km_wlkr_4K/"+"1979.6mn.atmos_daily_selvars.nc"
  ;hor_x=ispan(1,4000,1) ; for experiments with 1km grid spacing
  hor_x=ispan(2,4000,2) ; for experiments with 2km grid spacing
end if

infile_new=incoming

  print("incoming file is: "+infile_new)

var1="precip" ; time, grid_y, grid_x
starttime=1
endtime=1200
endtime=180
data_new = addfile(infile_new,"r")
field_new = data_new->$var1$(starttime:endtime,:,:)
;field_new = data_new->$var1$(:,:,:)
  print("dimsizes of field_new are: "+dimsizes(field_new))
p_in_xt=dim_avg_n(field_new,1)
; convert to mm/day
p_new_xt=86400*p_in_xt

p_new_xt!0="time"
p_new_xt!1="xdim"
p_new_xt&xdim=hor_x

p_new_mn_a=dim_avg_n(p_new_xt,1)
  print("dimsizes of p_new_mn_a are: "+dimsizes(p_new_mn_a))
p_new_mn_b=dim_avg_n(p_new_mn_a,0)

  print("---------------------------------------------")
  print("max of p_new is: "+max(p_new_xt))
  print("mean of p_new is: "+p_new_mn_b)
  print("dimsizes of p_new_xt are: "+dimsizes(p_new_xt))
  print("---------------------------------------------")

;plot_type="newPDF"
plot_type="eps"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/1,5,10,15,20, \
               25,30,35,40,45, \
               50,55,60,65,70, \
               75,80,85,90,95/); \
               ;100,105 /)

;my_levels1 = (/1,4,7,10,13, \
;               16,19,22,25,28, \
;               31,34,37,40,43, \
;               46,49,52,55,60/); \
;               ;100,105 /)
 
my_colors1 = (/111,121,124,134,159, \
                166,173,180,186,193, \
                200,205,210,215,220, \
                225,230,235,240,245, \
                255 /);,211,216/) ; 

gsn_define_colormap(wks,"amwg256")
plot = new(1,graphic)

; create resource for plot
 res = True     

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
 if (dom_x .gt. 1) then ; domain size is 16000km in x
  res@trXMaxF      = 16000
  res@tmXBValues   = (/25,4000,8000,12000,16000/)
  res@tmXBLabels   = (/"","4000 "," ","12000 ",""/)
 else
  res@trXMaxF      = 4000
  res@tmXBValues   = (/25,1000,2000,3000,4000/)
  res@tmXBLabels   = (/"","1000 "," ","3000 ",""/)
 end if
 res@trXMinF      = 2
; res@tmYLLabelsOn = False
 res@tmYROn       = False
 res@tmXTOn       = False
 res@tmXBMode     = "Explicit"
 ;res@tmXBValues   = (/25,1000,2000,3000,4000/)
 res@tiXAxisString     = "km"
; res@tmXBLabelAngleF   = 90
 res@tmYLLabelAngleF   = 90
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 ;res@vpWidthF          = .30 ; vpWidth and Height control box size
 ;res@vpHeightF         = 2.0 ; default for both is 0.6 in NDC units
 res@vpWidthF          = 0.50 ; vpWidth and Height control box size
 res@vpHeightF         = 0.81 ; default for both is 0.6 in NDC units
 ;res@vpWidthF          = 0.81 ; vpWidth and Height control box size
 ;res@vpHeightF         = 0.5 ; default for both is 0.6 in NDC units

 res@lbLabelBarOn      = False

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@tiXAxisString     = "km"
 res@tiYAxisString     = "days "

 plot(0) = gsn_csm_contour(wks,p_new_xt,res)
resP                         = True
resP@txString                = " " 
;resP@txString                = "good grief"
resP@txString                = plottitle
resP@gsnPanelLabelBar        = True
resP@lbLabelFontHeightF      = 0.012

gsn_panel(wks,plot,(/1,1/),resP)

end
