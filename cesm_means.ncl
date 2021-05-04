;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; cesm_means.ncl 
;
; compute mean values for particular variables in the deep tropics of cesm1 and cesm2
; for comparison with RCE experiments.
;
; after reading in the data, apply a land-sea mask so that we only
; plot points over oceans. 
;
; levi silvers                                                           feb 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

path_cmip6="/glade/campaign/collections/cmip/CMIP6/"
tocmip ="/glade/collections/cmip/"

path_cmip5=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/"

file_lsmask=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/fx/atmos/fx/r0i0p0/files/sftlf_20120614/sftlf_fx_CESM1-CAM5_amip_r0i0p0.nc"

plotAmip=True ; default is 0, which results in piControl experiment plots

;; amip paths
if (plotAmip) then
    print("using AMIP data")
  filen5="cl_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
  filen6="cl_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
  ;file_c5_in=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/cl/"+filen5
  ;file_c6_in=tocmip+"CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  almostpath_c5=tocmip+"cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/amip/mon/atmos/Amon/r1i1p1/latest/"
  almostpath_c6=tocmip+"CMIP6/CMIP/NCAR/CESM2/amip/r1i1p1f1/Amon/"
  endtime =239
  endtime2=239
else ; picontrol patha
    print("using piControl data")
  endtime =1199
  endtime2=1199
  filen6="cl_Amon_CESM2_piControl_r1i1p1f1_gn_060001-069912.nc"
  exp_file_c5="piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/"
  file_c6_in=tocmip+"CMIP6/CMIP/NCAR/CESM2/piControl/r1i1p1f1/Amon/cl/gn/latest/"+filen6
  filen5="cl_Amon_CESM1-CAM5_piControl_r1i1p1_031001-031912.nc"
  file_c5_in =path_cmip5+exp_file_c5+filen5
  ; use addfiles to read multiple files at once...
  c5_picontrol_fils=systemfunc("ls /glade/collections/cmip/cmip5/output1/NSF-DOE-NCAR/CESM1-CAM5/piControl/mon/atmos/Amon/r1i1p1/v20130313/cl/cl_Amon_CESM1-CAM5_piControl_r1i1p1_02*nc")
  f_test   =addfiles(c5_picontrol_fils,"r")
  ListSetType(f_test,"cat")
  c5_cl = f_test[:]->cl    ; read 3D cloud fraction
end if

; precipitation
var="pr"
filen5=var+"_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
filen6=var+"_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
pr_c5_f = almostpath_c5+var+"/"+filen5
pr_c6_f = almostpath_c6+var+"/gn/latest/"+filen6

; tas
var="tas"
filen5="tas_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
filen6="tas_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
ts_c5_f = almostpath_c5+var+"/"+filen5
ts_c6_f = almostpath_c6+var+"/gn/latest/"+filen6

; total cloud fraction
filen5="clt_Amon_CESM1-CAM5_amip_r1i1p1_197901-200512.nc"
filen6="clt_Amon_CESM2_amip_r1i1p1f1_gn_195001-201412.nc"
clt_c5 = almostpath_c5+filen5
clt_c6 = almostpath_c6+filen6

pr_c5_data     =addfile(pr_c5_f,"r")
pr_c6_data     =addfile(pr_c6_f,"r")  
ts_c5_data     =addfile(ts_c5_f,"r")
ts_c6_data     =addfile(ts_c6_f,"r")
f_in_lsm    =addfile(file_lsmask,"r")

pr_c5 = pr_c5_data->pr
pr_c6 = pr_c6_data->pr

ts_c5 = ts_c5_data->tas
ts_c6 = ts_c6_data->tas

printVarSummary(pr_c5)
printVarSummary(pr_c6)

end

