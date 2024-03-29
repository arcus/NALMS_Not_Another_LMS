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

### We also need to create the csv to upload with all of the alerts: one with weekly progress updates, one they get when the pathway is marked as complete, and the others for if they're inactive for two weeks.

bash scripts/create_completed_alert.sh $pathway
bash scripts/create_nudge_alert.sh $pathway 
bash scripts/create_progress_alert.sh $pathway

### Lastly, let's delete some of the helper files we created in this process

rm pathways/$pathway/completed_alert.md  ## this contained the html text of the completed alert
rm pathways/$pathway/nudge_alert.md  ## this contained the html text of the nudge alert
rm pathways/$pathway/progress_alert.md  ## this contained the html text of the progress alert
rm pathways/$pathway/instrument.csv ## this is now inside the zipped file
rm pathways/$pathway/survey_settings.csv ## this is now inside the zipped file
rm pathways/$pathway/list_of_modules ## helper file 
