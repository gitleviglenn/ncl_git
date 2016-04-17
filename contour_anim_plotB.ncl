;----------------------------------------------------------------------------
; load necessary libraries

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;----------------------------------------------------------------------------
;----a simple ncl script that reads in a NetCDF file and outputs contour plot
;----This can plot both regularly gridded data and data on the unstructured
;----triangular ICON grid, simply set Model = "unstructured"
;----levi silvers----10-06-2012
;    modified on     16-11-2012
;---------------------------------------------------------------------------
; basic syntax
;   ncl contour_plot_general.ncl 'iFile="path/file"'
;
; or, using the script written by Kalle:
;   nclsh contour_plot_general.ncl -iFile=nat_rce_r140/nat_rce_r140_DOM01_ML_0001.nc 
;   -gFile=nat_rce_r140/torus_grid_r140000s40.nc -timeStep=10 -varname=prm_t -structured
;
; if the -structured option is used, then the grid file is not needed.  the grid
; file is also not needed if the data file contains clat and clon values.
;
; required parameters
; iFile         : "filename" input file (must be a NetCDF file)
;
; Still needs work
;   - the unstructured grid is not centered in the same location as the 
;     structured grid, this should be explicitly set
;   - the variable to be plotted should be read in as a parameter to make
;     this script a bit more general.  the dimensions of this variable 
;     should also be determined simply by reading the incoming netcdf file
;     rather than having the dimensions hardcoded into the script
;---------------------------------------------------------------------------

; this defines whether the grid is structured or not
; default is unstructured

if (.not. isvar("structured")) then
  Model = "unstructured"
else
  Model = "ICOHDC"
end if
; default variable to be plotted is zonal wind
if (.not. isvar("varname")) then
  varname="prm_u"
end if
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "0"
  print("no time step specified")
end if
print("time step ="+timeStep)
if (.not. isvar("title")) then
  title = "no_title"
end if

plotTime = stringtointeger(timeStep)
; the precip fields are 2D so the plot lev shouldn't matter
plotlev  = 1

rad2deg = 45./atan(1.)   ; radians to degrees

; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")
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
if (Model.eq."unstructured")
  if (.not. isvar("twod")) then
    field1 = infile->$varname$(plotTime,plotlev,:)
  else
    field1 = infile->$varname$(plotTime,:)
  end if
else
  if (.not. isvar("twod")) then
    field1 = infile->$varname$(plotTime,plotlev,:,:)               
  else
    if (.not. isvar("var")) then
      field1 = infile->$varname$(plotTime,plotlev,:)               
    else
      field1 = infile->$varname$(:,0,:,0)
    end if
  end if  
end if
  ;lev = infile->lev(:)                       ; vertical levels
  ;lev = infile->height(:)                       ; vertical levels
  time = infile->time(:)                     ; time values
 ;field1 = infile->omega_z(2,0,:,:)        ; Div(time,lev,lat,lon)

print("max value of input variable = "+max(field1))

; Precipitation conversion factors:
; ----------------------------------------------------------------
; for the rain rates from NWP this is the conversion to mm/day:

if (isvar("convert")) then
;;;  print("no precip conversion applied")
  field1 = 86400.*field1
end if

;field1=-field1
print("field one has not had sign switch!!")

;if (varname .eq. "prm_rsfc") then
  field1 = 86400.*field1
  print("field one scaled by 86400!!")
;end if
;if (varname .eq. "prm_rsfl") then
;  field1 = 86400.*field1
;end if
;if (varname .eq. "rain_con") then
;  field1 = field1*(1./60.)
;end if
;if (varname .eq. "rain_gsp") then
;  field1 = field1*(1./60.)
;end if
; ----------------------------------------------------------------

if (Model.eq."unstructured") then
     x = clon*rad2deg
     y = clat*rad2deg
end if

; open a workstation (x11 in this case)
 plot_type="eps"
 wks = gsn_open_wks(plot_type,"testplotB")
 ;gsn_define_colormap(wks,"gui_default")
 gsn_define_colormap(wks,"MPL_Blues")
;; colorbar levels 
  ;my_levels1 = (/1,5,10,15,20, \
  ;               25,30,35,40,45, \
  ;               50,55,60,65,70 /)
  my_levels1 = (/1,5,10,15,20, \
                 25,30,35,40,45, \
                 50,55,60,65,70 /)
  ;my_colors1 = (/128,120,112,74,68,62,56,50,44,38,32,26,20,14,8,2/)
  ; uniform light
  ;my_colors1 = (/92,86,80,74,68,62,56,50,44,38,32,26,20,14,8,2/)
  ; uniform dark
  ;my_colors1 = (/122,114,106,98,90,82,74,66,58,50,42,34,26,18,10,2/)
  ; dark ocean
  ;my_colors1 = (/128,86,80,74,68,62,56,50,44,38,32,26,20,14,8,2/)
  ; light ocean, dark rain
  my_colors1 = (/2,26,32,38,44,50,56,62,68,74,80,86,92,98,104,128/)

;create a plot array
 plot = new(1,graphic)

 res                          = True

 res@gsnDraw                  = False
 res@gsnFrame                 = False

 res@cnInfoLabelOn            = False
 res@cnFillOn                 = True 
; res@cnFillMode               = "RasterFill"       ; Raster Mode
 res@cnLevelSelectionMode = "ExplicitLevels"   ; "ManuelLevels"
 res@cnLevels            = my_levels1
 res@cnFillColors        = my_colors1
; res@cnLevelSelectionMode = "ManualLevels"
; 100 to 320 are good for plots of OLR
; res@cnMinLevelValF       = 100.
; res@cnMaxLevelValF       = 320.
; res@cnLevelSpacingF      = 20.
; res@cnLineLabelInterval  = 0                   ; label every other line
; 5 to 70 is generally good for precip
; res@cnMinLevelValF       = 0.
; res@cnMaxLevelValF       = 70.
; res@cnLevelSpacingF      = 5.
; below is the switch to deterine if contour lines are labeled
 res@cnLineLabelInterval  = 0                   ; label every other line
; below is the switch for drawing the contour lines in black 
 res@cnLinesOn            = False
 ;res@cnCenterStringFontHeightF = 0.015
 ;res@cnCenterString            = "day 3"

; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

 res@gsnSpreadColors          = True
 res@gsnSpreadColorStart      = 2
 res@gsnSpreadColorEnd        = 20

if (Model.eq."unstructured")
 res@sfXArray = x
 res@sfYArray = y
end if

 res@tmYLLabelsOn             = False
 res@tmXBLabelsOn             = False
 res@tmXTLabelsOn             = False

 res@tmXTOn                   = False
 res@tmXBOn                   = False
 res@tmYLOn                   = False
 res@tmYROn                   = False

 res@lbLabelBarOn             = False
; res@trYReverse               = True     ; reverse the y-axis
; res@gsnYAxisIrregular2Log    = True     ; plot y as log
 res@vpWidthF          = 1.0 ; vpWidth and Height control box size
 res@vpHeightF         = 0.86 ; default for both is 0.6 in NDC units

; create plot
 plot = gsn_csm_contour(wks,field1,res)

  resP                     = True
  resP@txString            = title
  resP@gsnPanelLabelBar    = False
  resP@lbLabelFontHeightF  = 0.02
  gsn_panel(wks,plot,(/1,1/),resP)

; clean up and exit
; delete(plot)

end
