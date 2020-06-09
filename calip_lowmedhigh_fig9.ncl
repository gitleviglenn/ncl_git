;***********************************************************************************
; calip_lowmedhigh_fig9.ncl
;***********************************************************************************
; plot cloud frac for low, med, and high clouds from CALIPSO sim for several exps.
;
; gsn_panel screws up the positioning of plots.  but overlay is used with gsn_panel
; if you don't use gsn_panel, you can explicitly place panels.  But then you can't 
; use overlay and you have to use maximize_output(wks,psres)
;
; each of the columns in figure 9 are produced individually depending on which 
; switches are turned off/on
;
; left column:  plotbias=0; includelegend=1
; right column: plotbias=1; includelegend=0
;
; the center and righ column plot the profiles relative to a control experiment
; this experiment can be chosen as either the AMIP or PiControl experiment with 
; the controlexp switch. 
;
; this script is a mess and probably twice as long as necessary....
;
; levi silvers 							june 2020
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************************************
begin
;
plotbias=1  ; plotbias = 0 is default and corresponds to plotting climatology
;
includelegend=0  ; includelegend=1 plots legend in upper right corner of top panel
; 
controlexp=0 ; 0 uses amip as control, 1 uses piControl 

  if (plotbias .gt. 0) then
    ytitle  = "Cloud Anomaly [%]"
  else
    ytitle  = "Cloud Fraction [%]"
  end if


; variables to read: 
  varname1="cllcalipso"
  varname2="clmcalipso"
  varname3="clhcalipso"
  ; path to data on mac
  path_on_mac="/Users/silvers/data/cfmip_clouds/"
  ;
  path_to_data=path_on_mac

; title for legend labels
    title_lg0="amip"
    title_lg1="amip +4K"
    title_lg2="amip -4K"
    title_lg3="historical"
    title_lg4="abrupt 4xCO2"
    title_lg5="1pctCO2"
    title_lg6="amip +future4K"
    title_piC="P.I. Control"
    title_obs="CALIPSO"
;***********************************************************************************

  ;  observations from CALIPSO
  path_obs="/Users/silvers/data/SatData/CALIPSO/"
infile_calobs=path_obs+"MapLowMidHigh330m_200701-201612_avg_CFMIP2.5_sat_2.9_tmmean.nc"
data_calobs = addfile(infile_calobs,"r")
print("infile calipso obs is: "+infile_calobs)
  ; if using calipso data between 200701-201612 rescale it by 100.
  var1cal = data_calobs->$varname1$(0,:,:) ; low
  var1calscale=100*var1cal
  var2cal = data_calobs->$varname2$(0,:,:)
  var2calscale=100*var2cal
  var3cal = data_calobs->$varname3$(0,:,:)
  var3calscale=100*var3cal
  latitude_calip=data_calobs->latitude(:)

  var1calscale@_FillValue = 1.e+20
  var2calscale@_FillValue = 1.e+20
  var3calscale@_FillValue = 1.e+20

  ; compute zonal mean 
  var3calscale_zmn=dim_avg_n(var3calscale,1)
  var2calscale_zmn=dim_avg_n(var2calscale,1)
  var1calscale_zmn=dim_avg_n(var1calscale,1)
