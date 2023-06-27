;----------------------------------------------
; plot a 2d contour map
;
; plot 4 panel hovmoller diagram for Mock Walker sims.
;
; increased default wsMaximumSize
;
; levi silvers                        jun 2023
;----------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;  print("filen is: "+filen)
  print("pathn is: "+pathn)
  print("varn  is: "+varn)

;ncl 'varn="rlut"' 'ntime="two"' 'filen="CAM6_MockW_2p5K_cos_295_3yr_2D_rlut.nc"' 'pathn="/glade/scratch/levi/RCEMIPII/CAM6/MockW_2p5K_cos_295_3yr/2D/"' hovmoller_contour_map.ncl

sst="300"

fn1="CAM6_MockW_0p625K_cos_"+sst+"_3yr_2D_rlut.nc"
fn2="CAM6_MockW_1p25K_cos_"+sst+"_3yr_2D_rlut.nc"
fn3="CAM6_MockW_2p5K_cos_"+sst+"_3yr_2D_rlut.nc"
fn4="CAM6_MockW_5K_cos_"+sst+"_3yr_2D_rlut.nc"

pathb="/glade/scratch/levi/RCEMIPII/CAM6/"

;filename_in=path+"CAM6_GCM_RCEmip_3KW1_2D_wap500.nc"
filename_in1=pathb+"MockW_0p625K_cos_"+sst+"_3yr/2D/"+fn1
filename_in2=pathb+"MockW_1p25K_cos_"+sst+"_3yr/2D/"+fn2
filename_in3=pathb+"MockW_2p5K_cos_"+sst+"_3yr/2D/"+fn3
filename_in4=pathb+"MockW_5K_cos_"+sst+"_3yr/2D/"+fn4

;maintitle="what are you doing?"
maintitle=varn
  print("infile is: "+filename_in1)
file1 = addfile(filename_in1,"r")
file2 = addfile(filename_in2,"r")
file3 = addfile(filename_in3,"r")
file4 = addfile(filename_in4,"r")

; I think the time frequency is hourly at the moment
timeone=300
time1=0
time2=17519

lat1=64
lat2=128
;lat1=0
;lat2=191
lon1=90
lon2=98

; look at a monthly average: 24*30=720

;field = file1->$varn(time1:time2,lat1:lat2,lon1:lon2)
;vars = (/"wap500","tabot","pr_avg","cl"/)

if (varn.eq."prw") then
  field  = file1->prw(time1:time2,lat1:lat2,lon1:lon2)
  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
  scale = 1.
  ;my_levels1 = (/20,22,24,26,28,30, \
  ;               32,34,36,38,40,42, \
  ;               44,46,48,50,52,54,56 /) ;19  need 1 more color than level
;  my_levels1 = (/20,21,23,24,25,26, \
;                 27,28,29,30,31,32, \
;                 33,34,35,36,37,38,39 /) ;19  need 1 more color than level
  ;my_levels1 = (/14,15,16,17,18,19, \
  ;               20,21,22,23,24,25, \
  ;               26,27,28,29,30,31,32 /) ;19  need 1 more color than level
  my_levels1 = (/10,12,14,16,18,20, \
                 22,24,26,28,30,32, \
                 34,36,38,40,42,44,46 /) ;19  need 1 more color than level
end if
if (varn.eq."prw_avg") then
  field = file1->prw_avg(time1:time2,lat1:lat2,lon1:lon2)
  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
  scale = 1.
  my_levels1 = (/20,22,24,26,28,30, \
                 32,34,36,38,40,42, \
                 44,46,48,50,52,54,56 /) ;19  need 1 more color than level
end if
if (varn.eq."pr") then
  field = file1->pr(time1:time2,lat1:lat2,lon1:lon2)
  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
  scale = 86.4e3
  my_levels1 = (/0,0.5,1,1.5,2,2.5, \
                 3,3.5,4,4.5,5,5.5, \
                 6,6.5,7,7.5,8,8.5,9 /) ;19  need 1 more color than level
