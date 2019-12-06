;***********************************************************************************
; lowmedhigh.ncl
;***********************************************************************************
; plot cloud frac for low, med, and high clouds from CALIPSO sim for several exps.
;
; levi silvers 							nov 2019
;***********************************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************************************
begin
;
plotwarm=1  ; plotwarm = 0 corresponds to the figure with all experiments
;            1 plot a figure with only warming experiments
plotbias=1  ; plotbias = 0 is default and corresponds to plotting climatology
;
; variables to read: 
  varname1="cllcalipso"
  varname2="clmcalipso"
  varname3="clhcalipso"
  ; path to data on mac
  path_on_mac="/Users/silvers/data/cfmip_clouds/"
  ;
  path_to_data=path_on_mac
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

  ; historical coupled experiment
  filetoread_his_h="clhcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"
  filetoread_his_m="clmcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"
  filetoread_his_l="cllcalipso_CFmon_GFDL-CM4_historical_r1i1p1f1_gr1_195001-201412.nc"

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

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; define experiment paths and read data from files 
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; paths and names
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
  ;expname="historical coupled"
  infile3_l=path_to_data+filetoread_his_l
  infile3_m=path_to_data+filetoread_his_m
  infile3_h=path_to_data+filetoread_his_h
  ;expname="abrupt 4xCO2 coupled"
  infile4_l=path_to_data+filetoread_4xCO2_l
  infile4_m=path_to_data+filetoread_4xCO2_m
  infile4_h=path_to_data+filetoread_4xCO2_h
  ;expname="abrupt 4xCO2 coupled"
  infile5_l=path_to_data+filetoread_1pctCO2_l
  infile5_m=path_to_data+filetoread_1pctCO2_m
  infile5_h=path_to_data+filetoread_1pctCO2_h
;
; read data

; amip
print("amip data is: "+infile_l)
  data_l = addfile(infile_l,"r")
  data_m = addfile(infile_m,"r")
  data_h = addfile(infile_h,"r")

  var_l_full = data_l->$varname1$(:,:,:) ; low clouds from exp a
  var_l_tmn=dim_avg_n(var_l_full,0) ; average over time
  var_m_full = data_m->$varname2$(:,:,:) ; low clouds from exp a
  var_m_tmn=dim_avg_n(var_m_full,0) ; average over time
  var_h_full = data_h->$varname3$(:,:,:) ; low clouds from exp a
  var_h_tmn=dim_avg_n(var_h_full,0) ; average over time

  var_l_ztmn=dim_avg_n(var_l_tmn,1)
  var_m_ztmn=dim_avg_n(var_m_tmn,1)
  var_h_ztmn=dim_avg_n(var_h_tmn,1)

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

  var3_l_full = data_3_l->$varname1$(360::,:,:) ; low clouds from exp a
  ;var3_l_full = data_3_l->$varname1$(360:361,:,:) ; low clouds from exp a
  var3_l_tmn=dim_avg_n(var3_l_full,0) ; average over time
  var3_m_full = data_3_m->$varname2$(360::,:,:) ; mid clouds from exp a
  ;var3_m_full = data_3_m->$varname2$(360:361,:,:) ; mid clouds from exp a
  var3_m_tmn=dim_avg_n(var3_m_full,0)
  var3_h_full = data_3_h->$varname3$(360::,:,:) ; high clouds from exp a
  ;var3_h_full = data_3_h->$varname3$(360:361,:,:) ; high clouds from exp a
 ;printVarSummary(var3_h_full)
  var3_h_tmn=dim_avg_n(var3_h_full,0) ; 780 time steps...

  var3_l_ztmn=dim_avg_n(var3_l_tmn,1)
  var3_m_ztmn=dim_avg_n(var3_m_tmn,1)
  var3_h_ztmn=dim_avg_n(var3_h_tmn,1)

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
  data_5_l = addfile(infile5_l,"r")
  data_5_m = addfile(infile5_m,"r")
  data_5_h = addfile(infile5_h,"r")

  var5_l_full = data_5_l->$varname1$(:,:,:) ; low clouds from exp a
  var5_l_tmn=dim_avg_n(var5_l_full,0) ; average over time
  var5_m_full = data_5_m->$varname2$(:,:,:) ; mid clouds from exp a
  var5_m_tmn=dim_avg_n(var5_m_full,0)
  var5_h_full = data_5_h->$varname3$(:,:,:) ; high clouds from exp a
  var5_h_tmn=dim_avg_n(var5_h_full,0)

  var5_l_ztmn=dim_avg_n(var5_l_tmn,1)
  var5_m_ztmn=dim_avg_n(var5_m_tmn,1)
  var5_h_ztmn=dim_avg_n(var5_h_tmn,1)

;*************************************************************

; compute bias of cloud fields relative to a particular control exp.

;cont_exp=amip (var_l_ztmn, var_m_ztmn, var_h_ztmn)
  cont_l=var_l_ztmn
  cont_m=var_m_ztmn
  cont_h=var_h_ztmn
  
