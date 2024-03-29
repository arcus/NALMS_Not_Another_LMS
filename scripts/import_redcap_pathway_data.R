# This script pulls down learner information from Pipeline
# and builds an import file for NALMS that includes the Pipeline fields
# as well as the first "instance" for each learner's pathway survey.
# It fills in 0 (not started) for each of their assigned modules (leaving fields on all other pathways blank)
# and puts in "complete" status for their pathway survey. 
# Then the script imports the data to NALMS, so a new wave is ready to begin.

# This script should be run AFTER all of the pathways are created in NALMS 
# and pathway assignments are entered in Pipeline.

# API tokens stored in .Renviron https://cran.r-project.org/web/packages/httr/vignettes/secrets.html#environment-variables

source(here::here("scripts", "functions.R")) # get custom functions for this project

# get the record_id, name, email, and assigned pathway from Pipeline
url <- "https://redcap.chop.edu/api/"
formData <- list("token"=Sys.getenv("Pipeline_56668"),
                 content='record',
                 action='export',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 'fields[0]'='record_id',
                 'fields[1]'='first_name',
                 'fields[2]'='last_name',
                 'fields[3]'='email',
                 'fields[4]'='enrolled',
                 'fields[5]'='opted_out',
                 'fields[6]'='dropped_out',
                 'fields[7]'='wave',
                 'fields[8]'='pathway_wave2',
                 'fields[9]'='oss_module_data_sharing_fundamentals_complete',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='false',
                 exportDataAccessGroups='false',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
pipeline <- httr::content(response, show_col_types = FALSE) 

# Make pretest_complete info available in all events, not just pre_arm_1
pretest_completers <- pipeline |>
  dplyr::select(record_id, pretest_complete = oss_module_data_sharing_fundamentals_complete) |> 
  dplyr::filter(pretest_complete == 2) |> 
  unique()
pipeline <- pipeline |> 
  dplyr::select(-oss_module_data_sharing_fundamentals_complete) |> 
  dplyr::left_join(pretest_completers, by = "record_id")


# -------------------------------------------------------
# NOTE: FOR TESTING PURPOSES
#
# # OVERWRITE THE REAL EMAILS!
# pipeline$email <- "hartmanr1@chop.edu"
# # ADD FAKE PATHWAYS
# pipeline$pathway <- 10
# # LIMIT NUMBER OF PARTICIPANTS
# pipeline <- dplyr::filter(pipeline, record_id < 10)
# -------------------------------------------------------

pipeline_this_wave <- pipeline |> 
  dplyr::filter(wave == 2 & !is.na(pathway_wave2)) |> 
  # convert raw (numeric) pathways from pipeline into their labels
  convert_raw_to_label(col="pathway_wave2") |> 
  # rename pathway_wave2 as just pathway
  dplyr::rename(pathway=pathway_wave2)

# the complete list of pathways in Pipeline for this wave
pathways <- unique(pipeline_this_wave$pathway)

# get the field names for the whole NALMS project from redcap API
formData <- list("token"=Sys.getenv("NALMS_Wave2_61127"),
                 content='exportFieldNames',
                 format='csv',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
nalms_data <- httr::content(response, show_col_types = FALSE)
redcap_fields <- nalms_data$export_field_name

# it doesn't add fields for repeating instances, sigh
redcap_fields <- c("record_id", "redcap_repeat_instrument", "redcap_repeat_instance", redcap_fields[-1])

# import records for all of the participants assigned to pathways
# create a blank redcap template matrix with all NAs
redcap_matrix <- matrix(nrow = nrow(pipeline_this_wave), 
                        ncol = length(redcap_fields))
colnames(redcap_matrix) <- redcap_fields

# create an input dataframe from the blank redcap template matrix
basic_info <- as.data.frame(redcap_matrix) |> 
  # pull in data for Basic Info form
  dplyr::mutate(record_id = pipeline_this_wave$record_id,
                first_name = pipeline_this_wave$first_name,
                last_name = pipeline_this_wave$last_name,
                email = pipeline_this_wave$email,
                enrolled = pipeline_this_wave$enrolled,
                opted_out = pipeline_this_wave$opted_out,
                dropped_out = pipeline_this_wave$dropped_out,
                wave = pipeline_this_wave$wave,
                pathway = pipeline_this_wave$pathway,
                pretest_complete = pipeline_this_wave$pretest_complete,
                basic_info_complete = 2)


# the name of each pathway form should be the pathway color and "_pathway", e.g. "red_pathway"
pathway_form_names <- data.frame(pathway = pathways) |> 
  dplyr::mutate(redcap_repeat_instrument = paste0(pathway, "_pathway"))
# add form name to pipeline data frame so we can pull it in 
pipeline_this_wave <- dplyr::left_join(pipeline_this_wave, pathway_form_names, by = "pathway")

# put in first instance of pathway form
pathway_forms <- as.data.frame(redcap_matrix) |> 
  dplyr::mutate(record_id = pipeline_this_wave$record_id,
                redcap_repeat_instrument = pipeline_this_wave$redcap_repeat_instrument,
                redcap_repeat_instance = 1,
                pathway = pipeline_this_wave$pathway) |>  # pathway here is temporary
  # put in 2 (complete) for the "color_pathway_complete" field that matches participant's pathway
  # put in 0 (not started) for all modules that match the participant's pathway
  dplyr::mutate(
    dplyr::across(
      dplyr::starts_with(paste0(pathways, "_")),
      ~ ifelse(
        test = stringr::str_detect(dplyr::cur_column(), paste0("^", pathway, "_pathway_complete")),
        yes = 2,
          ifelse(
            test = stringr::str_detect(dplyr::cur_column(), paste0("^", pathway, "_")),
            yes = 0, 
            no = NA)
        ))) |> 
  dplyr::select(all_of(redcap_fields)) |> # make sure all of the columns are in the right order
  dplyr::mutate(pathway = NA) # get rid of temporary pathway values

# rbind basic_info form and pathway forms together, then sort on record_id
redcap_import <- rbind(basic_info, pathway_forms) |> 
  dplyr::arrange(record_id)

# use API to import the new data
formData <- list("token"=Sys.getenv("NALMS_Wave2_61127"),
                 content='record',
                 action='import',
                 format='csv',
                 type='flat',
                 overwriteBehavior='normal',
                 forceAutoNumber='false',
                 data=dataframe_as_string(redcap_import),
                 returnContent='count',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
result <- httr::content(response, show_col_types = FALSE)

if(nrow(result) > 0){
  message("Upload complete!")
} else {
  message("\nUpload failed!\n")
  message(result$error)
}
