;-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_1SST_pdf.ncl
;
; originally run by omega_testbins.sh
; 
; - open file
; - read vertical velocity variable
; - rescale to hPa/day
; - interpolate to standard lat lon grid
; - parse the ascending cells and descending cells into different arrays
; - compute the cosine weighting at each timestep.  
; - compute the pdf
; - compute the intensity of the overturning circulation
;
; should the time averaging come before or after the other analysis?
;
; goal: write out the pdf, circulation intensity, and SST to a ascii array
;
; levi silvers                                                       dec 2020
;-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;-----------------
; time parameters
; initially look at 5 day chunks
if (isvar("chunkdays")) then
  ndays=chunkdays
else
  ndays=5
end if
print("number of days in each averaging chunks is: "+ndays)

if (isvar("datafreq")) then
  freq=datafreq  ;[time per day] for most models this is 1 hr or 24 times per day, for IPSL it is 1 day
  print("data freq read, freq is: "+freq)
else
  freq=24
  print("data freq not detected, freq is: "+freq)
end if
if (isvar("textfile")) then
  foutname=textfile
else
  foutname="nofilename.txt"
end if

timewindow=ndays*freq

if (isvar("nperiods")) then
  numperiods=nperiods
else
  numperiods=73
end if
  print("number of averaging periods is: "+numperiods)

if (isvar("SST")) then
  seaST=SST
else
  seaST=295
end if
  print("SST is : "+seaST)

if (isvar("lasttime")) then
  endtime=lasttime
  print("lasttime var read, endtime is:  "+endtime)
else
  endtime=25000 ; ICON GCM has fewer timesteps that CAM or ECHAM
  print("lasttime var not detected, endtime is:  "+endtime)
end if

timelength=endtime-timewindow*numperiods
startime  =endtime-timewindow*numperiods+1

  print("ndays is: "+ndays)
  print("numperiods is: "+numperiods)
  ;print("timewindow of each period (ndays*freq) is: "+timewindow)
  print("startime for reading data: "+startime+" lasttime to read data is: "+endtime)

;-----------------

; path bases
path_laptop="/Users/silvers/data/CAM/"
path_cheyenne="/glade/scratch/levi/RCEMIP/"

path_C5="CAM5_GCM/";RCE_large305/2D/"
path_C6="CAM6_GCM/"

  print("begin adding files...")

;*************************************************************
; read variables
;---------------------------------------------------------
if (isvar("CAMGCM")) then

  whichCAM=CAMGCM
  if (CAMGCM .lt. 6) then
    file_omega_5=path_cheyenne+path_C5+"RCE_large"+seaST+"/2D/CAM5_GCM_RCE_large"+seaST+"_2D_wap500.nc"
    
    print("incoming file should be CAM: "+file_omega_5)

    fc5=addfile(file_omega_5,"r")
    wvar_a=fc5->wap500(startime:endtime,:,:)

    print("incoming file should be CAM: "+file_omega_5)
  else 
    file_omega_6=path_cheyenne+path_C6+"RCE_large"+seaST+"/2D/CAM6_GCM_RCE_large"+seaST+"_2D_wap500.nc"
    
    print("incoming file should be CAM: "+file_omega_6)

    fc6=addfile(file_omega_6,"r")
    wvar_a=fc6->wap500(startime:endtime,:,:)
    
    print("incoming file should be CAM: "+file_omega_6)
  end if
else
  ; for SST = 295K
  filen_test=model+"_RCE_large"+seaST+"_2D_"+varname+".nc"
  file_testmodel=path_cheyenne+"swift.dkrz.de/"+model+"/"+filen_test
  print("incoming file: "+file_testmodel)
  fin=addfile(file_testmodel,"r")
  if (omega .lt. 1) then
    wvar_a=fin->wap500(startime:endtime,:,:)
  else if (omega .lt. 2) then
    wvar_a=fin->wa500(startime:endtime,:,:)
  else if (omega .lt. 3) then
    wvar_a=fin->vertical_velocity_500hpa(startime:endtime,:,:)
  end if 
  end if 
  end if
;  printVarSummary(wvar_a)
end if

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;*************************************************************
; rescale variables to hPa/d 
;---------------------------------------------------------
;  print("convert to hPa/d")

; convert units to hPa/d?  
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is 6042 ?!! 

wvar_a=scalef*wvar_a

;  print("from omega500 pdf")
;  printVarSummary(wvar_a)

;*************************************************************
; perform regridding to 1x1 degree lat lon
;---------------------------------------------------------

