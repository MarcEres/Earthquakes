---
title: "README"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{knit}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

[![Build Status](https://app.travis-ci.com/MarcEres/Earthquakes.svg?branch=main)](https://app.travis-ci.com/MarcEres/Earthquakes)


```r
library(Earthquakes)
```

The package `Earthquakes` has been constructed to clean and plot earthquake data from NOAA.

The package is composed of three main files:

* Cleaning and formatting the dataset.
* Plotting the earthquakes on a line graph.
* Plotting the Eathquakes in a leaflet map.

## Cleaning and formatting the dataset

### A. eq_location_clean

`eq_location_clean` takes `data`, and returns that same data with its column LOCATION_NAME cleaned.

```r
## Function Call
data <- data.frame(LOCATION_NAME = "SPAIN:  BARCELONA")
eq_location_clean(data)
```

### B. eq_clean_data

`eq_clean_data` takes `data`  and returns a cleaned dataset with the `eq_location_clean` applied to it.



```r
## Data Setup
test <- data.frame(`Location Name` = c("SPAIN:  BARCELONA"),
                            Year = c(2005),
                            Mo = c(5),
                            Dy = c(1),
                            Latitude = c("33.4"),
                            Longitude = c("2.1"),
                            Mag = c(4),
                            `Total Deaths` = c(6))
```

```r
## Function Call
test %>%
  eq_location_clean()
```

## Plotting the earthquakes on a line graph

Rendering of a line graph to plot the different earthquakes based on Richter values and deaths.


### A. geom_timeline

`geom_timeline` is the layer function for the GeomTime Geom. The colour indicates the number of deaths
 and size the Richter value.



```r
## Data Setup
test <- data.frame(`Location Name` = c("SPAIN:  BARCELONA", "FRANCE:  PARIS"),
                            Year = c(2005,2006),
                            Mo = c(5,6),
                            Dy = c(1.2),
                            Latitude = c("33.4", "20.5"),
                            Longitude = c("2.1", "15.2"),
                            Mag = c(4,7),
                            `Total Deaths` = c(6,8))
## Function Call
test %>%
eq_clean_data() %>%
 dplyr::filter(COUNTRY %in% c("SPAIN") & (lubridate::year(DATE) >= 2000 & lubridate::year(DATE) <= 2015)) %>%
 ggplot() + geom_timeline( aes(x = DATE, size = MAGNITUDE, fill = DEATHS)) +
 ggplot2::labs(size = "Richter scale value", fill = "# Deaths") + theme_time()
```

### B. geom_timeline_label

`geom_timeline_label` is the layer function to call the GeomTimelineLabel Geom. This function requires
an argument  `label`. Another  argument required is `nmax`, required to know how many top labels to use in the annotation.



```r
## Function Call
test %>%
  eq_clean_data() %>%
  dplyr::filter(COUNTRY %in% c("SPAIN", "FRANCE") & lubridate::year(DATE) > 1950) %>%
  ggplot(aes(x = DATE, y = COUNTRY, color = DEATHS, size = MAGNITUDE)) +
  geom_timeline() + geom_timeline_label(aes(label = LOCATION_NAME), n_max = 2) +
  ggplot2::labs(size = "Richter scale value", col = "# Deaths") + theme_time()
```

## Plotting the Eathquakes in a leaflet map

### A. eq_map

`eq_map` is the function that plots the data found on the argument `data`, using the columns LATITUDE and LONGITUDE. The data will be plotted as circles in the map, once you click the circle a pop up will appear showing the information that was input in the `annot_col` argument.



```r

## Data Setup
test <- data.frame(`Location Name` = c("SPAIN:  BARCELONA"),
                            Year = c(2005),
                            Mo = c(5),
                            Dy = c(1),
                            Latitude = c("33.4"),
                            Longitude = c("2.1"),
                            Mag = c(4),
                            `Total Deaths` = c(6))
## Function Call
test %>%
 eq_clean_data() %>%
 dplyr::filter(COUNTRY %in% c("SPAIN") & lubridate::year(DATE) >= 2000) %>%
 eq_map(annot_col="DATE")                                                                                             ^
```

### B. eq_create_label

`eq_create_label` creates a new column called 'popup_text' using location name, magnitude and total deaths.
This column is the formatted into the HTML format. If any value == NA, it is skipped. The result is a leaflet map
that contains circles representing the earthquakes, of which the size is directly proportional to the magnitude.



```r

## Data Setup
test <- data.frame(`Location Name` = c("SPAIN:  BARCELONA"),
                            Year = c(2005),
                            Mo = c(5),
                            Dy = c(1),
                            Latitude = c("33.4"),
                            Longitude = c("2.1"),
                            Mag = c(4),
                            `Total Deaths` = c(6))
## Function Call
test %>%
 eq_clean_data() %>%
 dplyr::filter(COUNTRY %in% c("SPAIN") & lubridate::year(DATE) >= 2000) %>%
 dplyr::mutate(popup_text = eq_create_label(.)) %>% eq_map(annot_col = "popup_text")
```
