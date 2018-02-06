;***********************************************************************************
; alpha_tseries.ncl
; 
; Function codes: see https://www.ncl.ucar.edu/Applications/fcodes.shtml
; for useful examples.  This is how I inserted superscipts in the axis labels
;
; filling between lines: border lines/ boundary lines/ edge of filled region
;                        for some reason it seems necessary to create a new res 
;                        for each panel or else the lower edge of the contour lines
;                        will be outlined.  I don't understand this.
;
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
;infile1=datapath+"armlane.nc"
infile1=datapath+"idiot_box3.nc"
;infile2=datapath+"whatisyourdamage.nc"
infile2=datapath+"quwindows.nc"
f1=addfile(infile1,"r")
f2=addfile(infile2,"r")
print("incoming file1 is: "+infile1)
print("incoming file2 is: "+infile2)
; from file 1
  alpha_am4_f1           = f1->alpha_ensmbr_am4(:,:) 
  alpha_ensmn_am4_f1     = f1->alpha_ensmn_am4(:) 
  alpha_am3_f1           = f1->alpha_ensmbr_am3(:,:) 
  alpha_ensmn_am3_f1     = f1->alpha_ensmn_am3(:) 
  alpha_am2_f1           = f1->alpha_ensmbr_am2(:,:) 
  alpha_ensmn_am2_f1     = f1->alpha_ensmn_am2(:) 

  alpha_cre_am4_f1           = f1->alpha_cre_ensmbr_am4(:,:) 
  alpha_clr_am4_f1           = f1->alpha_clr_ensmbr_am4(:,:) 
  alpha_cre_ensmn_am4_f1     = f1->alpha_cre_ensmn_am4(:) 
  alpha_clr_ensmn_am4_f1     = f1->alpha_clr_ensmn_am4(:) 
  alpha_lwcre_ensmn_am4_f1   = f1->alpha_lwcre_ensmn_am4(:) 
  alpha_lwcre_am4_f1         = f1->alpha_lwcre_ensmbr_am4(:,:) 
  alpha_swcre_ensmn_am4_f1   = f1->alpha_swcre_ensmn_am4(:) 
  alpha_swcre_am4_f1         = f1->alpha_swcre_ensmbr_am4(:,:) 
  alpha_cre_am3_f1           = f1->alpha_cre_ensmbr_am3(:,:) 
  alpha_clr_am3_f1           = f1->alpha_clr_ensmbr_am3(:,:) 
  alpha_cre_ensmn_am3_f1     = f1->alpha_cre_ensmn_am3(:) 
  alpha_clr_ensmn_am3_f1     = f1->alpha_clr_ensmn_am3(:) 
  alpha_lwcre_ensmn_am3_f1   = f1->alpha_lwcre_ensmn_am3(:) 
  alpha_lwcre_am3_f1         = f1->alpha_lwcre_ensmbr_am3(:,:) 
  alpha_swcre_ensmn_am3_f1   = f1->alpha_swcre_ensmn_am3(:) 
  alpha_swcre_am3_f1         = f1->alpha_swcre_ensmbr_am3(:,:) 
  alpha_cre_am2_f1           = f1->alpha_cre_ensmbr_am2(:,:) 
  alpha_clr_am2_f1           = f1->alpha_clr_ensmbr_am2(:,:) 
  alpha_cre_ensmn_am2_f1     = f1->alpha_cre_ensmn_am2(:) 
  alpha_clr_ensmn_am2_f1     = f1->alpha_clr_ensmn_am2(:) 
  alpha_lwcre_ensmn_am2_f1   = f1->alpha_lwcre_ensmn_am2(:) 
  alpha_lwcre_am2_f1         = f1->alpha_lwcre_ensmbr_am2(:,:) 
  alpha_swcre_ensmn_am2_f1   = f1->alpha_swcre_ensmn_am2(:) 
  alpha_swcre_am2_f1         = f1->alpha_swcre_ensmbr_am2(:,:) 

  alpha_lcc_am4_f1           = f1->alpha_lcc_ensmbr_am4(:,:) 
  alpha_lcc_ensmn_am4_f1     = f1->alpha_lcc_ensmn_am4(:) 
  alpha_lcc_am3_f1           = f1->alpha_lcc_ensmbr_am3(:,:) 
  alpha_lcc_ensmn_am3_f1     = f1->alpha_lcc_ensmn_am3(:) 
  alpha_lcc_am2_f1           = f1->alpha_lcc_ensmbr_am2(:,:) 
  alpha_lcc_ensmn_am2_f1     = f1->alpha_lcc_ensmn_am2(:) 

;----------------------------------
  boohiss = f2->alpha_window_am4(:,:,:)
ensnumber=4

am2_qucal_arr=new((/105,ensnumber+1/),float)
am2_quper_arr=new((/105,ensnumber+1/),float)
am2_qucan_arr=new((/105,ensnumber+1/),float)
am2_qunam1_arr=new((/105,ensnumber+1/),float)
am2_qunam2_arr=new((/105,ensnumber+1/),float)
am2_quaus_arr=new((/105,ensnumber+1/),float)

am2_ntrops_arr=new((/105,ensnumber+1/),float)
am2_strops_arr=new((/105,ensnumber+1/),float)
am2_satl_arr=new((/105,ensnumber+1/),float)
am2_sind_arr=new((/105,ensnumber+1/),float)
am2_epac_arr=new((/105,ensnumber+1/),float)
am2_trops1_arr=new((/105,ensnumber+1/),float)
am2_trops2_arr=new((/105,ensnumber+1/),float)
am2_trops3_arr=new((/105,ensnumber+1/),float)
am2_trops4_arr=new((/105,ensnumber+1/),float)
am2_trops5_arr=new((/105,ensnumber+1/),float)
am2_trops6_arr=new((/105,ensnumber+1/),float)

am2_tropsA_arr=new((/105,ensnumber+1/),float)
am2_tropsB1_arr=new((/105,ensnumber+1/),float)
am2_tropsB2_arr=new((/105,ensnumber+1/),float)
am2_tropsC_arr=new((/105,ensnumber+1/),float)
am2_tropsD_arr=new((/105,ensnumber+1/),float)
am2_tropsE_arr=new((/105,ensnumber+1/),float)
am2_tropsF_arr=new((/105,ensnumber+1/),float)
am2_tropsG_arr=new((/105,ensnumber+1/),float)
am2_tropsH_arr=new((/105,ensnumber+1/),float)
am2_tropsI_arr=new((/105,ensnumber+1/),float)
am2_tropsJ_arr=new((/105,ensnumber+1/),float)
am2_tropsK_arr=new((/105,ensnumber+1/),float)

