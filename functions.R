library(httr)
library(jsonlite)
library(tidyr)

get_500_recent <- function(title, start_date = "start"){
  base_list = list(
    action = "query",
    prop = "revisions",
    rvprop = "timestamp",
    #rvprop = "timestamp|user|comment|content",
    #rvprop = "timestamp|user",
    #rvprop = "user",
    rvlimit = "500",
    rvslots = "main",
    redirects = "1",
    formatversion = "2",
    rvdir = "newer",
    format = "json"
  )

  # make list
  if (start_date == "start") {
    supp_list = list(
      titles = title
    )
  } else {
    supp_list = list(
      titles = title,
      rvstart = start_date
    )
  }

  query_list = c(base_list, supp_list)

  res = GET(
    "http://en.wikipedia.org/w/api.php",
    query = query_list
  )

  data = fromJSON(rawToChar(res$content))

  dom <- data$query$pages$revisions[[1]]

  return(dom)
}

# get full edit history

get_edit_history <- function(title){

  # get first set of data
  first_data <- get_500_recent(title)

  # if the first set of data is less than 500 rows then return that set
  if (nrow(first_data) < 500 ) {
    return(first_data)
  }

  # start a loop to get all the data
  fetched_data <- first_data # current set of fetched data
  data_out <- fetched_data # all data together

  while (nrow(fetched_data) == 500 ){
    # drop the last row of the data
    data_out <- data_out %>% filter(row_number() <= n()-1)
    # determine new start date for query
    date_start <- as.character(tail(fetched_data, n=1))
    # run new query using start date
    fetched_data <- get_500_recent(title, date_start)
    # combine new data(fetched_data) with data_out
    data_out <- rbind(data_out, fetched_data)
  }
  return(data_out)
}

process_edits <- function(edit_data){
  edit_data %>%
    mutate(dates =  as_date(timestamp)) %>%
    count(dates) %>%
    complete(dates = seq.Date(min(dates), max(dates), by="day")) %>%
    mutate(n = replace_na(n, 0))
}