;  plotbias=1  ; plotbias = 0 is default and corresponds to plotting climatology
  if (plotbias .gt. 0) then
    var_l_ztmn=var_l_ztmn-cont_l
    var_m_ztmn=var_m_ztmn-cont_m
    var_h_ztmn=var_h_ztmn-cont_h

    var1_l_ztmn=var1_l_ztmn-cont_l
    var1_m_ztmn=var1_m_ztmn-cont_m
    var1_h_ztmn=var1_h_ztmn-cont_h
    
    var2_l_ztmn=var2_l_ztmn-cont_l
    var2_m_ztmn=var2_m_ztmn-cont_m
    var2_h_ztmn=var2_h_ztmn-cont_h
    
    var3_l_ztmn=var3_l_ztmn-cont_l
    var3_m_ztmn=var3_m_ztmn-cont_m
    var3_h_ztmn=var3_h_ztmn-cont_h
    
    var4_l_ztmn=var4_l_ztmn-cont_l
    var4_m_ztmn=var4_m_ztmn-cont_m
    var4_h_ztmn=var4_h_ztmn-cont_h
    
    var5_l_ztmn=var5_l_ztmn-cont_l
    var5_m_ztmn=var5_m_ztmn-cont_m
    var5_h_ztmn=var5_h_ztmn-cont_h
  end if

;*************************************************************
    wks = gsn_open_wks("eps","testplot")          ; send graphics to ps file
    plot = new(3,graphic)
  
  ; resources for the panels, and the legend
    res                        = True
    lgres                      = True

    fontsize=0.03
   
    res@tiMainString = "Upper-Level Cloud Fraction"
    res@tiMainFont = 21
    res@tiMainFontHeightF = fontsize
    res@tiYAxisString  = "Cloud Fraction [%]"
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

    colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue","mediumorchid3","darkslategray4","cyan3"/) 
    ;lgres@lgLineColors  = (/colors(1),colors(2),colors(3),colors(4),colors(5),colors(6)/)
    ;lgres@lgDashIndexes = (/"0","0","0","0","0","0"/)

    title_lg0="amip"
    title_lg1="amip +4K"
    title_lg2="amip -4K"
    title_lg3="historical"
    title_lg4="abrupt 4xCO2"
    title_lg5="1pctCO2"
    title_obs="CALIPSO"

if (plotwarm .lt. 1) then
    lgres@lgLineColors  = (/colors(1),colors(4),colors(0)/)
    ;lgres@lgDashIndexes = (/"0","0","0","0","0","0"/)
    lgres@lgDashIndexes = (/"0","0","0"/)
;    labels = (/title_lg0,title_lg1,title_lg2,title_lg3,title_lg4,title_obs/) ; bottom to top
;    labels = (/title_lg0,title_lg1,title_lg2,title_lg3,title_obs/) ; bottom to top
    labels = (/title_lg0,title_lg3,title_obs/) ; bottom to top
else ; warming experiments plotted
    lgres@lgLineColors  = (/colors(1),colors(2),colors(5),colors(6)/)
    lgres@lgDashIndexes = (/"0","0","0","0"/)
    labels = (/title_lg0,title_lg1,title_lg4,title_lg5/) ; bottom to top