am3_qucal_arr=new((/105,ensnumber+1/),float)
am3_quper_arr=new((/105,ensnumber+1/),float)
am3_qucan_arr=new((/105,ensnumber+1/),float)
am3_qunam1_arr=new((/105,ensnumber+1/),float)
am3_qunam2_arr=new((/105,ensnumber+1/),float)
am3_quaus_arr=new((/105,ensnumber+1/),float)

am3_ntrops_arr=new((/105,ensnumber+1/),float)
am3_strops_arr=new((/105,ensnumber+1/),float)
am3_satl_arr=new((/105,ensnumber+1/),float)
am3_sind_arr=new((/105,ensnumber+1/),float)
am3_epac_arr=new((/105,ensnumber+1/),float)
am3_trops1_arr=new((/105,ensnumber+1/),float)
am3_trops2_arr=new((/105,ensnumber+1/),float)
am3_trops3_arr=new((/105,ensnumber+1/),float)
am3_trops4_arr=new((/105,ensnumber+1/),float)
am3_trops5_arr=new((/105,ensnumber+1/),float)
am3_trops6_arr=new((/105,ensnumber+1/),float)

am3_tropsA_arr=new((/105,ensnumber+1/),float)
am3_tropsB1_arr=new((/105,ensnumber+1/),float)
am3_tropsB2_arr=new((/105,ensnumber+1/),float)
am3_tropsC_arr=new((/105,ensnumber+1/),float)
am3_tropsD_arr=new((/105,ensnumber+1/),float)
am3_tropsE_arr=new((/105,ensnumber+1/),float)
am3_tropsF_arr=new((/105,ensnumber+1/),float)
am3_tropsG_arr=new((/105,ensnumber+1/),float)
am3_tropsH_arr=new((/105,ensnumber+1/),float)
am3_tropsI_arr=new((/105,ensnumber+1/),float)
am3_tropsJ_arr=new((/105,ensnumber+1/),float)
am3_tropsK_arr=new((/105,ensnumber+1/),float)

am4_qucal_arr=new((/105,ensnumber+1/),float)
am4_quper_arr=new((/105,ensnumber+1/),float)
am4_qucan_arr=new((/105,ensnumber+1/),float)
am4_qunam1_arr=new((/105,ensnumber+1/),float)
am4_qunam2_arr=new((/105,ensnumber+1/),float)
am4_quaus_arr=new((/105,ensnumber+1/),float)

am4_ntrops_arr=new((/105,ensnumber+1/),float)
am4_strops_arr=new((/105,ensnumber+1/),float)
am4_satl_arr=new((/105,ensnumber+1/),float)
am4_sind_arr=new((/105,ensnumber+1/),float)
am4_epac_arr=new((/105,ensnumber+1/),float)
am4_trops1_arr=new((/105,ensnumber+1/),float)
am4_trops2_arr=new((/105,ensnumber+1/),float)
am4_trops3_arr=new((/105,ensnumber+1/),float)
am4_trops4_arr=new((/105,ensnumber+1/),float)
am4_trops5_arr=new((/105,ensnumber+1/),float)
am4_trops6_arr=new((/105,ensnumber+1/),float)

am4_tropsA_arr=new((/105,ensnumber+1/),float)
am4_tropsB1_arr=new((/105,ensnumber+1/),float)
am4_tropsB2_arr=new((/105,ensnumber+1/),float)
am4_tropsC_arr=new((/105,ensnumber+1/),float)
am4_tropsD_arr=new((/105,ensnumber+1/),float)
am4_tropsE_arr=new((/105,ensnumber+1/),float)
am4_tropsF_arr=new((/105,ensnumber+1/),float)
am4_tropsG_arr=new((/105,ensnumber+1/),float)
am4_tropsH_arr=new((/105,ensnumber+1/),float)
am4_tropsI_arr=new((/105,ensnumber+1/),float)
am4_tropsJ_arr=new((/105,ensnumber+1/),float)
am4_tropsK_arr=new((/105,ensnumber+1/),float)


do c=0,ensnumber
; AM4
  am4_ntrops_arr(:,c) = f2->alpha_window_am4(:,c,4)
  am4_strops_arr(:,c) = f2->alpha_window_am4(:,c,5)
; grap timeseries for the tropical windows
  am4_satl_arr(:,c)   = f2->alpha_window_am4(:,c,0)
  am4_sind_arr(:,c)   = f2->alpha_window_am4(:,c,1)
  am4_epac_arr(:,c)   = f2->alpha_window_am4(:,c,2)
; grap timeseries for the rest of the tropics
  am4_trops1_arr(:,c) = f2->alpha_window_am4(:,c,8)
  am4_trops2_arr(:,c) = f2->alpha_window_am4(:,c,9)
  am4_trops3_arr(:,c) = f2->alpha_window_am4(:,c,10)
  am4_trops4_arr(:,c) = f2->alpha_window_am4(:,c,11)
  am4_trops5_arr(:,c) = f2->alpha_window_am4(:,c,12)
  am4_trops6_arr(:,c) = f2->alpha_window_am4(:,c,13)
; from Qu et al.'s windows Letters need to be checked with window numbers!!!!!
  am4_tropsA_arr(:,c) = f2->alpha_window_am4(:,c,25)
  am4_tropsB1_arr(:,c)= f2->alpha_window_am4(:,c,26)
  am4_tropsB2_arr(:,c)= f2->alpha_window_am4(:,c,26)
  am4_tropsC_arr(:,c) = f2->alpha_window_am4(:,c,27)
  am4_tropsD_arr(:,c) = f2->alpha_window_am4(:,c,28)
  am4_tropsE_arr(:,c) = f2->alpha_window_am4(:,c,29)
  am4_tropsF_arr(:,c) = f2->alpha_window_am4(:,c,30)
  am4_tropsG_arr(:,c) = f2->alpha_window_am4(:,c,31)
  am4_tropsH_arr(:,c) = f2->alpha_window_am4(:,c,32)
  am4_tropsI_arr(:,c) = f2->alpha_window_am4(:,c,33)
  am4_tropsJ_arr(:,c) = f2->alpha_window_am4(:,c,35)
  am4_tropsK_arr(:,c) = f2->alpha_window_am4(:,c,36)
