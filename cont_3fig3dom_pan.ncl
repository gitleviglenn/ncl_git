;----------------------------------------------------------------------------
;----create a panel plot with 9 contour figures of precip
;----levi silvers----11-2013
;---------------------------------------------------------------------------
; basic syntax
;   ncl lineplot.ncl 'iFile="path/file.nc"' 'iFile2="path/file.nc"' 
;                    'iFile3="path/file.nc"'
;
;   nclsh lineplot.ncl -iFile=path/file.nc -iFile2=path/file.nc 
;                    -iFile3=path/file.nc etc. -twod -fmn -nwp
;
; optional parameters: structured, twod, varname, fmn, nwp
; required parameters
; iFile         : "filename" input file (must be a NetCDF file)
;---------------------------------------------------------------------------
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
if (.not. isvar("var1")) then
  varname="rain_con_rate"
end if
  xtitle=varname
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "0"
end if

xtitle="default x"

; default title is "Vertical Profile"
if (.not. isvar("title")) then
  maintitle="Vertical Profile"
else
  maintitle=title
end if

; for plotting the same variable from all three incoming files: 
varname=varname
title1="varname"

plotTime = 590
;plotTime2 = 2390
;plotTime3 = 2400

plotTime3 = plotTime
plotTime2 = plotTime

; this should only be greater than 1 when precip is being plotted.
precipscale = 86400
;precipscale = 1

rad2deg = 45./atan(1.)   ; radians to degrees

; first grid file
if (isvar("gFile")) then
   gridfile = addfile(gFile,"r")
   clon = gridfile->clon(:)
   clat = gridfile->clat(:)
else
	if (Model.ne."unstructured") then
	  lon = infile->lon(:)                       ; longitude points
	  lat = infile->lat(:)                       ; latitude points
	else
	  clon = infile->clon(:)                       ; longitude points
	  clat = infile->clat(:)       
	end if
end if

if (Model.eq."unstructured") then
     x = clon*rad2deg
     y = clat*rad2deg
end if

; second grid file
delete(gridfile)
delete(clon)
delete(clat)
if (isvar("gFile2")) then
   gridfile = addfile(gFile2,"r")
   clon = gridfile->clon(:)
   clat = gridfile->clat(:)
else
  if (Model.ne."unstructured") then
    lon = infile->lon(:)                       ; longitude points
    lat = infile->lat(:)                       ; latitude points
  else
    clon = infile->clon(:)                       ; longitude points
    clat = infile->clat(:)       
  end if
end if

if (Model.eq."unstructured") then
     x2 = clon*rad2deg
     y2 = clat*rad2deg
end if

; third grid file
;
delete(gridfile)
delete(clon)
delete(clat)
;delete(lon)
;delete(lat)
if (isvar("gFile3")) then
   gridfile = addfile(gFile3,"r")
   clon = gridfile->clon(:)
   clat = gridfile->clat(:)
else
  if (Model.ne."unstructured") then
    lon = infile->lon(:)                       ; longitude points
    lat = infile->lat(:)                       ; latitude points
  else
    clon = infile->clon(:)                       ; longitude points
    clat = infile->clat(:)       
  end if
end if

if (Model.eq."unstructured") then
     x3 = clon*rad2deg
     y3 = clat*rad2deg
end if

