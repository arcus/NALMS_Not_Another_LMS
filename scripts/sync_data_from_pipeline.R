# This script pulls down the fields for NALMS Basic Info form from the DART Pipeline data
# then creates a blank import template for NALMS and fills in the Pipeline data for the relevant fields. 
# Then it imports the overwritten NALMS data back to the NALMS REDCap project

# API tokens stored in .Renviron https://cran.r-project.org/web/packages/httr/vignettes/secrets.html#environment-variables

source(here::here("scripts", "functions.R")) # get custom functions for this project

# get the Basic Info data from Pipeline
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
                 'fields[8]'='pathway',
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
  # put in pretest_complete
  dplyr::select(-oss_module_data_sharing_fundamentals_complete) |> 
  dplyr::left_join(pretest_completers, by = "record_id") |>
  # remove rows that aren't from the screener event
  dplyr::filter(redcap_event_name == "screening_arm_1") |> 
  # only keep fields that are synced with NALMS
  dplyr::select(record_id, first_name, last_name, email, enrolled, opted_out, dropped_out, wave, pathway, pretest_complete)

# -------------------------------------------------------
# NOTE: FOR TESTING PURPOSES
#
# OVERWRITE THE REAL EMAILS!
pipeline$email <- "rosemhartman@gmail.com"
# ADD FAKE PATHWAYS
pipeline$pathway <- 10
# LIMIT NUMBER OF PARTICIPANTS
pipeline <- dplyr::filter(pipeline, record_id < 10)
# -------------------------------------------------------

pipeline <- pipeline |> 
  # convert raw (numeric) pathways from Pipeline into their labels
  convert_raw_to_label(col="pathway")

# get data from the Basic Info form in NALMS
# (note we need this so we have the correct list of record_ids, since pipeline has more records than nalms)
formData <- list("token"=Sys.getenv("NALMS_Wave2_60956"),
    content='record',
    action='export',
    format='csv',
    type='flat',
    csvDelimiter='',
    'forms[0]'='basic_info',
    rawOrLabel='raw',
    rawOrLabelHeaders='raw',
    exportCheckboxLabel='false',
    exportSurveyFields='false',
    exportDataAccessGroups='false',
    returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
nalms_basic_info <- httr::content(response, show_col_types = FALSE)

nalms_basic_info_synced <- nalms_basic_info |>
    # only keep record_id from NALMS
    dplyr::select(record_id) |>
    # pull the rest of the data from Pipeline
    dplyr::left_join(pipeline, by = "record_id")

# get the field names for the whole NALMS project from redcap API
formData <- list("token"=Sys.getenv("NALMS_Wave2_60956"),
                 content='exportFieldNames',
                 format='csv',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
nalms_field_names <- httr::content(response, show_col_types = FALSE)
redcap_fields <- nalms_field_names$export_field_name

# it doesn't add fields for repeating instances, sigh
redcap_fields <- c("record_id", "redcap_repeat_instrument", "redcap_repeat_instance", redcap_fields[-1])

# create a blank redcap template matrix with all NAs
redcap_matrix <- matrix(nrow = nrow(nalms_basic_info), 
                        ncol = length(redcap_fields))
colnames(redcap_matrix) <- redcap_fields

# create an input dataframe from the blank redcap template matrix
redcap_import <- as.data.frame(redcap_matrix) |> 
  # pull in synced data
  dplyr::mutate(record_id = nalms_basic_info_synced$record_id,
                first_name = nalms_basic_info_synced$first_name,
                last_name = nalms_basic_info_synced$last_name,
                email = nalms_basic_info_synced$email,
                enrolled = nalms_basic_info_synced$enrolled,
                opted_out = nalms_basic_info_synced$opted_out,
                dropped_out = nalms_basic_info_synced$dropped_out,
                wave = nalms_basic_info_synced$wave,
                pathway = nalms_basic_info_synced$pathway,
                pretest_complete = nalms_basic_info_synced$pretest_complete) |> 
  # make sure it's sorted by record_id              
  dplyr::arrange(record_id)


# use API to import the new data
formData <- list("token"=Sys.getenv("NALMS_Wave2_60956"),
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
print(result) # If successful, this will be the number of rows. Otherwise, an error message.
