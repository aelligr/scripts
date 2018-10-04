!
! test_slice3.nl is part of the standard set of fieldextra tests
! 
! It extracts 2D vertical slices from COSMO-1 output, and generates 
! NetCDF output. Slices are approximated on grid (nn_on_grid).
!
!--------------------------------------------------------------------------

&RunSpecification
 additional_diagnostic = .true.
 additional_profiling  = .true.
 strict_nl_parsing     = .true.
 n_ompthread_total     = 2
 n_ompthread_collect   = 2
 n_ompthread_generate  = 2
 verbosity             = "high"
 diagnostic_length     = 100
/

&GlobalResource
 dictionary               = "/users/morsier/projects/resources/dictionary_cosmo.txt"
 grib_definition_path     = "/users/morsier/projects/resources/grib_api_definitions_cosmo",
                            "/users/morsier/projects/resources/grib_api_definitions_vendor"
 location_list            = "/users/morsier/projects/resources/location_list.txt"
 slice_list               = "/users/morsier/projects/resources/slice_list.txt"
/

&GlobalSettings
 default_dictionary      = "cosmo"  
 default_model_name      = "cosmo-1"
 location_to_gridpoint   = "sn" 
 slice_to_gridpoint      = "nn" 
 slice_resolution_factor = 0.5
 slice_upscaling_factor  = 10
 originating_center      = "Zurich"
 auxiliary_metainfo      = "localNumberOfExperiment=104", 
/

&ModelSpecification
 model_name         = "cosmo-1"
 earth_axis_large   = 6371229.
 earth_axis_small   = 6371229.
 hydrometeor        = "QR", "QG", "QS"
 precip_all         = "RAIN_GSP", "SNOW_GSP", "GRAU_GSP"
 precip_snow        = "SNOW_GSP", "GRAU_GSP"
 precip_rain        = "RAIN_GSP"
 precip_convective  =
 precip_gridscale   = "RAIN_GSP", "SNOW_GSP", "GRAU_GSP"
/


&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff00000000c"
  out_type="INCORE" 
/
&Process in_field ="FR_LAND" /
&Process in_field ="HSURF", tag="GRID" /



! Slice expressed in (lat,lon) space
!-----------------------------------
&Process
  in_type="INCORE"
  out_file="./results/slice3_upscaling_factor_10/geneve_munich.nc", out_type="NETCDF", 
  slice="Geneve-Munich"
/
&Process in_field ="HFL" /

&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff<DDHH>0000"
  tstart=0 , tstop=0 , tincr=1, 
  out_file="./results/slice3_upscaling_factor_10/geneve_munich.nc", out_type="NETCDF", 
  slice="Geneve-Munich"
/
&Process in_field ="P" /
&Process in_field ="T" /
&Process in_field ="QV" /

&Process out_field="T", offset=-273.15 /
&Process out_field="RELHUM", hoper="s9" /
&Process out_field="HFL" /



! Slice expressed in (location) space
!------------------------------------
&Process
  in_type="INCORE"
  out_file="./results/slice3_upscaling_factor_10/GVE-VIS.nc", out_type="NETCDF", 
  slice="GVE-VIS"
/
&Process in_field ="HFL" /

&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff<DDHH>0000"
  tstart=0 , tstop=0 , tincr=1, 
  out_file="./results/slice3_upscaling_factor_10/GVE-VIS.nc", out_type="NETCDF", 
  slice="GVE-VIS"
/
&Process in_field ="P" /
&Process in_field ="T" /
&Process in_field ="QV" /

&Process out_field="T", offset=-273.15 /
&Process out_field="RELHUM" /
&Process out_field="HFL" /
 


! Slice expressed in (i,j) space
!-----------------------------------
&Process
  in_type="INCORE"
  out_file="./results/slice3_upscaling_factor_10/j100.nc", out_type="NETCDF", 
  slice="j100"
/
&Process in_field ="HFL" /

