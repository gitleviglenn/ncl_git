;-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; streamline_simple.ncl
;
; plot wind data from ERA5 for Lesley Thorne's review paper
;
; contours of the wind magnitude are filled with warm colors and streamlines
; of the wind direction are overlayed
;
; lat/lon lines are plotted every 30 degrees
;
; 1 panel is plotted.  monthly means are computed so that a 3 month mean 
; can be plotted for example, for DJF or JJA.
;
; levi silvers                                                       mar 2023
;-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

begin

datapath="~/data/ERA5/"
filename="era5_monthly_1959to2022.nc"

infile=datapath+filename

  f = addfile(infile,"r")

ntimes=767
  ur1    = f->u10(0:ntimes:12,0,::-1,:)    ; read in example data [2D only here]
  ur2    = f->u10(1:ntimes:12,0,::-1,:)    
  ur3    = f->u10(2:ntimes:12,0,::-1,:)    
  ur12   = f->u10(11:ntimes:12,0,::-1,:)    
;  vrf    = f->v10(:,0,::-1,:)
  vr1    = f->v10(0:ntimes:12,0,::-1,:)
  vr2    = f->v10(1:ntimes:12,0,::-1,:)
  vr3    = f->v10(2:ntimes:12,0,::-1,:)
  vr12   = f->v10(11:ntimes:12,0,::-1,:)
;  magf   = f->si10(:,0,::-1,:)          
  mag1   = f->si10(1:ntimes:12,0,::-1,:)          
  mag2   = f->si10(2:ntimes:12,0,::-1,:)          
  mag12  = f->si10(11:ntimes:12,0,::-1,:)          

  urf    = f->u10(:,0,::-1,:)    ; read in example data [2D only here]
  uf = short2flt(urf); 
  u1 = short2flt(ur1); jan
  u2 = short2flt(ur2); feb
  u3 = short2flt(ur3); mar
  u12= short2flt(ur12); dec
;  vf = short2flt(vrf)
  v1 = short2flt(vr1)
  v2 = short2flt(vr2)
  v3 = short2flt(vr3)
  v12= short2flt(vr12)
;  wsf = short2flt(magf) ; wind speed (m/s)
  ws1 = short2flt(mag1) ; wind speed (m/s)
  ws2 = short2flt(mag2) ; wind speed (m/s)
  ws12= short2flt(mag12) ; wind speed (m/s)

printVarSummary(u1)
printVarSummary(ws1)

;; averate over time dimension
;fulla    = f->u10(:,0,:,:)    ; read in example data [2D only here]
;uf = short2flt(fulla); 
;printVarSummary(fulla)
;u_10m_tmn_f   = dim_avg_n_Wrap(uf,0)
;printVarSummary(u_10m_tmn_f)
;fulla    = f->v10(:,0,:,:)    ; read in example data [2D only here]
;uf = short2flt(fulla); 
;v_10m_tmn_f   = dim_avg_n_Wrap(uf,0)
;fulla    = f->si10(:,0,:,:)    ; read in example data [2D only here]
;uf = short2flt(fulla); 
;ws_10m_tmn_f   = dim_avg_n_Wrap(uf,0)

u_10m_tmn_1   = dim_avg_n_Wrap(u1,0)
u_10m_tmn_2   = dim_avg_n_Wrap(u2,0)
;u_10m_tmn_6 = dim_avg_n_Wrap(u5,0)
;u_10m_tmn_7 = dim_avg_n_Wrap(u6,0)
;u_10m_tmn_8 = dim_avg_n_Wrap(u7,0)
u_10m_tmn_12  = dim_avg_n_Wrap(u12,0)
;v_10m_tmn_f   = dim_avg_n_Wrap(vf,0)
v_10m_tmn_1   = dim_avg_n_Wrap(v1,0)
v_10m_tmn_2   = dim_avg_n_Wrap(v2,0)
v_10m_tmn_12  = dim_avg_n_Wrap(v12,0)
;ws_10m_tmn_f  = dim_avg_n_Wrap(wsf,0)
ws_10m_tmn_1  = dim_avg_n_Wrap(ws1,0)
ws_10m_tmn_2  = dim_avg_n_Wrap(ws2,0)
ws_10m_tmn_12 = dim_avg_n_Wrap(ws12,0)

u_djf = (u_10m_tmn_1+u_10m_tmn_2+u_10m_tmn_12)/3
v_djf = (v_10m_tmn_1+v_10m_tmn_2+v_10m_tmn_12)/3
ws_djf = (ws_10m_tmn_1+ws_10m_tmn_2+ws_10m_tmn_12)/3

u_djf!0="latitude"
u_djf&latitude=u1&latitude
u_djf!1="longitude"
u_djf&longitude=u1&longitude
v_djf!0="latitude"
v_djf&latitude=v1&latitude
v_djf!1="longitude"
v_djf&longitude=v1&longitude
ws_djf!0="latitude"
ws_djf&latitude=ws1&latitude
ws_djf!1="longitude"
ws_djf&longitude=ws1&longitude

printVarSummary(u_djf)

  res                      = True               ; plot mods desired

my_levels_omega= (/5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15/); 21
;res@cnLevelFlags=(/"LineOnly","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine", \
res@cnLevelFlags=(/"NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine", \
                     "NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine","NoLine"/)
my_colors_posneg = (/ 2,26,39,51,63,75,87,99,111,123,135,147,159,171,183,190,200,210,220,230,240,250/); 22


  wks  = gsn_open_wks("eps","stream_10mWind")           ; send graphics to PNG file
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")

  res                      = True               ; plot mods desired
  res@mpProjection         = "Mollweide"       ; choose projection
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpCenterLonF      = 200.
  res@mpGridAndLimbOn      = True
  res@mpGridPolarLonSpacingF = 30.
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpLandFillColor       = "black"   

  res@cnFillOn          = True              ; color plot desired
  res@cnMonoLevelFlag   = False
  res@cnLinesOn         = True
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLineThicknessF  = 2.5
  res@tiMainString      = "ERA5 10m Wind DJF"
  res@tiMainFontHeightF  = .020                               ; font height
  res@cnLevels          = my_levels_omega
  res@cnFillColors      = my_colors_posneg
  res@cnFillOn          = True
  res@gsnTickMarksOn     = False


  ;res@stMinDistanceF     = 0.02
  res@stMinDistanceF     = 0.04
  res@stArrowStride      = 10; draws fewer arroys by skipping grid boxes; 5 seems to be a bit too much
  ;res@stArrowLengthF     = 0.004; this would be my preference
  res@stArrowLengthF     = 0.008
  res@stLineThicknessF   = 1.5
;  res@stMinLineSpacingF  = 0.001; ? according to NDC coordinates: 0.0001 has too many arrows
; stMinLinSpacingF   --> 0.01 results in too few arrows and no streamlines
; stMinLinSpacingF   --> 0.001 results in arrows that are unequally spaced and too few streamlines
;  res@stStepSizeF        = 1; ?
;  res@stMinStepFactorF   = 19; default is 2.0; 19 is almost right, but creates more stmls than i like
; in the subtropical highs and too few in the Indian ocean...

  ;plot = gsn_csm_streamline_map_ce(wks,u_djf,v_djf,res)
  plot = gsn_csm_streamline_contour_map_ce(wks,u_djf,v_djf,ws_djf(:,:),res)
  ;plot = gsn_csm_streamline_contour_map_ce(wks,u_10m_tmn_f,v_10m_tmn_f,ws_10m_tmn_f(:,:),res)
  ;plot = gsn_csm_streamline_map(wks,u_djf,v_djf,res)

end
