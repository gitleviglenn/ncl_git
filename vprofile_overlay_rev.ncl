;================================================;
; vprofile_overlay
;
;	produces a 5 figure panel of the vertical 
;       profiles for various variables.
;
; optional parameters: -301, -diff : using both will 
; result in a plot showing the difference between 301 and 297
;
; the letters used in the labels represent the following exps:
; a: 384
; b: 192
; c: 96
; d: 768
; e: 48
; 
; levi silvers  		October 2013
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;
begin

; create some vars
if (.not. isvar("sst")) then
  sst="297"
  print("Using default sst: "+sst)
else
  sst=sst
end if

if (.not. isvar("date")) then
  ddate="aug09"
  print("Using default date: "+ddate)
else
  ddate=date
end if

; open/reference desired file (use addfiles to reference multiple data file)
title1="50M"
;title1="SST=297K"
; infile = addfile(iFile+".nc","r")
; infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_384gp_"+sst+"_more_"+ddate+"_fldtmn.nc","r")
; infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_384gp_297_more_julaug10_fldtmn.nc","r")
 infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_384gp_297_more_4mn_fldtmn.nc","r")
print("--------------------------------------------------------------------------")
print("file being read is: 384, 50M")
print("--------------------------------------------------------------------------")
; default title is "exp name"
if (.not. isvar("title")) then
  if (.not. isvar("diff")) then
    ;maintitle = "2 Month Mean Vertical Structure SST="+sst+" ";+ddate
    maintitle = "Mean Vertical Structure SST=297";+ddate
  else
    maintitle = "Mean Vertical Structure 301K-297K"
  end if
else
  maintitle = title
end if
xtitle="Relative Humidity (%)"
; read in vertical levels and time
lev = infile->height(:)                   ; vertical levels
; default time step to plot is 0
if (.not. isvar("timeStep")) then
  timeStep = "0"
end if

; default plotform type is eps
if (.not. isvar("plotform")) then
  plottype = "eps" 
else
  plottype = plotform
end if

  label1=" "
  label2=" "

;; increment is the increment of time between the two profiles 
;if (isvar("iFile2")) then
;  plotincrement=0
;  print("Second input file detected")
;else
;  plotincrement=4
;end if
plotincrement=0
;print("plotting increment is: "+plotincrement)
;-setParameters-----------------------------------------------------------

plotTime = stringtointeger(timeStep)
plotTime2 = plotTime+plotincrement

;-Reading and processing of data-------------------------------------------
;-read in field1-----------------------------------------------------------
;
; set appropriate variable name
  varnamerh   ="rh"  
  varnamet  ="temp"
  varnameclc="clc"
  varnameqc ="qc"
  ;varnameqi ="qv"
  varnameqi ="qi"
  ;varnameqi ="clc"
  ;varnamez="z_ifc"
  varnamez  ="z_mc"

;scale for converting from kg/kg to g/kg
convscale=1000.
print("CAUTION! scale factor of: "+convscale+" being applied")

;-read data----------------------------------------------------------------
; from file 1
fieldrh   = infile->$varnamerh$(plotTime,:,0,0)
fieldtemp = infile->$varnamet$(plotTime,:,0,0)
fieldclc  = infile->$varnameclc$(plotTime,:,0,0)
fieldqi   = infile->$varnameqi$(plotTime,:,0,0)
fieldqc   = infile->$varnameqc$(plotTime,:,0,0)
fieldz    = infile->$varnamez$(:,0,0)
totcld    = infile->clct(:,:,:)
totqv     = infile->tqv(:,:,:)
totqc     = infile->tqc(:,:,:)
totqi     = infile->tqi(:,:,:)
vaxis1=fieldz/convscale

print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

;field to be plotted to plot
fieldrha = fieldrh
fieldtempa = fieldtemp
fieldclca = fieldclc
fieldqia = fieldqi
fieldqca = fieldqc

print("max of fieldqi: "+max(fieldqia))
print("max of fieldqc: "+max(fieldqc))
delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])

