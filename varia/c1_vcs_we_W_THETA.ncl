;; start_list_of_input_files
;; /scratch/morsier/wd/17060503_102/resource/_NCLINP_const_f.nc
;; /scratch/morsier/wd/17060503_102/resource/_NCLINP_000_ml_f.nc
;; end_list_of_input_files

;; start_list_of_output_files
;; ./c1_vcs_sn_rh_000_000.png
;; end_list_of_output_files

;; plot_cost: 5

load "/users/morsier/ncl/cosmolib/src/panel_functions.ncl"


begin

 cosmolib_verbosity =  "INFO"

 cosmolib_tictoc_on =  False

 sloc = "main"

 ;; ================================================================================
 ;; open files, read variables and attach grid info
 ;; ================================================================================
 filec = addfile             ("./_NCLINP_const_c.nc","r")
 cosmolib_info(sloc,"open file ./_NCLINP_const_c.nc")
 file01 = addfile            ("./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc","r")
 cosmolib_info(sloc,"open file ./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc")
 
 res_getvar=True
 w0100 = jmb_getvar(file01,"W",res_getvar)
print(file01)
 hfl = jmb_getvar(file01,"HFL",res_getvar)
 hhl = jmb_getvar(file01,"HHL",res_getvar)
 z_1 = jmb_getvar(file01,"z_1",res_getvar)
 z_2 = jmb_getvar(file01,"z_2",res_getvar)
 slice = jmb_getvar(file01,"slice",res_getvar)
 label = jmb_getvar(file01,"label",res_getvar)
 labels = str_split(slice@labels," ")
; print(labels)          ; gdm
; printVarSummary(label) ; gdm
 length = jmb_getvar(file01,"length",res_getvar)
 length = length/1000.0
 length@units = "km"
; print("Replace length@long_name: "+length@long_name) ; gdm
; print("    with slice@long_name: "+slice@long_name)  ; gdm
 length@long_name=slice@long_name

; define slice name labels
 n_sln = 0
   sln =   (/labels/)
   sln@loc = fspan(0, length(dimsizes(label)-1),dimsizes(labels))
 printVarSummary(sln)
 do i = 1, dimsizes(label)-1
   if ((/label(i)/) .ne. 0) then
     n_sln = n_sln + 1
     ; remove underscores
     if (isStrSubset(sln(n_sln),"_")) then  
       str = str_split(sln(n_sln),"_")
       sln(n_sln) = str(0)+" "+str(1)
     end if
     ; remove unnamed ticks
     if (sln(n_sln) .eq. "-") then
       sln(n_sln) =""
     end if
     sln@loc(n_sln) = (/length(i)/) 
   end if
 end do
 print("gdm: "+sln+" length: "+sln@loc)

 topo = jmb_getvar(file01,"topo",res_getvar)
; jmb_getgrid(file01,filec,hfl,False)

; generate level attributes
  lev1 = file01->z_1
  lev2 = file01->z_2
  nlev1 = dimsizes(lev1)
  nlev2 = dimsizes(lev2)

  ; set coordinate dimension
; generate coordinate variables in level/length space instead of j/i space
  w0100!0 = "level"
  w0100!1 = "length"
  w0100&level = lev2
  w0100&length = length
  ; generate attributes:
  w0100@slice_type = "vertical"
  w0100@topo = topo
  w0100@z = hhl
  w0100@level_type = "levels"
  w0100@level_height = "z"
  w0100@level_height_units = "m"
  w0100@level_height_long_name = "height"