; shoudl be qu et al.'s tropical windows
  am4_qucal_arr(:,c)  = f2->alpha_window_am4(:,c,19)
  am4_quper_arr(:,c)  = f2->alpha_window_am4(:,c,20)
  am4_quaus_arr(:,c)  = f2->alpha_window_am4(:,c,21)
  am4_qunam1_arr(:,c) = f2->alpha_window_am4(:,c,22)
  am4_qunam2_arr(:,c) = f2->alpha_window_am4(:,c,23)
  am4_qucan_arr(:,c)  = f2->alpha_window_am4(:,c,24)

; AM3
  am3_ntrops_arr(:,c) = f2->alpha_window_am3(:,c,4)
  am3_strops_arr(:,c) = f2->alpha_window_am3(:,c,5)
; grap timeseries for the tropical windows
  am3_satl_arr(:,c)   = f2->alpha_window_am3(:,c,0)
  am3_sind_arr(:,c)   = f2->alpha_window_am3(:,c,1)
  am3_epac_arr(:,c)   = f2->alpha_window_am3(:,c,2)
; grap timeseries for the rest of the tropics
  am3_trops1_arr(:,c) = f2->alpha_window_am3(:,c,8)
  am3_trops2_arr(:,c) = f2->alpha_window_am3(:,c,9)
  am3_trops3_arr(:,c) = f2->alpha_window_am3(:,c,10)
  am3_trops4_arr(:,c) = f2->alpha_window_am3(:,c,11)
  am3_trops5_arr(:,c) = f2->alpha_window_am3(:,c,12)
  am3_trops6_arr(:,c) = f2->alpha_window_am3(:,c,13)
; from Qu et al.'s windows Letters need to be checked with window numbers!!!!!
  am3_tropsA_arr(:,c) = f2->alpha_window_am3(:,c,25)
  am3_tropsB1_arr(:,c)= f2->alpha_window_am3(:,c,26)
  am3_tropsB2_arr(:,c)= f2->alpha_window_am3(:,c,26)
  am3_tropsC_arr(:,c) = f2->alpha_window_am3(:,c,27)
  am3_tropsD_arr(:,c) = f2->alpha_window_am3(:,c,28)
  am3_tropsE_arr(:,c) = f2->alpha_window_am3(:,c,29)
  am3_tropsF_arr(:,c) = f2->alpha_window_am3(:,c,30)
  am3_tropsG_arr(:,c) = f2->alpha_window_am3(:,c,31)
  am3_tropsH_arr(:,c) = f2->alpha_window_am3(:,c,32)
  am3_tropsI_arr(:,c) = f2->alpha_window_am3(:,c,33)
  am3_tropsJ_arr(:,c) = f2->alpha_window_am3(:,c,35)
  am3_tropsK_arr(:,c) = f2->alpha_window_am3(:,c,36)
; shoudl be qu et al.'s tropical windows
  am3_qucal_arr(:,c)  = f2->alpha_window_am3(:,c,19)
  am3_quper_arr(:,c)  = f2->alpha_window_am3(:,c,20)
  am3_quaus_arr(:,c)  = f2->alpha_window_am3(:,c,21)
  am3_qunam1_arr(:,c) = f2->alpha_window_am3(:,c,22)
  am3_qunam2_arr(:,c) = f2->alpha_window_am3(:,c,23)
  am3_qucan_arr(:,c)  = f2->alpha_window_am3(:,c,24)

  am2_ntrops_arr(:,c) = f2->alpha_window_am2(:,c,4)
  am2_strops_arr(:,c) = f2->alpha_window_am2(:,c,5)
; grap timeseries for the tropical windows
  am2_satl_arr(:,c)   = f2->alpha_window_am2(:,c,0)
  am2_sind_arr(:,c)   = f2->alpha_window_am2(:,c,1)
  am2_epac_arr(:,c)   = f2->alpha_window_am2(:,c,2)
; grap timeseries for the rest of the tropics
  am2_trops1_arr(:,c) = f2->alpha_window_am2(:,c,8)
  am2_trops2_arr(:,c) = f2->alpha_window_am2(:,c,9)
  am2_trops3_arr(:,c) = f2->alpha_window_am2(:,c,10)
  am2_trops4_arr(:,c) = f2->alpha_window_am2(:,c,11)
  am2_trops5_arr(:,c) = f2->alpha_window_am2(:,c,12)
  am2_trops6_arr(:,c) = f2->alpha_window_am2(:,c,13)
; from Qu et al.'s windows Letters need to be checked with window numbers!!!!!
  am2_tropsA_arr(:,c) = f2->alpha_window_am2(:,c,25)
  am2_tropsB1_arr(:,c)= f2->alpha_window_am2(:,c,26)
  am2_tropsB2_arr(:,c)= f2->alpha_window_am2(:,c,26)
  am2_tropsC_arr(:,c) = f2->alpha_window_am2(:,c,27)
  am2_tropsD_arr(:,c) = f2->alpha_window_am2(:,c,28)
  am2_tropsE_arr(:,c) = f2->alpha_window_am2(:,c,29)
  am2_tropsF_arr(:,c) = f2->alpha_window_am2(:,c,30)
  am2_tropsG_arr(:,c) = f2->alpha_window_am2(:,c,31)
  am2_tropsH_arr(:,c) = f2->alpha_window_am2(:,c,32)
  am2_tropsI_arr(:,c) = f2->alpha_window_am2(:,c,33)
  am2_tropsJ_arr(:,c) = f2->alpha_window_am2(:,c,35)
  am2_tropsK_arr(:,c) = f2->alpha_window_am2(:,c,36)
; shoudl be qu et al.'s tropical windows
  am2_qucal_arr(:,c)  = f2->alpha_window_am2(:,c,19)
  am2_quper_arr(:,c)  = f2->alpha_window_am2(:,c,20)
  am2_quaus_arr(:,c)  = f2->alpha_window_am2(:,c,21)
  am2_qunam1_arr(:,c) = f2->alpha_window_am2(:,c,22)
  am2_qunam2_arr(:,c) = f2->alpha_window_am2(:,c,23)
  am2_qucan_arr(:,c)  = f2->alpha_window_am2(:,c,24)
end do

