begin
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

if (.not. isvar("structured")) then
  Model = "unstructured"
else
  Model = "ICOHDC"
end if

; default variable to be plotted is zonal wind
if (.not. isvar("var1")) then
  varname="rain_con_rate"
end if
  xtitle=var1
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
varname=var1
title1="varname"

plotTime = 590
plotTime2 = 2390
plotTime3 = 2400

; this should only be greater than 1 when precip is being plotted.
precipscale = 86400
precipscale = 1

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

; File 2
if (.not. isvar("onefile")) then
 infile = addfile(iFile2+".nc","r")
 print("reading from 2rd file")
end if
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn")) then
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field2 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field2 = infile->$varname$(plotTime,:,:)
    end if
  end if
end if
;field2=field2

; the precip needs to be converted to mm/day for comparison
field2 = precipscale*field2
print ("scaled field 2 max:")
print (max(field2))

; File 3
if (.not. isvar("onefile")) then
  infile = addfile(iFile3+".nc","r") 
  print("reading from 3rd file")
end if
if (Model.eq."unstructured")
  print("data is unstructured")
  if (.not. isvar("fmn"))
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field3 = infile->$varname$(plotTime,:,:,:)
    else
      print("data is twod data")
      field3 = infile->$varname$(plotTime,:,:)
    end if
  end if
end if

; the precip needs to be converted to mm/day for comparison
field3 = precipscale*field3
print ("scaled field 3 max:"+max(field3))

; File 4
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile4+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime2,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime2,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime2,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime2,:,:)
    end if
  end if
end if

