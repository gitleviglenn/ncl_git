;================================================;
; vprofile_updown_new
;
;	produces a 5 figure panel of the vertical 
;       profiles for various variables.
;
; levi silvers  		October 2013
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;
begin

; this turns off warnings.  be careful!
print("warnings turned off!")
err = NhlGetErrorObjectId()
setvalues err
  "errLevel" : "Fatal" ; only report Fatal errors
end setvalues 

; look for input parameters, set defaults otherwise
if (.not. isvar("title")) then
  maintitle = "Mean Vertical Structure ";+ddate
else
  maintitle = title
end if

; default plotform type is eps
if (.not. isvar("plotform")) then
  plottype = "eps" 
else
  plottype = plotform
end if

; set additional parameters-----------------------------------------------
xtitle="Relative Humidity"

; physical constants
rd  = 287.04 ; J/(K kg)
cpd = 1004.64 ; J/(K kg)
kap = rd/cpd
rkap = cpd/rd
p0  = 1000.0  ; hPa ref press  

tlev=59
plevel=38
hlev  = 38
;; increment is the increment of time between the two profiles 
plotincrement=0

; set appropriate variable name
  varnamerh   ="rh"  
  varnamet  ="temp"
  varnameclc="clc"
  varnameqc ="qc"
  varnameqi ="qi"
  varnamew="w"
  varnamerho="rho"
;  varnamez="z_ifc"
  varnamez  ="z_mc"

;scale for converting from kg/kg to g/kg
convscale=1000.
; scale factor (86400 converts kg/(m^2 s) to mm/day)
scale=1
print("scale factor is currently: "+scale)

; note on indices, fieldz contains interface levels and has one more 
; element than the rho or qv vars, which are defined at model levels.
; the 0 index is the toa, ikend should be the lowest layer
; indices for the time loop it
istart = 1 
;iend   = timelen
inc    = 1 
; indices for the vert loop iv
ikstart = 1 
ikend   = tlev

;-Reading data files-------------------------------------------------------
; read in multiple times, compute the vert vel vor each, and 
; separate the regions of up from down, then average each region over all up/down
; grids at each time step, then when there are two fields, one for up and 
; one for down welling regions, each field having been spacially averaged but still
;;----------------------------200M------------------------------------------
;title5="200M"
;print("reading data for 200M domain")
;; infile: 1 file      all_infiles: multiple files
;; infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_384gp_297_more_julaug10_fldtmn.nc","r")
;;all_infiles = systemfunc("ls to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0020.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0021.nc")  
;;  all_infiles = systemfunc("ls to_exps/rce_ecs_20km_768gp_297/rce_ecs_20km_768gp_297_more_wrhtemp_selvars_new.nc")  
;  all_infiles = systemfunc("ls to_exps/rce_ecs_20km_768gp_297/rce_ecs_20km_768gp_297_more_jul_DOM01_ML_0001.nc")  
;  files_in = addfiles(all_infiles,"r")
;
;  time1=files_in[:]->time
;  timelen=dimsizes(time1)-1
;print("reading data (rh)")
;  fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
;  fieldz    = files_in[0]->$varnamez$(:,0)
;  field3dw  = files_in[:]->$varnamew$(:timelen,:,:)
;  vaxis1    = fieldz/convscale
;
;  dimensions=dimsizes(fieldrh)
;  ncells=dimensions(2)
;; indices for the cells ic
;  icell   = 0
;  endcell = ncells-1
;
;  fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
;  fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
;  fieldrhdowntmn = new((/ikend+1/),float)
;
;print("ncells equals: "+ncells)
;print("time1 = "+dimsizes(time1))
;print("dimsizes of time1 are "+dimsizes(time1))
;print("fieldrh "+dimsizes(fieldrh))
;
;  do ik=ikstart,ikend,inc
;    fieldrhdown@_FillValue = default_fillvalue("float")
;    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
;  end do
;
;  delete([/fieldrh/])
;  fieldrhdownmn=dim_avg_n(fieldrhdown,2)
;
;  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
;  delete([/fieldrhdown,fieldrhdownmn/])
;
;print("max rh down: "+max(fieldrhdowntmn))
;print("reading and computing temp profile")
;  fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
;  fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
;  fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
;  fieldtempdowntmn = new((/ikend+1/),float)
;
;  do ik=ikstart,ikend,inc
;    fieldtempdown@_FillValue = default_fillvalue("float")
;    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
;  end do
;
;  fieldtempdownmn=dim_avg_n(fieldtempdown,2)
;  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
;  delete([/fieldtempdown,fieldtemp,fieldtempdownmn/])
;
;print("reading and computing clc profile")
;  fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
;  fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
;  fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
;  fieldclcdowntmn = new((/ikend+1/),float)
;
;  do ik=ikstart,ikend,inc
;    fieldclcdown@_FillValue = default_fillvalue("float")
;    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
;  end do
;
;  delete(fieldclc)
;  fieldclcdownmn=dim_avg_n(fieldclcdown,2)
;  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
;  delete([/fieldclcdown,fieldclcdownmn/])
;
;print("reading and computing qc profile")
;  fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
;  fieldqc   = fieldqc*convscale
;  fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
;  fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
;  fieldqcdowntmn = new((/ikend+1/),float)
;
;  do ik=ikstart,ikend,inc
;    fieldqcdown@_FillValue = default_fillvalue("float")
;    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
;  end do
;
;print("max of fieldqc: "+max(fieldqc))
;  delete(fieldqc)
;  fieldqcdownmn=dim_avg_n(fieldqcdown,2)
;  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
;  delete([/fieldqcdown,fieldqcdownmn/])
;
;print("reading and computing qi profile")
;  fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
;  fieldqi   = fieldqi*convscale
;print("1max of fieldqi is: "+max(fieldqi))
;  fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
;  fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
;  fieldqidowntmn = new((/ikend+1/),float)
;print("4max of fieldqi is: "+max(fieldqi))
;
;  do ik=ikstart,ikend,inc
;    fieldqidown@_FillValue = default_fillvalue("float")
;    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
;  end do
;
;print("max of fieldqi: "+max(fieldqi))
;  delete(fieldqi)
;  fieldqidownmn=dim_avg_n(fieldqidown,2)
;  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
;  delete([/fieldqidown,fieldqidownmn/])
;
;; eventually, when multible files are read in for 200m, we will have arrays like
;; fieldqidownmn for each of the files.  before taking the time mean of these arrays
;; they should be combined using the ncl function array_append_record(x1,x2,0)
;; add other variables 
;  delete([/field3dw/])
;
;;=========================================================================;
;; make plots....
;;=========================================================================;
;  plot0d    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    
;  overlay(plot0a,plot0d) 
;
;; temp
;  restemp@xyLineColors  = colors1(1) 
;  restemp@xyDashPattern = lsolid
;  plot1d    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    
;  overlay(plot1a,plot1d) 
;
;; clc
;  rescld@xyLineColors  = colors1(1) 
;  rescld@xyDashPattern = lsolid
;  plot2d    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    
;  overlay(plot2a,plot2d)
;
;; qc
;  resgc@xyLineColors  = colors1(1) 
;  resgc@xyDashPattern = lsolid
;  plot3d    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    
;  overlay(plot3a,plot3d)
;
;; qi
;  resqi@xyLineColors  = colors1(1) 
;  resqi@xyDashPattern = lsolid
;  plot4d    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    
;  overlay(plot4a,plot4d)