var_to_interpolate=wvar_a

if (isvar("longdimnames")) then
  var_to_interpolate!1="lat"
  var_to_interpolate&lat=wvar_a&latitude
  var_to_interpolate!2="lon"
  var_to_interpolate&lon=wvar_a&longitude
else
  var_to_interpolate!1="lat"
  var_to_interpolate&lat=wvar_a&lat
  var_to_interpolate!2="lon"
  var_to_interpolate&lon=wvar_a&lon
end if

;var_to_interpolate!1="lat"
;var_to_interpolate&lat=wvar_a&lat
;var_to_interpolate!2="lon"
;var_to_interpolate&lon=wvar_a&lon


dim_orig=dimsizes(var_to_interpolate)
nlat=dim_orig(1)
nlon=dim_orig(2)

latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

   opt = False

   NLAT1x1       = 180                               ; RES   = "180x288"
   MLON1x1       = 360
   ;LAT_out_temp  = latGlobeFo(NLAT1x1, "LAT_out_temp", "latitude" , "degrees_north")
   LAT_out  = latGlobeFo(NLAT1x1, "LAT_out_temp", "latitude" , "degrees_north")
   LON_out       = lonGlobeFo(MLON1x1, "LON_out", "longitude", "degrees_east" )

;   opt@NLATi       = nlati
;   opt@NLATo       = NLAT1x1
;   LAT_out     = LAT_out_temp({latS:latN})
   interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_out, LAT_out, opt)

intvar_180x360=interpolated_var
intvar_180x360!0="time"
intvar_180x360!1="lat"
intvar_180x360!2="lon"

;*************************************************************
; parse out the ascending and descending regions
;-------------------------------------------------------------

; printVarSummary(intvar_180x360)


omega_u_a=where((intvar_180x360 .le. 0),intvar_180x360,intvar_180x360@_FillValue)
omega_d_a=where((intvar_180x360 .ge. 0),intvar_180x360,intvar_180x360@_FillValue)
omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
 printVarSummary(omega_u_a)

;*************************************************************
; compute cosine weighting
;-------------------------------------------------------------
lat  = LAT_out
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)

intvar_u_cave  = wgt_areaave(omega_u_a,clat,1.0,0)
intvar_d_cave  = wgt_areaave(omega_d_a,clat,1.0,0)
; test no weighting...
;intvar_u_cave  = wgt_areaave(omega_u_a,1.0,1.0,0)
;intvar_d_cave  = wgt_areaave(omega_d_a,1.0,1.0,0)

  printVarSummary(intvar_u_cave)

;*************************************************************
; compute circulation intensity 
;-------------------------------------------------------------

;intvar_u=where((intvar_u_cave .gt. -0.0001),intvar_u_cave@_FillValue,intvar_u_cave)
;intvar_d=where((intvar_d_cave .lt. 0.0001),intvar_d_cave@_FillValue,intvar_d_cave)
;av_dn2 = dim_avg_n(intvar_d,0)
;av_up2 = dim_avg_n(intvar_u,0)

av_up = dim_avg_n(intvar_u_cave,0)
av_dn = dim_avg_n(intvar_d_cave,0)

;  print(down_min_up)   ; this is the circulation intensity
  print("av_dn is equal to: "+av_dn)
  print("av_up is equal to: "+av_up)
 ; print("av_dn2 is equal to: "+av_dn2)
 ; print("av_up2 is equal to: "+av_up2)
circulation_int = -av_dn-av_up
  print("is the circulation intensity at "+seaST+" equal to: "+circulation_int+"?")

;*************************************************************
; plot the pdf
;-------------------------------------------------------------
plot = new(1,"graphic")

; cosine weighted
b_reshape=new((/timewindow,numperiods,180,360/),float)
b_reshape=reshape(intvar_180x360,(/timewindow,numperiods,180,360/))
b_reshape_tmn=dim_avg_n(b_reshape,0)

; not cosine weighted
a_reshape=new((/timewindow,numperiods,nlat,nlon/),float)
a_reshape=reshape(wvar_a,(/timewindow,numperiods,nlat,nlon/))
a_reshape_tmn=dim_avg_n(a_reshape,0)

numbins = 48 

opt = True
opt@bin_min=-120
opt@bin_max=120
opt@bin_spacing=5
pdf_a=pdfx(a_reshape_tmn,numbins,opt)
pdf_b=pdfx(b_reshape_tmn,numbins,opt)

