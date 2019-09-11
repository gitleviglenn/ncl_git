;***********************************************************************************
; alpha_tseries.ncl
;***********************************************************************************
;***********************************************************************************
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************************************************
begin
;***********************************************************************************

datapath="~/data/amip_Long/"
infile1=datapath+"armlane.nc"
f1=addfile(infile1,"r")
print("incoming file is: "+infile1)
; from file 1
  alpha_am4_f1           = f1->alpha_ensmbr_am4(:,:) 
  alpha_ensmn_am4_f1     = f1->alpha_ensmn_am4(:) 
  alpha_am3_f1           = f1->alpha_ensmbr_am3(:,:) 
  alpha_ensmn_am3_f1     = f1->alpha_ensmn_am3(:) 
  alpha_am2_f1           = f1->alpha_ensmbr_am2(:,:) 
  alpha_ensmn_am2_f1     = f1->alpha_ensmn_am2(:) 
  time           = f1->TIME(:) 


wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
gsn_define_colormap(wks,"CBR_drywet")
plot = new(1,graphic)

res                   = True
res@trYMinF           = -3.5
res@trYMaxF           = 0.0
res@trXMinF           = 1885
res@trXMaxF           = 1990
res@tiMainString      = "watch it mr"
res@tmYROn            = False
res@tmXTOn            = False
res@tmXTBorderOn      = False
res@tmYRBorderOn      = False
res@gsnFrame          = False

scalef=-1.

;res@xyLineColors  = colors(1)
res@xyLineColors  = "black"
ens1 = gsn_csm_xy(wks,time,scalef*alpha_am4_f1(:,0),res)
ens2 = gsn_csm_xy(wks,time,scalef*alpha_am4_f1(:,1),res)
ens3 = gsn_csm_xy(wks,time,scalef*alpha_am4_f1(:,2),res)
ens4 = gsn_csm_xy(wks,time,scalef*alpha_am4_f1(:,3),res)
ens5 = gsn_csm_xy(wks,time,scalef*alpha_am4_f1(:,4),res)
res@xyLineThicknessF   = 3.0
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

res@xyLineThicknessF   = 1.0
;res@xyLineColors  = colors(2)
res@xyLineColors  = "red"
ens6 = gsn_csm_xy(wks,time,scalef*alpha_am3_f1(:,0),res)
ens7 = gsn_csm_xy(wks,time,scalef*alpha_am3_f1(:,1),res)
ens8 = gsn_csm_xy(wks,time,scalef*alpha_am3_f1(:,2),res)
ens9 = gsn_csm_xy(wks,time,scalef*alpha_am3_f1(:,3),res)
ens10 = gsn_csm_xy(wks,time,scalef*alpha_am3_f1(:,4),res)
res@xyLineThicknessF   = 3.0
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineThicknessF   = 1.0
;res@xyLineColors  = colors(3)
res@xyLineColors  = "blue"
ens11 = gsn_csm_xy(wks,time,scalef*alpha_am2_f1(:,0),res)
ens12 = gsn_csm_xy(wks,time,scalef*alpha_am2_f1(:,1),res)
ens13 = gsn_csm_xy(wks,time,scalef*alpha_am2_f1(:,2),res)
ens14 = gsn_csm_xy(wks,time,scalef*alpha_am2_f1(:,3),res)
ens15 = gsn_csm_xy(wks,time,scalef*alpha_am2_f1(:,4),res)
res@xyLineThicknessF   = 3.0
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

;overlay(ens1,ens2);,ens3,ens4,ens5)

;draw(ens1)
frame(wks)

end
