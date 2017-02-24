;***********************************************************************************
; glb_cf_isccp_full.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the modis cosp tool.
;
; example here is for clouds below 3km with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; note:
; cltisccp(time, lat, lon) = "Total Cloud Fraction as Calculated by the ISCCP Simulator"
; clisccp_1_1(time,lat,lon)="ISCCP CldFrac-tau between 0.0 and 0.3, pr between 1000 and 800hPa" 
;
; should the tclmodis and modis_#_# variables match exactly?  how well should they match
; with the tot_cld_amt variable?
; 
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							nov 2016
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; read in netCDF file
;***********************************************************************************
; variable to read: 
;varname1="tclmodis" ; MODIS total cloud fraction
varname1="tot_cld_amt" 
;
;***********************************************************************************
;infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/monthly_2yr/atmos.0002-0003.timmean.nc"
;infile="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_cfmon/gfdl.ncrc3-intel-prod-openmp/pp/atmos/av/monthly_2yr/atmos.0002-0003.01.nc"

;infile="/archive/Levi.Silvers/data/c96L32_am4G12r16_2010climo_new_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
;infile="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_modis/atmos_month_modis.0002-0011.alltmn.nc"
infile_cosp="/archive/Levi.Silvers/data/c96L32_am4G12r18_2010climo_A_cosp/atmos_month_cospx/atmos_month_cospx.0002-0011.alltmn.nc"
infile="/archive/Levi.Silvers/data/c96L32_am4G12r17_2010climo_A_cosp/atmos/atmos.0002-0011.all.nc"

modelv="am4g12r18"

;---------------------------------------------------------------------
; reading the cloud fraction from isccp is not so trivial....
  cospdata = addfile(infile_cosp,"r")
  ftime=0
  flat=0
  flon=0
  fields=new((/7,7/),float)
  varnames="clisccp_"+ispan(1,7,1)
  tmpfield_tot=new((/1,180,288/),float)
  tmpfield=new((/1,180,288/),float)
  tmpfield_tot=0.0
  do j=0,6,1
    tempvar=varnames(j)
    tempvars=tempvar+"_"+ispan(1,7,1)
    do i=0,6,1
      pisso=tempvars(i)
      ;print("single piss off: "+pisso+" varname at i="+i+" j="+j)
      ;print("piss offs: "+tempvars)
      fields(i,j)=cospdata->$pisso$(ftime,flat,flon)
      tmpfield=cospdata->$pisso$(ftime,:,:)
      ;print(fields(i,j)+" at i="+i+" j="+j)
      ;print("tmpfield "+tmpfield(ftime,90,90)+" at i="+i+" j="+j)
      tmpfield_tot=tmpfield_tot+tmpfield
      ;print("tmpfield_tot "+tmpfield_tot(ftime,90,90)+" at i="+i+" j="+j)
    end do
;    print("fields for i= "+i+" "+fields(i,6))
  end do
print("single piss off: "+pisso)

  data = addfile(infile,"r")
print("infile is: "+infile)
  ;t = a->tot_cld_amt(0,:,:)                                
  var2plot = data->$varname1$(0,:,:)    
  print("dims of var2plot: "+dimsizes(var2plot))                            
  print("dims of tmpfield_tot: "+dimsizes(tmpfield_tot))                            
  ;print("tmpfield_tot at a point: "+tmpfield_tot(:,90))                            
  tot_cld_sum=sum(var2plot)
  t2=where(var2plot.ge.100.,0.0,var2plot)
  tot_cld_sum2=sum(t2)
  mean_cld=tot_cld_sum2/51840.
  print("sum of tot_cld_amt: "+tot_cld_sum)
  print("sum2 of tot_cld_amt: "+tot_cld_sum2)
  print("mean of tot_cld_amt: "+mean_cld)

; assign grid information to isccp derived data
  tmpfield_tot!1="lat"
  tmpfield_tot&lat=var2plot&lat
  tmpfield_tot!2="lon"
  tmpfield_tot&lon=var2plot&lon
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = data->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
field1_weighted_ave     = wgt_areaave(var2plot,clat,1.0,1)
field2_weighted_ave     = wgt_areaave(tmpfield_tot,clat,1.0,1)
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
print("raw global mean of "+varname1+" is: "+field1_weighted_ave)
print("raw global mean of cosp simulated isccp is: "+field2_weighted_ave)
;
posh=flt2string(decimalPlaces(field1_weighted_ave,2,True))
posh2=flt2string(decimalPlaces(field2_weighted_ave,2,True))
;maintitle=modelv+" "+" 10yrm "+varname1+" = "+posh
maintitle=modelv+" cosp isccp "+" 10yrm = "+posh2
;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/25,30,35,40,45,50,55,60,65,70,75,80,85,90,95/) ; 15
my_colors = (/12,18,22,26,30,34,37,40,43,46,49,52,55,58,61,64/) ; 16

  wks = gsn_open_wks("newPDF","testplot")          ; send graphics to ps file
  gsn_define_colormap(wks,"matlab_jet")


  res                   = True
  res@mpProjection      = "Robinson"       ; choose projection
;  res@mpProjection      = "Mollweide"       ; choose projection
  res@cnLinesOn         = False
  res@mpCenterLonF      = 180.
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
 
; these commands turn off/on the varname and units at top of image
 res@gsnLeftString = ""
 res@gsnRightString = ""

  res@cnFillOn          = True              ; color plot desired
;  res@cnFillPalette     = "gui_default"     ; set color map: ncl 6.1
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels          = my_levels1
  res@cnFillColors      = my_colors
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = maintitle  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

;  contour = gsn_csm_contour_map(wks,var2plot,res)  ; create the plot
  contour = gsn_csm_contour_map(wks,tmpfield_tot(0,:,:),res)  ; create the plot
end

