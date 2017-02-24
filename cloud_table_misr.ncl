;================================================;
;cloud_table.ncl 
;
; produces a table of values for cloud types ordered
; as tau vs. cloud top height
;
; levi silvers  		feb 2017
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;

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
;file_name="atmos_month_misr5yr_march_fldmn.nc"
modv="am4g12r18"
toptitle="MISR "+modv+" 10 yrglmn"
xtitle="hieght (km)"
ytitle="optical depth"
file_name="atmos_month_misr_"+modv+"_5yrjan_fldmean.nc"
;expname="c96L32_"+modv+"_2000climo_cosp/"
expname="c96L32_am4g9_2000climo_cosp_isccp/"
;archdir="/archive/Levi.Silvers/awg/ulm_201505/"
archdir="/archive/Levi.Silvers/awg/ulm_201505/"
;exptree="gfdl.ncrc2-intel-prod-openmp/pp/atmos_month_misr/av/monthly_5yr/"
exptree="gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_misr/av/monthly_10yr/"
;filein="/archive/Levi.Silvers/awg/ulm_201505/c96L32_am4g6_2000climo_cosp/gfdl.ncrc2-intel-prod-openmp/pp/atmos_month_misr/av/monthly_5yr/atmos_month_"+file_base+".nc"
filein=archdir+expname+exptree+file_name
;filein="/Users/silvers/data/gfdlcosp/atmos_month_"+file_base+".nc"

filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"
;filein="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"
;filein="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"

 infile = addfile(filein,"r")

print("infile is: "+filein)

tau=infile->tauindx(:)
print("tau =: "+tau)
;
;;-Reading and processing of data-------------------------------------------
;
;;-read data----------------------------------------------------------------
;
;field_misr1=infile->misr_1
;print("----------------info for misr1---------------")
;print(field_misr1)

varnames="misr_"+ispan(1,16,1)

fields=new((/16,7/),float)

do i=0,15,1
  ;fields(i,:)=infile->$varnames(i)$(0,:,0,0)
  fields(i,:)=infile->$varnames(i)$(0,:)
end do

; reverse the vertical dimension so that the lowest layers are at the bottom of plot
fields=fields(::-1,:)

;print("what kind of var is fields?"+fields)
;print(fields)
print("dimensions of fields: "+dimsizes(fields))
ncr=dimsizes(fields)

print("ncr is: "+ncr)
print("overall max of fields is: "+max(fields))
print("overall min of fields is: "+min(fields))


fields=where(fields.le.0.001,0.0,fields)
fields=decimalPlaces(fields,1,True)
;print(fields)
text_values=""+fields

ncols=7
nrows=16
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

contours=(/0.0,0.1,0.5,1.0,2.0,3.0,5.0,7.0,10,30/)

cols_for_vals = colors(3)
do i=2,10
  do k=0,6
    do j=0,15
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      if(rng_beg.le.fields(j,k) .and. fields(j,k).lt.rng_end) then 
        cols_for_vals(j,k) = colors(i)
      else
        cols_for_vals = cols_for_vals
      end if  
    end do
  end do 
end do

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

  resb@vpYF                    = 0.92
  resb@vpXF                    = 0.10
  resb@vpHeightF               = 0.85
  resb@vpWidthF                = 0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = fspan(col_width2,1.-col_width2,ncols)
  print("what are these values? "+fspan(col_width2,1.-col_width2,ncols))
  ncol_labels=(/0.15,0.80,2.45,6.50,16.2,41.5,100./)
  nrow_labels=(/0.0,0.5,1.0,1.5,2.0,2.5,3.0,4.0,5.0,7.0,9.0,11.0,13.0,15.0,17.0/)
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





