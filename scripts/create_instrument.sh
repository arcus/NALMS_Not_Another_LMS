#############################
# Create the isntrument csv for a given pathway
#############################

### which pathway are we creating the instrument csv for?

pathway=$1

radio_buttons=$(cat templates/radio_buttons.txt)

instrument_file=pathways/$pathway/instrument.csv

head -1 templates/instrument.csv > $instrument_file

for SECTION in pathways/$pathway/sections/*
do

section_name=$(head -1 $SECTION)


# Iterate through the lines (except the first one) in $SECTION

## Only the first module in a section should have a section title before it:

tail +2 $SECTION| head -1 | while read line 
do
field_name=$line"_"$pathway
#module_name= make the module name be the actual module name
link_title="<a href=https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/$line/$line.md target=_blank> $line </a>"
action_tag="@IF([current-instance]=1,@DEFAULT='0', @SETVALUE='[$field_name:value][last-instance]')."
   echo $field_name,$pathway,$section_name,radio,\"$link_title\",$radio_buttons,,,,,,,,RH,,,,\"$action_tag\" >> $instrument_file
done

## The rest of the modules do not get their own section title since they do not start a new section
tail +3 $SECTION | while read line 
do
field_name=$line"_"$pathway
#module_name= make the module name be the actual module name
link_title="<a href=https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/$line/$line.md target=_blank> $line </a>"
action_tag="@IF([current-instance]=1,@DEFAULT='0', @SETVALUE='[$field_name:value][last-instance]')."
   echo $field_name,$pathway,,radio,\"$link_title\",$radio_buttons,,,,,,,,RH,,,,\"$action_tag\" >> $instrument_file
done

done