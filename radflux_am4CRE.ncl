;-------------------------------------------------------------------------
; radflux_am4CRE.ncl 
;-------------------------------------------------------------------------
;
; compute CRE as a function of latitude for particular CFMIP experiments
;
; feedbacks are also computed for these experiments using matlab
; glbmn_toa_cfmip_fb_driver.m which also uses
; glbmn_toa_cfmip_fb.m
;
; biases can be computed relative to either version of the CERES data
; or relative to the piControl experiment of CM4.0
;
; The cloud radiative effects are normalized for different experiments according
; to differing time periods.  I still need to determine an appropriate normalization
; for the 1pct CO2 ramp experiment and the two ceres profiles.  
;
; the temperature change of the air near the surface is not exactly 4K but:
; delT_amip_fut = 4.6816
; delT_amip_p4K = 4.4938
; delT_amip_m4K = 4.5217
; delT_aqua     = 4.1391
;
; levi silvers                                            mar 2020
;-------------------------------------------------------------------------

begin

path="/Users/silvers/data/cfmip_toafluxes/"

path_obs="/Users/silvers/data/SatData/CERES/"

; everything = 0; plotbias = 0 --> Panel on left, showing the raw CRE for CERES-EBAF, coupled experiments, and amip
; everything = 2; plotbias = 0 --> Panel on far right showing amip type feedback experiments


everything = 0 ; switch defining which profiles are plotted
; 0 plots the CRE from: ceres, amip, historical, abrupt, and 1pct
; 1 plots the shortwave, longwave, and net CRE for amip and aqua
; 2 plots CRE Feedback figure showing aqua and amip-based warming experiments

plotbias = 0 ; default is 0; for plotbias=1, a bias is plotted 

; years for the abrupt and ramp warming experiments
early="000101-010012"
late="010101-015012"

; years for the historical experiment
firsthalf="185001-194912"
seconhalf="195001-201412"

hist_yrs=seconhalf
warm_yrs=late
;
;  David has recommended that we use the years 1996-2015 for the historical 
;  and amip experiments to exclude some of the volcanic activity from the 
;  early 90's.  He doesn't have confidence in the GCMs ability to deal with
;  that period.  
;  The coupled runs from CMIP6 only extend through december of 2014, so 
;  we are likely looking at jan 1996 through dec 2014.  19 years, or 228 months.
;
;  as originally written, the historical files over the later periods cover 65 
;  years, which is 780 months. i want to grab the last 228 of them.  
lastmonth=779
timeper=228
firstmonth=lastmonth-timeper-1  
;
; since amip starts in 1979, the range is different...
; 432 months
lastmonth_amip = 431
firstmonth_amip=lastmonth_amip-timeper-1  
;-------------------------------------------------------------------------
; define variables borrowed from the matlab scripts: 
delT_amip_fut = 4.6816
delT_amip_p4K = 4.4938
delT_amip_m4K = 4.5217
delT_aqua     = 4.1391
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; for amip 
;-------------------------------------------------------------------------

; define filenames
filename="atmos_cmip.197901-201412.rsut.nc"
infile1=path+filename
filename="atmos_cmip.197901-201412.rsutcs.nc"
infile2=path+filename
filename="atmos_cmip.197901-201412.rlut.nc"
infile3=path+filename
filename="atmos_cmip.197901-201412.rlutcs.nc"
infile4=path+filename
filename="atmos_cmip.197901-201412.rsdt.nc"
infile5=path+filename

print("infile1 is: "+infile1)

; ceres data paths: 
filename="CERES_EBAF-TOA_Ed2.8_Subset_200003-201607.nc"
filename_4p1="CERES_EBAF_Ed4.1_Subset_200003-201809.nc"
infile_obs=path_obs+filename
infile_obs_4p1=path_obs+filename_4p1
print("infile_obs ceres v2.8 is: "+infile_obs)
print("infile_obs_4p1 ceres v4.1 is: "+infile_obs_4p1)

; read data
add_rsut=addfile(infile1,"r")
amip_rsut=add_rsut->rsut(firstmonth_amip:lastmonth_amip,:,:)
add_rsutcs=addfile(infile2,"r")
amip_rsutcs=add_rsutcs->rsutcs(firstmonth_amip:lastmonth_amip,:,:)
add_rlut=addfile(infile3,"r")
amip_rlut=add_rlut->rlut(firstmonth_amip:lastmonth_amip,:,:)
add_rlutcs=addfile(infile4,"r")
amip_rlutcs=add_rlutcs->rlutcs(firstmonth_amip:lastmonth_amip,:,:)
add_rsdt=addfile(infile5,"r")
amip_rsdt=add_rsdt->rsdt(firstmonth_amip:lastmonth_amip,:,:)

;-------------------------------------------------------------------------
; piControl
;-------------------------------------------------------------------------

; define filenames
filename="rsut_Amon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
infile_pic_1=path+filename
;filename="atmos_cmip.197901-201412.rsutcs.nc"
filename="rsutcs_Amon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
infile_pic_2=path+filename
filename="rlut_Amon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
;filename="atmos_cmip.197901-201412.rlut.nc"
infile_pic_3=path+filename
filename="rlutcs_Amon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
;filename="atmos_cmip.197901-201412.rlutcs.nc"
infile_pic_4=path+filename
filename="rsdt_Amon_GFDL-CM4_piControl_r1i1p1f1_gr1_025101-035012.nc"
;filename="atmos_cmip.197901-201412.rsdt.nc"
infile_pic_5=path+filename

; read data
add_rsut=addfile(infile_pic_1,"r")
pic_rsut=add_rsut->rsut(:,:,:)
add_rsutcs=addfile(infile_pic_2,"r")
pic_rsutcs=add_rsutcs->rsutcs(:,:,:)
add_rlut=addfile(infile_pic_3,"r")
pic_rlut=add_rlut->rlut(:,:,:)
add_rlutcs=addfile(infile_pic_4,"r")
pic_rlutcs=add_rlutcs->rlutcs(:,:,:)
add_rsdt=addfile(infile_pic_5,"r")
pic_rsdt=add_rsdt->rsdt(:,:,:)

;-------------------------------------------------------------------------


latitude=add_rsut->lat(:)

;----------- average data
amip_rsut_tmn=dim_avg_n(amip_rsut,0)
amip_rsut_tzmn=dim_avg_n(amip_rsut_tmn,1)

amip_rsutcs_tmn=dim_avg_n(amip_rsutcs,0)
amip_rsutcs_tzmn=dim_avg_n(amip_rsutcs_tmn,1)

amip_rlut_tmn=dim_avg_n(amip_rlut,0)
amip_rlut_tzmn=dim_avg_n(amip_rlut_tmn,1)

amip_rlutcs_tmn=dim_avg_n(amip_rlutcs,0)
amip_rlutcs_tzmn=dim_avg_n(amip_rlutcs_tmn,1)

amip_rsdt_tmn=dim_avg_n(amip_rsdt,0)
amip_rsdt_tzmn=dim_avg_n(amip_rsdt_tmn,1)

pic_rsut_tmn=dim_avg_n(pic_rsut,0)
pic_rsut_tzmn=dim_avg_n(pic_rsut_tmn,1)

pic_rsutcs_tmn=dim_avg_n(pic_rsutcs,0)
pic_rsutcs_tzmn=dim_avg_n(pic_rsutcs_tmn,1)

pic_rlut_tmn=dim_avg_n(pic_rlut,0)
pic_rlut_tzmn=dim_avg_n(pic_rlut_tmn,1)

pic_rlutcs_tmn=dim_avg_n(pic_rlutcs,0)
pic_rlutcs_tzmn=dim_avg_n(pic_rlutcs_tmn,1)

pic_rsdt_tmn=dim_avg_n(pic_rsdt,0)
pic_rsdt_tzmn=dim_avg_n(pic_rsdt_tmn,1)

print("dimensions of amip_rsut are: "+dimsizes(amip_rsut))
print("dimensions of pic_rsut are:  "+dimsizes(pic_rsut))

;------------ calculate CRE: cloud radiative effect
; for amip
cre_lw_amip=amip_rlut_tzmn-amip_rlutcs_tzmn
cre_sw_amip=amip_rsut_tzmn-amip_rsutcs_tzmn
cre_net_amip=cre_sw_amip+cre_lw_amip

cre_lw_amip_tmn =amip_rlut_tmn-amip_rlutcs_tmn
cre_sw_amip_tmn  =amip_rsut_tmn-amip_rsutcs_tmn
cre_net_amip_tmn =cre_sw_amip_tmn+cre_lw_amip_tmn

cre_lw_amip!0="lat"
cre_lw_amip&lat=amip_rsut&lat

cre_sw_amip!0="lat"
cre_sw_amip&lat=amip_rsut&lat

cre_net_amip!0="lat"
cre_net_amip&lat=amip_rsut&lat