;read in data from 301K experiment
if (sst .eq. 301) then
  if (.not. isvar("diff")) then
    maintitle = "Mean Vertical Structure SST=301"
  end if 
  infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_384gp_301_more_4mn_fldtmn.nc","r")
  fieldrh = infile->$varnamerh$(plotTime,:,0,0)
  fieldtemp = infile->$varnamet$(plotTime,:,0,0)
  fieldclc = infile->$varnameclc$(plotTime,:,0,0)
  fieldqi = infile->$varnameqi$(plotTime,:,0,0)
  fieldqc = infile->$varnameqc$(plotTime,:,0,0)
  totcld    = infile->clct(:,:,:)
  totqv     = infile->tqv(:,:,:)
  totqc     = infile->tqc(:,:,:)
  totqi     = infile->tqi(:,:,:)
print("sst = 301")
print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

  ; if plotting difference between 301K and 297K:
  if (isvar("diff")) then
    fieldrh=fieldrh-fieldrha
    fieldtemp=fieldtemp-fieldtempa
    fieldclc=fieldclc-fieldclca
    fieldqi=fieldqi-fieldqia
    fieldqc=fieldqc-fieldqca
  end if
  ;field to be plotted to plot
  fieldrha = fieldrh
  fieldtempa = fieldtemp
  fieldclca = fieldclc
  fieldqia = fieldqi
  fieldqca = fieldqc
  delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])
end if

;--------------------------------------------------------------------------
; from file 2
title2="12M"
;title2="SST=301K"
;infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_192gp_"+sst+"_more_"+ddate+"_fldtmn.nc","r")
;infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_96gp_301_more_junjulaug11_fldtmn.nc","r")
;infile = addfile("to_ecs/rce_ecs_20km_192gp_"+sst+"_more_augsep10_fldtmn.nc","r")
infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_192gp_297_more_amjjason12_fldtmn.nc","r")
print("--------------------------------------------------------------------------")
print("file being read is: 192, 12M")
print("--------------------------------------------------------------------------")

fieldrh = infile->$varnamerh$(plotTime2,:,0,0)
fieldtemp = infile->$varnamet$(plotTime,:,0,0)
fieldclc = infile->$varnameclc$(plotTime,:,0,0)
fieldqi = infile->$varnameqi$(plotTime,:,0,0)
fieldqc = infile->$varnameqc$(plotTime,:,0,0)
totcld    = infile->clct(:,:,:)
totqv     = infile->tqv(:,:,:)
totqc     = infile->tqc(:,:,:)
totqi     = infile->tqi(:,:,:)

print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")


;field to be plotted to plot
fieldrhb = fieldrh
fieldtempb = fieldtemp
fieldclcb = fieldclc
fieldqib = fieldqi
fieldqcb = fieldqc

print("max of fieldqi: "+max(fieldqib))
print("max of fieldqc: "+max(fieldqcb))
delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])

;read in data from 301K experiment
if (sst .eq. 301) then
  infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_192gp_301_more_amjjason12_fldtmn.nc","r")
  fieldrh = infile->$varnamerh$(plotTime,:,0,0)
  fieldtemp = infile->$varnamet$(plotTime,:,0,0)
  fieldclc = infile->$varnameclc$(plotTime,:,0,0)
  fieldqi = infile->$varnameqi$(plotTime,:,0,0)
  fieldqc = infile->$varnameqc$(plotTime,:,0,0)
  totcld    = infile->clct(:,:,:)
  totqv     = infile->tqv(:,:,:)
  totqc     = infile->tqc(:,:,:)
  totqi     = infile->tqi(:,:,:)
print("sst = 301")
print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

  ; if plotting difference between 301K and 297K:
  if (isvar("diff")) then
    fieldrh=fieldrh-fieldrhb
    fieldtemp=fieldtemp-fieldtempb
    fieldclc=fieldclc-fieldclcb
    fieldqi=fieldqi-fieldqib
    fieldqc=fieldqc-fieldqcb
  end if
  ;field to be plotted to plot
  fieldrhb = fieldrh
  fieldtempb = fieldtemp
  fieldclcb = fieldclc
  fieldqib = fieldqi
  fieldqcb = fieldqc
  delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])
