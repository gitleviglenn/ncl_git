;-------------------------------------------------------------------------
; radflux_am4CRE.ncl 
;-------------------------------------------------------------------------
;
; compute CRE as a function of latitude for particular CFMIP experiments
;
; levi silvers                                            oct 2019
;-------------------------------------------------------------------------

begin

path="/Users/silvers/data/cfmip_toafluxes/"

everything = 0 ; switch defining which profiles are plotted

; years for the abrupt and ramp warming experiments
early="000101-010012"
late="010101-015012"

; years for the historical experiment
firsthalf="185001-194912"
seconhalf="195001-201412"

hist_yrs=seconhalf
warm_yrs=late
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

; read data
add_rsut=addfile(infile1,"r")
amip_rsut=add_rsut->rsut(:,:,:)
add_rsutcs=addfile(infile2,"r")
amip_rsutcs=add_rsutcs->rsutcs(:,:,:)
add_rlut=addfile(infile3,"r")
amip_rlut=add_rlut->rlut(:,:,:)
add_rlutcs=addfile(infile4,"r")
amip_rlutcs=add_rlutcs->rlutcs(:,:,:)
add_rsdt=addfile(infile5,"r")
amip_rsdt=add_rsdt->rsdt(:,:,:)

latitude=add_rsut->lat(:)

; average data
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

print("dimensions of amip_rsut are: "+dimsizes(amip_rsut))

; calculate CRE: cloud radiative effect
cre_olr_amip=amip_rlut_tzmn-amip_rlutcs_tzmn
cre_sw_amip=amip_rsut_tzmn-amip_rsutcs_tzmn
cre_net_amip=cre_sw_amip+cre_olr_amip

cre_olr_amip!0="lat"
cre_olr_amip&lat=amip_rsut&lat

cre_sw_amip!0="lat"
cre_sw_amip&lat=amip_rsut&lat

cre_net_amip!0="lat"
cre_net_amip&lat=amip_rsut&lat

;-------------------------------------------------------------------------
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

print("dimensions of amip_rsut_m4k are: "+dimsizes(amip_rsut_m4K))
print("dimensions of amip_rsut_m4k_tmn are: "+dimsizes(amip_rsut_m4K_tmn))
print("dimensions of amip_rsut_m4k_tzmn are: "+dimsizes(amip_rsut_m4K_tzmn))

; calculate CRE: cloud radiative effect
cre_olr_amip_m4K=amip_rlut_m4K_tzmn-amip_rlutcs_m4K_tzmn
cre_sw_amip_m4K=amip_rsut_m4K_tzmn-amip_rsutcs_m4K_tzmn
cre_net_amip_m4K=cre_sw_amip_m4K+cre_olr_amip_m4K

cre_olr_amip_m4K!0="lat"
cre_olr_amip_m4K&lat=amip_rsut_m4K&lat

cre_sw_amip_m4K!0="lat"
cre_sw_amip_m4K&lat=amip_rsut_m4K&lat

cre_net_amip_m4K!0="lat"
cre_net_amip_m4K&lat=amip_rsut_m4K&lat
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
cre_olr_amip_p4K=amip_rlut_p4K_tzmn-amip_rlutcs_p4K_tzmn
cre_sw_amip_p4K=amip_rsut_p4K_tzmn-amip_rsutcs_p4K_tzmn
cre_net_amip_p4K=cre_sw_amip_p4K+cre_olr_amip_p4K

cre_olr_amip_p4K!0="lat"
cre_olr_amip_p4K&lat=amip_rsut_p4K&lat

cre_sw_amip_p4K!0="lat"
cre_sw_amip_p4K&lat=amip_rsut_p4K&lat

cre_net_amip_p4K!0="lat"
cre_net_amip_p4K&lat=amip_rsut_p4K&lat
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; for amip future
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
cre_olr_amip_future4K=amip_rlut_future4K_tzmn-amip_rlutcs_future4K_tzmn
cre_sw_amip_future4K=amip_rsut_future4K_tzmn-amip_rsutcs_future4K_tzmn
cre_net_amip_future4K=cre_sw_amip_future4K+cre_olr_amip_future4K

