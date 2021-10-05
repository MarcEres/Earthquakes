globalVariables(c("Dy", "Total Deaths", "Mag", "Latitude", "LOCATION_NAME", "Longitude", "Mo",
                  "Location Name", "Year", "popup_text"))


#' Format LOCATION_NAME
#'
#' This function removes the country and the ":" symbol from the location name.
#'
#' @param data dataframe containing a column with the name "LOCATION_NAME".
#'
#' @return This function returns location name with the title case format.
#'
#' @import dplyr
#' @import tools
#' @import magrittr
#'
#' @examples \dontrun{
#'  data <- data.frame(LOCATION_NAME = "SPAIN:  BARCELONA")
#'  eq_location_clean(data)
#' }
#'
#' @export
eq_location_clean <- function(data){
   data %>%
   dplyr:: mutate(LOCATION_NAME = tools::toTitleCase(tolower(gsub("[a-zA-Z].*:. ", "", LOCATION_NAME))))

}

#' Clean Data from the NOAA data frame.
#'
#' This function cleans the data, mainly the following columns.
#' YEAR, MONTH, DAY, LATITUDE, LONGITUDE, MAGNITUDE, COUNTRY and DEATHS
#'
#' @param data Earthquake dataset.
#'
#' @return The function returns the clean dataset and calls the next function
#'         eq_location_clean().
#'
#' @examples \dontrun{
#'  readr::read_delim("earthquakes-2021-09-27_15-28-44_+0200.tsv") %>%
#'  eq_clean_data()
#' }
#'
#' @import dplyr
#' @import magrittr
#'
#' @export
eq_clean_data <- function(data){
    data %>%
      dplyr::filter(Year > 0 & !is.na(Dy) & !is.na(Mo)) %>%
      dplyr::mutate(DATE = ISOdatetime(year = Year, month = Mo, day = Dy, hour = 0, min = 0, sec = 0, tz = "GMT"),
       LATITUDE = as.numeric(Latitude), LONGITUDE = as.numeric(Longitude),
       LOCATION_NAME = `Location Name`,
       DEATHS = as.numeric(`Total Deaths`),
       MAGNITUDE = as.numeric(Mag),
       COUNTRY = gsub(":.*", "", `Location Name`)) %>%
       eq_location_clean()
}
