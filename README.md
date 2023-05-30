# NALMS (Not Another LMS)
NALMS is the REDCap project intended to deliver the DART learning pathways to learners.

The purpose of this repository is to create the files needed for that project, including:
- zip files of REDCap Forms
- ASI (Automated Survey Invitations)
- scripts for the REDCap API to automate tasks in REDCap whenever possible

Ultimately a user should be able to create a pathway using section headings and module names, and then generate all files needed to create that pathway on REDCap.

## Setup for admin tasks

You'll need REDCap API tokens for the following projects:

- DART Pipeline (pid=56668)
- NALMS (pid=57556)

Your API tokens should be saved as environment variables. 
You can save your tokens as environment variables in R by [editing .Renviron](https://cran.r-project.org/web/packages/httr/vignettes/secrets.html#environment-variables) (for more detailed instructions, see our [REDCap API module](https://liascript.github.io/course/?https://raw.githubusercontent.com/arcus/education_modules/main/using_redcap_api/using_redcap_api.md#20)).
You'll only need to do this once.

**Be sure to save the NALMS token as `NALMS_57556` and the Pipeline token as `Pipeline_56668`.**

Note: To run the CLI commands here, make sure you're in the main NALMS directory. 

## Creating a pathway

The point of this repository is to make creating a new DART Pathway as easy as possible. But there are still a few steps involved.

### Organize the modules that will be in the pathway

Within the `pathways` directory recreate the following structure of nested folders with the name of the new pathway replacing `test_color`

```
./
└── pathways
    └── test_color
        └── sections
            ├── 1_First_Section.md
            ├── 2_Second_Section.md
            └── 3_Third_Section.md
```

The section files contain the name of the section on the first line, followed by the keys for the modules it contains:

```
Section Name For Display
reproducibility
citizen_science
using_redcap_api
```

### Create the files to upload to REDCap

To create the files for the `test_color` pathway, run the bash script `bash scripts/zip_files.sh test_color`. This will create the zip file for the instrument that can be uploaded directly to REDCap.

The zip file will be created in the folder for that pathway (e.g. `test_color`), called `test_color.zip` (with the pathway name you used instead of `test_color`).

Run `bash scripts/create_survey_settings.sh test_color` with whatever your pathway name is.

Run `bash scripts/create_completed_alert.sh test_color` with whatever your pathway name is.

This creates a number of files:
ELIZABETH!! CLEAN THIS UP!!

```
./
└── pathways
    └── test_color
        └── sections
            ├── 1_First_Section.md
            ├── 2_Second_Section.md
            └── 3_Third_Section.md
        └── asi.md                  (helper file with text of ASI, will not upload to REDCap)
        └── completed_alert.csv     (alert file to upload to REDCap)
        └── completed_alert.md      (helper file with text of the alert, will not upload to REDCap)
        └── instrument.csv          (gets compressed into the zip file, will not upload to REDCap)
        └── list_of_modules         (helper file with list of modules, will not upload to REDCap)
        └── survey_settings.csv     (ASI file to upload to REDCap)
        └── test_color.zip          (instrument zip to upload to REDCap)
```

### Upload instrument zip

In REDCap in the NALMS project (pid=57556), go to Designer, and click the "Upload and Instrument zip file" button.

![Data Collection Instruments menu showing buttons for adding new forms.](media/pathways_1.png)

Upload the zip file you just created.

### Make instrument repeating

Run `make_pathways_repeating.R`. You can do this from the command line with the following: 

`Rscript scripts/make_pathways_repeating.R`

### Upload automated survey invitation (ASI)

On the same Designer page in REDCap, click the "Auto invitations options" under "Survey Options"

![Survey Options menu.](media/pathways_2.png)

Select "upload automated survey invitations settings (csv)" and select "Choose and upload csv".
Upload the csv called "survey_settings.csv" in your pathway's directory.

### Upload "pathway completed" alert

In REDCap, go to Alerts & Notifications.
Click "Upload or download alerts", and then "Upload Alerts (CSV)".

![Alerts & Notifications menu.](media/pathways_3.png)

Select "completed_alert.csv" in your pathway's directory.

### Check that pathway is correctly set up in REDCap

ELIZABETH FILL THIS OUT :)

## Getting data from DART Pipeline

The following fields in NALMS come from DART Pipeline:

- record_id
- first_name
- last_name
- email
- enrolled
- opted_out
- dropped_out
- wave
- pathway

All of these fields are in the **Basic Info** form in NALMS, which is a form we fill out, not a participant-facing survey. 

**NOTE:** When a learner contacts us to update this information in any of these fields (preferred name, email, dropping out, etc.), it is our responsibility to update that in **both** REDCap projects: DART Pipeline (pid=56668) and NALMS (pid=57556). 

### Running data import scripts

There are two different R scripts for importing data into NALMS:

- `import_redcap_pathway_data.R`: To be run once, before the beginning of a new wave
- `sync_data_from_pipeline.R`: To be run periodically (weekly?) while a wave is underway

#### Initial import script

`import_redcap_pathway_data.R` sets up the data in NALMS at the beginning of a new wave. 

It pulls over learner info from Pipeline (fields in the Basic Info form, such as name and email), but it also sets up each learner's initial state for their pathway. 
For each learner, it puts in a status of 0 (not started) for every module in their assigned pathway survey and marks the survey as complete for the first instance. 
It leaves everything on the other surveys blank for that learner. 

All of the pathway surveys are set to allow repeating instances, and to display the last instance's responses as the default for each module status. 
So when a learner opens their pathway survey for the first time, it will show what REDCap thinks the previous instance is ("not started" for every module), which was actually entered by us. 
The first set of genuine learner responses will be recorded by REDCap as instance 2. 

#### Periodic syncing script

In addition to manually updating both NALMS and Pipeline with changes in learner information, we can periodically run the `sync_data_from_pipeline.R` import script to ensure the data in both places is staying synched. 

This script overwrites the fields that should be synced between Pipeline and NALMS with the current Pipeline data --- that means if you update Basic Info in NALMS and forget to add it to Pipeline as well, it will get erased! 
This script doesn't touch pathway survey responses, only the fields in the Basic Info form. 

**Note:** Eventually, it would be preferable to replace this syncing process with the [cross-project piping](https://github.com/vanderbilt-redcap/cross-project-piping-module) external module for REDCap, but it's not working in our tests with redcap_v13.4.12.

## Updating User Contact Info

Learners can update their contact info with us by filling out the [contact info update form](https://redcap.chop.edu/surveys/?s=C8DL97HYP3PDFDWP) (which is in its own RECap project, pid 59698). 
This triggers an email to hartmanr1@chop.edu with the updated fields. 

Then it is **our responsibility** to update both DART Pipeline and NALMS with the new info. 

## Changing admin settings for NALMS

ROSE FILL THIS OUT! :)

- Write brief instructions that point to where email cadence, program length, and other admin-level changes at this less-frequently used, admin level need to take place
- Write instructions such that any staff can, at the request of a learner, use their name and/or email address to find their record in NALMS and send that learner a link to their pathway
- Write instructions such that any staff can use a learner name and/or email address to find their record in NALMS and DART Pipeline and determine their participation status

