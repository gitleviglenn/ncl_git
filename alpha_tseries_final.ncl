;***********************************************************************************
; alpha_tseries.ncl
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
infile1=datapath+"armlane.nc"
infile2=datapath+"whatisyourdamage.nc"
f1=addfile(infile1,"r")
f2=addfile(infile2,"r")
print("incoming file1 is: "+infile1)
print("incoming file2 is: "+infile2)
; from file 1
  alpha_am4_f1           = f1->alpha_ensmbr_am4(:,:) 
  alpha_ensmn_am4_f1     = f1->alpha_ensmn_am4(:) 
  alpha_am3_f1           = f1->alpha_ensmbr_am3(:,:) 
  alpha_ensmn_am3_f1     = f1->alpha_ensmn_am3(:) 
  alpha_am2_f1           = f1->alpha_ensmbr_am2(:,:) 
  alpha_ensmn_am2_f1     = f1->alpha_ensmn_am2(:) 

  alpha_cre_am4_f1           = f1->alpha_cre_ensmbr_am4(:,:) 
  alpha_cre_ensmn_am4_f1     = f1->alpha_cre_ensmn_am4(:) 
  alpha_cre_am3_f1           = f1->alpha_cre_ensmbr_am3(:,:) 
  alpha_cre_ensmn_am3_f1     = f1->alpha_cre_ensmn_am3(:) 
  alpha_cre_am2_f1           = f1->alpha_cre_ensmbr_am2(:,:) 
  alpha_cre_ensmn_am2_f1     = f1->alpha_cre_ensmn_am2(:) 

  alpha_lcc_am4_f1           = f1->alpha_lcc_ensmbr_am4(:,:) 
  alpha_lcc_ensmn_am4_f1     = f1->alpha_lcc_ensmn_am4(:) 
  alpha_lcc_am3_f1           = f1->alpha_lcc_ensmbr_am3(:,:) 
  alpha_lcc_ensmn_am3_f1     = f1->alpha_lcc_ensmn_am3(:) 
  alpha_lcc_am2_f1           = f1->alpha_lcc_ensmbr_am2(:,:) 
  alpha_lcc_ensmn_am2_f1     = f1->alpha_lcc_ensmn_am2(:) 

;----------------------------------
  boohiss = f2->alpha_window_am4(:,:,:)
ensnumber=4

am2_satl_arr=new((/105,ensnumber+1/),float)
am2_sind_arr=new((/105,ensnumber+1/),float)
am2_epac_arr=new((/105,ensnumber+1/),float)
am2_trops1_arr=new((/105,ensnumber+1/),float)
am2_trops2_arr=new((/105,ensnumber+1/),float)
am2_trops3_arr=new((/105,ensnumber+1/),float)
am2_trops4_arr=new((/105,ensnumber+1/),float)
am2_trops5_arr=new((/105,ensnumber+1/),float)
am2_trops6_arr=new((/105,ensnumber+1/),float)

am3_satl_arr=new((/105,ensnumber+1/),float)
am3_sind_arr=new((/105,ensnumber+1/),float)
am3_epac_arr=new((/105,ensnumber+1/),float)
am3_trops1_arr=new((/105,ensnumber+1/),float)
am3_trops2_arr=new((/105,ensnumber+1/),float)
am3_trops3_arr=new((/105,ensnumber+1/),float)
am3_trops4_arr=new((/105,ensnumber+1/),float)
am3_trops5_arr=new((/105,ensnumber+1/),float)
am3_trops6_arr=new((/105,ensnumber+1/),float)

am4_satl_arr=new((/105,ensnumber+1/),float)
am4_sind_arr=new((/105,ensnumber+1/),float)
am4_epac_arr=new((/105,ensnumber+1/),float)
am4_trops1_arr=new((/105,ensnumber+1/),float)
am4_trops2_arr=new((/105,ensnumber+1/),float)
am4_trops3_arr=new((/105,ensnumber+1/),float)
am4_trops4_arr=new((/105,ensnumber+1/),float)
am4_trops5_arr=new((/105,ensnumber+1/),float)
am4_trops6_arr=new((/105,ensnumber+1/),float)

do c=0,ensnumber
  am4_ntrops = f2->alpha_window_am4(:,ensnumber,4)
  am4_strops = f2->alpha_window_am4(:,ensnumber,5)
