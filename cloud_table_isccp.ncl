;================================================;
;cloud_table_isccp.ncl 
;
; produces two tables of values for cloud types ordered
; as tau vs. cloud top height
;
; also produces two txt files with the values which
; populate the tables
;
; upper table is isccp simulator data
; lower table is isccp observational data (1983-2008)
;
; processes both observational or model output
;
; levi silvers  		may 2018
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


  toptitle="COSPISCCP cfrac fraction"
;
 ;model="sim c96L33_am4p0"
 model="simulator"
 obsper=" 1983-2008"
 obsper_mod=" 2003-2010"

;
 titlebase="AM4.0 ISCCP "+model
 title_obs=" ISCCP OBS"+obsper
;
; specify paths
;filein="/archive/oar.gfdl.cmip6/h1g/warsaw_201710_mom6_om4_v1.0/CM4_piControl_test_OM4_1p0/gfdl.ncrc4-intel16-prod-openmp/pp/atmos_cmip/av/annual_1yr/"+"atmos_cmip.0001.ann.nc"

; new files for isccp tests are here: 
; /archive/Levi.Silvers/CM4/warsaw_201803/CM4_amip_isccptest/gfdl.ncrc4-intel-prod/pp/atmos_cmip/ts/monthly/5yr/

filein="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP/gfdl.ncrc3-intel-prod-openmp/pp/atmos_cmip/av/annual_5yr/atmos_cmip.1990-1994.ann.nc"
;filein="/Users/silvers/data/am4p0/atmos_cmip.clisccp.1980-2014.cdotmn.nc" ; path on macbook

filein_obs="/net2/Levi.Silvers/data/isccpdata/clisccp_198307-200806.nc"       ; path on workstation
;filein_obs="/Users/silvers/data/SatData/ISCCP/clisccp_198307-200806_latlon.nc" ; path on macbook
;
  infile = addfile(filein,"r")
  infile_obs = addfile(filein_obs,"r")
print("infile is: "+filein)
print("infile for isccp observations is: "+filein_obs) ; (time, tau, plev7, lat, lon)
;
;;;-read data----------------------------------------------------------------
;;
  ftime=0
  flat=45 ; 90
  flon=0
  fields=new((/7,7/),float)
  fields_mod=new((/7,7/),float)
  field_obs=new((/7,7/),float)
  varnames="clisccp_"+ispan(1,7,1)
  varname="clisccp"
  varname_modobs="Optical_Thickness_vs_Cloud_Top_Pressure"
;;  varnamemn="cltisccp" ; ISCCP total cloud fraction
;print("test of isccp tau1: "+fieldobs_temp0a)
;print("test of isccp tau2: "+fieldobs_temp0b)
;print("test of isccp tau3: "+fieldobs_temp0c)
;print("test of isccp plev7: "+fieldobs_temp1)
;
;  field1=infile->$varnamemn$(ftime,:,:)          
;print("dimensions of "+varnamemn+" are "+dimsizes(field1))
;print("max of infile is: "+max(field1))
;print("min of infile is: "+min(field1))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
  lat  = infile->lat
  lato  = infile_obs->latitude
  lon  = infile->lon
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  clato = cos(lato*rad)
;

field_temp=infile_obs->$varname$(:,:,:,:,:)
print("dimensions of fieldobs_temp: "+dimsizes(field_temp))
  do j=0,6,1 ; this should be the tau dimension
    tempvar=varnames(j)
    tempvars=tempvar+"_"+ispan(1,7,1)
    ;tempvar_m=varnames_mod(j)
    ;tempvars_m=tempvar_m+"_"+ispan(1,7,1)
    do i=0,6,1 ; this should be the plev7 dimenion
      pisso=tempvars(i)
      ;pisso_m=tempvars_m(i)
      ;
      fields_temp=infile->$pisso$(ftime,:,:)
      fields(i,j)   = wgt_areaave(fields_temp,clat,1.0,0)
      ;fields(i,j)   = wgt_areaave(fields_temp,1.0,1.0,0)
      ;
      ; if j/tua is gt zero
      if (i .le. 5) then
        fieldobs_full=infile_obs->$varname$(:,i,j,:,:)
        fieldobs_temp=dim_avg_n(fieldobs_full,0)
        fieldobs_temp@_FillValue=1.e+20
        field_obs(j,i+1)   = wgt_areaave(fieldobs_temp,clato,1.0,0)
      end if
    end do
        field_obs(j,0) = 0.0
  end do
;;
;;
;; deterine which field will be tabulated and output...
fields=fields(::-1,:) ; for am4 data

fields_obs=field_obs ; for isccp sat observations

  print("dimensions of fields: "+dimsizes(fields))