; compute ensemble mean values
; am2 data
am2_ntrops=dim_avg_n(am2_ntrops_arr,1)
am2_strops=dim_avg_n(am2_strops_arr,1)
am2_satl=dim_avg_n(am2_satl_arr,1)
am2_sind=dim_avg_n(am2_sind_arr,1)
am2_epac=dim_avg_n(am2_epac_arr,1)
am2_trops1=dim_avg_n(am2_trops1_arr,1)
am2_trops2=dim_avg_n(am2_trops2_arr,1)
am2_trops3=dim_avg_n(am2_trops3_arr,1)
am2_trops4=dim_avg_n(am2_trops4_arr,1)
am2_trops5=dim_avg_n(am2_trops5_arr,1)
am2_trops6=dim_avg_n(am2_trops6_arr,1)
; qu tropical windows outside of low cloud regions
am2_tropsA=dim_avg_n(am2_tropsA_arr,1)
am2_tropsB1=dim_avg_n(am2_tropsB1_arr,1)
am2_tropsB2=dim_avg_n(am2_tropsB2_arr,1)
am2_tropsC=dim_avg_n(am2_tropsC_arr,1)
am2_tropsD=dim_avg_n(am2_tropsD_arr,1)
am2_tropsE=dim_avg_n(am2_tropsE_arr,1)
am2_tropsF=dim_avg_n(am2_tropsF_arr,1)
am2_tropsG=dim_avg_n(am2_tropsG_arr,1)
am2_tropsH=dim_avg_n(am2_tropsH_arr,1)
am2_tropsI=dim_avg_n(am2_tropsI_arr,1)
am2_tropsJ=dim_avg_n(am2_tropsJ_arr,1)
am2_tropsK=dim_avg_n(am2_tropsK_arr,1)
; qu tropical low cloud regions windows
am2_qucal=dim_avg_n(am2_qucal_arr,1)
am2_quper=dim_avg_n(am2_quper_arr,1)
am2_quaus=dim_avg_n(am2_quaus_arr,1)
am2_qunam1=dim_avg_n(am2_qunam1_arr,1)
am2_qunam2=dim_avg_n(am2_qunam2_arr,1)
am2_qucan=dim_avg_n(am2_qucan_arr,1)

; am3 data
am3_ntrops=dim_avg_n(am3_ntrops_arr,1)
am3_strops=dim_avg_n(am3_strops_arr,1)
am3_satl=dim_avg_n(am3_satl_arr,1)
am3_sind=dim_avg_n(am3_sind_arr,1)
am3_epac=dim_avg_n(am3_epac_arr,1)
am3_trops1=dim_avg_n(am3_trops1_arr,1)
am3_trops2=dim_avg_n(am3_trops2_arr,1)
am3_trops3=dim_avg_n(am3_trops3_arr,1)
am3_trops4=dim_avg_n(am3_trops4_arr,1)
am3_trops5=dim_avg_n(am3_trops5_arr,1)
am3_trops6=dim_avg_n(am3_trops6_arr,1)
; qu tropical windows outside of low cloud regions
am3_tropsA=dim_avg_n(am3_tropsA_arr,1)
am3_tropsB1=dim_avg_n(am3_tropsB1_arr,1)
am3_tropsB2=dim_avg_n(am3_tropsB2_arr,1)
am3_tropsC=dim_avg_n(am3_tropsC_arr,1)
am3_tropsD=dim_avg_n(am3_tropsD_arr,1)
am3_tropsE=dim_avg_n(am3_tropsE_arr,1)
am3_tropsF=dim_avg_n(am3_tropsF_arr,1)
am3_tropsG=dim_avg_n(am3_tropsG_arr,1)
am3_tropsH=dim_avg_n(am3_tropsH_arr,1)
am3_tropsI=dim_avg_n(am3_tropsI_arr,1)
am3_tropsJ=dim_avg_n(am3_tropsJ_arr,1)
am3_tropsK=dim_avg_n(am3_tropsK_arr,1)
; qu tropical low cloud regions windows
am3_qucal=dim_avg_n(am3_qucal_arr,1)
am3_quper=dim_avg_n(am3_quper_arr,1)
am3_quaus=dim_avg_n(am3_quaus_arr,1)
am3_qunam1=dim_avg_n(am3_qunam1_arr,1)
am3_qunam2=dim_avg_n(am3_qunam2_arr,1)
am3_qucan=dim_avg_n(am3_qucan_arr,1)

; am4 data
am4_ntrops=dim_avg_n(am4_ntrops_arr,1)
am4_strops=dim_avg_n(am4_strops_arr,1)
am4_satl=dim_avg_n(am4_satl_arr,1)
am4_sind=dim_avg_n(am4_sind_arr,1)
am4_epac=dim_avg_n(am4_epac_arr,1)
am4_trops1=dim_avg_n(am4_trops1_arr,1)
am4_trops2=dim_avg_n(am4_trops2_arr,1)
am4_trops3=dim_avg_n(am4_trops3_arr,1)
am4_trops4=dim_avg_n(am4_trops4_arr,1)
am4_trops5=dim_avg_n(am4_trops5_arr,1)
am4_trops6=dim_avg_n(am4_trops6_arr,1)
; qu tropical windows outside of low cloud regions
am4_tropsA=dim_avg_n(am4_tropsA_arr,1)
am4_tropsB1=dim_avg_n(am4_tropsB1_arr,1)
am4_tropsB2=dim_avg_n(am4_tropsB2_arr,1)
am4_tropsC=dim_avg_n(am4_tropsC_arr,1)
am4_tropsD=dim_avg_n(am4_tropsD_arr,1)
am4_tropsE=dim_avg_n(am4_tropsE_arr,1)
am4_tropsF=dim_avg_n(am4_tropsF_arr,1)
am4_tropsG=dim_avg_n(am4_tropsG_arr,1)
am4_tropsH=dim_avg_n(am4_tropsH_arr,1)
am4_tropsI=dim_avg_n(am4_tropsI_arr,1)
am4_tropsJ=dim_avg_n(am4_tropsJ_arr,1)
am4_tropsK=dim_avg_n(am4_tropsK_arr,1)
; qu tropical low cloud regions windows
am4_qucal=dim_avg_n(am4_qucal_arr,1)
am4_quper=dim_avg_n(am4_quper_arr,1)
am4_quaus=dim_avg_n(am4_quaus_arr,1)
am4_qunam1=dim_avg_n(am4_qunam1_arr,1)
am4_qunam2=dim_avg_n(am4_qunam2_arr,1)
am4_qucan=dim_avg_n(am4_qucan_arr,1)

; compute sums over desired geographic regions for plotting

  ;am4_tropsrest      = am4_trops1+am4_trops2+am4_trops3+am4_trops4+am4_trops5+am4_trops6
  am4_trops_ns        = am4_strops+am4_ntrops
  am4_tropwinds       = am4_satl+am4_sind+am4_epac
  am4_tropsrest       = am4_trops1+am4_trops2+am4_trops3+am4_trops4+am4_trops5+am4_trops6
  am4_trops_qu_rest   = am4_tropsA+am4_tropsB1+am4_tropsB2+am4_tropsC+am4_tropsD+am4_tropsE+am4_tropsF+am4_tropsG+am4_tropsH+am4_tropsI+am4_tropsJ+am4_tropsK
  am4_lctrops_qu      = am4_qucal+am4_quper+am4_quaus+am4_qunam1+am4_qunam2+am4_qucan
  am4_qu_tr_windowsum = am4_lctrops_qu+am4_trops_qu_rest

;; I am confused about what the code below is doing.  why am i only using ensnumber and not a loop?
;; am i plotting the time series from individual members here?
;  am3_ntrops = f2->alpha_window_am3(:,ensnumber,4)
;  am3_strops = f2->alpha_window_am3(:,ensnumber,5)
;; grap timeseries for the tropical windows
;  am3_satl   = f2->alpha_window_am3(:,ensnumber,0)
;  am3_sind   = f2->alpha_window_am3(:,ensnumber,1)
;  am3_epac   = f2->alpha_window_am3(:,ensnumber,2)
;; grap timeseries for the rest of the tropics
;  am3_trops1 = f2->alpha_window_am3(:,ensnumber,8)
;  am3_trops2 = f2->alpha_window_am3(:,ensnumber,9)
;  am3_trops3 = f2->alpha_window_am3(:,ensnumber,10)
;  am3_trops4 = f2->alpha_window_am3(:,ensnumber,11)
;  am3_trops5 = f2->alpha_window_am3(:,ensnumber,12)
;  am3_trops6 = f2->alpha_window_am3(:,ensnumber,13)
;
;  ;am3_tropsrest   = am3_trops1+am3_trops2+am3_trops3+am3_trops4+am3_trops5+am3_trops6
;  am3_tropwinds   = am3_satl+am3_sind+am3_epac
;  am3_tropsrest   = am3_trops1+am3_trops2+am3_trops3+am3_trops4+am3_trops5+am3_trops6
;
;  am2_ntrops = f2->alpha_window_am2(:,ensnumber,4)
;  am2_strops = f2->alpha_window_am2(:,ensnumber,5)
;; grap timeseries for the tropical windows
;  am2_satl   = f2->alpha_window_am2(:,ensnumber,0)
;  am2_sind   = f2->alpha_window_am2(:,ensnumber,1)
;  am2_epac   = f2->alpha_window_am2(:,ensnumber,2)
;; grap timeseries for the rest of the tropics
;  am2_trops1 = f2->alpha_window_am2(:,ensnumber,8)
;  am2_trops2 = f2->alpha_window_am2(:,ensnumber,9)
;  am2_trops3 = f2->alpha_window_am2(:,ensnumber,10)
;  am2_trops4 = f2->alpha_window_am2(:,ensnumber,11)
;  am2_trops5 = f2->alpha_window_am2(:,ensnumber,12)
;  am2_trops6 = f2->alpha_window_am2(:,ensnumber,13)

  am3_tropwinds   = am3_satl+am3_sind+am3_epac
  am3_trops_ns        = am3_strops+am3_ntrops
  am3_tropsrest   = am3_trops1+am3_trops2+am3_trops3+am3_trops4+am3_trops5+am3_trops6
  am3_lctrops_qu  = am3_qucal+am3_quper+am3_quaus+am3_qunam1+am3_qunam2+am3_qucan
  am3_trops_qu_rest   = am3_tropsA+am3_tropsB1+am3_tropsB2+am3_tropsC+am3_tropsD+am3_tropsE+am3_tropsF+am3_tropsG+am3_tropsH+am3_tropsI+am3_tropsJ+am3_tropsK

  am2_tropwinds   = am2_satl+am2_sind+am2_epac
  am2_trops_ns        = am2_strops+am2_ntrops
  am2_tropsrest   = am2_trops1+am2_trops2+am2_trops3+am2_trops4+am2_trops5+am2_trops6
  am2_lctrops_qu  = am2_qucal+am2_quper+am2_quaus+am2_qunam1+am2_qunam2+am2_qucan
  am2_trops_qu_rest   = am2_tropsA+am2_tropsB1+am2_tropsB2+am2_tropsC+am2_tropsD+am2_tropsE+am2_tropsF+am2_tropsG+am2_tropsH+am2_tropsI+am2_tropsJ+am2_tropsK

;----------------------------------

  time           = f1->TIME(:) 

; name dimesions
alpha_am4_f1!0 = "year"
alpha_am4_f1!1 = "ensnum"
print("dimsizes of alpha_am4_f1 are: "+dimsizes(alpha_am4_f1))


mnmx = new((/6,105/), float)
mnmx(0,:) = dim_min( alpha_am4_f1)
mnmx(1,:) = dim_max( alpha_am4_f1)
mnmx(2,:) = dim_min( alpha_am3_f1)
mnmx(3,:) = dim_max( alpha_am3_f1)
mnmx(4,:) = dim_min( alpha_am2_f1)
mnmx(5,:) = dim_max( alpha_am2_f1)

mnmx_cre = new((/6,105/), float)
mnmx_cre(0,:) = dim_min( alpha_cre_am4_f1)
mnmx_cre(1,:) = dim_max( alpha_cre_am4_f1)
mnmx_cre(2,:) = dim_min( alpha_cre_am3_f1)
mnmx_cre(3,:) = dim_max( alpha_cre_am3_f1)
mnmx_cre(4,:) = dim_min( alpha_cre_am2_f1)
mnmx_cre(5,:) = dim_max( alpha_cre_am2_f1)

mnmx_clr = new((/6,105/), float)
mnmx_clr(0,:) = dim_min( alpha_clr_am4_f1)
mnmx_clr(1,:) = dim_max( alpha_clr_am4_f1)
mnmx_clr(2,:) = dim_min( alpha_clr_am3_f1)
mnmx_clr(3,:) = dim_max( alpha_clr_am3_f1)
mnmx_clr(4,:) = dim_min( alpha_clr_am2_f1)
mnmx_clr(5,:) = dim_max( alpha_clr_am2_f1)

mnmx_lcc = new((/6,105/), float)
mnmx_lcc(0,:) = dim_min( alpha_lcc_am4_f1)
mnmx_lcc(1,:) = dim_max( alpha_lcc_am4_f1)
mnmx_lcc(2,:) = dim_min( alpha_lcc_am3_f1)
mnmx_lcc(3,:) = dim_max( alpha_lcc_am3_f1)
mnmx_lcc(4,:) = dim_min( alpha_lcc_am2_f1)
mnmx_lcc(5,:) = dim_max( alpha_lcc_am2_f1)

mnmx_lwcre = new((/6,105/), float)
mnmx_lwcre(0,:) = dim_min( alpha_lwcre_am4_f1)
mnmx_lwcre(1,:) = dim_max( alpha_lwcre_am4_f1)
mnmx_lwcre(2,:) = dim_min( alpha_lwcre_am3_f1)
mnmx_lwcre(3,:) = dim_max( alpha_lwcre_am3_f1)
mnmx_lwcre(4,:) = dim_min( alpha_lwcre_am2_f1)
mnmx_lwcre(5,:) = dim_max( alpha_lwcre_am2_f1)

mnmx_swcre = new((/6,105/), float)
mnmx_swcre(0,:) = dim_min( alpha_swcre_am4_f1)
mnmx_swcre(1,:) = dim_max( alpha_swcre_am4_f1)
mnmx_swcre(2,:) = dim_min( alpha_swcre_am3_f1)
mnmx_swcre(3,:) = dim_max( alpha_swcre_am3_f1)
mnmx_swcre(4,:) = dim_min( alpha_swcre_am2_f1)
mnmx_swcre(5,:) = dim_max( alpha_swcre_am2_f1)

;-----------------------------------------------------------
;wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file

gsn_define_colormap(wks,"GMT_relief_oceanonly")

;am2fill="orange1"
am2fill="paleturquoise1"
am3fill="palegreen2"
am4fill="cornsilk3"

;am2line="royalblue1"
am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"

plot = new(6,graphic)

res                   = True
res@trYMinF           = -3.5
res@trYMaxF           = 0.0
res@trXMinF           = 1885
res@trXMaxF           = 1990
;res@tmYLLabelFontHeightF = 0.01
res@tiYAxisFontHeightF = 0.011
res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")" 
res@tiXAxisString    = " "
res@tmYROn            = False
res@tmXTOn            = False
res@tmXTBorderOn      = False
res@tmYRBorderOn      = False
res@gsnDraw           = False ; default: T
res@gsnFrame          = False ; default: T

length=0.40
height=0.25

res@vpWidthF          = length
res@vpHeightF         = height

scalef=-1.


res@gsnXYFillColors = am2fill 
res@xyLineColor     = -1
am2_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(4:5,:),res) ; create filled xy plot

res@gsnXYFillColors = am3fill
res@xyLineColor     = -1
am3_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(2:3,:),res) ; create filled xy plot

res@gsnXYFillColors = am4fill
res@xyLineColor     = -1
am4_cloud  = gsn_csm_xy(wks,time,scalef*mnmx(0:1,:),res) ; create filled xy plot

res@xyLineThicknessF   = 3.0
res@xyLineColors  = am2line
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

res@xyLineColors  = am3line
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineColors  = am4line
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

overlay(am2_cloud,am3_cloud)
overlay(am2_cloud,am4_cloud)
overlay(am2_cloud,ens_am2mn)
overlay(am2_cloud,ens_am3mn)
overlay(am2_cloud,ens_am4mn)

; legend for panel (A)

ltitle3="  GFDL AM4.0"
ltitle2="  GFDL AM3"
ltitle1="  GFDL AM2.1"
lthick=3.0

colors1 = (/am2line,am3line,am4line/) 

lgres                      = True
lgres@xyLabelMode            = "Custom"
lgres@xyLineLabelFontHeightF = 0.015                ; font height
lgres@lgLineColors         = (/colors1(0),colors1(1),colors1(2)/)
lgres@lgItemType           = "Lines"
lgres@lgLabelFontHeightF   = .08
lgres@vpWidthF             = 0.12        ; width of legend
lgres@vpHeightF            = 0.1        ; height of legend
lgres@lgLineThicknessF     = lthick
lgres@lgPerimThicknessF    = 2.0
lgres@lgMonoDashIndex      = False
lgres@lgDashIndexes          = (/"0","0","0"/)
lgres@lgPerimOn            = False

labels = (/ltitle1,ltitle2,ltitle3/)
legend  = gsn_create_legend (wks, 3, labels, lgres)
amres = True
amres@amJust = "BottomRight"
amres@amParallelPosF   = 0.5    ; Move legend to right
amres@amOrthogonalPosF = -0.05     ; Move legend down

annoid = gsn_add_annotation(am2_cloud,legend,amres) ; add legend to plot

plot(0) = am2_cloud

; second plot - --------------------------------------------------
res@vpWidthF          = length
res@vpHeightF         = height
res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")"
res@tiXAxisString    = " "
res@xyLineColors  = am4line
res@xyLineThicknessF   = 1.0