; grap timeseries for the tropical windows
  am4_satl_arr(:,c)   = f2->alpha_window_am4(:,c,0)
  am4_sind_arr(:,c)   = f2->alpha_window_am4(:,c,1)
  am4_epac_arr(:,c)   = f2->alpha_window_am4(:,c,2)
; grap timeseries for the rest of the tropics
  am4_trops1_arr(:,c) = f2->alpha_window_am4(:,c,8)
  am4_trops2_arr(:,c) = f2->alpha_window_am4(:,c,9)
  am4_trops3_arr(:,c) = f2->alpha_window_am4(:,c,10)
  am4_trops4_arr(:,c) = f2->alpha_window_am4(:,c,11)
  am4_trops5_arr(:,c) = f2->alpha_window_am4(:,c,12)
  am4_trops6_arr(:,c) = f2->alpha_window_am4(:,c,13)
; grap timeseries for the tropical windows
  am3_satl_arr(:,c)   = f2->alpha_window_am3(:,c,0)
  am3_sind_arr(:,c)   = f2->alpha_window_am3(:,c,1)
  am3_epac_arr(:,c)   = f2->alpha_window_am3(:,c,2)
; grap timeseries for the rest of the tropics
  am3_trops1_arr(:,c) = f2->alpha_window_am3(:,c,8)
  am3_trops2_arr(:,c) = f2->alpha_window_am3(:,c,9)
  am3_trops3_arr(:,c) = f2->alpha_window_am3(:,c,10)
  am3_trops4_arr(:,c) = f2->alpha_window_am3(:,c,11)
  am3_trops5_arr(:,c) = f2->alpha_window_am3(:,c,12)
  am3_trops6_arr(:,c) = f2->alpha_window_am3(:,c,13)
; grap timeseries for the tropical windows
  am2_satl_arr(:,c)   = f2->alpha_window_am2(:,c,0)
  am2_sind_arr(:,c)   = f2->alpha_window_am2(:,c,1)
  am2_epac_arr(:,c)   = f2->alpha_window_am2(:,c,2)
; grap timeseries for the rest of the tropics
  am2_trops1_arr(:,c) = f2->alpha_window_am2(:,c,8)
  am2_trops2_arr(:,c) = f2->alpha_window_am2(:,c,9)
  am2_trops3_arr(:,c) = f2->alpha_window_am2(:,c,10)
  am2_trops4_arr(:,c) = f2->alpha_window_am2(:,c,11)
  am2_trops5_arr(:,c) = f2->alpha_window_am2(:,c,12)
  am2_trops6_arr(:,c) = f2->alpha_window_am2(:,c,13)
end do

am2_satl=dim_avg_n(am2_satl_arr,1)
am2_sind=dim_avg_n(am2_sind_arr,1)
am2_epac=dim_avg_n(am2_epac_arr,1)
am2_trops1=dim_avg_n(am2_trops1_arr,1)
am2_trops2=dim_avg_n(am2_trops2_arr,1)
am2_trops3=dim_avg_n(am2_trops3_arr,1)
am2_trops4=dim_avg_n(am2_trops4_arr,1)
am2_trops5=dim_avg_n(am2_trops5_arr,1)
am2_trops6=dim_avg_n(am2_trops6_arr,1)

am3_satl=dim_avg_n(am3_satl_arr,1)
am3_sind=dim_avg_n(am3_sind_arr,1)
am3_epac=dim_avg_n(am3_epac_arr,1)
am3_trops1=dim_avg_n(am3_trops1_arr,1)
am3_trops2=dim_avg_n(am3_trops2_arr,1)
am3_trops3=dim_avg_n(am3_trops3_arr,1)
am3_trops4=dim_avg_n(am3_trops4_arr,1)
am3_trops5=dim_avg_n(am3_trops5_arr,1)
am3_trops6=dim_avg_n(am3_trops6_arr,1)

