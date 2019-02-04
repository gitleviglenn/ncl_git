;=======================================================================================;
;re_tau_modis.ncl 
;
; produces a table of values for cloud types ordered
; as reliq vs. tau using output from
; the modis simulator
;
; originally based on the old script ctp_tau_misr.ncl
;
; the output file may have extra dimensions which should be averaged over such as
; longitude, latitude, or time.  
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.clmisr.nc atmos_cosp_cfmip.187001-187012.clmisr.ncwa.nc
; cdo timmean atmos_cosp_cfmip.187001-187012.clmisr.ncwa.nc test3.nc
;
; levi silvers  		march 2018
;=======================================================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;=======================================================================================;

;----------------------------------------------------------------------
; Procedure to attach a labelbar to the bottom of plot.
;----------------------------------------------------------------------
undef("add_labelbar")
procedure add_labelbar(wks,plot,colors,labels)
local vph, vpw, nboxes, lbres, lbid, amres, annoid
begin
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.15 * vpw    ; labelbar width
  lbres@vpHeightF          = 0.95 * vph    ; labelbar height
  lbres@lbFillColors       = colors        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.05          ; font height. default is small
  lbres@lbLabelAlignment   = "BoxCenters"  ; center of box
  lbres@lbOrientation      = "Vertical"
  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "CenterLeft"
  amres@amParallelPosF   =  0.52
  amres@amOrthogonalPosF =  0.0
  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end


;----------------------------------------------------------------------
; main code
;----------------------------------------------------------------------
begin

; open/reference desired file (use addfiles to reference multiple data file)
modv="am4 "
toptitle="MODIS reice "+modv;+" 1 yrglmn"
ytitle="reff (microns)"
xtitle="optical depth"

varname="jpdftaureliqmodis"
;filein_new="/net2/Levi.Silvers/data/cfamip_testdiag/atmos_cosp_cfmip.187001-187012.jpdftaureliqmodis.ncwa.tmn.nc"
;filein_new="/archive/Levi.Silvers/data/cfmip_highfreq/atmos_cosp_cfmip.18700101-18701231.jpdftaureliqmodis.ncwa.tmn.nc"
filein_new="/archive/oar.gfdl.cmip6/CM4/warsaw_201803/CM4_amip/gfdl.ncrc4-intel16-prod-openmp/pp/atmos_cosp_cfmip/ts/monthly/6yr/atmos_cosp_cfmip.200901-201412.jpdftaureliqmodis.nc"

;varname="jpdftaureicemodis"
;;filein_new="/net2/Levi.Silvers/data/cfamip_testdiag/atmos_cosp_cfmip.187001-187012.jpdftaureicemodis.ncwa.tmn.nc"
;filein_new="/archive/Levi.Silvers/data/cfmip_highfreq/atmos_cosp_cfmip.18700101-18701231.jpdftaureicemodis.ncwa.tmn.nc"


 infile_new = addfile(filein_new,"r")
print("infile new is: "+filein_new)

;
;;-Reading and processing of data-------------------------------------------
;


fields_new=new((/6,7/),float)
fields_new=-999

do i=0,6,1
  do j=0,5,1
    fields_new(j,i)=infile_new->$varname$(0,i,j)
  end do
end do

print("number of missing values in fields_new: "+num(ismissing(fields_new)))

fields=100.*fields_new

print("fields_new at i=3: "+fields_new(:,3))
print("fields_new at j=3: "+fields_new(3,:))

; reverse the vertical dimension so that the lowest layers are at the bottom of plot
fields=fields(::-1,:)

print("dimensions of fields: "+dimsizes(fields))
ncr=dimsizes(fields)

print("ncr is: "+ncr)
print("overall max of fields is: "+max(fields))
print("overall min of fields is: "+min(fields))


fields=where(fields.le.0.001,0.0,fields)
fields=decimalPlaces(fields,1,True)
;text_values=""+fields

ncols=7
nrows=6
col_width  = 1./ncols
row_width  = 1./nrows
col_width2 = col_width/2.
row_width2 = row_width/2.

