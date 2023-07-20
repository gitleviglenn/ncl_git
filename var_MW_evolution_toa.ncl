load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; var_MW_evolution_toa.ncl
;
; paths to cmip style processed data: 
; /glade/scratch/levi/RCEMIP/CAM5_GCM/RCE_large300/
;
; paths to the pre-CMIP-stype output data: 
; /glade/scratch/kareed/RCEMIP/CAM5_GCM_RCE_large295/run/
;
; experiments were integrated for 3 years.  the precip data plotted is hourly
; therefore we have 26281 time steps. 17520 corresponds to two years.
;
; how many statistically independent samples do we have in the data?  I would guess 
; that each hour is not independent, but probably each 4-6 hours are. 4x per day?
;
; 4 independent samples per day gives 4*730 = 2,920 independent samples
; how sensitive is our ttest to this number? test it for 1460 independent samples too.
; 
; levi silvers                                                      may 2023
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; read in variable name then read in the appropriate 12 files

;  print("filen is: "+filen)
  print("pathn is: "+pathn)
  print("varn  is: "+varn)

;path2="MockW_0p625K_cos_295_3yr/0D/"

;filename_in=path+"CAM6_GCM_RCEmip_3KW1_2D_wap500.nc"

testpath="/glade/scratch/levi/RCEMIPII/CAM6/MockW_1p25K_cos_300_3yr/0D/"
bfile   ="CAM6_MockW_1p25K_cos_300_3yr_0D_"
; f_in_a=/glade/scratch/levi/RCEMIPII/CAM6/MockW_1p25K_cos_300_3yr/0D/CAM6_MockW_1p25K_cos_300_3yr_0D_rsdt_avg.nc

; variable names for the radiative fluxes:
vars=(/"rsdt_avg","rsut_avg","rlut_avg","rsutcs_avg","rlutcs_avg"/)

; varnames and parameters
time1=1
time2=17520
;time2=26279

s1="CAM6_MockW_"
s2="3yr_0D_"
t1="_295_"
t2="_300_"
t3="_305_"

; SST gradients:
g1="0p625K"
g2="1p25K"
g3="2p5K"
g4="5K"

do i = 0,4
  fpath = systemfunc("ls "+testpath+bfile+vars(0)+".nc")
  fdata = addfile(fpath,"r")
    print("file being read is: "+fpath)
  fdims = fdata->rsdt_avg(time1:time2) 
end do

ntimes = dimsizes(fdims)

; create arrays to hold the time series
avg_pr_new = new ( (/12,ntimes/), double) 
avg_toa    = new ( (/5,12,ntimes/), double) 
avg_r_toa  = new ( (/12,ntimes/), double) 

; path names
patha="MockW_"+g1+"_cos"+t1+"3yr/0D/"
pathb="MockW_"+g2+"_cos"+t1+"3yr/0D/"
pathc="MockW_"+g3+"_cos"+t1+"3yr/0D/"
pathd="MockW_"+g4+"_cos"+t1+"3yr/0D/"
pathe="MockW_"+g1+"_cos"+t2+"3yr/0D/"
pathf="MockW_"+g2+"_cos"+t2+"3yr/0D/"
pathg="MockW_"+g3+"_cos"+t2+"3yr/0D/"
pathh="MockW_"+g4+"_cos"+t2+"3yr/0D/"
pathi="MockW_"+g1+"_cos"+t3+"3yr/0D/"
pathj="MockW_"+g2+"_cos"+t3+"3yr/0D/"
pathk="MockW_"+g3+"_cos"+t3+"3yr/0D/"
pathl="MockW_"+g4+"_cos"+t3+"3yr/0D/"



maintitle=varn

; first need of varn/vars?