am4_satl=dim_avg_n(am4_satl_arr,1)
am4_sind=dim_avg_n(am4_sind_arr,1)
am4_epac=dim_avg_n(am4_epac_arr,1)
am4_trops1=dim_avg_n(am4_trops1_arr,1)
am4_trops2=dim_avg_n(am4_trops2_arr,1)
am4_trops3=dim_avg_n(am4_trops3_arr,1)
am4_trops4=dim_avg_n(am4_trops4_arr,1)
am4_trops5=dim_avg_n(am4_trops5_arr,1)
am4_trops6=dim_avg_n(am4_trops6_arr,1)

  am4_tropsrest   = am4_trops1+am4_trops2+am4_trops3+am4_trops4+am4_trops5+am4_trops6
  am4_tropwinds   = am4_satl+am4_sind+am4_epac
  am4_tropsrest   = am4_trops1+am4_trops2+am4_trops3+am4_trops4+am4_trops5+am4_trops6

  am3_ntrops = f2->alpha_window_am3(:,ensnumber,4)
  am3_strops = f2->alpha_window_am3(:,ensnumber,5)
; grap timeseries for the tropical windows
  am3_satl   = f2->alpha_window_am3(:,ensnumber,0)
  am3_sind   = f2->alpha_window_am3(:,ensnumber,1)
  am3_epac   = f2->alpha_window_am3(:,ensnumber,2)
; grap timeseries for the rest of the tropics
  am3_trops1 = f2->alpha_window_am3(:,ensnumber,8)
  am3_trops2 = f2->alpha_window_am3(:,ensnumber,9)
  am3_trops3 = f2->alpha_window_am3(:,ensnumber,10)
  am3_trops4 = f2->alpha_window_am3(:,ensnumber,11)
  am3_trops5 = f2->alpha_window_am3(:,ensnumber,12)
  am3_trops6 = f2->alpha_window_am3(:,ensnumber,13)

  am3_tropsrest   = am3_trops1+am3_trops2+am3_trops3+am3_trops4+am3_trops5+am3_trops6
  am3_tropwinds   = am3_satl+am3_sind+am3_epac
  am3_tropsrest   = am3_trops1+am3_trops2+am3_trops3+am3_trops4+am3_trops5+am3_trops6

  am2_ntrops = f2->alpha_window_am2(:,ensnumber,4)
  am2_strops = f2->alpha_window_am2(:,ensnumber,5)
; grap timeseries for the tropical windows
  am2_satl   = f2->alpha_window_am2(:,ensnumber,0)
  am2_sind   = f2->alpha_window_am2(:,ensnumber,1)
  am2_epac   = f2->alpha_window_am2(:,ensnumber,2)
; grap timeseries for the rest of the tropics
  am2_trops1 = f2->alpha_window_am2(:,ensnumber,8)
  am2_trops2 = f2->alpha_window_am2(:,ensnumber,9)
  am2_trops3 = f2->alpha_window_am2(:,ensnumber,10)
  am2_trops4 = f2->alpha_window_am2(:,ensnumber,11)
  am2_trops5 = f2->alpha_window_am2(:,ensnumber,12)
  am2_trops6 = f2->alpha_window_am2(:,ensnumber,13)

  am2_tropsrest   = am2_trops1+am2_trops2+am2_trops3+am2_trops4+am2_trops5+am2_trops6
  am2_tropwinds   = am2_satl+am2_sind+am2_epac
  am2_tropsrest   = am2_trops1+am2_trops2+am2_trops3+am2_trops4+am2_trops5+am2_trops6

;----------------------------------

  time           = f1->TIME(:) 

; name dimesions
alpha_am4_f1!0 = "year"
alpha_am4_f1!1 = "ensnum"
print("dimsizes of alpha_am4_f1 are: "+dimsizes(alpha_am4_f1))


mnmx = new((/6,105/), float)
mnmx(0,:) = dim_min( alpha_am4_f1)
mnmx(1,:) = dim_max( alpha_am4_f1)
mnmx(2,:) = dim_min( alpha_am3_f1)
mnmx(3,:) = dim_max( alpha_am3_f1)
mnmx(4,:) = dim_min( alpha_am2_f1)
mnmx(5,:) = dim_max( alpha_am2_f1)

mnmx_cre = new((/6,105/), float)
mnmx_cre(0,:) = dim_min( alpha_cre_am4_f1)
mnmx_cre(1,:) = dim_max( alpha_cre_am4_f1)
mnmx_cre(2,:) = dim_min( alpha_cre_am3_f1)
mnmx_cre(3,:) = dim_max( alpha_cre_am3_f1)
mnmx_cre(4,:) = dim_min( alpha_cre_am2_f1)
mnmx_cre(5,:) = dim_max( alpha_cre_am2_f1)

