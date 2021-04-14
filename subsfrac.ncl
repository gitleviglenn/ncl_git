;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; subsfrac.ncl
;
; compute the subsidence fraction for CAMRCE simulations
;
; what dimension and frequency do we need to have for the omega field when
; computing the subsidence fraction?
;
; /glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large295/2D/CAM5_GCM_RCE_large295_2D_wap500.nc
; what is the frequency? it is hourly.  3 years comes out to 26280
;
; script from Brian and Kevin...
; glade/work/kareed/data_analysis/publications/wing_GMD_RCEMIP_description/aggregation_omega.ncl
;
; levi silvers                                         April 2020
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

file_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large295/2D/CAM5_GCM_RCE_large295_2D_wap500.nc"
file2_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large300/2D/CAM5_GCM_RCE_large300_2D_wap500.nc"
file3_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large305/2D/CAM5_GCM_RCE_large305_2D_wap500.nc"

;fileb_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large295/2D/CAM5_GCM_RCE_large295_2D_wap500.nc"
;file2b_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large300/2D/CAM5_GCM_RCE_large300_2D_wap500.nc"
;file3b_omega="/glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large305/2D/CAM5_GCM_RCE_large305_2D_wap500.nc"
fileb_omega="/glade/scratch/levi/RCEMIP/CAM6_GCM/RCE_large295/2D/CAM6_GCM_RCE_large295_2D_wap500.nc"
file2b_omega="/glade/scratch/levi/RCEMIP/CAM6_GCM/RCE_large300/2D/CAM6_GCM_RCE_large300_2D_wap500.nc"
file3b_omega="/glade/scratch/levi/RCEMIP/CAM6_GCM/RCE_large305/2D/CAM6_GCM_RCE_large305_2D_wap500.nc"

F0=addfile(file_omega,"r")
F1=addfile(file2_omega,"r")
F2=addfile(file3_omega,"r")

F0_c6=addfile(fileb_omega,"r")
F1_c6=addfile(file2b_omega,"r")
F2_c6=addfile(file3b_omega,"r")

time = F0->time
W0=F0->wap500
W1=F1->wap500
W2=F2->wap500

W0b=F0_c6->wap500
W1b=F1_c6->wap500
W2b=F2_c6->wap500

W0 = (/864.*W0/)
W1 = (/864.*W1/)
W2 = (/864.*W2/)

W0b = (/864.*W0b/)
W1b = (/864.*W1b/)
W2b = (/864.*W2b/)

W0_day = calculate_daily_values(W0,"avg",0,False)
W1_day = calculate_daily_values(W1,"avg",0,False)
W2_day = calculate_daily_values(W2,"avg",0,False)

W0b_day = calculate_daily_values(W0b,"avg",0,False)
W1b_day = calculate_daily_values(W1b,"avg",0,False)
W2b_day = calculate_daily_values(W2b,"avg",0,False)

printVarSummary(W0)

W0_day=where((W0_day .ge. 0),1.,0.)
W1_day=where((W1_day .ge. 0),1.,0.)
W2_day=where((W2_day .ge. 0),1.,0.)
W0b_day=where((W0b_day .ge. 0),1.,0.)
W1b_day=where((W1b_day .ge. 0),1.,0.)
W2b_day=where((W2b_day .ge. 0),1.,0.)
;;fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
; where(conditional, true value, false value)
;

; compute global mean
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
  lat  = F0->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  ;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))

endtime=1090

print("dimsizes of W0_day are: "+dimsizes(W0_day))

field0_weighted=new(endtime,float)
field1_weighted=new(endtime,float)
field2_weighted=new(endtime,float)

field0b_weighted=new(endtime,float)
field1b_weighted=new(endtime,float)
field2b_weighted=new(endtime,float)


do ti=0,endtime-1
  field0_weighted(ti)     = wgt_areaave(W0_day(ti,:,:),clat,1.0,0)
  field1_weighted(ti)     = wgt_areaave(W1_day(ti,:,:),clat,1.0,0)
  field2_weighted(ti)     = wgt_areaave(W2_day(ti,:,:),clat,1.0,0)
  ;print("weighted ave at time 1 ="+field_weighted(ti))
  field0b_weighted(ti)     = wgt_areaave(W0b_day(ti,:,:),clat,1.0,0)
  field1b_weighted(ti)     = wgt_areaave(W1b_day(ti,:,:),clat,1.0,0)
  field2b_weighted(ti)     = wgt_areaave(W2b_day(ti,:,:),clat,1.0,0)
end do

