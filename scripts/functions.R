# this function takes a dataframe and returns a string that is formatted like csv,
# for importing into redcap via the API
dataframe_as_string <- function(df){
  paste(utils::capture.output(data.table::fwrite(df)), collapse = "\n")
}

# this function takes the variable col in dataframe df 
# and retrieves its labels to convert from raw to label
convert_raw_to_label <- function(df, col, token=Sys.getenv("Pipeline_56668")){
  # get the raw and label values for col
  formData <- list("token"=token,
                   content='metadata',
                   format='csv',
                   returnFormat='json'
  )
  response <- httr::POST("https://redcap.chop.edu/api/", body = formData, encode = "form")
  metadata <- httr::content(response, show_col_types = FALSE) |> 
    dplyr::filter(field_name == col)
  
  choices <- metadata$select_choices_or_calculations
  stopifnot(length(choices) == 1)
    
  # create a dataframe with raw and label values for col
  values <- data.frame(value=strsplit(choices, split = " | ", fixed = TRUE)[[1]]) |> 
    tidyr::separate(value, into=c(col, "label"), convert = TRUE)
  
  # save the colnames of df, to preserve ordering 
  df_cols <- colnames(df)
  
  # join in the labels for col, and drop the original raw col 
  df <- df |> 
    dplyr::left_join(values, by=col) |> 
    dplyr::select(-tidyselect::all_of(col)) 
  
  # rename label as col
  colnames(df)[ncol(df)] <- col
  
  # return df, and ensure the columns are back in order
  return(dplyr::select(df, tidyselect::all_of(df_cols)))
}