;  print("mean of -omega for 295K is: "+avg(pdf_a(0:21)))
;  print("mean of omega for 295K is: "+avg(pdf_a(22:41)))
;  print("mean of -omega for 300K is: "+avg(pdf_b(0:21)))
;  print("mean of omega for 300K is: "+avg(pdf_b(22:41)))
;  print("mean of -omega for 305K is: "+avg(pdf_c(0:21)))
;  print("mean of omega for 305K is: "+avg(pdf_c(22:41)))
;
;  print("bin centers are: "+pdf_a@bin_center)

binsb2=numbins/2
; below is a work in progress trying to weight as in bony et al. 
;do i=0,binsb2-1
;  omegaup(i)=pdf_a@bin_center(i)*pdf_a(i)
;  omegadn(i)=pdf_a@bin_center(i+binsb2)*pdf_a(i+binsb2)
;end do
;
;;omegaup/sum(pdf_a@bin_center)
;
;omegaupbar=sum(omegaup)/sum(pdf_a@bin_center)
;omegadnbar=sum(omegadn)/sum(pdf_a@bin_center)

colors = (/"chocolate2","aquamarine3"/)
;
wks = gsn_open_wks("eps","testplot")

res                    = True
res@gsnDraw            = False
res@gsnFrame           = False
res@xyLineThicknessF   = 5.
res@tiYAxisString      = "PDF (%)"
res@tiXAxisString      = "circulation regime (hPa/d)"

res@trXMinF = -150.0
res@trXMaxF = 50.0
res@trYMinF = 0.0
res@trYMaxF = 20.0

;  printVarSummary(pdf_a)
;  print("pdf_a values are: "+pdf_a)
;  print("sum of pdf_a? is: "+sum(pdf_a))
;  print("sum of pdf_a bin_center values is: "+sum(pdf_a@bin_center))
;  print("sum of pdf_b? is: "+sum(pdf_b))
;  print("sum of pdf_b? is: "+sum(pdf_c))
;
;res@gsnCenterString    = "default bins"
res@xyLineColors = colors(0)
res@xyDashPattern =  0
res@xyLineThicknessF = 2.
plot0_a    =  gsn_csm_xy (wks,pdf_a@bin_center, pdf_a, res)
res@xyLineColors = colors(0)
;;res@xyDashPattern =  3
res@xyLineThicknessF = 4.
plot0_b    =  gsn_csm_xy (wks,pdf_b@bin_center, pdf_b, res)
;res@xyLineColors = colors(0)
;;res@xyDashPattern =  16
;res@xyLineThicknessF = 6.
;plot0_c    =  gsn_csm_xy (wks,pdf_c@bin_center, pdf_c, res)
overlay(plot0_a,plot0_b)
;overlay(plot0_a,plot0_c)
plot(0)=plot0_a

;
resP    = True
resP@gsnPanelMainString  = "Circulation Regime over last year"
gsn_panel(wks,plot,(/1,1/),resP)

;==========================
; write out data to a txt file...
; what should we write?  Perhaps the PDF, I,Iup,Idn, SST, and Model name?  
; although the Model name would require writing different data types to the same arr
;
arrdim=numbins+4
arrayout  =new((/2,arrdim/),double)
tarray    =new((/1,numbins/),double)
;tarray = pdf_a@bin_center
tarray = pdf_a
  print("dimsizes of arrayout: "+dimsizes(arrayout))
do z=0,numbins-1
  ;print("temp at z= "+z+" is: "+temp_tmn(z)+" gamma is: "+gamma_a(z)+" press is: "+press_tmn(z)+" rho is: "+rho(z)+" and gamma_m is: "+gamma_m(z)+" num: "+numer(z)+" den: "+denom(z))
  print(" value of pdf_a for z = "+z+" is: "+pdf_a(z))
  ;arrayout(0,z)=pdf_a@bin_center(z)
  arrayout(0,z)=tarray(0,z)
  arrayout(1,z)=pdf_a@bin_center(z)
end do
  arrayout(0,numbins)   = 34. ;I
  arrayout(0,numbins+1) = 35. ;Iup
  arrayout(0,numbins+2) = 36. ;Idn
  arrayout(0,numbins+3) = seaST

option         = True   ; if False then output is sent to standard out
option@fout    = foutname
;option@title   = "gamma_a, gamma_m, sbycp, sigma, hur_tmn, press, rscs, rlcs, diabdiv"
;write_matrix (arrayout, "7f7.2", option)
write_matrix (arrayout, "1f14.4", option)




end