;----------------------------50M-------------------------------------------
title2="50M"
print("reading data for 50M domain")
;delete([/fieldz,time1,all_infiles,files_in/])
;infile = addfile(iFile+".nc","r")
; infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_384gp_297_more_julaug10_fldtmn.nc","r")
all_infiles = systemfunc("ls to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0017.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0018.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0019.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0020.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0021.nc")  
; the file ending JA10_0020s_selvar contains 30 days of data
;all_infiles = systemfunc("ls to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_0020s_selvars.nc")  
files_in = addfiles(all_infiles,"r")

time1=files_in[:]->time
print("time1 = "+dimsizes(time1))
timelen=dimsizes(time1)-1
; end index for timeloops
;iend   = timelen

;-read data----------------------------------------------------------------
; from file 1
; containing multiple times, then average over time....
print("reading data (rh)")
fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
fieldz    = files_in[0]->$varnamez$(:,0)
vaxis1    = fieldz/convscale
print("reading data (exner,w)")
;fieldex   = files_in[:]->exner(:timelen,plevel,:)
;fieldw    = files_in[:]->$varnamew$(:timelen,plevel,:)
field3dw    = files_in[:]->$varnamew$(:timelen,:,:)
;fieldrho  = files_in[:]->$varnamerho$(:timelen,:,:)
; to plot the upwelling regions reverse sign

plotdown=0 
print("-----------------------------------------")
  if (plotdown .eq. 1) then
    print("plotting profiles for downwelling regions")
  else
    field3dw=-field3dw
    print("plotting profiles for upwelling regions")
  end if
print("-----------------------------------------")

; perform vertical integration 

dimensions=dimsizes(fieldrh)
print("fieldrh "+dimsizes(fieldrh))
ncells=dimensions(2)

; indices for the cells ic
icell   = 0
endcell = ncells-1
print("ncells equals: "+ncells)

print("defining new arrays for computations")
fieldvert= new((/ikend+1/),float)

fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldrhdowntmn = new((/ikend+1/),float)
print("dimsizes of time1 are "+dimsizes(time1))

print("vaxis1 "+dimsizes(vaxis1))

  do ik=ikstart,ikend,inc
    fieldrhdown@_FillValue = default_fillvalue("float")
    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
  end do

;delete([/fieldex,fieldrh/])
delete([/fieldrh/])
fieldrhdownmn=dim_avg_n(fieldrhdown,2)
delete(fieldrhdown)

print("reading and computing temp profile")
fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldtempdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldtempdown@_FillValue = default_fillvalue("float")
    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
  end do

fieldtempdownmn=dim_avg_n(fieldtempdown,2)
delete([/fieldtempdown,fieldtemp/])

print("reading and computing clc profile")
fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldclcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldclcdown@_FillValue = default_fillvalue("float")
    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
  end do

delete(fieldclc)
fieldclcdownmn=dim_avg_n(fieldclcdown,2)
delete(fieldclcdown)

print("reading and computing qc profile")
fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
fieldqc   = fieldqc*convscale
fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldqcdown@_FillValue = default_fillvalue("float")
    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
  end do

print("max of fieldqc: "+max(fieldqc))
delete(fieldqc)
fieldqcdownmn=dim_avg_n(fieldqcdown,2)
delete(fieldqcdown)

print("reading and computing qi profile")
fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
fieldqi   = fieldqi*convscale
fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqidowntmn = new((/ikend+1/),float)
print("max of fieldqi is: "+max(fieldqi))

  do ik=ikstart,ikend,inc
    fieldqidown@_FillValue = default_fillvalue("float")
    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
  end do

print("max of fieldqi: "+max(fieldqi))
delete(fieldqi)
fieldqidownmn=dim_avg_n(fieldqidown,2)
delete(fieldqidown)

