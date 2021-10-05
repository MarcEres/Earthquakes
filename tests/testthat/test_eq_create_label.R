library(testthat)
library(Earthquakes)
library(ggplot2)
library(dplyr)

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

data_clean <- eq_clean_data(data)

map <- data_clean %>% dplyr::mutate(popup_text = eq_create_label(.)) %>% eq_map(annot_col = "popup_text")


test_that("map default width is 100%", {
  expect_true(map$sizingPolicy$defaultWidth == "100%")
})