; calculate the standard deviation and variance of the last two years

stats_sub=new((/6,725/), double)

print("dimensions of field0_weighted are: "+dimsizes(field0_weighted))

field0_weighted2yr=field0_weighted(365::)
print("dimensions of field0_weighted2yr are: "+dimsizes(field0_weighted2yr))
stats_sub(0,:)=field0_weighted(365::) 
;f02y=dim_stat4_n(field0_weighted2yr,0)
field1_weighted2yr=field1_weighted(365::)
stats_sub(1,:)=field1_weighted(365::) 
;f12y=dim_stat4_n(field1_weighted2yr,0)
field2_weighted2yr=field2_weighted(365::)
stats_sub(2,:)=field2_weighted(365::) 
;f22y=dim_stat4_n(field2_weighted2yr,0)
;field3_weighted2yr=field3_weighted(365::)
stats_sub(3,:)=field0b_weighted(365::) 
;f32y=dim_stat4_n(field3_weighted2yr,0)
;field4_weighted2yr=field4_weighted(365::)
stats_sub(4,:)=field1b_weighted(365::) 
;f42y=dim_stat4_n(field4_weighted2yr,0)
;field5_weighted2yr=field5_weighted(365::)
stats_sub(5,:)=field2b_weighted(365::) 
;f52y=dim_stat4_n(field5_weighted2yr,0)

stats_2yr=dim_stat4_n(stats_sub,1)
  print("~!@#$%^&*()*&^%$#@!~")
print("statistics of sub time series for last two years: "+stats_2yr)
  print("~!@#$%^&*()*&^%$#@!~")


;var_w500 = omega_500->wap500(:,:,:)
;
;var_6a_mn=dim_avg_n(var_6a,0)
;
  print("~!@#$%^&*()*&^%$#@!~")
  print("~!@#$%^&*()*&^%$#@!~")

plotname = "w500_subfrac_comp_cam5"
wks = gsn_open_wks("eps",plotname)

clrs = read_colormap_file("GMT_paired")
res = True
res@gsnDraw = False
res@gsnFrame = False
;res@xyLineColors = (/"chocolate2","chocolate2","chocolate2","aquamarine3","aquamarine3","aquamarine3"/)
;res@xyLineThicknessF   = (/1.0,2.5,4.0,1.0,2.5,4.0/) 
res@xyDashPattern = 0
;res@xyLineThicknessF = 3.
;res@vpWidthF = 0.6
;res@vpHeightF = 0.2
res@vpWidthF = 0.5
res@vpHeightF = 0.5

res@tmXTOn = False
res@tmXTBorderOn = False
res@tmYROn = False
res@tmYRBorderOn = False
res@tmXBMinorOn = False
res@tmYLMinorOn = False
res@gsnLeftString = "Fraction of ~F33~w~F21~~B3~500    > 0"
res@tiYAxisString = "Subsidence Fraction"
res@tiXAxisString = "Time (years)"
;
res@trYMaxF = 0.85
res@trYMinF = 0.65
;;; 
res@trXMinF = 2
res@trXMaxF = 3.1
;
;
;print(W2_up)
;
fotime=fspan(1,1090,1090)
f0_runmn=runave_n_Wrap(field0_weighted,10,0,0)
f1_runmn=runave_n_Wrap(field1_weighted,10,0,0)
f2_runmn=runave_n_Wrap(field2_weighted,10,0,0)
f0b_runmn=runave_n_Wrap(field0b_weighted,10,0,0)
f1b_runmn=runave_n_Wrap(field1b_weighted,10,0,0)
f2b_runmn=runave_n_Wrap(field2b_weighted,10,0,0)
;
print("mean of cam5 295K sub frac: "+dim_avg_n(field0_weighted,0))
print("mean of cam5 300K sub frac: "+dim_avg_n(field1_weighted,0))
print("mean of cam5 305K sub frac: "+dim_avg_n(field2_weighted,0))
print("mean of cam6 295K sub frac: "+dim_avg_n(field0b_weighted,0))
print("mean of cam6 300K sub frac: "+dim_avg_n(field1b_weighted,0))
print("mean of cam6 305K sub frac: "+dim_avg_n(field2b_weighted,0))
;
;print("dimsizes of time are: "+dimsizes(time))
;print("dimsizes of field0_weighted are: "+dimsizes(field0_weighted))
;print("dimsizes of field1_weighted are: "+dimsizes(field1_weighted))
;print("dimsizes of field2_weighted are: "+dimsizes(field2_weighted))
; below can be used if to plot all at once, with no overlay, but then I am unsure how 
; to change line thickness...
;plot = gsn_csm_xy(wks, (/fotime/365,fotime/365,fotime/365,fotime/365,fotime/365,fotime/365/),\
;                       (/field0_weighted,field1_weighted,field2_weighted,field0b_weighted,field1b_weighted,field2b_weighted/),res)
res@xyLineThicknessF = 1.
res@xyLineColors = "chocolate2"
plot0 = gsn_csm_xy(wks, fotime/365,f0_runmn, res )
res@xyLineThicknessF = 2.5
res@xyLineColors = "chocolate2"
plot1 = gsn_csm_xy(wks, fotime/365,f1_runmn, res )
res@xyLineThicknessF = 4.0
res@xyLineColors = "chocolate2"
plot2 = gsn_csm_xy(wks, fotime/365,f2_runmn, res )
res@xyLineThicknessF = 1.
res@xyLineColors = "aquamarine3"
plot0b = gsn_csm_xy(wks, fotime/365,f0b_runmn, res )
res@xyLineThicknessF = 2.5
res@xyLineColors = "aquamarine3"
plot1b = gsn_csm_xy(wks, fotime/365,f1b_runmn, res )
res@xyLineThicknessF = 4.0
res@xyLineColors = "aquamarine3"
plot2b = gsn_csm_xy(wks, fotime/365,f2b_runmn, res )
;
overlay(plot0,plot1)
overlay(plot0,plot2)
overlay(plot0,plot0b)
overlay(plot0,plot1b)
overlay(plot0,plot2b)