res@xyLineThicknessF   = 2.0
res@xyDashPattern = 2 ; short dash
tropwinds_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropwinds(:),res)
res@xyDashPattern = 16 ; long dash
tropsrest_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropsrest(:),res)
res@xyDashPattern = 2  ; short dashed, almost dots
res@xyLineThicknessF   = 2.0
trops_qu_lcc_am4mn = gsn_csm_xy(wks,time,scalef*am4_lctrops_qu(:),res)
res@xyDashPattern = 16 ; long dash
trops_qu_rest_am4mn = gsn_csm_xy(wks,time,scalef*am4_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
trops_ns_am4mn = gsn_csm_xy(wks,time,scalef*am4_trops_ns(:),res)
res@xyDashPattern = 0
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

res@xyLineColors  = am3line
res@xyDashPattern = 16
res@xyLineThicknessF   = 2.0
res@xyDashPattern = 2 ; short dash
tropwinds_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropwinds(:),res)
res@xyDashPattern = 16 ; long dash
tropsrest_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropsrest(:),res)
res@xyDashPattern = 2
res@xyLineThicknessF   = 2.0
trops_qu_lcc_am3mn = gsn_csm_xy(wks,time,scalef*am3_lctrops_qu(:),res)
res@xyDashPattern = 16 ; long dash
trops_qu_rest_am3mn = gsn_csm_xy(wks,time,scalef*am3_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
trops_ns_am3mn = gsn_csm_xy(wks,time,scalef*am3_trops_ns(:),res)
res@xyDashPattern = 0
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineColors  = am2line
res@xyDashPattern = 16
res@xyLineThicknessF   = 2.0
res@xyDashPattern = 2 ; short dash
tropwinds_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropwinds(:),res)
res@xyDashPattern = 16
tropsrest_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropsrest(:),res)
res@xyDashPattern = 2
res@xyLineThicknessF   = 2.0
trops_qu_lcc_am2mn = gsn_csm_xy(wks,time,scalef*am2_lctrops_qu(:),res)
res@xyDashPattern = 2 ; short dash
trops_qu_rest_am2mn = gsn_csm_xy(wks,time,scalef*am2_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
trops_ns_am2mn = gsn_csm_xy(wks,time,scalef*am2_trops_ns(:),res)
res@xyDashPattern = 0
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

overlay(tropwinds_am4mn,tropwinds_am2mn)
overlay(tropwinds_am4mn,ens_am2mn)
overlay(tropwinds_am4mn,tropsrest_am2mn)
;overlay(tropwinds_am4mn,trops_qu_lcc_am2mn)
;overlay(tropwinds_am4mn,trops_qu_rest_am2mn)

overlay(tropwinds_am4mn,tropwinds_am3mn)
overlay(tropwinds_am4mn,ens_am3mn)
overlay(tropwinds_am4mn,tropsrest_am3mn)
;overlay(tropwinds_am4mn,trops_qu_lcc_am3mn)
;overlay(tropwinds_am4mn,trops_qu_rest_am3mn)

overlay(tropwinds_am4mn,ens_am4mn)
overlay(tropwinds_am4mn,tropsrest_am4mn)
;overlay(tropwinds_am4mn,trops_qu_lcc_am4mn)
;overlay(tropwinds_am4mn,trops_qu_rest_am4mn)

; legend for panel (B)

ltitle1="  Global"
ltitle2="  Tropics"
;ltitle3="  Tropics-Windows"
ltitle3="  Windows"
lthick=3.0

colors1 = (/am2line,am3line,am4line/) 

lgres                      = True
lgres@xyLabelMode            = "Custom"
lgres@xyLineLabelFontHeightF = 0.015                ; font height
lgres@lgLineColors         = (/colors1(2),colors1(2),colors1(2)/)
lgres@lgItemType           = "Lines"
lgres@lgLabelFontHeightF   = .08
lgres@vpWidthF             = 0.1        ; width of legend
lgres@vpHeightF            = 0.1        ; height of legend
lgres@lgLineThicknessF     = lthick
lgres@lgPerimThicknessF    = 2.0
lgres@lgMonoDashIndex      = False
lgres@lgDashIndexes        = (/"0","16","2"/)
lgres@lgPerimOn            = False

labels = (/ltitle1,ltitle2,ltitle3/)
legend  = gsn_create_legend (wks, 3, labels, lgres)
amres = True
amres@amJust = "BottomRight"
amres@amParallelPosF   = 0.5    ; Move legend to right
amres@amOrthogonalPosF = -0.05     ; Move legend down

annoid = gsn_add_annotation(tropwinds_am4mn,legend,amres) ; add legend to plot

plot(1) = tropwinds_am4mn

; third plot - ---------------------------------------------------
res3                   = True
res3@trXMinF           = 1885
res3@trXMaxF           = 1990
res3@tiYAxisFontHeightF = 0.011
res3@tiYAxisString    = "Cloud feedback parameters (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")"
res3@tiXAxisString    = " "
res3@tmYROn            = False
res3@tmXTOn            = False
res3@tmXTBorderOn      = False
res3@tmYRBorderOn      = False
res3@gsnDraw           = False ; default: T
res3@gsnFrame          = False ; default: T

res3@xyLineThicknessF   = 1.0
res3@xyLineColor     = -1
res3@trYMinF           = -1.3
res3@trYMaxF           = 2.2

res3@vpWidthF          = length
res3@vpHeightF         = height
;res3@tiMainString      = "where"

scalef=1.0

res3@xyLineColor     = -1
res3@gsnXYFillColors = am2fill 
res3@xyLineColor     = -1
am2_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(4:5,:),res3) ; create filled xy plot
am2_clr_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_clr(4:5,:),res3) ; create filled xy plot
res3@xyLineColor     = -1
res3@gsnXYFillColors = am3fill 
res3@xyLineColor     = -1
am3_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(2:3,:),res3) ; create filled xy plot
am3_clr_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_clr(2:3,:),res3) ; create filled xy plot
res3@xyLineColor     = -1
res3@gsnXYFillColors = am4fill
res3@xyLineColor     = -1
am4_cre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_cre(0:1,:),res3) ; create filled xy plot
am4_clr_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_clr(0:1,:),res3) ; create filled xy plot

res3@xyLineThicknessF   = 3.0
res3@xyLineColors  = am2line
ens_cre_am2mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am2_f1(:),res3)
ens_clr_am2mn = gsn_csm_xy(wks,time,scalef*alpha_clr_ensmn_am2_f1(:),res3)
res3@xyDashPattern = 0

res3@xyLineColors  = am3line
ens_cre_am3mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am3_f1(:),res3)
ens_clr_am3mn = gsn_csm_xy(wks,time,scalef*alpha_clr_ensmn_am3_f1(:),res3)
res3@xyLineThicknessF   = 3.0
res3@xyDashPattern = 0

res3@xyLineColors  = am4line
ens_cre_am4mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am4_f1(:),res3)
ens_clr_am4mn = gsn_csm_xy(wks,time,scalef*alpha_clr_ensmn_am4_f1(:),res3)
res3@xyDashPattern = 0

overlay(am2_clr_cloud,am3_cre_cloud)
overlay(am2_clr_cloud,am3_clr_cloud)
overlay(am2_clr_cloud,am4_clr_cloud)
overlay(am2_clr_cloud,am2_cre_cloud)
overlay(am2_clr_cloud,am4_cre_cloud)
overlay(am2_clr_cloud,ens_cre_am2mn)
overlay(am2_clr_cloud,ens_clr_am2mn)
overlay(am2_clr_cloud,ens_cre_am3mn)
overlay(am2_clr_cloud,ens_clr_am3mn)
overlay(am2_clr_cloud,ens_cre_am4mn)
overlay(am2_clr_cloud,ens_clr_am4mn)

plot(2) = am2_clr_cloud

; fourth plot - --------------------------------------------------
res4                   = True
res4@trXMinF           = 1885
res4@trXMaxF           = 1990
res4@tiYAxisFontHeightF = 0.011
res4@tiYAxisString    = "Cloud anomaly parameter (% "+"K~S~-1"+"~N~"+")"
res4@tiXAxisString    = " "
res4@tmYROn            = False
res4@tmXTOn            = False
res4@tmXTBorderOn      = False
res4@tmYRBorderOn      = False
res4@gsnDraw           = False ; default: T
res4@gsnFrame          = False ; default: T

res4@xyLineThicknessF   = 1.0
res4@xyLineColor     = -1
res4@trYMinF           = -2.0
res4@trYMaxF           = 1.5