mnmx_lcc = new((/6,105/), float)
mnmx_lcc(0,:) = dim_min( alpha_lcc_am4_f1)
mnmx_lcc(1,:) = dim_max( alpha_lcc_am4_f1)
mnmx_lcc(2,:) = dim_min( alpha_lcc_am3_f1)
mnmx_lcc(3,:) = dim_max( alpha_lcc_am3_f1)
mnmx_lcc(4,:) = dim_min( alpha_lcc_am2_f1)
mnmx_lcc(5,:) = dim_max( alpha_lcc_am2_f1)

;-----------------------------------------------------------
;wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file

gsn_define_colormap(wks,"GMT_relief_oceanonly")

;am2fill="orange1"
am2fill="paleturquoise1"
am3fill="palegreen2"
am4fill="cornsilk3"

;am2line="royalblue1"
am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"

plot = new(4,graphic)

res                   = True
res@trYMinF           = -3.5
res@trYMaxF           = 0.0
res@trXMinF           = 1885
res@trXMaxF           = 1990
;res@tmYLLabelFontHeightF = 0.01
res@tiYAxisFontHeightF = 0.011
res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+")"
res@tiXAxisString    = " "
res@tmYROn            = False
res@tmXTOn            = False
res@tmXTBorderOn      = False
res@tmYRBorderOn      = False
res@gsnDraw           = False ; default: T
res@gsnFrame          = False ; default: T

length=0.40
height=0.25

res@vpWidthF          = length
res@vpHeightF         = height

scalef=-1.


res@gsnXYFillColors = am2fill 
res@xyLineColor     = -1
am2_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(4:5,:),res) ; create filled xy plot

res@gsnXYFillColors = am3fill
res@xyLineColor     = -1
am3_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(2:3,:),res) ; create filled xy plot

res@gsnXYFillColors = am4fill
res@xyLineColor     = -1
am4_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(0:1,:),res) ; create filled xy plot

res@xyLineThicknessF   = 3.0
res@xyLineColors  = am2line
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

res@xyLineColors  = am3line
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineColors  = am4line
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

overlay(am2_cloud,am3_cloud)
overlay(am2_cloud,am4_cloud)
overlay(am2_cloud,ens_am2mn)
overlay(am2_cloud,ens_am3mn)
overlay(am2_cloud,ens_am4mn)
plot(0) = am2_cloud

; second plot - --------------------------------------------------
res@vpWidthF          = length
res@vpHeightF         = height
res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+")"
res@tiXAxisString    = " "
res@xyLineColors  = am4line
res@xyLineThicknessF   = 1.0

res@xyDashPattern = 16
tropwinds_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropwinds(:),res)
res@xyDashPattern = 0
tropsrest_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropsrest(:),res)

res@xyLineThicknessF   = 3.0
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

res@xyLineColors  = am3line
res@xyLineThicknessF   = 1.0
res@xyDashPattern = 16
tropwinds_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropwinds(:),res)
res@xyDashPattern = 0
tropsrest_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropsrest(:),res)

res@xyLineThicknessF   = 3.0
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineColors  = am2line
res@xyLineThicknessF   = 1.0
res@xyDashPattern = 16
tropwinds_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropwinds(:),res)
res@xyDashPattern = 0
tropsrest_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropsrest(:),res)

res@xyLineThicknessF   = 3.0
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

overlay(tropwinds_am4mn,tropwinds_am2mn)
overlay(tropwinds_am4mn,tropwinds_am3mn)
overlay(tropwinds_am4mn,tropsrest_am2mn)
overlay(tropwinds_am4mn,tropsrest_am3mn)
overlay(tropwinds_am4mn,tropsrest_am4mn)
overlay(tropwinds_am4mn,ens_am2mn)
overlay(tropwinds_am4mn,ens_am3mn)
overlay(tropwinds_am4mn,ens_am4mn)

plot(1) = tropwinds_am4mn