cre_olr_amip_future4K!0="lat"
cre_olr_amip_future4K&lat=amip_rsut_future4K&lat
cre_sw_amip_future4K!0="lat"
cre_sw_amip_future4K&lat=amip_rsut_future4K&lat
cre_net_amip_future4K!0="lat"
cre_net_amip_future4K&lat=amip_rsut_future4K&lat
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
;; read data
add_rsut_historical=addfile(infile1,"r")
h2_rsut_historical=add_rsut_historical->rsut(:,:,:)
add_rsutcs_historical=addfile(infile2,"r")
h2_rsutcs_historical=add_rsutcs_historical->rsutcs(:,:,:)
add_rlut_historical=addfile(infile3,"r")
h2_rlut_historical=add_rlut_historical->rlut(:,:,:)
add_rlutcs_historical=addfile(infile4,"r")
h2_rlutcs_historical=add_rlutcs_historical->rlutcs(:,:,:)
add_rsdt_historical=addfile(infile5,"r")
h2_rsdt_historical=add_rsdt_historical->rsdt(:,:,:)
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
cre_olr_h2_historical=h2_rlut_historical_tzmn-h2_rlutcs_historical_tzmn
cre_sw_h2_historical=h2_rsut_historical_tzmn-h2_rsutcs_historical_tzmn
cre_net_h2_historical=cre_sw_h2_historical+cre_olr_h2_historical
;
cre_olr_h2_historical!0="lat"
cre_olr_h2_historical&lat=h2_rsut_historical&lat
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
cre_olr_abr2=abr2_rlut_abrupt4xCO2_tzmn-abr2_rlutcs_abrupt4xCO2_tzmn
cre_sw_abr2=abr2_rsut_abrupt4xCO2_tzmn-abr2_rsutcs_abrupt4xCO2_tzmn
cre_net_abr2=cre_sw_abr2+cre_olr_abr2
;
cre_olr_abr2!0="lat"
cre_olr_abr2&lat=abr2_rsut_abrupt4xCO2&lat
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
cre_olr_aqua=amip_rlut_aqua_tzmn-amip_rlutcs_aqua_tzmn
cre_sw_aqua=amip_rsut_aqua_tzmn-amip_rsutcs_aqua_tzmn
cre_net_aqua=cre_sw_aqua+cre_olr_aqua

cre_olr_aqua!0="lat"
cre_olr_aqua&lat=amip_rsut_aqua&lat

cre_sw_aqua!0="lat"
cre_sw_aqua&lat=amip_rsut_aqua&lat

cre_net_aqua!0="lat"
cre_net_aqua&lat=amip_rsut_aqua&lat
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
amip_rsut_aqua_p4K=add_rsut_aqua->rsut(:,:,:)
add_rsutcs_aqua_p4K=addfile(infile2,"r")
amip_rsutcs_aqua_p4K=add_rsutcs_aqua->rsutcs(:,:,:)
add_rlut_aqua_p4K=addfile(infile3,"r")
amip_rlut_aqua_p4K=add_rlut_aqua->rlut(:,:,:)
add_rlutcs_aqua_p4K=addfile(infile4,"r")
amip_rlutcs_aqua_p4K=add_rlutcs_aqua->rlutcs(:,:,:)
add_rsdt_aqua_p4K=addfile(infile5,"r")
amip_rsdt_aqua_p4K=add_rsdt_aqua->rsdt(:,:,:)

; average data
amip_rsut_aqua_p4K_tmn=dim_avg_n(amip_rsut_aqua,0)
amip_rsut_aqua_p4K_tzmn=dim_avg_n(amip_rsut_aqua_tmn,1)
amip_rsutcs_aqua_p4K_tmn=dim_avg_n(amip_rsutcs_aqua,0)
amip_rsutcs_aqua_p4K_tzmn=dim_avg_n(amip_rsutcs_aqua_tmn,1)
amip_rlut_aqua_p4K_tmn=dim_avg_n(amip_rlut_aqua,0)
amip_rlut_aqua_p4K_tzmn=dim_avg_n(amip_rlut_aqua_tmn,1)
amip_rlutcs_aqua_p4K_tmn=dim_avg_n(amip_rlutcs_aqua,0)
amip_rlutcs_aqua_p4K_tzmn=dim_avg_n(amip_rlutcs_aqua_tmn,1)
amip_rsdt_aqua_p4K_tmn=dim_avg_n(amip_rsdt_aqua,0)
amip_rsdt_aqua_p4K_tzmn=dim_avg_n(amip_rsdt_aqua_tmn,1)