;-=-=-=-=-=-=-=-

  ;  aqua control
  filetoread_aqh="clhcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aqm="clmcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aql="cllcalipso_CFmon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
  
  ;  aqua control lwoff 
  filetoread_aqlw_h="clhcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aqlw_m="clmcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aqlw_l="cllcalipso_CFmon_GFDL-CM4_aqua-control-lwoff_r1i1p1f1_gr1_198001-198912.nc"
  
  ;  aqua p4K
  filetoread_aqp4_h="clhcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aqp4_m="clmcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
  filetoread_aqp4_l="cllcalipso_CFmon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
 
  ; amip
  filetoread_amip_h="atmos_cmip.197901-201412.clhcalipso.nc"
  filetoread_amip_m="atmos_cmip.197901-201412.clmcalipso.nc"
  filetoread_amip_l="atmos_cmip.197901-201412.cllcalipso.nc"
 
  ; amip p4K
  filetoread_amp4_h="clhcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amp4_m="clmcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amp4_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
  
  ; amip p4K lwoff
  filetoread_amp4lw_h="clhcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amp4lw_m="clmcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amp4lw_l="cllcalipso_CFmon_GFDL-CM4_amip-p4K-lwoff_r1i1p1f1_gr1_197901-201412.nc"
  
  ; amip m4K
  filetoread_amm4_h="clhcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amm4_m="clmcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amm4_l="cllcalipso_CFmon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
  
  ; amip future 4K experiment
  filetoread_amfu_h="clhcalipso_CFmon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amfu_m="clmcalipso_CFmon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
  filetoread_amfu_l="cllcalipso_CFmon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"

  ; historical coupled experiment
  ; second chunk of years (780 months)
  filetoread_his_h="clhcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"
  filetoread_his_m="clmcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"
  filetoread_his_l="cllcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"
  ; first chunk of years (1200 months) in the historical experiment
  filetoread_his_early_h="clhcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_185001-194912.nc"
  filetoread_his_early_m="clmcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_185001-194912.nc"
  filetoread_his_early_l="cllcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_185001-194912.nc"

  ; 4xCO2 abrupt coupled experiment
  filetoread_4xCO2a_h="clhcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_000101-010012.nc"
  filetoread_4xCO2a_m="clmcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_000101-010012.nc"
  filetoread_4xCO2a_l="cllcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_000101-010012.nc"

  filetoread_4xCO2_h="clhcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_010101-015012.nc"
  filetoread_4xCO2_m="clmcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_010101-015012.nc"
  filetoread_4xCO2_l="cllcalipso_CFmon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_010101-015012.nc"
 
  ; 1pctCO2 coupled experiment
  filetoread_1pctCO2a_h="clhcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_000101-010012.nc"
  filetoread_1pctCO2a_m="clmcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_000101-010012.nc"
  filetoread_1pctCO2a_l="cllcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_000101-010012.nc"

  filetoread_1pctCO2_h="clhcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
  filetoread_1pctCO2_m="clmcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
  filetoread_1pctCO2_l="cllcalipso_CFmon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"

  ; Pre Industrial Control
  filetoread_piC_h="clhcalipso_CFmon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
  filetoread_piC_m="clmcalipso_CFmon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
  filetoread_piC_l="cllcalipso_CFmon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; define experiment paths and read data from files 
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; paths and names
  ;expname="piControl"
  infile_pic_l=path_to_data+filetoread_piC_l
  infile_pic_m=path_to_data+filetoread_piC_m
  infile_pic_h=path_to_data+filetoread_piC_h
  ;expname="amip"
  infile_l=path_to_data+filetoread_amip_l
  infile_m=path_to_data+filetoread_amip_m
  infile_h=path_to_data+filetoread_amip_h
  ;expname="amip-p4K"
  infile1_l=path_to_data+filetoread_amp4_l
  infile1_m=path_to_data+filetoread_amp4_m
  infile1_h=path_to_data+filetoread_amp4_h
  ;expname="amip-m4K"
  infile2_l=path_to_data+filetoread_amm4_l
  infile2_m=path_to_data+filetoread_amm4_m
  infile2_h=path_to_data+filetoread_amm4_h
  ;expname="amip-future4K"
  infile6_l=path_to_data+filetoread_amfu_l
  infile6_m=path_to_data+filetoread_amfu_m
  infile6_h=path_to_data+filetoread_amfu_h
  ;expname="historical coupled"
  infile3_l=path_to_data+filetoread_his_l
  infile3_m=path_to_data+filetoread_his_m
  infile3_h=path_to_data+filetoread_his_h
  infile3_e_l=path_to_data+filetoread_his_early_l
  infile3_e_m=path_to_data+filetoread_his_early_m
  infile3_e_h=path_to_data+filetoread_his_early_h
  ;expname="abrupt 4xCO2 coupled"
  infile4_l=path_to_data+filetoread_4xCO2_l
  infile4_m=path_to_data+filetoread_4xCO2_m
  infile4_h=path_to_data+filetoread_4xCO2_h
  ;expname="1pctCO2 coupled"
  infile5_l=path_to_data+filetoread_1pctCO2a_l
  infile5_m=path_to_data+filetoread_1pctCO2a_m
  infile5_h=path_to_data+filetoread_1pctCO2a_h