;3.  take the time mean of the two regions
  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
  print("max rh down: "+max(fieldrhdowntmn))
  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
  print("max temp down: "+max(fieldtempdowntmn))
  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
  print("max clc down: "+max(fieldclcdowntmn))
  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
  print("max qc down: "+max(fieldqcdowntmn))
  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
  print("max qi down: "+max(fieldqidowntmn))

  delete([/field3dw,fieldrhdownmn,fieldtempdownmn,fieldclcdownmn,fieldqcdownmn,fieldqidownmn/])

;=========================================================================;
; make plots....
;=========================================================================;
plot_type=plottype
wks  = gsn_open_wks(plot_type,"testplot")   	; output using eps
gsn_define_colormap(wks,"gui_default")
;create a plot array
plot = new(5,graphic)

; plot resources
ymaxval = 24 ; maximum height for y axis
lthick = 2.0 ; line thickness
hxaxis = 0.03; x axis font height
tmxheight = 0.025
lsolid = 0   ; solid marking for lines
ldash  = 1   ; dashed marking for lines
;       colors1 defines the colors of the different spectra
colors1 = (/"LawnGreen","SteelBlue","GoldenRod","Black","OrangeRed"/) 

res          = True

  res@gsnDraw          = False
  res@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
  ;res@tiMainString      = maintitle2
  ;res@gsnCenterString   = varname
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
    lgres@xyLineLabelFontHeightF = 0.020                ; font height
    lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2)/)
    lgres@lgItemType           = "Lines"
    lgres@lgLabelFontHeightF   = .10
    lgres@vpWidthF             = 0.3        ; width of legend
    lgres@vpHeightF            = 0.20        ; height of legend
    lgres@lgLineThicknessF     = lthick
    lgres@lgPerimThicknessF    = 2.0
    lgres@lgMonoDashIndex      = False 
    lgres@lgDashIndexes          = (/"0","0","0"/)
    lgres@lgPerimOn            = False

; set up axis limits
  res@trXMinF = 0       
  res@trXMaxF = 100       
  res@trYMinF = 0       
  res@trYMaxF = ymaxval       

  res@xyDashPattern = lsolid ; 0 gives solid line
  res@xyLineColors  = colors1(3) 
  print("vaxis1 "+dimsizes(vaxis1))
  print("fielddowntmn "+dimsizes(fieldrhdowntmn))
  res@xyDashPattern = lsolid
  plot0a    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    

;-second figure of panel-------------------------------------------------
    restemp          = True

  restemp@gsnDraw          = False
  restemp@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
  maintitle2 = "Mn Vert Structure for Upwelling Regions"
  ;restemp@tiMainString      = maintitle
  ;restemp@gsnCenterString   = varname
  restemp@tiXAxisString     = "Domain mean Temp"
  restemp@tiXAxisFontHeightF= hxaxis
  restemp@tmYLLabelsOn      = False
  restemp@tmXBLabelFontHeightF = 0.025
  restemp@tmXBMode      = "Explicit"
  restemp@tmXBValues    = (/220,260,300/)
  restemp@tmXBLabels    = "" + restemp@tmXBValues
  ;restemp@tiYAxisString     = "z (km)"
  restemp@vpWidthF          = 0.4
  restemp@vpHeightF         = 0.7
  restemp@gsnFrame          = False
  restemp@xyLineThicknessF  = lthick
; set up axis limits
  restemp@trXMinF = 190       
  restemp@trXMaxF = 320       
  restemp@trYMinF = 0       
  restemp@trYMaxF = ymaxval       
  restemp@xyLineColors  = colors1(3) 
  restemp@xyDashPattern = lsolid
  plot1a    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    

;-third figure of panel-------------------------------------------------
  rescld          = True

  rescld@gsnDraw          = False
  rescld@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
  ;rescld@tiMainString      = maintitle
  ;rescld@gsnCenterString   = varname
  rescld@tiXAxisString     = "Cloud Cov %"
  rescld@tiXAxisFontHeightF= hxaxis
  rescld@tmXBLabelFontHeightF = tmxheight
  rescld@tmYLLabelsOn      = False
  rescld@vpWidthF          = 0.4
  rescld@vpHeightF         = 0.7
  rescld@gsnFrame          = False
  rescld@xyLineThicknessF  = lthick
; set up axis limits
  rescld@trXMinF = 0       
  rescld@trXMaxF = 80       
  rescld@trYMinF = 0       
  rescld@trYMaxF = ymaxval       
  rescld@xyLineColors  = colors1(3) 
  rescld@xyDashPattern = lsolid
  plot2a    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    

;-fourth figure of panel-------------------------------------------------
    resgc          = True

    resgc@gsnDraw          = False
    resgc@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
    ;resgc@tiMainString      = maintitle
   ;resgc@gsnCenterString   = varname
    resgc@tiXAxisString     = "Cloud Liq water (g/kg)"
    resgc@tiXAxisFontHeightF= hxaxis
    resgc@tmXBLabelFontHeightF = tmxheight
    resgc@tmYLLabelsOn      = False
    resgc@vpWidthF          = 0.4
    resgc@vpHeightF         = 0.7
    resgc@gsnFrame          = False
    resgc@xyLineThicknessF  = lthick
; set up axis limits
    resgc@trXMinF = 0       
    resgc@trXMaxF = 0.08       
    ;resgc@trXMaxF = 0.04       
    resgc@trYMinF = 0       
    resgc@trYMaxF = ymaxval       
    resgc@tmXBMode      = "Explicit"
    resgc@tmXBValues    = (/0.0,0.02,0.04,0.06,0.08/)
    resgc@tmXBLabels    = "" + resgc@tmXBValues
    resgc@xyLineColors  = colors1(3) 
    resgc@xyDashPattern = lsolid
    plot3a    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    

