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
;; for historical
;;-------------------------------------------------------------------------
;filename="rsut_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
;infile1=path+filename
;filename="rsutcs_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
;infile2=path+filename
;filename="rlut_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
;infile3=path+filename
;filename="rlutcs_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
;infile4=path+filename
;filename="rsdt_Amon_GFDL-CM4_amip-p4K_r1i1p1f1_gr1_197901-201412.nc"
;infile5=path+filename
;
;; read data
;add_rsut_future4K=addfile(infile1,"r")
;amip_rsut_future4K=add_rsut_future4K->rsut(:,:,:)
;add_rsutcs_future4K=addfile(infile2,"r")
;amip_rsutcs_future4K=add_rsutcs_future4K->rsutcs(:,:,:)
;add_rlut_future4K=addfile(infile3,"r")
;amip_rlut_future4K=add_rlut_future4K->rlut(:,:,:)
;add_rlutcs_future4K=addfile(infile4,"r")
;amip_rlutcs_future4K=add_rlutcs_future4K->rlutcs(:,:,:)
;add_rsdt_future4K=addfile(infile5,"r")
;amip_rsdt_future4K=add_rsdt_future4K->rsdt(:,:,:)
;
;; average data
;amip_rsut_future4K_tmn=dim_avg_n(amip_rsut_future4K,0)
;amip_rsut_future4K_tzmn=dim_avg_n(amip_rsut_future4K_tmn,1)
;amip_rsutcs_future4K_tmn=dim_avg_n(amip_rsutcs_future4K,0)
;amip_rsutcs_future4K_tzmn=dim_avg_n(amip_rsutcs_future4K_tmn,1)
;amip_rlut_future4K_tmn=dim_avg_n(amip_rlut_future4K,0)
;amip_rlut_future4K_tzmn=dim_avg_n(amip_rlut_future4K_tmn,1)
;amip_rlutcs_future4K_tmn=dim_avg_n(amip_rlutcs_future4K,0)
;amip_rlutcs_future4K_tzmn=dim_avg_n(amip_rlutcs_future4K_tmn,1)
;amip_rsdt_future4K_tmn=dim_avg_n(amip_rsdt_future4K,0)
;amip_rsdt_future4K_tzmn=dim_avg_n(amip_rsdt_future4K_tmn,1)
;
;; calculate CRE: cloud radiative effect
;cre_olr_amip_future4K=amip_rlut_future4K_tzmn-amip_rlutcs_future4K_tzmn
;cre_sw_amip_future4K=amip_rsut_future4K_tzmn-amip_rsutcs_future4K_tzmn
;cre_net_amip_future4K=cre_sw_amip_future4K+cre_olr_amip_future4K
;
;cre_olr_amip_future4K!0="lat"
;cre_olr_amip_future4K&lat=amip_rsut_future4K&lat
;cre_sw_amip_future4K!0="lat"
;cre_sw_amip_future4K&lat=amip_rsut_future4K&lat
;cre_net_amip_future4K!0="lat"
;cre_net_amip_future4K&lat=amip_rsut_future4K&lat
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
  colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid4","darkslategray4"/) 
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

 res@trYMinF = -70 
 res@trYMaxF = 110 
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

 net_cre_amip       =dim_avg_n(cre_net_amip,0)
 print("net cre amip = "+net_cre_amip)
 net_cre_amip_p4K   =dim_avg_n(cre_net_amip_p4K,0)
 print("net cre amip p4K = "+net_cre_amip_p4K)
 net_cre_amip_m4K   =dim_avg_n(cre_net_amip_m4K,0)
 print("net cre amip m4K = "+net_cre_amip_m4K)

 amip_cre_fb_a=(net_cre_amip_p4K-net_cre_amip)/4
 amip_cre_fb_b=(net_cre_amip-net_cre_amip_m4K)/4
 print("amip cre fb a: "+amip_cre_fb_a)
 print("amip cre fb b: "+amip_cre_fb_b)

 net_cre_aqua   =dim_avg_n(cre_net_aqua,0)
 print("net cre aqua = "+net_cre_aqua)
 net_cre_aquap4K=dim_avg_n(cre_net_aqua_p4K,0)
 print("net cre aqua+4K = "+net_cre_aquap4K)

 aqua_cre_fb=(net_cre_aquap4K-net_cre_aqua)/4
 print("net cre aqua: "+aqua_cre_fb)

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
 plot(0)=plot0a

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

;-------------------------------------------------------------------------
end