do i = 0,4
  ;fpath = systemfunc("ls "+testpath+bfile+vars(i)+".nc")
  ;fdata = addfile(fpath,"r")
  ;  print("file being read is: "+fpath)

  f1 = patha+s1+"0p625K_cos"+t1+s2+vars(i)+".nc"
  f2 = pathb+s1+"1p25K_cos"+t1+s2+vars(i)+".nc"
  f3 = pathc+s1+"2p5K_cos"+t1+s2+vars(i)+".nc"
  f4 = pathd+s1+"5K_cos"+t1+s2+vars(i)+".nc"
  f5 = pathe+s1+"0p625K_cos"+t2+s2+vars(i)+".nc"
  f6 = pathf+s1+"1p25K_cos"+t2+s2+vars(i)+".nc"
  f7 = pathg+s1+"2p5K_cos"+t2+s2+vars(i)+".nc"
  f8 = pathh+s1+"5K_cos"+t2+s2+vars(i)+".nc"
  f9 = pathi+s1+"0p625K_cos"+t3+s2+vars(i)+".nc"
  f10 = pathj+s1+"1p25K_cos"+t3+s2+vars(i)+".nc"
  f11 = pathk+s1+"2p5K_cos"+t3+s2+vars(i)+".nc"
  f12 = pathl+s1+"5K_cos"+t3+s2+vars(i)+".nc"
  
  f1_in=pathn+f1
  f2_in=pathn+f2
  f3_in=pathn+f3
  f4_in=pathn+f4
  f5_in=pathn+f5
  f6_in=pathn+f6
  f7_in=pathn+f7
  f8_in=pathn+f8
  f9_in=pathn+f9
  f10_in=pathn+f10
  f11_in=pathn+f11
  f12_in=pathn+f12

  print("infile is: "+f1_in)
  file1 = addfile(f1_in,"r")
  file2 = addfile(f2_in,"r")
  file3 = addfile(f3_in,"r")
  file4 = addfile(f4_in,"r")
  file5 = addfile(f5_in,"r")
  file6 = addfile(f6_in,"r")
  file7 = addfile(f7_in,"r")
  file8 = addfile(f8_in,"r")
  file9 = addfile(f9_in,"r")
  file10 = addfile(f10_in,"r")
  file11 = addfile(f11_in,"r")
  file12 = addfile(f12_in,"r")

  scale = 86.4e3