end if

    res@gsnDraw         = False
    res@gsnFrame         = False
  
    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 15
      res@trYMaxF = 55
    end if
    res@xyLineColors=colors(0)
    plot0obs=gsn_csm_xy(wks,latitude_calip(:),var3calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    plot0a=gsn_csm_xy(wks,latitude(:),var_h_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot0b=gsn_csm_xy(wks,latitude(:),var1_h_ztmn(:),res)
    res@xyLineColors=colors(3)
    plot0c=gsn_csm_xy(wks,latitude(:),var2_h_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot0d=gsn_csm_xy(wks,latitude(:),var3_h_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot0e=gsn_csm_xy(wks,latitude(:),var4_h_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot0f=gsn_csm_xy(wks,latitude(:),var5_h_ztmn(:),res)

;    overlay(plot0a,plot0b)
    overlay(plot0a,plot0obs)
;    overlay(plot0a,plot0c)
    overlay(plot0a,plot0d)
    ;overlay(plot0a,plot0e)
    ;overlay(plot0a,plot0f)

if (plotwarm .lt. 1) then
    plot(0)=plot0a
end if

    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 0
      res@trYMaxF = 40
    end if
    res@tiMainString = "Mid-Level Cloud Fraction"
    res@xyLineColors=colors(0)
    plot1obs=gsn_csm_xy(wks,latitude_calip(:),var2calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    plot1a=gsn_csm_xy(wks,latitude(:),var_m_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot1b=gsn_csm_xy(wks,latitude(:),var1_m_ztmn(:),res)
    res@xyLineColors=colors(3)
    plot1c=gsn_csm_xy(wks,latitude(:),var2_m_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot1d=gsn_csm_xy(wks,latitude(:),var3_m_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot1e=gsn_csm_xy(wks,latitude(:),var4_m_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot1f=gsn_csm_xy(wks,latitude(:),var5_m_ztmn(:),res)

;    overlay(plot1a,plot1b)
    overlay(plot1a,plot1obs)
;    overlay(plot1a,plot1c)
    overlay(plot1a,plot1d)
    ;overlay(plot1a,plot1e)
    ;overlay(plot1a,plot1f)

if (plotwarm .lt. 1) then
    plot(1)=plot1a
end if

    if (plotbias .gt. 0) then
      res@trYMinF = -10
      res@trYMaxF = 10 
    else
      res@trYMinF = 5 
      res@trYMaxF = 70 
    end if
    res@xyLineColors=colors(0)
    plot2obs=gsn_csm_xy(wks,latitude_calip(:),var1calscale_zmn(:),res)
    res@xyLineColors=colors(1)
    res@tiMainString = "Low-Level Cloud Fraction"
    plot2a=gsn_csm_xy(wks,latitude(:),var_l_ztmn(:),res)
    res@xyLineColors=colors(2)
    plot2b=gsn_csm_xy(wks,latitude(:),var1_l_ztmn(:),res)
    res@xyLineColors=colors(3)
    plot2c=gsn_csm_xy(wks,latitude(:),var2_l_ztmn(:),res)
    res@xyLineColors=colors(4)
    plot2d=gsn_csm_xy(wks,latitude(:),var3_l_ztmn(:),res)
    res@xyLineColors=colors(5)
    plot2e=gsn_csm_xy(wks,latitude(:),var4_l_ztmn(:),res)
    res@xyLineColors=colors(6)
    plot2f=gsn_csm_xy(wks,latitude(:),var5_l_ztmn(:),res)

;    overlay(plot2a,plot2b)
    overlay(plot2a,plot2obs)
;    overlay(plot2a,plot2c)
    overlay(plot2a,plot2d)
    ;overlay(plot2a,plot2e)
    ;overlay(plot2a,plot2f)

if (plotwarm .lt. 1) then
    plot(2)=plot2a
end if

; make a warming plot....

if (plotwarm .gt. 0) then

  ;for top panel
  res@tiMainString = "Upper-Level Cloud Fraction"
  if (plotbias .gt. 0) then
    res@trYMinF = -10
    res@trYMaxF = 10 
  else
    res@trYMinF = 15
    res@trYMaxF = 55
  end if

  res@xyLineColors=colors(1)
  plot0a=gsn_csm_xy(wks,latitude(:),var_h_ztmn(:),res)
  overlay(plot0a,plot0b)
  overlay(plot0a,plot0e)
  overlay(plot0a,plot0f)
  plot(0)=plot0a

  ;for middle panel
  res@tiMainString = "Mid-Level Cloud Fraction"
  if (plotbias .gt. 0) then
    res@trYMinF = -10
    res@trYMaxF = 10 
  else
    res@trYMinF = 0
    res@trYMaxF = 40
  end if
  
  res@xyLineColors=colors(1)
  plot1a=gsn_csm_xy(wks,latitude(:),var_m_ztmn(:),res)
  overlay(plot1a,plot1b)
  overlay(plot1a,plot1e)
  overlay(plot1a,plot1f)
  plot(1)=plot1a

  res@tiMainString = "Low-Level Cloud Fraction"
  if (plotbias .gt. 0) then
    res@trYMinF = -10
    res@trYMaxF = 10 
  else
    res@trYMinF = 5 
    res@trYMaxF = 70 
  end if

  res@xyLineColors=colors(1)
  plot2a=gsn_csm_xy(wks,latitude(:),var_l_ztmn(:),res)
  overlay(plot2a,plot2b)
  overlay(plot2a,plot2e)
  overlay(plot2a,plot2d) ; i think this is the historical exp
  overlay(plot2a,plot2f)
  plot(2)=plot2a

  lgres@lgLineColors  = (/colors(1),colors(2),colors(5),colors(6)/)
  lgres@lgDashIndexes = (/"0","0","0","0"/)
end if


; add a legend
 
;    lgres                      = True
    lgres@xyLabelMode            = "Custom"
    lgres@xyLineLabelFontHeightF = 0.020                ; font height
    lgres@lgItemType           = "Lines"
    lgres@lgLabelFontHeightF   = .07
    lgres@vpWidthF             = 0.3        ; width of legend
    lgres@vpHeightF            = 0.20        ; height of legend
    lgres@lgLineThicknessF     = lthick
    lgres@lgPerimThicknessF    = 2.0
    lgres@lgMonoDashIndex      = False 
    lgres@lgPerimOn            = False
   
   ; draw panel with white space added
  if (plotwarm .gt. 0) then ; warming experiments
    legend  = gsn_create_legend (wks, 4, labels, lgres)
  else ; all experiments
    ;legend  = gsn_create_legend (wks, 5, labels, lgres)
    legend  = gsn_create_legend (wks, 3, labels, lgres)
  end if
    resP                 = True
    resP@amJust = "BottomRight"
    ;resP@amParallelPosF   = 0.42    ; Move legend to right
    resP@amParallelPosF   = -0.12    ; Move legend to right
    resP@amOrthogonalPosF = -0.12     ; Move legend down
  
    annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
  
    gsn_panel(wks,plot,(/3,1/),resP)

end