;
; read data

; amip
  endi=431
;  starti=endi-120 ; if only plotting 10 years
  starti=0
print("amip data is: "+infile_l)
  data_l = addfile(infile_l,"r")
  data_m = addfile(infile_m,"r")
  data_h = addfile(infile_h,"r")

  var_l_10yr = data_l->$varname1$(starti:endi,:,:) ; low clouds from exp a
  var_l_tmn=dim_avg_n(var_l_10yr,0) ; average over time
  var_m_10yr = data_m->$varname2$(starti:endi,:,:) ; low clouds from exp a
  var_m_tmn=dim_avg_n(var_m_10yr,0) ; average over time
  var_h_10yr = data_h->$varname3$(starti:endi,:,:) ; low clouds from exp a
  var_h_tmn=dim_avg_n(var_h_10yr,0) ; average over time

  var_l_ztmn=dim_avg_n(var_l_tmn,1)
  var_m_ztmn=dim_avg_n(var_m_tmn,1)
  var_h_ztmn=dim_avg_n(var_h_tmn,1)

  var_l_full = data_l->$varname1$(:,:,:) ; low clouds from exp a
  var_l_tmn=dim_avg_n(var_l_full,0) ; average over time
  var_m_full = data_m->$varname2$(:,:,:) ; low clouds from exp a
  var_m_tmn=dim_avg_n(var_m_full,0) ; average over time
  var_h_full = data_h->$varname3$(:,:,:) ; low clouds from exp a
  var_h_tmn=dim_avg_n(var_h_full,0) ; average over time

  var_l_full_ztmn=dim_avg_n(var_l_tmn,1)
  var_m_full_ztmn=dim_avg_n(var_m_tmn,1)
  var_h_full_ztmn=dim_avg_n(var_h_tmn,1)

print("dimsizes of amip data are: "+dimsizes(var_l_full))

; amip-p4K
print("amip +4K data is: "+infile1_l)
  data_1_l = addfile(infile1_l,"r")
  data_1_m = addfile(infile1_m,"r")
  data_1_h = addfile(infile1_h,"r")
print("what is this file name>? "+infile1_m)

  ; read latitude dimensions from model
  latitude=data_1_l->lat(:)

  var1_l_full = data_1_l->$varname1$(:,:,:) ; low clouds from exp a
print("dimsizes of amip p4k data are: "+dimsizes(var1_l_full))
  var1_l_tmn=dim_avg_n(var1_l_full,0) ; average over time
  var1_m_full = data_1_m->$varname2$(:,:,:) ; mid clouds from exp a
  var1_m_tmn=dim_avg_n(var1_m_full,0)
  var1_h_full = data_1_h->$varname3$(:,:,:) ; high clouds from exp a
  var1_h_tmn=dim_avg_n(var1_h_full,0)

  var1_l_ztmn=dim_avg_n(var1_l_tmn,1)
  var1_m_ztmn=dim_avg_n(var1_m_tmn,1)
  var1_h_ztmn=dim_avg_n(var1_h_tmn,1)

; amip-future4K
print("future-4K data is: "+infile6_l)
  data_6_l = addfile(infile6_l,"r")
  data_6_m = addfile(infile6_m,"r")
  data_6_h = addfile(infile6_h,"r")

  var6_l_full = data_6_l->$varname1$(:,:,:) ; low clouds from exp a
  var6_l_tmn=dim_avg_n(var6_l_full,0) ; average over time
  var6_m_full = data_6_m->$varname2$(:,:,:) ; mid clouds from exp a
  var6_m_tmn=dim_avg_n(var6_m_full,0)
  var6_h_full = data_6_h->$varname3$(:,:,:) ; high clouds from exp a
  var6_h_tmn=dim_avg_n(var6_h_full,0)

  var6_l_ztmn=dim_avg_n(var6_l_tmn,1)
  var6_m_ztmn=dim_avg_n(var6_m_tmn,1)
  var6_h_ztmn=dim_avg_n(var6_h_tmn,1)