; File 1
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(plotTime,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(plotTime,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(plotTime,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field1 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field1 = infile->$varname$(plotTime,:,:)
    end if
  end if
end if
;field1=field1

print ("field 1 max:"+max(field1))

; the precip needs to be converted to mm/day for comparison
field1 = precipscale*field1
print ("scaled field 1 max:"+max(field1))


; File 4
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile2+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime2,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime2,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime2,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime2,:,:)
    end if
  end if
end if

; the precip needs to be converted to mm/day for comparison
field2 = precipscale*field2
print ("scaled field 2 max:"+max(field2))

; File 7
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile3+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime3,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime3,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime3,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime3,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field3 = precipscale*field3
print ("scaled field 3 max:"+max(field3))

;------------------------------------------------------------------------
time = infile->time(:)                     ; time values

timemax=dimsizes(time)
lasttime=timemax-1

print(min(time))
print(max(time))
print("dimensions of field1")
print(dimsizes(field1))

; open a workstation 
 plot_type="eps"
 wks = gsn_open_wks(plot_type,"testplot")
 gsn_define_colormap(wks,"gui_default")
;create a plot array
 plot = new(3,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnLinesOn                = False
 res@cnLevelSelectionMode = "ManualLevels"
 res@cnMinLevelValF       = 0.
 res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 5                   ; label every other line
 res@cnLevelSpacingF      = 5.0

; if plotting total cloud cover use below:
; res@cnMinLevelValF       = 40.
; res@cnMaxLevelValF       = 100.
; res@cnLineLabelInterval  = 0                   
; res@cnLevelSpacingF      = 10.0

; res@cnCenterStringFontHeightF = 0.015
; res@cnCenterString            = "20km"

 res@gsnSpreadColors          = True
 res@gsnSpreadColorStart      = 2
 res@gsnSpreadColorEnd        = 20
 
 res@tmYLLabelsOn             = False
 res@tmXBLabelsOn             = False
 res@tmXTLabelsOn             = False

if (Model.eq."unstructured")
 res@sfXArray = x
 res@sfYArray = y
end if

 res@lbLabelBarOn             = False

; create plot Top Row
  res@tiXAxisString     = "1920X1920(km)"
 plot(0) = gsn_csm_contour(wks,field1,res)
;  res@tiXAxisString     = "301K; 20km"
; plot(1) = gsn_csm_contour(wks,field2,res)
;  res@tiXAxisString     = "305K; 20km"
; plot(2) = gsn_csm_contour(wks,field3,res)

; create plot Middle Row

; create resource for plot
 resmid = True     

 resmid@gsnDraw          = False
 resmid@gsnFrame         = False

; set up vertical axis limits
 resmid@cnInfoLabelOn            = False
 resmid@cnFillOn                 = True 
 resmid@cnLinesOn                = False
 resmid@cnLevelSelectionMode = "ManualLevels"
 resmid@cnMinLevelValF       = 0.
 resmid@cnMaxLevelValF       = 70.
 resmid@cnLineLabelInterval  = 5                   ; label every other line
 resmid@cnLevelSpacingF      = 5.0

;; if plotting total cloud cover use below:
; resmid@cnMinLevelValF       = 40.
; resmid@cnMaxLevelValF       = 100.
; resmid@cnLineLabelInterval  = 0                   
; resmid@cnLevelSpacingF      = 10.0

; resmid@cnCenterStringFontHeightF = 0.015
; resmid@cnCenterString            = "40km"

 resmid@gsnSpreadColors          = True
 resmid@gsnSpreadColorStart      = 2
 resmid@gsnSpreadColorEnd        = 20

 resmid@tmYLLabelsOn             = False
 resmid@tmXBLabelsOn             = False
 resmid@tmXTLabelsOn             = False

if (Model.eq."unstructured")
 resmid@sfXArray = x2
 resmid@sfYArray = y2
end if

 resmid@lbLabelBarOn             = False
  resmid@tiXAxisString     = "3840X3840(km)"
 plot(1) = gsn_csm_contour(wks,field2,resmid)

; create resbotource for plot
 resbot = True     

 resbot@gsnDraw          = False
 resbot@gsnFrame         = False

; set up vertical axis limits
 resbot@cnInfoLabelOn            = False
 resbot@cnFillOn                 = True 
 resbot@cnLinesOn                = False
 resbot@cnLevelSelectionMode = "ManualLevels"
; if plotting convective precip use below:
 resbot@cnMinLevelValF       = 0.
 resbot@cnMaxLevelValF       = 70.
 resbot@cnLineLabelInterval  = 5                   ; label every other line
 resbot@cnLevelSpacingF      = 5.0

;; if plotting total cloud cover use below:
; resbot@cnMinLevelValF       = 40.
; resbot@cnMaxLevelValF       = 100.
; resbot@cnLineLabelInterval  = 0                   
; resbot@cnLevelSpacingF      = 10.0

 resbot@gsnSpreadColors          = True
 resbot@gsnSpreadColorStart      = 2
 resbot@gsnSpreadColorEnd        = 20

 resbot@tmYLLabelsOn             = False
 resbot@tmXBLabelsOn             = False
 resbot@tmXTLabelsOn             = False

if (Model.eq."unstructured")
 resbot@sfXArray = x3
 resbot@sfYArray = y3
end if

 resbot@lbLabelBarOn             = False

  resbot@tiXAxisString     = "7680X7680 (km)"
 plot(2) = gsn_csm_contour(wks,field3,resbot)

 resP                     = True
 ;resP@txString            = "Conv Precip on Large Domain (7680km)^2"
 resP@txString            = "Convective Precip vs. Dom Size"
; resP@pmLabelBarWidthF    = 0.8
 resP@gsnPanelLabelBar    = True
 resP@lbLabelFontHeightF  = 0.012
 gsn_panel(wks,plot,(/1,3/),resP)

end
