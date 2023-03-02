# this function takes a dataframe and returns a string that is formatted like csv,
# for importing into redcap via the API
dataframe_as_string <- function(df){
  paste(utils::capture.output(data.table::fwrite(df)), collapse = "\n")
}