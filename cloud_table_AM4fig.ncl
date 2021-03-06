;================================================;
;cloud_table_isccp.ncl 
;
; produces a table of values for cloud types ordered
; as tau vs. cloud top height
;
; this is the script that was used to produce the figure
; 10 in Zhao et al. 2018, Part 1
;
; levi silvers  		feb 2018
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
 titlebase_mod="AM4.0 MODIS "+model
 title_mod_obs=" MODIS OBS"+obsper_mod
;
; specify paths

; from model output
;filein="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP/gfdl.ncrc3-intel-prod-openmp/pp/atmos_cmip/av/annual_5yr/atmos_cmip.clisccp.1980-2014.tmn.nc" ; path on archive
filein="/Users/silvers/data/am4p0/atmos_cmip.clisccp.1980-2014.cdotmn.nc" ; path on macbook

;filein_mod="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP_bugfix2/gfdl.ncrc3-intel-prod-openmp-modisbugfix/pp/atmos_cmip_modis/av/annual_5yr/atmos_cmip_modis.1980-2014.ann.glbtmn.nc" ; path on archive
filein_mod="/Users/silvers/data/am4p0/atmos_cmip_modis.1980-2014.ann.glbtmn.nc" ; path on macbook
;filein_mod="/Users/silvers/data/am4p0/atmos_cmip_modis.1980th2014.ann.bug.glbtmn.nc" ; path on macbook

; from observations
;filein_obs="/net2/Levi.Silvers/data/isccpdata/clisccp_198307-200806_latlon.nc"       ; path on workstation
filein_obs="/Users/silvers/data/SatData/ISCCP/clisccp_198307-200806_latlon.nc" ; path on macbook

;filein_modobs="/net2/Levi.Silvers/data/modisdata/MCD08_M3_NC.2003th2010.total.C051.V02.gmn_ymn.nc" ; path on workstation
filein_modobs="/Users/silvers/data/SatData/MODIS/MCD08_M3_NC.2003th2010.total.C051.V02.gmn_ymn.nc" ; path on macbook
;
  infile = addfile(filein,"r")
  infile_mod = addfile(filein_mod,"r")
  infile_obs = addfile(filein_obs,"r")
  infile_modobs = addfile(filein_modobs,"r")
print("infile is: "+filein)
print("infile for modis is: "+filein_mod)
print("infile for isccp observations is: "+filein_obs) ; (time, tau, plev7, lat, lon)
print("infile for modis observations is: "+filein_modobs) ; (time, tau, plev7)
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
  varnames_mod="tauctpmodis_"+ispan(1,7,1)
  varname_mod="tauctpmodis"
  varname_modobs="Optical_Thickness_vs_Cloud_Top_Pressure"
;;  varnamemn="cltisccp" ; ISCCP total cloud fraction
;     fieldobs_temp0a=infile_obs->$varname$(ftime,:,0,36,72)
;     fieldobs_temp0b=infile_obs->$varname$(ftime,:,3,36,72)
;     fieldobs_temp0c=infile_obs->$varname$(ftime,:,5,36,72)
;     fieldobs_temp1=infile_obs->$varname$(ftime,3,:,36,72)
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
  lato  = infile_obs->lat
  lon  = infile->lon
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  clato = cos(lato*rad)
;  field1_test = where(field1.gt.0., field1,default_fillvalue("float"))
;  field1_weighted_ave     = wgt_areaave(field1,clat,1.0,1)
;
; read in modis observations
field_modobs=infile_modobs->$varname_modobs$(0,:,:)

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
      ;fields_mod(i,j)=infile_mod->$pisso_m$(ftime,:,:)
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
;
; read in data from modis simulator
;
fields_mod=0.0
  do j=1,6,1 ; this should be the tau dimension
    tempvar_m=varnames_mod(j)
    tempvars_m=tempvar_m+"_"+ispan(1,7,1)
    do i=0,6,1 ; this should be the plev7 dimenion
      pisso_m=tempvars_m(i)
;print("pisso_m is: "+pisso_m)
      fields_mod(i,j)=infile_mod->$pisso_m$(ftime,:,:)
    end do
  end do
;print("who? "+fields_mod)
;
; deterine which field will be tabulated and output...
fields=fields(::-1,:) ; for am4 data
fields_mod=fields_mod(::-1,:) ; for am4 data
fields_modobs=100.*field_modobs
fields_obs=field_obs ; for isccp sat observations

  print("dimensions of fields_modobs: "+dimsizes(fields_modobs))
  print("select values from fields_modobs: "+fields_modobs(3,4))
  print("dimensions of fields_mod: "+dimsizes(fields_mod))
  print("dimensions of fields: "+dimsizes(fields))
tot_cldfrac_isccp=sum(fields)
tot_cldfrac_isccp_obs=sum(fields_obs)
tot_cldfrac_mod_sim=sum(fields_mod)
tot_cldfrac_mod_obs=sum(fields_modobs)
  print("total cloud fraction from isccp simulator : "+tot_cldfrac_isccp)
  print("total cloud fraction from isccp obs : "+tot_cldfrac_isccp_obs)
  print("total cloud fraction from modis simulator : "+tot_cldfrac_mod_sim)
  print("total cloud fraction from modis obs : "+tot_cldfrac_mod_obs)
