### This script creates the pathway progress alert
### This is because the ASIs are not working well and we need these to go out as alerts instead.
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1
pathwayunderscore=$pathway"_pathway"
progress_alert_location=pathways/$pathway/progress_alert.md


echo "<p>Here is your progress so far on the $pathway pathway as of the time this email was sent:</p>" > $progress_alert_location 

### Start table of modules:

echo "<table>" >> $progress_alert_location
echo "<tbody>" >> $progress_alert_location

### Build the contents of the table from the pathway's sections:

for SECTION in pathways/$pathway/sections/*
do

    ### Create section headers

    section_name=$(head -1 $SECTION)
    echo "<tr>
    <td><strong>$section_name</strong></td>
    <td></td>
    <td></td>
    </tr>" >> $progress_alert_location

### Include links to each modules within the section


tail +2 $SECTION | while read line 
do
field_name=$pathway"_"$line
module_title=$(grep $line module_title.txt | sed "s/^[^ ]* //")
field_text="<a href=https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/$line/$line.md target=_blank>$module_title</a>"
module_time=$(grep $line module_time.txt | sed "s/^[^ ]* //")

### I can't make the grammar work to get the right latest instance of the field working in an alert. Sometimes it shows up blank, other times it shows up incorrectly, or merges with other links in weird ways.
current_status="["$field_name"][last-instance]" #tried [$field_name][last-instance] and many other combinations with the $pathwayunderscore variable...
echo "<tr>
<td>$field_text</td>
<td>$module_time</td>
<td>$current_status
</td>
</tr>" >> $progress_alert_location
done


done



### End table of modules:
echo "</tbody>" >> $progress_alert_location
echo "</table>" >> $progress_alert_location

### Concluding paragraph about updating progress:
echo "<p></p>
<p>As you continue trying out modules, you can check and update your progress in this form:<br />[survey-link:$pathwayunderscore:Progress on the $pathway pathway][new-instance]</p>
<p>You can update this as many times as you want, either by following the link in this email, or by pasting the following url into your browser:<br />[survey-url:$pathwayunderscore][new-instance]</p>
<p>This link is unique to you and should not be forwarded to others.</p>
<p>Need to update your name or email? Use this link to <a href=https://redcap.chop.edu/surveys/?s=C8DL97HYP3PDFDWP&dart_id=[record-name]>update your contact information with us</a>.</p>" >> $progress_alert_location


### Now the text of the email needs to be wrapped in an automated survey invititation csv so that it can be uploaded with all of the appropriate settings:

alert_file=pathways/$pathway/progress_alert_$pathway.csv

head -1 templates/alerts.csv > $alert_file

### Some of the settings we want to be able to change relatively easily:
num_recurrence=7
units_recurrence=DAYS
max_recurrence=14
send_date="8/21/2023  08:05"
alert_title=$pathway" pathway progress - weeks 3-16"

echo ,$alert_title,LOGIC,,ANY,[pathway]=\'$pathway\' and [stop_emails]"<>"\'1\' and [pretest_complete]=\'2\' and [wave]=\'2\' and [$pathway"_complete"][current-instance]"<>"\'2\',Y,RECORD,DATE,,,,,,,,$send_date,SCHEDULE,,7,DAYS,$max_recurrence,,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Your progress on the $pathway pathway,\"$(cat $progress_alert_location)\",,{},{},N,,,N >> $alert_file
