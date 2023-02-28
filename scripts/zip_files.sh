### Create the zip file to upload to REDCap

### This script takes a single arguement, the pathway color

pathway="$1"

### Run create_instrument.sh for the given pathway

bash scripts/create_instrument.sh $pathway

zip -j $pathway.zip pathways/$pathway/instrument.csv templates/OriginID.txt templates/survey_settings.csv 

