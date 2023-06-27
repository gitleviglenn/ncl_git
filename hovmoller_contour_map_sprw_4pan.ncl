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
;  print("pathn is: "+pathn)
;  print("varn  is: "+varn)

;ncl 'varn="rlut"' 'ntime="two"' 'filen="CAM6_MockW_2p5K_cos_295_3yr_2D_rlut.nc"' 'pathn="/glade/scratch/levi/RCEMIPII/CAM6/MockW_2p5K_cos_295_3yr/2D/"' hovmoller_contour_map.ncl

sst="300"

fn1a="CAM6_MockW_0p625K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
fn2a="CAM6_MockW_1p25K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
;fn3a="CAM6_MockW_0p625K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
;fn4a="CAM6_MockW_1p25K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
fn3a="CAM6_MockW_2p5K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
fn4a="CAM6_MockW_5K_cos_"+sst+"_1yr_CRH_2D_prw.nc"
fn1b="CAM6_MockW_0p625K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"
fn2b="CAM6_MockW_1p25K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"
;fn3b="CAM6_MockW_0p625K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"
;fn3b="CAM6_MockW_1p25K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"
fn3b="CAM6_MockW_2p5K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"
fn4b="CAM6_MockW_5K_cos_"+sst+"_1yr_CRH_2D_sprw.nc"

pathb="/glade/scratch/levi/RCEMIPII/CAM6/"

;filename_in=path+"CAM6_GCM_RCEmip_3KW1_2D_wap500.nc"
filename_in1a=pathb+"MockW_0p625K_cos_"+sst+"_1yr_CRH/2D/"+fn1a
filename_in2a=pathb+"MockW_1p25K_cos_"+sst+"_1yr_CRH/2D/"+fn2a
filename_in3a=pathb+"MockW_2p5K_cos_"+sst+"_1yr_CRH/2D/"+fn3a
filename_in4a=pathb+"MockW_5K_cos_"+sst+"_1yr_CRH/2D/"+fn4a
filename_in1b=pathb+"MockW_0p625K_cos_"+sst+"_1yr_CRH/2D/"+fn1b
filename_in2b=pathb+"MockW_1p25K_cos_"+sst+"_1yr_CRH/2D/"+fn2b
filename_in3b=pathb+"MockW_2p5K_cos_"+sst+"_1yr_CRH/2D/"+fn3b
filename_in4b=pathb+"MockW_5K_cos_"+sst+"_1yr_CRH/2D/"+fn4b

;maintitle="what are you doing?"
maintitle=varn
  print("infile is: "+filename_in1a)
file1a = addfile(filename_in1a,"r")
file2a = addfile(filename_in2a,"r")
file3a = addfile(filename_in3a,"r")
file4a = addfile(filename_in4a,"r")
file1b = addfile(filename_in1b,"r")
file2b = addfile(filename_in2b,"r")
file3b = addfile(filename_in3b,"r")
file4b = addfile(filename_in4b,"r")

; I think the time frequency is hourly at the moment
timeone=300
time1=0
time2=4800
;time2=8750

; how many lat and long points are there? 192X288
; so delta lat is about 1.1 degrees and
; delta lon is about 1.25 degrees
lat1=63
lat2=128
;lat1=0
;lat2=191
lon1=0
lon2=287

; look at a monthly average: 24*30=720

;field = file1->$varn(time1:time2,lat1:lat2,lon1:lon2)
;vars = (/"wap500","tabot","pr_avg","cl"/)

