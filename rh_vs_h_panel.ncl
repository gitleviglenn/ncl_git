begin
;================================================;
; line_plots_general
;
;	produce a line plot showing RH 
;
; levi silvers  		October 2013
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;

; note the echam var in this program refers to the full echam model
; hydro, or george refers to icoham with echam physics
; nwp refers to icon with nwp physics

; work still needs to be done for the pure echam case

; open/reference desired file (use addfiles to reference multiple data file)
 infile = addfile(iFile+".nc","r")
 infile2 = addfile(iFile2+".nc","r")
 infile3 = addfile(iFile3+".nc","r")

; default title is "exp name"
if (.not. isvar("title")) then
  maintitle = "exp name"
else
  maintitle = title
end if
xtitle="default"
; below is the main title for the panel plot.
maintitle            = "Relative Humidity [%]; Res of 20km"
; read in vertical levels and time
if (.not. isvar("echam")) then
  ;lev = infile->lev(:)                   ; vertical levels
  lev = infile->height(:)                   ; vertical levels
end if
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "0"
end if

; increment is the increment of time between the two profiles 
plotincrement=400
tlev=39
print("current value of tlev is"+tlev)
;-setParameters-----------------------------------------------------------

plotTime = stringtointeger(timeStep)
plotTime2 = plotTime+plotincrement+1000
plotTime3 = plotTime+plotincrement
;plotTime2 = plotTime

;-Reading and processing of data-------------------------------------------
;-read in field1-----------------------------------------------------------
;
; set appropriate variable name
; george is a substitute for 'hydro'
if (.not. isvar("george")) then
  print("no george var")
  if (.not. isvar("echam")) then ; usual case
    varname="rh"  
    ;varnamez="z_ifc"
    varnamez="z_mc"
  else ; the echam model outputs qvi
    varname="prm_rh"
  end if
  title1="rh" ; total vapor
else ; data is from icoham
  print("assuming data from icoham")
  varname="prm_rh"
  title1="rh" ; total vapor
end if

;-read data----------------------------------------------------------------
; from file 1
if (.not. isvar("george")) then ; data is not from icoham
  print("no george var")
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
        field1 = infile->$varname$(plotTime,:,:)
        field2 = infile->$varname$(plotTime2,:,:)
    else
        field1 = infile->$varname$(plotTime,0,:,0)
        field2 = infile->$varname$(plotTime2,0,:,0)
        fieldz = infile->$varnamez$(0,:,0)
        vaxis1=fieldz/1000.
    end if
    
  else ; data is from echam so do following
    print("data from echam, reading has not been tested")
  end if
else ; data is from icoham so do following
  print("george var")
  if (.not. isvar("fmn"))
      print("check reading of var for no fmn")
  else
      field1 = infile->$varname$(plotTime,:,:,:)
      field2 = infile->$varname$(plotTime2,:,:,:)
  end if
end if
; from file 2
if (.not. isvar("george")) then ; data is not from icoham
  print("no george var")
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
        field3 = infile2->$varname$(plotTime,:,:)
        field4 = infile2->$varname$(plotTime2,:,:)
    else
        field3 = infile2->$varname$(plotTime,0,:,0)
        field4 = infile2->$varname$(plotTime2,0,:,0)
        fieldz = infile2->$varnamez$(0,:,0)
        vaxis2=fieldz/1000.
    end if
    
  else ; data is from echam so do following
    print("data from echam, reading has not been tested")
  end if
else ; data is from icoham so do following
  print("george var")
  if (.not. isvar("fmn"))
      print("check reading of var for no fmn")
  else
      field3 = infile2->$varname$(plotTime,:,:,:)
      field4 = infile2->$varname$(plotTime2,:,:,:)
  end if
end if
; from file 3
if (.not. isvar("george")) then ; data is not from icoham
  print("no george var")
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
        field5 = infile3->$varname$(plotTime,:,:)
        field6 = infile3->$varname$(plotTime3,:,:)
    else
        field5 = infile3->$varname$(plotTime,0,:,0)
        field6 = infile3->$varname$(plotTime3,0,:,0)
        fieldz = infile3->$varnamez$(0,:,0)
        vaxis2=fieldz/1000.
    end if
    
  else ; data is from echam so do following
    print("data from echam, reading has not been tested")
  end if
else ; data is from icoham so do following
  print("george var")
  if (.not. isvar("fmn"))
      print("check reading of var for no fmn")
  else
      field5 = infile3->$varname$(plotTime,:,:,:)
      field6 = infile3->$varname$(plotTime3,:,:,:)
  end if
end if
;================================================;
        plot_type="eps"
	wks  = gsn_open_wks(plot_type,"testplot")   	; output using eps
        ;gsn_define_colormap(wks,"gui_default")
        ;create a plot array
        plot = new(3,graphic)

; plot resources
     	lthick = 2.0
   
     	res          = True

        res@gsnDraw          = False
        res@gsnFrame         = False
;        res@cnInfoLabelOn    = False
        ;res@gsnPanelDebug    = True
;	res@tiMainString      = maintitle
     	res@tiXAxisString     = xtitle
     	res@tiYAxisString     = "z (km)"
     	res@xyLineThicknessF  = lthick
; set up vertical axis limits
        res@trXMinF = 0       
    	res@trXMaxF = 100       
        res@trYMinF = 0       
    	res@trYMaxF = 18       
;       add a legend
;        res@pmLegendHeightF      = 0.18 ; legend height
   
	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Small Domain (96x96)"
     	plot0    = gsn_csm_xy (wks,field1(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot1    = gsn_csm_xy (wks,field2(:),vaxis1,res) 		; create plot    
       
        overlay(plot0,plot1) 
        plot(0) = plot0

	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Medium Domain (192x192)"
    	plot2    = gsn_csm_xy (wks,field3(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot3    = gsn_csm_xy (wks,field4(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Large Domain (384x384)"
     	plot4    = gsn_csm_xy (wks,field5(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot5    = gsn_csm_xy (wks,field6(:),vaxis1,res) 		; create plot    
        overlay(plot2,plot3) 
        overlay(plot4,plot5) 
        plot(1) = plot2
        plot(2) = plot4
 resP                     = True
 resP@txString            = maintitle
; resP@pmLabelBarWidthF    = 0.8
; resP@gsnPanelLabelBar    = True
 resP@lbLabelFontHeightF  = 0.012
        gsn_panel(wks,plot,(/1,3/),resP)

end






