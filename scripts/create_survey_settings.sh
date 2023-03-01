#############################
# Create the survey_settings csv for a given pathway
# This script takes a single arguement, the pathway name, e.g. test_color
#############################

### which pathway are we creating the instrument csv for?

pathway=$1

sed s/Magenta/$pathway/g templates/survey_settings.csv > pathways/$pathway/survey_settings.csv


### make the pathway name uppercase?
#echo ${pathway:0:1} | tr '[a-z]' '[A-Z]'
#echo ${pathway:1:50}