end if

;--------------------------------------------------------------------------
; from file 3
title3="3M"
;infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_96gp_"+sst+"_more_"+ddate+"_fldtmn.nc","r")
;infile = addfile("to_data/cdodata/rce_ecs_20km_96gp_301_more_fldsum_tmn.nc","r")
;infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_96gp_301_more_junjulaug11_fldtmn.nc","r")
;infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_96gp_"+sst+"_more_"+ddate+"_fldtmn.nc","r")
infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_96gp_297_more_MJJA18_fldtmn.nc","r")
print("--------------------------------------------------------------------------")
print("file being read is: 96, 3M")
print("--------------------------------------------------------------------------")

fieldrh = infile->$varnamerh$(plotTime2,:,0,0)
fieldtemp = infile->$varnamet$(plotTime,:,0,0)
fieldclc = infile->$varnameclc$(plotTime,:,0,0)
fieldqi = infile->$varnameqi$(plotTime,:,0,0)
fieldqc = infile->$varnameqc$(plotTime,:,0,0)
totcld    = infile->clct(:,:,:)
totqv     = infile->tqv(:,:,:)
totqc     = infile->tqc(:,:,:)
totqi     = infile->tqi(:,:,:)

print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

;field to be plotted
fieldrhc = fieldrh
fieldtempc = fieldtemp
fieldclcc = fieldclc
fieldqic = fieldqi
fieldqcc = fieldqc

print("max of fieldqi: "+max(fieldqic))
print("max of fieldqc: "+max(fieldqcc))
delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])

;read in data from 301K experiment
if (sst .eq. 301) then
  infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_96gp_301_more_MJJA18_fldtmn.nc","r")
  fieldrh = infile->$varnamerh$(plotTime,:,0,0)
  fieldtemp = infile->$varnamet$(plotTime,:,0,0)
  fieldclc = infile->$varnameclc$(plotTime,:,0,0)
  fieldqi = infile->$varnameqi$(plotTime,:,0,0)
  fieldqc = infile->$varnameqc$(plotTime,:,0,0)
  totcld    = infile->clct(:,:,:)
  totqv     = infile->tqv(:,:,:)
  totqc     = infile->tqc(:,:,:)
  totqi     = infile->tqi(:,:,:)
print("sst = 301")
print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

  ; if plotting difference between 301K and 297K:
  if (isvar("diff")) then
    fieldrh=fieldrh-fieldrhc
    fieldtemp=fieldtemp-fieldtempc
    fieldclc=fieldclc-fieldclcc
    fieldqi=fieldqi-fieldqic
    fieldqc=fieldqc-fieldqcc
  end if
  ;field to be plotted
  fieldrhc = fieldrh
  fieldtempc = fieldtemp
  fieldclcc = fieldclc
  fieldqic = fieldqi
  fieldqcc = fieldqc
  delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])
end if

;--------------------------------------------------------------------------
; from file 4
title4="200M"
;title4="50M Rotation"
;title4="3/4 M"
infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_768gp_297_more_aprjul23d_fldtmn.nc","r")
;infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_96gp_297_more_MJJA18_fldtmn.nc","r")
;infile = addfile("elisa_rce_ecs_20km_384gp_297_more_select_fldtmn.nc","r")
print("--------------------------------------------------------------------------")
print("file being read is: 768, 200M")
print("--------------------------------------------------------------------------")

fieldrh = infile->$varnamerh$(plotTime2,:,0,0)
fieldtemp = infile->$varnamet$(plotTime,:,0,0)
fieldclc = infile->$varnameclc$(plotTime,:,0,0)
fieldqi = infile->$varnameqi$(plotTime,:,0,0)
fieldqc = infile->$varnameqc$(plotTime,:,0,0)
totcld    = infile->clct(:,:,:)
totqv     = infile->tqv(:,:,:)
totqc     = infile->tqc(:,:,:)
totqi     = infile->tqi(:,:,:)

