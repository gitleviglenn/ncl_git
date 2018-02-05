;================================================;
;cloud_table_isccp.ncl 
;
; produces a table of values for cloud types ordered
; as tau vs. cloud top height
;
; can process either observational or model output
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

; attempts at pp with cdo to grab data from a particular region for Septempber, October, and November 
; cdo copy atmos_month_cospx.0002-0011.09.nc atmos_month_cospx.0002-0011.10.nc atmos_month_cospx.0002-0011.11.nc atmos_month_cospx.0002-0011.SON.nc
; cdo timmean atmos_month_cospx.0002-0011.SON.nc atmos_month_cospx.0002-0011.SON_tmn.nc
; cdo -selname,clisccp_2_2 atmos_month_cospx.0002-0011.SON.nc atmos_month_cospx.0002-0011.SON_selname.nc
; cdo sellonlatbox,160,-125,50,60 atmos_month_cospx.0002-0011.SON_selname.nc atmos_month_cospx.0002-0011.SON_selname_box.nc
; cdo fldmean atmos_month_cospx.0002-0011.SON_selname_box.nc atmos_month_cospx.0002-0011.SON_selname_box_fmn.nc
;
; but the main problem is that i had to grab just clisccp_2_2.  this needs to be eliminated or automated becauese I need 49 vars

;;; open/reference desired file (use addfiles to reference multiple data file)
  toptitle="COSPISCCP cfrac fraction"
;
;region="_gmn"
;regi="gl"
;
; model="c96L32_am4G12r18_2010climo_A_cosp"
; model="CM4_piControl_test_OM4_1p0"
 model="c96L33_am4p0"

;
 titlebase=" ISCCP "+model
;
; specify paths
;filein="/archive/oar.gfdl.cmip6/h1g/warsaw_201710_mom6_om4_v1.0/CM4_piControl_test_OM4_1p0/gfdl.ncrc4-intel16-prod-openmp/pp/atmos_cmip/av/annual_1yr/"+"atmos_cmip.0001.ann.nc"

;filein="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP/gfdl.ncrc3-intel-prod-openmp/pp/atmos_cmip/av/annual_5yr/atmos_cmip.1990-1994.ann.nc"
filein="/Users/silvers/data/am4p0/atmos_cmip.clisccp.1980-2014.cdotmn.nc" ; path on macbook

;filein_obs="/net2/Levi.Silvers/data/isccpdata/clisccp_198307-200806.nc"
filein_obs="/Users/silvers/data/SatData/ISCCP/clisccp_198307-200806_latlon.nc" ; path on macbook
;
  infile = addfile(filein,"r")
  infile_obs = addfile(filein_obs,"r")
print("infile is: "+filein)
print("infile for observations is: "+filein_obs) ; (time, tau, plev7, lat, lon)
;
;;;-read data----------------------------------------------------------------
;;
  ftime=0
  flat=45
  flon=0
  fields=new((/7,7/),float)
  field_obs=new((/7,7/),float)
  varnames="clisccp_"+ispan(1,7,1)
  varname="clisccp"
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
field_temp=infile_obs->$varname$(:,:,:,:,:)
print("dimensions of fieldobs_temp: "+dimsizes(field_temp))
  do j=0,6,1 ; this should be the tau dimension
    tempvar=varnames(j)
    tempvars=tempvar+"_"+ispan(1,7,1)
    do i=0,6,1 ; this should be the plev7 dimenion
      pisso=tempvars(i)
      ;print("single piss off: "+pisso+" varname at i="+i+" j="+j)
      ;print("piss offs: "+tempvars)
      ;
      ;fields(i,j)=infile->$pisso$(ftime,flat,flon)
      fields_temp=infile->$pisso$(ftime,:,:)
      fields(i,j)   = wgt_areaave(fields_temp,clat,1.0,0)
      ;
      ;print(fields(i,j)+" at i="+i+" j="+j)
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
;
;print("field_obs at 0:"+field_obs(0,:)+" 1:"+field_obs(1,:)+" 2:"+field_obs(2,:)+" 3:"+field_obs(3,:)+" 4:"+field_obs(4,:)+" 5:"+field_obs(5,:)+" 6:"+field_obs(6,:))
;
print("single piss off: "+pisso)
; some schenanigans were necessary to get the plot to line up correctly with the 
; pressure and tau levels
;
;
; deterine which field will be tabulated and output...
;fields=fields(::-1,:) ; for am4 data
fields=field_obs ; for isccp sat observations

  print("dimensions of fields: "+dimsizes(fields))
ncr=dimsizes(fields)
;
print("ncr is: "+ncr)
print("overall max of fields is: "+max(fields))
print("overall min of fields is: "+min(fields))
;
tot_cldfrac_isccp=sum(fields)
print("total cloud fraction from clisccp_tau_p : "+tot_cldfrac_isccp)
;
  fields=where(fields.le.0.001,0.0,fields)
  fields=decimalPlaces(fields,1,True)
  text_values=""+fields
;
  ncols=7
  nrows=7
  col_width  = 1./ncols
  row_width  = 1./nrows
  col_width2 = col_width/2.
  row_width2 = row_width/2.
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
colors = (/"White","Black","white","floralwhite","lightcyan","darkslategray1","darkslategray2","darkslategray3","deepskyblue1","deepskyblue3","blue"/)
;
labels = new(dimsizes(colors)-1,string)    ; for labelbar
;
;; Assign a color to a particular range of data.
cols_for_vals = new(ncr,"string")
cols_for_txt = new(ncr,"string")
;
contours=(/0.0,0.1,0.5,1.0,2.0,3.0,5.0,7.0,10,30/)
;
cols_for_vals = colors(3)
do i=2,10
  do k=0,6
    do j=0,6
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
;
;;  print(colos_for_vals)
;
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
  ;resb@tmXBValues              = fspan(col_width2,1.-col_width2,ncols)
  resb@tmXBValues              = fspan(0.,1.-col_width,ncols)
;  print("what are these values? "+fspan(col_width2,1.-col_width2,ncols))
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
  ;resb@tiMainString            = file_base
  totaltitle = titlebase
  resb@tiMainString            = totaltitle

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