cre_lw_amip_tmn!0="lat"
cre_lw_amip_tmn&lat=amip_rsut&lat
cre_lw_amip_tmn!1="lon"
cre_lw_amip_tmn&lon=amip_rsut&lon

cre_sw_amip_tmn!0="lat"
cre_sw_amip_tmn&lat=amip_rsut&lat
cre_sw_amip_tmn!1="lon"
cre_sw_amip_tmn&lon=amip_rsut&lon

cre_net_amip_tmn!0="lat"
cre_net_amip_tmn&lat=amip_rsut&lat
cre_net_amip_tmn!1="lon"
cre_net_amip_tmn&lon=amip_rsut&lon

; for pic
cre_lw_pic=pic_rlut_tzmn-pic_rlutcs_tzmn
cre_sw_pic=pic_rsut_tzmn-pic_rsutcs_tzmn
cre_net_pic=cre_sw_pic+cre_lw_pic

cre_lw_pic_tmn =pic_rlut_tmn-pic_rlutcs_tmn
cre_sw_pic_tmn  =pic_rsut_tmn-pic_rsutcs_tmn
cre_net_pic_tmn =cre_sw_pic_tmn+cre_lw_pic_tmn

cre_lw_pic!0="lat"
cre_lw_pic&lat=pic_rsut&lat

cre_sw_pic!0="lat"
cre_sw_pic&lat=pic_rsut&lat

cre_net_pic!0="lat"
cre_net_pic&lat=pic_rsut&lat

cre_lw_pic_tmn!0="lat"
cre_lw_pic_tmn&lat=pic_rsut&lat
cre_lw_pic_tmn!1="lon"
cre_lw_pic_tmn&lon=pic_rsut&lon

cre_sw_pic_tmn!0="lat"
cre_sw_pic_tmn&lat=pic_rsut&lat
cre_sw_pic_tmn!1="lon"
cre_sw_pic_tmn&lon=pic_rsut&lon

cre_net_pic_tmn!0="lat"
cre_net_pic_tmn&lat=pic_rsut&lat
cre_net_pic_tmn!1="lon"
cre_net_pic_tmn&lon=pic_rsut&lon

;-------------------------------------------------------------------------
;---------------------------------------------------------------------
; ceres data read below
;---------------------------------------------------------------------
  crs = addfile(infile_obs,"r")
varname1="toa_cre_sw_mon"
varname2="toa_cre_lw_mon"
varname3="toa_cre_net_mon"
ceres_swcre = crs->$varname1$(:,:,:)
ceres_lwcre = crs->$varname2$(:,:,:)
ceres_netcre = crs->$varname3$(:,:,:)

print("dims before averaging "+dimsizes(ceres_swcre))
ceres_swcre_tmn  =dim_avg_n(ceres_swcre,0)
ceres_lwcre_tmn  =dim_avg_n(ceres_lwcre,0)
ceres_netcre_tmn =dim_avg_n(ceres_netcre,0)
print("dims after averaging "+dimsizes(ceres_swcre_tmn))

;
  crs_4p1 = addfile(infile_obs_4p1,"r")
varname1="toa_sw_all_mon"
varname2="toa_sw_clr_t_mon"; what is the difference between the clr_t and clr_c vars?
;varname2="toa_sw_clr_c_mon"; what is the difference between the clr_t and clr_c vars?
varname3="toa_lw_all_mon"
varname4="toa_lw_clr_t_mon"
;varname4="toa_lw_clr_c_mon"
ceres_sw_all = crs_4p1->$varname1$(:,:,:)
ceres_sw_clr = crs_4p1->$varname2$(:,:,:)
ceres_lw_all = crs_4p1->$varname3$(:,:,:)
ceres_lw_clr = crs_4p1->$varname4$(:,:,:)

ceres_lw_cre=-ceres_lw_all+ceres_lw_clr
ceres_lw_cre_tmn=dim_avg_n(ceres_lw_cre,0)
ceres_sw_cre=-ceres_sw_all+ceres_sw_clr
ceres_sw_cre_tmn=dim_avg_n(ceres_sw_cre,0)

ceres_2p8_cre=ceres_netcre_tmn
;ceres_2p8_cre=ceres_lwcre_tmn+ceres_swcre_tmn
ceres_4p1_cre=ceres_lw_cre_tmn+ceres_sw_cre_tmn

; ceres data is at a higher resolution (180x360 than) so we need to interpolate 
; CERES to the AM4 grid if we want to plot global maps

ceres_2p8_cre_ztmn=dim_avg_n(ceres_2p8_cre,1)
ceres_4p1_cre_ztmn=dim_avg_n(ceres_4p1_cre,1)

;;-------------------------------------------------------------------------
;; compute global mean values of data from ceres and am4
;;-------------------------------------------------------------------------
;lat      = crs->lat
;latitude = crs->lat
;rad      = 4.0*atan(1.0)/180.0
;clat     = cos(lat*rad)
;
;ceres_2p8_ave=wgt_areaave(ceres_2p8_cre,clat,1.0,0)
;ceres_4p1_ave=wgt_areaave(ceres_4p1_cre,clat,1.0,0)
;
;print("mean of ceres 2p8: "+dim_avg_n(ceres_2p8_cre_ztmn,0))
;print("w mean of ceres 2p8: "+ceres_2p8_ave)
;print("mean of ceres 4p1: "+dim_avg_n(ceres_4p1_cre_ztmn,0))
;print("w mean of ceres 4p1: "+ceres_4p1_ave)
;;printVarSummary(var_to_interpolate)
;-------------------------------------------------------------------------
; for amip m4K
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_amip-m4K_r1i1p1f1_gr1_197901-201412.nc"
infile5=path+filename

print("infile1 is: "+infile1)

; read data
add_rsut_m4K=addfile(infile1,"r")
amip_rsut_m4K=add_rsut_m4K->rsut(:,:,:)
add_rsutcs_m4K=addfile(infile2,"r")
amip_rsutcs_m4K=add_rsutcs_m4K->rsutcs(:,:,:)
add_rlut_m4K=addfile(infile3,"r")
amip_rlut_m4K=add_rlut_m4K->rlut(:,:,:)
add_rlutcs_m4K=addfile(infile4,"r")
amip_rlutcs_m4K=add_rlutcs_m4K->rlutcs(:,:,:)
add_rsdt_m4K=addfile(infile5,"r")
amip_rsdt_m4K=add_rsdt_m4K->rsdt(:,:,:)

; average data
amip_rsut_m4K_tmn=dim_avg_n(amip_rsut_m4K,0)
amip_rsut_m4K_tzmn=dim_avg_n(amip_rsut_m4K_tmn,1)
amip_rsutcs_m4K_tmn=dim_avg_n(amip_rsutcs_m4K,0)
amip_rsutcs_m4K_tzmn=dim_avg_n(amip_rsutcs_m4K_tmn,1)
amip_rlut_m4K_tmn=dim_avg_n(amip_rlut_m4K,0)
amip_rlut_m4K_tzmn=dim_avg_n(amip_rlut_m4K_tmn,1)
amip_rlutcs_m4K_tmn=dim_avg_n(amip_rlutcs_m4K,0)
amip_rlutcs_m4K_tzmn=dim_avg_n(amip_rlutcs_m4K_tmn,1)
amip_rsdt_m4K_tmn=dim_avg_n(amip_rsdt_m4K,0)
amip_rsdt_m4K_tzmn=dim_avg_n(amip_rsdt_m4K_tmn,1)

;print("dimensions of amip_rsut_m4k are: "+dimsizes(amip_rsut_m4K))
;print("dimensions of amip_rsut_m4k_tmn are: "+dimsizes(amip_rsut_m4K_tmn))
;print("dimensions of amip_rsut_m4k_tzmn are: "+dimsizes(amip_rsut_m4K_tzmn))

; calculate CRE: cloud radiative effect
cre_lw_amip_m4K=amip_rlut_m4K_tzmn-amip_rlutcs_m4K_tzmn
cre_sw_amip_m4K=amip_rsut_m4K_tzmn-amip_rsutcs_m4K_tzmn
cre_net_amip_m4K=cre_sw_amip_m4K+cre_lw_amip_m4K

cre_lw_amip_m4K_tmn =amip_rlut_m4K_tmn-amip_rlutcs_m4K_tmn
cre_sw_amip_m4K_tmn  =amip_rsut_m4K_tmn-amip_rsutcs_m4K_tmn
cre_net_amip_m4K_tmn =cre_sw_amip_m4K_tmn+cre_lw_amip_m4K_tmn

cre_lw_amip_m4K!0="lat"
cre_lw_amip_m4K&lat=amip_rsut_m4K&lat

cre_sw_amip_m4K!0="lat"
cre_sw_amip_m4K&lat=amip_rsut_m4K&lat

cre_net_amip_m4K!0="lat"
cre_net_amip_m4K&lat=amip_rsut_m4K&lat

