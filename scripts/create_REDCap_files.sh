### Create the zip file to upload to REDCap

### This script takes a single arguement, the pathway color

pathway="$1"

### Run create_instrument.sh for the given pathway

bash scripts/create_instrument.sh $pathway

### Run create_survey_settings.sh for the given pathway

bash scripts/create_survey_settings.sh $pathway

### REDCap is very picky about the three files that need to be in the zipped file, 
### they must be correctly named and cannot be in any directories within the zipped file.
### The tag -j ensures that there are no directories in the zipped file.

zip -j pathways/$pathway/$pathway.zip pathways/$pathway/instrument.csv templates/OriginID.txt pathways/$pathway/survey_settings.csv 

### Depending on how things look in REDCap, we may want to replace the survey_settings.csv file with 
### individually generated survey_settings files for each pathway. This will allow us to have different text
### for each pathway, but for the moment they are all getting the same generic text.

### We also need to create three csv files to upload, one with the automated survey invitation, and the others with the alerts they get when the pathway is marked as complete or if they're inactive for two weeks.

bash scripts/create_asi.sh $pathway
bash scripts/create_completed_alert.sh $pathway
bash scripts/create_nudge_alert.sh $pathway 

### Lastly, let's delete some of the helper files we created in this process

rm pathways/$pathway/asi.md ## This was a helper file with the html text of the asi
rm pathways/$pathway/completed_alert.md  ## this contained the html text of the completed alert
rm pathways/$pathway/nudge_alert.md  ## this contained the html text of the nudge alert
rm pathways/$pathway/instrument.csv ## this is now inside the zipped file
rm pathways/$pathway/survey_settings.csv ## this is now inside the zipped file
rm pathways/$pathway/list_of_modules ## helper file 