print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")


;field to be plotted
fieldrhd = fieldrh
fieldtempd = fieldtemp
fieldclcd = fieldclc
fieldqid = fieldqi
fieldqcd = fieldqc

print("max of fieldqi: "+max(fieldqid))
print("max of fieldqc: "+max(fieldqcd))
delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])

;read in data from 301K experiment
if (sst .eq. 301) then
  infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_768gp_301_more_aprjul23d_fldtmn.nc","r")
  ;infile = addfile("elisa_rce_ecs_20km_384gp_297_more_select_fldtmn.nc","r")
  ;infile = addfile("to_exps/rce_ecs_20km_48gp_301/rce_ecs_20km_48gp_301_more_fldtmn.nc","r")
  fieldrh = infile->$varnamerh$(plotTime,:,0,0)
  fieldtemp = infile->$varnamet$(plotTime,:,0,0)
  fieldclc = infile->$varnameclc$(plotTime,:,0,0)
  fieldqi = infile->$varnameqi$(plotTime,:,0,0)
  fieldqc = infile->$varnameqc$(plotTime,:,0,0)
  totcld    = infile->clct(:,:,:)
  totqv     = infile->tqv(:,:,:)
  totqc     = infile->tqc(:,:,:)
  totqi     = infile->tqi(:,:,:)
print("sst = 301")
print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

  ; if plotting difference between 301K and 297K:
  if (isvar("diff")) then
    fieldrh=fieldrh-fieldrhd
    fieldtemp=fieldtemp-fieldtempd
    fieldclc=fieldclc-fieldclcd
    fieldqi=fieldqi-fieldqid
    fieldqc=fieldqc-fieldqcd
  end if

  ;field to be plotted
  fieldrhd = fieldrh
  fieldtempd = fieldtemp
  fieldclcd = fieldclc
  fieldqid = fieldqi
  fieldqcd = fieldqc

  delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])
end if

;--------------------------------------------------------------------------
; from file 5
title5="3/4 M"
infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_48gp_297_more_lstyr_fldtmn.nc","r")
print("--------------------------------------------------------------------------")
print("file being read is: 48, 3/4M")
print("--------------------------------------------------------------------------")

fieldrh = infile->$varnamerh$(plotTime2,:,0,0)
fieldtemp = infile->$varnamet$(plotTime,:,0,0)
fieldclc = infile->$varnameclc$(plotTime,:,0,0)
fieldqi = infile->$varnameqi$(plotTime,:,0,0)
fieldqc = infile->$varnameqc$(plotTime,:,0,0)
totcld    = infile->clct(:,:,:)
totqv     = infile->tqv(:,:,:)
totqc     = infile->tqc(:,:,:)
totqi     = infile->tqi(:,:,:)

print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

;field to be plotted
fieldrhe = fieldrh
fieldtempe = fieldtemp
fieldclce = fieldclc
fieldqie = fieldqi
fieldqce = fieldqc

print("max of fieldqi: "+max(fieldqid))
print("max of fieldqc: "+max(fieldqcd))
delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])

;read in data from 301K experiment
if (sst .eq. 301) then
  infile = addfile("../to_ecs/mean_timerun/rce_ecs_20km_48gp_301_more_lstyr_fldtmn.nc","r")
  ;infile = addfile("elisa_rce_ecs_20km_384gp_297_more_select_fldtmn.nc","r")
  ;infile = addfile("to_exps/rce_ecs_20km_48gp_301/rce_ecs_20km_48gp_301_more_fldtmn.nc","r")
  fieldrh = infile->$varnamerh$(plotTime,:,0,0)
  fieldtemp = infile->$varnamet$(plotTime,:,0,0)
  fieldclc = infile->$varnameclc$(plotTime,:,0,0)
  fieldqi = infile->$varnameqi$(plotTime,:,0,0)
  fieldqc = infile->$varnameqc$(plotTime,:,0,0)
  totcld    = infile->clct(:,:,:)
  totqv     = infile->tqv(:,:,:)
  totqc     = infile->tqc(:,:,:)
  totqi     = infile->tqi(:,:,:)