if (varn.eq."CRH") then
  field  = file1a->prw(time1:time2,lat1:lat2,lon1:lon2)
  field2a = file2a->prw(time1:time2,lat1:lat2,lon1:lon2)
  field3a = file3a->prw(time1:time2,lat1:lat2,lon1:lon2)
  field4a = file4a->prw(time1:time2,lat1:lat2,lon1:lon2)
  fieldb  = file1b->sprw(time1:time2,lat1:lat2,lon1:lon2)
  field2b = file2b->sprw(time1:time2,lat1:lat2,lon1:lon2)
  field3b = file3b->sprw(time1:time2,lat1:lat2,lon1:lon2)
  field4b = file4b->sprw(time1:time2,lat1:lat2,lon1:lon2)
  scale = 1.
  ;my_levels1 = (/10,12,14,16,18,20, \
  ;               22,24,26,28,30,32, \
  ;               34,36,38,40,42,44,46 /) ;19  need 1 more color than level
  ;my_levels1 = (/0.5,0.1,0.15,0.2,0.25,0.3, \
  ;               0.35,0.4,0.45,0.5,0.55,0.6, \
  ;               0.65,0.7,0.75,0.8,0.85,0.9,0.95 /) ;19  need 1 more color than level
  my_levels1 = (/0.1,0.125,0.15,0.175,0.2,0.225,0.25,0.275,0.3, \
                 0.325,0.35,0.375,0.4,0.425,0.45,0.475,0.5,0.525,0.55,0.575,0.6, \
                 0.625,0.65,0.675,0.7,0.725,0.75,0.775,0.8,0.825,0.85,0.875,0.9/) ; need 1 more color than level
  ;my_levels1 = (/0.025,0.05,0.075,0.1,0.125,0.15,0.175,0.2,0.225,0.25,0.275,0.3, \
  ;               0.325,0.35,0.375,0.4,0.425,0.45,0.475,0.5,0.525,0.55,0.575,0.6, \
  ;               0.625,0.65,0.675,0.7,0.725,0.75,0.775,0.8,0.825,0.85,0.875,0.9, \
  ;               0.925,0.95,0.975/) ;19 need 1 more color than level
end if
;if (varn.eq."prw_avg") then
;  field = file1->prw_avg(time1:time2,lat1:lat2,lon1:lon2)
;  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
;  scale = 1.
;  my_levels1 = (/20,22,24,26,28,30, \
;                 32,34,36,38,40,42, \
;                 44,46,48,50,52,54,56 /) ;19  need 1 more color than level
;end if
;if (varn.eq."pr") then
;  field = file1->pr(time1:time2,lat1:lat2,lon1:lon2)
;  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
;  scale = 86.4e3
;  my_levels1 = (/0,0.5,1,1.5,2,2.5, \
;                 3,3.5,4,4.5,5,5.5, \
;                 6,6.5,7,7.5,8,8.5,9 /) ;19  need 1 more color than level
;end if
;if (varn.eq."pr_avg") then
;  field = file1->pr_avg(time1:time2,lat1:lat2,lon1:lon2)
;  field2 = file2->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field3 = file3->prw(time1:time2,lat1:lat2,lon1:lon2)
;  field4 = file4->prw(time1:time2,lat1:lat2,lon1:lon2)
;  scale = 86.4e3
;  my_levels1 = (/0,0.5,1,1.5,2,2.5, \
;                 3,3.5,4,4.5,5,5.5, \
;                 6,6.5,7,7.5,8,8.5,9 /) ;19  need 1 more color than level
;end if

;if (varn.eq."rlut") then
;  field = file1->rlut(time1:time2,lat1:lat2,lon1:lon2)
;  field2 = file2->rlut(time1:time2,lat1:lat2,lon1:lon2)
;  field3 = file3->rlut(time1:time2,lat1:lat2,lon1:lon2)
;  field4 = file4->rlut(time1:time2,lat1:lat2,lon1:lon2)
;  scale = 1.
;  my_levels1 = (/ 30,35,40,45,50,55, \ 
;                  60,65,70,75,80,85,90, \   
;                  95,100,105,110,115,120,125, \ 
;                  130,135,140,145,150,155,160, \ 
;                  165,170,175,180,185,190,195, \ 
;                  200,205,210,215,220,225,230, \ 
;                  235,240,245,250,255,260,265, \ 
;                  270,275,280,285,290,295,300 /) ;55  need 1 more color than level
;end if

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
  var2plotb=scale*dim_avg_n(field2a,2)
  var2plotc=scale*dim_avg_n(field3a,2)
  var2plotd=scale*dim_avg_n(field4a,2)
  var2plotab=scale*dim_avg_n(fieldb,2)
  var2plotbb=scale*dim_avg_n(field2b,2)
  var2plotcb=scale*dim_avg_n(field3b,2)
  var2plotdb=scale*dim_avg_n(field4b,2)