tot_cldfrac_isccp=sum(fields)
tot_cldfrac_isccp_obs=sum(fields_obs)
  print("total cloud fraction from isccp simulator : "+tot_cldfrac_isccp)
  print("total cloud fraction from isccp obs : "+tot_cldfrac_isccp_obs)
;
  
  fields=where(fields.le.0.001,0.0,fields)
  fields=decimalPlaces(fields,1,True)
  text_values=""+fields
  
  fields_obs=where(fields_obs.le.0.001,0.0,fields_obs)
  fields_obs=decimalPlaces(fields_obs,1,True)
  text_values_obs=""+fields_obs
;
;;
;; Define colors to use for the table. Be sure to include white and black for background
;; and foreground.
;;
;; using the colortable NCV_gebco looks promising...
;;gsn_define_colormap(wks,"CBR_drywet")
;; 
;;colors = (/"White","Black","Navy","MediumBlue","MediumTurquoise","SeaGreen1",\
;;           "Green","Yellow","Orange","Firebrick1","Red","Brown"/)
;;colors = (/"White","Black","Navy","MediumBlue","MediumTurquoise","SeaGreen1",\
;;           "Yellow","Orange","Firebrick1"/)
;;colors = (/"White","Black","aliceblue","darkslategray1","darkslategray2","darkslategray3","darkslategray4","darkslategray","SeaGreen1"/)
;;colors = (/2,2,17,14,12,10,8,6,4/) 
;colors = (/2,2,17,14,12,10,8,6,4/) 
colors = (/"White","Black","white","floralwhite","lightcyan","darkslategray1","darkslategray2","darkslategray3","deepskyblue1","deepskyblue3","blue"/)
;
labels = new(dimsizes(colors)-1,string)    ; for labelbar
;
;contours=(/0.0,0.1,0.5,1.0,2.0,3.0,5.0,7.0,10,30/)
contours=(/0.0,0.1,1.0,2.0,3.0,4.0,5.0,6.0,7.0,10/)

;-----------------------------------------------------------------------------------------
; begin tables....
ncr=dimsizes(fields)
;
print("ncr is: "+ncr)
;
  ncols=7
  nrows=7
  col_width  = 1./ncols
  row_width  = 1./nrows
  col_width2 = col_width/2.
  row_width2 = row_width/2.
;
;; Assign a color to a particular range of data.
cols_for_vals = new(ncr,"string")
cols_for_txt = new(ncr,"string")
cols_for_vals_obs = new(ncr,"string")
cols_for_txt_obs = new(ncr,"string")
;cols_for_vals_mod = new(ncr,"string")
;cols_for_txt_mod = new(ncr,"string")
;cols_for_vals_modobs = new(ncr,"string")
;cols_for_txt_modobs = new(ncr,"string")
;
; for isccp 
cols_for_vals = colors(3)
do i=2,10
  do k=0,6
    do j=0,6
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      ; for model simulator
      if(rng_beg.le.fields(j,k) .and. fields(j,k).lt.rng_end) then 
        cols_for_vals(j,k) = colors(i)
      else
        cols_for_vals = cols_for_vals
      end if  
      ; for isccp obs
      if(rng_beg.le.fields_obs(j,k) .and. fields_obs(j,k).lt.rng_end) then 
        cols_for_vals_obs(j,k) = colors(i)
      else
        cols_for_vals_obs = cols_for_vals_obs
      end if  
    end do
  end do 
end do
;
;;---Create formatted labels for the labelbar
;;---Converts floats or doubles into formatted strings.
do i=2,10
  rng_beg = contours(i-2)
  rng_end = contours(i-1)
  labels(i-2) = sprintf("%3.1f", rng_beg) + " - " + \
                sprintf("%3.1f",rng_end)
end do
;
cols_for_txt = where(cols_for_vals.eq."Navy".or.cols_for_vals.eq."MediumBlue","white","black")
cols_for_txt_obs = where(cols_for_vals_obs.eq."Navy".or.cols_for_vals_obs.eq."MediumBlue","white","black")
;cols_for_txt_mod = where(cols_for_vals_mod.eq."Navy".or.cols_for_vals_mod.eq."MediumBlue","white","black")
;cols_for_txt_modobs = where(cols_for_vals_modobs.eq."Navy".or.cols_for_vals_modobs.eq."MediumBlue","white","black")
;
;;-----------------------------------------------------------------------------
; Start the graphics.

  wks = gsn_open_wks("newPDF","testplot")
  ;wks = gsn_open_wks("eps","testplot")
  gsn_define_colormap(wks,colors)
  ;gsn_define_colormap(wks,MPL_Blues)

