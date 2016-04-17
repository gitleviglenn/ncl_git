; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

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

if (.not. isvar("structured")) then
  Model = "unstructured"
else
  Model = "ICOHDC"
end if

; default variable to be plotted is zonal wind
if (.not. isvar("var1")) then
  varname="rain_con_rate"
;  varname="rain_gsp_rate"
  precipscale = 86400
else
  varname=var1
  precipscale = 1
end if
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
;varname=var1
title1="varname"

plotTime = 0
plotTime3 = 0
plotTime2 = 0

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
     x1 = clon*rad2deg
     y1 = clat*rad2deg
end if

if (isvar("multiDom")) then
  ; second grid file
  delete(gridfile)
  delete(clon)
  delete(clat)
;  gridfile=addfile("to_exps/rce_ecs_20km_192gp_301/torus_grid_r20000s192.nc","r")
  gridfile=addfile("to_data/grids/torus_grid_x48_y48_e20km.nc","r")
  ;gridfile = addfile(gFile2,"r")
  clon = gridfile->clon(:)
  clat = gridfile->clat(:)
  x0 = clon*rad2deg
  y0 = clat*rad2deg
end if

if (isvar("multiDom")) then
  ; second grid file
  delete(gridfile)
  delete(clon)
  delete(clat)
;  gridfile=addfile("to_exps/rce_ecs_20km_192gp_301/torus_grid_r20000s192.nc","r")
  gridfile=addfile("to_data/grids/torus_grid_r20000s192.nc","r")
  ;gridfile = addfile(gFile2,"r")
  clon = gridfile->clon(:)
  clat = gridfile->clat(:)
  x2 = clon*rad2deg
  y2 = clat*rad2deg
end if

; third grid file
;
if (isvar("multiDom")) then
  delete(gridfile)
  delete(clon)
  delete(clat)
  ;delete(lon)
  ;delete(lat)
  gridfile=addfile("to_data/grids/torus_grid_r20000s384.nc","r")
  ; gridfile = addfile(gFile3,"r")
   clon = gridfile->clon(:)
   clat = gridfile->clat(:)
   x3 = clon*rad2deg
   y3 = clat*rad2deg
end if

; fourth grid file
;
if (isvar("multiDom")) then
  delete(gridfile)
  delete(clon)
  delete(clat)
  gridfile=addfile("to_data/grids/torus_grid_x768_y768_e20km.nc","r")
   clon = gridfile->clon(:)
   clat = gridfile->clat(:)
   x4 = clon*rad2deg
   y4 = clat*rad2deg
  delete(gridfile)
end if

; File 1
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile0+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field0 = infile->$varname$(plotTime,:,:)
    else
      print("data is twod data")
      field0 = infile->$varname$(plotTime,:)
    end if
  else
    print("data is field mn data")
  end if
end if
print ("field 0 max:"+max(field0))

; the precip needs to be converted to mm/day for comparison
field0 = precipscale*field0
print ("scaled field 0 max:"+max(field0))
print ("scaled field 0 min:"+min(field0))

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
print ("scaled field 1 min:"+min(field0))


; File 2
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
print ("scaled field 2 min:"+min(field2))

; File 3
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
print ("scaled field 3 min:"+min(field3))

; File 4
; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile4+".nc","r")
if (Model.eq."unstructured") then
  print("data is unstructured")
  if (.not. isvar("fmn")) then
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime3,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime3,:)
    end if
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime3,:,:)
    end if
  end if
else
  print("data is structured")
  if (.not. isvar("fmn"))
    print("not configured yet for non fmn data")
  else
    print("data is field mn data")
    if (.not. isvar("twod")) then
      field4 = infile->$varname$(plotTime3,:,:,:)
    else
      print("data is twod data")
      field4 = infile->$varname$(plotTime3,:,:)
    end if
  end if
end if
; the precip needs to be converted to mm/day for comparison
field4 = precipscale*field4
print ("scaled field 4 max:"+max(field4))
print ("scaled field 4 min:"+min(field4))

;------------------------------------------------------------------------
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
 wks = gsn_open_wks(plot_type,"testplot_5dom")
 ;gsn_define_colormap(wks,"gui_default")
 ;gsn_define_colormap(wks,"MPL_Blues")
;; colorbar levels 
;if (.not. isvar("var1")) then
 gsn_define_colormap(wks,"MPL_Blues")
