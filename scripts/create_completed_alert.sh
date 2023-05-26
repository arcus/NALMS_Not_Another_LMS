### This script creates the Congratulations on completing your pathway email text
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

alert_location=pathways/$pathway/completed_alert.md

### Note that the [pathway] is a field in REDCap, not the directory in this repo
### although they should match because one of the conditions of sending the email
### will have to be [pathway]="$pathway"

## Congratulatory body of the email:

echo "<p>Congratulations! You just indicated that you have completed all of the modules in the [pathway] pathway!</p>
<p></p>
<p>While we won't be sending you regular emails about your progress, you will always have access to the modules in your pathway, which is displayed at the end of this email for your future reference. You are also welcome to check out the <a href= >complete collection of modules in the DART program</a>.</p>
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

