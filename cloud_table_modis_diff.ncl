;================================================;
;cloud_table_modis.ncl 
;
; produces a table of values from the modis simulator
; for cloud types ordered
; as tau vs. cloud top height
;
; the intention is to compare with something like what is
; shown in Pincus et al. 2012
;
; levi silvers  		jan 2017
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
;----------------------------------------------------------------------
;----------------------------------------------------------------------
; code for the modis simulator data
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

;; open/reference desired file (use addfiles to reference multiple data file)
;xtitle="pressure(hPa)"
;ytitle="optical depth"
; below for am4g10r8
;
;filein="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_bigout/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_modis/av/monthly_2yr/atmos_month_modis.0002-0003.alltmn.nc"
;filein2="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_bigout/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_modis/av/monthly_2yr/atmos_month_modis.0002-0003.alltmn_ncwa.nc"
;; below for am4g11r11
;  toptitle="COSPMODIS cfrac am4g11r11 5yrgmn"
;  filein="/archive/Levi.Silvers/awg/verona/c96L32_am4g11r11_2010climo_cosp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_modis/av/monthly_5yr/atmos_month_modis.0007-0011.alltmn.nc"
;  filein2="/archive/Levi.Silvers/awg/verona/c96L32_am4g11r11_2010climo_cosp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_modis/av/monthly_5yr/atmos_month_modis.0007-0011.alltmn_ncwa.nc"
;
;
; titlebase="COSPMODIS cfrac am4g12r18 10yrm"
;
; regions: .nc _perustr.nc, _npac.nc, _wp.nc
;
;region="_gmn"
;regi="gl"
;region="_perustr_mn"
; regi="peru st"
;region="_npac_mn"
; regi="npac"
;region="_wpmn"
; regi="wm pl"
region="_trop_mn"
 regi="trops"
;
;
 model="c96L32_am4G12r18_2010climo_A_cosp"
 mode="r18"
; model="c96L32_am4G12r17_2010climo_A_cosp"
; mode="r17"
;model="c96L32_am4G12r16_2010climo_new_cosp"
; mode="r16"
outputfile="modis2010_obsminus"+mode+" "+regi
;
 titlebase="obs - simulator "+mode+" "+regi
;
; am4G12r18
;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn_gmn.nc"
;filein_glb="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn_wpmn.nc"
;region="npac_mn.nc"
;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn_npac_mn.nc"
;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn_perustr_mn.nc"
;; am4G12r17
;;filein="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn_gmn.nc"
;;filein_glb="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;
; specify paths
filein="/archive/Levi.Silvers/data/"+model+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn"+region+".nc"
filein_glb="/archive/Levi.Silvers/data/"+model+"/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;
;
;
  infile = addfile(filein,"r")
  infile_glb = addfile(filein_glb,"r")
;
  print("infile is: "+filein)
  print("infile_glb is: "+filein_glb)
;
;;;-read data----------------------------------------------------------------
;;
  ftime=0
  flat=0
  flon=0
  fields=new((/7,7/),float)
  fields=0.0
  varnames="tauctpmodis_"+ispan(1,7,1)
  varnamemn="tclmodis" ; MODIS total cloud fraction
;
  field1=infile_glb->$varnamemn$(ftime,:,:)          
print("dimensions of "+varnamemn+" are "+dimsizes(field1))
print("max of infile is: "+max(field1))
print("min of infile is: "+min(field1))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
  lat  = infile_glb->lat
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  field1_test = where(field1.gt.0., field1,default_fillvalue("float"))
  field1_weighted_ave     = wgt_areaave(field1,clat,1.0,1)
  field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
  field1_nonweighted_ave= wgt_areaave(field1,1.0,1.0,1)