; calculate CRE: cloud radiative effect
cre_olr_aqua_p4K=amip_rlut_aqua_tzmn-amip_rlutcs_aqua_tzmn
cre_sw_aqua_p4K=amip_rsut_aqua_tzmn-amip_rsutcs_aqua_tzmn
cre_net_aqua_p4K=cre_sw_aqua+cre_olr_aqua

cre_olr_aqua_p4K!0="lat"
cre_olr_aqua_p4K&lat=amip_rsut_aqua&lat

cre_sw_aqua_p4K!0="lat"
cre_sw_aqua_p4K&lat=amip_rsut_aqua&lat

cre_net_aqua_p4K!0="lat"
cre_net_aqua_p4K&lat=amip_rsut_aqua&lat
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

; calculate CRE: cloud radiative effect
cre_olr_aqua_p4K=amip_rlut_aqua_p4K_tzmn-amip_rlutcs_aqua_p4K_tzmn
cre_sw_aqua_p4K=amip_rsut_aqua_p4K_tzmn-amip_rsutcs_aqua_p4K_tzmn
cre_net_aqua_p4K=cre_sw_aqua_p4K+cre_olr_aqua_p4K

cre_olr_aqua_p4K!0="lat"
cre_olr_aqua_p4K&lat=amip_rsut_aqua_p4K&lat

cre_sw_aqua_p4K!0="lat"
cre_sw_aqua_p4K&lat=amip_rsut_aqua_p4K&lat

cre_net_aqua_p4K!0="lat"
cre_net_aqua_p4K&lat=amip_rsut_aqua_p4K&lat
;-------------------------------------------------------------------------
; make plot
  ;wks   = gsn_open_wks ("newPDF","testplot")
  wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
  plot = new(1,graphic)

; resources for the panels, and the legend
  res                        = True
  lgres                      = True
 
  fontsize=0.03
 
  res@tiMainString = "CRE"
  res@tiMainFont = 21
  res@tiMainFontHeightF = fontsize
  res@tiYAxisString  = "Cloud Radiative Effect [W/m2]" 
  ;res@tiYAxisString  = "Cloud Feedback"
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
   colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid4","darkslategray4","gold"/) 
;  colors = (/"LawnGreen","black","SteelBlue","GoldenRod","Black"/);,"OrangeRed"/) 
  ;colors = (/"black","darkgoldenrod","darkolivegreen3","chocolate"/) 
  ;colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue"/) 
  lgres@lgLineColors  = (/colors(1),colors(2),colors(3),colors(0)/)
  lgres@lgDashIndexes = (/"0","0","0","0"/)
  title_1="net CRE"
  title_2="sw CRE"
  title_3="lw CRE"
  labels = (/title_1,title_2,title_3/) ; bottom to top
  ; the plotting order is: observations,r,s,u ; top to bottom
 
 res@gsnDraw         = False
 res@gsnFrame         = False

if (everything .ge. 1) then ; plot the whole shebang
 res@trYMinF = -70 
 res@trYMaxF = 110 
else
 res@trYMinF = -10 
 res@trYMaxF = 50 