end if
if (varn.eq."pr_avg") then
  field = file1->pr_avg(time1:time2,lat1:lat2,lon1:lon2)
  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
  scale = 86.4e3
  my_levels1 = (/0,0.5,1,1.5,2,2.5, \
                 3,3.5,4,4.5,5,5.5, \
                 6,6.5,7,7.5,8,8.5,9 /) ;19  need 1 more color than level
end if

if (varn.eq."rlut") then
  field = file1->rlut(time1:time2,lat1:lat2,lon1:lon2)
  field2 = file2->rlut(time1:time2,lat1:lat2,lon1:lon2)
  field3 = file3->rlut(time1:time2,lat1:lat2,lon1:lon2)
  field4 = file4->rlut(time1:time2,lat1:lat2,lon1:lon2)
  scale = 1.
  my_levels1 = (/ 30,35,40,45,50,55, \ 
                  60,65,70,75,80,85,90, \   
                  95,100,105,110,115,120,125, \ 
                  130,135,140,145,150,155,160, \ 
                  165,170,175,180,185,190,195, \ 
                  200,205,210,215,220,225,230, \ 
                  235,240,245,250,255,260,265, \ 
                  270,275,280,285,290,295,300 /) ;55  need 1 more color than level
end if

  printVarSummary(field)

  print("----------------------------------------------")
  print("varname is: "+varn)
  print(min(min(min(field))))
  print(max(max(max(field))))
  print("----------------------------------------------")

; average over the selected range of longitudes
if (ntime.eq."one") then
  var_to_plot=scale*field
else
  var2plota=scale*dim_avg_n(field,2)
  var2plotb=scale*dim_avg_n(field2,2)
  var2plotc=scale*dim_avg_n(field3,2)
  var2plotd=scale*dim_avg_n(field4,2)
end if

  print("----------------------------------------------")
  print("varname is: "+varn)
  print("dimensions of averaged var2plota are: "+dimsizes(var2plota))
  print("scaled var is: "+min(min(min(var2plota))))
  print("scaled var is: "+max(max(max(var2plota))))
  print("----------------------------------------------")

var2plota!0="time"
var2plota&time=field&time
var2plota!1="lat"
var2plota&lat=field&lat

var2plotb!0="time"
var2plotb&time=field2&time
var2plotb!1="lat"
var2plotb&lat=field2&lat

var2plotc!0="time"
var2plotc&time=field3&time
var2plotc!1="lat"
var2plotc&lat=field3&lat

var2plotd!0="time"
var2plotd&time=field4&time
var2plotd!1="lat"
var2plotd&lat=field4&lat


;************************************************

;my_colors1 = (/13,23,33,43,53,63, \
;               73,83,93,103,113,123, \
;               133,143,153,163,173,183,193,203 /);  \

if (varn.eq."pr_avg") then
  my_colors1 = (/145,125,120,115,110,105, \
               100,95,90,85,80,75, \
               70,65,60,55,50,45,40,35 /);  \
;else
;  my_colors1 = (/13,23,33,43,53,63, \
;               73,83,93,103,113,123, \
;               133,143,153,163,173,183,193,203 /);  \
end if

if (varn.eq."prw") then
  my_colors1 = (/128,123,118,113,108,103, \
                 98,93,88,83,78,73, \
                 68,63,58,53,48,43,38,33/); 
;  my_colors1 = (/13,23,33,43,53,63, \
;               73,83,93,103,113,123, \
;               133,143,153,163,173,183,193,203 /);  \
end if 

if (varn.eq."rlut") then
;  my_colors1 = (/18,20,22,24,26,28,30, \
;                 32,34,36,38,40,42,44, \; 
;                 46,48,50,52,54,56,58, \; 
;                 60,62,64,66,68,70,72, \; 
;                 74,76,78,80,82,84,86, \; 
;                 88,90,92,94,96,98,100, \; 
;                 102,104,106,108,110,112,114, \; 
;                 116,118,120,122,124,126,128/); need 56 colors ranging from 2 to 128, inverted 126 by 56 is 
  my_colors1 = (/4,6,8,10,12,14,16,    \;
                 18,20,22,24,26,28,30, \
                 32,34,36,38,40,42,44, \; 
                 46,48,50,52,54,56,58, \; 
                 60,62,64,66,68,70,72, \; 
                 74,76,78,80,82,84,86, \; 
                 88,90,92,94,96,98,100, \; 
                 104,108,112,116,120,124,128/); need 56 colors ranging from 2 to 128, inverted 126 by 56 is 