print("sst = 301")
print("total cloud cover is: "+totcld+" %")
print("total integrated water vapor is: "+totqv+"[kg/m^2]")
print("total integrated liquid water is: "+totqc+"[kg/m^2]")
print("total integrated cloud ice is: "+totqi+"[kg/m^2]")

  ; if plotting difference between 301K and 297K:
  if (isvar("diff")) then
    fieldrh=fieldrh-fieldrhe
    fieldtemp=fieldtemp-fieldtempe
    fieldclc=fieldclc-fieldclce
    fieldqi=fieldqi-fieldqie
    fieldqc=fieldqc-fieldqce
  end if

  ;field to be plotted
  fieldrhe = fieldrh
  fieldtempe = fieldtemp
  fieldclce = fieldclc
  fieldqie = fieldqi
  fieldqce = fieldqc

  delete([/infile,fieldrh,fieldtemp,fieldclc,fieldqi,fieldqc/])
end if

;--------------------------------------------------------------------------


; it seems that when cdo is used to produce a time average
; the values of the vertical coordinate are set to zero
; the vertical coordinate must then be read from a file 
; in which averaging has not taken place....
if (isvar("gFile")) then
  delete(fieldz)
  delete(infile)
  infile = addfile(gFile+".nc","r")
  fieldz = infile->$varnamez$(:,0,0)
  vaxis1=fieldz/1000.
end if
; basic checks for bug finding
; scale factor (86400 converts kg/(m^2 s) to mm/day)
scale=1
print("scale factor is currently: "+scale)
; make plots....
;=========================================================================;
        plot_type=plottype
	wks  = gsn_open_wks(plot_type,"testplot")   	; output using eps
        ;gsn_define_colormap(wks,"gui_default")
        ;gsn_define_colormap(wks,"GMT_gray")
        gsn_define_colormap(wks,"CBR_drywet")
        ;create a plot array
        plot = new(5,graphic)

; plot resources
        ymaxval = 24 ; maximum height for y axis
        ;ymaxval = 6.0 ; maximum height for y axis
     	lthick = 1.5 ; line thickness
        hxaxis = 0.03; x axis font height
        tmxheight = 0.025
        lsolid = 0   ; solid marking for lines
;        dasha   = 12   ; dashed marking for lines
;        dashb   = 16   ; dashed marking for lines
;        dashc   = 11
;        dashe   = 2 
;        dashd   = 0
        dasha   = 0   ; dashed marking for lines
        dashb   = 0   ; dashed marking for lines
        dashc   = 0 
        dashe   = 0 
        dashd   = 0
;       colors1 defines the colors of the different spectra
;        colors1 = (/"OrangeRed","Black","GoldenRod","SteelBlue","LawnGreen"/) 
        ;colors1 = (/12,11,10,9,8/) ; greens
        colors1 = (/2,3,4,5,6/) ; browns
        ;colors1 = (/"black","black","black","black","black"/) 
     	res          = True

        res@gsnDraw          = False
        res@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
	;res@tiMainString      = maintitle
     	;res@gsnCenterString   = varname
        res@tmYROn            = False
        res@tmXTOn            = False
        res@tmYRBorderOn      = False
        res@tmXTBorderOn      = False
     	res@tiXAxisString     = xtitle
        res@tiXAxisFontHeightF= hxaxis
        res@tmXBLabelFontHeightF = tmxheight
        res@tiYAxisFontHeightF= 0.04
     	res@tiYAxisString     = "z (km)"
        res@tmYLLabelFontHeightF = 0.025
   ; resgc@tmXBMode      = "Explicit"
   ; resgc@tmXBValues    = (/0.0,0.02,0.04/)
   ; resgc@tmXBLabels    = "" + resgc@tmXBValues
        res@vpWidthF          = 0.4 ; vpWidth and Height control box size
        res@vpHeightF         = 0.7
     	res@gsnFrame          = False
     	res@xyLineThicknessF  = lthick

        ;res@xyLineColor       = line_col
        ;res@xyDashPattern     = line_pat