end if

  print("----------------------------------------------")
  print("varname is: "+varn)
  print("dimensions of averaged var2plota are: "+dimsizes(var2plota))
  print("scaled var is: "+min(min(min(var2plota))))
  print("scaled var is: "+max(max(max(var2plota))))
  print("----------------------------------------------")

var2pl1=var2plota/var2plotab
var2pl2=var2plotb/var2plotbb
var2pl3=var2plotc/var2plotcb
var2pl4=var2plotd/var2plotdb

var2pl1!0="time"
var2pl1&time=field&time
var2pl1!1="lat"
var2pl1&lat=field&lat

var2pl2!0="time"
var2pl2&time=field&time
var2pl2!1="lat"
var2pl2&lat=field&lat

var2pl3!0="time"
var2pl3&time=field&time
var2pl3!1="lat"
var2pl3&lat=field&lat

var2pl4!0="time"
var2pl4&time=field&time
var2pl4!1="lat"
var2pl4&lat=field&lat

;************************************************

;;my_colors1 = (/13,23,33,43,53,63, \
;;               73,83,93,103,113,123, \
;;               133,143,153,163,173,183,193,203 /);  \
;
;if (varn.eq."pr_avg") then
;  my_colors1 = (/145,125,120,115,110,105, \
;               100,95,90,85,80,75, \
;               70,65,60,55,50,45,40,35 /);  \
;;else
;;  my_colors1 = (/13,23,33,43,53,63, \
;;               73,83,93,103,113,123, \
;;               133,143,153,163,173,183,193,203 /);  \
;end if

if (varn.eq."prw") then
  my_colors1 = (/128,123,118,113,108,103, \
                 98,93,88,83,78,73, \
                 68,63,58,53,48,43,38,33/); 
;  my_colors1 = (/13,23,33,43,53,63, \
;               73,83,93,103,113,123, \
;               133,143,153,163,173,183,193,203 /);  \
end if 

;if (varn.eq."rlut") then
;;  my_colors1 = (/18,20,22,24,26,28,30, \
;;                 32,34,36,38,40,42,44, \; 
;;                 46,48,50,52,54,56,58, \; 
;;                 60,62,64,66,68,70,72, \; 
;;                 74,76,78,80,82,84,86, \; 
;;                 88,90,92,94,96,98,100, \; 
;;                 102,104,106,108,110,112,114, \; 
;;                 116,118,120,122,124,126,128/); need 56 colors ranging from 2 to 128, inverted 126 by 56 is 
;  my_colors1 = (/13,14,15,16,18,20,22, \;
;                 24,26,28,30,32,34,36, \; 
;                 38,40,42,44,46,48,50, \; 
;                 54,58,62,66,72,76,80, \; 
;                 84,86,88,90,92,94,95, \; 
;                 96,97,98,99,100,101,102, \; 
;                 103,104,105,106,107,108,109/); need 56 colors ranging from 2 to 128, inverted 126 by 56 is 
;else
  ;my_colors1 = (/2,4,6,8,10,12,14, \; 6,8,10,12,14,16,    \;
  ;               16,18,20,22,24,26,28, \;
  ;               30,32,34,37,40,43,46, \;
  ;               49,52,55,58,61,64,67, \;
  ;               70,73,76,79,81,82,83, \;
  ;               84,85,86,87,88/)