;-fifth figure of panel-------------------------------------------------
    resqi          = True

    resqi@gsnDraw          = False
    resqi@gsnFrame         = False
;	pltTitle="title" ; Plot title if required 
    
    ;resqi@tiMainString      = maintitle
   ;resqi@gsnCenterString   = varname
    resqi@tiXAxisString     = "Cloud Ice (mg/kg)"
    resqi@tiXAxisFontHeightF= hxaxis
    resqi@tmXBLabelFontHeightF = tmxheight
    resqi@tmYLLabelsOn      = False
   ; resqi@tiYAxisString     = "z (km)"
    resqi@vpWidthF          = 0.4
    resqi@vpHeightF         = 0.7
    resqi@gsnFrame          = False
    resqi@xyLineThicknessF  = lthick
; set up axis limits
    resqi@trXMinF = 0       
    ;resqi@trXMaxF = 0.006       
    resqi@trXMaxF = 14.0       
    resqi@trYMinF = 0       
    resqi@trYMaxF = ymaxval        
    resqi@tmXBMode      = "Explicit"
    ;resqi@tmXBValues    = (/0.0,0.003,0.006/)
    resqi@tmXBValues    = (/0.0,2.0,4.0,6.0,8.0,10.0,12.0,14.0/)
    resqi@tmXBLabels    = "" + resqi@tmXBValues
    resqi@xyLineColors  = colors1(3) 
    resqi@xyDashPattern = lsolid
    plot4a    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    

;-------------------------------------------------------------------------
; now read in and process data from second file(s)
;-------------------------------------------------------------------------
;----------------------------200M------------------------------------------
title1="200M"
print("reading data for 200M domain")
delete([/fieldz,time1,all_infiles,files_in/])
; infile: 1 file      all_infiles: multiple files
; infile = addfile("to_ecs/mean_timerun/rce_ecs_20km_384gp_297_more_julaug10_fldtmn.nc","r")
;all_infiles = systemfunc("ls to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0020.nc to_exps/rce_ecs_20km_384gp_297/data_more_aug10/rce_ecs_20km_384gp_297_more_JA10_DOM01_ML_0021.nc")  
;  all_infiles = systemfunc("ls to_exps/rce_ecs_20km_768gp_297/rce_ecs_20km_768gp_297_more_wrhtemp_selvars_new.nc")  
  all_infiles = systemfunc("ls to_exps/rce_ecs_20km_768gp_297/rce_ecs_20km_768gp_297_more_jul_DOM01_ML_0001.nc")  
  files_in = addfiles(all_infiles,"r")

  time1=files_in[:]->time
  timelen=dimsizes(time1)-1
print("reading data (rh)")
  fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
  fieldz    = files_in[0]->$varnamez$(:,0)
  field3dw  = files_in[:]->$varnamew$(:timelen,:,:)
  vaxis1    = fieldz/convscale

  dimensions=dimsizes(fieldrh)
  ncells=dimensions(2)
; indices for the cells ic
  icell   = 0
  endcell = ncells-1

  fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldrhdowntmn = new((/ikend+1/),float)

print("ncells equals: "+ncells)
print("time1 = "+dimsizes(time1))
print("dimsizes of time1 are "+dimsizes(time1))
print("fieldrh "+dimsizes(fieldrh))

  do ik=ikstart,ikend,inc
    fieldrhdown@_FillValue = default_fillvalue("float")
    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
  end do

  delete([/fieldrh/])
  fieldrhdownmn=dim_avg_n(fieldrhdown,2)

  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
  delete([/fieldrhdown,fieldrhdownmn/])

print("max rh down: "+max(fieldrhdowntmn))
print("reading and computing temp profile")
  fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
  fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldtempdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldtempdown@_FillValue = default_fillvalue("float")
    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
  end do

  fieldtempdownmn=dim_avg_n(fieldtempdown,2)
  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
  delete([/fieldtempdown,fieldtemp,fieldtempdownmn/])

print("reading and computing clc profile")
  fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
  fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldclcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldclcdown@_FillValue = default_fillvalue("float")
    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
  end do

  delete(fieldclc)
  fieldclcdownmn=dim_avg_n(fieldclcdown,2)
  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
  delete([/fieldclcdown,fieldclcdownmn/])

print("reading and computing qc profile")
  fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
  fieldqc   = fieldqc*convscale
  fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldqcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldqcdown@_FillValue = default_fillvalue("float")
    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
  end do

print("max of fieldqc: "+max(fieldqc))
  delete(fieldqc)
  fieldqcdownmn=dim_avg_n(fieldqcdown,2)
  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
  delete([/fieldqcdown,fieldqcdownmn/])

print("reading and computing qi profile")
  fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
  fieldqi   = fieldqi*convscale
print("1max of fieldqi is: "+max(fieldqi))
  fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldqidowntmn = new((/ikend+1/),float)
print("4max of fieldqi is: "+max(fieldqi))

  do ik=ikstart,ikend,inc
    fieldqidown@_FillValue = default_fillvalue("float")
    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
  end do

print("max of fieldqi: "+max(fieldqi))
  delete(fieldqi)
  fieldqidownmn=dim_avg_n(fieldqidown,2)
  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
  delete([/fieldqidown,fieldqidownmn/])

