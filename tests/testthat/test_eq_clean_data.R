library(dplyr)
library(testthat)
library(Earthquakes)

data <- structure(list(`Location Name` = c("SPAIN:  BARCELONA", "SPAIN:  VALENCIA", "SPAIN:  MADRID", "SPAIN:  TARRAGONA"),
                     Year = c(2000, 2001, 2002, 2003),
                     Mo = c(1, 2, 3, 4),
                     Dy = c(1, 5, 15, 20),
                     Mag = c("1.1", "2.2", "3.3", "4.4"),
                     Latitude = c("41.387", "39.469", "40.416", "41.118"),
                     Longitude = c("2.168", "0.376", "3.703", "1.244"),
                     `Total Deaths` = c(10, 100, 200, 400)),
                .Names = c("Location Name", "Year", "Mo", "Dy", "Mag", "Latitude","Longitude","Total Deaths"),
                row.names = c(NA, 4L), class = "data.frame")

test_that("Data was cleaned as expected", {
  city <- eq_clean_data(data) %>% filter( MAGNITUDE > 4) %>% select(LOCATION_NAME)
  latitude <- eq_clean_data(data) %>% filter( MAGNITUDE > 4) %>% select(LATITUDE)
  longitude <- eq_clean_data(data) %>% filter( MAGNITUDE > 4) %>% select(LONGITUDE)
  date <- eq_clean_data(data) %>% filter( MAGNITUDE > 4) %>% select(DATE)
  expect_equal(city[1,], "Tarragona")
  expect_equal(latitude[1,], 41.118)
  expect_equal(longitude[1,], 1.244)
  expect_equal(date[1,], ISOdatetime(year = 2003, month = 4, day = 20, hour = 0, min = 0, sec = 0, tz = "GMT"))
})