cre_lw_amip_m4K_tmn!0="lat"
cre_lw_amip_m4K_tmn&lat=amip_rsut_m4K&lat
cre_lw_amip_m4K_tmn!1="lon"
cre_lw_amip_m4K_tmn&lon=amip_rsut_m4K&lon

cre_sw_amip_m4K_tmn!0="lat"
cre_sw_amip_m4K_tmn&lat=amip_rsut_m4K&lat
cre_sw_amip_m4K_tmn!1="lon"
cre_sw_amip_m4K_tmn&lon=amip_rsut_m4K&lon

cre_net_amip_m4K_tmn!0="lat"
cre_net_amip_m4K_tmn&lat=amip_rsut_m4K&lat
cre_net_amip_m4K_tmn!1="lon"
cre_net_amip_m4K_tmn&lon=amip_rsut_m4K&lon
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; for amip p4K
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
infile5=path+filename

; read data
add_rsut_p4K=addfile(infile1,"r")
amip_rsut_p4K=add_rsut_p4K->rsut(:,:,:)
add_rsutcs_p4K=addfile(infile2,"r")
amip_rsutcs_p4K=add_rsutcs_p4K->rsutcs(:,:,:)
add_rlut_p4K=addfile(infile3,"r")
amip_rlut_p4K=add_rlut_p4K->rlut(:,:,:)
add_rlutcs_p4K=addfile(infile4,"r")
amip_rlutcs_p4K=add_rlutcs_p4K->rlutcs(:,:,:)
add_rsdt_p4K=addfile(infile5,"r")
amip_rsdt_p4K=add_rsdt_p4K->rsdt(:,:,:)

; average data
amip_rsut_p4K_tmn=dim_avg_n(amip_rsut_p4K,0)
amip_rsut_p4K_tzmn=dim_avg_n(amip_rsut_p4K_tmn,1)
amip_rsutcs_p4K_tmn=dim_avg_n(amip_rsutcs_p4K,0)
amip_rsutcs_p4K_tzmn=dim_avg_n(amip_rsutcs_p4K_tmn,1)
amip_rlut_p4K_tmn=dim_avg_n(amip_rlut_p4K,0)
amip_rlut_p4K_tzmn=dim_avg_n(amip_rlut_p4K_tmn,1)
amip_rlutcs_p4K_tmn=dim_avg_n(amip_rlutcs_p4K,0)
amip_rlutcs_p4K_tzmn=dim_avg_n(amip_rlutcs_p4K_tmn,1)
amip_rsdt_p4K_tmn=dim_avg_n(amip_rsdt_p4K,0)
amip_rsdt_p4K_tzmn=dim_avg_n(amip_rsdt_p4K_tmn,1)

; calculate CRE: cloud radiative effect
cre_lw_amip_p4K=amip_rlut_p4K_tzmn-amip_rlutcs_p4K_tzmn
cre_sw_amip_p4K=amip_rsut_p4K_tzmn-amip_rsutcs_p4K_tzmn
cre_net_amip_p4K=cre_sw_amip_p4K+cre_lw_amip_p4K

cre_lw_amip_p4K_tmn=amip_rlut_p4K_tmn-amip_rlutcs_p4K_tmn
cre_sw_amip_p4K_tmn=amip_rsut_p4K_tmn-amip_rsutcs_p4K_tmn
cre_net_amip_p4K_tmn=cre_sw_amip_p4K_tmn+cre_lw_amip_p4K_tmn

cre_lw_amip_p4K!0="lat"
cre_lw_amip_p4K&lat=amip_rsut_p4K&lat

cre_sw_amip_p4K!0="lat"
cre_sw_amip_p4K&lat=amip_rsut_p4K&lat

cre_net_amip_p4K!0="lat"
cre_net_amip_p4K&lat=amip_rsut_p4K&lat

cre_lw_amip_p4K_tmn!0="lat"
cre_lw_amip_p4K_tmn&lat=amip_rsut_p4K&lat
cre_lw_amip_p4K_tmn!1="lon"
cre_lw_amip_p4K_tmn&lon=amip_rsut_p4K&lon

cre_sw_amip_p4K_tmn!0="lat"
cre_sw_amip_p4K_tmn&lat=amip_rsut_p4K&lat
cre_sw_amip_p4K_tmn!1="lon"
cre_sw_amip_p4K_tmn&lon=amip_rsut_p4K&lon

cre_net_amip_p4K_tmn!0="lat"
cre_net_amip_p4K_tmn&lat=amip_rsut_p4K&lat
cre_net_amip_p4K_tmn!1="lon"
cre_net_amip_p4K_tmn&lon=amip_rsut_p4K&lon
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; for amip future
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_amip-future4K_r1i1p1f1_gr1_197901-201412.nc"
infile5=path+filename

; read data
add_rsut_future4K=addfile(infile1,"r")
amip_rsut_future4K=add_rsut_future4K->rsut(:,:,:)
add_rsutcs_future4K=addfile(infile2,"r")
amip_rsutcs_future4K=add_rsutcs_future4K->rsutcs(:,:,:)
add_rlut_future4K=addfile(infile3,"r")
amip_rlut_future4K=add_rlut_future4K->rlut(:,:,:)
add_rlutcs_future4K=addfile(infile4,"r")
amip_rlutcs_future4K=add_rlutcs_future4K->rlutcs(:,:,:)
add_rsdt_future4K=addfile(infile5,"r")
amip_rsdt_future4K=add_rsdt_future4K->rsdt(:,:,:)

; average data
amip_rsut_future4K_tmn=dim_avg_n(amip_rsut_future4K,0)
amip_rsut_future4K_tzmn=dim_avg_n(amip_rsut_future4K_tmn,1)
amip_rsutcs_future4K_tmn=dim_avg_n(amip_rsutcs_future4K,0)
amip_rsutcs_future4K_tzmn=dim_avg_n(amip_rsutcs_future4K_tmn,1)
amip_rlut_future4K_tmn=dim_avg_n(amip_rlut_future4K,0)
amip_rlut_future4K_tzmn=dim_avg_n(amip_rlut_future4K_tmn,1)
amip_rlutcs_future4K_tmn=dim_avg_n(amip_rlutcs_future4K,0)
amip_rlutcs_future4K_tzmn=dim_avg_n(amip_rlutcs_future4K_tmn,1)
amip_rsdt_future4K_tmn=dim_avg_n(amip_rsdt_future4K,0)
amip_rsdt_future4K_tzmn=dim_avg_n(amip_rsdt_future4K_tmn,1)
;
; calculate CRE: cloud radiative effect
cre_lw_amip_future4K=amip_rlut_future4K_tzmn-amip_rlutcs_future4K_tzmn
cre_sw_amip_future4K=amip_rsut_future4K_tzmn-amip_rsutcs_future4K_tzmn
cre_net_amip_future4K=cre_sw_amip_future4K+cre_lw_amip_future4K

cre_lw_amip_future4K_tmn =amip_rlut_future4K_tmn-amip_rlutcs_future4K_tmn
cre_sw_amip_future4K_tmn  =amip_rsut_future4K_tmn-amip_rsutcs_future4K_tmn
cre_net_amip_future4K_tmn =cre_sw_amip_future4K_tmn+cre_lw_amip_future4K_tmn

cre_lw_amip_future4K!0="lat"
cre_lw_amip_future4K&lat=amip_rsut_future4K&lat
cre_sw_amip_future4K!0="lat"
cre_sw_amip_future4K&lat=amip_rsut_future4K&lat
cre_net_amip_future4K!0="lat"
cre_net_amip_future4K&lat=amip_rsut_future4K&lat

cre_lw_amip_future4K_tmn!0="lat"
cre_lw_amip_future4K_tmn&lat=amip_rsut_future4K&lat
cre_lw_amip_future4K_tmn!1="lon"
cre_lw_amip_future4K_tmn&lon=amip_rsut_future4K&lon

cre_sw_amip_future4K_tmn!0="lat"
cre_sw_amip_future4K_tmn&lat=amip_rsut_future4K&lat
cre_sw_amip_future4K_tmn!1="lon"
cre_sw_amip_future4K_tmn&lon=amip_rsut_future4K&lon