;vars=(/"rsdt_avg","rsut_avg","rlut_avg","rsutcs_avg","rlutcs_avg"/)
  if (vars(i).eq."rsdt_avg") then
    field1 = file1->rsdt_avg(time1:time2)
    field2 = file2->rsdt_avg(time1:time2)
    field3 = file3->rsdt_avg(time1:time2)
    field4 = file4->rsdt_avg(time1:time2)
    field5 = file5->rsdt_avg(time1:time2)
    field6 = file6->rsdt_avg(time1:time2)
    field7 = file7->rsdt_avg(time1:time2)
    field8 = file8->rsdt_avg(time1:time2)
    field9 = file9->rsdt_avg(time1:time2)
    field10 = file10->rsdt_avg(time1:time2)
    field11 = file11->rsdt_avg(time1:time2)
    field12 = file12->rsdt_avg(time1:time2)
    times  = file1->time ;(0:365*6-1) ;(365*4:ntime-1)
    print("reading from rsdt_avg")
  end if
  if (vars(i).eq."rlut_avg") then
    field1 = file1->rlut_avg(time1:time2)
    field2 = file2->rlut_avg(time1:time2)
    field3 = file3->rlut_avg(time1:time2)
    field4 = file4->rlut_avg(time1:time2)
    field5 = file5->rlut_avg(time1:time2)
    field6 = file6->rlut_avg(time1:time2)
    field7 = file7->rlut_avg(time1:time2)
    field8 = file8->rlut_avg(time1:time2)
    field9 = file9->rlut_avg(time1:time2)
    field10 = file10->rlut_avg(time1:time2)
    field11 = file11->rlut_avg(time1:time2)
    field12 = file12->rlut_avg(time1:time2)
    print("reading from rlut_avg")
  end if
  if (vars(i).eq."rlutcs_avg") then
    field1 = file1->rlutcs_avg(time1:time2)
    field2 = file2->rlutcs_avg(time1:time2)
    field3 = file3->rlutcs_avg(time1:time2)
    field4 = file4->rlutcs_avg(time1:time2)
    field5 = file5->rlutcs_avg(time1:time2)
    field6 = file6->rlutcs_avg(time1:time2)
    field7 = file7->rlutcs_avg(time1:time2)
    field8 = file8->rlutcs_avg(time1:time2)
    field9 = file9->rlutcs_avg(time1:time2)
    field10 = file10->rlutcs_avg(time1:time2)
    field11 = file11->rlutcs_avg(time1:time2)
    field12 = file12->rlutcs_avg(time1:time2)
    print("reading from rlutcs_avg")
  end if
  if (vars(i).eq."rsutcs_avg") then
    field1 = file1->rsutcs_avg(time1:time2)
    field2 = file2->rsutcs_avg(time1:time2)
    field3 = file3->rsutcs_avg(time1:time2)
    field4 = file4->rsutcs_avg(time1:time2)
    field5 = file5->rsutcs_avg(time1:time2)
    field6 = file6->rsutcs_avg(time1:time2)
    field7 = file7->rsutcs_avg(time1:time2)
    field8 = file8->rsutcs_avg(time1:time2)
    field9 = file9->rsutcs_avg(time1:time2)
    field10 = file10->rsutcs_avg(time1:time2)
    field11 = file11->rsutcs_avg(time1:time2)
    field12 = file12->rsutcs_avg(time1:time2)
    print("reading from rsutcs_avg")
  end if
  if (vars(i).eq."rsut_avg") then
    field1 = file1->rsut_avg(time1:time2)
    field2 = file2->rsut_avg(time1:time2)
    field3 = file3->rsut_avg(time1:time2)
    field4 = file4->rsut_avg(time1:time2)
    field5 = file5->rsut_avg(time1:time2)
    field6 = file6->rsut_avg(time1:time2)
    field7 = file7->rsut_avg(time1:time2)
    field8 = file8->rsut_avg(time1:time2)
    field9 = file9->rsut_avg(time1:time2)
    field10 = file10->rsut_avg(time1:time2)
    field11 = file11->rsut_avg(time1:time2)
    field12 = file12->rsut_avg(time1:time2)
    print("reading from rsut_avg")
  end if

  ;printVarSummary(field1)

  print("----------------------------------------------")
  print("varname is: "+vars(i))
  print(min(min(min(field1))))
  print(max(max(max(field1))))
  print("----------------------------------------------")

  avg_pr_new(0,:)  = scale*field1(:)
  avg_pr_new(1,:)  = scale*field2(:)
  avg_pr_new(2,:)  = scale*field3(:)
  avg_pr_new(3,:)  = scale*field4(:)
  avg_pr_new(4,:)  = scale*field5(:)
  avg_pr_new(5,:)  = scale*field6(:)
  avg_pr_new(6,:)  = scale*field7(:)
  avg_pr_new(7,:)  = scale*field8(:)
  avg_pr_new(8,:)  = scale*field9(:)
  avg_pr_new(9,:)  = scale*field10(:)
  avg_pr_new(10,:) = scale*field11(:)
  avg_pr_new(11,:) = scale*field12(:)

  avg_toa(i,0,:)  = field1(:)
  avg_toa(i,1,:)  = field2(:)
  avg_toa(i,2,:)  = field3(:)
  avg_toa(i,3,:)  = field4(:)
  avg_toa(i,4,:)  = field5(:)
  avg_toa(i,5,:)  = field6(:)
  avg_toa(i,6,:)  = field7(:)
  avg_toa(i,7,:)  = field8(:)
  avg_toa(i,8,:)  = field9(:)
  avg_toa(i,9,:)  = field10(:)
  avg_toa(i,10,:) = field11(:)
  avg_toa(i,11,:) = field12(:)

