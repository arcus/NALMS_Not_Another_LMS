### This script creates the Automated Survey Invitation (ASI) text.
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

asi_location=pathways/$pathway/asi.md

### Note that the [pathway-color] is a field in REDCap, not the directory in this repo
### although they should match because one of the conditions of sending the email
### will have to be [pathway-color]="$pathway"

echo "<p>Here is your progress so far on the [pathway_color] pathway as of the time this email was sent:</p>" > $asi_location 

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
    </tr>" >> $asi_location

### Include links to each modules within the section

tail +2 $SECTION | while read line 
do
field_name=$line"_"$pathway
module_name=$(grep $line module_list.txt | sed "s/^[^ ]* //")
field_text="<a href=https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/$line/$line.md target=_blank>$module_name</a>"

echo "<tr>
<td>$field_text</td>
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
<p>As you continue trying out modules, you can check and update your progress in this form:<br />[survey-link:Progress on the $pathway pathway][new-instance]</p>
<p>You can update this as many times as you want, either by following the link in this email, or by pasting the following url into your browser:<br />[survey-url][new-instance]</p>
<p>This link is unique to you and should not be forwarded to others.</p>" >> $asi_location