; third plot - ---------------------------------------------------
res3                   = True
res3@trXMinF           = 1885
res3@trXMaxF           = 1990
res3@tiYAxisFontHeightF = 0.011
res3@tiYAxisString    = "Cloud feedback parameter (W "+"m~S~-2~NN~K~S~-1"+")"
res3@tiXAxisString    = "Year"
res3@tmYROn            = False
res3@tmXTOn            = False
res3@tmXTBorderOn      = False
res3@tmYRBorderOn      = False
res3@gsnDraw           = False ; default: T
res3@gsnFrame          = False ; default: T

res3@xyLineThicknessF   = 1.0
res3@xyLineColor     = -1
res3@trYMinF           = -1.5
res3@trYMaxF           = 1.5

res3@vpWidthF          = length
res3@vpHeightF         = height
;res3@tiMainString      = "where"

scalef=1.0

res3@xyLineColor     = -1
res3@gsnXYFillColors = am2fill 
res3@xyLineColor     = -1
am2_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(4:5,:),res3) ; create filled xy plot
res3@xyLineColor     = -1
res3@gsnXYFillColors = am3fill 
res3@xyLineColor     = -1
am3_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(2:3,:),res3) ; create filled xy plot
res3@xyLineColor     = -1
res3@gsnXYFillColors = am4fill
res3@xyLineColor     = -1
am4_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(0:1,:),res3) ; create filled xy plot

res3@xyLineThicknessF   = 3.0
res3@xyLineColors  = am2line
ens_cre_am2mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am2_f1(:),res3)

res3@xyLineColors  = am3line
ens_cre_am3mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am3_f1(:),res3)

res3@xyLineColors  = am4line
ens_cre_am4mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am4_f1(:),res3)

overlay(am2_cre_cloud,am3_cre_cloud)
overlay(am2_cre_cloud,am4_cre_cloud)
overlay(am2_cre_cloud,ens_cre_am2mn)
overlay(am2_cre_cloud,ens_cre_am3mn)
overlay(am2_cre_cloud,ens_cre_am4mn)

plot(2) = am2_cre_cloud

; fourth plot - --------------------------------------------------
res4                   = True
res4@trXMinF           = 1885
res4@trXMaxF           = 1990
res4@tiYAxisFontHeightF = 0.011
res4@tiYAxisString    = "Cloud anomaly parameter (% "+"K~S~-1"+")"
res4@tiXAxisString    = "Year"
res4@tmYROn            = False
res4@tmXTOn            = False
res4@tmXTBorderOn      = False
res4@tmYRBorderOn      = False
res4@gsnDraw           = False ; default: T
res4@gsnFrame          = False ; default: T

res4@xyLineThicknessF   = 1.0
res4@xyLineColor     = -1
res4@trYMinF           = -1.5
res4@trYMaxF           = 1.5

res4@vpWidthF          = length
res4@vpHeightF         = height

;res4@vpWidthF          = .81
;res4@vpHeightF         = .5
;res4@tiMainString      = "how"

scalef=1.0

res4@xyLineColor     = -1
res4@gsnXYFillColors = am2fill 
res4@xyLineColor     = -1
am2_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(4:5,:),res4) ; create filled xy plot
res4@xyLineColor     = -1
res4@gsnXYFillColors = am3fill
res4@xyLineColor     = -1
am3_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(2:3,:),res4) ; create filled xy plot
res4@xyLineColor     = -1
res4@gsnXYFillColors = am4fill
res4@xyLineColor     = -1
am4_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(0:1,:),res4) ; create filled xy plot

res4@xyLineThicknessF   = 3.0
res4@xyLineColors  = am2line
ens_lcc_am2mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am2_f1(:),res4)

res4@xyLineColors  = am3line
ens_lcc_am3mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am3_f1(:),res4)

res4@xyLineColors  = am4line
ens_lcc_am4mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am4_f1(:),res4)


overlay(am2_lcc_cloud,am3_lcc_cloud)
overlay(am2_lcc_cloud,am4_lcc_cloud)
overlay(am2_lcc_cloud,ens_lcc_am2mn)
overlay(am2_lcc_cloud,ens_lcc_am3mn)
overlay(am2_lcc_cloud,ens_lcc_am4mn)

plot(3) = am2_lcc_cloud

; -----------------------------------
;frame(wks)
respanel = True
respanel@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/)
respanel@amJust = "TopLeft"
;respanel@txString = "16 hp"
gsn_panel(wks,plot,(/2,2/),respanel)

end