end if 

wks = gsn_open_wks("eps","testplot_map")          ; send graphics to PNG file

; default of wsMaximumSize is: 100000000
setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 400000000
end setvalues

;gsn_define_colormap(wks,"gui_default")
;gsn_define_colormap(wks,"WhBlGrYeRe")
;gsn_define_colormap(wks,"cmocean_balance")
if (varn.eq."rlut") then
  gsn_define_colormap(wks,"MPL_Greys")
else
  gsn_define_colormap(wks,"cmocean_balance")
end if

plot = new(4,graphic)

testw=0.2
testh=0.65

res                      = True

;res@vpWidthF             = 0.3
;res@vpHeightF            = 0.75

res@cnLinesOn            = False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels             = my_levels1
res@cnFillColors         = my_colors1
res@cnFillMode           = "RasterFill" 
;res@mpProjection         = "Mollweide"       ; choose projection
;res@mpOutlineOn          = False
;res@mpCenterLonF         = 180.
;res@mpCenterLatF         = 180.
;res@mpCenterLatF         = 0.
;res@mpGridAndLimbOn      = True              ; turn on lat/lon lines
;res@mpPerimOn            = False             ; turn off box around plot
;res@mpGridLatSpacingF    = 30.               ; spacing for lat lines
;res@mpGridLonSpacingF    = 30.               ; spacing for lon lines
;res@gsnPanelLabelBar     = True
res@lbLabelAngleF        = 90
res@cnLineLabelInterval  = 0
res@lbTitleString        = "kg m-2"
res@lbLabelBarOn      = False
res@pmLabelBarWidthF     = 0.3
res@pmLabelBarHeightF    = 0.06
;res@mpFillOn             = False
res@gsnDraw              = False
res@gsnFrame             = False
res@gsnMaximize          = True
res@gsnPaperOrientation  = "landscape"
 
res@cnFillOn             = True              ; color plot desired

;res@tiMainString         = maintitle
res@tiMainString         = "0.625" 
res@tiMainFontHeightF    = .018                               ; font height
res@tiYAxisString     = "  "
; far left
 res@vpXF            =   0.15
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour1 = gsn_csm_contour(wks,var2plota(:,:),res)  ; create the plot
res@tiMainString         = "1.25" 
res@tiYAxisString      = "  "
res@tmYLLabelsOn       = False
 res@vpXF              =   0.4
 res@vpYF              =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour2 = gsn_csm_contour(wks,var2plotb(:,:),res)  ; create the plot
res@tiMainString         = "2.5" 
res@tiYAxisString     = "  "
res@tmYLLabelsOn       = False
 res@vpXF            =   0.6
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour3 = gsn_csm_contour(wks,var2plotc(:,:),res)  ; create the plot
res@tiMainString         = "5" 
res@tiYAxisString     = "  "
res@tmYLLabelsOn       = False
 res@vpXF            =   0.70
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour4 = gsn_csm_contour(wks,var2plotd(:,:),res)  ; create the plot
plot(0) = contour1
plot(1) = contour2
plot(2) = contour3
plot(3) = contour4

respanel = True

resP                         = True
resP@txString                = " "
;resP@txString                = "good grief"
;resP@txString                = plottitle
resP@gsnPanelLabelBar        = True
resP@pmLabelBarWidthF    = 0.3
resP@pmLabelBarHeightF    = 0.06
resP@lbTitleOn           = True
resP@lbTitlePosition     = "Top"
resP@lbTitleString       = "mm/day"
resP@lbTitleFontHeightF  = 0.015
resP@lbLabelFontHeightF      = 0.015
resP@gsnPanelFigureStrings = (/"a.","b.","c.","d."/)
resP@gsnPanelFigureStringsFontHeightF = 0.015
resP@amJust                = "TopLeft"

gsn_panel(wks,plot,(/1,4/),respanel)

end