plot=plot0
;;***********************************************
;; legend resources
;;***********************************************
 lgres                    = True
  lgres@lgLineColors       = (/"chocolate2","aquamarine3"/)
  lgres@lgLineThicknessF   = res@xyLineThicknessF  ; legend line thickness = contour line thickness
  lgres@lgMonoDashIndex    = True
  lgres@lgDashIndex        = 0
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
  lgres@vpWidthF           = 0.12           ; width of legend (NDC)
  lgres@vpHeightF          = 0.15           ; height of legend (NDC)
  lgres@lgPerimOn          = False
  
  lbid = gsn_create_legend(wks,2,(/"CAM5", "CAM6"/),lgres)         ; create legend

  amres = True
  amres@amParallelPosF   = 0.25		    ; move legend to the right
  amres@amOrthogonalPosF = -0.35             ; move the legend down
  annoid1 = gsn_add_annotation(plot,lbid,amres)   ; add legend to plot

; add dots representing the mean values of the precipitation...

polyres                         = True
polyres@gsMarkerIndex     = 16 
polyres@gsMarkerSizeF     = .01   
polyres@gsLineThicknessF  = 3.5

; cam5 is chocolate, has highest precip values, and largest variance
  dataarr=(/0.71,0.74,0.74,0.70,0.77,0.76/)
;           c5 ,c5 ,c5 ,c6 ,c6 ,c6
;          295,300,305 ,295,300,305
; var:    0.0001,.0002,.0003 ,0.0001,.0002,.0002
; std:    0.1, 0.17,0.22,0.1,.14,.17
sigma=(/0.01,0.014,0.017,0.01,0.014,0.014/) ; standard deviation
yup=(/-999.,-999.,-999.,-999.,-999.,-999./)
ydn=(/-999.,-999.,-999.,-999.,-999.,-999./)

; define vertical extent of bars showing std.
do t=0,5
  yup(t)=dataarr(t)+sigma(t)
  ydn(t)=dataarr(t)-sigma(t) 
end do

  hpos=(/3.0,3.00,3.02,3.02,3.00,3.02/)
  centers = new(6,graphic)
  varianc = new(6,graphic)

  color4markers=(/"chocolate2","chocolate2","chocolate2","aquamarine3","aquamarine3","aquamarine3"/)

  do t=0,5
    polyres@gsMarkerColor = color4markers(t) 
    polyres@gsLineColor = color4markers(t)
    print("1 "+hpos(t))
    print("2 "+dataarr(t))
    centers(t)   = gsn_add_polymarker(wks,plot(0),hpos(t),dataarr(t),polyres)
    varianc(t)   = gsn_add_polyline(wks,plot(0),(/hpos(t),hpos(t)/),(/yup(t),ydn(t)/),polyres)
  end do

 draw(plot0) ; this seems to output a mess....
 frame(wks)

;draw(plot)
;frame(wks)
;;
;; .brian

  print("you made it to the end you old fool")

end 

