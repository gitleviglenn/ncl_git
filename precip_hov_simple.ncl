; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path_to_wc="/Users/silvers/data"

fileout="hov_precip"
plottitle="100km noconv lwoff"

; are you plotting gcm or crm data?
model_type=2 ; 2 is default and corresponds to plotting gcm data

; define the incoming data
if (model_type .gt. 1) then
  ; for gcm...
  incoming=path_to_wc+"/WalkerCell/testing_20181203/c8x160L33_am4p0_100km_wlkr_ent0p9_noconv_lwoff/"+"1979th1983_daily.nc"
  ;incoming=path_to_wc+"/WalkerCell/testing_20181203/c8x40L33_am4p0_100km_wlkr_ent0p9/"+"1979th1983_daily.nc"
  ;incoming=path_to_wc+"/WalkerCell/testing_20181203/c8x160L33_am4p0_25km_wlkr_ent0p9_noconv/"+"1979th1983_daily.nc"
  ;hor_x=ispan(25,4000,25)
  ;hor_x=ispan(100,4000,100)
  hor_x=ispan(100,16000,100)
else
  ; for crm...
  incoming=path_to_wc+"/WalkerCell/testing_20181203/c10x4000L33_am4p0_1km_wlkr_4K_lwoff/"+"1979.6mn.atmos_daily_selvars.nc"
  hor_x=ispan(1,4000,1) ; for experiments with 1km grid spacing
  ;hor_x=ispan(2,4000,2) ; for experiments with 2km grid spacing
end if

infile_new=incoming

  print("incoming file is: "+infile_new)

var1="precip" ; time, grid_y, grid_x
data_new = addfile(infile_new,"r")
field_new = data_new->$var1$(1:180,:,:)
  print("dimsizes of field_new are: "+dimsizes(field_new))
p_in_xt=dim_avg_n(field_new,1)
; convert to mm/day
p_new_xt=86400*p_in_xt

;hor_x=ispan(100,4000,100)

p_new_xt!0="time"
p_new_xt!1="xdim"
p_new_xt&xdim=hor_x

  print("---------------------------------------------")
  print("max of p_new is: "+max(p_new_xt))
  print("dimsizes of p_new_xt are: "+dimsizes(p_new_xt))
  print("---------------------------------------------")

plot_type="newPDF"
wks = gsn_open_wks(plot_type,fileout)

my_levels1 = (/1,4,7,10,13, \
               16,19,22,25,28, \
               31,34,37,40,43, \
               46,49,52,55,60/); \
               ;100,105 /)

 
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
 res@trXMaxF      = 16000
 res@trXMinF      = 2
; res@tmYLLabelsOn = False
 res@tmYROn       = False
 res@tmXTOn       = False
 res@tmXBMode     = "Explicit"
 ;res@tmXBValues   = (/25,1000,2000,3000,4000/)
 res@tmXBValues   = (/25,4000,8000,12000,16000/)
 res@tmXBLabels   = (/"","4000 "," ","12000 ",""/)
 res@tiXAxisString     = "km"
; res@tmXBLabelAngleF   = 90
 res@tmYLLabelAngleF   = 90
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 ;res@vpWidthF          = .30 ; vpWidth and Height control box size
 ;res@vpHeightF         = 2.0 ; default for both is 0.6 in NDC units
 ;res@vpWidthF          = 0.50 ; vpWidth and Height control box size
 ;res@vpHeightF         = 0.81 ; default for both is 0.6 in NDC units
 res@vpWidthF          = 0.81 ; vpWidth and Height control box size
 res@vpHeightF         = 0.5 ; default for both is 0.6 in NDC units

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