&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff<DDHH>0000"
  tstart=0 , tstop=0 , tincr=1, 
  out_file="./results/slice3_upscaling_factor_10/j100.nc", out_type="NETCDF", 
  slice="j100"
/
&Process in_field ="P" /
&Process in_field ="T" /
&Process in_field ="QV" /

&Process out_field="T", offset=-273.15 /
&Process out_field="RELHUM" /
&Process out_field="HFL" /
 


! Slice expressed in (lat,lon) space west-east
!---------------------------------------------
&Process
  in_type="INCORE"
  in_regrid_target="GRID", in_regrid_method="average,square,0.9"
  out_file="./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc", out_type="NETCDF", out_type_largenc=.true.
  slice="Lyon-Memmingen"
/
&Process in_field="HSURF" /
&Process in_field="HHL", levmin=1, levmax=81 /
&Process in_field="HFL", levmin=1, levmax=80 /

&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff<DDHH>0000"
  tstart=0 , tstop=0 , tincr=1, 
  in_regrid_target="GRID", in_regrid_method="average,square,0.9",
  out_file="./results/slice3_upscaling_factor_10/Lyon-Memmingen.nc", out_type="NETCDF", out_type_largenc=.true.
  slice="Lyon-Memmingen"
/
&Process in_field = "P",   levmin = 1, levmax = 80 /
&Process in_field = "T",   levmin = 1, levmax = 80 /
&Process in_field = "QV",  levmin = 1, levmax = 80 /
&Process in_field = "U",   regrid=.t., poper="n2geog", levmin = 1, levmax = 80 /
&Process in_field = "V",   regrid=.t., poper="n2geog", levmin = 1, levmax = 80 /
&Process in_field = "W",   levmin = 1, levmax = 81 /
&Process in_field = "TKE", levmin = 1, levmax = 81 /
&Process out_field = "T" /
&Process out_field = "W" /
&Process out_field = "TKE" /
&Process out_field = "DD" /
&Process out_field = "FF" /
&Process out_field = "RH_ICE"/
&Process out_field = "THETA"/
&Process out_field="HFL" /
&Process out_field="HHL" /


! Slice expressed in (lat,lon) space South-North
!-----------------------------------------------
&Process
  in_type="INCORE"
  in_regrid_target="GRID", in_regrid_method="average,square,0.9"
  out_file="./results/slice3_upscaling_factor_10/sn.nc", out_type="NETCDF", out_type_largenc=.true.
  slice="Malpensa-Stutt"
/
&Process in_field="HSURF" /
&Process in_field="HHL", levmin=1, levmax=81 /
&Process in_field="HFL", levmin=1, levmax=80 /

&Process
  in_file="/scratch/morsier/wd/17060503_102/lm_coarse/lfff<DDHH>0000"
  tstart=0 , tstop=0 , tincr=1, 
  in_regrid_target="GRID", in_regrid_method="average,square,0.9",
  out_file="./results/slice3_upscaling_factor_10/sn.nc", out_type="NETCDF", out_type_largenc=.true.
  slice="Malpensa-Stutt"
/
&Process in_field = "P",   levmin = 1, levmax = 80 /
&Process in_field = "T",   levmin = 1, levmax = 80 /
&Process in_field = "QV",  levmin = 1, levmax = 80 /
&Process in_field = "U",   regrid=.t., poper="n2geog", levmin = 1, levmax = 80 /
&Process in_field = "V",   regrid=.t., poper="n2geog", levmin = 1, levmax = 80 /
&Process in_field = "W",   levmin = 1, levmax = 81 /
&Process in_field = "TKE", levmin = 1, levmax = 81 /
&Process out_field = "T" /
&Process out_field = "W" /
&Process out_field = "TKE" /
&Process out_field = "DD" /
&Process out_field = "FF" /
&Process out_field = "RH_ICE"/
&Process out_field = "THETA"/
&Process out_field="HFL" /
&Process out_field="HHL" /