; eventually, when multible files are read in for 200m, we will have arrays like
; fieldqidownmn for each of the files.  before taking the time mean of these arrays
; they should be combined using the ncl function array_append_record(x1,x2,0)
; add other variables 
  delete([/field3dw/])

;=========================================================================;
; make plots....
;=========================================================================;
  plot0d    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    
  overlay(plot0a,plot0d) 

; temp
  restemp@xyLineColors  = colors1(4) 
  restemp@xyDashPattern = lsolid
  plot1d    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    
  overlay(plot1a,plot1d) 

; clc
  rescld@xyLineColors  = colors1(4) 
  rescld@xyDashPattern = lsolid
  plot2d    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    
  overlay(plot2a,plot2d)

; qc
  resgc@xyLineColors  = colors1(4) 
  resgc@xyDashPattern = lsolid
  plot3d    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    
  overlay(plot3a,plot3d)

; qi
  resqi@xyLineColors  = colors1(4) 
  resqi@xyDashPattern = lsolid
  plot4d    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    
  overlay(plot4a,plot4d)


;-----------------------------12M------------------------------------------

print("reading data from 12M file...")
delete([/fieldz,time1,all_infiles,files_in/])
;all_infiles = systemfunc("ls to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/rce_ecs_20km_96gp_297_C_more_MJJA18_DOM01_ML_0033.nc to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/rce_ecs_20km_96gp_297_C_more_MJJA18_DOM01_ML_0034.nc")
all_infiles = systemfunc("ls to_exps/rce_ecs_20km_192gp_297/rce_ecs_20km_192gp_297_more_ason12_DOM01_ML_008*")  
files_in = addfiles(all_infiles,"r")
title3="12M"

time1=files_in[:]->time
print("time1 = "+dimsizes(time1))
timelen=dimsizes(time1)-1

print("reading data (rh)")
fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
fieldz    = files_in[0]->$varnamez$(:,0)
print("reading data (exner,w)")
fieldex   = files_in[:]->exner(:timelen,plevel,:)
vaxis1    = fieldz/convscale
field3dw    = files_in[:]->$varnamew$(:timelen,:,:)
;fieldrho  = files_in[:]->$varnamerho$(:timelen,:,:)

print("-----------------------------------------")
  if (plotdown .eq. 1) then
    print("plotting profiles for downwelling regions")
  else
    field3dw=-field3dw
    print("plotting profiles for upwelling regions")
  end if
print("-----------------------------------------")

; perform vertical integration 
; note on indices, fieldz contains interface levels and has one more 
; element than the rho or qv vars, which are defined at model levels.
; the 0 index is the toa, ikend should be the lowest layer
; indices for the time loop it
istart = 1 
;iend   = timelen
inc    = 1 
; indices for the vert loop iv
ikstart = 1 
ikend   = tlev

dimensions=dimsizes(fieldrh)
print("fieldrh "+dimsizes(fieldrh))
ncells=dimensions(2)

; indices for the cells ic
icell   = 0
endcell = ncells-1
print("ncells equals: "+ncells)

print("defining new arrays for computations")
;fieldpress= new((/ikend+1/),float)

fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldrhdowntmn = new((/ikend+1/),float)
print("dimsizes of time1 are "+dimsizes(time1))

print("vaxis1 "+dimsizes(vaxis1))

  do ik=ikstart,ikend,inc
    fieldrhdown@_FillValue = default_fillvalue("float")
    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
  end do

