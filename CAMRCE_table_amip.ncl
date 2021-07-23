;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; CAMRCE_table_amip.ncl
;
; levi silvers                                                           july 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  
path_cmip6="/glade/campaign/collections/cmip/CMIP6/"
tocmip ="/glade/collections/cmip/"
;exp_file_c6="timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/atm/proc/tseries/day_1/"

path_cmip5=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/"

file_lsmask=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/fx/atmos/fx/r0i0p0/files/sftlf_20120614/sftlf_fx_CESM1-CAM5_amip_r0i0p0.nc"

selectvar=5

if (selectvar .eq. 1) then
  varname="pr"
  scale=86400; converts precipitation into mm/day
else if (selectvar .eq. 2) then
  varname="prc"
  scale=86400; converts precipitation into mm/day
else if (selectvar .eq. 3) then
  varname="clt"
  scale=1; 
else if (selectvar .eq. 4) then
  varname="rlut"
  scale=1; 
else if (selectvar .eq. 5) then
  varname="prw"
  scale=1; 
end if
end if
end if
end if
end if

  filen5=varname+"_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
  filen6=varname+"_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"

  file_c5_am=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/"+varname+"/"+filen5
  file_c6_am=tocmip+"CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/"+varname+"/gn/latest/"+filen6

  filen5=varname+"_Amon_CESM1-CAM5_piControl_r1i1p1_031001-031912.nc"
  filen6=varname+"_Amon_CESM2_piControl_r1i1p1f1_gn_060001-069912.nc"

  exp_file_c5="piControl/mon/atmos/Amon/r1i1p1/v20130313/"+varname+"/"
  file_c5_piC =path_cmip5+exp_file_c5+filen5
  file_c6_piC=tocmip+"CMIP6/CMIP/NCAR/CESM2/piControl/r1i1p1f1/Amon/"+varname+"/gn/latest/"+filen6

f_in_c5_am     =addfile(file_c5_am,"r") ; reads from single file for vert dim creation.
f_in_c6_am     =addfile(file_c6_am,"r")
;f_in_lsm =addfile(file_lsmask,"r")

  print("incoming amip for cam5 file is: "+file_c5_am)
  print("incoming amip for cam6 file is: "+file_c6_am)

endtime =239


; latitudes to analyze
; 96 is the midpoint
;fd_lat1=80    ; 0 at NP
;fd_lat2=100   ; 180 at SP

; set the geographic regions to select
trop_lat1=90    ; 0 at NP       
trop_lat2=101   ; 180 at SP

;c5_amip_full    =f_in_c5_am->pr(:,:,:)
; precip
if (selectvar .eq. 1) then
  c5_amip_var     =f_in_c5_am->pr(0:endtime,trop_lat1:trop_lat2,0:287)
  c6_amip_var     =f_in_c6_am->pr(0:endtime,trop_lat1:trop_lat2,0:287)
else if (selectvar .eq. 2) then
  ; precip due to convection
  c5_amip_var     =f_in_c5_am->prc(0:endtime,trop_lat1:trop_lat2,0:287)
  c6_amip_var     =f_in_c6_am->prc(0:endtime,trop_lat1:trop_lat2,0:287)
else if (selectvar .eq. 3) then
  ; total cloud fraction
  c5_amip_var     =f_in_c5_am->clt(0:endtime,trop_lat1:trop_lat2,0:287)
  c6_amip_var     =f_in_c6_am->clt(0:endtime,trop_lat1:trop_lat2,0:287)
else if (selectvar .eq. 4) then
  ; OLR 
  c5_amip_var     =f_in_c5_am->rlut(0:endtime,trop_lat1:trop_lat2,0:287)
  c6_amip_var     =f_in_c6_am->rlut(0:endtime,trop_lat1:trop_lat2,0:287)
else if (selectvar .eq. 5) then
  ; prw 
  c5_amip_var     =f_in_c5_am->prw(0:endtime,trop_lat1:trop_lat2,0:287)
  c6_amip_var     =f_in_c6_am->prw(0:endtime,trop_lat1:trop_lat2,0:287)
end if
end if
end if
end if
end if

;printVarSummary(c5_amip_full)
;printVarSummary(c5_amip_var)
;printVarSummary(c6_amip_var)

; compute cosine weighted mean value for the profiles...
lat  = f_in_c6_am->lat
lat_a = lat(trop_lat1:trop_lat2)
;  print("latitudes are: "+lat)
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat_a*rad)

c5_amip_var_tmn   = dim_avg_n(c5_amip_var,0)
c6_amip_var_tmn   = dim_avg_n(c6_amip_var,0)

;printVarSummary(c5_amip_var_tmn)
;printVarSummary(c6_amip_var_tmn)
;printVarSummary(clat)

field_am_c5_gmn   = wgt_areaave(c5_amip_var_tmn,clat,1.0,0)
field_am_c6_gmn   = wgt_areaave(c6_amip_var_tmn,clat,1.0,0)

  print("mean c5 var val is: "+scale*field_am_c5_gmn)
  print("mean c6 var val is: "+scale*field_am_c6_gmn)





end 

