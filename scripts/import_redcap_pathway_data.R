source(here::here("secrets", "secrets.R")) # get the API tokens

dataframe_as_string <- function(df){
  paste(utils::capture.output(data.table::fwrite(df)), collapse = "\n")
}

# get the record_id, name, email, and assigned pathway from Pipeline
url <- "https://redcap.chop.edu/api/"
formData <- list("token"=token_Pipeline,
                 content='record',
                 action='export',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 'fields[0]'='record_id',
                 'fields[1]'='first_name',
                 'fields[2]'='last_name',
                 'fields[3]'='email',
                 'fields[4]'='pathway',
                 'fields[5]'='wave',
                 'fields[6]'='opted_out',
                 'fields[7]'='dropped_out',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='false',
                 exportDataAccessGroups='false',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
pipeline <- httr::content(response)

pipeline_this_wave <- dplyr::filter(pipeline, wave == 1 & !is.na(pathway))

# NOTE: FOR TESTING PURPOSES, OVERWRITE THE REAL EMAILS!
pipeline_this_wave$email <- "xxx@example.com"
# NOTE: FOR TESTING, OVERWRITE REAL PATHWAYS WITH TEST ONES
pipeline_this_wave$pathway <- ifelse(pipeline_this_wave$pathway < 3, "aqua", 
                                     ifelse(pipeline_this_wave$pathway < 6, "sepia", "magenta"))

# the complete list of pathways in Pipeline for this wave
pathways <- unique(pipeline_this_wave$pathway)

# get the field names for the whole NALMS project from redcap API
formData <- list("token"=token_NALMS_testing,
                 content='exportFieldNames',
                 format='csv',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
nalms_data <- httr::content(response)
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
  # pull in record_id, pathway, name, email, dropped_out, and opted_out
  dplyr::mutate(record_id = pipeline_this_wave$record_id,
                pathway = pipeline_this_wave$pathway,
                first_name = pipeline_this_wave$first_name,
                last_name = pipeline_this_wave$last_name,
                email = pipeline_this_wave$email,
                opted_out = pipeline_this_wave$opted_out,
                dropped_out = pipeline_this_wave$dropped_out,
                basic_info_complete = 2)


# the name of each form should be the capitalized pathway color and "Pathway", e.g. "Red Pathway"
pathway_form_names <- data.frame(pathway = pathways) |> 
  dplyr::mutate(redcap_repeat_instrument = paste0(pathway, "_pathway"))
#  dplyr::mutate(redcap_repeat_instrument = paste(paste0(toupper(substring(pathway, 1, 1)), substring(pathway, 2)), "Pathway"))
# add form name to pipeline data frame so we can pull it in 
pipeline_this_wave <- dplyr::left_join(pipeline_this_wave, pathway_form_names, by = "pathway")

# put in first instance of pathway form
pathway_forms <- as.data.frame(redcap_matrix) |> 
  dplyr::mutate(record_id = pipeline_this_wave$record_id,
                redcap_repeat_instrument = pipeline_this_wave$redcap_repeat_instrument,
                redcap_repeat_instance = 1,
                pathway = pipeline_this_wave$pathway) |> # pathway here is temporary
  # for each pathway, put in "not done" (0) for each module in that pathway
  # pivot longer to pull the pathway name out of the module field name
  tidyr::pivot_longer(cols = dplyr::ends_with(pathways)) |> 
  tidyr::extract(col = name, into = c("module", "mod_path"), regex = "(.*)_([[:lower:]]+)") |> 
  # put in 0 (not started) for all modules that match the participant's pathway
  dplyr::mutate(value = ifelse(pathway == mod_path, 0, NA)) |> 
  # collapse the module and module path fields back together
  tidyr::unite(col = "name", module, mod_path, sep="_") |> 
  # pivot back wider to original formatting
  tidyr::pivot_wider(names_from = name, values_from = value) |> 
  dplyr::select(all_of(redcap_fields)) |> # make sure all of the columns are in the right order
  dplyr::mutate(pathway = NA) # get rid of temporary pathway values

# [form]_complete = 2

# rbind basic_info form and pathway forms together, then sort on record_id
redcap_import <- rbind(basic_info, pathway_forms) |> 
  dplyr::arrange(record_id)

# use API to import the new data
formData <- list("token"=token_NALMS_testing,
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
result <- httr::content(response)
print(result) 