; amip-m4K
print("amip -4K data is: "+infile2_l)
  data_2_l = addfile(infile2_l,"r")
  data_2_m = addfile(infile2_m,"r")
  data_2_h = addfile(infile2_h,"r")

  var2_l_full = data_2_l->$varname1$(:,:,:) ; low clouds from exp a
  var2_l_tmn=dim_avg_n(var2_l_full,0) ; average over time
  var2_m_full = data_2_m->$varname2$(:,:,:) ; mid clouds from exp a
  var2_m_tmn=dim_avg_n(var2_m_full,0)
  var2_h_full = data_2_h->$varname3$(:,:,:) ; high clouds from exp a
  var2_h_tmn=dim_avg_n(var2_h_full,0)

  var2_l_ztmn=dim_avg_n(var2_l_tmn,1)
  var2_m_ztmn=dim_avg_n(var2_m_tmn,1)
  var2_h_ztmn=dim_avg_n(var2_h_tmn,1)

; historical  (eventually I probably want to compare only with the amip years...)
  data_3_l = addfile(infile3_l,"r")
  data_3_m = addfile(infile3_m,"r")
  data_3_h = addfile(infile3_h,"r")
  data_3_e_l = addfile(infile3_e_l,"r")
  data_3_e_m = addfile(infile3_e_m,"r")
  data_3_e_h = addfile(infile3_e_h,"r")

; data from pre-industrial control experiment
  data_pic_l = addfile(infile_pic_l,"r")
  data_pic_m = addfile(infile_pic_m,"r")
  data_pic_h = addfile(infile_pic_h,"r")

; 120 months equal 10 years
; period 1 (1850-1949) has 1200 months
; period 2 (1950-2014) has 780 months
  endi=779
  ;starti=endi-120
  var3_l_10yr = data_3_l->$varname1$(starti:endi,:,:) ; low clouds from exp a
  ;var3_l_10yrfull = data_3_l->$varname1$(:,:,:) ; low clouds from exp a
  ;print("dimensions of historical file: "+dimsizes(var3_l_10yrfull))
  var3_l_tmn=dim_avg_n(var3_l_10yr,0) ; average over time
  var3_m_10yr = data_3_m->$varname2$(starti:endi,:,:) ; mid clouds from exp a
  var3_m_tmn=dim_avg_n(var3_m_10yr,0)
  var3_h_10yr = data_3_h->$varname3$(starti:endi,:,:) ; high clouds from exp a
 ;printVarSummary(var3_h_10yr)
  var3_h_tmn=dim_avg_n(var3_h_10yr,0)

  var3_l_ztmn=dim_avg_n(var3_l_tmn,1)
  var3_m_ztmn=dim_avg_n(var3_m_tmn,1)
  var3_h_ztmn=dim_avg_n(var3_h_tmn,1)

; historical long
  var3_l_full = data_3_l->$varname1$(:,:,:) ; low clouds from exp a
  var3_m_full = data_3_m->$varname2$(:,:,:) ; mid clouds from exp a
  var3_h_full = data_3_h->$varname3$(:,:,:) ; high clouds from exp a

  var3_l_f_tmn=dim_avg_n(var3_l_full,0) ; average over time
  var3_m_f_tmn=dim_avg_n(var3_m_full,0)
  var3_h_f_tmn=dim_avg_n(var3_h_full,0)

  var3_l_full_ztmn=dim_avg_n(var3_l_f_tmn,1)
  var3_m_full_ztmn=dim_avg_n(var3_m_f_tmn,1)
  var3_h_full_ztmn=dim_avg_n(var3_h_f_tmn,1)

; historical early (1850-1949) 
  var3_e_l_full = data_3_e_l->$varname1$(:,:,:) ; low clouds from exp a
  var3_e_m_full = data_3_e_m->$varname2$(:,:,:) ; mid clouds from exp a
  var3_e_h_full = data_3_e_h->$varname3$(:,:,:) ; high clouds from exp a

  var3_l_ef_tmn=dim_avg_n(var3_e_l_full,0) ; average over time
  var3_m_ef_tmn=dim_avg_n(var3_e_m_full,0)
  var3_h_ef_tmn=dim_avg_n(var3_e_h_full,0)

  var3_l_efull_ztmn=dim_avg_n(var3_l_ef_tmn,1)
  var3_m_efull_ztmn=dim_avg_n(var3_m_ef_tmn,1)
  var3_h_efull_ztmn=dim_avg_n(var3_h_ef_tmn,1)

