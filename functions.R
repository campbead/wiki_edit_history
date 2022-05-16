library(httr)
library(jsonlite)

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

  first_data <- get_500_recent(title)

  if (nrow(first_data) < 500 ) {
    return(first_data)
  }

  fetched_data <- first_data
  data_out <- fetched_data

  while (nrow(fetched_data) == 500 ){
    data_out <- data_out %>% filter(row_number() <= n()-1)
    date_start <- as.character(tail(fetched_data, n=1))
    fetched_data <- get_500_recent(title, date_start)
    data_out <- rbind(data_out, fetched_data)
  }
  return(data_out)
}