cre_net_amip_future4K_tmn!0="lat"
cre_net_amip_future4K_tmn&lat=amip_rsut_future4K&lat
cre_net_amip_future4K_tmn!1="lon"
cre_net_amip_future4K_tmn&lon=amip_rsut_future4K&lon
;
;-------------------------------------------------------------------------
;;-------------------------------------------------------------------------
; for historical
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_historical_r1i1p1f1_gr1_"+hist_yrs+".nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_historical_r1i1p1f1_gr1_"+hist_yrs+".nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_historical_r1i1p1f1_gr1_"+hist_yrs+".nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_historical_r1i1p1f1_gr1_"+hist_yrs+".nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_historical_r1i1p1f1_gr1_"+hist_yrs+".nc"
infile5=path+filename
;
;
;; read data
add_rsut_historical=addfile(infile1,"r")
h2_rsut_historical=add_rsut_historical->rsut(firstmonth:lastmonth,:,:)
add_rsutcs_historical=addfile(infile2,"r")
h2_rsutcs_historical=add_rsutcs_historical->rsutcs(firstmonth:lastmonth,:,:)
add_rlut_historical=addfile(infile3,"r")
h2_rlut_historical=add_rlut_historical->rlut(firstmonth:lastmonth,:,:)
add_rlutcs_historical=addfile(infile4,"r")
h2_rlutcs_historical=add_rlutcs_historical->rlutcs(firstmonth:lastmonth,:,:)
add_rsdt_historical=addfile(infile5,"r")
h2_rsdt_historical=add_rsdt_historical->rsdt(firstmonth:lastmonth,:,:)
;
;print("!@#$Q$#^#$^%&$^*")
;print("one of the historical files is: "+infile2)
;print("!@#$Q$#^#$^%&$^*")
;
;; average data
h2_rsut_historical_tmn=dim_avg_n(h2_rsut_historical,0)
h2_rsut_historical_tzmn=dim_avg_n(h2_rsut_historical_tmn,1)
h2_rsutcs_historical_tmn=dim_avg_n(h2_rsutcs_historical,0)
h2_rsutcs_historical_tzmn=dim_avg_n(h2_rsutcs_historical_tmn,1)
h2_rlut_historical_tmn=dim_avg_n(h2_rlut_historical,0)
h2_rlut_historical_tzmn=dim_avg_n(h2_rlut_historical_tmn,1)
h2_rlutcs_historical_tmn=dim_avg_n(h2_rlutcs_historical,0)
h2_rlutcs_historical_tzmn=dim_avg_n(h2_rlutcs_historical_tmn,1)
h2_rsdt_historical_tmn=dim_avg_n(h2_rsdt_historical,0)
h2_rsdt_historical_tzmn=dim_avg_n(h2_rsdt_historical_tmn,1)
;
;; calculate CRE: cloud radiative effect
cre_lw_h2_historical=h2_rlut_historical_tzmn-h2_rlutcs_historical_tzmn
cre_sw_h2_historical=h2_rsut_historical_tzmn-h2_rsutcs_historical_tzmn
cre_net_h2_historical=cre_sw_h2_historical+cre_lw_h2_historical
;
cre_lw_h2_historical!0="lat"
cre_lw_h2_historical&lat=h2_rsut_historical&lat
cre_sw_h2_historical!0="lat"
cre_sw_h2_historical&lat=h2_rsut_historical&lat
cre_net_h2_historical!0="lat"
cre_net_h2_historical&lat=h2_rsut_historical&lat
;
;;-------------------------------------------------------------------------
; for 1pctCO2 
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_1pctCO2_r1i1p1f1_gr1_010101-015012.nc"
infile5=path+filename
;
;; read data
add_rsut_1pctCO2=addfile(infile1,"r")
abr2_rsut_1pctCO2=add_rsut_1pctCO2->rsut(:,:,:)
add_rsutcs_1pctCO2=addfile(infile2,"r")
abr2_rsutcs_1pctCO2=add_rsutcs_1pctCO2->rsutcs(:,:,:)
add_rlut_1pctCO2=addfile(infile3,"r")
abr2_rlut_1pctCO2=add_rlut_1pctCO2->rlut(:,:,:)
add_rlutcs_1pctCO2=addfile(infile4,"r")
abr2_rlutcs_1pctCO2=add_rlutcs_1pctCO2->rlutcs(:,:,:)
add_rsdt_1pctCO2=addfile(infile5,"r")
abr2_rsdt_1pctCO2=add_rsdt_1pctCO2->rsdt(:,:,:)

;; average data
abr2_rsut_1pctCO2_tmn=dim_avg_n(abr2_rsut_1pctCO2,0)
abr2_rsut_1pctCO2_tzmn=dim_avg_n(abr2_rsut_1pctCO2_tmn,1)
abr2_rsutcs_1pctCO2_tmn=dim_avg_n(abr2_rsutcs_1pctCO2,0)
abr2_rsutcs_1pctCO2_tzmn=dim_avg_n(abr2_rsutcs_1pctCO2_tmn,1)
abr2_rlut_1pctCO2_tmn=dim_avg_n(abr2_rlut_1pctCO2,0)
abr2_rlut_1pctCO2_tzmn=dim_avg_n(abr2_rlut_1pctCO2_tmn,1)
abr2_rlutcs_1pctCO2_tmn=dim_avg_n(abr2_rlutcs_1pctCO2,0)
abr2_rlutcs_1pctCO2_tzmn=dim_avg_n(abr2_rlutcs_1pctCO2_tmn,1)
abr2_rsdt_1pctCO2_tmn=dim_avg_n(abr2_rsdt_1pctCO2,0)
abr2_rsdt_1pctCO2_tzmn=dim_avg_n(abr2_rsdt_1pctCO2_tmn,1)
;
;; calculate CRE: cloud radiative effect
cre_lw_1pct=abr2_rlut_1pctCO2_tzmn-abr2_rlutcs_1pctCO2_tzmn
cre_sw_1pct=abr2_rsut_1pctCO2_tzmn-abr2_rsutcs_1pctCO2_tzmn
cre_net_1pct=cre_sw_1pct+cre_lw_1pct
;
cre_lw_1pct!0="lat"
cre_lw_1pct&lat=abr2_rsut_1pctCO2&lat
cre_sw_1pct!0="lat"
cre_sw_1pct&lat=abr2_rsut_1pctCO2&lat
cre_net_1pct!0="lat"
cre_net_1pct&lat=abr2_rsut_1pctCO2&lat
;
;;-------------------------------------------------------------------------
; for abrupt 4xCO2 
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_"+warm_yrs+".nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_"+warm_yrs+".nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_"+warm_yrs+".nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_"+warm_yrs+".nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_abrupt-4xCO2_r1i1p1f1_gr1_"+warm_yrs+".nc"
infile5=path+filename
;
;; read data
add_rsut_abrupt4xCO2=addfile(infile1,"r")
abr2_rsut_abrupt4xCO2=add_rsut_abrupt4xCO2->rsut(:,:,:)
add_rsutcs_abrupt4xCO2=addfile(infile2,"r")
abr2_rsutcs_abrupt4xCO2=add_rsutcs_abrupt4xCO2->rsutcs(:,:,:)
add_rlut_abrupt4xCO2=addfile(infile3,"r")
abr2_rlut_abrupt4xCO2=add_rlut_abrupt4xCO2->rlut(:,:,:)
add_rlutcs_abrupt4xCO2=addfile(infile4,"r")
abr2_rlutcs_abrupt4xCO2=add_rlutcs_abrupt4xCO2->rlutcs(:,:,:)
add_rsdt_abrupt4xCO2=addfile(infile5,"r")
abr2_rsdt_abrupt4xCO2=add_rsdt_abrupt4xCO2->rsdt(:,:,:)
;
;; average data
abr2_rsut_abrupt4xCO2_tmn=dim_avg_n(abr2_rsut_abrupt4xCO2,0)
abr2_rsut_abrupt4xCO2_tzmn=dim_avg_n(abr2_rsut_abrupt4xCO2_tmn,1)
abr2_rsutcs_abrupt4xCO2_tmn=dim_avg_n(abr2_rsutcs_abrupt4xCO2,0)
abr2_rsutcs_abrupt4xCO2_tzmn=dim_avg_n(abr2_rsutcs_abrupt4xCO2_tmn,1)
abr2_rlut_abrupt4xCO2_tmn=dim_avg_n(abr2_rlut_abrupt4xCO2,0)
abr2_rlut_abrupt4xCO2_tzmn=dim_avg_n(abr2_rlut_abrupt4xCO2_tmn,1)
abr2_rlutcs_abrupt4xCO2_tmn=dim_avg_n(abr2_rlutcs_abrupt4xCO2,0)
abr2_rlutcs_abrupt4xCO2_tzmn=dim_avg_n(abr2_rlutcs_abrupt4xCO2_tmn,1)
abr2_rsdt_abrupt4xCO2_tmn=dim_avg_n(abr2_rsdt_abrupt4xCO2,0)
abr2_rsdt_abrupt4xCO2_tzmn=dim_avg_n(abr2_rsdt_abrupt4xCO2_tmn,1)
;
;; calculate CRE: cloud radiative effect
cre_lw_abr2=abr2_rlut_abrupt4xCO2_tzmn-abr2_rlutcs_abrupt4xCO2_tzmn
cre_sw_abr2=abr2_rsut_abrupt4xCO2_tzmn-abr2_rsutcs_abrupt4xCO2_tzmn
cre_net_abr2=cre_sw_abr2+cre_lw_abr2
;
cre_lw_abr2!0="lat"
cre_lw_abr2&lat=abr2_rsut_abrupt4xCO2&lat
cre_sw_abr2!0="lat"
cre_sw_abr2&lat=abr2_rsut_abrupt4xCO2&lat
cre_net_abr2!0="lat"
cre_net_abr2&lat=abr2_rsut_abrupt4xCO2&lat
;
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; for aqua control 
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_aqua-control_r1i1p1f1_gr1_198001-198912.nc"
infile5=path+filename

