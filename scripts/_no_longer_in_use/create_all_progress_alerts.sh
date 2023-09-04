## This script will make a single csv containing all of the progress alerts so that they can be uploaded once as a batch.

csv_file=progress_alerts.csv

## make sure the csv has all of the fields that REDCap expects for an alert upload:

head -1 templates/progress_alert_template.csv > $csv_file

for flower in pathways/*
do
    pathway=$(basename $flower)
    ## Create the individual alert for that pathway
    bash scripts/create_progress_alert.sh $pathway
    ## add that alert line to the main file
    head -2 pathways/$pathway/progress_alert_$pathway.csv | tail -1 >> $csv_file
    ## delete the individual pathway csv and md files to clean up clutter
    rm pathways/$pathway/progress_alert_$pathway.csv
    rm pathways/$pathway/progress_alert.md
done