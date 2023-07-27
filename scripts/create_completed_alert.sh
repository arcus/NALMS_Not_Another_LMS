### This script creates the Congratulations on completing your pathway email text
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

alert_location=pathways/$pathway/completed_alert.md
alert_csv=pathways/$pathway/alerts_$pathway.csv

### Note that the [pathway] is a field in REDCap, not the directory in this repo
### although they should match because one of the conditions of sending the email
### will have to be [pathway]="$pathway"

## Congratulatory body of the email:

echo "<p>Congratulations! You just indicated that you have completed all of the modules in the [pathway] pathway!</p>
<p></p>
<p>While we won't be sending you regular emails about your progress, you will always have access to the modules in your pathway, which is displayed at the end of this email for your future reference. You are also welcome to check out the <a href=https://arcus.github.io/education_modules/list_of_modules target=_blank>complete collection of modules in the DART program</a>.</p>
<p></p>
<p>Congratulations again on your acheivement!</p>
<p>The entire DART team</p>" > $alert_location 

### Start table of modules:

echo "<table>" >> $alert_location
echo "<tbody>" >> $alert_location

### Build the contents of the table from the pathway's sections:

for SECTION in pathways/$pathway/sections/*
do

    ### Create section headers

    section_name=$(head -1 $SECTION)
    echo "<tr>
    <td><strong>$section_name</strong></td>
    <td></td>
    </tr>" >> $alert_location

### Include links to each modules within the section

tail +2 $SECTION | while read line 
do
field_name=$pathway"_"$line
module_title=$(grep $line module_title.txt | sed "s/^[^ ]* //")
field_text="<a href=https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/$line/$line.md target=_blank>$module_title</a>"
module_time=$(grep $line module_time.txt | sed "s/^[^ ]* //")

echo "<tr>
<td>$field_text</td>
<td>$module_time</td>
</tr>" >> $alert_location
done


done

### End table of modules:
echo "</tbody>" >> $alert_location
echo "</table>" >> $alert_location

### The text from alert_location will then be piped into a csv with all of the survey settings.

head -1 templates/alerts.csv > $alert_csv

echo ',Completed '$pathway' pathway,SUBMIT-LOGIC,'$pathway'_pathway,COMPLETE,['$pathway'_complete][current-instance] ="2" AND [wave] ="2" AND [stop_emails] = "0" AND [pretest_complete] = "2",N,RECORD,NOW,,,,,,,,,ONCE,,,,,,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Congratulations on completing your pathway!,"'$(cat pathways/$pathway/completed_alert.md)'",,{},{},Y,,,N' >>$alert_csv