end if
 res@xyLineColors=colors(3)
 res@xyDashPattern="0"
 plot0a=gsn_csm_xy(wks,latitude(:),cre_net_amip_m4K(:),res)
 res@xyDashPattern="2"
 res@xyLineColors=colors(3)
 plot0b=gsn_csm_xy(wks,latitude(:),cre_sw_amip_m4K(:),res)
 res@xyLineColors=colors(3)
 plot0c=gsn_csm_xy(wks,latitude(:),cre_olr_amip_m4K(:),res)

 res@xyLineColors=colors(1)
 res@xyDashPattern="0"
 plot1a=gsn_csm_xy(wks,latitude(:),cre_net_amip(:),res)
 res@xyLineColors=colors(1)
 plot1b=gsn_csm_xy(wks,latitude(:),cre_sw_amip(:),res)
 res@xyLineColors=colors(1)
 plot1c=gsn_csm_xy(wks,latitude(:),cre_olr_amip(:),res)

 res@xyLineColors=colors(2)
 res@xyDashPattern="0"
 plot2a=gsn_csm_xy(wks,latitude(:),cre_net_amip_p4K(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(2)
 plot2b=gsn_csm_xy(wks,latitude(:),cre_sw_amip_p4K(:),res)
 res@xyLineColors=colors(2)
 plot2c=gsn_csm_xy(wks,latitude(:),cre_olr_amip_p4K(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(0)
 plot3a=gsn_csm_xy(wks,latitude(:),cre_net_aqua(:),res)
 res@xyLineColors=colors(0)
 plot3b=gsn_csm_xy(wks,latitude(:),cre_sw_aqua(:),res)
 res@xyLineColors=colors(0)
 plot3c=gsn_csm_xy(wks,latitude(:),cre_olr_aqua(:),res)
 
 res@xyDashPattern="0"
 res@xyLineColors=colors(0)
 plot4a=gsn_csm_xy(wks,latitude(:),cre_net_aqua_p4K(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(0)
 plot4b=gsn_csm_xy(wks,latitude(:),cre_sw_aqua_p4K(:),res)
 res@xyLineColors=colors(0)
 plot4c=gsn_csm_xy(wks,latitude(:),cre_olr_aqua_p4K(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(4)
 plot5a=gsn_csm_xy(wks,latitude(:),cre_net_h2_historical(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(4)
 plot5b=gsn_csm_xy(wks,latitude(:),cre_sw_h2_historical(:),res)
 res@xyLineColors=colors(4)
 plot5c=gsn_csm_xy(wks,latitude(:),cre_olr_h2_historical(:),res)

 res@xyDashPattern="0"
 res@xyLineColors=colors(5)
 plot6a=gsn_csm_xy(wks,latitude(:),cre_net_abr2(:),res)
 res@xyDashPattern="16"
 res@xyLineColors=colors(5)
 plot6b=gsn_csm_xy(wks,latitude(:),cre_sw_abr2(:),res)
 res@xyLineColors=colors(5)
 plot6c=gsn_csm_xy(wks,latitude(:),cre_olr_abr2(:),res)

;everything = 0
if (everything .ge. 1) then ; plot the whole shebang
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
  overlay(plot1a,plot5a)
  overlay(plot1a,plot6a)
  plot(0)=plot1a
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
 ;labels = (/"string1","string2","string3","string4"/)
 legend  = gsn_create_legend (wks, 3, labels, lgres)
 resP                 = True
 resP@amJust = "BottomRight"
 ;resP@amParallelPosF   = 0.42    ; Move legend to right
 resP@amParallelPosF   = -0.12    ; Move legend to right
 resP@amOrthogonalPosF = -0.85     ; Move legend down more negative moves higher

 annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
 
 gsn_panel(wks,plot,(/1,1/),resP)

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; compute average cre values and print to screen
 net_cre_amip             = dim_avg_n(cre_net_amip,0)
 print("net cre amip      = "+net_cre_amip)
 net_cre_amip_p4K         = dim_avg_n(cre_net_amip_p4K,0)
 print("net cre amip p4K  = "+net_cre_amip_p4K)
 net_cre_amip_m4K         = dim_avg_n(cre_net_amip_m4K,0)
 print("net cre amip m4K  = "+net_cre_amip_m4K)

 net_cre_aqua   =dim_avg_n(cre_net_aqua,0)
 print("net cre aqua = "+net_cre_aqua)
 net_cre_aquap4K=dim_avg_n(cre_net_aqua_p4K,0)
 print("net cre aqua+4K = "+net_cre_aquap4K)

; compute the cre feedback values and print to screen
 amip_cre_fb_a =(net_cre_amip_p4K-net_cre_amip)/4
 print("amip cre fb a: "+amip_cre_fb_a)
 amip_cre_fb_b =(net_cre_amip-net_cre_amip_m4K)/4
 print("amip cre fb b: "+amip_cre_fb_b)
 aqua_cre_fb=(net_cre_aquap4K-net_cre_aqua)/4
 print("net cre aqua: "+aqua_cre_fb)

;-------------------------------------------------------------------------
end

