;***********************************************************************************
; lcceis_tseries.ncl
; 
; Function codes: see https://www.ncl.ucar.edu/Applications/fcodes.shtml
; for useful examples.  This is how I inserted superscipts in the axis labels
;
;***********************************************************************************
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin
;***********************************************************************************

datapath="~/data/amip_Long/"
;infile1=datapath+"armlane.nc"
infile2=datapath+"lcc_mlr_eis_pm60.nc"
;infile2=datapath+"whatisyourdamage.nc"
;f1=addfile(infile1,"r")
f2=addfile(infile2,"r")
;print("incoming file1 is: "+infile1)
print("incoming file2 is: "+infile2)

am2_lcc            = f2->am2_lcc_smooth(:)
am3_lcc            = f2->am3_lcc_smooth(:)
am4_lcc            = f2->am4_lcc_smooth(:)
am2_app_lcc            = f2->am2_applcc_smooth(:)
am3_app_lcc            = f2->am3_applcc_smooth(:)
am4_app_lcc            = f2->am4_applcc_smooth(:)
am2_sst_scaled            = f2->am2_sst_scaled(:)
am3_sst_scaled            = f2->am3_sst_scaled(:)
am4_sst_scaled            = f2->am4_sst_scaled(:)
;; from file 1
;  alpha_am4_f1           = f1->alpha_ensmbr_am4(:,:) 
;  alpha_ensmn_am4_f1     = f1->alpha_ensmn_am4(:) 
;  alpha_am3_f1           = f1->alpha_ensmbr_am3(:,:) 
;  alpha_ensmn_am3_f1     = f1->alpha_ensmn_am3(:) 
;  alpha_am2_f1           = f1->alpha_ensmbr_am2(:,:) 
;  alpha_ensmn_am2_f1     = f1->alpha_ensmn_am2(:) 
;
;  alpha_cre_am4_f1           = f1->alpha_cre_ensmbr_am4(:,:) 
;  alpha_cre_ensmn_am4_f1     = f1->alpha_cre_ensmn_am4(:) 
;  alpha_cre_am3_f1           = f1->alpha_cre_ensmbr_am3(:,:) 
;  alpha_cre_ensmn_am3_f1     = f1->alpha_cre_ensmn_am3(:) 
;  alpha_cre_am2_f1           = f1->alpha_cre_ensmbr_am2(:,:) 
;  alpha_cre_ensmn_am2_f1     = f1->alpha_cre_ensmn_am2(:) 
;
;  alpha_lcc_am4_f1           = f1->alpha_lcc_ensmbr_am4(:,:) 
;  alpha_lcc_ensmn_am4_f1     = f1->alpha_lcc_ensmn_am4(:) 
;  alpha_lcc_am3_f1           = f1->alpha_lcc_ensmbr_am3(:,:) 
;  alpha_lcc_ensmn_am3_f1     = f1->alpha_lcc_ensmn_am3(:) 
;  alpha_lcc_am2_f1           = f1->alpha_lcc_ensmbr_am2(:,:) 
;  alpha_lcc_ensmn_am2_f1     = f1->alpha_lcc_ensmn_am2(:) 
;
;
;;----------------------------------

time           = f2->TIME(:) 

;
;-----------------------------------------------------------
wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
;wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file

gsn_define_colormap(wks,"GMT_relief_oceanonly")

;am2fill="orange1"
am2fill="paleturquoise1"
am3fill="palegreen2"
am4fill="cornsilk3"

;am2line="royalblue1"
am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"

plot = new(1,graphic)

;res                   = True
;res@trYMinF           = -3.5
;res@trYMaxF           = 0.0
;res@trXMinF           = 1885
;res@trXMaxF           = 1990
;;res@tmYLLabelFontHeightF = 0.01
;res@tiYAxisFontHeightF = 0.011
;res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+")"
;res@tiXAxisString    = " "
;res@tmYROn            = False
;res@tmXTOn            = False
;res@tmXTBorderOn      = False
;res@tmYRBorderOn      = False
;res@gsnDraw           = False ; default: T
;res@gsnFrame          = False ; default: T
;
length=0.40
height=0.25
;
;res@vpWidthF          = length
;res@vpHeightF         = height
;
scalef=-1.



; fourth plot - --------------------------------------------------
res4                   = True
res4@trXMinF           = 1875
res4@trXMaxF           = 2000
res4@tiYAxisFontHeightF = 0.011
res4@tiYAxisString    = "Anomalous LCC (%)"
res4@tiXAxisString    = "Year"
res4@tmYROn            = False
res4@tmXTOn            = False
res4@tmXTBorderOn      = False
res4@tmYRBorderOn      = False
res4@gsnDraw           = False ; default: T
res4@gsnFrame          = False ; default: T

res4@xyLineThicknessF   = 2.0
res4@trYMinF           = -0.4
res4@trYMaxF           = 0.3

res4@vpWidthF          = length
res4@vpHeightF         = height

res4@vpWidthF          = .81
res4@vpHeightF         = .5
;res4@tiMainString      = "how"

res4@xyLineColors  = am2line
res4@xyLineThicknessF   = 3.0
am2_lcc_cloud   = gsn_csm_xy(wks,time,am2_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am2_alcc_cloud  = gsn_csm_xy(wks,time,am2_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am2_sst         = gsn_csm_xy(wks,time,am2_sst_scaled(:),res4) ; create filled xy plot
res4@xyLineColors  = am3line
res4@xyLineThicknessF   = 3.0
res4@xyDashPattern = 0
am3_lcc_cloud   = gsn_csm_xy(wks,time,am3_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am3_alcc_cloud  = gsn_csm_xy(wks,time,am3_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am3_sst         = gsn_csm_xy(wks,time,am3_sst_scaled(:),res4) ; create filled xy plot
res4@xyLineColors  = am4line
res4@xyLineThicknessF   = 3.0
res4@xyDashPattern = 0
am4_lcc_cloud   = gsn_csm_xy(wks,time,am4_lcc(:),res4) ; create filled xy plot
res4@xyLineThicknessF   = 1.5
am4_alcc_cloud  = gsn_csm_xy(wks,time,am4_app_lcc(:),res4) ; create filled xy plot
res4@xyDashPattern = 16
am4_sst         = gsn_csm_xy(wks,time,am4_sst_scaled(:),res4) ; create filled xy plot


overlay(am2_lcc_cloud,am2_alcc_cloud)
overlay(am2_lcc_cloud,am2_sst)
overlay(am2_lcc_cloud,am3_lcc_cloud)
overlay(am2_lcc_cloud,am3_alcc_cloud)
overlay(am2_lcc_cloud,am3_sst)
overlay(am2_lcc_cloud,am4_lcc_cloud)
overlay(am2_lcc_cloud,am4_alcc_cloud)
overlay(am2_lcc_cloud,am4_sst)

plot = am2_lcc_cloud

; -----------------------------------
;frame(wks)
respanel = True
;respanel@txString = "16 hp"
gsn_panel(wks,plot,(/1,1/),respanel)

end
