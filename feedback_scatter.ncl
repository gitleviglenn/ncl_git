;----------------------------------------------------------------------
; simple script to make a scatter plot of a few points
; levi silvers
;
; usage: /Users/silvers/bin/nclsh feedback_scatter.ncl -feedback
;
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;----------------------------------------------------------------------
; Data is hard-coded here. 
;----------------------------------------------------------------------
  climsens = (/2.0,1.6,1.7,3.3,2.3/)
  ecs_up = (/2.5,1.8,2.0,59.5,2.6/)
  ecs_dn = (/1.7,1.4,1.5,1.7,2.1/)
  feedbck = (/-1.9,-2.4,-2.2,-1.1,-1.6,-1.225686/)
  feedup = (/-2.3,-2.7,-2.4,-1.3,-1.7/)
  feeddn = (/-1.5,-2.1,-1.9,-0.9,-1.4/)
  cmip5feedbck = (/-0.8622759,-1.313801,-1.225686,-0.9342824,-1.024827,-1.113774,-0.7696735,-0.6336084,-0.832868,-0.9000754,-0.7695135,-1.454132,-1.405773,-1.521645,-0.8085405,-0.8222315,-1.008389,-0.9106839,-1.596132,-1.012313,-1.205067,-1.24026,-1.322653,-1.23226,-1.59119,-1.651219,-1.530647,-1.738301,-1.670806,-1.577141,-1.27037,-1.139287/)
print(cmip5feedbck)
;min_lam = -1.30808 max_lam = -0.943192
  domsize = (/1.0,2.0,3.0,4.0,5.0,5.5/)

  dataarr = new(dimsizes(climsens)+1,float)
  dataup = new(dimsizes(climsens),float)
  datadn = new(dimsizes(climsens),float)

  error_bar = new(dimsizes(climsens),graphic)
  centers = new(dimsizes(climsens),graphic)
  centers1 = new(dimsizes(cmip5feedbck),graphic)

if(isvar("feedback")) then
  dataarr = feedbck
  cmipdataarr = cmip5feedbck
  dataup  = feedup
  datadn  = feeddn
else
  dataarr = climsens
  dataup  = ecs_up
  datadn  = ecs_dn
end if

;----------------------------------------------------------------------
; Set some plot resources
;----------------------------------------------------------------------
  wks = gsn_open_wks ("eps","testplot")

;----------------------------------------------------------------------
; define colors or colortable to use
;  gsn_define_colormap(wks,colors)
;    colors = (/"white","Black","SteelBlue","GoldenRod","OrangeRed","LawnGreen","DarkTurquoise","Blue","Red"/)
;  mycolors = (/"LawnGreen","SteelBlue","GoldenRod","Black","OrangeRed"/)
  gsn_define_colormap(wks,"CBR_drywet")
  colors = (/8,9,10,11,12,5/)                                                          
;----------------------------------------------------------------------
  res                    = True

  res@gsnDraw            = False       ; Don't draw plot
  res@gsnFrame           = False       ; Don't advance frame

;---XY marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarkerSizeF      = 0.02
 ; res@xyMarkerSizeF      = (/0.02,0.02,0.02,0.02,0.02,0.01/)
  res@xyMarkerThicknessF = 3.
  res@xyMonoMarkerColor  = False          ; Allow different colors for markers
  res@xyMarkerColors     = (/colors(0),colors(1),colors(2),colors(3),colors(4),colors(5)/)     ; It's okay to list more than
                                          ; you need here
  res@xyMarkers          = (/16,16,16,16,16,1/)
;---Resources for X/Y axes.
  res@trXMinF            =  0.                  ; min value on x-axis
  res@trXMaxF            =  6.                  ; max value on x-axis
;---Title resources
  res@tiMainString       = " "
  res@tiXAxisString      = "Domain"
if(isvar("feedback")) then
  res@trYMinF            =  -3.5                  ; min value on y-axis
  res@trYMaxF            =  0.0                  ; max value on y-axis
  ;res@trYReverse         = True
  res@tiYAxisString      = "Feedback Parameter"
else
  res@trYMinF            =  0.0                  ; min value on y-axis
  res@trYMaxF            =  4.0                  ; max value on y-axis
  res@tiYAxisString      = "ECS"
end if
  res@tiMainFontHeightF  = 0.03
;---Deal with labels on x axis
  res@tmXUseBottom       = "True"
  res@tmXBMode           = "Explicit"
  res@tmXBValues         = (/0.,1.,2.,3.,4.,5.,6./)
  res@tmXBLabels           = (/" ","3/4M","3M","12M","50M","200M"," "/)

plot = gsn_csm_xy (wks,transpose((/domsize,domsize/)), \
                         transpose((/dataarr,dataarr/)),res)

;************************************************
; add error bars
;************************************************  
  polyres                   = True                       ; marker resources
  polyres@gsMarkerIndex     = 1                          ; index for circle
  polyres@gsMarkerSizeF     = .02                        ; size 
  polyres@gsLineThicknessF  = 5
  endpoint=dimsizes(climsens)
  do t=0,dimsizes(climsens)-1
    polyres@gsMarkerColor = colors(t)
    polyres@gsLineColor = colors(t)
    centers(t)   = gsn_add_polymarker(wks,plot,domsize(t),dataarr(t),polyres)
    error_bar(t) = gsn_add_polyline(wks,plot,(/domsize(t),domsize(t)/),\
    (/dataup(t),datadn(t)/),polyres)
  end do
  polyres@gsMarkerIndex     = 16                          ; index for circle
  polyres@gsMarkerColor = colors(5)
  polyres@gsMarkerSizeF     = .01                        ; size 
  ;centers1(endpoint)   = gsn_add_polymarker(wks,plot,domsize(endpoint),cmipdataarr(10),polyres)
  do tt=0,dimsizes(cmipdataarr)-1
    centers1(tt)   = gsn_add_polymarker(wks,plot,domsize(endpoint),cmipdataarr(tt),polyres)
  end do
draw(plot)
end
