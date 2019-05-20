;=======================================================================================;
;height_sr_calipso.ncl 
;
; produces a table of values for cloud fraction from the calipso simulator ordered
; as height (km) vs. lidar scattering ratio 
;
; originally based on the old script cloud_table_misr.ncl
;
; the output file for 1 yr was so large (1.4GB) that ncwa did not seem able to average it.  so 
; i broke into into monthly chunks, spatiall averaged them, recombined them with cdo cat , and then 
; computed the yearly time mean.  
;
; ncks -d time,0 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t0.nc
; ncks -d time,1 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t1.nc
; ncks -d time,2 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t2.nc
; ncks -d time,3 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t3.nc
; ncks -d time,4 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t4.nc
; ncks -d time,5 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t5.nc
; ncks -d time,6 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t6.nc
; ncks -d time,7 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t7.nc
; ncks -d time,8 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t8.nc
; ncks -d time,9 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t9.nc
; ncks -d time,10 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t10.nc
; ncks -d time,11 atmos_cosp_cfmip.187001-187012.cfadLidarsr532.nc -O atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t11.nc
;
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t0.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t0.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t1.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t1.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t2.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t2.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t3.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t3.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t4.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t4.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t5.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t5.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t6.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t6.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t7.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t7.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t8.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t8.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t9.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t9.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t10.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t10.nc
; ncwa -O -a lat,lon atmos_cosp_cfmip.187001-187012.cfadLidarsr532.t11.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t11.nc
;
; cdo cat atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t0.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t1.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t2.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t3.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t4.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t5.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t6.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t7.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t8.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t9.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t10.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.t11.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.1yr.nc
;
; cdo timmean atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.1yr.nc atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.1yrmn.nc
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
modv="am4"
toptitle="CALIPSO "+modv+" 1yr glmn"
;ytitle="height (km)"
ytitle="alt40 levs"
xtitle="Lidar Scattering Ratio"

;filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"

filein="/net2/Levi.Silvers/data/cfamip_testdiag/test3.nc"
filein_new="/net2/Levi.Silvers/data/cfamip_testdiag/atmos_cosp_cfmip.187001-187012.cfadLidarsr532.ncwa.1yrmn.nc"

infile = addfile(filein,"r")
infile_new = addfile(filein_new,"r")

  print("infile is: "+filein)
  print("infile new is: "+filein_new)

;
;;-Reading and processing of data-------------------------------------------
;

varname_misr="clmisr"
varname_calipso="cfadLidarsr532"

fields_cali=new((/15,40/),float)
fields_cali=infile_new->$varname_calipso$(0,:,:)
print("dimensions of cfadLidarsr532 are: "+dimsizes(fields_cali))

;fields_new=new((/16,7/),float)
;fields_new=-999
;
;do i=0,6,1
;  do j=0,15,1
;    fields_new(j,i)=infile->$varname_misr$(0,i,j)
;  end do
;end do

fields=transpose(fields_cali)
fields=100.*fields

;print("fields_new at i=3: "+fields_new(:,3))

;; reverse the vertical dimension so that the lowest layers are at the bottom of plot
fields=fields(::-1,:)

print("dimensions of fields: "+dimsizes(fields))
ncr=dimsizes(fields)

print("ncr is: "+ncr)
print("overall max of fields is: "+max(fields))
print("overall min of fields is: "+min(fields))


fields=where(fields.le.0.0001,0.0,fields)
fields=decimalPlaces(fields,1,True)
text_values=""+fields

ncols=15
nrows=40
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

contours=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09/)
contours=(/0.0,0.1,0.2,0.4,0.6,0.8,1.0,3.0,6.0,9.0/)

cols_for_vals = colors(1)
do i=2,10
  do k=0,39
    do j=0,14
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      if(rng_beg.le.fields(k,j) .and. fields(k,j).lt.rng_end) then 
        cols_for_vals(k,j) = colors(i)
      else
        cols_for_vals = cols_for_vals
      end if  
    end do
  end do 
end do

;print("fields at 1,: are:"+fields(1,1)+" fields at :,5 are: "+fields(:,5))

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

  resb@vpYF                    = 0.90
  resb@vpXF                    = 0.15
  resb@vpHeightF               = 0.8
  resb@vpWidthF                = 0.7

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = fspan(col_width2,1.-col_width2,ncols)
  print("what are these values? "+fspan(col_width2,1.-col_width2,ncols))
  ncol_labels=(/0.01,1.2,3,5,7,10,15,20,30,40,50,60,80/)
  ;nrow_labels=(/0.0,0.5,1.0,1.5,2.0,2.5,3.0,4.0,5.0,7.0,9.0,11.0,13.0,15.0,17.0/)
  nrow_labels=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40/)
  resb@tmXBLabels              = ncol_labels
  resb@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb@tmYLMode                = "Explicit"
  resb@tmYLValues              = fspan(row_width,1.-row_width,nrows-1)
  resb@tmYLLabels              = nrow_labels
;
; The Y labels need to be reversed, because the label in the first
; row in the ASCII file is associated with the top of the plot.
;
  ;resb@tmYLLabels              = nrow_labels(::-1)
  resb@tmYLLabelFontHeightF    = 0.010            ; Make tck mark font smaller

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
  resb@txFontHeightF = 0.010             ; Size of centered text

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

  ;rest@tiXAxisString    = xtitle
  ;rest@tiYAxisString    = ytitle
  rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals     ; Each cell of table
  rest@txFontColor   = cols_for_txt

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values,rest)    ; Draw table

end
;





