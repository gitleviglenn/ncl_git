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
maintitle            = "Moist Static Energy; Res of 20km"
; read in vertical levels and time
if (.not. isvar("echam")) then
  ;lev = infile->lev(:)                   ; vertical levels
  lev = infile->height(:)                   ; vertical levels
end if
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "0"
end if

; define acceleration due to gravity same as in icon
grav=9.80665 ; m/s^2
cp = 1004.64 ; J/(K kg) for dry air
lv = 2.5008e6 ; J/kg latent heat of vaporization
print("latent heat: "+lv)

; increment is the increment of time between the two profiles 
plotincrement=400
;klev1 = infile->lev_3(:40)
tlev=39
print("current value of tlev is"+tlev)
;-setParameters-----------------------------------------------------------
; indices for the vert loop
ikstart = 1
ikend   = tlev

plotTime = stringtointeger(timeStep)
plotTime2 = plotTime+plotincrement+1000
plotTime3 = plotTime+plotincrement
; when it is desired to plot different time intervals from one plot to 
; another, then comment out the line below.  this results in 2 final
; plotTimes
;plotTime2 = plotTime3

;-Reading and processing of data-------------------------------------------
;-read in field1-----------------------------------------------------------
;
; set appropriate variable name
; george is a substitute for 'hydro'
if (.not. isvar("george")) then
  print("no george var")
  if (.not. isvar("echam")) then ; usual case
    ;varname="rh"  
    varname="qv"
    varnamez="z_ifc"
    varnamezm="z_mc"
    varnamerho="rho"
    tempvar="temp" ;var from nwp physics 
  else ; the echam model outputs qvi
    ;varname="prm_rh"
    varname="qvi"
  end if
  title1="iqv" ; total vapor
else ; data is from icoham
  print("assuming data from icoham")
  varname="prm_qvi"
  title1="qvi" ; total vapor
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
; compute the moist energy
mstenga=field1*lv
mstengb=field2*lv
print("msteng at sfc: "+field1(39)*lv)
; compute the potential energy
print("poteng at sfc: "+fieldz(39)*grav)
poteng = grav*fieldz

;read and process data
if (.not. isvar("george")) then ; data is not from icoham
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
      tempfielda = infile->$tempvar$(plotTime,:,:)
      tempfieldb = infile->$tempvar$(plotTime2,:,:)
    else 
      tempfielda = infile->$tempvar$(plotTime,0,:,0)
      tempfieldb = infile->$tempvar$(plotTime2,0,:,0)
    end if
    intengda=tempfielda*cp ; internal energy for dry air
    intengdb=tempfieldb*cp ; internal energy for dry air
  end if ; echam
else ; data is from icoham
  print("george var")
  if (.not. isvar("fmn"))
    print("check reading of var for no fmn")
    ;tempfield = infile->$tempvar$(:timelen,:)
  else
    tempfielda = infile->$tempvar$(plotTime,:,:)
    tempfieldb = infile->$tempvar$(plotTime2,:,:)
  end if
  intengda=tempfielda*cp ; internal energy for dry air
  intengdb=tempfieldb*cp ; internal energy for dry air
end if ; george
print("cp :"+cp+"tempfield a:"+tempfielda(39)+"intengd a at sfc: "+tempfielda(39)*cp)
;print(tempfield)

; compute total and/or differences of vars to plot

print(dimsizes(intengda))
print(dimsizes(poteng))
print(dimsizes(mstenga))

mse1a = intengda + poteng + mstenga
mse1b = intengdb + poteng + mstengb 
;--------------------------------------------------------
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
;read and process temp data
if (.not. isvar("george")) then ; data is not from icoham
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
      tempfielda = infile2->$tempvar$(plotTime,:,:)
      tempfieldb = infile2->$tempvar$(plotTime2,:,:)
    else 
      tempfielda = infile2->$tempvar$(plotTime,0,:,0)
      tempfieldb = infile2->$tempvar$(plotTime2,0,:,0)
    end if
    intengd2a=tempfielda*cp ; internal energy for dry air
    intengd2b=tempfieldb*cp ; internal energy for dry air
  end if ; echam
