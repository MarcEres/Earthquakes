#' Plot Earthquakes in a Map
#'
#' This function takes a dataset, with latitude and longitude columns, and displays
#' its earthquakes in a leaflet map. The data is presented as circles with popup info
#' and the size is proportional to the magnitude registered.
#'
#' @param data The dataset to plot.
#' @param annot_col Data representing the markers that will be used in the popup.
#'
#' @import leaflet
#' @import dplyr
#' @import magrittr
#'
#' @return This function returns a leaflet map with the earthquakes positioned in each location.
#'
#' @examples  \dontrun{
#' readr::read_delim("earthquakes-2021-09-27_15-28-44_+0200.tsv") %>%
#' eq_clean_data() %>%
#' dplyr::filter(COUNTRY %in% c("MEXICO") & lubridate::year(DATE) >= 2000) %>%
#' eq_map(annot_col = "DATE")
#' }
#'
#' @export
eq_map <- function(data, annot_col) {
  data <- data %>%
    dplyr::mutate(poplabel = data[[annot_col]])
  m <- data %>%
    leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addCircleMarkers(~LONGITUDE,
                              ~LATITUDE,
                              popup = ~poplabel,
                              weight = 1,
                              radius = ~Mag)
  return(m)
}

#' Introduce Labels in a Leaflet Map
#'
#' This function plots a leaflet map and labels it.
#'
#' @param data The dataset to plot.
#'
#' @import dplyr
#' @import magrittr
#' @import stringr
#' @import htmltools
#' @import leaflet
#'
#' @examples \dontrun{
#' readr::read_delim("earthquakes-2021-09-27_15-28-44_+0200.tsv") %>%
#' eq_clean_data() %>%
#' dplyr::filter(COUNTRY %in% c("MEXICO") & lubridate::year(DATE) >= 2000) %>%
#' dplyr::mutate(popup_text = eq_create_label(.)) %>% eq_map(annot_col = "popup_text")
#' }
#'
#' @export
eq_create_label <- function(data) {
  # Remove possible NAs
  rm <- stringr::str_c(c("<strong>Location: </strong>NA<br/>",
                         "<strong>Magnitude: </strong>NA<br/>",
                         "<strong>Total Deaths: </strong>NA"), collapse = "|")
  data <- data %>%
    dplyr::mutate(popup_text = (paste0('<strong>Location: </strong>',
                                       `Location Name`, '<br/>',
                                       '<strong>Magnitude: </strong>',
                                       Mag, '<br/>',
                                       '<strong>Total Deaths: </strong>',
                                       `Total Deaths`) %>% lapply(htmltools::HTML))) %>%
    dplyr::mutate(popup_text = stringr::str_remove_all(popup_text, rm))

  return(as.vector(data$popup_text))
}
