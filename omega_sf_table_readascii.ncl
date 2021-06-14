;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; omega_sf_table_readascii.ncl
;
; read output from stability_omegaD.ncl and tabulate results from individual models
; into a table that can be read in Matlab
;
; levi silvers                                                           may 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

if (isvar("seaST")) then
  SST=seaST
else
  SST="295"
end if

if (isvar("DaysInChunk")) then
  chunk=DaysInChunk
else
  chunk="5d"
end if

if (isvar("VertRange")) then
  vertavg=VertRange
else
  vertavg="600to200"
end if

;vertavg="600to200"
;;vertavg="900to1"

m_1=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_CAM5_"+SST+".txt",9,"float",(/1,1/))
m_2=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_CAM6_"+SST+".txt",9,"float",(/1,1/))
m_3=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_CNRM-CM6-1_"+SST+".txt",9,"float",(/1,1/))
m_4=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_ECHAM6_GCM_"+SST+".txt",9,"float",(/1,1/))
m_5=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_GEOS_GCM_"+SST+".txt",9,"float",(/1,1/))
m_6=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_ICON_GCM_"+SST+".txt",9,"float",(/1,1/))
; IPSL
m_7=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_SAM0-UNICON_"+SST+".txt",9,"float",(/1,1/))
m_8=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_SP-CAM_"+SST+".txt",9,"float",(/1,1/))
m_9=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_SPX-CAM_"+SST+".txt",9,"float",(/1,1/))
m_10=readAsciiTable("mean_vals_"+vertavg+"_"+chunk+"_UKMO-GA7.1_"+SST+".txt",9,"float",(/1,1/))

;m_1=readAsciiTable("mean_vals_CAM5_295.txt",6,"float",(/1,1/))
;m_2=readAsciiTable("mean_vals_CAM6_295.txt",6,"float",(/1,1/))
;m_3=readAsciiTable("mean_vals_CNRM-CM6-1_295.txt",6,"float",(/1,1/))
;m_4=readAsciiTable("mean_vals_ECHAM6_GCM_295.txt",6,"float",(/1,1/))
;m_5=readAsciiTable("mean_vals_GEOS_GCM_295.txt",6,"float",(/1,1/))
;m_6=readAsciiTable("mean_vals_ICON_GCM_295.txt",6,"float",(/1,1/))
;; IPSL
;m_7=readAsciiTable("mean_vals_SAM0-UNICON_295.txt",6,"float",(/1,1/))
;m_8=readAsciiTable("mean_vals_SP-CAM_295.txt",6,"float",(/1,1/))
;m_9=readAsciiTable("mean_vals_SPX-CAM_295.txt",6,"float",(/1,1/))
;m_10=readAsciiTable("mean_vals_UKMO-GA7.1_295.txt",6,"float",(/1,1/))

printVarSummary(m_1)
print("m_1 values are: "+m_1)
print("m_2 values are: "+m_2)
print("m_3 values are: "+m_3)
print("m_4 values are: "+m_4)
print("m_5 values are: "+m_5)
print("m_6 values are: "+m_6)
print("m_7 values are: "+m_7)
print("m_8 values are: "+m_8)
print("m_9 values are: "+m_9)
print("m_10 values are: "+m_10)

; add the SST in the last column... need to do this in stability_omegaD.ncl
arrayout = new((/10,9/),float)

printVarSummary(m_1)
do y=0,8
  arrayout(0,y)=m_1(0,y)
  arrayout(1,y)=m_2(0,y)
  arrayout(2,y)=m_3(0,y)
  arrayout(3,y)=m_4(0,y)
  arrayout(4,y)=m_5(0,y)
  arrayout(5,y)=m_6(0,y)
  arrayout(6,y)=m_7(0,y)
  arrayout(7,y)=m_8(0,y)
  arrayout(8,y)=m_9(0,y)
  arrayout(9,y)=m_10(0,y)
end do  

;==========================
; write out data to a txt file...
  print(">>>>>>>>>>>> writing first text file")

foutname="meanvals_10GCMs_"+vertavg+"hPa_"+chunk+"_"+SST+".txt"

option         = True   ; if False then output is sent to standard out 
option@fout    = foutname
option@title   = "omega_db, I, omega_dn, omega_up, SF, SST, omega_db2, Qmn, sig_mn"
write_matrix (arrayout, "9f14.4", option)


end