; read data
add_rsut_aqua=addfile(infile1,"r")
amip_rsut_aqua=add_rsut_aqua->rsut(:,:,:)
add_rsutcs_aqua=addfile(infile2,"r")
amip_rsutcs_aqua=add_rsutcs_aqua->rsutcs(:,:,:)
add_rlut_aqua=addfile(infile3,"r")
amip_rlut_aqua=add_rlut_aqua->rlut(:,:,:)
add_rlutcs_aqua=addfile(infile4,"r")
amip_rlutcs_aqua=add_rlutcs_aqua->rlutcs(:,:,:)
add_rsdt_aqua=addfile(infile5,"r")
amip_rsdt_aqua=add_rsdt_aqua->rsdt(:,:,:)

; average data
amip_rsut_aqua_tmn=dim_avg_n(amip_rsut_aqua,0)
amip_rsut_aqua_tzmn=dim_avg_n(amip_rsut_aqua_tmn,1)
amip_rsutcs_aqua_tmn=dim_avg_n(amip_rsutcs_aqua,0)
amip_rsutcs_aqua_tzmn=dim_avg_n(amip_rsutcs_aqua_tmn,1)
amip_rlut_aqua_tmn=dim_avg_n(amip_rlut_aqua,0)
amip_rlut_aqua_tzmn=dim_avg_n(amip_rlut_aqua_tmn,1)
amip_rlutcs_aqua_tmn=dim_avg_n(amip_rlutcs_aqua,0)
amip_rlutcs_aqua_tzmn=dim_avg_n(amip_rlutcs_aqua_tmn,1)
amip_rsdt_aqua_tmn=dim_avg_n(amip_rsdt_aqua,0)
amip_rsdt_aqua_tzmn=dim_avg_n(amip_rsdt_aqua_tmn,1)

; calculate CRE: cloud radiative effect
cre_lw_aqua=amip_rlut_aqua_tzmn-amip_rlutcs_aqua_tzmn
cre_sw_aqua=amip_rsut_aqua_tzmn-amip_rsutcs_aqua_tzmn
cre_net_aqua=cre_sw_aqua+cre_lw_aqua

cre_lw_aqua_tmn=amip_rlut_aqua_tmn-amip_rlutcs_aqua_tmn
cre_sw_aqua_tmn=amip_rsut_aqua_tmn-amip_rsutcs_aqua_tmn
cre_net_aqua_tmn=cre_sw_aqua_tmn+cre_lw_aqua_tmn

cre_lw_aqua!0="lat"
cre_lw_aqua&lat=amip_rsut_aqua&lat

cre_sw_aqua!0="lat"
cre_sw_aqua&lat=amip_rsut_aqua&lat

cre_net_aqua!0="lat"
cre_net_aqua&lat=amip_rsut_aqua&lat

cre_lw_aqua_tmn!0="lat"
cre_lw_aqua_tmn&lat=amip_rsut_aqua&lat
cre_lw_aqua_tmn!1="lon"
cre_lw_aqua_tmn&lon=amip_rsut_aqua&lon

cre_sw_aqua_tmn!0="lat"
cre_sw_aqua_tmn&lat=amip_rsut_aqua&lat
cre_sw_aqua_tmn!1="lon"
cre_sw_aqua_tmn&lon=amip_rsut_aqua&lon

cre_net_aqua_tmn!0="lat"
cre_net_aqua_tmn&lat=amip_rsut_aqua&lat
cre_net_aqua_tmn!1="lon"
cre_net_aqua_tmn&lon=amip_rsut_aqua&lon
;
;--------------------------------------------------------------------------
; for aqua p4K 
;-------------------------------------------------------------------------
filename="rsut_Amon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
infile1=path+filename
filename="rsutcs_Amon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
infile2=path+filename
filename="rlut_Amon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
infile3=path+filename
filename="rlutcs_Amon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
infile4=path+filename
filename="rsdt_Amon_GFDL-CM4_aqua-p4K_r1i1p1f1_gr1_198001-198912.nc"
infile5=path+filename

; read data
add_rsut_aqua_p4K=addfile(infile1,"r")
amip_rsut_aqua_p4K=add_rsut_aqua_p4K->rsut(:,:,:)
add_rsutcs_aqua_p4K=addfile(infile2,"r")
amip_rsutcs_aqua_p4K=add_rsutcs_aqua_p4K->rsutcs(:,:,:)
add_rlut_aqua_p4K=addfile(infile3,"r")
amip_rlut_aqua_p4K=add_rlut_aqua_p4K->rlut(:,:,:)
add_rlutcs_aqua_p4K=addfile(infile4,"r")
amip_rlutcs_aqua_p4K=add_rlutcs_aqua_p4K->rlutcs(:,:,:)
add_rsdt_aqua_p4K=addfile(infile5,"r")
amip_rsdt_aqua_p4K=add_rsdt_aqua_p4K->rsdt(:,:,:)

;--------------------------------------------------------------------
; average data
amip_rsut_aqua_p4K_tmn=dim_avg_n(amip_rsut_aqua_p4K,0)
amip_rsut_aqua_p4K_tzmn=dim_avg_n(amip_rsut_aqua_p4K_tmn,1)
amip_rsutcs_aqua_p4K_tmn=dim_avg_n(amip_rsutcs_aqua_p4K,0)
amip_rsutcs_aqua_p4K_tzmn=dim_avg_n(amip_rsutcs_aqua_p4K_tmn,1)
amip_rlut_aqua_p4K_tmn=dim_avg_n(amip_rlut_aqua_p4K,0)
amip_rlut_aqua_p4K_tzmn=dim_avg_n(amip_rlut_aqua_p4K_tmn,1)
amip_rlutcs_aqua_p4K_tmn=dim_avg_n(amip_rlutcs_aqua_p4K,0)
amip_rlutcs_aqua_p4K_tzmn=dim_avg_n(amip_rlutcs_aqua_p4K_tmn,1)
amip_rsdt_aqua_p4K_tmn=dim_avg_n(amip_rsdt_aqua_p4K,0)
amip_rsdt_aqua_p4K_tzmn=dim_avg_n(amip_rsdt_aqua_p4K_tmn,1)

;--------------------------------------------------------------------
; calculate CRE: cloud radiative effect
cre_lw_aqua_p4K=amip_rlut_aqua_p4K_tzmn-amip_rlutcs_aqua_p4K_tzmn
cre_sw_aqua_p4K=amip_rsut_aqua_p4K_tzmn-amip_rsutcs_aqua_p4K_tzmn
cre_net_aqua_p4K=cre_sw_aqua_p4K+cre_lw_aqua_p4K

cre_lw_aqua_p4K_tmn=amip_rlut_aqua_p4K_tmn-amip_rlutcs_aqua_p4K_tmn
cre_sw_aqua_p4K_tmn=amip_rsut_aqua_p4K_tmn-amip_rsutcs_aqua_p4K_tmn
cre_net_aqua_p4K_tmn=cre_sw_aqua_p4K_tmn+cre_lw_aqua_p4K_tmn

cre_lw_aqua_p4K!0="lat"
cre_lw_aqua_p4K&lat=amip_rsut_aqua_p4K&lat

cre_sw_aqua_p4K!0="lat"
cre_sw_aqua_p4K&lat=amip_rsut_aqua_p4K&lat

cre_net_aqua_p4K!0="lat"
cre_net_aqua_p4K&lat=amip_rsut_aqua_p4K&lat

cre_lw_aqua_p4K_tmn!0="lat"
cre_lw_aqua_p4K_tmn&lat=amip_rsut_aqua&lat
cre_lw_aqua_p4K_tmn!1="lon"
cre_lw_aqua_p4K_tmn&lon=amip_rsut_aqua&lon

cre_sw_aqua_p4K_tmn!0="lat"
cre_sw_aqua_p4K_tmn&lat=amip_rsut_aqua&lat
cre_sw_aqua_p4K_tmn!1="lon"
cre_sw_aqua_p4K_tmn&lon=amip_rsut_aqua&lon

cre_net_aqua_p4K_tmn!0="lat"
cre_net_aqua_p4K_tmn&lat=amip_rsut_aqua&lat
cre_net_aqua_p4K_tmn!1="lon"
cre_net_aqua_p4K_tmn&lon=amip_rsut_aqua&lon

;
;-------------------------------------------------------------------------
; compute bias of cre relative to a particular control exp.
;-------------------------------------------------------------------------

