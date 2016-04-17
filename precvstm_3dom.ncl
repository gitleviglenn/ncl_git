;===========================================================================;
; precvstm_convsgsp.ncl
;  
;   basic syntax (assuming input is fmn and twod!):
;   ncl precvstm_convsgsp.ncl -fmn -twod -timeMax=maxtimeplotted
; 
; plots the proportion of large-scale verses convective precipitation for 
; 3 different domain sizes.
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
  timeMax=100
else
  timeMax=timeMax
end if
timelen=timeMax-timemin+1
interv=timeMax-timemin
; Title
xtitle="time [days]"
;ytitle="Conv Precip/(Conv + Large Scale Precip) "
ytitle=" Precip [mm/day]"

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
title1="  50M"
title2="  12M"
title3="  3M"

; File 1
; open/reference desired file (use addfiles to reference multiple data file)
; convective precip 
; if you want read in a file from the command line: 
;infile = addfile(iFile+".nc","r")
;file1="/work/mh0287/users/levi/data/nwprce/rce_ecs/rce_ecs_20km_384gp_301_fldmn.nc"
;file1="/work/mh0287/users/levi/data/nwprce/rce_ecs/rce_ecs_20km_384gp_301_fldmn_2yrprecip.nc"
file1="../to_ecs/rce_ecs_20km_384gp_301_fldmn_2yrprecip.nc"
infile = addfile(file1,"r")
print("first file used is: "+file1)
  ;lev = infile->height(:)                       ; vertical levels

