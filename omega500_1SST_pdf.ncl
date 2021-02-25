;-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; omega500_1SST_pdf.ncl
;
; used with the script omega_gcm_pdf.sh
; 
; output both an .eps and a .txt file
;
; - open file
; - read vertical velocity variable
; - rescale to hPa/day
; - interpolate to standard lat lon grid
;         - not for CRMs, but shouldn't we interpolate to common block? 
; - parse the ascending cells and descending cells into different arrays
; - compute the cosine weighting at each timestep.  
;         - not for CRMs
; - compute the pdf
; - compute the intensity of the overturning circulation
;
; should the time averaging come before or after the other analysis?
;
; note: CRM models used a channel shaped domain and were run for 100 days.  
;
; goal: write out the pdf, circulation intensity, and SST to a ascii array
;
; levi silvers                                                       dec 2020
;-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  print("scumstash is right.")
;-----------------
; time parameters
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
numygp=127
numxgp=1983

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
else if (CRM .lt. 1) ; case for GCM data that is not from CAM5 or CAM6
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
else ; case for CRM data
  filen_test=model+"_RCE_large"+seaST+"_2D_"+varname+".nc"
  file_testmodel=path_cheyenne+"swift.dkrz.de/"+model+"/"+filen_test
  fin=addfile(file_testmodel,"r")
    print("incoming file: "+file_testmodel)
  if (isvar("flippeddim")) then  ; ICON LEM
    wvar_a=fin->wa500(startime:endtime,0:numxgp,0:numygp)  
    y_orig=fin->y(0:numxgp)
    x_orig=fin->x(0:numygp)
  else ; below should be the default reading, which works for SAM
    wvar_a=fin->wa500(startime:endtime,0:numygp,0:numxgp)  
    y_orig=fin->y(0:numygp)
    x_orig=fin->x(:numxgp)
  end if

  if (isvar("flippeddim")) then  ; ICON LEM
    x_new=fspan(0,384000,5)
    y_new=fspan(0,5952000,63)
  else                           ; SAM
    y_new=fspan(0,384000,5)
    x_new=fspan(0,5952000,63)
  end if

  print("original y array is: "+y_orig)
  print("new y array is: "+y_new)
  print("new x array is: "+x_new)

end if
end if

wvar_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

;*************************************************************
; rescale variables to hPa/d 
;---------------------------------------------------------

; convert units to hPa/d?  
; for models with Pa/s conversion factor is 864
; for models with m/s, conversion factor is 6042 ?!! 

wvar_a=scalef*wvar_a

;  print("from omega500 pdf")
;  printVarSummary(wvar_a)

if (isvar("RCE_GCM"))
;*************************************************************
; perform regridding to 1x1 degree lat lon
;---------------------------------------------------------
    print("begin interpolation...")
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

  dim_orig=dimsizes(var_to_interpolate)
  nlat=dim_orig(1)
  nlon=dim_orig(2)

  latS=var_to_interpolate&lat(0)                      ; southern extent of input grid
  latN=var_to_interpolate&lat(nlat-1)                 ; northern extent of input grid

  opt = False

  NLAT1x1       = 180                               ; RES   = "180x288"
  MLON1x1       = 360
  LAT_out       = latGlobeFo(NLAT1x1, "LAT_out_temp", "latitude" , "degrees_north")
  LON_out       = lonGlobeFo(MLON1x1, "LON_out", "longitude", "degrees_east" )

    print("just before interpolation...")
  interpolated_var = area_conserve_remap_Wrap (var_to_interpolate&lon, var_to_interpolate&lat, var_to_interpolate,LON_out, LAT_out, opt)
    print("just after interpolation...")

  intvar_out=interpolated_var
  intvar_out!0="time"
  intvar_out!1="lat"
  intvar_out!2="lon"
    print("interpolation finished")
    printVarSummary(intvar_out)
else
  ; for SAM
  ;y_new=fspan(0,288000,4)
  ;x_new=fspan(0,6048000,64)
  ; for ICON-LEM
  ;y_new=fspan(0,288000,4)
  ;x_new=fspan(0,5856000,62)
  ; would this work?
  if (isvar("flippeddim")) then  ; ICON LEM
    x_new=fspan(0,384000,5)
    y_new=fspan(0,5952000,63)
  else                           ; SAM
    y_new=fspan(0,384000,5)
    x_new=fspan(0,5952000,63)
  end if
    print("original y array is: "+y_orig)
    print("new y array is: "+y_new)
    print("new x array is: "+x_new)
  var_to_interpolate=wvar_a ; incoming CRM data
  ; var_to_interpolate must have y,x as its two rightmost dimensions...
  juljack=area_hi2lores(x_orig,y_orig,var_to_interpolate,False,1,x_new,y_new,False)
  intvar_out=juljack
