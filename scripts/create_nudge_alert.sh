### This script creates the "nudge" email text to send participants who have been inactive for at least two weeks
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

alert_location=pathways/$pathway/nudge_alert.md
alert_csv=pathways/$pathway/alerts.csv 

### Note that the [pathway] is a field in REDCap, not the directory in this repo
### although they should match because one of the conditions of sending the email
### will have to be [pathway]="$pathway"

## body of the email:

echo "<p>Hi!</p>
<p>We noticed that it has been a while since you logged any progress in your DART Program learning pathway:</p>
<p>[survey-link:"$pathway"_pathway][new-instance]</p>
<p>This link will take you to a page with the full list of education modules curated for you by our team. Indicate which ones you've been working on, and click "Submit" at the bottom of the form to log your progress. You can update your progress as many times as you want, either by following the link in this email, or by pasting the following url into your browser:</p>
<p>[survey-url:"$pathway"_pathway][new-instance] This link is unique to you and should not be forwarded to others.</p>
<p>Log in today to try out the next module in your learning pathway!</p>
<p>We look forward to seeing you on the platform, and please don't hesitate to email us if you have any technical (or other) questions.</p>
<p>Sincerely,</p>
<p>The DART Team at Children's Hospital of Philadelphia</p>
<p>P.S. If you have decided that participating in the DART program isn't for you after all, reply to this email to let us know and we will unenroll you from the study.</p>" > $alert_location 

### The text from alert_location will then be piped into a csv with all of the survey settings.
### NOTE: This script adds a line to the existing alerts.csv file, and therefore must be run AFTER create_completed_alert.sh

echo ',Inactive nudge '$pathway' pathway,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [complete] <> ""2""",Y,RECORD,DATE,,,,,,,,8/21/2023  9:00,SCHEDULE,,14,DAYS,,12/1/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv


