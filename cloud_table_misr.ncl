;================================================;
;cloud_table_misr.ncl 
;
; produces a table of values for cloud types ordered
; as cloud top height (km) vs. tau using output from
; the misr simulator
;
; levi silvers  		feb 2020
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;

;;----------------------------------------------------------------------
;; Procedure to attach a labelbar to the bottom of plot.
;;----------------------------------------------------------------------
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

;; open/reference desired file (use addfiles to reference multiple data file)
toptitle="MISR AM4"
xtitle="hieght (km)"
ytitle="optical depth"
;
;;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_misr/atmos_month_misr.0002-0011.alltmn_wavg.nc"

filein="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_197901-198412.nc"
;obs_filein="/Users/silvers/data/cfmip_clouds/clmisr_Emon_GFDL-CM4_amip_r1i1p1f1_gr1_197901-198412.nc"

obs_filein="/Users/silvers/data/SatData/MISR/clMISR/clMISR_obs4MIPS_20000601_20130531_tmn.nc"

infile = addfile(filein,"r")
obs_infile = addfile(obs_filein,"r")

  print("infile is: "+filein)
;  print("observations infile is: "+obs_filein)

tau=infile->tau(:)
  print("tau =: "+tau)
;
;;-Reading and processing of data-------------------------------------------
;

varnames="misr_"+ispan(1,16,1)
varname="clmisr"
ob_varname="clMISR"

fields=new((/7,16/),float)

fields_full=infile->$varname$(:,:,:,:,:)
obs_fields=obs_infile->$ob_varname$(:,:,:,90,90)

  print("overall max of fields is: "+max(fields_full))
  print("overall min of fields is: "+min(fields_full))

;;---------------------------------------------------------------------
; first we want to average over time and decide which geographic region to look at
; once the geographic region has been selected, compute the spatial average

fields_tmn=dim_avg_n(fields_full,0)
  print("dimsizes of fields_tmn are:"+dimsizes(fields_tmn))

fields_patch =new((/7,16,180,288/),float)
fields_point =new((/7,16/),float)
cf_array     =new((/16,7/),float)
ncr          =dimsizes(fields_point)
ncr_flip     =dimsizes(cf_array)

fields_patch=fields_tmn
fields_gmn_a=dim_avg_n(fields_tmn,2)
fields_gmn  =dim_avg_n(fields_gmn_a,2)
  ;print("dimsizes of gmn_a are: "+dimsizes(fields_gmn_a))
  ;print("dimsizes of gmn are: "+dimsizes(fields_gmn))
fields_point=fields_patch(:,:,90,144)

;fields=fields_point
fields=fields_gmn
  print("dimsizes of fields are:"+dimsizes(fields))
  ;print(fields(:,5))
  ;print(fields(:,10))

; reverse the vertical dimension so that the lowest layers are at the bottom of plot
;fields=fields(::-1,:)

printVarSummary(fields)

fields!0="tau"
cf_array!1="tau"
fields&tau=fields_full&tau
cf_array&tau=fields_full&tau
fields!1="alt16"
cf_array!0="alt16"
fields&alt16=fields_full&alt16
cf_array&alt16=fields_full&alt16

  print("--------- old fields --------")
  printVarSummary(fields)

cf_array=fields(alt16|:,tau|:)

  print("--------- cf array 1----------")
  printVarSummary(cf_array)
  print("--------- cf array 2----------")
cf_array=cf_array(::-1,:)
  printVarSummary(cf_array)
  print("-----------------------------")


;;;---------------------------------------------------------------------
;;; compute lat weights to determine the global mn
;lat  = infile->lat
;rad  = 4.0*atan(1.0)/180.0
;clat = cos(lat*rad)
;;
;field_weighted_ave     = wgt_areaave(fields_tmn,clat,1.0,1)
;;
;;; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
;;; available non-missing data. 
;;  print("global mean of "+varname4+" before interpolation is: "+field4_weighted_ave)
;;;---------------------------------------------------------------------


;fields=where(fields_gmn.le.0.001,0.0,fields_gmn)
cf_array=where(cf_array.le.0.001,0.0,cf_array)
cf_array=decimalPlaces(cf_array,1,True)
;print(fields)
text_values=""+cf_array
;
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
;fields_point=new((/7,16/),float)
;cols_for_vals = new((/ncr(0),ncr(1)/),"string")
;cols_for_txt = new((/ncr(0),ncr(1)/),"string")
cols_for_vals = new((/16,7/),"string")
cols_for_txt = new((/16,7/),"string")

contours=(/0.0,0.1,0.5,1.0,2.0,3.0,5.0,7.0,10,30/)

cols_for_vals = colors(3)
do i=2,10
  do k=0,6
  ;do k=0,15
    do j=0,15
    ;do j=0,6
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      ;if(rng_beg.le.fields(j,k) .and. fields(j,k).lt.rng_end) then 
      if(rng_beg.le.cf_array(j,k) .and. cf_array(j,k).lt.rng_end) then 
        cols_for_vals(j,k) = colors(i)
      else
        cols_for_vals = cols_for_vals
      end if  
    end do
  end do 
end do

;;---Create formatted labels for the labelbar
;;---Converts floats or doubles into formatted strings.
do i=2,10
  rng_beg = contours(i-2)
  rng_end = contours(i-1)
  labels(i-2) = sprintf("%3.1f", rng_beg) + " - " + \
                sprintf("%3.1f",rng_end)
end do

cols_for_txt = where(cols_for_vals.eq."Navy".or.cols_for_vals.eq."MediumBlue","white","black")

;  print(colos_for_vals)
;
;;;-----------------------------------------------------------------------------
;; Start the graphics.
;
;; why doesn't png work?
  wks = gsn_open_wks("newPDF","testplot")
  gsn_define_colormap(wks,colors)
;
;  ;
;; Create a blank plot so we can get some tickmarks.
;;
;; Do the blank plot before the table, so we can maximize
;; the blank plot. Later we'll make sure the table goes
;; in the same location as the blank plot.
;;
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

  gsn_table(wks,ncr_flip,x,y,text_values,rest)    ; Draw table

end
;