; printVarSummary(w0100)

 theta0100 = jmb_getvar(file01,"THETA",res_getvar)
 theta0100!0 = "level"
 theta0100!1 = "length"
 theta0100&level = lev1
 theta0100&length = length
 ; generate attributes:
 theta0100@slice_type = "vertical"
 theta0100@topo = topo
 theta0100@z = hfl
 theta0100@level_type = "levels"
 theta0100@level_height = "z"
 theta0100@level_height_units = "m"
 theta0100@level_height_long_name = "height"

 ; clean up
 delete(lev1)
 delete(lev2)
 delete(nlev1)
 delete(nlev2)
 delete(res_getvar)

 ;; ================================================================================
 ;; get meta information for plot title
 ;; ================================================================================
 var_meta_plot_title     = get_var_meta_info(w0100)
 var_meta_plot_title@infile  = "./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc"
 file_meta_plot_title        = get_file_meta_info(file01)
 file_meta_plot_title@infile = "./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc"
 ;; ================================================================================
 ;; open workstation
 ;; ================================================================================
 res_wks = True
 res_wks@PaperOrientation = "portrait"
 res_wks@PaperHeight = 29.7
 res_wks@PaperWidth = 21.0
 res_wks@FileFormat = "pdf"
 res_wks@FileName = "./c1_vcs_we_W_THETA_000"
 res_wks@DrawNDCGrid = False
 wks = open_wks(res_wks)
 dummy = jmb_set_ct(wks,"default",False)
 ;; ================================================================================
 ;; define resources
 ;; ================================================================================
 ;; ------------------------------
 ;; default resources
 ;; ------------------------------
 res_def_convert = True
 res_def_convert@infile = res_wks@FileName
 res_def_convert@informat = "pdf"
 res_def_convert@outformat = "png"
 res_def_convert@opt_depth = 8
 res_def_convert@opt_quality = 100
 res_def_convert@opt_density = 95
 res_def_convert@opt_trim = "-trim"
 res_def_convert@opt_bordercolor = "white"
 res_def_convert@opt_border = 3
 res_def_convert@opt_gravity = "northwest"
 res_def_convert@opt_extent = "766x"
 res_def_convert@opt_background = "white"
 res_def_convert@opt_flatten = "-"
 res_def_convert@opt_repage = "+"

 res_eshop_convert = True
 res_eshop_convert@infile = res_wks@FileName
 res_eshop_convert@outfile_prefix = "eshop_"
 res_eshop_convert@informat = "pdf"
 res_eshop_convert@outformat = "png"
 res_eshop_convert@opt_depth = 8
 res_eshop_convert@opt_quality = 100
 res_eshop_convert@opt_density = 114
 res_eshop_convert@opt_trim = "-trim"
 res_eshop_convert@opt_bordercolor = "white"
 res_eshop_convert@opt_border = 3
 res_eshop_convert@opt_gravity = "northwest"
 res_eshop_convert@opt_extent = "897x"
 res_eshop_convert@opt_background = "white"
 res_eshop_convert@opt_flatten = "-"
 res_eshop_convert@opt_repage = "+"

 res_def_pag_xz = True
 res_def_pag_xz@left_margin = 0.02
 res_def_pag_xz@right_margin = 0.02
 res_def_pag_xz@top_margin = 0.07
 res_def_pag_xz@bottom_margin = 0.02
 res_def_pag_xz@XMin = res_wks@NDC_LowerX
 res_def_pag_xz@YMin = res_wks@NDC_LowerY
 res_def_pag_xz@XMax = res_wks@NDC_UpperX
 res_def_pag_xz@YMax = res_wks@NDC_UpperY
 res_def_pag_xz@XMinPanel = 0.11
 res_def_pag_xz@YMaxPanel = 0.88
 res_def_pag_xz@XPanel = 0.5
 res_def_pag_xz@DxPanel = 0.02
 res_def_pag_xz@DyPanel = 0.02
 res_def_pag_xz@NPanelCols = 1

 res_def_pag_xy = True
 res_def_pag_xy@left_margin = 0.02
 res_def_pag_xy@right_margin = 0.02
 res_def_pag_xy@top_margin = 0.07
 res_def_pag_xy@bottom_margin = 0.02
 res_def_pag_xy@XMin = res_wks@NDC_LowerX
 res_def_pag_xy@YMin = res_wks@NDC_LowerY
 res_def_pag_xy@XMax = res_wks@NDC_UpperX
 res_def_pag_xy@YMax = res_wks@NDC_UpperY
 res_def_pag_xy@XMinPanel = 0.02
 res_def_pag_xy@YMaxPanel = 0.88
 res_def_pag_xy@XPanel = 0.59
 res_def_pag_xy@DxPanel = 0.02
 res_def_pag_xy@DyPanel = 0.02
 res_def_pag_xy@NPanelCols = 2

 res_pag = True
 res_pag = res_def_pag_xy

 res_def_xy_filled_oro = True
 res_def_xy_filled_oro@cutname = "level"
 res_def_xy_filled_oro@cnFillOn = True
 res_def_xy_filled_oro@cnLinesOn = False
 res_def_xy_filled_oro@cnFillMode = "RasterFill"
 res_def_xy_filled_oro@cnRasterSmoothingOn = False
 res_def_xy_filled_oro@cnInfoLabelOn = False
 res_def_xy_filled_oro@cnConstFLabelOn = False
 res_def_xy_filled_oro@cnNoDataLabelOn = False
 res_def_xy_filled_oro@cnMissingValFillColor = "grey80"
 res_def_xy_filled_oro@lbLabelBarOn = True
 res_def_xy_filled_oro@lbLabelAutoStride = False
 res_def_xy_filled_oro@lbLabelFontHeightF = 0.011
 res_def_xy_filled_oro@lbLeftMarginF = 0
 res_def_xy_filled_oro@lbLabelOffsetF = 0.05
 res_def_xy_filled_oro@lbTitleOn = True
 res_def_xy_filled_oro@lbTitleExtentF = 0.05
 res_def_xy_filled_oro@lbTitleFontHeightF = 0.011
 res_def_xy_filled_oro@lbTitleOffsetF = 0.02
 res_def_xy_filled_oro@pmLabelBarOrthogonalPosF = -0.05

 res_def_xy_filled = True
 res_def_xy_filled@cutname = "level"
 res_def_xy_filled@cnFillOn = True
 res_def_xy_filled@cnLinesOn = False
 res_def_xy_filled@cnFillMode = "AreaFill"
 res_def_xy_filled@cnInfoLabelOn = False
 res_def_xy_filled@cnConstFLabelOn = False
 res_def_xy_filled@cnNoDataLabelOn = False
 res_def_xy_filled@cnMissingValFillColor = "grey80"
 res_def_xy_filled@lbLabelBarOn = True
 res_def_xy_filled@lbLabelAutoStride = False
 res_def_xy_filled@lbLabelFontHeightF = 0.011
 res_def_xy_filled@lbLeftMarginF = 0
 res_def_xy_filled@lbLabelOffsetF = 0.05
 res_def_xy_filled@lbTitleOn = True
 res_def_xy_filled@lbTitleExtentF = 0.05
 res_def_xy_filled@lbTitleFontHeightF = 0.011
 res_def_xy_filled@lbTitleOffsetF = 0.02
 res_def_xy_filled@pmLabelBarOrthogonalPosF = -0.05

 res_def_xz_filled = True
 res_def_xz_filled@cnFillOn = True
 res_def_xz_filled@cnLinesOn = False
 res_def_xz_filled@cnFillMode = "AreaFill"
 res_def_xz_filled@cnInfoLabelOn = False
 res_def_xz_filled@cnConstFLabelOn = False
 res_def_xz_filled@cnNoDataLabelOn = False
 res_def_xz_filled@cnMissingValFillColor = "black"
 res_def_xz_filled@lbLabelBarOn = True
 res_def_xz_filled@lbLabelAutoStride = False
 res_def_xz_filled@lbLabelFontHeightF = 0.011
 res_def_xz_filled@lbLeftMarginF = 0
 res_def_xz_filled@lbLabelOffsetF = 0.05
 res_def_xz_filled@lbTitleOn = True
 res_def_xz_filled@lbTitleExtentF = 0.05
 res_def_xz_filled@lbTitleFontHeightF = 0.011
 res_def_xz_filled@lbTitleOffsetF = 0.02
 res_def_xz_filled@pmLabelBarOrthogonalPosF = -0.05
 res_def_xz_filled@tmXBMode              = "Explicit"
 res_def_xz_filled@tmXBValues            = sln@loc ; gdm
 res_def_xz_filled@tmXBLabels            = sln     ; gdm
 res_def_xz_filled@tmXBLabelAngleF       = 30.0
 res_def_xz_filled@tmXBLabelJust         = "CenterRight"
 res_def_xz_filled@tmXBMajorLengthF = -0.01
 res_def_xz_filled@tmXBLabelFontHeightF = 0.010
 res_def_xz_filled@tmYLLabelFontHeightF = 0.010
 res_def_xz_filled@tiXAxisFontHeightF = 0.012
 res_def_xz_filled@tiYAxisFontHeightF = 0.012

 res_def_xz_line = True
 res_def_xz_line@cutname = "level"
 res_def_xz_line@cnFillOn = False
 res_def_xz_line@cnLinesOn = True
 res_def_xz_line@cnLineThicknessF = 1.0
 res_def_xz_line@cnLineColor = "black"
 res_def_xz_line@cnLineLabelsOn = True
 res_def_xz_line@cnLineLabelAngleF = -1.0
 res_def_xz_line@cnLineLabelDensityF = 0.8
 res_def_xz_line@cnLabelMasking = True
 res_def_xz_line@cnLineLabelPerimOn = False
 res_def_xz_line@cnNoDataLabelOn = False
 res_def_xz_line@tmXBMajorLengthF = -0.01
 res_def_xz_line@tmXBLabelFontHeightF = 0.010
 res_def_xz_line@tmYLLabelFontHeightF = 0.010
 res_def_xz_line@tiXAxisFontHeightF = 0.012
 res_def_xz_line@tiYAxisFontHeightF = 0.012

 res_def_xy_line = True
 res_def_xy_line@cutname = "level"
 res_def_xy_line@cnFillOn = False
 res_def_xy_line@cnLinesOn = True
 res_def_xy_line@cnLineThicknessF = 3.0
 res_def_xy_line@cnLineColor = "black"
 res_def_xy_line@cnLineLabelsOn = True
 res_def_xy_line@cnLabelMasking = True
 res_def_xy_line@cnLineLabelPerimOn = False
 res_def_xy_line@cnNoDataLabelOn = False

 res_def_xy_vector = True
 res_def_xy_vector@cutname = "level"
 res_def_xy_vector@vcGlyphStyle = "CurlyVector"
 res_def_xy_vector@vcMinFracLengthF = 0.0
 res_def_xy_vector@vcRefAnnoOn = False

 res_gen = True
 res_gen@jmbAnnotationsOn = False
 res_gen@gsnMaximize = False

 res_def_ov = True
 res_def_ov = res_gen
 res_def_ov@gsnFrame = False
 res_def_ov@jmbCopyrightOn = True
 res_def_ov@jmbCopyrightFontHeightF = 0.01
 res_def_ov@jmbPanelAnnoOn = False
 res_def_ov@jmbPanelAnnoamJust = "BottomLeft"

 res_ov = True
 res_ov = res_def_ov

 res_def_map = True
 res_def_map = res_gen
 res_def_map@mpGridAndLimbOn = True
 res_def_map@mpGridLineDashPattern = 2
 res_def_map@mpOutlineOn = True
 res_def_map@mpNationalLineColor = "Black"
 res_def_map@mpGeophysicalLineColor = "Black"
 res_def_map@mpShapeMode = "FixedAspectNoFitBB"
 res_def_map@tmXBOn = False
 res_def_map@tmYLOn = False
 res_def_map@tiMainOn = False
 res_def_map@geo = False
 res_def_map@geo_domain = "cosmo1_latlon"
 res_def_map@geo_rank_coast = 3
 res_def_map@geo_rank_border = 1
 res_def_map@geo_rank_river = 2
 res_def_map@geo_color_coast = "Black"
 res_def_map@geo_color_border = "Black"
 res_def_map@geo_color_river = "grey40"
 res_def_map@geo_thick_coast = 1
 res_def_map@geo_thick_border = 1
 res_def_map@geo_thick_river = 1

 res_def_top_text = True
 res_def_top_text@txFontQuality = "High"
 res_def_top_text@txFontHeightF = 0.012
 res_def_top_text@txFontColor = "Black"

 res_def_bottom_text = True
 res_def_bottom_text@txFontQuality = "High"
 res_def_bottom_text@txFontHeightF = 0.01
 res_def_bottom_text@txFontColor = "Black"

 res_text_01 = True
 res_text_01 = res_def_top_text
 res_text_01@string = str_upper(file_meta_plot_title@model_name_and_type)

 res_text_02 = True
 res_text_02 = res_def_top_text
 res_text_02@string = file_meta_plot_title@model_version

 res_text_03 = True
 res_text_03 = res_def_top_text
 res_text_03@string = var_meta_plot_title@validation_time
 res_text_03@txFontColor = "Red"

 res_text_04 = True
 res_text_04 = res_def_top_text

 res_text_05 = True

 res_text_06 = True
 res_text_06 = res_def_top_text
 res_text_06@string = var_meta_plot_title@model_run

 res_text_07 = True
 res_text_07 = res_def_bottom_text

 res_text_08 = True
 res_text_08 = res_def_bottom_text

 res_text_09 = True
 res_text_09 = res_def_bottom_text

 res_text_10 = True
 res_text_10 = res_def_bottom_text

 res_text_11 = True
 res_text_11 = res_def_bottom_text

 res_text_12 = True
 res_text_12 = res_def_bottom_text

 res_text_13 = True
 res_text_13 = res_def_bottom_text

 res_text_14 = True
 res_text_14 = res_def_bottom_text

 res_text_15 = True
 res_text_15 = res_def_bottom_text

 res_text_16 = True
 res_text_16 = res_def_bottom_text

 res_text_17 = True
 res_text_17 = res_def_bottom_text

 res_text_18 = True
 res_text_18 = res_def_bottom_text

 res_def_labelbar = True
 res_def_labelbar@lbAutoManage = False
 res_def_labelbar@lbPerimOn = False
 res_def_labelbar@lbBottomMarginF = 0.0
 res_def_labelbar@lbTopMarginF = 0.0
 res_def_labelbar@lbLeftMarginF = 0.0
 res_def_labelbar@lbRightMarginF = 0.0
 res_def_labelbar@lbJustification = "TopLeft"
 res_def_labelbar@lbOrientation = "Vertical"
 res_def_labelbar@vpWidthF = 0.025
 res_def_labelbar@lbBoxMinorExtentF = 1.0
 res_def_labelbar@lbTitleOn = True
 res_def_labelbar@lbTitleString = "%"
 res_def_labelbar@lbTitleFontHeightF = res_def_top_text@txFontHeightF
 res_def_labelbar@lbTitleJust = "TopLeft"
 res_def_labelbar@lbTitleExtentF = 0.025
 res_def_labelbar@lbLabelsOn = True
 res_def_labelbar@lbLabelAlignment = "InteriorEdges"
 res_def_labelbar@lbLabelOffsetF = 0.5
 res_def_labelbar@lbLabelFontHeightF = res_def_top_text@txFontHeightF
 res_def_labelbar@lbMonoFillPattern = True

 ;; ------------------------------
 ;; plot resources
 ;; ------------------------------
 res_pag = True
 res_pag = res_def_pag_xz

 res_ov = True
 res_ov = res_def_ov
 res_ov@jmbCopyrightOn = False

 ;; ================================================================================
 ;; define panels
 ;; ================================================================================

 ;; ==============================
 ;; Panel
 ;; ==============================
 res_pag@DomainAspectRatio = 1.5
 res_pos = True
 res_pos@vpWidthF = res_pag@XPanel
 res_pos@vpHeightF = res_pag@XPanel/res_pag@DomainAspectRatio
 res_pos@vpXF = res_pag@XMinPanel + mod(0,res_pag@NPanelCols)*(res_pag@XPanel+res_pag@DxPanel)
 res_pos@vpYF = res_pag@YMaxPanel - toint(0/res_pag@NPanelCols)*(res_pos@vpHeightF+res_pag@DyPanel)

 ;; Layer
 res_w = jmb_set_ct(wks,"w_18lev",False)
 res_w = res_gen
 res_w = res_pos
 res_w = res_def_xz_filled
 res_w@units = "m/s"
 res_w@cutname = "latlon_list"
 res_w@trYMaxF = 4000
 res_w@lbTitleString = "m/s"

 ;; Layer
 res_theta = True
 res_theta = res_gen
 res_theta = res_pos
 res_theta = res_def_xz_line
 res_theta@cnLevelSelectionMode = "ManualLevels"
 res_theta@cnLevelSpacingF = 2.0
 res_theta@cnMinLevelValF = 200.0
 res_theta@cnLineThicknessF = 1.0
 res_theta@cnLineLabelFontHeightF = 0.008
 res_theta@cnLineLabelInterval = 1
 res_theta@cnLineLabelDensityF = 1.3

 ;; Add grid information to res_ov (for relaxation zone box)
 if (isatt(res_ov,"jmbBox") .and. res_ov@jmbBox) then
   add_grid_info(w0100,res_ov)
 end if

 ;; Subroutine Call
 panel000 = xz_field1_field2(wks,w0100,theta0100,res_w,res_theta,res_ov)
 ;; ================================================================================
 ;; Draw Label Bars
 ;; ================================================================================
 map = gsn_retrieve_colormap(wks)

 ;; ================================================================================
 ;; Draw Text Boxes
 ;; ================================================================================

 ;; ------------------------------
 ;; Set Plot Text Resources
 ;; ------------------------------
 res_text_04 = True
 res_text_04 = res_def_top_text
 res_text_04@string = "Relative Humidity Over Ice and Potential Temperature"

