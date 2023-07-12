# NALMS dress rehearsal (aka user acceptance testing)


## What is the point of this?

The goal is to run through each step of the NALMS system as though real participants were using it, so we're confident we can implement it smoothly when Wave 2 launches. 

## Prep work for Rosie before the dress rehearsal

- Download Pipeline data and create three new records for the dress rehearsal participants (us).
- Assign participants (us) to pathways, and enroll in wave 2. 
- Upload this back to Pipeline. Verify we're the only participants enrolled in wave 2.
- In `import_redcap_pathway_data.R`, remove code to mask email addresses. 
- Write out three pathways and have each ready to share during meeting. 
- Make sure pathway ASIs are set to go out on date/time that will fall during our meeting (this is a change in `create_asi.sh` -- can also adjust this during meeting if needed).
- Make sure ASI reminders for pathways are set to every 2 min (this is a change in `create_asi.sh`).

## Dress rehearsal instructions

Hello and welcome to administering NALMS! 
We have three participants enrolled in our study, Rose, Rose, and Joy. 
They've already gone through enrollment and filled out the needs assessment, and we designed some lovely pathways for them. 

0. If you haven't already, clone the NALMS repo. Make sure you have API tokens for both Pipeline and NALMS, and save them as environment variables. See [setup for admin tasks](https://github.com/arcus/NALMS_Not_Another_LMS/blob/main/README.md#setup-for-admin-tasks).
1. Save the pathways as md files in the NALMS repo, run scripts to generate the REDCap files, and upload them to REDCap. See [creating a pathway](https://github.com/arcus/NALMS_Not_Another_LMS/blob/main/README.md#creating-a-pathway). 
2. Pull participant (us) info from Pipeline and upload to NALMS project in REDCap. 

Now we put on our participant hats! 

3. NALMS is live! We should each have emails. Click them, record progress on your modules. 
4. Try finishing your modules. You should get a congrats email. 


## After meeting:

- Remove our test records from Pipeline. 
- Delete all test pathways and data from NALMS. 
- Set initial NALMS ASI to go out on... Aug 8? Note that we can't coordinate NALMS ASI with Pipeline info so it's not possible e.g. require that pretest be completed before the NALMS ASI goes out. 
- Set ASI reminder to every 1 week. 

# Our pretend pathways!

## pansy

### Welcome

reproducibility

### Learn Python

demystifying_python
python_basics_writing_python_code
tidy_data
pandas_transform

### Command line and Git

git_setup_windows
git_setup_mac_and_linux
bash_command_line_101
git_creation_and_tracking
git_history_of_project
bash_command_line_102
bash_103_combining_commands
bash_conditionals_loops
bash_scripts

## Data visualization

data_visualization_in_open_source_software
data_visualization_in_ggplot2
data_visualization_in_seaborn

### Hands-on Practice

python_practice
r_practice

### More to Explore

citizen_science
data_management_basics

## sunflower

### Welcome

reproducibility
learning_to_learn

### Intro to Python

demystifying_python
python_basics_writing_python_code
how_to_troubleshoot

### Data Visualization in R and Python

r_basics_visualize_data
data_visualization_in_open_source_software
data_visualization_in_ggplot2
data_visualization_in_seaborn

### Hands-on Practice

python_practice
r_practice

### More to Explore

statistical_tests
git_intro
demystifying_geospatial_data
demystifying_sql
citizen_science

## violet

### Welcome

reproducibility

### Learn SQL

sql_basics
sql_intermediate
database_normalization
sql_joins

### Learn R

r_basics_transform_data
r_basics_visualize_data
r_reshape_long_wide
data_visualization_in_open_source_software
data_visualization_in_ggplot2
r_missing_values
r_practice

### More to Explore

citizen_science
data_management_basics