end if  ; end interpolation loop

;*************************************************************
; parse out the ascending and descending regions and comp SF
;-------------------------------------------------------------

;intvar_out(time lat lon)
; compute mean upwelling and downwelling without chunks
omega_u_a      =where((intvar_out .le. 0),intvar_out,intvar_out@_FillValue)
omega_u_a_frac =where((intvar_out .le. 0),1.0,0.0)
omega_d_a      =where((intvar_out .ge. 0),intvar_out,intvar_out@_FillValue)
omega_d_a_frac =where((intvar_out .ge. 0),1.0,0.0)

omega_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
omega_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue

  printVarSummary(omega_u_a)
dim_om=dimsizes(omega_u_a)
  print("first dimension of omega_u_a: "+dim_om(1))
  print("second dimension of omega_u_a: "+dim_om(2))
total_area=dim_om(1)*dim_om(2)
sfrac      =new((/dim_om(0)/),float)
sfrac_up   =new((/dim_om(0)/),float)
do tt=0,dim_om(0)-1
  omega_temp2=omega_u_a_frac(tt,:,:)
  omega_temp3=omega_d_a_frac(tt,:,:)
  sfrac_up(tt)=sum(omega_temp2)/total_area
  sfrac(tt)=sum(omega_temp3)/total_area
end do
  print("poor mans subs frac at 1 timestep is: "+sfrac(10)+" and fraction of ascending air is: "+sfrac_up(10))

;*************************************************************
; compute cosine weighting
;-------------------------------------------------------------
if (CRM .lt. 1)
  lat  = LAT_out
  rad  = 4.0*atan(1.0)/180.0
  clat = cos(lat*rad)
  
  intvar_u_ave  = wgt_areaave(omega_u_a,clat,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,clat,1.0,0)
  ; test no weighting...
  ;intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
  ;intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
  
    printVarSummary(intvar_u_ave)
else
  intvar_u_ave  = wgt_areaave(omega_u_a,1.0,1.0,0)
  intvar_d_ave  = wgt_areaave(omega_d_a,1.0,1.0,0)
end if
;*************************************************************
; compute circulation intensity 
;-------------------------------------------------------------

w_up=intvar_u_ave*sfrac_up
w_dn=intvar_d_ave*sfrac

av_up = dim_avg_n(intvar_u_ave,0)
av_dn = dim_avg_n(intvar_d_ave,0)

wav_up = dim_avg_n(w_up,0)
wav_dn = dim_avg_n(w_dn,0)

  print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
;  print(down_min_up)   ; this is the circulation intensity
  print("av_dn is equal to: "+av_dn)
  print("weighted by sf, w_dn at 1 time is equal to: "+w_dn(10)+" and weighted w_up is equal to: "+w_up(10))
  print("ave weighted by sf, wav_dn, is equal to: "+wav_dn+" and weighted wav_up is equal to: "+wav_up)
  print("av_up is equal to: "+av_up)
 ; print("av_dn2 is equal to: "+av_dn2)
 ; print("av_up2 is equal to: "+av_up2)
circulation_int = av_dn-av_up
  print("the circulation intensity of unchunked data at "+seaST+" is equal to: "+circulation_int)
  print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

;*************************************************************
; first reshape the time dimension, then compute the pdf
;
; almost certainly, the omega parameters should be computed 
; using the same array as the pdf is calculated with...

if (CRM .lt. 1)
  ; cosine weighted
  a_reshape=new((/timewindow,numperiods,180,360/),float)
  a_reshape=reshape(intvar_out,(/timewindow,numperiods,180,360/))
  a_reshape_tmn=dim_avg_n(a_reshape,0)
else
  xdim=63
  ydim=5 
  if (isvar("flippeddim")) then  ; ICON LEM  has the long and short dims of the channel reversed from SAM...
    a_reshape=new((/timewindow,numperiods,xdim,ydim/),float)
    a_reshape=reshape(intvar_out,(/timewindow,numperiods,xdim,ydim/))
  else ; SAM
    a_reshape=new((/timewindow,numperiods,ydim,xdim/),float)
    a_reshape=reshape(intvar_out,(/timewindow,numperiods,ydim,xdim/))
  end if
  a_reshape_tmn=dim_avg_n(a_reshape,0)
end if

numbins =  48; originally 48 

; should we compute the pdf of the time averaged data 
; or should we compute the time average of the pdfs? 