;res_text_11 = True
;res_text_11 = res_def_bottom_text
;res_text_11@string = slice@type
 res_text_13 = True
 res_text_13 = res_def_bottom_text
 res_text_13@string = res_w@slicename


 ;; ------------------------------
 ;; Set Position Resources and Draw Textbox 1
 ;; ------------------------------
 x1=res_pag@left_margin
 dx=res_pag@XMax - 2*res_pag@right_margin
 dy=3*res_def_top_text@txFontHeightF
 y1=res_pag@YMax - res_pag@top_margin - dy
 box = (/x1,y1,x1+dx,y1+dy/)
 draw_text_array_3x2_ndc(wks,box,\
 res_text_01,\
 res_text_02,\
 res_text_03,\
 res_text_04,\
 res_text_05,\
 res_text_06,False)

 ;; ------------------------------
 ;; Set Position Resources and Draw Textbox 2 and 3
 ;; ------------------------------
 x1=res_pag@left_margin
 dx=res_pag@XMax - 2*res_pag@right_margin
 dy=3*res_def_bottom_text@txFontHeightF
 y1=res_pos@vpYF - res_pos@vpHeightF - 1.5*dy
 box = (/x1,y1,x1+dx,y1+dy/)
 draw_text_array_3x2_ndc(wks,box,\
 res_text_07,\
 res_text_08,\
 res_text_09,\
 res_text_10,\
 res_text_11,\
 res_text_12,False)
 x1=res_pag@left_margin
 dx=res_pag@XMax - 2*res_pag@right_margin
 dy=3*res_def_bottom_text@txFontHeightF
 y1=y1-1.14*dy
 box = (/x1,y1,x1+dx,y1+dy/)
 draw_text_array_3x2_ndc(wks,box,\
 res_text_13,\
 res_text_14,\
 res_text_15,\
 res_text_16,\
 res_text_17,\
 res_text_18,False)

 ;; ================================================================================
 ;; Close output file
 ;; ================================================================================
 delete(wks)

 ;; ================================================================================
 ;; Convert Output File(s)
 ;; ================================================================================
 res_convert=True
 delete(res_convert)
 res_convert = True
 res_convert = res_def_convert
 img_convert(res_convert)

 cosmolib_info(sloc,"NCL script successfully completed")

end