res4@vpWidthF          = length
res4@vpHeightF         = height

scalef=1.0

res4@xyLineColor     = -1
res4@gsnXYFillColors = am2fill 
res4@xyLineColor     = -1
am2_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(4:5,:),res4) ; create filled xy plot
res4@xyLineColor     = -1
res4@gsnXYFillColors = am3fill
res4@xyLineColor     = -1
am3_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(2:3,:),res4) ; create filled xy plot
res4@xyLineColor     = -1
res4@gsnXYFillColors = am4fill
res4@xyLineColor     = -1
am4_lcc_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lcc(0:1,:),res4) ; create filled xy plot

res4@xyLineThicknessF   = 3.0
res4@xyLineColors  = am2line
ens_lcc_am2mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am2_f1(:),res4)

res4@xyLineColors  = am3line
ens_lcc_am3mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am3_f1(:),res4)

res4@xyLineColors  = am4line
ens_lcc_am4mn = gsn_csm_xy(wks,time,scalef*alpha_lcc_ensmn_am4_f1(:),res4)


overlay(am2_lcc_cloud,am3_lcc_cloud)
overlay(am2_lcc_cloud,am4_lcc_cloud)
overlay(am2_lcc_cloud,ens_lcc_am2mn)
overlay(am2_lcc_cloud,ens_lcc_am3mn)
overlay(am2_lcc_cloud,ens_lcc_am4mn)

plot(3) = am2_lcc_cloud

; fifth plot - ---------------------------------------------------
res5                   = True
res5@trXMinF           = 1885
res5@trXMaxF           = 1990
res5@tiYAxisFontHeightF = 0.011
res5@tiYAxisString    = "SW Cloud feedback parameter (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")"
res5@tiXAxisString    = "Year"
res5@tmYROn            = False
res5@tmXTOn            = False
res5@tmXTBorderOn      = False
res5@tmYRBorderOn      = False
res5@gsnDraw           = False ; default: T
res5@gsnFrame          = False ; default: T

res5@xyLineThicknessF   = 1.0
res5@xyLineColor     = -1
res5@trYMinF           = -2.0
res5@trYMaxF           = 1.5

res5@vpWidthF          = length
res5@vpHeightF         = height

scalef=1.0

res5@gsnXYFillColors = am2fill 
res5@xyLineColor     = -1
am2_swcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_swcre(4:5,:),res5) ; create filled xy plot

res5@gsnXYFillColors = am3fill 
res5@xyLineColor     = -1
am3_swcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_swcre(2:3,:),res5) ; create filled xy plot

res5@gsnXYFillColors = am4fill 
res5@xyLineColor     = -1
am4_swcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_swcre(0:1,:),res5) ; create filled xy plot

res5@xyLineColors  = am4line
res5@xyDashPattern = 0
res5@xyLineThicknessF   = 3.0
ens_swcre_am4mn = gsn_csm_xy(wks,time,scalef*alpha_swcre_ensmn_am4_f1(:),res5)
res5@xyLineColors  = am3line
ens_swcre_am3mn = gsn_csm_xy(wks,time,scalef*alpha_swcre_ensmn_am3_f1(:),res5)
res5@xyLineColors  = am2line
ens_swcre_am2mn = gsn_csm_xy(wks,time,scalef*alpha_swcre_ensmn_am2_f1(:),res5)

overlay(am2_swcre_cloud,am3_swcre_cloud)
overlay(am2_swcre_cloud,am4_swcre_cloud)
overlay(am2_swcre_cloud,ens_swcre_am4mn)
overlay(am2_swcre_cloud,ens_swcre_am3mn)
overlay(am2_swcre_cloud,ens_swcre_am2mn)

plot(4) = am2_swcre_cloud
; sixth plot - ---------------------------------------------------
res6                   = True
res6@trXMinF           = 1885
res6@trXMaxF           = 1990
res6@tiYAxisFontHeightF = 0.011
res6@tiYAxisString    = "LW Cloud feedback parameter (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")"
res6@tiXAxisString    = "Year"
res6@tmYROn            = False
res6@tmXTOn            = False
res6@tmXTBorderOn      = False
res6@tmYRBorderOn      = False
res6@gsnDraw           = False ; default: T
res6@gsnFrame          = False ; default: T

res6@xyLineThicknessF   = 1.0
res6@xyLineColor     = -1
res6@trYMinF           = -2.0
res6@trYMaxF           = 1.5

res6@vpWidthF          = length
res6@vpHeightF         = height

scalef=1.0

res6@gsnXYFillColors = am2fill 
res6@xyLineColor     = -1
am2_lwcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lwcre(4:5,:),res6) ; create filled xy plot

res6@gsnXYFillColors = am3fill 
res6@xyLineColor     = -1
am3_lwcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lwcre(2:3,:),res6) ; create filled xy plot

res6@gsnXYFillColors = am4fill 
res6@xyLineColor     = -1
am4_lwcre_cloud  = gsn_csm_xy(wks,time,scalef*mnmx_lwcre(0:1,:),res6) ; create filled xy plot

res6@xyDashPattern = 0
res6@xyLineThicknessF   = 3.0
res6@xyLineColors  = am4line
ens_cre_am4mn = gsn_csm_xy(wks,time,scalef*alpha_cre_ensmn_am4_f1(:),res6)
res6@xyLineColors  = am4line
ens_lwcre_am4mn = gsn_csm_xy(wks,time,scalef*alpha_lwcre_ensmn_am4_f1(:),res6)
res6@xyLineColors  = am3line
ens_lwcre_am3mn = gsn_csm_xy(wks,time,scalef*alpha_lwcre_ensmn_am3_f1(:),res6)
res6@xyLineColors  = am2line
ens_lwcre_am2mn = gsn_csm_xy(wks,time,scalef*alpha_lwcre_ensmn_am2_f1(:),res6)

overlay(am2_lwcre_cloud,am3_lwcre_cloud)
overlay(am2_lwcre_cloud,am4_lwcre_cloud)
overlay(am2_lwcre_cloud,ens_lwcre_am4mn)
overlay(am2_lwcre_cloud,ens_lwcre_am3mn)
overlay(am2_lwcre_cloud,ens_lwcre_am2mn)
plot(5) = am2_lwcre_cloud

; -----------------------------------
;frame(wks)
respanel = True
;respanel@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/)
;respanel@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/)
respanel@gsnPanelFigureStrings= (/"A","B","C","D","E","F"/)
respanel@amJust = "TopLeft"
gsn_panel(wks,plot,(/3,2/),respanel)

end