opt = True
opt@bin_min=-120
opt@bin_max=120
;opt@bin_spacing=5
opt@bin_spacing=10
pdf_a=pdfx(a_reshape_tmn,numbins,opt)
pdf_b=pdfx(intvar_out,numbins,opt)
pdf_c=pdfx(wvar_a,numbins,opt)
  print("dimsizes of pdf_a are: "+dimsizes(pdf_a))
  print("dimsizes of pdf_b are: "+dimsizes(pdf_b))
  print("dimsizes of pdf_c are: "+dimsizes(pdf_c))

;;********************************************************************
;printVarSummary(a_reshape_tmn)
;; compute mean up and down using chunks...
;om_u_a      =where((a_reshape_tmn .le. 0),a_reshape_tmn,a_reshape_tmn@_FillValue)
;om_d_a      =where((a_reshape_tmn .ge. 0),a_reshape_tmn,a_reshape_tmn@_FillValue)
;
;om_u_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
;om_d_a@_FillValue = default_fillvalue("float")    ; set devault FillValue
;
;; calculate the cosine weighted mean
;if (CRM .lt. 1)
;  om_u_mn = wgt_areaave(omega_u_a,clat,1.0,0)
;  om_d_mn = wgt_areaave(omega_d_a,clat,1.0,0)
;else
;  om_u_mn = wgt_areaave(omega_u_a,1.0,1.0,0)
;  om_d_mn = wgt_areaave(omega_d_a,1.0,1.0,0)
;end if
;
;; calculate the time mean
;om_u_tmn = dim_avg_n(om_u_mn,0)
;om_d_tmn = dim_avg_n(om_d_mn,0)
;
;circ2=om_d_tmn-om_u_tmn
;  print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
;  print("omega bar up equals: "+om_u_tmn+" and omega bar down equals: "+om_d_tmn)
;  print("Circulation strength computed without any chunking is: "+circ2)
;  print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")


;new_pdf   =new((/dim_om(0)/),float)
;do tt=0,dim_om(0)-1
;  omega_temp3=omega_d_a_frac(tt,:,:)
;  sfrac(tt)=sum(omega_temp3)/total_area
;end do

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
;;omegaup/sum(pdf_a@bin_center)
;omegaupbar=sum(omegaup)/sum(pdf_a@bin_center)
;omegadnbar=sum(omegadn)/sum(pdf_a@bin_center)

;*************************************************************
; plot the pdf
;-------------------------------------------------------------
plot = new(1,"graphic")

colors = (/"chocolate2","aquamarine3"/)
;
wks = gsn_open_wks("eps","testplot")

res                    = True
res@gsnDraw            = False
res@gsnFrame           = False
res@xyLineThicknessF   = 5.
res@tiYAxisString      = "PDF (%)"
res@tiXAxisString      = "circulation regime (hPa/d)"

res@trXMinF = -120.0
res@trXMaxF = 100.0
res@trYMinF = 0.0
res@trYMaxF = 25.0

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
res@xyLineThicknessF = 4.
plot0_a    =  gsn_csm_xy (wks,pdf_a@bin_center, pdf_a, res)
res@xyLineThicknessF = 2.
res@xyDashPattern =  1
plot0_b    =  gsn_csm_xy (wks,pdf_b@bin_center, pdf_b, res)
res@xyLineThicknessF = 2.
res@xyDashPattern =  2
plot0_c    =  gsn_csm_xy (wks,pdf_c@bin_center, pdf_c, res)

overlay(plot0_a,plot0_b)
overlay(plot0_a,plot0_c)

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
;tarray = pdf_b@bin_center
arrayout = -999.
tarray = pdf_b
  ;print("dimsizes of arrayout: "+dimsizes(arrayout))
do z=0,numbins-1
  ;print("temp at z= "+z+" is: "+temp_tmn(z)+" gamma is: "+gamma_a(z)+" press is: "+press_tmn(z)+" rho is: "+rho(z)+" and gamma_m is: "+gamma_m(z)+" num: "+numer(z)+" den: "+denom(z))
  print(" value of pdf_a for z = "+z+" is: "+pdf_a(z))
  ;arrayout(0,z)=pdf_a@bin_center(z)
  arrayout(0,z)=tarray(0,z)
  arrayout(1,z)=pdf_b@bin_center(z)
end do
;circulation_int = av_dn-av_up
arrayout(0,numbins)   = circulation_int ;I
arrayout(0,numbins+1) = av_up ;Iup
arrayout(0,numbins+2) = av_dn ;Idn
arrayout(0,numbins+3) = seaST

option         = True   ; if False then output is sent to standard out
option@fout    = foutname
;option@title   = "gamma_a, gamma_m, sbycp, sigma, hur_tmn, press, rscs, rlcs, diabdiv"
;write_matrix (arrayout, "7f7.2", option)
write_matrix (arrayout, "1f14.4", option)


end
