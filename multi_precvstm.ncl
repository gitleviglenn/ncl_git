begin
;----------------------------------------------------------------------------
;----a simple ncl script that reads in a NetCDF file and outputs a line plot
;----levi silvers----9-2013
;---------------------------------------------------------------------------
; basic syntax
;   ncl lineplot.ncl 'iFile="path/file.nc"'
;
; required parameters
; iFile         : "filename" input file (must be a NetCDF file)
;---------------------------------------------------------------------------
; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

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
if (.not. isvar("timeStep")) then
  timeStep = "0"
end if

; Title
xtitle="time [6hr intervals]"
ytitle="Convective Precip [mm/day]"
maintitle="SST = 305K; Res = 20km"

;; default title is "Vertical Profile"
;if (.not. isvar("title")) then
;  maintitle="Vertical Profile"
;else
;  maintitle=title
;end if

; for precip values the vertical lev shoudln't matter because they are 2D
nlev=39

; for plotting the same variable from all three incoming files: 
varname="rain_con_rate"
title1="Dom=(7680km)^2"
varname2="rain_con_rate"
title2="Dom=(3840km)^2"
varname3="rain_con_rate"
title3="Dom=(1920km)^2"

plotTime = stringtointeger(timeStep)

; open/reference desired file (use addfiles to reference multiple data file)
; define variables 
; lon = infile->lon(:)                       ; longitude points
; lat = infile->lat(:)                       ; latitude points
; time = infile->time(:)                     ; time values
; precip = infile->prm_t(:,:,:)               ; depends on input file

; File 1
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")
if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(:,:,:)
    else
      print("data is twod data")
      ;field1 = infile->$varname$(plotTime,:)
      field1 = infile->$varname$(:,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(:,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(:,:,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(:,:,:)
    end if
  end if
end if

; File 2
; open/reference desired file (use addfiles to reference multiple data file)
 infile2 = addfile(iFile2+".nc","r")
if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field2 = infile2->$varname2$(:,:,:)
    else
      print("data is twod data")
      ;field2 = infile2->$varname2$(plotTime,:)
      field2 = infile2->$varname2$(:,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile2->$varname2$(plotTime,:,:,:)
    else
      print("data is twod data")
      field2 = infile2->$varname2$(:,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile2->$varname2$(:,:,:,:)
    else
      print("data is twod data")
      field2 = infile2->$varname2$(:,:,:)
    end if
  end if
end if

; File 3
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile3+".nc","r")
if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field3 = infile->$varname3$(:,:,:)
    else
      print("data is twod data")
      ;field3 = infile->$varname3$(plotTime,:)
      field3 = infile->$varname3$(:,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname3$(plotTime,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname3$(:,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname3$(:,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname3$(:,:,:)
    end if
  end if
end if

;varname4="z_ifc"
;varname5="z_mc"
;heightinf = infile ->$varname4$(0,:,0)
;heightmid = infile ->$varname5$(0,:,0)

  ;lev = infile->lev(:)                       ; vertical levels
  lev = infile->height(:)                       ; vertical levels
  time = infile->time(:)                     ; time values

timemax = 560
;timemax=dimsizes(time)
psuedotime=ispan(1,timemax,1)
lasttime=timemax-1

; for precip values in kg/m^2s we need to scale to convert to
; mm/day
scale=86400
field1=scale*field1
field2=scale*field2
field3=scale*field3
print("fields scaled by :"+scale)

print(min(time))
print(max(time))
print("dimensions of field1")
print(dimsizes(field1))
print("dimensions of field2")
print(dimsizes(field2))
print("dimensions of field3")
print(dimsizes(field3))

;print("field1"+field1(0,0,0))
;print("psuedotime"+psuedotime)
;print(field2(0,4,0))
;print(field3(0,4,0))

; open a workstation 
 wks = gsn_open_wks("eps","testplot")

; resources for the legend
        lgres                      = True
        lgres@xyLabelMode            = "Custom"
        lgres@xyExplicitLabels       = (/"1","2","3"/)  ; explicit labels
        lgres@xyLineLabelFontHeightF = 0.015                ; font height
        ;lgres@lgLineColors         = colors1
        ;lgres@lgItemType           = "Lines"
        lgres@lgLabelFontHeightF   = .17
        lgres@vpWidthF             = 0.25        ; width of legend
        lgres@vpHeightF            = 0.22        ; height of legend
        lgres@lgPerimThicknessF    = 2.0
        lgres@lgMonoDashIndex      = False
        ;lgres@lgDashIndex          = (/"0","1","2"/)
        ;lgres@lgDashIndexes          = (/"0","1","2"/)

; create resource for plot
 res = True     
; set the thickness of the line
 lthick = 2.0

; only reverse the y-axis when plotting in model levels
; res@trYReverse               = True     ; reverse the y-axis
; set up vertical axis limits
 res@trXMinF = 0       
 res@trXMaxF = timemax      
 res@trYMinF = 0       
 res@trYMaxF = 4.5       
 ;res@trYMinF = -0.000015*scale      
 ;res@trYMaxF = 0.00009*scale   
 res@xyLineThicknessF = lthick
 res@tiMainString     = maintitle
 res@tiXAxisString    = xtitle
 res@tiYAxisString    = ytitle
 res@gsnFrame          = False

; create plot
; field1 vs. lev plots model levs
; plot = gsn_xy(wks,field1(lasttime,0,:,0),lev,res)
; field1 vs. field3 plots height of levels
 ;plot1 = gsn_xy(wks,field1(lasttime,0,:,0),heightmid,res)
 ;plot2 = gsn_xy(wks,field2(lasttime,0,:,0),heightmid,res)
 ;plot3 = gsn_xy(wks,field3(lasttime,0,:,0),heightmid,res)
;	res@xyDashPattern = 0
; plot1 = gsn_csm_xy (wks,field1(0,:,0),heightmid,res)
;	res@xyDashPattern = 1
; plot2 = gsn_csm_xy (wks,field2(0,:,0),heightmid,res)
;	res@xyDashPattern = 2
; plot3 = gsn_csm_xy (wks,field3(0,:,0),heightmid,res)

	res@xyDashPattern = 0
 plot1 = gsn_csm_xy(wks,psuedotime,field1(:lasttime,0,0),res)
	res@xyDashPattern = 1
 plot2 = gsn_csm_xy(wks,psuedotime,field2(:lasttime,0,0),res)
	res@xyDashPattern = 2
 plot3 = gsn_csm_xy(wks,psuedotime,field3(:lasttime,0,0),res)

 overlay(plot1,plot2)
 overlay(plot1,plot3)

        labels = (/title1,title2,title3/)
        legend  = gsn_create_legend (wks, 3, labels, lgres)

        amres = True
        amres@amJust = "BottomRight"

        amres@amParallelPosF   = 0.45    ; Move legend to right
        amres@amOrthogonalPosF = 0.45     ; Move legend down

        annoid = gsn_add_annotation(plot1,legend,amres) ; add legend to plot

 draw(plot1)

 frame(wks)

end
