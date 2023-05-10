library(tidyverse)

data <- tibble(
  record_id = 1:4,
  pathway = rep(c("a", "b"), 2),
  a_module_title = NA,
  a_another_module = NA,
  a_pathway_complete = NA,
  b_module_title = NA,
  b_new_module = NA,
  b_pathway_complete = NA
)


data |>
  mutate(
    across(
      starts_with("a_"), ~ ifelse(pathway == "a", 0, NA)
    ),
    across(
      starts_with("b_"), ~ ifelse(pathway == "b", 0, NA)
    )
  )

data |>
  dplyr::mutate(
    dplyr::across(
      dplyr::starts_with(c("a_", "b_")),
      ~ ifelse(
        test = stringr::str_detect(dplyr::cur_column(), paste0("^", pathway, "_pathway_complete")),
        yes = 2,
        ifelse(
          test = stringr::str_detect(dplyr::cur_column(), paste0("^", pathway, "_")),
          yes = 0, 
          no = NA))))
