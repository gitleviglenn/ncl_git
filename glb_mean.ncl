;---------------------------------------------------------------------
; glb_mean.ncl
;---------------------------------------------------------------------
;
; reads in data file from one experiment
; and computes cosine weighted global mean value ignoring points with a
; value of zero (typically, land points).  This is mostly to 
; ensure I am computing the lat weighted gbl mn in matlab coreectly
;
; gives same answer as global_wmean_script.m
; 
; levi silvers                                               feb 2018                    
;---------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;---------------------------------------------------------------------
begin
;---------------------------------------------------------------------
;varname="cltisccp" ; ISCCP total cloud fraction
varname="clt"; ISCCP total cloud fraction
;varname="Cloud_Optical_Thickness_Total_Mean"
;varname="tas"
  print("varname is: "+varname)
;infile1="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_onlyisccp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_2yr/atmos_month_cospx.all_mn.nc"
infile="/net2/Levi.Silvers/data/modisdata/MCD08_M3_NC.2005.02.C051.V02.nc"
;infile="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP_bugfix2/gfdl.ncrc3-intel-prod-openmp-modisbugfix/pp/atmos_cmip/av/monthly_5yr/atmos_cmip.2005-2009.12.nc"
infile="/archive/Levi.Silvers/awg/warsaw_201710/c96L33_am4p0_cmip6_cosp_ModisISCCP/gfdl.ncrc3-intel-prod-openmp/pp/atmos_cmip/av/annual_5yr/atmos_cmip.1990-1994.ann.nc"
;
aa = addfile(infile,"r")
time=0
field1 = aa->$varname$(time,:,:)          
;field1 = aa->$varname$(:,:)          
;field1 = aa->$varname$(time,0,:,:)          
;
; this depends on the incoming file...
;field1@_FillValue=-999.
;---------------------------------------------------------------------
; print max and min values
  print("infile is: "+infile)
  print("dimensions of "+varname+" are "+dimsizes(field1))
  print("max of infile is: "+max(field1))
  print("min of infile is: "+min(field1))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
miss=0 ; should be zero when missing data is present

; available non-missing data. 
lat  = aa->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;;field1_test = where(field1.eq.0, default_fillvalue("float"),field1)
;; where(condition, true, false)
;field1_test = where(field1.gt.0., field1,default_fillvalue("float"))
field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))
field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,miss)
  print("global mean of non missing data "+varname+" at time "+time+" is: "+field1_weighted_ave_test)

field1_weighted_ave     = wgt_areaave(field1,clat,1.0,miss)
  print("raw global mean of "+varname+" at time "+time+" is: "+field1_weighted_ave)

;
;---------------------------------------------------------------------
;;---------------------------------------------------------------------
;; code to compute mean of pattern from Webb et al. 2016 Appendix
;infilesst="/net2/Levi.Silvers/data/CMIP3_sstpatt/cfmip2_4k_patterned_sst_forcing.vn1.0.nc"
;;
;  ww = addfile(infilesst,"r")
;  time=0
;  varname1="dt"
;  field_webb = ww->$varname1$(time,0,:,:)          
;;
;print("infilesst is: "+infilesst)
;print("dimensions of "+varname1+" are "+dimsizes(field_webb))
;print("max of infile is: "+max(field_webb))
;print("min of infile is: "+min(field_webb))
;  latit  = ww->latitude
;  rad  = 4.0*atan(1.0)/180.0
;  clat2 = cos(latit*rad)
;  field_webb_test = where(field_webb.gt.-900., field_webb,default_fillvalue("float"))
;  field_webb_weighted_ave_test     = wgt_areaave(field_webb_test,clat2,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field_webb_weighted_ave_test)
;;---------------------------------------------------------------------
;; code to compute mean of general variable
;infile_gen="/net2/Levi.Silvers/data/amip_long/c96L32_am4g10r8_longamip_1860rad/atmos.187101-201512.t_ref.nc"
;;
;  ww = addfile(infile_gen,"r")
;  time=13
;  varname1="t_ref"
;  field_gen = ww->$varname1$(time,:,:)          
;;
;print("infile_gen is: "+infile_gen)
;print("dimensions of "+varname1+" are "+dimsizes(field_gen))
;print("max of infile is: "+max(field_gen))
;print("min of infile is: "+min(field_gen))
;  latit_gen  = ww->lat
;  rad  = 4.0*atan(1.0)/180.0
;  clat3 = cos(latit_gen*rad)
;  field_gen_test = where(field_gen.gt.-900., field_gen,default_fillvalue("float"))
;  field_gen_weighted_ave_test     = wgt_areaave(field_gen_test,clat3,1.0,0)
;print("global mean of non missing data "+varname1+" at time "+time+" is: "+field_gen_weighted_ave_test)
;;---------------------------------------------------------------------


end