if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(timemin:timeMax,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(timemin:timeMax,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(timemin:timeMax,:,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(timemin:timeMax,:,:)
    end if
  end if
else
  print("data is structured")
end if

; gsp precip 
if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field4 = infile->$varname4$(:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname4$(:,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field4 = infile->$varname4$(timemin:timeMax,:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname4$(timemin:timeMax,:,:)
    end if
  end if
else
  print("data is structured")
end if

; compute the total precip
  field_50m_301_tot = field1+field4

; read in same variables from two more files
delete(infile)
; below is the path on mac
;infile = addfile("to_rce/rce_ecs/rce_ecs_20km_192gp_301_fldsummean.nc","r")
; below is the path on wizard

file2="../to_ecs/rce_ecs_20km_384gp_297_fldmn_2yrprecip.nc"
infile = addfile(file2,"r")
print("second file used is: "+file2)
      field1b = infile->$varname$(timemin:timeMax,:,:)
      field4b = infile->$varname4$(timemin:timeMax,:,:)
      field_50m_297_tot = field1b+field4b
delete(infile)

file3="../to_ecs/rce_ecs_20km_96gp_301_B_fldmn_010808th310810.nc"
infile = addfile(file3,"r")
print("third file used is: "+file3)
      field1c = infile->$varname$(timemin:timeMax,:,:)
      field4c = infile->$varname4$(timemin:timeMax,:,:)
      field_3m_301_tot = field1c+field4c

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
      field1_3m_297 = infile->$varname$(timemin:timeMax,:,:)
      field4_3m_297 = infile->$varname4$(timemin:timeMax,:,:)
      ;field1_3m_297 = infile->$varname$(newtimemin:tottimelen,:,:)
      ;field4_3m_297 = infile->$varname4$(newtimemin:tottimelen,:,:)
      field_3m_297_tot = field1_3m_297+field4_3m_297

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
      field1_12m_297 = infile->$varname$(timemin:timeMax,:,:)
      field4_12m_297 = infile->$varname4$(timemin:timeMax,:,:)
      ;field1_12m_297 = infile->$varname$(newtimemin:tottimelen,:,:)
      ;field4_12m_297 = infile->$varname4$(newtimemin:tottimelen,:,:)
      field_12m_297_tot = field1_12m_297+field4_12m_297

file6="../to_ecs/rce_ecs_20km_192gp_301_B_fldmn_010808th310810.nc"
infile = addfile(file6,"r")
print("fourth file used is: "+file6)
      field1_12m_301 = infile->$varname$(timemin:timeMax,:,:)
      field4_12m_301 = infile->$varname4$(timemin:timeMax,:,:)
      field_12m_301_tot = field1_12m_301+field4_12m_301

;file7="/work/mh0287/users/levi/data/nwprce/rce_ecs/rce_ecs_20km_768gp_297_fldmn_010808th310810.nc"
;infile = addfile(file6,"r")
;print("fourth file used is: "+file6)
;      field1_200m_297 = infile->$varname$(timemin:timeMax,:,:)
;      field4_200m_297 = infile->$varname4$(timemin:timeMax,:,:)
;      field_200m_297_tot = field1_200m_297+field4_200m_297

; for precip values in kg/m^2s we need to scale to convert to
; mm/day
scale=86400
; if plotting the relative percentage of total precip, no scaling is needed
;scale=1
print("Caution! fields scaled by :"+scale)

; compute a 5 day running mean to smooth the output a bit...
; for 2hr output intervals 5d runn mean needs an aveint=60
  aveint=1*360

; from file 1
  field1=scale*runave_n(field1,aveint,0,0)
  field_50m_301_tot=scale*runave_n(field_50m_301_tot,aveint,0,0)

; from file 2
  field1b=scale*runave_n(field1b,aveint,0,0)
  field_50m_297_tot=scale*runave_n(field_50m_297_tot,aveint,0,0)

; from file 3
  field1c=scale*runave_n(field1c,aveint,0,0)
  field_3m_301_tot=scale*runave_n(field_3m_301_tot,aveint,0,0)

; from file4
  field1_3m_297=scale*runave_n(field1_3m_297,aveint,0,0)
  field_3m_297_tot=scale*runave_n(field_3m_297_tot,aveint,0,0)

; from file5
  field1_12m_297=scale*runave_n(field1_12m_297,aveint,0,0)
  field_12m_297_tot=scale*runave_n(field_12m_297_tot,aveint,0,0)

; from file6
  field1_12m_301=scale*runave_n(field1_12m_301,aveint,0,0)
  field_12m_301_tot=scale*runave_n(field_12m_301_tot,aveint,0,0)

; often, the actual time is not so nice to plot as the x-axis
; instead simply use an integer array of same length as time
;finaltimeday=timelen/4 ; when output is in 6 hr intervals
finaltimeday=timelen/12.; when output is in 2 hr intervals
;timelen=dimsizes(time)
psuedotime=ispan(1,timelen,1)
print("timelen: "+timelen)
print("final time in days = "+finaltimeday)
print("psuedotime: "+dimsizes(psuedotime))
;timemax=psuedotime(timemax-1)
;lasttime=timemax-1

; timing for the plot
timeoffset=0 ; what in the dickens is this?  
; the offset is the starting point for the time axis
;scaledtime=psuedotime/4.+timeoffset
scaledtime=psuedotime/12.+timeoffset
timemmax=scaledtime(timelen-1)
lasttime=floattoint(timemmax-1)
; newtime is only used for plotting
;newtime=timeMax-1
newtime=timeMax
print("last time is "+lasttime)
print("newtime is: "+newtime)

print("scaledtime and timemin:newtime are used for plot")

;tdiff=finaltimeday-timeoffset
;print("offset - finaltimeday ="+tdiff)
print("offset must be less than final time!!")
print("timeoffset for time axis is "+timeoffset+"!!")
print("dim of scaledtime = "+dimsizes(scaledtime))
;print("scaledtime = "+scaledtime)

print("dimensions of field1")
print(dimsizes(field1))
print("max of field1:"+max(field1))

; open a workstation 
; apparantly png plots need to have draw(wks) at 
; the end of the program
 wks = gsn_open_wks("eps","testplot")

; set the thickness of the line
 lthick = 3.0
; create color table to use
        colors1 = (/"Black","SteelBlue","GoldenRod","OrangeRed","LawnGreen","DarkTurquoise","Blue","Red"/) 
; resources for the legend
  lgres                      = True
  lgres@xyLabelMode            = "Custom"
  ;lgres@xyExplicitLabels       = (/"1","2","3"/)  ; explicit labels
  lgres@xyLineLabelFontHeightF = 0.013                ; font height
  lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2)/)
  lgres@lgItemType           = "Lines"
  lgres@lgLabelFontHeightF   = .08
  lgres@vpWidthF             = 0.3        ; width of legend
  lgres@vpHeightF            = 0.17        ; height of legend
  lgres@lgLineThicknessF = lthick
  lgres@lgPerimThicknessF    = 2.0
  lgres@lgMonoDashIndex      = False
  ;lgres@lgDashIndex          = (/"0","0","0"/)
  lgres@lgDashIndexes          = (/"0","0","0"/)
  lgres@lgPerimOn            = False

; create resource for plot
 res = True     

; only reverse the y-axis when plotting in model levels
; res@trYReverse               = True     ; reverse the y-axis
; set up vertical axis limits
 res@trXMinF = timeoffset       
 res@trXMaxF = finaltimeday+timeoffset
 res@trYMinF = 3.0       
 res@trYMaxF = 5.0       
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
print("newtime is: "+newtime)
print("dim of Scaled time is: "+dimsizes(scaledtime))

; create plot

    res@xyLineColors  = colors1(0) 
 ;plot0 = gsn_csm_xy(wks,scaledtime,field1(timemin:newtime,0,0),res)
 ;plot0 = gsn_csm_xy(wks,scaledtime,field1(:,0,0),res)
 ;plot0 = gsn_csm_xy(wks,scaledtime,field_50m_301_tot(:,0,0),res)

    res@xyDashPattern = 0
    res@xyLineColors  = colors1(0) 
 ;plot1 = gsn_csm_xy(wks,scaledtime,field1b(timemin:newtime,0,0),res)
 plot1 = gsn_csm_xy(wks,scaledtime,field1b(:,0,0),res)
 ;plot1 = gsn_csm_xy(wks,scaledtime,field_50m_297_tot(:,0,0),res)
    res@xyDashPattern = 0
    res@xyLineColors  = colors1(2) 
 ;plot2 = gsn_csm_xy(wks,scaledtime,field1c(timemin:newtime,0,0),res)
 ;plot2 = gsn_csm_xy(wks,scaledtime,field1c(:,0,0),res)
 ;plot2 = gsn_csm_xy(wks,scaledtime,field_3m_301_tot(:,0,0),res)

    res@xyDashPattern = 0
    res@xyLineColors  = colors1(2) 
 plot3 = gsn_csm_xy(wks,scaledtime,field1_3m_297(:,0,0),res)
 ;plot3 = gsn_csm_xy(wks,scaledtime,field_3m_297_tot(:,0,0),res)

    res@xyDashPattern = 0
    res@xyLineColors  = colors1(1) 
 plot4 = gsn_csm_xy(wks,scaledtime,field1_12m_297(:,0,0),res)
; plot4 = gsn_csm_xy(wks,scaledtime,field_12m_297_tot(:,0,0),res)

    res@xyDashPattern = 0
    res@xyLineColors  = colors1(1) 
 ;plot5 = gsn_csm_xy(wks,scaledtime,field1_12m_301(:,0,0),res)
 ;plot5 = gsn_csm_xy(wks,scaledtime,field_12m_301_tot(:,0,0),res)
 overlay(plot1,plot3)
 overlay(plot1,plot4)
 ;overlay(plot1,plot2)
 ;overlay(plot1,plot5)
 ;overlay(plot1,plot0)

 labels = (/title1,title2,title3/)
 legend  = gsn_create_legend (wks, 3, labels, lgres)

 amres = True
 amres@amJust = "BottomRight"

 amres@amParallelPosF   = 0.42    ; Move legend to right
 amres@amOrthogonalPosF = 0.47     ; Move legend down

 annoid = gsn_add_annotation(plot1,legend,amres) ; add legend to plot

 draw(plot1)

 frame(wks)

end