;       add a legend
 
    lgres                      = True
    lgres@xyLabelMode            = "Custom"
    lgres@xyLineLabelFontHeightF = 0.015                ; font height
    lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2),colors1(3),colors1(4)/)
    ;lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2),colors1(3),colors1(4)/)
    lgres@lgItemType           = "Lines"
    lgres@lgLabelFontHeightF   = .10
    lgres@vpWidthF             = 0.2        ; width of legend
    lgres@vpHeightF            = 0.18        ; height of legend
    lgres@lgLineThicknessF     = lthick
    lgres@lgPerimThicknessF    = 2.0
    lgres@lgMonoDashIndex      = False 
    ;lgres@lgDashIndexes          = (/"0","12","16","11","2"/)
    ;lgres@lgDashIndexes          = (/"2","2","0","0","0"/)
    lgres@lgDashIndexes          = (/"0","0","0","0","0"/)
    ;lgres@lgDashIndexes          = (/200,50,12,3,3/4/)
    lgres@lgPerimOn            = False

; set up axis limits
if (sst .eq. 301) then
  if (isvar("diff")) then
    res@trXMinF = -15.       
    res@trXMaxF = 15.       
  else
    res@trXMinF = 0.       
    res@trXMaxF = 100.       
  end if
end if
    res@trYMinF = 0       
    res@trYMaxF = ymaxval       

    res@xyDashPattern = dasha
    res@xyLineColors  = colors1(1) 
    plot0a    = gsn_csm_xy (wks,fieldrha(:),vaxis1,res) 		; create plot    
    res@xyDashPattern = dashb
    res@xyLineColors  = colors1(2) 
    plot0b    = gsn_csm_xy (wks,fieldrhb(:),vaxis1,res) 		; create plot    
    res@xyDashPattern = dashc
    res@xyLineColors  = colors1(3) 
    plot0c    = gsn_csm_xy (wks,fieldrhc(:),vaxis1,res) 		; create plot    
    res@xyDashPattern = dashe
    res@xyLineColors  = colors1(4) 
    plot0d    = gsn_csm_xy (wks,fieldrhe(:),vaxis1,res) 		; create plot    
    res@xyDashPattern = dashd
    res@xyLineColors  = colors1(0) 
    plot0e    = gsn_csm_xy (wks,fieldrhd(:),vaxis1,res) 		; create plot    

    overlay(plot0b,plot0c) 
    overlay(plot0b,plot0d) 
    overlay(plot0b,plot0e) 
    overlay(plot0b,plot0a) 
 
    plot(0) = plot0b

;-second figure of panel-------------------------------------------------
;	pltTitle="title" ; Plot title if required 
    
    ;restemp@tiMainString      = maintitle
    res@tiXAxisString    = "Domain mean Temp (K)"
    res@tiYAxisOn        = False
    res@tmYLLabelsOn     = False
    res@tmXBMode         = "Manual"
    ;restemp@tiYAxisString     = "z (km)"
    res@trXMinF          = 180.
    res@trXMaxF          = 320.
    res@tmXBTickStartF   = 180.       
    res@tmXBTickEndF     = 320. 
    res@tmXBTickSpacingF = 40  
    ;res@gsnLeftString    = "tmXBMode = Manual"   
    ;res@tmXBValues    = (/220.,260.,300./)
; set up axis limits
if (sst .eq. 301) then
  if (isvar("diff")) then
    res@trXMinF = 0.      
    res@trXMaxF = 15.       
    res@tmXBTickStartF   = 0.       
    res@tmXBTickEndF     = 15. 
    res@tmXBTickSpacingF = 2  
    ;res@tmXBValues    = (/0.,5.,10./)
  end if