; control CRE:
;cont_cre=ceres_2p8_cre_ztmn
;cont_cre=ceres_4p1_cre_ztmn
cont_cre=-cre_net_pic 
;-------------------------------------------------------------------------
; compute CRE feedbacks....
;-------------------------------------------------------------------------

cre_aqua_p4K_fb     =cre_net_aqua_p4K-cre_net_aqua
cresw_aqua_p4K_fb   =cre_sw_aqua_p4K-cre_sw_aqua
crelw_aqua_p4K_fb   =cre_lw_aqua_p4K-cre_lw_aqua

cre_amip_base_fb    =cre_net_amip-cre_net_amip
crelw_amip_base_fb  =cre_lw_amip-cre_lw_amip
cresw_amip_base_fb  =cre_sw_amip-cre_sw_amip

cre_amip_fut_fb     =cre_net_amip_future4K-cre_net_amip
cresw_amip_fut_fb   =cre_sw_amip_future4K-cre_sw_amip
crelw_amip_fut_fb   =cre_lw_amip_future4K-cre_lw_amip

cre_amip_p4K_fb     =cre_net_amip_p4K-cre_net_amip
cresw_amip_p4K_fb   =cre_sw_amip_p4K-cre_sw_amip
crelw_amip_p4K_fb   =cre_lw_amip_p4K-cre_lw_amip

;cre_amip_m4K_fb    =cre_net_amip_m4K-cre_net_amip
cre_amip_m4K_fb     =cre_net_amip-cre_net_amip_m4K
cresw_amip_m4K_fb   =cre_sw_amip-cre_sw_amip_m4K
crelw_amip_m4K_fb   =cre_lw_amip-cre_lw_amip_m4K

;cre_amip_m4K_fb=cre_net_amip_m4K-cre_net_amip

cresw_aqua_p4K_fb!0="lat"
cresw_aqua_p4K_fb&lat=amip_rsut_future4K&lat
crelw_aqua_p4K_fb!0="lat"
crelw_aqua_p4K_fb&lat=amip_rsut_future4K&lat

cresw_amip_base_fb!0="lat"
cresw_amip_base_fb&lat=amip_rsut_future4K&lat
crelw_amip_base_fb!0="lat"
crelw_amip_base_fb&lat=amip_rsut_future4K&lat

cresw_amip_fut_fb!0="lat"
cresw_amip_fut_fb&lat=amip_rsut_future4K&lat
crelw_amip_fut_fb!0="lat"
crelw_amip_fut_fb&lat=amip_rsut_future4K&lat

cresw_amip_p4K_fb!0="lat"
cresw_amip_p4K_fb&lat=amip_rsut_future4K&lat
crelw_amip_p4K_fb!0="lat"
crelw_amip_p4K_fb&lat=amip_rsut_future4K&lat

cresw_amip_m4K_fb!0="lat"
cresw_amip_m4K_fb&lat=amip_rsut_future4K&lat
crelw_amip_m4K_fb!0="lat"
crelw_amip_m4K_fb&lat=amip_rsut_future4K&lat

cre_aqua_p4K_fb!0="lat"
cre_aqua_p4K_fb&lat=amip_rsut_future4K&lat
cre_amip_base_fb!0="lat"
cre_amip_base_fb&lat=amip_rsut_future4K&lat
cre_amip_fut_fb!0="lat"
cre_amip_fut_fb&lat=amip_rsut_future4K&lat
cre_amip_p4K_fb!0="lat"
cre_amip_p4K_fb&lat=amip_rsut_future4K&lat
cre_amip_m4K_fb!0="lat"
cre_amip_m4K_fb&lat=amip_rsut_future4K&lat

;-------------------------------------------------------------------------
; compute global mean values of data from ceres and am4
;-------------------------------------------------------------------------
lat      = crs->lat
rad      = 4.0*atan(1.0)/180.0
clat     = cos(lat*rad)
clat_am4 = cos(latitude*rad)

axis_coslat=new((/180/),float)

ceres_2p8_ave=wgt_areaave(ceres_2p8_cre,clat,1.0,0)
ceres_4p1_ave=wgt_areaave(ceres_4p1_cre,clat,1.0,0)

print("mean of ceres 2p8: "+dim_avg_n(ceres_2p8_cre_ztmn,0))
print("w mean of ceres 2p8: "+ceres_2p8_ave)
print("mean of ceres 4p1: "+dim_avg_n(ceres_4p1_cre_ztmn,0))
print("w mean of ceres 4p1: "+ceres_4p1_ave)

; amip p4K 
cre_p4K=wgt_areaave(cre_net_amip_p4K_tmn,clat_am4,1.0,0)
cre_amip=wgt_areaave(cre_net_amip_tmn,clat_am4,1.0,0)
amip_p4K_a=(cre_p4K-cre_amip)/delT_amip_p4K

; amip m4K
cre_m4K=wgt_areaave(cre_net_amip_m4K_tmn,clat_am4,1.0,0)
amip_m4K_a=(cre_m4K-cre_amip)/delT_amip_m4K

; amip future4K
cre_future4K=wgt_areaave(cre_net_amip_future4K_tmn,clat_am4,1.0,0)
amip_future4K_a=(cre_future4K-cre_amip)/delT_amip_fut

; aqua p4K 
cre_aqua=wgt_areaave(cre_net_aqua_tmn,clat_am4,1.0,0)
cre_aqua4K=wgt_areaave(cre_net_aqua_p4K_tmn,clat_am4,1.0,0)
aqua_p4K_a=(cre_aqua4K-cre_aqua)/delT_aqua

  print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
  print(" The following values indicate that the sign of the CRE and Feedbacks should be switched...")
  print(" Clouds should cool the earth overall, by roughly 20 W/m2 ")
  print("w mean of aqua p 4K time series fb:      "+aqua_p4K_a)
  print("w mean of amip time series net:          "+cre_amip)
  print("w mean of amip p 4K time series net:     "+cre_p4K)
  print("w mean of amip p 4K time series fb:      "+amip_p4K_a)
  print("w mean of amip m 4K time series fb:      "+amip_m4K_a)
  print("w mean of amip future 4K time series fb: "+amip_future4K_a)
  print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

amip_cre_fb_p4K =cre_amip_p4K_fb/delT_amip_p4K
amip_b=amip_cre_fb_p4K*clat_am4/180

;  print("dimsizes of amip_cre_fb_p4K: "+dimsizes(amip_cre_fb_p4K))
;  print("amip_cre_fb_p4K (0): "+amip_cre_fb_p4K(0)+" :"+cos(latitude(0)*rad)+"; amip_cre_fb_p4K (90): "+amip_cre_fb_p4K(90)+" :"+cos(latitude(90)*rad))

;amip_cre_fb_p4K_gave=wgt_areaave(amip_cre_fb_p4K,clat_am4,1.0,0)
;  print("w mean of amip p4K fb: "+amip_cre_fb_p4K_gave)
  print("w jerry-rigged mean of amip p4K fb: "+sum(amip_b))

;printVarSummary(var_to_interpolate)
;-------------------------------------------------------------------------
; make plot
  ;wks   = gsn_open_wks ("newPDF","testplot")
  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  plot = new(1,graphic)

; resources for the panels, and the legend
  res                        = True
  lgres                      = True
 
  fontsize    = 0.03
  lthick      = 2.0
  lthin       = 1.0
  ldash       = 16
  ldash_solid = 0
 
  res@tiMainFont = 21
  res@tiMainFontHeightF = fontsize
  ;res@tiYAxisString  = "[W/m2K]" 
  ;res@tiYAxisString  = "[W/m2]" 
  res@tiYAxisFont    = 21
  res@tiYAxisFontHeightF = fontsize 
  res@tiXAxisString  = "Latitude"
  res@tiXAxisFont    = 21
  res@tiXAxisFontHeightF = fontsize
 
  res@vpWidthF          = 1.2 
  res@vpHeightF         = 0.5 
 
  res@tmYLLabelFontHeightF = fontsize 
  res@tmXBLabelFontHeightF = fontsize
 
  lthick=3.0
  res@xyLineThicknessF     = lthick
  res@tmXBMode = "explicit"
  res@tmXBValues = (/-60,-30,0,30,60/)
  res@tmXBLabels = (/-60,-30,0,30,60/)
  res@tmXBMinorValues =(/-80.,-70.,-50.,-40.,-20.,-10.,10.,20.,40.,50.,70.,80./)

; here is where the colors, line styles, and string names are defined 
 ; colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid4","darkslategray4","gold"/) 
    colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3","red"/) 
  title_1="net CRE"
  title_2="sw CRE"
  title_3="lw CRE"
  labels = (/title_1,title_2,title_3/) ; bottom to top
  ; the plotting order is: observations,r,s,u ; top to bottom
 
 res@gsnDraw         = False
 res@gsnFrame         = False