;do it=0,iend,inc
;  subindex=0.0
;  print("beginnig of time loop: at time step: "+it)
;  do ic=icell,endcell,inc
;    fieldrhdown(it,:,ic)=emptyvert
;    ;print("pressure at model levels...")
;    fieldpress = p0*(fieldex(it,ic)^rkap)
;    ;print("pressure at plevel: "+plevel+" is = "+fieldpress)
;;2.  filter the fields into regions of upwelling and downwelling
;    ;relative humidity
;    if (fieldw(it,ic) .lt. 0) then
;      subindex=subindex+1
;      fieldrhdown(it,:,ic)=fieldrh(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;  subsidence(it)=subindex/endcell
;end do ; time

delete([/fieldrh,fieldex/])

fieldrhdownmn=dim_avg_n(fieldrhdown,2)
delete(fieldrhdown)

print("reading and computing temp profile")
fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldtempdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldtempdown@_FillValue = default_fillvalue("float")
    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldtempdown(it,:,ic)=emptyvert
;    if (fieldw(it,ic) .lt. 0) then
;      fieldtempdown(it,:,ic)=fieldtemp(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
delete(fieldtemp)
fieldtempdownmn=dim_avg_n(fieldtempdown,2)
delete(fieldtempdown)

print("reading and computing clc profile")
fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldclcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldclcdown@_FillValue = default_fillvalue("float")
    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldclcdown(it,:,ic)=emptyvert
;    ;cloud cover
;    if (fieldw(it,ic) .lt. 0) then
;      fieldclcdown(it,:,ic)=fieldclc(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
delete(fieldclc)
fieldclcdownmn=dim_avg_n(fieldclcdown,2)
delete(fieldclcdown)

print("reading and computing qc profile")
fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
fieldqc   = fieldqc*convscale
fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldqcdown@_FillValue = default_fillvalue("float")
    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldqcdown(it,:,ic)=emptyvert
;    ;cloud liquid water
;    if (fieldw(it,ic) .lt. 0) then
;      fieldqcdown(it,:,ic)=fieldqc(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
print("max of fieldqc: "+max(fieldqc))
delete(fieldqc)
fieldqcdownmn=dim_avg_n(fieldqcdown,2)
delete(fieldqcdown)

print("reading and computing qi profile")
fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
fieldqi   = fieldqi*convscale
print("1max of fieldqi is: "+max(fieldqi))
fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqidowntmn = new((/ikend+1/),float)
print("4max of fieldqi is: "+max(fieldqi))

  do ik=ikstart,ikend,inc
    fieldqidown@_FillValue = default_fillvalue("float")
    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldqidown(it,:,ic)=emptyvert
;    ;cloud ice
;    if (fieldw(it,ic) .lt. 0) then
;      fieldqidown(it,:,ic)=fieldqi(it,:,ic)
;    end if ; sign of vertical
;  end do ; loop over cells
;end do ; loop over time
print("max of fieldqi: "+max(fieldqi))
delete(fieldqi)
fieldqidownmn=dim_avg_n(fieldqidown,2)
delete(fieldqidown)

;3.  take the time mean of the two regions
  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
  print("max rh down: "+max(fieldrhdowntmn))
  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
  print("max temp down: "+max(fieldtempdowntmn))
  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
  print("max clc down: "+max(fieldclcdowntmn))
  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
  print("max qc down: "+max(fieldqcdowntmn))
  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
  print("max qi down: "+max(fieldqidowntmn))

  delete([/fieldrhdownmn,fieldtempdownmn,fieldclcdownmn,fieldqcdownmn,fieldqidownmn/])

;  avgsub=avg(subsidence)
;  print("mean subsidence fraction is: "+avgsub)
;  delete(subsidence)

;=========================================================================;
; make plots for second file(s)....
;=========================================================================;
  plot0b    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    
  overlay(plot0a,plot0b) 

; temp
  restemp@xyLineColors  = colors1(2) 
  restemp@xyDashPattern = lsolid
  plot1b    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    
  overlay(plot1a,plot1b) 

; clc
  rescld@xyLineColors  = colors1(2) 
  rescld@xyDashPattern = lsolid
  plot2b    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    
  overlay(plot2a,plot2b)

; qc
  resgc@xyLineColors  = colors1(2) 
  resgc@xyDashPattern = lsolid
  plot3b    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    
  overlay(plot3a,plot3b)

; qi
  resqi@xyLineColors  = colors1(2) 
  resqi@xyDashPattern = lsolid
  plot4b    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    
  overlay(plot4a,plot4b)

;-------------------------------------------------------------------------
; now read in and process data from third file(s)
;-------------------------------------------------------------------------
;--------------------------------3M---------------------------------------
print("reading in data from 3M domain")
delete([/fieldz,field3dw,time1,all_infiles,files_in/])
all_infiles = systemfunc("ls to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/*")  
;all_infiles = systemfunc("ls to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/rce_ecs_20km_96gp_297_C_more_MJJA18_DOM01_ML_0034.nc to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/rce_ecs_20km_96gp_297_C_more_MJJA18_DOM01_ML_0035.nc to_exps/rce_ecs_20km_96gp_297_C/more_1mn_18/rce_ecs_20km_96gp_297_C_more_MJJA18_DOM01_ML_0033.nc")
files_in = addfiles(all_infiles,"r")
title4="3M"

;timelen=23
time1=files_in[:]->time
print("time1 = "+dimsizes(time1))
timelen=dimsizes(time1)-1

print("reading data (rh)")
fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
fieldz    = files_in[0]->$varnamez$(:,0)
print("reading data (exner,w)")
fieldex   = files_in[:]->exner(:timelen,plevel,:)
vaxis1    = fieldz/convscale
field3dw    = files_in[:]->$varnamew$(:timelen,:,:)
;fieldrho  = files_in[:]->$varnamerho$(:timelen,:,:)

print("-----------------------------------------")
  if (plotdown .eq. 1) then
    print("plotting profiles for downwelling regions")
  else
    field3dw=-field3dw
    print("plotting profiles for upwelling regions")
  end if
print("-----------------------------------------")

; perform vertical integration 
; note on indices, fieldz contains interface levels and has one more 
; element than the rho or qv vars, which are defined at model levels.
; the 0 index is the toa, ikend should be the lowest layer
; indices for the time loop it
istart = 1 
;iend   = timelen
inc    = 1 
; indices for the vert loop iv
ikstart = 1 
ikend   = tlev

dimensions=dimsizes(fieldrh)
print("fieldrh "+dimsizes(fieldrh))
ncells=dimensions(2)

; indices for the cells ic
icell   = 0
endcell = ncells-1
print("ncells equals: "+ncells)

print("defining new arrays for computations")
fieldvert= new((/ikend+1/),float)
fieldpress= new((/ikend+1/),float)
;subsidence = new((/dimsizes(time1)/),float)

fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldrhdowntmn = new((/ikend+1/),float)
print("dimsizes of time1 are "+dimsizes(time1))

print("vaxis1 "+dimsizes(vaxis1))

emptyvert=fieldvert
empty=default_fillvalue("float")
emptyvert=empty

;subsidence=0.0

  do ik=ikstart,ikend,inc
    fieldrhdown@_FillValue = default_fillvalue("float")
    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
  end do

;do it=0,iend,inc
;  print("beginnig of time loop: at time step: "+it)
;  do ic=icell,endcell,inc
;;2.  filter the fields into regions of upwelling and downwelling
;    if (fieldw(it,ic) .lt. 0) then
;      fieldrhdown(it,:,ic)=fieldrh(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time

delete(fieldex)
delete(fieldrh)

fieldrhdownmn=dim_avg_n(fieldrhdown,2)
delete(fieldrhdown)

print("reading and computing temp profile")
fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldtempdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldtempdown@_FillValue = default_fillvalue("float")
    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldtempdown(it,:,ic)=emptyvert
;    if (fieldw(it,ic) .lt. 0) then
;      fieldtempdown(it,:,ic)=fieldtemp(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
delete(fieldtemp)
fieldtempdownmn=dim_avg_n(fieldtempdown,2)
delete(fieldtempdown)

print("reading and computing clc profile")
fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldclcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldclcdown@_FillValue = default_fillvalue("float")
    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldclcdown(it,:,ic)=emptyvert
;    ;cloud cover
;    if (fieldw(it,ic) .lt. 0) then
;      fieldclcdown(it,:,ic)=fieldclc(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
delete(fieldclc)
fieldclcdownmn=dim_avg_n(fieldclcdown,2)
delete(fieldclcdown)

print("reading and computing qc profile")
fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
fieldqc   = fieldqc*convscale
fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldqcdown@_FillValue = default_fillvalue("float")
    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldqcdown(it,:,ic)=emptyvert
;    ;cloud liquid water
;    if (fieldw(it,ic) .lt. 0) then
;      fieldqcdown(it,:,ic)=fieldqc(it,:,ic)
;    end if ; sign of vertical
;  end do ; cells
;end do ; time
print("max of fieldqc: "+max(fieldqc))
delete(fieldqc)
fieldqcdownmn=dim_avg_n(fieldqcdown,2)
delete(fieldqcdown)

print("reading and computing qi profile")
fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
fieldqi   = fieldqi*convscale
print("1max of fieldqi is: "+max(fieldqi))
fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
fieldqidowntmn = new((/ikend+1/),float)
print("4max of fieldqi is: "+max(fieldqi))

  do ik=ikstart,ikend,inc
    fieldqidown@_FillValue = default_fillvalue("float")
    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
  end do

;do it=0,iend,inc
;  do ic=icell,endcell,inc
;    fieldqidown(it,:,ic)=emptyvert
;    ;cloud ice
;    if (fieldw(it,ic) .lt. 0) then
;      fieldqidown(it,:,ic)=fieldqi(it,:,ic)
;    end if ; sign of vertical
;  end do ; loop over cells
;end do ; loop over time
print("max of fieldqi: "+max(fieldqi))
delete(fieldqi)
fieldqidownmn=dim_avg_n(fieldqidown,2)
delete(fieldqidown)

;3.  take the time mean of the two regions
  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
  print("max rh down: "+max(fieldrhdowntmn))
  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
  print("max temp down: "+max(fieldtempdowntmn))
  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
  print("max clc down: "+max(fieldclcdowntmn))
  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
  print("max qc down: "+max(fieldqcdowntmn))
  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
  print("max qi down: "+max(fieldqidowntmn))

  delete([/fieldrhdownmn,fieldtempdownmn,fieldclcdownmn,fieldqcdownmn,fieldqidownmn/])

;  avgsub=avg(subsidence)
;  print("mean subsidence fraction is: "+avgsub)
;  delete(subsidence)

;=========================================================================;
; make plots for third file(s)....
;=========================================================================;

; rh
  res@xyDashPattern = lsolid
  res@xyLineColors  = colors1(1) 
  plot0c    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    
  overlay(plot0a,plot0c) 
  plot(0) = plot0a

; temp
  restemp@xyLineColors  = colors1(1) 
  restemp@xyDashPattern = lsolid
  plot1c    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    
  overlay(plot1a,plot1c) 
  plot(1) = plot1a

; clc
  rescld@xyLineColors  = colors1(1) 
  rescld@xyDashPattern = lsolid
  plot2c    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    
  overlay(plot2a,plot2c)
  plot(2) = plot2a

; qc
  resgc@xyLineColors  = colors1(1) 
  resgc@xyDashPattern = lsolid
  plot3c    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    
  overlay(plot3a,plot3c)
  plot(3) = plot3a

; qi
  resqi@xyLineColors  = colors1(1) 
  resqi@xyDashPattern = lsolid
  plot4c    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    
  overlay(plot4a,plot4c)
  plot(4) = plot4a

;----------------------------3/4M---------------------------------------------------
title5="3b4M"
print("-----------------------------")
print("reading data for 3b4M domain")
print("-----------------------------")
delete([/fieldz,time1,all_infiles,files_in/])
; infile: 1 file      all_infiles: multiple files
  all_infiles = systemfunc("ls to_exps/rce_ecs_20km_48gp_297/more_4mn/rce_ecs_20km_48gp_297_selvars.nc")  
  files_in = addfiles(all_infiles,"r")

  time1=files_in[:]->time
  timelen=dimsizes(time1)-1
print("reading data (rh)")
  fieldrh   = files_in[:]->$varnamerh$(:timelen,:,:)
  fieldz    = files_in[0]->$varnamez$(:,0)
  field3dw  = files_in[:]->$varnamew$(:timelen,:,:)
  vaxis1    = fieldz/convscale

  dimensions=dimsizes(fieldrh)
  ncells=dimensions(2)
; indices for the cells ic
  icell   = 0
  endcell = ncells-1

  fieldrhdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldrhdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldrhdowntmn = new((/ikend+1/),float)

print("ncells equals: "+ncells)
print("time1 = "+dimsizes(time1))
print("dimsizes of time1 are "+dimsizes(time1))
print("fieldrh "+dimsizes(fieldrh))

  do ik=ikstart,ikend,inc
    fieldrhdown@_FillValue = default_fillvalue("float")
    fieldrhdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldrh(:,ik,:),fieldrhdown@_FillValue)
  end do

  delete([/fieldrh/])
  fieldrhdownmn=dim_avg_n(fieldrhdown,2)

  fieldrhdowntmn=dim_avg_n(fieldrhdownmn,0)
  delete([/fieldrhdown,fieldrhdownmn/])

print("max rh down: "+max(fieldrhdowntmn))
print("reading and computing temp profile")
  fieldtemp = files_in[:]->$varnamet$(:timelen,:,:)
  fieldtempdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldtempdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldtempdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldtempdown@_FillValue = default_fillvalue("float")
    fieldtempdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldtemp(:,ik,:),fieldtempdown@_FillValue)
  end do

  fieldtempdownmn=dim_avg_n(fieldtempdown,2)
  fieldtempdowntmn=dim_avg_n(fieldtempdownmn,0)
  delete([/fieldtempdown,fieldtemp,fieldtempdownmn/])

print("reading and computing clc profile")
  fieldclc  = files_in[:]->$varnameclc$(:timelen,:,:)
  fieldclcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldclcdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldclcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldclcdown@_FillValue = default_fillvalue("float")
    fieldclcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldclc(:,ik,:),fieldclcdown@_FillValue)
  end do

  delete(fieldclc)
  fieldclcdownmn=dim_avg_n(fieldclcdown,2)
  fieldclcdowntmn=dim_avg_n(fieldclcdownmn,0)
  delete([/fieldclcdown,fieldclcdownmn/])

print("reading and computing qc profile")
  fieldqc   = files_in[:]->$varnameqc$(:timelen,:,:)
  fieldqc   = fieldqc*convscale
  fieldqcdown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldqcdownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldqcdowntmn = new((/ikend+1/),float)

  do ik=ikstart,ikend,inc
    fieldqcdown@_FillValue = default_fillvalue("float")
    fieldqcdown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqc(:,ik,:),fieldqcdown@_FillValue)
  end do

print("max of fieldqc: "+max(fieldqc))
  delete(fieldqc)
  fieldqcdownmn=dim_avg_n(fieldqcdown,2)
  fieldqcdowntmn=dim_avg_n(fieldqcdownmn,0)
  delete([/fieldqcdown,fieldqcdownmn/])

print("reading and computing qi profile")
  fieldqi   = files_in[:]->$varnameqi$(:timelen,:,:)
  fieldqi   = fieldqi*convscale
print("1max of fieldqi is: "+max(fieldqi))
  fieldqidown = new((/dimsizes(time1),ikend+1,ncells/),float)
  fieldqidownmn = new((/dimsizes(time1),ikend+1/),float)
  fieldqidowntmn = new((/ikend+1/),float)
print("4max of fieldqi is: "+max(fieldqi))

  do ik=ikstart,ikend,inc
    fieldqidown@_FillValue = default_fillvalue("float")
    fieldqidown(:,ik,:)=where((field3dw(:,hlev,:) .le. 0),fieldqi(:,ik,:),fieldqidown@_FillValue)
  end do

print("max of fieldqi: "+max(fieldqi))
  delete(fieldqi)
  fieldqidownmn=dim_avg_n(fieldqidown,2)
  fieldqidowntmn=dim_avg_n(fieldqidownmn,0)
  delete([/fieldqidown,fieldqidownmn/])

; eventually, when multible files are read in for 200m, we will have arrays like
; fieldqidownmn for each of the files.  before taking the time mean of these arrays
; they should be combined using the ncl function array_append_record(x1,x2,0)
; add other variables 
  delete([/field3dw/])

;=========================================================================;
; make plots....
;=========================================================================;
  plot0e    = gsn_csm_xy (wks,fieldrhdowntmn(:),vaxis1,res) 		; create plot    
  overlay(plot0a,plot0e) 

; temp
  restemp@xyLineColors  = colors1(0) 
  restemp@xyDashPattern = lsolid
  plot1e    = gsn_csm_xy (wks,fieldtempdowntmn(:),vaxis1,restemp)   ; create plot    
  overlay(plot1a,plot1e) 

; clc
  rescld@xyLineColors  = colors1(0) 
  rescld@xyDashPattern = lsolid
  plot2e    = gsn_csm_xy (wks,fieldclcdowntmn(:),vaxis1,rescld)   ; create plot    
  overlay(plot2a,plot2e)

; qc
  resgc@xyLineColors  = colors1(0) 
  resgc@xyDashPattern = lsolid
  plot3e    = gsn_csm_xy (wks,fieldqcdowntmn(:),vaxis1,resgc)   ; create plot    
  overlay(plot3a,plot3e)

; qi
  resqi@xyLineColors  = colors1(0) 
  resqi@xyDashPattern = lsolid
  plot4e    = gsn_csm_xy (wks,fieldqidowntmn(:)*1000,vaxis1,resqi)   ; create plot    
  overlay(plot4a,plot4e)

;-------------------------------------------------------------------------
; and finally, draw all the data onto one final figure...
    labels = (/title1,title2,title3,title4,title5/)
    legend  = gsn_create_legend (wks, 5, labels, lgres)
    amres = True
    amres@amJust = "BottomRight"

    amres@amParallelPosF   = 0.42    ; Move legend to right
    amres@amOrthogonalPosF = 0.47     ; Move legend down

    annoid = gsn_add_annotation(plot4a,legend,amres) ; add legend to plot

    respanel = True
    respanel@txString = maintitle2

    gsn_panel(wks,plot,(/1,5/),respanel)

  ;  psres = True
  ;  maximize_output(wks,psres)   ; draw everything on the workstation  
end






