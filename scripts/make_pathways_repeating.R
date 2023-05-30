# This script pulls down the current list of all instruments from the redcap API, 
# then makes any instruments with "_pathway" in their name repeating
# and imports that info back to the project via the API again

# API tokens stored in .Renviron https://cran.r-project.org/web/packages/httr/vignettes/secrets.html#environment-variables

source(here::here("scripts", "functions.R")) # get custom functions for this project\

# get the current list of all instruments
url <- "https://redcap.chop.edu/api/"
formData <- list("token"=Sys.getenv("NALMS_57556"),
                 content='instrument',
                 format='csv',
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
instruments <- httr::content(response)$instrument_name

# the list of all pathway instruments
pathways <- grep(x = instruments, pattern = "_pathway", value = TRUE)

# format it for importing to redcap
repeating_instruments <- data.frame(form_name = pathways, custom_form_label = NA) |> 
  dataframe_as_string()
  
# import the list of repeating instruments via redcap API
formData <- list("token"=Sys.getenv("NALMS_57556"),
                 content='repeatingFormsEvents',
                 format='csv',
                 data=repeating_instruments,
                 returnFormat='json'
)
response <- httr::POST(url, body = formData, encode = "form")
result <- httr::content(response)
print(result) # if it imports correctly, result should be the number of repeating instruments