print("raw w global mean of "+varnamemn+" at time "+ftime+" is: "+field1_weighted_ave)
print("raw uw global mean of "+varnamemn+" at time "+ftime+" is: "+field1_nonweighted_ave)
print("global mean of non missing data "+varnamemn+" at time "+ftime+" is: "+field1_weighted_ave_test)
;
;tauctpmodis
;print("infile is: "+filein)
print("dimensions of fields are: "+dimsizes(fields))
  do j=1,6,1
    tempvar=varnames(j)
    tempvars=tempvar+"_"+ispan(0,7,1)
    ;print("tempvar for j: "+varnames(j))
    do i=0,6,1
      pisso=tempvars(i+1)
      ;print("single piss off: "+pisso+" varname at i="+i+" j="+j)
      ;print(fields(i,j)+" at i="+i+" j="+j) 
      ;print("piss offs: "+tempvars
      ;fields(i,j)=infile2->$pisso$(ftime,flat,flon) ; for single point
      fields(i,j)=infile->$pisso$(ftime); for global mean
      ;print(fields(i,j)+" at i="+i+" j="+j)
    end do
;    print("fields for i= "+i+" "+fields(i,6))
  end do
;
print("single piss off: "+pisso)
; some schenanigans were necessary to get the plot to line up correctly with the 
; pressure and tau levels
;
fields=fields(::-1,:)
print("dimensions of fields: "+dimsizes(fields))
  fields=where(fields.le.0.001,0.0,fields)
  fields=decimalPlaces(fields,1,True)
;  row_width2 = row_width/2.
;;
;;;
;;
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
; code for the modis observational data
;----------------------------------------------------------------------
; titlebase="Modis Observations 2010"
;
; specify paths
; specify region of interest
region="tropmn"
filein_obs1="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.01.C051.V02."+region+".nc"
filein_obs2="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.02.C051.V02."+region+".nc"
filein_obs3="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.03.C051.V02."+region+".nc"
filein_obs4="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.04.C051.V02."+region+".nc"
filein_obs5="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.05.C051.V02."+region+".nc"
filein_obs6="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.06.C051.V02."+region+".nc"
filein_obs7="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.07.C051.V02."+region+".nc"
filein_obs8="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.08.C051.V02."+region+".nc"
filein_obs9="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.09.C051.V02."+region+".nc"
filein_obs10="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.10.C051.V02."+region+".nc"
filein_obs11="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.11.C051.V02."+region+".nc"
filein_obs12="/net2/Levi.Silvers/data/modisdata/MYD08_M3_NC.2010.12.C051.V02."+region+".nc"
;
;
  infile_obs1 = addfile(filein_obs1,"r")
  infile_obs2 = addfile(filein_obs2,"r")
  infile_obs3 = addfile(filein_obs3,"r")
  infile_obs4 = addfile(filein_obs4,"r")
  infile_obs5 = addfile(filein_obs5,"r")
  infile_obs6 = addfile(filein_obs6,"r")
  infile_obs7 = addfile(filein_obs7,"r")
  infile_obs8 = addfile(filein_obs8,"r")
  infile_obs9 = addfile(filein_obs9,"r")
  infile_obs10 = addfile(filein_obs10,"r")
  infile_obs11 = addfile(filein_obs11,"r")
  infile_obs12 = addfile(filein_obs12,"r")
;
  print("infile_obs1 is: "+filein_obs1)
  print("infile_obs11 is: "+filein_obs11)
;
;;;-read data----------------------------------------------------------------
;;
  field_obs=new((/7,7/),float)
  field_obs=0.0
  jan=new((/7,7/),float)
  jan=0.0
  feb=new((/7,7/),float)
  feb=0.0
  mar=new((/7,7/),float)
  mar=0.0
  apr=new((/7,7/),float)
  apr=0.0
  may=new((/7,7/),float)
  may=0.0
  jun=new((/7,7/),float)
  jun=0.0
  jul=new((/7,7/),float)
  jul=0.0
  aug=new((/7,7/),float)
  aug=0.0
  sep=new((/7,7/),float)
  sep=0.0
  oct=new((/7,7/),float)
  oct=0.0
  nov=new((/7,7/),float)
  nov=0.0
  dec=new((/7,7/),float)
  dec=0.0
  
  varname="Optical_Thickness_vs_Cloud_Top_Pressure"
;(lat, lon, Cloud_Top_Pressure, Cloud_Optical_Thickness)
  varnames="tauctpmodis_"+ispan(1,7,1)
  varnamemn="tclmodis" ; MODIS total cloud fraction
;
;---------------------------------------------------------------------
;
print("dimensions of fieldobss are: "+dimsizes(field_obs))
  do j=1,6,1
    do i=0,6,1
      jan(i,j)=100.*infile_obs1->$varname$(i,j) ; for single point
      feb(i,j)=100.*infile_obs2->$varname$(i,j) ; for single point
      mar(i,j)=100.*infile_obs3->$varname$(i,j) ; for single point
      apr(i,j)=100.*infile_obs4->$varname$(i,j) ; for single point
      may(i,j)=100.*infile_obs5->$varname$(i,j) ; for single point
      jun(i,j)=100.*infile_obs6->$varname$(i,j) ; for single point
      jul(i,j)=100.*infile_obs7->$varname$(i,j) ; for single point
      aug(i,j)=100.*infile_obs8->$varname$(i,j) ; for single point
      sep(i,j)=100.*infile_obs9->$varname$(i,j) ; for single point
      oct(i,j)=100.*infile_obs10->$varname$(i,j) ; for single point
      nov(i,j)=100.*infile_obs11->$varname$(i,j) ; for single point
      dec(i,j)=100.*infile_obs12->$varname$(i,j) ; for single point
      ;field_obs(i,j)=100.*infile_obs1->$varname$(i,j) ; for single point
      field_obs(i,j)=(jan(i,j)+feb(i,j)+mar(i,j)+\
                  apr(i,j)+may(i,j)+jun(i,j)+\
                  jul(i,j)+aug(i,j)+sep(i,j)+\
                  oct(i,j)+nov(i,j)+dec(i,j))/12
      ;print(field_obs(i,j)+" at i="+i+" j="+j)
    end do
  end do
;
print("dimensions of field_obs: "+dimsizes(field_obs))
  ncr=dimsizes(field_obs)
;
print("ncr is: "+ncr)
print("overall max of field_obs is: "+max(field_obs))
print("overall min of field_obs is: "+min(field_obs))
;
xtitle="total clfract: "
;
  field_obs=where(field_obs.le.0.001,0.0,field_obs)
  field_obs=decimalPlaces(field_obs,1,True)
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------

field_moonhooch=field_obs-fields
;field_moonhooch=fields-field_obs
field_moonhooch=decimalPlaces(field_moonhooch,1,True)
tot_diff=sum(field_moonhooch)
sumdiff=decimalPlaces(tot_diff,2,True)

print("dimensions of moonhooch are: "+dimsizes(field_moonhooch))
print("fields at point: "+fields(4,4))
print("field_obs at point: "+field_obs(4,4))
print("field_moonhooch at point: "+field_moonhooch(4,4))

; processing before the actual figure 
;;-----------------------------------------------------------------------------
;;-----------------------------------------------------------------------------
;;-----------------------------------------------------------------------------
  text_values=""+field_moonhooch

  ncols=7
  nrows=7
  col_width  = 1./ncols
  row_width  = 1./nrows
  col_width2 = col_width/2.
  row_width2 = row_width/2.

colors = (/"White","Black","Coral","Moccasin","LightYellow","LightCyan","PowderBlue","LightSkyBlue","CornflowerBlue","RoyalBlue","SteelBlue"/)  ; 11
labels = new(dimsizes(colors)-1,string)    ; for labelbar
cols_for_vals = new(ncr,"string")
cols_for_txt = new(ncr,"string")
contours=(/-1.0,-0.5,-0.1,0.0,0.1,0.5,1.0,2.0,3.0,5.0/)  ; 10
;
cols_for_vals = colors(3)
do i=2,10
  do k=0,6
    do j=0,6
      rng_beg = contours(i-2)
      rng_end = contours(i-1)
      if(rng_beg.le.field_moonhooch(j,k) .and. field_moonhooch(j,k).lt.rng_end) then 
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
;
cols_for_txt = where(cols_for_vals.eq."Navy".or.cols_for_vals.eq."MediumBlue","white","black")
;
;;  print(colos_for_vals)
;;-----------------------------------------------------------------------------
; Start the graphics.

; why doesn't png work?
;  wks = gsn_open_wks("ps","testplot")
  wks = gsn_open_wks("newPDF",outputfile)
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
  totaltitle = titlebase+" sum:"+sumdiff
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

  rest@tiXAxisString    = xtitle
  ;rest@tiYAxisString    = ytitle
  rest@gsLineColor   = -1                ; No border lines
  rest@gsFillColor   = cols_for_vals     ; Each cell of table
  rest@txFontColor   = cols_for_txt

  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,text_values,rest)    ; Draw table

end
;





