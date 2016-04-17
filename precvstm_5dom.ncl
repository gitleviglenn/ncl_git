;===========================================================================;
; precvstm_convsgsp.ncl
;  
;   basic syntax (assuming input is fmn and twod!):
;   ncl precvstm_convsgsp.ncl -fmn -twod -timeMax=maxtimeplotted
; 
; plots the proportion of large-scale verses convective precipitation for 
; 3 different domain sizes.
;
; /Users/silvers/bin/nclsh precvstm_5dom.ncl -twod -timeMax=8700 -title=" "
;
; levi silvers                        Oct 2014
;===========================================================================;
; load necessary libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

if (.not. isvar("structured")) then
  Model = "unstructured"
else
  Model = "ICOHDC"
end if

; default variable to be plotted is zonal wind
if (.not. isvar("varname")) then
  varname="prm_u"
end if
  xtitle=varname
; default time step to plot is 0
; using the timeMin option does not work at the moment
; due to some idiotic indexing problem.  
if (.not. isvar("timeMin")) then
  timemin=20
else
  timemin=timeMin
end if

if (.not. isvar("timeMax")) then
  timeMax=720
else
  timeMax=timeMax
end if
if (timeMax .gt. 4200) then
  timeMax200m = 4200
else
  timeMax200m = timeMax
end if

timelen=timeMax-timemin+1
timelen2=timeMax200m-timemin+1
interv=timeMax-timemin
; Title
xtitle="time (days)"
;ytitle="Conv Precip/(Conv + Large Scale Precip) "
ytitle=" Precipitation (mm/day)"

;; default title is "Vertical Profile"
if (.not. isvar("title")) then
  maintitle="default title"
else
  maintitle=title
end if

; for plotting the same variable from all three incoming files: 
varname="rain_con_rate"
varname4="rain_gsp_rate"
;title1="res=20km"
title5="  200M"
title4="  50M"
title3="  12M"
title2="  3M"
title1="  3/4M"

; compute a 5 day running mean to smooth the output a bit...
; for 2hr output intervals 5d runn mean needs an aveint=60
aveint=1*360
sstval=0 ; 1 for sst=297, 0 for sst=301
print("sstval set to:"+sstval+"!!")

; for precip values in kg/m^2s we need to scale to convert to
; mm/day
scale=86400
; if plotting the relative percentage of total precip, no scaling is needed
print("Caution! fields scaled by :"+scale)

; File 1
; open/reference desired file (use addfiles to reference multiple data file)
; convective precip 
; if you want read in a file from the command line: 
;infile = addfile(iFile+".nc","r")
file1="../to_ecs/rce_ecs_20km_384gp_301_fldmn_2yrprecip.nc"
infile = addfile(file1,"r")
print("first file used is: "+file1)

print("data is field mn data")
if (.not. isvar("twod")) then
  field_50m_301 = infile->$varname$(timemin:timeMax,:,:,:)
  field_50m_301gsp = infile->$varname4$(timemin:timeMax,:,:,:)
else
  print("data is twod data")
  field_50m_301 = infile->$varname$(timemin:timeMax,:,:)
  field_50m_301gsp = infile->$varname4$(timemin:timeMax,:,:)
end if
; compute the total precip
  field_50m_301_tot = field_50m_301+field_50m_301gsp

; read in same variables from two more files
delete(infile)
file2="../to_ecs/rce_ecs_20km_384gp_297_fldmn_2yrprecip.nc"
infile = addfile(file2,"r")
print("second file used is: "+file2)
      field_50m_297 = infile->$varname$(timemin:timeMax,:,:)
      field_50m_297gsp = infile->$varname4$(timemin:timeMax,:,:)
      field_50m_297_tot = field_50m_297+field_50m_297gsp
print("Max val of field_50m_297:"+max(field_50m_297)+" field_50m_297gsp:"+max(field_50m_297gsp)+" field50m_297_tot:"+max(field_50m_297_tot))

delete(infile)
file3="../to_ecs/rce_ecs_20km_96gp_301_B_fldmn_010808th310810.nc"
infile = addfile(file3,"r")
print("third file used is: "+file3)
      field_3m_301 = infile->$varname$(timemin:timeMax,:,:)
      field_3m_301gsp = infile->$varname4$(timemin:timeMax,:,:)
      field_3m_301_tot = field_3m_301+field_3m_301gsp