; abrupt 4xCO2
  data_4_l = addfile(infile4_l,"r")
  data_4_m = addfile(infile4_m,"r")
  data_4_h = addfile(infile4_h,"r")

  var4_l_full = data_4_l->$varname1$(:,:,:) ; low clouds from exp a
  var4_l_tmn=dim_avg_n(var4_l_full,0) ; average over time
  var4_m_full = data_4_m->$varname2$(:,:,:) ; mid clouds from exp a
  var4_m_tmn=dim_avg_n(var4_m_full,0)
  var4_h_full = data_4_h->$varname3$(:,:,:) ; high clouds from exp a
  var4_h_tmn=dim_avg_n(var4_h_full,0)

  var4_l_ztmn=dim_avg_n(var4_l_tmn,1)
  var4_m_ztmn=dim_avg_n(var4_m_tmn,1)
  var4_h_ztmn=dim_avg_n(var4_h_tmn,1)

; ramp 1pctCO2

  startmon=840
  endmon=1199
  data_5_l = addfile(infile5_l,"r")
  data_5_m = addfile(infile5_m,"r")
  data_5_h = addfile(infile5_h,"r")

  var5_l_full = data_5_l->$varname1$(startmon:endmon,:,:) ; low clouds from exp a
  var5_l_tmn=dim_avg_n(var5_l_full,0) ; average over time
  var5_m_full = data_5_m->$varname2$(startmon:endmon,:,:) ; mid clouds from exp a
  var5_m_tmn=dim_avg_n(var5_m_full,0)
  var5_h_full = data_5_h->$varname3$(startmon:endmon,:,:) ; high clouds from exp a
  var5_h_tmn=dim_avg_n(var5_h_full,0)

  var5_l_ztmn=dim_avg_n(var5_l_tmn,1)
  var5_m_ztmn=dim_avg_n(var5_m_tmn,1)
  var5_h_ztmn=dim_avg_n(var5_h_tmn,1)

; pre industrial control

  var_pic_l_full = data_pic_l->$varname1$(:,:,:) ; low clouds from exp a
  var_pic_l_tmn=dim_avg_n(var_pic_l_full,0) ; average over time
  var_pic_m_full = data_pic_m->$varname2$(:,:,:) ; mid clouds from exp a
  var_pic_m_tmn=dim_avg_n(var_pic_m_full,0)
  var_pic_h_full = data_pic_h->$varname3$(:,:,:) ; high clouds from exp a
  var_pic_h_tmn=dim_avg_n(var_pic_h_full,0)

  var_pic_l_ztmn=dim_avg_n(var_pic_l_tmn,1)
  var_pic_m_ztmn=dim_avg_n(var_pic_m_tmn,1)
  var_pic_h_ztmn=dim_avg_n(var_pic_h_tmn,1)


print("dimsizes of 1pctCO2 data are: "+dimsizes(var5_l_full))

;*************************************************************

; compute bias of cloud fields relative to a particular control exp.

;cont_exp=amip (var_l_ztmn, var_m_ztmn, var_h_ztmn)
; if amip is desired to be the control against which a bias is computed...

  if (controlexp .gt. 0) then ; use piControl as control
    cont_l=var_pic_l_ztmn
    cont_m=var_pic_m_ztmn
    cont_h=var_pic_h_ztmn
  else ; default case is to use amip as control, controlexp=0
    cont_l=var_l_ztmn
    cont_m=var_m_ztmn
    cont_h=var_h_ztmn
  end if 
 
