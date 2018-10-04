# plotpdf.sh
# This scripts call the plotpdf.ncl and run it.
# This scripts gives the input varibles for plotpdf.ncl script.
# Input variables are: variable to plot, time, case, settings, zoom area, topography background on/off, borders on/off, water on/off, and if should be a footprint or not
# Variables definition for call:
# v - var, t - time, c - cas, s - sett, z - zoom, g - topography, b - borders, w - water, f - foot.

# First of all give all the input varibales empty strings

# Read in specific variables 
while getopts v:t:c:s:z:g:b:w:f: option
do
case "${option}"
in
v) var=${OPTARG};;
t) time=${OPTARG};;
c) cas=${OPTARG};;
s) sett=$OPTARG;;
z) zoom=${OPTARG};;
g) back=${OPTARG};;
b) bord=${OPTARG};;
w) wat=${OPTARG};;
f) foot=${OPTARG}

esac
done
# Print what will be done
echo "Use plotpdf.ncl for predefined arguments: Variables: "$var" Time: " $time " Case: " $cas " Settings: " $sett " Area: " $zoom " Topography: " $back " Borders: " $bord " Water: " $wat " Footprint: " $foot

# Call of plotpdf.ncl script
  ncl plotpdf.ncl 'var="'${var}'"' 'time="'${time}'"' 'cas="'${cas}'"'  'sett="'${sett}'"' 'zoom="'${zoom}'"' 'back="'${back}'"' 'bord="'${bord}'"' 'wat="'${wat}'"' 'foot="'${foot}'"'



