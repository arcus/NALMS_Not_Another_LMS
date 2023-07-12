# NALMS dress rehearsal (aka user acceptance testing)


## Cooking show style

Hello and welcome to administering NALMS. 
We've already got the needs assessment data and we designed some lovely pathways. 

Rosie do beforehand: Assign participants (us) to pathways. Note that this will use the clustering results, so it's just a question of joining a little pathways table to the participant data. Upload this to Pipeline.

1. Save the pathways as md files in the NALMS repo, run scripts to generate the REDCap files, and upload them to REDCap. See [creating a pathway](https://github.com/arcus/NALMS_Not_Another_LMS/blob/main/README.md#creating-a-pathway). 
2. Pull participant (us) info from Pipeline and upload to NALMS project in REDCap. 
3. NALMS is live! We should each have emails. Click them, record updates. For testing, set emails to send every 2 min, so we can see updates. 
4. Try finishing your modules. You should get a congrats email. 

To prep: 

- Upload testing participants to Pipeline. One for each of our email addresses, each "assigned" to a different pathway.
- Check that list of participants who will be imported to NALMS is only us (no one else in wave 2 yet). Remove code to mask email addresses. 
- Have md files ready for all but one pathway? Or have everyone do their own pathway. 
- Make sure notifications are set to go out on date/time that will fall during our meeting (can adjust this during meeting if needed).
- Make sure ASI reminder is set to every 2 min. 

After meeting:

- Remove our test records from Pipeline. 
- Delete all test pathways and data from NALMS. 
- Set initial NALMS notification to go out on... Aug 8? Note that we can't coordinate NALMS ASI with Pipeline info so it's not possible e.g. require that pretest be completed before the NALMS ASI goes out. 
- Set ASI reminder to every 1 week. 

## Notes

- We each clone the NALMS repo, and we have a pathway assigned to us. I have prepped the data in Pipeline and removed the code to mask emails from the import script. 
- Each of us writes the md files for our pathway then runs the NALMS scripts and uploads the files to REDCap. 
- I run the data import script to pull our info from Pipeline and upload to NALMS. 
