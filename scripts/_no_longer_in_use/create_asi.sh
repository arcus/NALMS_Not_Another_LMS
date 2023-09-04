### This script creates the Automated Survey Invitation (ASI) text.
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

pathwayunderscore=$pathway"_pathway"

asi_location=pathways/$pathway/asi.md

### Note that the [pathway-color] is a field in REDCap, not the directory in this repo
### although they should match because one of the conditions of sending the email
### will have to be [pathway-color]="$pathway"

echo "<p>Here is your progress so far on the [pathway] pathway as of the time this email was sent:</p>" > $asi_location 

### Start table of modules:

echo "<table>" >> $asi_location
echo "<tbody>" >> $asi_location

### Build the contents of the table from the pathway's sections:

for SECTION in pathways/$pathway/sections/*
do

    ### Create section headers

    section_name=$(head -1 $SECTION)
    echo "<tr>
    <td><strong>$section_name</strong></td>
    <td></td>
    <td></td>
    </tr>" >> $asi_location

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
<td>[$field_name:label][last-instance]
</td>
</tr>" >> $asi_location
done


done



### End table of modules:
echo "</tbody>" >> $asi_location
echo "</table>" >> $asi_location

### Concluding paragraph about updating progress:
echo "<p></p>
<p>As you continue trying out modules, you can check and update your progress in this form:<br />[survey-link:$pathwayunderscore:Progress on the $pathway pathway][new-instance]</p>
<p>You can update this as many times as you want, either by following the link in this email, or by pasting the following url into your browser:<br />[survey-url:$pathwayunderscore][new-instance]</p>
<p>This link is unique to you and should not be forwarded to others.</p>
<p>Need to update your name or email? Use this link to <a href=https://redcap.chop.edu/surveys/?s=C8DL97HYP3PDFDWP&dart_id=[record-name]>update your contact information with us</a>.</p>" >> $asi_location


### Now the text of the email needs to be wrapped in an automated survey invititation csv so that it can be uploaded with all of the appropriate settings:

asi_file=pathways/$pathway/asi_$pathway.csv

head -1 templates/asi.csv > $asi_file

### Some of the settings we want to be able to change relatively easily:
num_recurrence=7
units_recurrence=DAYS
max_recurrence=16
send_date="8/14/2023  08:05:00 AM"

echo $pathway"_pathway",basic_info,$num_recurrence,$units_recurrence,$max_recurrence,1,"Your Progress on the "$pathway" pathway",\"$(cat $asi_location)\",dart@chop.edu,,AND,"[pathway]=\"$pathway\" and ["$pathway"_complete][last-instance]<>\"2\" and [wave] = \"2\" and [stop_emails]=\"0\" and [pretest_complete]=\"2\"",EXACT_TIME,,,,,after,,,$send_date,EMAIL,,,,,,,,0,1 >> $asi_file
