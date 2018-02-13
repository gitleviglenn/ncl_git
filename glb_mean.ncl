;---------------------------------------------------------------------
; glb_radflux.ncl
;---------------------------------------------------------------------
;
; reads in data file from one experiment
; and computes cosine weighted global mean value ignoring points with a
; value of zero (typically, land points).  This is mostly to 
; ensure I am computing the lat weighted gbl mn in matlab coreectly
; 
; levi silvers                                         june 2016                    
;---------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;---------------------------------------------------------------------
begin
;---------------------------------------------------------------------
; olr,olr_clr,swdn_toa,swup_toa,swdn_toa_clr,swup_toa_clr
pre1="_"
;varname1="sst"
varname1="cltisccp" ; ISCCP total cloud fraction
;varname1="tot_cld_amt"  
;varname1="dt"
;years="006101-014012"
;infile1="/archive/Ming.Zhao/awglg/ulm/AM4OM2F_c96l32_am4g5r11_2000climo_1pct/ts_all/atmos."+years+"."+varname1+".nc"
;infile1="/archive/Ming.Zhao/awg/ulm/CM2.1U-D4_1PctTo2X_I1/ts_all/atmos.000101-010012."+varname1+".nc"
;infile1="/archive/Ming.Zhao/awglg/ulm/AM4OM2F_c96l32_am4g5r11_2000climo_1pct/ts_all/atmos.006101-014012."+varname1+".nc"
;infile1="/net2/Levi.Silvers/data/input_sstpattern/sst_am4g6_2000_1pct_co2_patt.nc"
;infile1="/net2/Levi.Silvers/data/input_sstpattern/sst_am4g6_1860_4xCO2_patt.nc"
;infile1="/home/lgs/sst_1pctCO2_regpatt_360x180_pp.nc"
;infile1="/home/lgs/sst_4xCO2_regpatt_360x180_tmn.nc"
;infile1="/home/lgs/sst_am4g6_1860_ctlpreg_4xco2.nc"
;infile1="/home/lgs/sst_4xco2_testpat_tmn_remap.nc"
;infile1="/home/lgs/diff4xCOm1pct_tmn.nc"
;infile1="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_isccp3/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_5yr/atmos_month_cospx.0002-0006.01.nc"
;infile1="/archive/Levi.Silvers/awg/ulm_201505/c96L32_am4g9_2000climo_cosp_isccp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_10yr/atmos_month_cospx.0002-0011.01.nc"
infile1="/archive/Levi.Silvers/awg/verona/c96L32_am4g10r8_2000climo_cosp_onlyisccp/gfdl.ncrc3-intel-prod-openmp/pp/atmos_month_cospx/av/monthly_2yr/atmos_month_cospx.all_mn.nc"
;
  aa = addfile(infile1,"r")
time=0
  field1 = aa->$varname1$(time,:,:)          
  ;field1 = aa->$varname1$(time,0,:,:)          
;
;---------------------------------------------------------------------
; print max and min values
print("infile1 is: "+infile1)
print("dimensions of "+varname1+" are "+dimsizes(field1))
print("max of infile is: "+max(field1))
print("min of infile is: "+min(field1))
;---------------------------------------------------------------------
; compute lat weights to determine the global mn
lat  = aa->lat
rad  = 4.0*atan(1.0)/180.0
clat = cos(lat*rad)
;field1_test = where(field1.eq.0, default_fillvalue("float"),field1)
; where(condition, true, false)
field1_test = where(field1.gt.0., field1,default_fillvalue("float"))
;field1_test = where(field1.gt.-900., field1,default_fillvalue("float"))
field1_weighted_ave     = wgt_areaave(field1,clat,1.0,1)
; using 0 instead of 1 as the last parameter of wgt_areaave ave is calculated with 
; available non-missing data. 
field1_weighted_ave_test     = wgt_areaave(field1_test,clat,1.0,0)
print("raw global mean of "+varname1+" at time "+time+" is: "+field1_weighted_ave)
print("global mean of non missing data "+varname1+" at time "+time+" is: "+field1_weighted_ave_test)
;
;---------------------------------------------------------------------
;---------------------------------------------------------------------
; code to compute mean of pattern from Webb et al. 2016 Appendix
infilesst="/net2/Levi.Silvers/data/CMIP3_sstpatt/cfmip2_4k_patterned_sst_forcing.vn1.0.nc"
;
  ww = addfile(infilesst,"r")
  time=0
  varname1="dt"
  field_webb = ww->$varname1$(time,0,:,:)          
;
print("infilesst is: "+infilesst)
print("dimensions of "+varname1+" are "+dimsizes(field_webb))
print("max of infile is: "+max(field_webb))
print("min of infile is: "+min(field_webb))
  latit  = ww->latitude
  rad  = 4.0*atan(1.0)/180.0
  clat2 = cos(latit*rad)
  field_webb_test = where(field_webb.gt.-900., field_webb,default_fillvalue("float"))
  field_webb_weighted_ave_test     = wgt_areaave(field_webb_test,clat2,1.0,0)
print("global mean of non missing data "+varname1+" at time "+time+" is: "+field_webb_weighted_ave_test)
;---------------------------------------------------------------------
; code to compute mean of general variable
infile_gen="/net2/Levi.Silvers/data/amip_long/c96L32_am4g10r8_longamip_1860rad/atmos.187101-201512.t_ref.nc"
;
  ww = addfile(infile_gen,"r")
  time=13
  varname1="t_ref"
  field_gen = ww->$varname1$(time,:,:)          
;
print("infile_gen is: "+infile_gen)
print("dimensions of "+varname1+" are "+dimsizes(field_gen))
print("max of infile is: "+max(field_gen))
print("min of infile is: "+min(field_gen))
  latit_gen  = ww->lat
  rad  = 4.0*atan(1.0)/180.0
  clat3 = cos(latit_gen*rad)
  field_gen_test = where(field_gen.gt.-900., field_gen,default_fillvalue("float"))
  field_gen_weighted_ave_test     = wgt_areaave(field_gen_test,clat3,1.0,0)
print("global mean of non missing data "+varname1+" at time "+time+" is: "+field_gen_weighted_ave_test)
;---------------------------------------------------------------------


end

