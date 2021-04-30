;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; cam_2D_omega.ncl
; 
; plot 2D maps of omega 
; the period over which the omega fields are averaged should be specified
;
; this script can also plot a coarsened plot based on a particular block size.
;
; the SAM RCEMIP experiments used a grid-spacing of 3km on a grid of 128x2048 grid points
; that corresponds to 384x6144 km^2.
; 
; for a grid that is coarsened to grid spacing of 96km the resulting grid would have 
; 4x64 grid points
;
; for a grid that is coarsened to grid spacing of 192km (as in Cronin and Wing, 2017) would 
; have a grid with 2x32 grid points.
;
; levi silvers                                                                 mar 2021
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  print("@@@@@@@@@@@@ entering omega_2D_plot.ncl script @@@@@@@@@@@@@@@@@@@@@@@@@@")

;******************************************************
;  Open a netCDF file containing the grid and data from the HOMME
;  (High-Order Multiscale Modeling Environment) model, formerly
;  called SEAM (Spectral Element Atmosphere Model).
;******************************************************
  wks_type = "eps"
  wks_type@wkPaperWidthF  =  8.5  ; in inches
  wks_type@wkPaperHeightF = 11.0  ; in inches
  wks = gsn_open_wks(wks_type,"omega_testplot")
  ;gsn_define_colormap(wks,"gsltod")   ; choose colormap
  ;gsn_define_colormap(wks,"NCV_jaisnd")   ; choose colormap
  gsn_define_colormap(wks,"amwg256")   ; choose colormap

  RCEMIP_dir = "/glade/scratch/levi/RCEMIP/"
;  plot_time = 1*24*365*3   ; this will need to be changed evenutally...
  plot_time = 26200; 
; set SST used with i: 
if (isvar("seaST")) then
  temp=seaST
else
  temp="295"
end if
model = "SAM_CRM"

  print("{{{{{{{{{{ The SST value is: "+temp+"}}}}}}}}}}")

;ntemp = dimsizes(temp)
;nmodel= dimsizes(model)

;  filein_c5 = addfile(RCEMIP_dir+model(0)+"_GCM/RCE_large"+temp(tempindex)+"/2D/"+model(0)+"_GCM_RCE_large"+temp(tempindex)+"_2D_wap500.nc","r")
;  filein_c6 = addfile(RCEMIP_dir+model(1)+"_GCM/RCE_large"+temp(tempindex)+"/2D/"+model(1)+"_GCM_RCE_large"+temp(tempindex)+"_2D_wap500.nc","r")
;
 
;do j = 0,nmodel-1
;  omega_array = new((/3,192,288/),"float") 
;    print("Creating plots for temperature = "+temp(tempindex))
  ;file_omega = addfile(RCEMIP_dir+model(j)+"_GCM/RCE_large"+temp(i)+"/2D/"+model(j)+"_GCM_RCE_large"+temp(i)+"_2D_wap500.nc","r")

  file_omega = addfile(RCEMIP_dir+"swift.dkrz.de/"+model+"/"+model+"_RCE_large"+temp+"_2D_wa500.nc","r")
  
;  omega      = file_omega->wap500(plot_time,:,:)

; grab data over a one day period of time: 
;  omega_raw = file_omega->wa500(2000:2023,:,:)
; grab data over a 20 day period of time: 
  ;omega_raw = file_omega->wa500(1920:2399,:,:)
; grab data over 50 days
;  omega_raw = file_omega->wa500(1200:2399,:,:)
; grab data over 75 days
  omega_raw = file_omega->wa500(600:2399,:,:)
    printVarSummary(omega_raw)

dims=dimsizes(omega_raw)
fulltime=dims(0)
xdim=dims(1)
ydim=dims(2)
timewindow=120
nperds=fulltime/timewindow

print("nperds, number of periods is: "+nperds)
print("block of days averaged over is: "+timewindow/24)

; create a chunked array...
a_reshape       = new((/timewindow,nperds,xdim,ydim/),float)
a_reshape       = reshape(omega_raw,(/timewindow,nperds,xdim,ydim/))
omega_block     = dim_avg_n(a_reshape,0)

  omega_raw@_FillValue = default_fillvalue("float")
  omega_coarse = -scalef*omega_raw
  omega_block  = -scalef*omega_block