; 33 contours levels, aboutish...
  my_colors1 = (/96,94,92,90,88,87,86,85,84,83,82,\; 11
                 81,75,70,65,60,55,50,\;  7
                 48,46,44,42,40,38,36,34,32,30,\ ; 10
                 28,26,24,22,20,18,16/); 34
;;                 10,8,6,4,2/)
;;  my_colors1 = (/85,84,83,82,81,80,79, \; 6,8,10,12,14,16,    \;
;;                 78,77,76,75,74,73,72, \;
;;                 71,70,69,68,67,66,65, \;
;;                 64,63,62,61,60,59,58, \;
;;                 57,56,55,54,53,52,51, \;
;;                 50,49,48,47,46,45,44, \;
;;                 43,42,39,36,33,30,27, \;
;;                 24,21,18,15,12,9,6/);
;;                 ;43,42,41,40,39,38,37, \;
;;                 ;36,35,34,33,32,31,30/);
;;  my_colors1 = (/4,6,8,10,12,14,16,    \;
;;                 18,20,22,24,26,28,30, \;
;;                 32,34,36,38,40,42,44, \; 
;;                 46,48,50,52,54,56,58, \; 
;;                 60,62,64,66,68,70,72, \; 
;;                 74,76,78,80,82,84,86, \; 
;;                 88,90,92,94,96,98,100, \; 
;;                 104,108,112,116,120,124,128/); need 56 colors ranging from 2 to 128, inverted 126 by 56 is 
;end if 

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
  ;gsn_define_colormap(wks,"cmocean_balance")
  gsn_define_colormap(wks,"MPL_jet")
end if

plot = new(4,graphic)

testw=0.2
testh=0.75

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
res@tiYAxisString     = "days "
printMinMax(var2pl1,1)
printMinMax(var2pl2,1)
printMinMax(var2pl3,1)
printMinMax(var2pl4,1)
; far left
 res@vpXF            =   0.15
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour1 = gsn_csm_contour(wks,var2pl1(:,:),res)  ; create the plot
res@tiMainString         = "1.25" 
res@tiYAxisString      = "  "
res@tmYLLabelsOn       = False
res@tmXBValues         = (/-30,-20,-10,0,10,20,30/)
res@tmXBLabels         = (/"30S","","","0","","","30N"/)
 res@vpXF              =   0.4
 res@vpYF              =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour2 = gsn_csm_contour(wks,var2pl2(:,:),res)  ; create the plot
res@tiMainString         = "2.5" 
res@tiYAxisString     = "  "
res@tmYLLabelsOn       = False
 res@vpXF            =   0.6
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour3 = gsn_csm_contour(wks,var2pl3(:,:),res)  ; create the plot
res@tiMainString         = "5" 
res@tiYAxisString     = "  "
res@tmYLLabelsOn       = False
 res@vpXF            =   0.70
 res@vpYF            =   0.85
 res@vpWidthF          = testw ; vpWidth and Height control box size
 res@vpHeightF         = testh ; default for both is 0.6 in NDC units
  contour4 = gsn_csm_contour(wks,var2pl4(:,:),res)  ; create the plot
;var2pl4
plot(0) = contour1
plot(1) = contour2
plot(2) = contour3
plot(3) = contour4

resP = True

resP                         = True
resP@txString                = " "
;resP@txString                = "good grief"
;resP@txString                = plottitle
resP@gsnPanelLabelBar        = True
resP@pmLabelBarWidthF    = 0.3
resP@pmLabelBarHeightF    = 0.06
resP@lbTitleOn           = False 
;resP@lbTitlePosition     = "Top"
;resP@lbTitleString       = "mm/day"
;resP@lbTitleString       = "mm/day"
resP@lbTitleFontHeightF  = 0.015
resP@lbLabelFontHeightF      = 0.015
resP@gsnPanelFigureStrings = (/"a.","b.","c.","d."/)
resP@gsnPanelFigureStringsFontHeightF = 0.015
resP@amJust                = "TopLeft"

gsn_panel(wks,plot,(/1,4/),resP)

end
