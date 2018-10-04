README for these scripts
There are several scripts, which were created during the HAILCAST Master Thesis
All the data files are in /project/d91/aelligr/ and there is again a README file for the orientation

Scripts:
- boxplots: 
   boxplots_bins.ncl makes boxplots out of post-processed(with hailpath files) outloopfiles, which were made from print outs from the runs
- plotter: 
   hailmax.ncl plots out of the post-processed outloopfiles a chart
   loop.season calls plotseason.ncl and makes a chart out of the season data
   plotcase.ncl plots a case out of case data
   plotpdf.sh call plotpdf.ncl and makes a beautiful Chart out of case data
- process_data: 
   conca_hailmax.sh post-processes outloopfiles and uses ij_local2global.pl
   footprint.sh calls footprint.ncl and makes daily footprints out of usual output data for DHAILMAX
   mk_daily_file.ncl makes daily file out of MESHS data from the whole season(There is the whole summer in one f
- Verification:
   verification.ncl prints out the verification based on a 2x2 contingency table. Modify for other threholds etc
   verificationrandom.sh calls verificationrandom.ncl and makes contingency tables from every day to every day. Therefore you get the values for the Climatic database to get a Heidke-Skill-Score