;  my_levels1 = (/1,5,10,15,20, \
;               25,30,35,40,45, \
;               50,55,60,65,70 /)
;  my_levels1 = (/1,2,5,10,15, \
;               20,25,30,35,40, \
;               50,60,70 /)
  my_levels1 = (/20,25,30,35,40, \
               45,50,55,60,65, \
               70,75,80 /)
  ; light ocean, dark rain
  ;my_colors1 = (/2,26,32,38,44,50,56,62,68,74,80,86,92,98,104,128/)
  my_colors1 = (/2,15,32,42,50,58,66,74,82,90,98,106,114,128/)
  ;my_colors1 = (/2,2,2,42,50,58,66,74,82,90,98,106,128,128/)
;else
; gsn_define_colormap(wks,"gui_default")
;end if
;create a plot array
 plot = new(5,graphic)

; create resource for plot
 res = True     

 res@gsnDraw          = False
 res@gsnFrame         = False

; set up vertical axis limits
 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
 res@cnLinesOn                = False
 res@cnFillMode               = "RasterFill"
if (.not. isvar("var1")) then
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
else
 ;res@cnLevelSelectionMode = "ManualLevels"
 ;res@cnMinLevelValF       = 10.
 ;res@cnMaxLevelValF       = 60.
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
end if
 res@cnLinesOn             = False
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
 res@cnLineLabelInterval  = 0                   ; label every other line
; res@cnLevelSpacingF      = 5.0
 res@vpWidthF          = 1.0 ; vpWidth and Height control box size
 res@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units

; res@cnCenterStringFontHeightF = 0.015
; res@cnCenterString            = "20km"

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

 res@gsnSpreadColors          = True
 res@gsnSpreadColorStart      = 2
 res@gsnSpreadColorEnd        = 20
 
 res@tmYLLabelsOn             = False
 res@tmXBLabelsOn             = False
 res@tmXTLabelsOn             = False
 res@lbLabelBarOn             = False

  if (Model.eq."unstructured")
   res@sfXArray = x0
   res@sfYArray = y0
  end if
  res@tiXAxisString     = "3/4M "
  plot(0) = gsn_csm_contour(wks,field0,res)

if (Model.eq."unstructured")
 delete(res@sfXArray)
 delete(res@sfYArray)
 res@sfXArray = x1
 res@sfYArray = y1
end if

  res@tiXAxisString     = "3M "
 plot(1) = gsn_csm_contour(wks,field1,res)
if (.not. isvar("multiDom")) then
;  res@tiXAxisString     = "12M "
 plot(1) = gsn_csm_contour(wks,field2,res)
;  res@tiXAxisString     = "50M "
 plot(2) = gsn_csm_contour(wks,field3,res)
;  res@tiXAxisString     = "200M "
; plot(3) = gsn_csm_contour(wks,field4,res)
else 
  
  ;
  if (Model.eq."unstructured")
   delete(res@sfXArray)
   delete(res@sfYArray)
   res@sfXArray = x2
   res@sfYArray = y2
  end if
  ;
  res@tiXAxisString     = "12M"
  plot(2) = gsn_csm_contour(wks,field2,res)
  
  if (Model.eq."unstructured")
   delete(res@sfXArray)
   delete(res@sfYArray)
   res@sfXArray = x3
   res@sfYArray = y3
  end if
  
  res@tiXAxisString     = "50M"
  plot(3) = gsn_csm_contour(wks,field3,res)
  
  if (Model.eq."unstructured")
   delete(res@sfXArray)
   delete(res@sfYArray)
   res@sfXArray = x4
   res@sfYArray = y4
  end if

 res@tiXAxisString     = "200M "
 plot(4) = gsn_csm_contour(wks,field4,res)

end if

;
 resP                     = True
; resP@txString            = "Convective Precip vs. Dom Size"
 resP@gsnPanelLabelBar    = True
 resP@gsnPanelRowSpec     = True ; tell panel what order to plt
;; resP@pmLabelBarWidthF    = 0.8
;; resP@lbTitleOn           = True
;; resP@lbTitlePosition     = "Bottom"
;; resP@lbTitleString       = "mm/day"
 resP@lbLabelFontHeightF  = 0.020
 gsn_panel(wks,plot,(/3,2/),resP)

end