;  plotbias=1  ; plotbias = 0 is default and corresponds to plotting climatology
  if (plotbias .gt. 0) then
    var_l_ztmn=var_l_ztmn-cont_l
    var_m_ztmn=var_m_ztmn-cont_m
    var_h_ztmn=var_h_ztmn-cont_h

    var_l_full_ztmn=var_l_full_ztmn-cont_l
    var_m_full_ztmn=var_m_full_ztmn-cont_m
    var_h_full_ztmn=var_h_full_ztmn-cont_h

    var1_l_ztmn=var1_l_ztmn-cont_l
    var1_m_ztmn=var1_m_ztmn-cont_m
    var1_h_ztmn=var1_h_ztmn-cont_h
    
    var2_l_ztmn=var2_l_ztmn-cont_l
    var2_m_ztmn=var2_m_ztmn-cont_m
    var2_h_ztmn=var2_h_ztmn-cont_h
    
    var3_l_ztmn=var3_l_ztmn-cont_l
    var3_m_ztmn=var3_m_ztmn-cont_m
    var3_h_ztmn=var3_h_ztmn-cont_h
    
    var3_l_full_ztmn=var3_l_full_ztmn-cont_l
    var3_m_full_ztmn=var3_m_full_ztmn-cont_m
    var3_h_full_ztmn=var3_h_full_ztmn-cont_h
    
    var3_l_efull_ztmn=var3_l_efull_ztmn-cont_l
    var3_m_efull_ztmn=var3_m_efull_ztmn-cont_m
    var3_h_efull_ztmn=var3_h_efull_ztmn-cont_h
    
    var4_l_ztmn=var4_l_ztmn-cont_l
    var4_m_ztmn=var4_m_ztmn-cont_m
    var4_h_ztmn=var4_h_ztmn-cont_h
    
    var5_l_ztmn=var5_l_ztmn-cont_l
    var5_m_ztmn=var5_m_ztmn-cont_m
    var5_h_ztmn=var5_h_ztmn-cont_h
    
    var6_l_ztmn=var6_l_ztmn-cont_l
    var6_m_ztmn=var6_m_ztmn-cont_m
    var6_h_ztmn=var6_h_ztmn-cont_h

    var_pic_l_ztmn=var_pic_l_ztmn-cont_l
    var_pic_m_ztmn=var_pic_m_ztmn-cont_m
    var_pic_h_ztmn=var_pic_h_ztmn-cont_h
  end if

;*************************************************************
    ;relwidth = 0.5
    relwidth = 0.4
    relheight = 0.2

; these values indicate the positioning of the figures 
    figtop=0.9
    figmid=0.62
    figbot=0.34
    figl  =0.20
    ;figm  =0.35
    ;figr  =0.60

; set Font Sizes
txFontSize  = 0.011  ; was 0.015
tiYFontSize = 0.012   ; sets the font height in NDC coordinates for the Y-Axis title
tmYFontSize = 0.010  ; sets the height of the Y-Axis labels in NDC coordinates

;*************************************************************
    wksType = "eps"
    wks = gsn_open_wks(wksType,"testplot")          ; send graphics to ps file
    plot = new(3,graphic)
  
  ; resources for the panels, and the legend
    res                        = True
    lgres                      = True

    res@gsnDraw         = False
    res@gsnFrame         = False

    ;fontsize=0.03

    res@txFontHeightF      = txFontSize
    res@tiYAxisFontHeightF    = tiYFontSize
    res@tmYLLabelFontHeightF  = tmYFontSize
 
    res@vpWidthF     = relwidth
    res@vpHeightF    = relheight
  
    res@tiMainString = "Upper-Level Cloud Fraction"
    res@tiMainFont = 21
    res@tiMainFontHeightF = tiYFontSize
    res@tiYAxisString  = ytitle
    res@tiYAxisFont    = 21
    res@tiXAxisString  = "Latitude"
    res@tiXAxisFont    = 21
    res@tiXAxisFontHeightF = tiYFontSize

    res@tmYLLabelFontHeightF = tiYFontSize
    res@tmXBLabelFontHeightF = tiYFontSize
   
    lthick=3.0
    res@xyLineThicknessF     = lthick
    res@tmXBMode = "explicit"
    res@tmXBValues = (/-60,-30,0,30,60/)
    res@tmXBLabels = (/-60,-30,0,30,60/)
    res@tmXBMinorValues =(/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)

    colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3","red"/) 
    lgres@lgLineColors  = (/colors(1),colors(7),colors(2),colors(4),colors(5),colors(6),colors(0)/)
    lgres@lgDashIndexes = (/"0","0","0","0","0","0","0"/)
    labels = (/title_lg0,title_lg6,title_lg1,title_lg3,title_lg4,title_lg5,title_piC/) ; bottom to top

    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 15
      res@trYMaxF = 55
    end if

    res@tiXAxisString  = " "

    res@vpXF     = figl
    res@vpYF     = figtop