delete(infile)
file4="../to_ecs/rce_ecs_20km_96gp_297_fldmn_0808th0718.nc"
infile = addfile(file4,"r")
print("fourth file used is: "+file4)
tottime=infile->time(:)
tottimelen=dimsizes(tottime)-1
print("tottimelen"+tottimelen)
timeint1=timeMax-timemin
newtimemin=tottimelen-timeMax+20
timeint2=tottimelen-newtimemin
print("time int is: "+timeint1)
print("later time int is: "+timeint2)
      field_3m_297 = infile->$varname$(timemin:timeMax,:,:)
      field_3m_297gsp = infile->$varname4$(timemin:timeMax,:,:)
      ;field1_3m_297 = infile->$varname$(newtimemin:tottimelen,:,:)
      ;field4_3m_297 = infile->$varname4$(newtimemin:tottimelen,:,:)
      field_3m_297_tot = field_3m_297+field_3m_297gsp

delete(infile)
file5="../to_ecs/rce_ecs_20km_192gp_297_fldmn_010808th010812_precip.nc"
infile = addfile(file5,"r")
print("fifth file used is: "+file5)
delete([/tottime,tottimelen,timeint1,newtimemin,timeint2/])
tottime=infile->time(:)
tottimelen=dimsizes(tottime)-1
print("tottimelen"+tottimelen)
timeint1=timeMax-timemin
newtimemin=tottimelen-timeMax+20
timeint2=tottimelen-newtimemin
print("time int is: "+timeint1)
print("later time int is: "+timeint2)
  field_12m_297 = infile->$varname$(timemin:timeMax,:,:)
  field_12m_297gsp = infile->$varname4$(timemin:timeMax,:,:)
  ;field1_12m_297 = infile->$varname$(newtimemin:tottimelen,:,:)
  ;field4_12m_297 = infile->$varname4$(newtimemin:tottimelen,:,:)
  field_12m_297_tot = field_12m_297+field_12m_297gsp

delete(infile)
file6="../to_ecs/rce_ecs_20km_192gp_301_B_fldmn_010808th310810.nc"
infile = addfile(file6,"r")
print("sixth file used is: "+file6)
  field_12m_301 = infile->$varname$(timemin:timeMax,:,:)
  field_12m_301gsp = infile->$varname4$(timemin:timeMax,:,:)
  field_12m_301_tot = field_12m_301+field_12m_301gsp

delete(infile)
file7="../to_ecs/rce_ecs_20km_48gp_301_fldmn.nc"
infile = addfile(file7,"r")
print("seventh file used is: "+file7)
  field_3b4m_301     = infile->$varname$(timemin:timeMax,:,:)
  field_3b4m_301gsp  = infile->$varname4$(timemin:timeMax,:,:)
  field_3b4m_301_tot = field_3b4m_301+field_3b4m_301gsp

delete(infile)
file8="../to_ecs/rce_ecs_20km_48gp_297_fldmn.nc"
infile = addfile(file8,"r")
print("eighth file used is: "+file8)
  field_3b4m_297     = infile->$varname$(timemin:timeMax,:,:)
  field_3b4m_297gsp  = infile->$varname4$(timemin:timeMax,:,:)
  field_3b4m_297_tot = field_3b4m_297+field_3b4m_297gsp

delete(infile)
;field_200m_297 = new(dimsizes(field_50m_297),float)
;field_200m_297gsp = new(dimsizes(field_50m_297),float)
;field_200m_297_tot = new(dimsizes(field_50m_297),float)
;field_200m_297=default_fillvalue("float")
;field_200m_297gsp=default_fillvalue("float")
;field_200m_297_tot=default_fillvalue("float")
;print("dimensions of field: "+dimsizes(field_200m_297))
file9="../to_ecs/rce_ecs_20km_768gp_301_prec_selvars_fldmn.nc"
infile = addfile(file9,"r")
print("ninth file used is: "+file9)
  field_200m_301     = infile->$varname$(timemin:timeMax200m,:,:)
  field_200m_301gsp  = infile->$varname4$(timemin:timeMax200m,:,:)
  field_200m_301_tot = field_200m_301+field_200m_301gsp
;print("dimensions of field: "+dimsizes(field_200m_297))