;--------------------------
;;; parameters for grid blocks of 192km 
cors_array  = new((/dims(0),2,32/),float)
block_array = new((/nperds,4,64/),float)
block = floattointeger(64) ; block size for grid spacing of 192km
iend  = 1 ; for 2048 gridpoints, there are 32 blocks of 64
jend  = 31 ; for 128 gridpoints, there are two blocks of 64 

;;; parameters for grid blocks of 96km 
;cors_array  = new((/dims(0),4,64/),float)
;block_array = new((/nperds,4,64/),float)
;block = floattointeger(32) ; block size for grid spacing of 96km
;iend  = 3 ; for 2048 gridpoints, there are 32 blocks of 64
;jend  = 63 ; for 128 gridpoints, there are two blocks of 64 

tend  = dims(0) 

; without blocks
do t=0,tend-1
  do i=0,iend
    icounter=i*block
    do j=0,jend  
      jcounter=j*block
      cors_single   =omega_coarse(t,icounter:icounter+block-1,jcounter:jcounter+block-1)
      cors_array(t,i,j)=avg(cors_single)
    end do
  end do
end do

; with blocks
do t=0,nperds-1
  do i=0,iend
    icounter=i*block
    do j=0,jend  
      jcounter=j*block
      block_single   =omega_block(t,icounter:icounter+block-1,jcounter:jcounter+block-1)
      block_array(t,i,j)=avg(block_single)
    end do
  end do
end do

block_array@_FillValue = default_fillvalue("float")


; --------------------------------------
; sort into rising and sinking arrays...
; --------------------------------------
; with data averaged over blocks...
omega_up_a=where((block_array .le. 0),block_array,block_array@_FillValue)
omega_dn_a=where((block_array .ge. 0),block_array,block_array@_FillValue)
omega_bar_u_a  = wgt_areaave(omega_up_a,1.0,1.0,0)
omega_bar_d_a  = wgt_areaave(omega_dn_a,1.0,1.0,0)
circ_a = omega_bar_d_a - omega_bar_u_a 

  print("blocked max of omega_coarse is: "+max(omega_coarse))
  print("blocked max of block_array is: "+max(block_array))
  print("blocked max/min of omega_bar_d_a is: "+max(omega_bar_d_a)+" and "+min(omega_bar_d_a))
  print("blocked min of omega_coarse is: "+min(omega_coarse))
  print("blocked min of block_array is: "+min(block_array))
  print("blocked max/min of omega_bar_u_a is: "+max(omega_bar_u_a)+" and "+min(omega_bar_u_a))
  print("{{{{{{{{{{{{{{   }}}}}}}}}}}}}}") 
  print("blocked time averaged bar omega dn: "+dim_avg_n(omega_bar_d_a,0))
  print("blocked time averaged bar omega up: "+dim_avg_n(omega_bar_u_a,0))
  print("blocked time averaged intensity of the circulation is: "+dim_avg_n(circ_a,0))
  print("{{{{{{{{{{{{{{   }}}}}}}}}}}}}}") 

; without data averaged over blocks...
omega_up_b=where((cors_array .le. 0),cors_array,cors_array@_FillValue)
omega_dn_b=where((cors_array .ge. 0),cors_array,cors_array@_FillValue)
omega_bar_u_b  = wgt_areaave(omega_up_b,1.0,1.0,0)
omega_bar_d_b  = wgt_areaave(omega_dn_b,1.0,1.0,0)
circ_b = omega_bar_d_b - omega_bar_u_b 

  print("max of omega_coarse is: "+max(omega_coarse))
  print("max of cors_array is: "+max(cors_array))
  print("max/min of omega_bar_d_b is: "+max(omega_bar_d_b)+" and "+min(omega_bar_d_b))
  print("min of omega_coarse is: "+min(omega_coarse))
  print("min of cors_array is: "+min(cors_array))
  print("max/min of omega_bar_u_b is: "+max(omega_bar_u_b)+" and "+min(omega_bar_u_b))
  print("{{{{{{{{{{{{{{   }}}}}}}}}}}}}}") 
  print("time averaged bar omega dn: "+dim_avg_n(omega_bar_d_b,0))
  print("time averaged bar omega up: "+dim_avg_n(omega_bar_u_b,0))
  print("time averaged intensity of the circulation is: "+dim_avg_n(circ_b,0))
  print("{{{{{{{{{{{{{{   }}}}}}}}}}}}}}") 

