### This script creates the "nudge" email text to send participants who have been inactive for at least two weeks
### It takes a single arguement, the pathway color, and returns
### html that can be inserted into the REDCap ASI for that pathway.

pathway=$1

alert_location=pathways/$pathway/nudge_alert.md
alert_csv=pathways/$pathway/alerts_$pathway.csv

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
### This creates a separate alert for each week of the program because REDCap won't add newly eligible participants (i.e. those who have recently become inactive) to reminders on a single alert
### When we update to a new wave, the send-on-date field here for each alert will have to be updated
### NOTE: This script adds additional lines to the existing alerts.csv file, and therefore must be run AFTER create_completed_alert.sh

echo ',Inactive nudge '$pathway' pathway Week 3,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,8/24/2023  9:00,ONCE,,,,,8/25/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 4,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,8/31/2023  9:00,ONCE,,,,,9/1/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 5,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,9/7/2023  9:00,ONCE,,,,,9/8/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 6,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,9/14/2023  9:00,ONCE,,,,,9/15/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 7,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,9/21/2023  9:00,ONCE,,,,,9/22/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 8,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,9/28/2023  9:00,ONCE,,,,,9/29/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 9,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,10/5/2023  9:00,ONCE,,,,,10/6/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 10,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,10/12/2023  9:00,ONCE,,,,,10/13/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 11,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,10/19/2023  9:00,ONCE,,,,,10/20/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 12,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,10/26/2023  9:00,ONCE,,,,,10/27/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 13,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,11/2/2023  9:00,ONCE,,,,,11/3/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 14,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,11/9/2023  9:00,ONCE,,,,,11/10/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 15,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,11/16/2023  9:00,ONCE,,,,,11/17/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv
echo ',Inactive nudge '$pathway' pathway Week 16,LOGIC,,ANY,"[pathway] = ""'$pathway'"" and datediff([survey-date-completed:'$pathway'_pathway][last-instance], ""today"", ""d"", ""ymd"") > 14 AND [stop_emails] <> ""1"" AND [wave] = ""2"" AND [pretest_complete] = ""2"" AND ['$pathway'_complete] <> ""2""",Y,RECORD,DATE,,,,,,,,11/20/2023  9:00,ONCE,,,,,11/21/2023  9:00,EMAIL,,dart@chop.edu,[survey-participant-email],,,,Log back in and keep learning!,"'$(cat pathways/$pathway/nudge_alert.md)'",,{},{},Y,,,N' >>$alert_csv