delete(infile)
file10="../to_ecs/rce_ecs_20km_768gp_297_prec_selvars_fldmn.nc"
infile = addfile(file10,"r")
print("tenth file used is: "+file10)
  field_200m_297     = infile->$varname$(timemin:timeMax200m,:,:)
  field_200m_297gsp  = infile->$varname4$(timemin:timeMax200m,:,:)
  field_200m_297_tot = field_200m_297+field_200m_297gsp

; from file 1
if (isvar("convp")) then
  print("plotting only convective precip")
  if (sstval .gt. 0) then
    print("plotting precip for sst=297")
    field_200m=scale*runave_n(field_200m_297,aveint,0,0)
    field_50m=scale*runave_n(field_50m_297,aveint,0,0)
    field_12m=scale*runave_n(field_12m_297,aveint,0,0)
    field_3m=scale*runave_n(field_3m_297,aveint,0,0)
    field_3b4m=scale*runave_n(field_3b4m_297,aveint,0,0)
  else; 301
    print("plotting precip for sst=301")
    field_200m=scale*runave_n(field_200m_301,aveint,0,0)
    field_50m=scale*runave_n(field_50m_301,aveint,0,0)
    field_12m=scale*runave_n(field_12m_301,aveint,0,0)
    field_3m=scale*runave_n(field_3m_301,aveint,0,0)
    field_3b4m=scale*runave_n(field_3b4m_301,aveint,0,0)
  end if
else ; total precip
  print("plotting total precip")
  if (sstval .gt. 0) then
    print("plotting precip for sst=297")
    field_200m=scale*runave_n(field_200m_297_tot,aveint,0,0)
    field_50m=scale*runave_n(field_50m_297_tot,aveint,0,0)
    field_12m=scale*runave_n(field_12m_297_tot,aveint,0,0)
    field_3m=scale*runave_n(field_3m_297_tot,aveint,0,0)
    field_3b4m=scale*runave_n(field_3b4m_297_tot,aveint,0,0)
  else ; 301
    print("plotting precip for sst=301")
    field_200m=scale*runave_n(field_200m_301_tot,aveint,0,0)
    field_50m=scale*runave_n(field_50m_301_tot,aveint,0,0)
    field_12m=scale*runave_n(field_12m_301_tot,aveint,0,0)
    field_3m=scale*runave_n(field_3m_301_tot,aveint,0,0)
    field_3b4m=scale*runave_n(field_3b4m_301_tot,aveint,0,0)
  end if
end if

; often, the actual time is not so nice to plot as the x-axis
; instead simply use an integer array of same length as time
;finaltimeday=timelen/4 ; when output is in 6 hr intervals
finaltimeday=timelen/12.; when output is in 2 hr intervals
;timelen=dimsizes(time)
psuedotime=ispan(1,timelen,1)
psuedotime2=ispan(1,timelen2,1)
print("timelen: "+timelen)
print("final time in days = "+finaltimeday)
print("psuedotime: "+dimsizes(psuedotime))

; timing for the plot
timeoffset=0   
; the offset is the starting point for the time axis
scaledtime=psuedotime/12.+timeoffset
scaledtime2=psuedotime2/12.+timeoffset

;tdiff=finaltimeday-timeoffset
print("offset must be less than final time!!")
print("timeoffset for time axis is "+timeoffset+"!!")
print("dim of scaledtime = "+dimsizes(scaledtime))

; open a workstation 
; apparantly png plots need to have draw(wks) at 
; the end of the program
 wks = gsn_open_wks("eps","testplot")
   gsn_define_colormap(wks,"CBR_drywet")

; set the thickness of the line
 lthick = 3.0
; create color table to use
;  colors1 = (/"LawnGreen","SteelBlue","GoldenRod","Black","OrangeRed"/)
  colors1 = (/8,9,10,11,12/) 
; resources for the legend
  lgres                      = True
  lgres@xyLabelMode          = "Custom"
  ;lgres@xyExplicitLabels       = (/"1","2","3"/)  ; explicit labels
  lgres@xyLineLabelFontHeightF = 0.015                ; font height
  lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2),colors1(3),colors1(4)/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .10
  lgres@vpWidthF             = 0.2        ; width of legend
  lgres@vpHeightF            = 0.18        ; height of legend
  lgres@lgLineThicknessF     = lthick
  lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False
  lgres@lgDashIndexes        = (/"0","0","0","16","16"/)
  lgres@lgPerimOn            = False

; create resource for plot
 res = True     

; only reverse the y-axis when plotting in model levels
; res@trYReverse               = True     ; reverse the y-axis
; set up vertical axis limits
 res@trXMinF = timeoffset       
 res@trXMaxF = finaltimeday+timeoffset
 ;res@trYMinF = 3.6       
 res@trYMinF = 0.0       
 res@trYMaxF = 5.5       
 ;res@trYMinF = -0.000015*scale      
 ;res@trYMaxF = 0.00009*scale   
 res@xyLineThicknessF = lthick
 res@tiMainString     = maintitle
 res@tiXAxisString    = xtitle
 res@tiYAxisString    = ytitle
 res@gsnFrame          = False

; check dimensions
;print("Scaled time is: "+scaledtime)
print("timemin is: "+timemin)
print("timeMax is: "+timeMax)
print("dim of Scaled time is: "+dimsizes(scaledtime))

; create plot

    res@xyDashPattern = 0
    res@xyLineColors  = colors1(0) 
 plot0 = gsn_csm_xy(wks,scaledtime,field_3b4m(:,0,0),res)
 round3b4=decimalPlaces(avg(field_3b4m),1,True)
 print("mean of field_3b4m is: "+avg(field_3b4m))
 print("rounded? "+round3b4)
 
    res@xyDashPattern = 0
    res@xyLineColors  = colors1(1) 
 plot1 = gsn_csm_xy(wks,scaledtime,field_3m(:,0,0),res)
 round3=decimalPlaces(avg(field_3m),1,True)
 print("rounded? "+round3)
 print("mean of field_3m is: "+avg(field_3m))
 
    res@xyDashPattern = 0
    res@xyLineColors  = colors1(2) 
 plot2 = gsn_csm_xy(wks,scaledtime,field_12m(:,0,0),res)
 round12=decimalPlaces(avg(field_12m),1,True)
 print("rounded? "+round12)
 print("mean of field_12m is: "+avg(field_12m))
 
    res@xyDashPattern = 16
    res@xyLineColors  = colors1(3) 
 plot3 = gsn_csm_xy(wks,scaledtime,field_50m(:,0,0),res)
 round50=decimalPlaces(avg(field_50m),1,True)
 print("rounded? "+round50)
 print("mean of field_50m is: "+avg(field_50m))

    res@xyDashPattern = 16
    res@xyLineColors  = colors1(4) 
 plot4 = gsn_csm_xy(wks,scaledtime2,field_200m(:,0,0),res)
 round200=decimalPlaces(avg(field_200m),1,True)
 print("rounded? "+round200)
 print("mean of field_200m is: "+avg(field_200m))
 
 overlay(plot0,plot1)
 overlay(plot0,plot2)
 overlay(plot0,plot3)
 overlay(plot0,plot4)

 labels = (/title1,title2,title3,title4,title5/)
 legend  = gsn_create_legend (wks, 5, labels, lgres)

 amres = True
 amres@amJust = "BottomRight"

 amres@amParallelPosF   = 0.42    ; Move legend to right
 amres@amOrthogonalPosF = 0.47     ; Move legend down

 annoid = gsn_add_annotation(plot0,legend,amres) ; add legend to plot

  polyres                   = True                       ; marker resources
  polyres@gsMarkerIndex     = 16                         ; index for circle
  polyres@gsMarkerSizeF     = .02                        ; size 
  polyres@gsLineThicknessF  = 5

  dataarr=(/4.67,4.92,5.11,5.20,5.21/)
  dataarrround=(/round3b4,round3,round12,round50,round200/)
  print("avg of avg precip: "+avg(dataarrround))
  avgrounded=avg(dataarrround)
  print("avgrounded "+avgrounded)
  ;diffarr=dataarrround-avg(dataarrround)
  diffarr=dataarrround-avgrounded
  print("array of differences: "+diffarr)
  percentdiff=diffarr/avgrounded
  print("percent diff "+percentdiff)

  hpos=(/710,710,710,710,710/)
  centers = new(5,graphic)

  do t=0,4
    polyres@gsMarkerColor = colors1(t)
    ;polyres@gsLineColor = colors1(t)
    print("1 "+hpos(t))
    print("2 "+dataarr(t))
    centers(t)   = gsn_add_polymarker(wks,plot0,hpos(t),dataarr(t),polyres)
    ;error_bar(t) = gsn_add_polyline(wks,plot,(/domsize(t),domsize(t)/),\
    ;(/dataup(t),datadn(t)/),polyres)
  end do

 draw(plot0)

 frame(wks)

end
