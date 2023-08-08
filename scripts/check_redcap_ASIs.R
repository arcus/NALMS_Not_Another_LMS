# This script uses the API to get both the record of survey invitations (ASIs) that have gone out 
# and also the current information on each record which should determine which ASIs should go out.
# It will print the record_id for any records that look like they should have had a ASI sent but it hasn't gone out yet.
#
# This script is only useful for the first round of ASIs, i.e. during the first week of the program.

# print the time so it's easier to look back in the console history and see when this was run
message(Sys.time()) 

pathways <- c("aster", "azalea", "begonia", "camellia", "crocus", "daffodil", "dahlia", "daisy", "geranium", "iris", "jasmine",
              "lavender", "lilac", "lily", "lotus", "magnolia", "marigold", "peony", "tulip")


invites <- vector(mode = "list", length = length(pathways))
names(invites) <- pathways

for(this_pathway in pathways){
  # for each pathway, get the sent ASIs 
  formData <- list("token"=Sys.getenv("NALMS_Wave2_61127"),
                   content='participantList',
                   format='csv',
                   instrument=paste0(this_pathway, '_pathway'),
                   event='',
                   returnFormat='json'
  )
  invites[[this_pathway]] <- httr::content(httr::POST("https://redcap.chop.edu/api/", body = formData, encode = "form"), show_col_types = FALSE) |> 
    dplyr::filter(repeat_instance == 1 & invitation_sent_status) |> 
    dplyr::mutate(pathway = this_pathway) |> 
    dplyr::select(record_id = record, pathway, invitation_sent_status)
}

# combine it all into a single data frame
invites <- dplyr::bind_rows(invites)


# get NALMS Basic Info data to check criteria for sending ASIs (pretest_complete, etc.)
formData <- list("token"=Sys.getenv("NALMS_Wave2_61127"),
                 content='record',
                 action='export',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 'fields[0]'='record_id',
                 'fields[1]'='stop_emails',
                 'fields[2]'='wave',
                 'fields[3]'='pathway',
                 'fields[4]'='pretest_complete',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='false',
                 exportDataAccessGroups='false',
                 returnFormat='json'
)
nalms <- httr::content(httr::POST("https://redcap.chop.edu/api/", body = formData, encode = "form"), show_col_types = FALSE) |> 
  dplyr::select(-c(redcap_repeat_instrument, redcap_repeat_instance)) |> 
  dplyr::left_join(invites, by=c("record_id", "pathway"))


missing_asis <- dplyr::filter(nalms, is.na(invitation_sent_status) & wave == 2 & stop_emails == 0 & pretest_complete == 2) 

if(nrow(missing_asis) > 0 ){
  
  message(paste0("The following records *should* have been sent ASIs but they haven't gone out yet:\n", paste0(missing_asis$record_id, collapse = "\n")))
  
} else {
  
  message("ASIs appear to be up to date!")
  
}

        