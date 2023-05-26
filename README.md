# NALMS (Not Another LMS)
NALMS is the REDCap project intended to deliver the DART learning pathways to learners.

The purpose of this repository is to create the files needed for that project, including:
- zip files of REDCap Forms
- ASI (Automated Survey Invitations)
- scripts for the REDCap API to automate tasks in REDCap whenever possible

Ultimately a user should be able to create a pathway using section headings and module names, and then generate all files needed to create that pathway on REDCap.

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

### Create the zip files to upload to REDCap

To create the files for the `test_color` pathway, run the bash script `bash scripts/zip_files.sh test_color`. This will create the zip file for the instrument that can be uploaded directly to REDCap.

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


## Processes we still need to document:
- Upload the .zip file to REDCap
- Upload automated survey invitations to REDCap with the correct settings (via an R script, the csv with all the settings will also need to be built.)
- Upload the "pathway completed" alert, which is stored in a .csv, to REDCap (possibly need to create an R script to do this via the API)