end do

; end cycling over nvar here...

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

; calculate net r at toa
avg_r_toa(:,:)=avg_toa(0,:,:)-avg_toa(1,:,:)-avg_toa(2,:,:)

; compute running mean
; for hourly output, averaging over 240 tsteps is a 10 day running mean.
avg_pr_runave     =runave_n_Wrap(avg_pr_new,120,0,1)
avg_r_toa_runave  =runave_n_Wrap(avg_r_toa,120,0,1)
avg_toa_runave    =runave_n_Wrap(avg_toa,120,0,2)

;;******************************************************
;; create plot
;;******************************************************
wks = gsn_open_wks("eps","evolMW_toa_ts_200d")               ; open workstation
gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
plot = new(1,graphic)

res                        = True         ; plot modifications desired

res@gsnDraw                = False        ; should draw later, after overlaying
res@gsnFrame               = False

res@xyLineColors           = (/"paleturquoise3","paleturquoise3","paleturquoise3","paleturquoise3","palegreen3","palegreen3","palegreen3","palegreen3","palevioletred3","palevioletred3","palevioletred3","palevioletred3"/)
res@xyLineThicknesses      = (/2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5/)
res@xyDashPatterns         =(/0,1,2,3,0,1,2,3,0,1,2,3/)
res@tiYAxisString          = "Rad Fluxes (W/m2)"
res@tiXAxisString          = "days"

res@trXMinF                =  0.0
res@trXMaxF                =  1090.0 ; 1095 days = 3 years
;res@trYMinF                =  1.0
;res@trYMaxF                =  5.0

res@tmXTOn = False
res@tmXTBorderOn = False
res@tmYROn = False
res@tmYRBorderOn = False
res@tmXBMinorOn = False
res@tmYLMinorOn = False


res@vpWidthF               = 0.7
res@vpHeightF              = 0.35

print("dimensions of avg_pr_runave are: "+dimsizes(avg_pr_runave))
print("dimensions of avg_toa_runave are: "+dimsizes(avg_toa_runave))
print("dimensions of avg_r_toa_runave are: "+dimsizes(avg_r_toa_runave))
print("size of times is: "+dimsizes(times))
  ;plot(0)   = gsn_csm_xy(wks,time5/365,avg_pr,res)
  ;plot(0)   = gsn_csm_xy(wks,times(time1:time2)/24,avg_pr_runave,res)
  ;plot(0)   = gsn_csm_xy(wks,times(time1:time2),avg_toa_runave(1,:,:),res)
  plot(0)   = gsn_csm_xy(wks,times(time1:time2),avg_r_toa_runave,res)
;;;

; from cam_prw_pdf.ncl
  lgres                    = True
  lgres@lgAutoManage       = True; defualt is true
res@xyLineColors           = (/"paleturquoise3","paleturquoise3","paleturquoise3","paleturquoise3","palegreen3","palegreen3","palegreen3","palegreen3","palevioletred3","palevioletred3","palevioletred3","palevioletred3"/)
  lgres@lgLineColors       = (/"black","black","black","black"/)    
  lgres@vpWidthF           = 0.22                   ; width of legend (NDC)
  lgres@vpHeightF          = 0.08                   ; height of legend (NDC)
  lgres@lgPerimOn          = False                 ; turn off perimeter
  lgres@lgDashIndexes      = (/0,1,2,3/)              ; dash indexes
  lgres@lgLineLabelStrings = (/"","","",""/)             ; no labels in lines
  lgres@lgLineThicknessF   = 4.0
  lgres@lgLabelFontHeightF = 0.1
  lgres@lgLabelFont        = 12                      ; specifies the font used in the legend
  lgres@lgBoxMinorExtentF  = .2
; x,y  
  gsn_legend_ndc(wks,4,(/" 0.625K"," 1.25K"," 2.5K"," 5K"/),.35,.55,lgres)

 draw(plot(0)) 

 frame(wks)

end
;