;
; Define colors to use for the table. Be sure to include white and black for background
; and foreground.
;
; using the colortable NCV_gebco looks promising...
;gsn_define_colormap(wks,"CBR_drywet")
; 
;colors = (/"White","Black","Navy","MediumBlue","MediumTurquoise","SeaGreen1",\
;           "Green","Yellow","Orange","Firebrick1","Red","Brown"/)
;colors = (/"White","Black","Navy","MediumBlue","MediumTurquoise","SeaGreen1",\
;           "Yellow","Orange","Firebrick1"/)
;colors = (/"White","Black","aliceblue","darkslategray1","darkslategray2","darkslategray3","darkslategray4","darkslategray","SeaGreen1"/)
;colors = (/2,2,17,14,12,10,8,6,4/) 
colors = (/"White","Black","white","floralwhite","lightcyan","darkslategray1","darkslategray2","darkslategray3","deepskyblue1","deepskyblue3","blue"/)

labels = new(dimsizes(colors)-1,string)    ; for labelbar

; Assign a color to a particular range of data.
cols_for_vals = new(ncr,"string")
cols_for_txt = new(ncr,"string")

; for liquid re
contours=(/0.0,0.1,0.5,1.0,2.0,3.0,4.0,5.0,7.0,10.0/)
; for ice re

cols_for_vals = colors(3)
do i=2,10
  do k=0,6
    do j=0,5
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      if(ismissing(fields(j,k))) then
        fields(j,k)=0.0
      end if
      if(rng_beg.le.fields(j,k) .and. fields(j,k).lt.rng_end) then 
        cols_for_vals(j,k) = colors(i)
      else
        cols_for_vals = cols_for_vals
      end if  
    end do
  end do 
end do

text_values=""+fields

;---Create formatted labels for the labelbar
;---Converts floats or doubles into formatted strings.
do i=2,10
  rng_beg = contours(i-2)
  rng_end = contours(i-1)
  labels(i-2) = sprintf("%3.1f", rng_beg) + " - " + \
                sprintf("%3.1f",rng_end)
end do

cols_for_txt = where(cols_for_vals.eq."Navy".or.cols_for_vals.eq."MediumBlue","white","black")

;  print(colos_for_vals)

;;-----------------------------------------------------------------------------
; Start the graphics.

; why doesn't png work?
  wks = gsn_open_wks("newPDF","testplot")
  gsn_define_colormap(wks,colors)

  ;
; Create a blank plot so we can get some tickmarks.
;
; Do the blank plot before the table, so we can maximize
; the blank plot. Later we'll make sure the table goes
; in the same location as the blank plot.
;
  resb                         = True
  resb@gsnDraw                 = False
  resb@gsnFrame                = False

  resb@vpYF                    = 0.9
  resb@vpXF                    = 0.15
  resb@vpHeightF               = 0.8
  resb@vpWidthF                = 0.7

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = fspan(0.,1.-col_width,ncols)
  print("what are these values? "+fspan(col_width2,1.-col_width2,ncols))
  ncol_labels=(/0.0,0.3,1.3,3.6,9.4,23,60./)
; for liq re
;  nrow_labels=(/8.0,10.0,13.0,15.0,20.0,30.0/)
; for ice re
  nrow_labels=(/10.0,20.0,30.0,40.0,60.0,90.0/)
  resb@tmXBLabels              = ncol_labels
  resb@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb@tmYLMode                = "Explicit"
  resb@tmYLValues              = fspan(0.+row_width,1.,nrows)
  resb@tmYLLabels              = nrow_labels
;
; The Y labels need to be reversed, because the label in the first
; row in the ASCII file is associated with the top of the plot.
;
  ;resb@tmYLLabels              = nrow_labels(::-1)
  resb@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Rotate the X axis labels 90 degrees.
  ;resb@tmXBLabelAngleF         = 90.
  resb@tmXBLabelJust           = "CenterRight"

; Turn off right and top tickmarks
  resb@tmYROn                  = False
  resb@tmXTOn                  = False

; Main title
  ;resb@tiMainString            = file_base
  resb@tiMainString            = toptitle
  resb@tiXAxisString    = xtitle
  resb@tiYAxisString    = ytitle

  blank = gsn_csm_blank_plot(wks,resb)
  add_labelbar(wks,blank,colors(2:),labels)   ; Attach labelbar
  draw(blank)                                 ; Draw tickmarks and labelbar
;
; Get position and size of the blank plot so we can
; be sure to draw the table in same location.
;
  getvalues blank
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

; Start and end coordinates for table.
  x = (/vpx,vpx+vpw/)
  y = (/vpy-vph,vpy/)


; Set up resources for table
  rest               = True

  rest@tiXAxisString    = xtitle
  rest@tiYAxisString    = ytitle
  rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals     ; Each cell of table
  rest@txFontColor   = cols_for_txt

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values,rest)    ; Draw table

end
;