;--------------------------------------

; we need one more color than level
; if zero is desired to be the center point then we should have an even number of colors

my_levels1 = (/150,140,130,120,110, \
               100,90,80,70,60, \
               50,40,30,20,10, \
               0, \
               -10,-20,-30,-40,-50, \
               -60,-70,-80,-90,-100, \
               -110,-120,-130,-140,-150/)
my_colors1 = (/25,32,39,46,51, \
               58,65,72,79,86, \
              93,100,107,114,121, \
              128,129, \
              136,143,150,157,164, \
              171,177,184,191,198, \
              210,225,235,245,255/) ; 
 
  res1                      = True         ; plot modifications desired
  res1@gsnDraw              = False        ; don't draw plot
  res1@gsnFrame             = False        ; don't advance frame

  ;res1@cnLevelSelectionMode = "manualLevels"    ; set contour intervals
  res1@cnLevelSelectionMode = "ExplicitLevels"    ; set contour intervals
  ;res1@cnLevelSpacingF      =  20.                ;
  ;res1@cnMinLevelValF       =  -150.0           ;
  ;res1@cnMaxLevelValF       =  150.0 ;
  res1@cnLevels            = my_levels1
  res1@cnFillColors        = my_colors1
  res1@cnFillOn             = True         ; Turn on contour fill
  res1@cnFillMode           = "RasterFill"
  res1@vpWidthF             = 0.95
  res1@vpHeightF            = 0.095
  res1@cnLinesOn            = False        ; Turn off contour lines
  res1@cnLineLabelsOn       = False        ; Turn off contour line labels
  res1@lbLabelBarOn         = False

  res1@gsnRightString  = ""
  res1@gsnLeftString   = ""

  res1@tiYAxisFontHeightF    = 0.025
  res1@tiYAxisFont           = 22   
  res1@tiYAxisSide           = "Left"

  ;plot1 = gsn_csm_contour(wks,block_array(:,:),res1)
    print("WARNING!! only plotting one of many possible times.")
  plot1 = gsn_csm_contour(wks,block_array(0,:,:),res1)
;  

panelres1                            = True
panelres1@gsnFrame                   = False   ; save panel until both ready 
panelres1@gsnPanelBottom             = 0.2     ; shrink panel plot by setting bottom edge of plot
panelres1@gsnPanelTop                = 0.9     ; shrink panel plot by setting top edge of plot
panelres1@gsnPanelLabelBar           = True
;panelres1@vpXF                       = 0.518-.22 ; Position labelbar at
panelres1@vpHeightF                  = 0.095     ; Height of labelbar
panelres1@vpWidthF                   = 0.44      ; Width of labelbar
panelres1@lbLabelFontHeightF         = 0.01
panelres1@lbLabelStride              = 2
panelres1@txPosXF                    = 0.72
panelres1@txPosYF                    = 0.925
panelres1@txFont                     = 22 
;panelres1@lbTitleString              = "Outgoing Longwave Radiation (W/m~S~2~N~)"
panelres1@lbTitleString              = "Instantaneous Pressure Velocity (hPa/day) "
panelres1@lbTitlePosition            = "Top"
panelres1@lbTitleFontHeightF         = 16
panelres1@lbTitleFont                = 22
panelres1@pmLabelBarOrthogonalPosF   = -.01
gsn_panel(wks,plot1, (/1,1/),panelres1)

frame(wks)

  print("@@@@@@@@@@@@ leaving omega_2D_plot.ncl script @@@@@@@@@@@@@@@@@@@@@@@@@@")

end

