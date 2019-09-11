;***********************************************************************************
; alpha_tseries_1pan.ncl
; 
; Function codes: see https://www.ncl.ucar.edu/Applications/fcodes.shtml
; for useful examples.  This is how I inserted superscipts in the axis labels
;
; mirror plot 1b of Silvers et al. 2017 GRL, but include windows and rest of tropics
; region from windows used by Qu et al. 2014.  
;
; levi silvers                                                     November 7, 2017
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
infile1=datapath+"idiot_box3.nc"
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
  am4_trops_ns        = am4_strops+am4_ntrops ; should be tropics between +/- 30 degrees
  am4_tropwinds       = am4_satl+am4_sind+am4_epac
  am4_tropsrest       = am4_trops1+am4_trops2+am4_trops3+am4_trops4+am4_trops5+am4_trops6
; determined the tropical (+/-) region outside the realm of Qu et al.'s 2014 windows is a mess.  I used the 12 windows below
  am4_trops_qu_rest   = am4_tropsA+am4_tropsB1+am4_tropsB2+am4_tropsC+am4_tropsD+am4_tropsE+am4_tropsF+am4_tropsG+am4_tropsH+am4_tropsI+am4_tropsJ+am4_tropsK
  am4_lctrops_qu      = am4_qucal+am4_quper+am4_quaus+am4_qunam1+am4_qunam2+am4_qucan ; 5 windows from Qu et al. 2014
  am4_qu_tr_windowsum = am4_lctrops_qu+am4_trops_qu_rest

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


;-----------------------------------------------------------
wks = gsn_open_wks("newpdf","testplot")          ; send graphics to PNG file
;wks = gsn_open_wks("pdf","testplot")          ; send graphics to PNG file
;wks = gsn_open_wks("eps","testplot")          ; send graphics to PNG file

gsn_define_colormap(wks,"GMT_relief_oceanonly")

am2fill="paleturquoise1"
am3fill="palegreen2"
am4fill="cornsilk3"

am2line="deepskyblue3"
am3line="darkgreen"
am4line="black"

length=0.40
height=0.25

scalef=-1.


res                   = True
res@trYMinF           = -3.5
res@trYMaxF           = 0.0
res@trXMinF           = 1885
res@trXMaxF           = 1990
;res@tmYLLabelFontHeightF = 0.01
res@tiYAxisFontHeightF = 0.011
res@tmYROn            = False
res@tmXTOn            = False
res@tmXTBorderOn      = False
res@tmYRBorderOn      = False
res@gsnDraw           = True ; default: T
res@gsnFrame          = False; default: T

res@vpWidthF          = length
res@vpHeightF         = height
res@tiYAxisString    = "Climate feedback parameter (W "+"m~S~-2~NN~K~S~-1"+"~N~"+")"
res@tiXAxisString    = "Year "
res@xyLineColors  = am4line
res@xyLineThicknessF   = 1.0

res@xyLineThicknessF   = 3.0
res@xyDashPattern = 2 ; short dash
tropwinds_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropwinds(:),res)
res@xyDashPattern = 16 ; long dash
tropsrest_am4mn = gsn_csm_xy(wks,time,scalef*am4_tropsrest(:),res)
res@xyDashPattern = 2  ; short dashed, almost dots
res@xyLineThicknessF   = 1.0
trops_qu_lcc_am4mn = gsn_csm_xy(wks,time,scalef*am4_lctrops_qu(:),res)
res@xyDashPattern = 16 ; long dash
trops_qu_rest_am4mn = gsn_csm_xy(wks,time,scalef*am4_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
;trops_ns_am4mn = gsn_csm_xy(wks,time,scalef*am4_trops_ns(:),res)
res@xyDashPattern = 0
ens_am4mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am4_f1(:),res)

res@xyLineColors  = am3line
res@xyDashPattern = 16
res@xyLineThicknessF   = 3.0
res@xyDashPattern = 2 ; short dash
tropwinds_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropwinds(:),res)
res@xyDashPattern = 16 ; long dash
tropsrest_am3mn = gsn_csm_xy(wks,time,scalef*am3_tropsrest(:),res)
res@xyDashPattern = 2
res@xyLineThicknessF   = 1.0
trops_qu_lcc_am3mn = gsn_csm_xy(wks,time,scalef*am3_lctrops_qu(:),res)
res@xyDashPattern = 16 ; long dash
trops_qu_rest_am3mn = gsn_csm_xy(wks,time,scalef*am3_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
;trops_ns_am3mn = gsn_csm_xy(wks,time,scalef*am3_trops_ns(:),res)
res@xyDashPattern = 0
ens_am3mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am3_f1(:),res)

res@xyLineColors  = am2line
res@xyDashPattern = 16
res@xyLineThicknessF   = 3.0
res@xyDashPattern = 2 ; short dash
tropwinds_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropwinds(:),res)
res@xyDashPattern = 16
tropsrest_am2mn = gsn_csm_xy(wks,time,scalef*am2_tropsrest(:),res)
res@xyDashPattern = 2
res@xyLineThicknessF   = 1.0
trops_qu_lcc_am2mn = gsn_csm_xy(wks,time,scalef*am2_lctrops_qu(:),res)
res@xyDashPattern = 16 ; short dash
trops_qu_rest_am2mn = gsn_csm_xy(wks,time,scalef*am2_trops_qu_rest(:),res)
res@xyDashPattern = 0
res@xyLineThicknessF   = 3.0
;trops_ns_am2mn = gsn_csm_xy(wks,time,scalef*am2_trops_ns(:),res)
res@xyDashPattern = 0
ens_am2mn = gsn_csm_xy(wks,time,scalef*alpha_ensmn_am2_f1(:),res)

;overlay(tropwinds_am4mn,tropwinds_am2mn)
;overlay(tropwinds_am4mn,tropsrest_am2mn)
;overlay(tropwinds_am4mn,ens_am2mn)
;;overlay(tropwinds_am4mn,trops_qu_lcc_am2mn)
;;overlay(tropwinds_am4mn,trops_qu_rest_am2mn)
;
;overlay(tropwinds_am4mn,tropwinds_am3mn)
;overlay(tropwinds_am4mn,ens_am3mn)
;overlay(tropwinds_am4mn,tropsrest_am3mn)
;;overlay(tropwinds_am4mn,trops_qu_lcc_am3mn)
;;overlay(tropwinds_am4mn,trops_qu_rest_am3mn)
;
;overlay(tropwinds_am4mn,ens_am4mn)
;overlay(tropwinds_am4mn,tropsrest_am4mn)
;;overlay(tropwinds_am4mn,trops_qu_lcc_am4mn)
;;overlay(tropwinds_am4mn,trops_qu_rest_am4mn)

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

;plot = tropwinds_am4mn

;; third plot - ---------------------------------------------------
;
;; fourth plot - --------------------------------------------------
;overlay(am2_lcc_cloud,ens_lcc_am3mn)
;overlay(am2_lcc_cloud,ens_lcc_am4mn)
;
;plot(3) = am2_lcc_cloud
;
;
;;; -----------------------------------
frame(wks)
;;respanel = True
;;;respanel@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/)
;;;respanel@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/)
;;respanel@gsnPanelFigureStrings= (/"A","B","C","D","E","F"/)
;;respanel@amJust = "TopLeft"
;;gsn_panel(wks,plot,(/3,2/),respanel)

end