else ; data is from icoham
  print("george var")
  if (.not. isvar("fmn"))
    print("check reading of var for no fmn")
    ;tempfield = infile2->$tempvar$(:timelen,:)
  else
    tempfielda = infile2->$tempvar$(plotTime,:,:)
    tempfieldb = infile2->$tempvar$(plotTime2,:,:)
  end if
  intengd2a=tempfielda*cp ; internal energy for dry air
  intengd2b=tempfieldb*cp ; internal energy for dry air
end if ; george
print("cp :"+cp+"tempfield a:"+tempfielda(39)+"intengd2 a at sfc: "+intengd2a(39))
;print(tempfield)

; compute the moist energy
msteng2a=field3*lv
msteng2b=field4*lv
print("msteng a at sfc: "+field3(39)*lv)
; compute the potential energy
print("poteng at sfc: "+fieldz(39)*grav)
poteng2 = grav*fieldz

mse2a = intengd2a + poteng2 + msteng2a 
mse2b = intengd2b + poteng2 + msteng2b 
;---------------------------------------------------------
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
;read and process temp data
if (.not. isvar("george")) then ; data is not from icoham
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
      tempfielda = infile3->$tempvar$(plotTime,:,:)
      tempfieldb = infile3->$tempvar$(plotTime3,:,:)
    else 
      tempfielda = infile3->$tempvar$(plotTime,0,:,0)
      tempfieldb = infile3->$tempvar$(plotTime3,0,:,0)
    end if
    intengd3a=tempfielda*cp ; internal energy for dry air
    intengd3b=tempfieldb*cp ; internal energy for dry air
  end if ; echam
else ; data is from icoham
  print("george var")
  if (.not. isvar("fmn"))
    print("check reading of var for no fmn")
    ;tempfield = infile3->$tempvar$(:timelen,:)
  else
    tempfielda = infile3->$tempvar$(plotTime,:,:)
    tempfieldb = infile3->$tempvar$(plotTime3,:,:)
  end if
  intengd3a=tempfielda*cp ; internal energy for dry air
  intengd3b=tempfieldb*cp ; internal energy for dry air
end if ; george
print("cp :"+cp+"tempfield a:"+tempfielda(39)+"intengd3a at sfc: "+intengd3a(39))
;print(tempfielda)

; compute the moist energy
msteng3a=field5*lv
msteng3b=field6*lv
print("msteng at sfc: "+field5(39)*lv)
; compute the potential energy
print("poteng at sfc: "+fieldz(39)*grav)
poteng3 = grav*fieldz

mse3a = intengd3a + poteng3 + msteng3a 
mse3b = intengd3b + poteng3 + msteng3b 
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
        res@trXMinF = 290       
    	res@trXMaxF = 390       
        res@trYMinF = 0       
    	res@trYMaxF = 18       
;       add a legend
;        res@pmLegendHeightF      = 0.18 ; legend height
  

; scale factor, mse is plotted in units of kJ/kg 
scale=1000.
mse1a=mse1a/scale
mse1b=mse1b/scale
mse2a=mse2a/scale
mse2b=mse2b/scale
mse3a=mse3a/scale
mse3b=mse3b/scale

	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Small Domain (96x96)"
     	plot0    = gsn_csm_xy (wks,mse1a(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot1    = gsn_csm_xy (wks,mse1b(:),vaxis1,res) 		; create plot    
       
        overlay(plot0,plot1) 
        plot(0) = plot0

	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Medium Domain (192x192)"
    	plot2    = gsn_csm_xy (wks,mse2a(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot3    = gsn_csm_xy (wks,mse2b(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 0 ; 0 gives solid line
     	res@tiXAxisString     = "Large Domain (384x384)"
     	plot4    = gsn_csm_xy (wks,mse3a(:),vaxis1,res) 		; create plot    
	res@xyDashPattern = 1
     	plot5    = gsn_csm_xy (wks,mse3b(:),vaxis1,res) 		; create plot    
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






