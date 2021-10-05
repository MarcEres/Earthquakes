library(testthat)
library(Earthquakes)
library(ggplot2)


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

plot <- ggplot(data_clean) +
  geom_timeline( aes(x = DATE, y = COUNTRY, size = MAGNITUDE, fill = DEATHS))

test_that("plot object has DEATHS info", {
  expect_true("DEATHS" %in% names(plot$data))
})