end if
    ;res@tmXBLabels    = "" + res@tmXBValues
    res@trYMinF = 0       
    res@trYMaxF = ymaxval       
    res@xyLineColors  = colors1(1) 
    res@xyDashPattern = dasha
    ;print("temp equals: "+fieldtempa+" vaxis: "+vaxis1)
    plot1a    = gsn_csm_xy (wks,fieldtempa(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(2) 
    res@xyDashPattern = dashb
    ;print("temp equals: "+fieldtempa+" vaxis: "+vaxis1)
    plot1b    = gsn_csm_xy (wks,fieldtempb(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(3) 
    res@xyDashPattern = dashc
    ;print("temp equals: "+fieldtempa+" vaxis: "+vaxis1)
    plot1c    = gsn_csm_xy (wks,fieldtempc(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(4) 
    res@xyDashPattern = dashe
    ;print("temp equals: "+fieldtempa+" vaxis: "+vaxis1)
    plot1d    = gsn_csm_xy (wks,fieldtempe(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(0) 
    res@xyDashPattern = dashd
    ;print("temp a,b,c,d,e equals: "+fieldtempa+" "+fieldtempb+" "+fieldtempc+" "+fieldtempd+" "+fieldtempe+" vaxis: "+vaxis1)
    plot1e    = gsn_csm_xy (wks,fieldtempd(:),vaxis1,res)   ; create plot    

    overlay(plot1b,plot1c) 
    overlay(plot1b,plot1d) 
    overlay(plot1b,plot1e) 
    overlay(plot1b,plot1a) 

    plot(1) = plot1b

;-third figure of panel-------------------------------------------------

    ;res@tiMainString      = maintitle
   ;res@gsnCenterString   = varname
    res@tiXAxisString     = "Cloud Cov (%)"
    res@tmXBMode         = "Automatic"
    res@tmYLLabelsOn      = False
    res@trXMinF = 0.       
    res@trXMaxF = 50. 
    res@gsnFrame          = False
    res@xyLineThicknessF  = lthick
; set up axis limits
if (sst .eq. 301) then
  if (isvar("diff")) then
    res@trXMinF = -20       
    res@trXMaxF = 20       
  end if
end if      
    res@xyLineColors  = colors1(1) 
    res@xyDashPattern = dasha
    plot2a    = gsn_csm_xy (wks,fieldclca(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(2) 
    res@xyDashPattern = dashb
    plot2b    = gsn_csm_xy (wks,fieldclcb(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(3) 
    res@xyDashPattern = dashc
    plot2c    = gsn_csm_xy (wks,fieldclcc(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(4) 
    res@xyDashPattern = dashe
    plot2d    = gsn_csm_xy (wks,fieldclce(:),vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(0) 
    res@xyDashPattern = dashd
    plot2e    = gsn_csm_xy (wks,fieldclcd(:),vaxis1,res)   ; create plot    

    overlay(plot2b,plot2c)
    overlay(plot2b,plot2d)
    overlay(plot2b,plot2e)
    overlay(plot2b,plot2a)

    plot(2) = plot2b

;-fourth figure of panel-------------------------------------------------
    
    res@tiXAxisString     = "Cloud Liq water (g/kg)"
    res@tiXAxisFontHeightF= hxaxis
    res@tmXBLabelFontHeightF = tmxheight
    res@tmYLLabelsOn      = False
    res@vpWidthF          = 0.4
    res@vpHeightF         = 0.7
    res@gsnFrame          = False
    res@xyLineThicknessF  = lthick
    ;res@tmXBMode      = "Explicit"
    res@trXMinF = 0.0       
    res@trXMaxF = 0.04  
    res@tmXBFormat = "f" ; remove trailing 0     
    res@tmXBPrecision = 2   ; set the precision to 2 significant digits
    ;res@tmXBValues    = (/0.0,0.01,0.02,0.03,0.04/)
; set up axis limits
if (sst .eq. 301) then
  if (isvar("diff")) then
    res@trXMinF = -0.04       
    res@trXMaxF = 0.04       
    ;res@tmXBValues    = (/-0.04,-0.02,0.0,0.02,0.04/)
  end if
end if
    ;res@tmXBLabels    = "" + res@tmXBValues
    res@trYMinF = 0       
    res@trYMaxF = ymaxval       
    res@xyLineColors  = colors1(1) 
    res@xyDashPattern = dasha
    plot3a    = gsn_csm_xy (wks,fieldqca(:)*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(2) 
    res@xyDashPattern = dashb
    plot3b    = gsn_csm_xy (wks,fieldqcb(:)*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(3) 
    res@xyDashPattern = dashc
    plot3c    = gsn_csm_xy (wks,fieldqcc(:)*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(4) 
    res@xyDashPattern = dashe
    plot3d    = gsn_csm_xy (wks,fieldqce(:)*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(0) 
    res@xyDashPattern = dashd
    plot3e    = gsn_csm_xy (wks,fieldqcd(:)*convscale,vaxis1,res)   ; create plot    

    overlay(plot3b,plot3c)
    overlay(plot3b,plot3d)
    overlay(plot3b,plot3e)
    overlay(plot3b,plot3a)

    plot(3) = plot3b

;-fifth figure of panel-------------------------------------------------
    scaleqi        = 1000.0

    res@tiXAxisString     = "Cloud Ice (mg/kg)"
    ;res@tiXAxisString     = "qv (g/kg)"
    res@tiXAxisFontHeightF= hxaxis
    res@tmXBLabelFontHeightF = tmxheight
    res@tmYLLabelsOn      = False
   ; res@tiYAxisString     = "z (km)"
    res@vpWidthF          = 0.4
    res@vpHeightF         = 0.7
    res@gsnFrame          = False
    res@xyLineThicknessF  = lthick
    res@trXMinF = 0.0       
    res@trXMaxF = 8.0       
    ;res@tmXBMode      = "Explicit"
    ;res@tmXBValues    = (/0.0,2.0,4.0,6.0/)
; set up axis limits
if (sst .eq. 301) then
  if (isvar("diff")) then
    res@trXMinF = -2.0       
    res@trXMaxF = 6.0       
    ;res@tmXBValues    = (/0.0,2.0,4.0,6.0/)
  end if
end if
    ;res@tmXBLabels    = "" + res@tmXBValues
    res@trYMinF = 0       
    res@trYMaxF = ymaxval        
    res@xyLineColors  = colors1(1) 
    res@xyDashPattern = dasha
    plot4a    = gsn_csm_xy (wks,fieldqia(:)*scaleqi*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(2) 
    res@xyDashPattern = dashb
    plot4b    = gsn_csm_xy (wks,fieldqib(:)*scaleqi*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(3) 
    res@xyDashPattern = dashc
    plot4c    = gsn_csm_xy (wks,fieldqic(:)*scaleqi*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(4) 
    res@xyDashPattern = dashe
    plot4d    = gsn_csm_xy (wks,fieldqie(:)*scaleqi*convscale,vaxis1,res)   ; create plot    
    res@xyLineColors  = colors1(0) 
    res@xyDashPattern = dashd
    plot4e    = gsn_csm_xy (wks,fieldqid(:)*scaleqi*convscale,vaxis1,res)   ; create plot    
  
  
    overlay(plot4b,plot4c)
    overlay(plot4b,plot4d)
    overlay(plot4b,plot4e)
    overlay(plot4b,plot4a)

    labels = (/title4,title1,title2,title3,title5/)
    ;labels = (/"first","second","third","fourth"/) ; starting at bottom
    legend  = gsn_create_legend (wks, 5, labels, lgres)
    amres = True
    amres@amJust = "BottomRight"

    amres@amParallelPosF   = 0.44    ; Move legend to right
    amres@amOrthogonalPosF = 0.47     ; Move legend down
    if (isvar("diff")) then
      amres@amOrthogonalPosF =-0.22     ; Move legend down
    end if

    annoid = gsn_add_annotation(plot4b,legend,amres) ; add legend to plot

    plot(4) = plot4b

; draw the plots on page One 

    respanel = True
    respanel@txString = maintitle

    gsn_panel(wks,plot,(/1,5/),respanel)

  ;  psres = True
  ;  maximize_output(wks,psres)   ; draw everything on the workstation  
end