; the precip needs to be converted to mm/day for comparison
field4 = precipscale*field4
print ("scaled field 4 max:"+max(field4))
; File 5
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile5+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field5 = infile->$varname$(plotTime2,:,:)
    else
      print("data is twod data")
      field5 = infile->$varname$(plotTime2,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field5 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field5 = infile->$varname$(plotTime2,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field5 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field5 = infile->$varname$(plotTime2,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field5 = precipscale*field5
print ("scaled field 5 max:"+max(field5))

; File 6
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile6+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field6 = infile->$varname$(plotTime2,:,:)
    else
      print("data is twod data")
      field6 = infile->$varname$(plotTime2,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field6 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field6 = infile->$varname$(plotTime2,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field6 = infile->$varname$(plotTime2,:,:,:)
    else
      print("data is twod data")
      field6 = infile->$varname$(plotTime2,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field6 = precipscale*field6
print ("scaled field 6 max:"+max(field6))

; File 7
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile7+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field7 = infile->$varname$(plotTime3,:,:)
    else
      print("data is twod data")
      field7 = infile->$varname$(plotTime3,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field7 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field7 = infile->$varname$(plotTime3,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field7 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field7 = infile->$varname$(plotTime3,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field7 = precipscale*field7
print ("scaled field 7 max:"+max(field7))

; File 8
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile8+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field8 = infile->$varname$(plotTime3,:,:)
    else
      print("data is twod data")
      field8 = infile->$varname$(plotTime3,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field8 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field8 = infile->$varname$(plotTime3,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field8 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field8 = infile->$varname$(plotTime3,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field8 = precipscale*field8
print ("scaled field 8 max:"+max(field8))

; File 9
; open/reference desired file (use addfiles to reference multiple data file)
 infile9 = addfile(iFile9+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field9 = infile9->$varname$(plotTime3,:,:)
    else
      print("data is twod data")
      field9 = infile9->$varname$(plotTime3,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field9 = infile9->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field9 = infile9->$varname$(plotTime3,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field9 = infile9->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field9 = infile9->$varname$(plotTime3,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field9 = precipscale*field9
print ("scaled field 9 max:"+max(field9))
;------------------------------------------------------------------------
time = infile->time(:)                     ; time values

timemax=dimsizes(time)
lasttime=timemax-1

print(min(time))
print(max(time))
print("dimensions of field1")
print(dimsizes(field1))

;print(field1(0,4,0))
;print(field2(0,4,0))
;print(field3(0,4,0))

; open a workstation 
 plot_type="ps"
 wks = gsn_open_wks(plot_type,"testplot")
 gsn_define_colormap(wks,"gui_default")
;create a plot array
 plot = new(9,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnLinesOn                = False
 res@cnLevelSelectionMode = "ManualLevels"
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
; res@cnLineLabelInterval  = 5                   ; label every other line
; res@cnLevelSpacingF      = 5.0

; if plotting total cloud cover use below:
 res@cnMinLevelValF       = 40.
 res@cnMaxLevelValF       = 100.
 res@cnLineLabelInterval  = 0                   
 res@cnLevelSpacingF      = 10.0

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
  res@tiXAxisString     = "297K; 20km"
 plot(0) = gsn_csm_contour(wks,field1,res)
  res@tiXAxisString     = "301K; 20km"
; plot(1) = gsn_csm_contour(wks,field2,res)
  res@tiXAxisString     = "305K; 20km"
 plot(2) = gsn_csm_contour(wks,field3,res)

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
; resmid@cnMinLevelValF       = 0.
; resmid@cnMaxLevelValF       = 70.
; resmid@cnLineLabelInterval  = 5                   ; label every other line
; resmid@cnLevelSpacingF      = 5.0

; if plotting total cloud cover use below:
 resmid@cnMinLevelValF       = 40.
 resmid@cnMaxLevelValF       = 100.
 resmid@cnLineLabelInterval  = 0                   
 resmid@cnLevelSpacingF      = 10.0

; resmid@cnCenterStringFontHeightF = 0.015
; resmid@cnCenterString            = "40km"

 resmid@gsnSpreadColors          = True
 resmid@gsnSpreadColorStart      = 2
 resmid@gsnSpreadColorEnd        = 20

 resmid@tmYLLabelsOn             = False
 resmid@tmXBLabelsOn             = False
 resmid@tmXTLabelsOn             = False

; resmid@tiMainString     = "what?"
; resmid@tiXAxisString    = "Rick Von Schmidt"

if (Model.eq."unstructured")
 resmid@sfXArray = x2
 resmid@sfYArray = y2
end if

 resmid@lbLabelBarOn             = False
  resmid@tiXAxisString     = "297K; 40km"
 plot(3) = gsn_csm_contour(wks,field4,resmid)
  resmid@tiXAxisString     = "301K; 40km"
 plot(4) = gsn_csm_contour(wks,field5,resmid)
  resmid@tiXAxisString     = "305K; 40km"
 plot(5) = gsn_csm_contour(wks,field6,resmid)

; create plot Bottom Row

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
; resbot@cnMinLevelValF       = 0.
; resbot@cnMaxLevelValF       = 70.
; resbot@cnLineLabelInterval  = 5                   ; label every other line
; resbot@cnLevelSpacingF      = 5.0

; if plotting total cloud cover use below:
 resbot@cnMinLevelValF       = 40.
 resbot@cnMaxLevelValF       = 100.
 resbot@cnLineLabelInterval  = 0                   
 resbot@cnLevelSpacingF      = 10.0

 resbot@gsnSpreadColors          = True
 resbot@gsnSpreadColorStart      = 2
 resbot@gsnSpreadColorEnd        = 20

 resbot@tmYLLabelsOn             = False
 resbot@tmXBLabelsOn             = False
 resbot@tmXTLabelsOn             = False

 ;resbot@tiMainString     = "what?"
 ;resbot@tiXAxisString    = "Rick Von Schmidt"

if (Model.eq."unstructured")
 resbot@sfXArray = x3
 resbot@sfYArray = y3
end if

 resbot@lbLabelBarOn             = False

  resbot@tiXAxisString     = "297K; 120km"
 plot(6) = gsn_csm_contour(wks,field7,resbot)
  resbot@tiXAxisString     = "301K; 120km"
 plot(7) = gsn_csm_contour(wks,field8,resbot)
  resbot@tiXAxisString     = "305K; 120km"
 plot(8) = gsn_csm_contour(wks,field9,resbot)

 resP                     = True
 ;resP@txString            = "Conv Precip on Large Domain (7680km)^2"
 resP@txString            = "Cloud Cover on Large Domain (7680km)^2"
; resP@pmLabelBarWidthF    = 0.8
 resP@gsnPanelLabelBar    = True
 resP@lbLabelFontHeightF  = 0.012
 gsn_panel(wks,plot,(/3,3/),resP)

end