;    res@xyLineColors=colors(0)
;    plot0obs=gsn_csm_xy(wks,latitude_calip(:),var3calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    plot0a=gsn_csm_xy(wks,latitude(:),var_h_ztmn(:),res)
;    res@xyLineColors=colors(1)
;    plot0a_f=gsn_csm_xy(wks,latitude(:),var_h_full_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot0b=gsn_csm_xy(wks,latitude(:),var1_h_ztmn(:),res)
;    res@xyLineColors=colors(3)
;    plot0c=gsn_csm_xy(wks,latitude(:),var2_h_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot0d=gsn_csm_xy(wks,latitude(:),var3_h_ztmn(:),res)
;    res@xyLineColors=colors(4)
;    plot0d_f=gsn_csm_xy(wks,latitude(:),var3_h_full_ztmn(:),res)
;    res@xyLineColors=colors(4)
;    plot0d_ef=gsn_csm_xy(wks,latitude(:),var3_h_efull_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot0e=gsn_csm_xy(wks,latitude(:),var4_h_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot0f=gsn_csm_xy(wks,latitude(:),var5_h_ztmn(:),res)
    res@xyLineColors=colors(7)
    plot0g=gsn_csm_xy(wks,latitude(:),var6_h_ztmn(:),res)
    res@xyLineColors=colors(0)
    plot0h=gsn_csm_xy(wks,latitude(:),var_pic_h_ztmn(:),res)
;
;    overlay(plot0a,plot0b)    ; amip p4K
;    overlay(plot0a,plot0obs)  ; plot0a is usually not the full amip period, but 2005-2014
;    overlay(plot0a,plot0c)    ; amip m4K
;    ;overlay(plot0a,plot0d)    ; 2005-2014 of historical, i think
;    ;overlay(plot0a,plot0d_f) ; 1950-2014
;    ;overlay(plot0a,plot0d_ef); 1850-1949
;    overlay(plot0a,plot0a_f) ; full amip period
;    overlay(plot0a,plot0g)    ; amip future 4K
;    ;overlay(plot0a,plot0e)
;    ;overlay(plot0a,plot0f)
;    overlay(plot0a,plot0h)  ; picontrol

    plot(0)=plot0a

    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 0
      res@trYMaxF = 40
    end if

    res@tiXAxisString  = " "

    res@vpXF     = figl
    res@vpYF     = figmid

    res@tiMainString = "Mid-Level Cloud Fraction"
;    res@xyLineColors=colors(0)
;    plot1obs=gsn_csm_xy(wks,latitude_calip(:),var2calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    plot1a=gsn_csm_xy(wks,latitude(:),var_m_ztmn(:),res)
;    res@xyLineColors=colors(1)
;    plot1a_f=gsn_csm_xy(wks,latitude(:),var_m_full_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot1b=gsn_csm_xy(wks,latitude(:),var1_m_ztmn(:),res)
;    res@xyLineColors=colors(3)
;    plot1c=gsn_csm_xy(wks,latitude(:),var2_m_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot1d=gsn_csm_xy(wks,latitude(:),var3_m_ztmn(:),res)
;    res@xyLineColors=colors(4)
;    plot1d_f=gsn_csm_xy(wks,latitude(:),var3_m_full_ztmn(:),res)
;    res@xyLineColors=colors(4)
;    plot1d_ef=gsn_csm_xy(wks,latitude(:),var3_m_efull_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot1e=gsn_csm_xy(wks,latitude(:),var4_m_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot1f=gsn_csm_xy(wks,latitude(:),var5_m_ztmn(:),res)
    res@xyLineColors=colors(7)
    plot1g=gsn_csm_xy(wks,latitude(:),var6_m_ztmn(:),res)
    res@xyLineColors=colors(0)
    plot1h=gsn_csm_xy(wks,latitude(:),var_pic_m_ztmn(:),res)
;
;    overlay(plot1a,plot1b)  ; amip p4K
;    overlay(plot1a,plot1obs)
;    overlay(plot1a,plot1c)  ; amip m4k
;;    overlay(plot1a,plot1d)   ; 2005-2014
;    ;overlay(plot1a,plot1d_f)
;    ;overlay(plot1a,plot1d_ef)
;    overlay(plot1a,plot1a_f) ; full amip period
;    ;overlay(plot1a,plot1e)
;    overlay(plot1a,plot1g)
;    ;overlay(plot1a,plot1f)
;    overlay(plot1a,plot1h) ; picontrol

    plot(1)=plot1a

    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 5 
      res@trYMaxF = 75 
    end if

    res@tiXAxisString  = "Latitude"

    res@vpXF     = figl
    res@vpYF     = figbot

    res@tiMainString = "Low-Level Cloud Fraction"

;    res@xyLineColors=colors(0)
;    plot2obs=gsn_csm_xy(wks,latitude_calip(:),var1calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    plot2a=gsn_csm_xy(wks,latitude(:),var_l_ztmn(:),res)
;    plot2a_f=gsn_csm_xy(wks,latitude(:),var_l_full_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot2b=gsn_csm_xy(wks,latitude(:),var1_l_ztmn(:),res)
;    res@xyLineColors=colors(3)
;    plot2c=gsn_csm_xy(wks,latitude(:),var2_l_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot2d=gsn_csm_xy(wks,latitude(:),var3_l_ztmn(:),res)
;    res@xyLineColors=colors(4)
;    plot2d_f=gsn_csm_xy(wks,latitude(:),var3_l_full_ztmn(:),res)
;    plot2d_ef=gsn_csm_xy(wks,latitude(:),var3_l_efull_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot2e=gsn_csm_xy(wks,latitude(:),var4_l_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot2f=gsn_csm_xy(wks,latitude(:),var5_l_ztmn(:),res)
    res@xyLineColors=colors(7)
    plot2g=gsn_csm_xy(wks,latitude(:),var6_l_ztmn(:),res)
    res@xyLineColors=colors(0)
    plot2h=gsn_csm_xy(wks,latitude(:),var_pic_l_ztmn(:),res)

;    overlay(plot2a,plot2b)
;    overlay(plot2a,plot2obs)
;    overlay(plot2a,plot2c)
;    ;overlay(plot2a,plot2d)    ; 2005-2014
;    ;overlay(plot2a,plot2d_f)
;    ;overlay(plot2a,plot2d_ef)
;    overlay(plot2a,plot2a_f)
;    ;overlay(plot2a,plot2e)
;    overlay(plot2a,plot2g)
;    ;overlay(plot2a,plot2f)
;    overlay(plot2a,plot2h)

    plot(2)=plot2a


; add a legend
  if (includelegend .gt. 0) then
 
    lgres@xyLabelMode          = "Custom"
    lgres@lgAutoManage         = False
;    lgres@xyLineLabelFontHeightF = 0.30                ; font height
    lgres@lgItemType           = "Lines"
; when lgAutoManage is set to False, lgLabelFontHeight does seem to control the font height.  not so
; with xyLineLabelFontHeightF
    lgres@lgLabelFontHeightF   = 0.06; .05 works but is small .07 seems slightly too large  
    lgres@vpWidthF             = 0.13        ; width of legend
    lgres@vpHeightF            = 0.12      ; height of legend
    lgres@lgLineThicknessF     = lthick
    lgres@lgPerimThicknessF    = 2.0
    lgres@lgMonoDashIndex      = False 
    lgres@lgPerimOn            = False
   
   ; draw panel with white space added
    legend  = gsn_create_legend (wks, 7, labels, lgres)
    resP                 = True
    ;resP@amJust = "BottomRight"
    ;;resP@amParallelPosF   = 0.42    ; Move legend to right
    resP@amParallelPosF   = 0.33    ; Move legend to right
    resP@amOrthogonalPosF = -0.22     ; Move legend down
  
    annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
  end if

psres  = True
maximize_output(wks,psres)
  
;    gsn_panel(wks,plot,(/3,1/),resP)

end