; 
; first table *******************************************************************
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

;  resb@vpYF                    = 0.48  ; specifies the location of top edge of view object
;  resb@vpXF                    = 0.15  ; specifies the location of the left edge of view object
;  resb@vpHeightF               = 0.3 ; 0.45 ; 0.85
;  resb@vpWidthF                = 0.3 ; 0.35 ; 0.75

  resb@vpYF                    = 0.92
  resb@vpXF                    = 0.15
  resb@vpHeightF               = 0.3 ; 0.45 ; 0.85
  resb@vpWidthF                = 0.3 ;0.35 ; 0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = fspan(0.,1.-col_width,ncols)
  ncol_labels=(/0.0,0.3,1.3,3.6,9.4,23.0,60.0/)
  nrow_labels=(/1000,800,680,560,440,310,180/)
  resb@tmXBLabels              = ncol_labels
  resb@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb@tmYLMode                = "Explicit"
  resb@tmYLValues              = fspan(0.,1.-row_width,nrows)
  resb@tmYLLabels              = nrow_labels
;
; The Y labels need to be reversed, because the label in the first
; row in the ASCII file is associated with the top of the plot.
;
  ;resb@tmYLLabels              = nrow_labels(::-1)
  resb@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Rotate the X axis labels 90 degrees.
  ;resb@tmXBLabelAngleF         = 90.
;  resb@tmXBLabelJust           = "CenterRight"

; Turn off right and top tickmarks
  resb@tmYROn                  = False
  resb@tmXTOn                  = False

; Main title
  totaltitle = titlebase
  resb@tiMainString            = totaltitle
  ;resb@tiXAxisString    = "Optical depth"
  resb@tiYAxisString    = "Cloud top pressure (hPa)"

  blank = gsn_csm_blank_plot(wks,resb)
;  add_labelbar(wks,blank,colors(2:),labels)   ; Attach labelbar
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

  ;rest@tiXAxisString    = "tau tau tau"
  ;rest@tiYAxisString    = ytitle
  ;rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals     ; Each cell of table
  rest@txFontColor   = cols_for_txt

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values,rest)    ; Draw table

; 
; third table *******************************************************************
;
  resb3                         = True
  resb3@gsnDraw                 = False
  resb3@gsnFrame                = False

  resb3@vpYF                    = 0.48  ; specifies the location of top edge of view object
  resb3@vpXF                    = 0.15  ; specifies the location of the left edge of view object
  resb3@vpHeightF               = 0.3 ; 0.45 ; 0.85
  resb3@vpWidthF                = 0.3 ; 0.35 ; 0.75

;  resb3@vpYF                    = 0.92
;  resb3@vpXF                    = 0.15
;  resb3@vpHeightF               = 0.3 ; 0.45 ; 0.85
;  resb3@vpWidthF                = 0.3 ;0.35 ; 0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb3@tmXBMode                = "Explicit"
  resb3@tmXBValues              = fspan(0.,1.-col_width,ncols)
  ncol_labels=(/0.0,0.3,1.3,3.6,9.4,23.0,60.0/)
  nrow_labels=(/1000,800,680,560,440,310,180/)
  resb3@tmXBLabels              = ncol_labels
  resb3@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
;  resb3@tiXAxisString    = "tau "
  resb3@tmYLMode                = "Explicit"
  resb3@tmYLValues              = fspan(0.,1.-row_width,nrows)
  resb3@tmYLLabels              = nrow_labels
;
  resb3@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Rotate the X axis labels 90 degrees.
  ;resb3@tmXBLabelAngleF         = 90.
;  resb3@tmXBLabelJust           = "CenterRight"

; Turn off right and top tickmarks
  resb3@tmYROn                  = False
  resb3@tmXTOn                  = False

; Main title
  totaltitle = title_obs
  resb3@tiXAxisString    = "Optical depth"
  resb3@tiYAxisString    = "Cloud top pressure (hPa)"
  resb3@tiMainString            = totaltitle

  blank = gsn_csm_blank_plot(wks,resb3)
;  add_labelbar(wks,blank,colors(2:),labels)   ; Attach labelbar
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
  ;rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals_obs     ; Each cell of table
  rest@txFontColor   = cols_for_txt_obs

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values_obs,rest)    ; Draw table
 
; 
;;

;--------------------------------------------------------
; write out ASCII files
  option        = True
  option@row    = False
  option@tspace = 0

  option@fout   = "ISCCPObs.txt"
  option@title  = title_obs
  write_matrix (fields_obs, "7f7.2", option)

  option@fout   = "AM4IsccpObs.txt"
  option@title  = titlebase
  write_matrix (fields, "7f7.2", option)

end
;





