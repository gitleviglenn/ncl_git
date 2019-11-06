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
; variables to read: 
  varname1="cllcalipso"
  varname2="clmcalipso"
  varname3="clhcalipso"
  ; path to data on mac
  path_on_mac="/Users/silvers/data/cfmip_clouds/"
  ;
  path_to_data=path_on_mac
;***********************************************************************************

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
 
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; read data from files 
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  ;expname="amip"
  infile_l=path_to_data+filetoread_amip_l
  infile_m=path_to_data+filetoread_amip_m
  infile_h=path_to_data+filetoread_amip_h
  ;expname="amip-p4K"
  infile1_l=path_to_data+filetoread_amp4_l
  infile1_m=path_to_data+filetoread_amp4_m
  infile1_h=path_to_data+filetoread_amp4_h
  ;expname="amip-p4K"
  infile2_l=path_to_data+filetoread_amm4_l
  infile2_m=path_to_data+filetoread_amm4_m
  infile2_h=path_to_data+filetoread_amm4_h
;
  data_l = addfile(infile_l,"r")
  data_m = addfile(infile_m,"r")
  data_h = addfile(infile_h,"r")

  data_1_l = addfile(infile1_l,"r")
  data_1_m = addfile(infile1_m,"r")
  data_1_h = addfile(infile1_h,"r")
print("what is this file name>? "+infile1_m)

  ; read data

  ; read latitude dimensions from model
  latitude=data_1_l->lat(:)

    var_l_full = data_l->$varname1$(:,:,:) ; low clouds from exp a
    var_m_full = data_m->$varname2$(:,:,:) ; low clouds from exp a
    var_h_full = data_h->$varname3$(:,:,:) ; low clouds from exp a
print("dimsizes of amip data are: "+dimsizes(var_l_full))

    var1_l_full = data_1_l->$varname1$(:,:,:) ; low clouds from exp a
print("dimsizes of amip p4k data are: "+dimsizes(var1_l_full))
    var1_l_tmn=dim_avg_n(var1_l_full,0) ; average over time
    var1_m_full = data_1_m->$varname2$(:,:,:) ; mid clouds from exp a
    var1_m_tmn=dim_avg_n(var1_m_full,0)
    var1_h_full = data_1_h->$varname3$(:,:,:) ; high clouds from exp a
    var1_h_tmn=dim_avg_n(var1_h_full,0)

  ; the dimensions appear to get overwritten when the dim_avg_n function is used
  ;  var1_l_tmn!0="lat"
  ;  var1_l_tmn&lat=var1_l_full&lat
  ;  var1_l_tmn!1="lon"
  ;  var1_l_tmn&lon=var1_l_full&lon

    var1_l_ztmn=dim_avg_n(var1_l_tmn,1)
    var1_m_ztmn=dim_avg_n(var1_m_tmn,1)
    var1_h_ztmn=dim_avg_n(var1_h_tmn,1)

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

    colors = (/"black","darkgoldenrod","darkolivegreen3","steelblue"/) 
    lgres@lgLineColors  = (/colors(1),colors(2),colors(3),colors(0)/)
    lgres@lgDashIndexes = (/"0","0","0","0"/)

    title_lg1="stop"
    title_lg2="over"
    title_lg3="out"
    labels = (/title_lg1,title_lg2,title_lg3,"Observations"/) ; bottom to top

    res@gsnDraw         = False
    res@gsnFrame         = False
  
      res@trYMinF = 15
      res@trYMaxF = 55
      res@xyLineColors=colors(0)
      plot0a=gsn_csm_xy(wks,latitude(:),var1_h_ztmn(:),res)
;      plot0a=gsn_csm_xy(wks,latitude(:),var3calscale_zmn(:),res)
;      res@xyLineColors=colors(1)
;      plot0b=gsn_csm_xy(wks,latitude(:),var3_90x180_zmn(:),res)
;      res@xyLineColors=colors(2)
;      plot0c=gsn_csm_xy(wks,latitude(:),var3s_90x180_zmn(:),res)
;      res@xyLineColors=colors(3)
;      plot0d=gsn_csm_xy(wks,latitude(:),var3u_90x180_zmn(:),res)

    plot(0)=plot0a

      res@trYMinF = 0
      res@trYMaxF = 40
      res@tiMainString = "Mid-Level Cloud Fraction"
      res@xyLineColors=colors(0)
      plot1a=gsn_csm_xy(wks,latitude(:),var1_m_ztmn(:),res)
;      plot1a=gsn_csm_xy(wks,latitude(:),var2calscale_zmn(:),res)
;      res@xyLineColors=colors(1)
;      plot1b=gsn_csm_xy(wks,latitude(:),var2_90x180_zmn(:),res)
;      res@xyLineColors=colors(2)
;      plot1c=gsn_csm_xy(wks,latitude(:),var2s_90x180_zmn(:),res)
;      res@xyLineColors=colors(3)
;      plot1d=gsn_csm_xy(wks,latitude(:),var2u_90x180_zmn(:),res)

    plot(1)=plot1a

      res@trYMinF = 5 
      res@trYMaxF = 70 
      res@xyLineColors=colors(0)
      res@tiMainString = "Low-Level Cloud Fraction"
      ;plot2a=gsn_csm_xy(wks,latitude(:),var1calscale_zmn(:),res)
      plot2a=gsn_csm_xy(wks,latitude(:),var1_l_ztmn(:),res)
      ;res@xyLineColors=colors(1)
      ;res@xyDashPattern="0"
      ;plot2c=gsn_csm_xy(wks,latitude_model(:),var1_zmn(:),res)
      ;res@xyLineColors=colors(2)
      ;res@xyDashPattern="0"
      ;plot2d=gsn_csm_xy(wks,latitude_model(:),var1s_zmn(:),res)
      ;res@xyLineColors=colors(3)
      ;res@xyDashPattern="0"
      ;plot2e=gsn_csm_xy(wks,latitude_model(:),var1u_zmn(:),res)

    plot(2)=plot2a

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
    legend  = gsn_create_legend (wks, 4, labels, lgres)
    resP                 = True
    resP@amJust = "BottomRight"
    ;resP@amParallelPosF   = 0.42    ; Move legend to right
    resP@amParallelPosF   = -0.12    ; Move legend to right
    resP@amOrthogonalPosF = -0.12     ; Move legend down
  
    annoid = gsn_add_annotation(plot0a,legend,resP) ; add legend to plot
  
    gsn_panel(wks,plot,(/3,1/),resP)

end