if (everything .ge. 2) then ; plot amip based feedback of CRE
 res@tiMainString = "SW CRE Feedback"
 res@tiYAxisString  = "[W/m2K]" 
 res@trYMinF = -4
 res@trYMaxF = 1 
else if (everything .ge. 1) then ; plot the whole shebang
 res@tiMainString = "CRE "
 res@tiYAxisString  = "[W/m2]" 
 res@trYMinF = -70 
 res@trYMaxF = 110 
else
 res@tiMainString = "Cloud Radiative Effect "
 res@tiYAxisString  = "[W/m2]" 
 res@trYMinF = -50 
 res@trYMaxF = 10 
end if
end if
if (plotbias .gt. 0) then ; plot the cre feedback
 res@tiMainString = "Cloud Radiative Effect bias"
 res@trYMinF = -20 
 res@trYMaxF = 10 
end if

 res@xyLineColors=colors(3)
 res@xyDashPattern="0"
 plot0a=gsn_csm_xy(wks,latitude(:),cre_net_amip_m4K(:),res)
 res@xyDashPattern="2"
 res@xyLineColors=colors(3)
 plot0b=gsn_csm_xy(wks,latitude(:),cre_sw_amip_m4K(:),res)
 res@xyLineColors=colors(3)
 plot0c=gsn_csm_xy(wks,latitude(:),cre_lw_amip_m4K(:),res)

 res@xyLineColors=colors(1)
 res@xyDashPattern="0"
 plot1a=gsn_csm_xy(wks,latitude(:),cre_net_amip(:),res)
 res@xyLineColors=colors(1)
 plot1b=gsn_csm_xy(wks,latitude(:),cre_sw_amip(:),res)
 res@xyLineColors=colors(1)
 plot1c=gsn_csm_xy(wks,latitude(:),cre_lw_amip(:),res)

 res@xyLineColors=colors(2)
 res@xyDashPattern="0"
 plot2a=gsn_csm_xy(wks,latitude(:),cre_net_amip_p4K(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(2)
 plot2b=gsn_csm_xy(wks,latitude(:),cre_sw_amip_p4K(:),res)
 res@xyLineColors=colors(2)
 plot2c=gsn_csm_xy(wks,latitude(:),cre_lw_amip_p4K(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(0)
 plot3a=gsn_csm_xy(wks,latitude(:),cre_net_aqua(:),res)
 res@xyLineColors=colors(0)
 plot3b=gsn_csm_xy(wks,latitude(:),cre_sw_aqua(:),res)
 res@xyLineColors=colors(0)
 plot3c=gsn_csm_xy(wks,latitude(:),cre_lw_aqua(:),res)
 
 res@xyDashPattern="0"
 res@xyLineColors=colors(0)
 plot4a=gsn_csm_xy(wks,latitude(:),cre_net_aqua_p4K(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(0)
 plot4b=gsn_csm_xy(wks,latitude(:),cre_sw_aqua_p4K(:),res)
 res@xyLineColors=colors(0)
 plot4c=gsn_csm_xy(wks,latitude(:),cre_lw_aqua_p4K(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(4)
 plot5a=gsn_csm_xy(wks,latitude(:),cre_net_h2_historical(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(4)
 plot5b=gsn_csm_xy(wks,latitude(:),cre_sw_h2_historical(:),res)
 res@xyLineColors=colors(4)
 plot5c=gsn_csm_xy(wks,latitude(:),cre_lw_h2_historical(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(5)
 plot6a=gsn_csm_xy(wks,latitude(:),cre_net_abr2(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(5)
 plot6b=gsn_csm_xy(wks,latitude(:),cre_sw_abr2(:),res)
 res@xyLineColors=colors(5)
 plot6c=gsn_csm_xy(wks,latitude(:),cre_lw_abr2(:),res)

;;; compute bias
; I am still working out the normalizations for these profiles...
; 
if (plotbias .gt. 0) then ; plot the cre feedback
 cre_net_amip          =(cre_net_amip+cont_cre)/0.76
 cre_net_h2_historical =(cre_net_h2_historical+cont_cre)/0.8
 cre_net_abr2          =(cre_net_abr2+cont_cre)/3.99
 cre_net_1pct          =(cre_net_1pct+cont_cre)/2.0
 ceres_2p8_cre_ztmn    =(ceres_2p8_cre_ztmn-cont_cre)/0.8
 ceres_4p1_cre_ztmn    =(ceres_4p1_cre_ztmn-cont_cre)/0.8
end if
;
 res@xyLineColors=colors(1)
 res@xyDashPattern="0"
 plot_alt_1=gsn_csm_xy(wks,latitude(:),-cre_net_amip(:),res)
 res@xyDashPattern="0"
 res@xyLineColors=colors(4)
 plot_alt_2=gsn_csm_xy(wks,latitude(:),-cre_net_h2_historical(:),res)
 res@xyDashPattern="0"
 res@xyLineColors=colors(5)
 plot_alt_3=gsn_csm_xy(wks,latitude(:),-cre_net_abr2(:),res)
 res@xyLineColors=colors(6)
 plot_alt_4=gsn_csm_xy(wks,latitude(:),-cre_net_1pct(:),res)
 res@xyDashPattern="1"
 res@xyLineColors=colors(0)
 plot_alt_5=gsn_csm_xy(wks,latitude(:),ceres_2p8_cre_ztmn(:),res)
 res@xyDashPattern="0"
 res@xyLineColors=colors(0)
 plot_alt_6=gsn_csm_xy(wks,latitude(:),ceres_4p1_cre_ztmn(:),res)

print("plotted ceres 2p8 mean is: "+dim_avg_n(ceres_2p8_cre_ztmn,0))
print("plotted ceres 4p1 mean is: "+dim_avg_n(ceres_4p1_cre_ztmn,0))
print("plotted cre net amip mean is: "+dim_avg_n(cre_net_amip,0))
print("plotted cre net h2 historical mean is: "+dim_avg_n(cre_net_h2_historical,0))
print("plotted cre net abr2 mean is: "+dim_avg_n(cre_net_abr2,0))
print("plotted cre net 1pct mean is: "+dim_avg_n(cre_net_1pct,0))

if (everything .ge. 2) then ; plot the cre feedback
  colors_cre = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3","red","steelblue1"/) 
  labels_cre = (/"amip +future4K","amip +4K","amip -4K","aqua +4K"/) ; bottom to top

testaxis=cos(latitude*rad)
testaxis=where(latitude.lt.0,-testaxis,testaxis)
;print("creeps: "+testaxis)
;printVarSummary(latitude)

  res@xyLineColors=colors_cre(0)
  res@xyLineThicknessF  = lthin
  res@xyDashPattern = ldash_solid
  plot0a=gsn_csm_xy(wks,latitude(:),-cre_amip_base_fb(:),res)
  res@xyDashPattern = ldash
  plot0ac=gsn_csm_xy(wks,latitude(:),-crelw_amip_base_fb(:),res)
  res@xyDashPattern = ldash_solid
  res@xyLineThicknessF  = lthick
  plot0ab=gsn_csm_xy(wks,latitude(:),-cresw_amip_base_fb(:),res)

  res@xyLineColors=colors_cre(2)
  res@xyLineThicknessF  = lthin
  res@xyDashPattern = ldash_solid
  plot0b=gsn_csm_xy(wks,latitude(:),-cre_amip_p4K_fb(:)/delT_amip_p4K,res)
  res@xyDashPattern = ldash
  plot0bc=gsn_csm_xy(wks,latitude(:),-crelw_amip_p4K_fb(:)/delT_amip_p4K,res)
  res@xyDashPattern = ldash_solid
  res@xyLineThicknessF  = lthick
  plot0bb=gsn_csm_xy(wks,latitude(:),-cresw_amip_p4K_fb(:)/delT_amip_p4K,res)

  res@xyLineColors=colors_cre(3)
  res@xyLineThicknessF  = lthin
  res@xyDashPattern = ldash_solid
  plot0c=gsn_csm_xy(wks,latitude(:),-cre_amip_m4K_fb(:)/delT_amip_m4K,res)
  res@xyDashPattern = ldash
  plot0cc=gsn_csm_xy(wks,latitude(:),-crelw_amip_m4K_fb(:)/delT_amip_m4K,res)
  res@xyDashPattern = ldash_solid
  res@xyLineThicknessF  = lthick
  plot0cb=gsn_csm_xy(wks,latitude(:),-cresw_amip_m4K_fb(:)/delT_amip_m4K,res)

  res@xyLineColors=colors_cre(7)
  res@xyLineThicknessF  = lthin
  res@xyDashPattern = ldash_solid
  plot0d=gsn_csm_xy(wks,latitude(:),-cre_amip_fut_fb(:)/delT_amip_fut,res)
  res@xyDashPattern = ldash
  plot0dc=gsn_csm_xy(wks,latitude(:),-crelw_amip_fut_fb(:)/delT_amip_fut,res)
  res@xyDashPattern = ldash_solid
  res@xyLineThicknessF  = lthick
  plot0db=gsn_csm_xy(wks,latitude(:),-cresw_amip_fut_fb(:)/delT_amip_fut,res)

  res@xyLineColors=colors_cre(8)
  res@xyLineThicknessF  = lthin
  res@xyDashPattern = ldash_solid
  plot0e=gsn_csm_xy(wks,latitude(:),-cre_aqua_p4K_fb(:)/delT_aqua,res)
  res@xyDashPattern = ldash
  plot0ec=gsn_csm_xy(wks,latitude(:),-crelw_aqua_p4K_fb(:)/delT_aqua,res)
  res@xyDashPattern = ldash_solid
  res@xyLineThicknessF  = lthick
  plot0eb=gsn_csm_xy(wks,latitude(:),-cresw_aqua_p4K_fb(:)/delT_aqua,res)

; plot sw cre
  overlay(plot0a,plot0bb)
  overlay(plot0a,plot0cb)
  overlay(plot0a,plot0db)
  overlay(plot0a,plot0eb)

;; pretty much everything...
;  overlay(plot0a,plot0e)
;  overlay(plot0a,plot0eb)
;  overlay(plot0a,plot0ec)
;  overlay(plot0a,plot0b)
;  overlay(plot0a,plot0bb)
;  overlay(plot0a,plot0bc)
;  overlay(plot0a,plot0c)
;  overlay(plot0a,plot0cb)
;  overlay(plot0a,plot0cc)
;  overlay(plot0a,plot0d)
;  overlay(plot0a,plot0db)
;  overlay(plot0a,plot0dc)

  plot(0)=plot0a

else if (everything .ge. 1) then ; plot the whole shebang
 ; overlay the profiles to plot
 ; amip -4K
  overlay(plot0a,plot0b)
  overlay(plot0a,plot0c)
 
 ; amip
  overlay(plot0a,plot1a)
  overlay(plot0a,plot1b)
  overlay(plot0a,plot1c)
 
 ; amip +4K
  overlay(plot0a,plot2a)
  overlay(plot0a,plot2b)
  overlay(plot0a,plot2c)
 
 ; aqua 
  overlay(plot0a,plot3a)
  overlay(plot0a,plot3b)
  overlay(plot0a,plot3c)
 
 ; aqua +4K
  overlay(plot0a,plot4a)
  overlay(plot0a,plot4b)
  overlay(plot0a,plot4c)
 
 ; historical 2
  overlay(plot0a,plot5a)
  overlay(plot0a,plot5b)
  overlay(plot0a,plot5c)
 
 ; abrupt 4xCO2 2
  overlay(plot0a,plot6a)
  overlay(plot0a,plot6b)
  overlay(plot0a,plot6c)
 
  plot(0)=plot0a
 
else
  overlay(plot_alt_1,plot_alt_2)
  overlay(plot_alt_1,plot_alt_3)
  overlay(plot_alt_1,plot_alt_4)
  overlay(plot_alt_1,plot_alt_5)
  overlay(plot_alt_1,plot_alt_6)
  plot(0)=plot_alt_1
end if
end if

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=--=-=-=-=-=-=-=-=-=-=-=-=-
;       add a legend

 lgres                      = True
 lgres@xyLabelMode            = "Custom"
 lgres@xyLineLabelFontHeightF = 0.020                ; font height
 ;lgres@lgLineColors         = (/"black","darkgoldenrod","darkolivegreen3","chocolate"/)
 lgres@lgItemType           = "Lines"
 lgres@lgLabelFontHeightF   = .07
 lgres@vpWidthF             = 0.3        ; width of legend
 lgres@vpHeightF            = 0.20        ; height of legend
 lgres@lgLineThicknessF     = lthick
 lgres@lgPerimThicknessF    = 2.0
 lgres@lgMonoDashIndex      = False 
 ;lgres@lgDashIndexes          = (/"0","0","0","0"/)
 lgres@lgPerimOn            = False

; draw panel with white space added
if (plotbias .ge. 0) then ; plot the cre feedback
  if (everything .ge. 2) then
   print("everything is greather than 2")
   legend  = gsn_create_legend (wks, 4, labels_cre, lgres)
   lgres@lgLineColors         = (/colors_cre(7),colors_cre(2),colors_cre(3),colors_cre(8)/)
   lgres@lgDashIndexes = (/"0","0","0","0"/)
   legend  = gsn_create_legend (wks, 4, labels_cre, lgres)
   resP                 = True
   resP@amJust = "BottomRight"
   ;resP@amParallelPosF   = 0.42    ; Move legend to right
   ;resP@amOrthogonalPosF = -0.1     ; Move legend down more negative moves higher
   resP@amParallelPosF   = 0.32    ; Move legend to right
   resP@amOrthogonalPosF = 0.35     ; Move legend down more negative moves higher
   annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
  else if(everything .ge. 1) then ; plot the whole shebang
   legend  = gsn_create_legend (wks, 3, labels, lgres)
   lgres@lgDashIndexes = (/"0","0","0","0"/)
   resP                 = True
   resP@amJust = "BottomRight"
   ;resP@amParallelPosF   = 0.42    ; Move legend to right
   resP@amParallelPosF   = -0.12    ; Move legend to right
   resP@amOrthogonalPosF = -0.85     ; Move legend down more negative moves higher
   annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
  else    ; plot only ceres-ebaf, amip, historical, abrupt 4xCO2, and 1% CO2 ramp
  ; labels_b = (/"CERES-EBAF v2.8","CERES-EBAF v4.1","amip","historical","abrupt 4xCO2","1% CO2 Ramp"/)
   labels_b = (/"amip","historical","abrupt 4xCO2","1% CO2 Ramp","CERES-EBAF v2.8","CERES-EBAF v4.1"/)
    ; colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3"/) 
   ;lgres@lgLineColors         = (/colors(0),colors(0),colors(1),colors(4),colors(5),colors(6)/)
   lgres@lgLineColors         = (/colors(1),colors(4),colors(5),colors(6),colors(0),colors(0)/)
   lgres@lgDashIndexes          = (/"0","0","0","0","1","0"/)
   legend  = gsn_create_legend (wks, 6, labels_b, lgres)
   resP                 = True
   resP@amJust = "BottomRight"
   resP@amParallelPosF   = -0.08    ; Move legend to right
   resP@amOrthogonalPosF = -0.05     ; Move legend down more negative moves higher
   ;resP@amParallelPosF   = -0.12    ; Move legend to right
   ;resP@amOrthogonalPosF = 0.45     ; Move legend down more negative moves higher
  
   annoid = gsn_add_annotation(plot_alt_1,legend,resP) ; add legend to plot
  end if 
  end if
  resP                 = True
  annoid = gsn_add_annotation(plot_alt_1,legend,resP) ; add legend to plot
end if

 gsn_panel(wks,plot,(/1,1/),resP)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; compute average cre values and print to screen
; net_cre_amip             = dim_avg_n(cre_net_amip,0)
; print("net cre amip      = "+net_cre_amip)
; net_cre_amip_p4K         = dim_avg_n(cre_net_amip_p4K,0)
; print("net cre amip p4K  = "+net_cre_amip_p4K)
; net_cre_amip_m4K         = dim_avg_n(cre_net_amip_m4K,0)
; print("net cre amip m4K  = "+net_cre_amip_m4K)
;
;print("dimensions of amip future fb are: "+dimsizes(cre_amip_fut_fb)) 
;net_amip_fut_fb            = dim_avg_n(cre_amip_fut_fb,0)
;print("net cre fut fb      = "+net_amip_fut_fb)
;net_amip_p4K_fb            = dim_avg_n(cre_amip_p4K_fb,0)
;print("net cre p4K fb      = "+net_amip_p4K_fb)
;net_amip_m4K_fb            = dim_avg_n(cre_amip_m4K_fb,0)
;print("net cre m4K fb      = "+net_amip_m4K_fb)
;
; net_cre_aqua   =dim_avg_n(cre_net_aqua,0)
; print("net cre aqua = "+net_cre_aqua)
; net_cre_aquap4K=dim_avg_n(cre_net_aqua_p4K,0)
; print("net cre aqua+4K = "+net_cre_aquap4K)
;
;; compute the cre feedback values and print to screen
; amip_cre_fb_p4K =(net_cre_amip_p4K-net_cre_amip)/delT_amip_p4K
; print("amip cre fb p4K: "+amip_cre_fb_p4K)
; amip_cre_fb_m4K =(net_cre_amip-net_cre_amip_m4K)/delT_amip_m4K
; print("amip cre fb m4K: "+amip_cre_fb_m4K)
; aqua_cre_fb=(net_cre_aquap4K-net_cre_aqua)/delT_aqua
; print("net cre aqua: "+aqua_cre_fb)
;
;;-------------------------------------------------------------------------
end

