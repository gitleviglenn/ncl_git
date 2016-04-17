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
; infile2 = addfile(iFile2+".nc","r")

; default title is "exp name"
if (.not. isvar("title")) then
  maintitle = "exp name"
else
  maintitle = title
end if
xtitle="Rel Hum [%]"
; read in vertical levels and time
if (.not. isvar("echam")) then
  ;lev = infile->lev(:)                   ; vertical levels
  lev = infile->height(:)                   ; vertical levels
end if
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "20"
end if

; increment is the increment of time between the two profiles 
if (isvar("iFile2")) then
  plotincrement=0
  print("Second input file detected")
  label1="Conv On"
  label2="Conv Off"
else
  plotincrement=1499
  label1="RH first"
  label2="RH second"
end if
print("plotting increment is: "+plotincrement)
tlev=39
print("current value of tlev is"+tlev)
;-setParameters-----------------------------------------------------------

plotTime = stringtointeger(timeStep)
plotTime2 = plotTime+plotincrement

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
       ; field1 = infile->$varname$(plotTime,0,:,0)
       ; field2 = infile->$varname$(plotTime2,0,:,0)
       ; fieldz = infile->$varnamez$(0,:,0)
        field1 = infile->$varname$(plotTime,:,0,0)
        field2 = infile->$varname$(plotTime2,:,0,0)
        fieldz = infile->$varnamez$(:,0,0)
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
if (isvar("iFile2")) then
delete(field2)
delete(infile)
plotTime2=plotTime
infile = addfile(iFile2+".nc","r")
if (.not. isvar("george")) then ; data is not from icoham
  print("no george var")
  if (.not. isvar("echam")) then
    if (.not. isvar("fmn"))
        field2 = infile->$varname$(plotTime2,:,:)
    else
       ; field2 = infile->$varname$(plotTime2,0,:,0)
        field2 = infile->$varname$(plotTime2,:,0,0)
    end if
    
  else ; data is from echam so do following
    print("data from echam, reading has not been tested")
  end if
else ; data is from icoham so do following
  print("george var")
  if (.not. isvar("fmn"))
      print("check reading of var for no fmn")
  else
      ;field1 = infile->$varname$(plotTime,:,:,:)
      field2 = infile->$varname$(plotTime2,:,:,:)
  end if
end if
end if
; basic checks for bug finding
; scale factor (86400 converts kg/(m^2 s) to mm/day)
scale=1
print("scale factor is currently: "+scale)
print("dim of field1: "+dimsizes(field1))
print("dim of field2: "+dimsizes(field2))
print("dim of vaxis1: "+dimsizes(vaxis1))
;================================================;
        plot_type="eps"
	wks  = gsn_open_wks(plot_type,"testplot")   	; output using eps
        gsn_define_colormap(wks,"gui_default")
        ;create a plot array
        plot = new(1,graphic)

; plot resources
     	lthick = 2.0
;       colors1 defines the colors of the different spectra
        colors1 = (/"Black","SteelBlue","GoldenRod","OrangeRed","LawnGreen","DarkTurquoise","Blue","Red"/) 
print("are we here?1")   
     	res          = True

        res@gsnDraw          = False
        res@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
	res@tiMainString      = maintitle
     	;res@gsnCenterString   = varname
     	res@tiXAxisString     = xtitle
     	res@tiYAxisString     = "z (km)"
     	res@gsnFrame          = False
     	res@xyLineThicknessF  = lthick

;       add a legend
        res@pmLegendHeightF      = 0.18 ; legend height
   
        lgres                      = True
        lgres@lgLineColors         = colors1
        lgres@lgItemType           = "Lines"
        lgres@lgLabelFontHeightF   = .08
        lgres@vpWidthF             = 0.2        ; width of legend
        lgres@vpHeightF            = 0.17        ; height of legend
        lgres@lgPerimThicknessF    = 2.0
;        lgres@lgMonoDashIndex      = True
;        lgres@lgDashIndex          = 0

; set up vertical axis limits
        res@trXMinF = 0       
    	res@trXMaxF = 100       
        res@trYMinF = 0       
    	res@trYMaxF = 18       
     	;res@tiYAxisString     = "mm/day"
     	;res@tiYAxisString     = "kg/(m^2 s)"

print("are we here?2")   
	;res@xyDashPattern = 0 ; 0 gives solid line
     	res@xyLineColors  = colors1(0) 
     	plot0    = gsn_csm_xy (wks,field1(:),vaxis1,res) 		; create plot    
	;res@xyDashPattern = 1
     	res@xyLineColors  = colors1(1) 
     	plot1    = gsn_csm_xy (wks,field2(:),vaxis1,res) 		; create plot    
       
        overlay(plot0,plot1) 
print("are we here?3")   
 

; resP                     = True
;; resP@txString            = "RH"
;; resP@pmLabelBarWidthF    = 0.8
;; resP@gsnPanelLabelBar    = True
; resP@lbLabelFontHeightF  = 0.012
;        gsn_panel(wks,plot0,(/1,1/),resP)

        labels = (/label1,label2/)
        legend  = gsn_create_legend (wks, 2, labels, lgres)

        amres = True
        amres@amJust = "BottomRight"

        amres@amParallelPosF   = 0.45    ; Move legend to right
        amres@amOrthogonalPosF = 0.0     ; Move legend down

        annoid = gsn_add_annotation(plot0,legend,amres) ; add legend to plot

        draw(plot0)

end






