;***********************************************************************************
; glb_cf_isccp_3d.ncl
;***********************************************************************************
;
; plot global cloud fraction as computed with the iscpp cosp tool.
;
; example here is for clouds below 3km with tau .gt. 0.3
; for reference see Fig 9 of Marchand et al. 2010 JGR
;
; plot clisccp globally through a given height and for a given range of tau
;
; clisccp is effectively a 5 dimensional variable saved to file as
; clisccp_#_#(time, lat, lon) with physical hieght and cloud optical depth being represented 
;   by the _#_# part of the file name.  
; clisccp_1_1:long_name = "ISCCP CldFrac - tau between  0.0 and      0.3 , pr between  1000 and  800 hPa"
;
; note:
; cltisccp(time, lat, lon) = "Total Cloud Fraction as Calculated by the ISCCP Simulator"
; clisccp_1_1(time,lat,lon)="ISCCP CldFrac-tau between 0.0 and 0.3, pr between 1000 and 800hPa" 
;
; the pressure levels for isccp are: 
; 1000,800,680,560,440,310,180,0 hPa
;
; the tau levels for isccp are (different than for misr): 
; 0.0,0.3,1.3,3.6,9.4,23.0,60.0,100000.0
;
; the tau levels in misr are:
; 0.15,0.8,2.45,6.5,16.2,41.5,100.
;
; model data will need to be pp'ed with the script misr_pp_yrlowcl.s
;
; levi silvers							oct 2016
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************************************************
begin
;***********************************************************************************
; read in netCDF file
;***********************************************************************************
;dirin="/work/Levi.Silvers/moddata/misr_pp_am4g10r8_taugt0p3/"
dirin="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_onlyisccp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_2yr/"
;dirin="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_isccp3/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_5yr/"
filein=dirin+"atmos_month_cospx.all.nc"
;infile=dirin+"atmos_month_cospx.0002-0006.alltmn.tot_cld_amt.nc"
  infile = addfile(filein,"r")
print("infile is: "+filein)
;;
  ftime=0
  flat=70
  flon=70
  fields=new((/7,7/),float)
  fields_glb=new((/7,7,180,288/),float)
  varnames="clisccp_"+ispan(1,7,1)
  varnamemn="cltisccp" ; ISCCP total cloud fraction
;
print("infile is: "+filein)
  field1=infile->$varnamemn$(ftime,:,:)          
print("infile is: "+filein)
print("dimensions of "+varnamemn+" are "+dimsizes(field1))
print("max of infile is: "+max(field1))
print("min of infile is: "+min(field1))
  do i=0,6,1
    tempvar=varnames(i)
    tempvars=tempvar+"_"+ispan(1,7,1)
    do j=0,6,1
    ;print("piss off: "+tempvar)
      pisso=tempvars(j)
    ;  print("single piss off: "+pisso)
    ;  print("piss offs: "+tempvars)
      fields(j,i)=infile->$pisso$(ftime,flat,flon)
      do jlat=0,179,1
        do ilon=0,279,1
          fields_glb(j,i,jlat,ilon)=infile->$pisso$(ftime,jlat,ilon)
          ;fields_glb(j,i,:,:)=infile->$pisso$(ftime,:,:)
        end do
      end do
    end do
  end do
;
; read the lat and lon dimensions
printVarSummary(fields_glb)
latit=infile->lat
latit@units="degrees_north"
latit!0="lat"
latit@long_name="latitude"
latit@standard_name="longitude"
latit@axis="X"
;
longi=infile->lon
longi@units="degrees_east"
longi!0="lon"
longi@long_name="longitude"
longi@standard_name="longitude"
longi@axis="Y"
;try to add the lat and lon info
fields_glb!0="lat"
;fields_glb&lat=latit
fields_glb!1="lon"
;lat@units="degrees_north"
;lon@units="degrees_east"
;fields_glb@lon=longi
;
longsum=dim_sum_n(fields_glb,3)
latsum=dim_sum_n(longsum,2)
print("dimensions of latsum are: "+dimsizes(latsum))
tausum=dim_sum_n(latsum,1)
totalsum=sum(tausum)
print("totalsum="+totalsum)
totalsum2=sum(fields_glb)
print("totalsum2="+totalsum2)

sumovertau=dim_sum_n(fields_glb,1)
print("dimensions of sumovertau are: "+dimsizes(sumovertau))
sumoverpressl=dim_sum_n(sumovertau,0)
print("dimensions of sumoverpressl are: "+dimsizes(sumoverpressl))



; fields(tau levels, pressure levels)
print("dimensions of fields: "+dimsizes(fields))
print("overall max of fields is: "+max(fields))
print("overall min of fields is: "+min(fields))

print("all tau values for pressure layer 0: "+fields(0,0)+" "+fields(0,1)+" "+fields(0,2)+" "+fields(0,3)+" "+fields(0,4)+" "+fields(0,5)+" "+fields(0,6))
print("all tau values for pressure layer 1: "+fields(1,0)+" "+fields(1,1)+" "+fields(1,2)+" "+fields(1,3)+" "+fields(1,4)+" "+fields(1,5)+" "+fields(1,6))
print("all tau values for pressure layer 2: "+fields(2,0)+" "+fields(2,1)+" "+fields(2,2)+" "+fields(2,3)+" "+fields(2,4)+" "+fields(2,5)+" "+fields(2,6))
print("all tau values for pressure layer 3: "+fields(3,0)+" "+fields(3,1)+" "+fields(3,2)+" "+fields(3,3)+" "+fields(3,4)+" "+fields(3,5)+" "+fields(3,6))
print("all tau values for pressure layer 4: "+fields(4,0)+" "+fields(4,1)+" "+fields(4,2)+" "+fields(4,3)+" "+fields(4,4)+" "+fields(4,5)+" "+fields(4,6))
print("all tau values for pressure layer 5: "+fields(5,0)+" "+fields(5,1)+" "+fields(5,2)+" "+fields(5,3)+" "+fields(5,4)+" "+fields(5,5)+" "+fields(5,6))
print("all tau values for pressure layer 6: "+fields(6,0)+" "+fields(6,1)+" "+fields(6,2)+" "+fields(6,3)+" "+fields(6,4)+" "+fields(6,5)+" "+fields(6,6))

;***********************************************************************************
; create plot
;***********************************************************************************
; create colors to use in contours
; contour levels
my_levels1 = (/0,10,15,20,30,35,40,45,50,55,60,65,70,75,80/)
my_colors = (/25,28,35,41,46,53,59,65,69,75,79,85,91,95,97,101/)

  ;wks = gsn_open_wks("ps","proj")          ; send graphics to ps file
  wks = gsn_open_wks("png","testplot")          ; send graphics to PNG file
  gsn_define_colormap(wks,"WhBlGrYeRe")


  res                   = True
;  res@mpProjection      = "Mollweide"       ; choose projection
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

  ;res@tiMainString       = maintitle  ; add a title
  res@tiMainString       = "are you working"; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,sumoverpressl,res)  ; create the plot
end