;
  fields_mod=where(fields_mod.le.0.001,0.0,fields_mod)
  fields_mod=decimalPlaces(fields_mod,1,True)
  text_values_mod=""+fields_mod
  
  fields_modobs=where(fields_modobs.le.0.001,0.0,fields_modobs)
  fields_modobs=decimalPlaces(fields_modobs,1,True)
  text_values_modobs=""+fields_modobs
  
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
cols_for_vals_mod = new(ncr,"string")
cols_for_txt_mod = new(ncr,"string")
cols_for_vals_modobs = new(ncr,"string")
cols_for_txt_modobs = new(ncr,"string")
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
      ; for modis sim data
      if(rng_beg.le.fields_mod(j,k) .and. fields_mod(j,k).lt.rng_end) then 
        cols_for_vals_mod(j,k) = colors(i)
      else
        cols_for_vals_mod = cols_for_vals_mod
      end if  
      ; for modis obs data
      if(rng_beg.le.fields_modobs(j,k) .and. fields_modobs(j,k).lt.rng_end) then 
        cols_for_vals_modobs(j,k) = colors(i)
      else
        cols_for_vals_modobs = cols_for_vals_modobs
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
cols_for_txt_mod = where(cols_for_vals_mod.eq."Navy".or.cols_for_vals_mod.eq."MediumBlue","white","black")
cols_for_txt_modobs = where(cols_for_vals_modobs.eq."Navy".or.cols_for_vals_modobs.eq."MediumBlue","white","black")
;
;;-----------------------------------------------------------------------------
; Start the graphics.

  ;wks = gsn_open_wks("newPDF","testplot")
  wks = gsn_open_wks("eps","testplot")
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
  ;rest@gsFillColor   = cols_for_vals_mod     ; Each cell of table
  ;rest@txFontColor   = cols_for_txt_mod

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values_obs,rest)    ; Draw table
 
; 
; fourth table *******************************************************************
;
  resb4                         = True
  resb4@gsnDraw                 = False
  resb4@gsnFrame                = False

  resb4@vpYF                    = 0.48  ; specifies the location of top edge of view object
  resb4@vpXF                    = 0.55  ; specifies the location of the left edge of view object
  resb4@vpHeightF               = 0.3 ; 0.45 ; 0.85
  resb4@vpWidthF                = 0.3 ; 0.35 ; 0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb4@tmXBMode                = "Explicit"
  resb4@tmXBValues              = fspan(0.,1.-col_width,ncols)
  ncol_labels=(/0.0,0.3,1.3,3.6,9.4,23.0,60.0/)
  nrow_labels=(/1000,800,680,560,440,310,180/)
  resb4@tmXBLabels              = ncol_labels
  resb4@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb4@tmYLMode                = "Explicit"
  resb4@tmYLValues              = fspan(0.,1.-row_width,nrows)
  resb4@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Turn off right and top tickmarks
  resb4@tmYROn                  = False
  resb4@tmXTOn                  = False

; Main title
  title_mod_obs=" MODIS OBS"+obsper_mod
  ;totaltitle4 = title_mod_obs
  resb4@tiXAxisString    = "Optical depth"
  ;resb4@tiMainString            = totaltitle4

  ;totaltitle = titlebase_mod
  resb4@tiMainString            =title_mod_obs

  blank = gsn_csm_blank_plot(wks,resb4)
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
  ;rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals_modobs     ; Each cell of table
  rest@txFontColor   = cols_for_txt_modobs

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values_modobs,rest)    ; Draw table

; 
; second table *******************************************************************
;
  resb2                         = True
  resb2@gsnDraw                 = False
  resb2@gsnFrame                = False

  resb2@vpYF                    = 0.92  ; specifies the location of top edge of view object
  resb2@vpXF                    = 0.55  ; specifies the location of the left edge of view object
  resb2@vpHeightF               = 0.3 ; 0.45 ; 0.85
  resb2@vpWidthF                = 0.3 ; 0.35 ; 0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb2@tmXBMode                = "Explicit"
  resb2@tmXBValues              = fspan(0.,1.-col_width,ncols)
  ncol_labels=(/0.0,0.3,1.3,3.6,9.4,23.0,60.0/)
  nrow_labels=(/1000,800,680,560,440,310,180/)
  resb2@tmXBLabels              = ncol_labels
  resb2@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb2@tmYLMode                = "Explicit"
  resb2@tmYLValues              = fspan(0.,1.-row_width,nrows)
  resb2@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Turn off right and top tickmarks
  resb2@tmYROn                  = False
  resb2@tmXTOn                  = False

; Main title
  totaltitle = titlebase_mod
  resb2@tiMainString            = totaltitle

  blank = gsn_csm_blank_plot(wks,resb2)
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
  ;rest@gsLineColor   = -1                ; No border lines
  ;rest@gsFillColor   = cols_for_vals_obs     ; Each cell of table
  ;rest@txFontColor   = cols_for_txt_obs
  rest@gsFillColor   = cols_for_vals_mod     ; Each cell of table
  rest@txFontColor   = cols_for_txt_mod

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values_mod,rest)    ; Draw table

;--------------------------------------------------------
; write out ASCII files
  option        = True
  option@row    = False
  option@tspace = 0

  option@fout   = "am4ModisSim.txt"
  option@title  = titlebase_mod
  write_matrix (fields_mod, "7f7.2", option)

  option@fout   = "ModisObs.txt"
  option@title  = title_mod_obs
  write_matrix (fields_modobs, "7f7.2", option)

  option@fout   = "ISCCPObs.txt"
  option@title  = title_obs
  write_matrix (fields_obs, "7f7.2", option)

  option@fout   = "AM4IsccpObs.txt"
  option@title  = titlebase
  write_matrix (fields, "7f7.2", option)

  blah=fields_modobs-fields_mod
  option@fout   = "AM4diff.txt"
  option@title  = "MOD obs minus MOD sim"
  write_matrix (blah, "7f7.2", option)

end
;





