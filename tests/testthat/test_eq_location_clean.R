library(testthat)
library("Earthquakes")


test_that("Location was cleaned as expected", {
  data <- data.frame(LOCATION_NAME = "SPAIN:  BARCELONA")
  location <- eq_location_clean(data)
  expect_equal(location[1,], "Barcelona")
  })
