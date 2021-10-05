globalVariables(c("Dy", "Total Deaths", "Mag", "Latitude", "LOCATION_NAME", "Longitude", "Mo",
                  "Location Name", "Year", "popup_text"))


#' Customize the plot theme
#'
#' Plot theme is modified from ggplot2 package.
#'
#' @details The parameters used to customize the theme can be found in the
#'          url : https://ggplot2.tidyverse.org/reference/theme.html
#'
#' @import ggplot2
#'
#'
theme_time <- function() {
  ggplot2::theme(
    plot.background = ggplot2::element_blank(),
    panel.background = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    axis.line.y = ggplot2::element_blank(),
    axis.line.x = ggplot2::element_line(size = 0.5, linetype = 1),
    legend.key = ggplot2::element_blank(),
    legend.position = "bottom"
  )
}

#' Creating a Geom -> GeomTime
#'
#' This Geom returns a ggproto object for our geom to inherit from.
#'
#' @param data A dataframe with the data to plot.
#' @param x Data to be plotted on the x-axis.
#' @param y Data to be plotted on the y-coordinate.
#' @param size Column of data proportional to the size of each point.
#' @param colour Column of data depicting the colour of each point.
#' @param shape Column of data in charge of the shape of each of the points.
#' @param alpha Column of data used to apply the alpha. \cr \cr
#' @param fill  String introduced to modify the fill of the points.S
#'
#' @import grid
#' @import ggplot2
#'
#' @return The function returns a Geom to be used by geom_timeline to render
#'         the images into the plot.
#'
#'
GeomTime <- ggplot2::ggproto("GeomTime", ggplot2::Geom,
        required_aes = c("x"),
        default_aes = ggplot2::aes(colour = "grey3",
                                   fill = "grey3",
                                   size = 0.5,
                                   shape = 19,
                                   alpha = 0.4,
                                   y = 0.2),
        draw_key =  ggplot2::draw_key_point,
        draw_panel = function(data, panel_scales, coord) {

                coords <- coord$transform(data, panel_scales)

                points <- pointsGrob(
                  x = coords$x,
                  y = coords$y,
                  size = grid::unit(coords$size, "mm"),
                  pch = coords$shape,

                  gp = grid::gpar(size = coords$size,
                                  col = scales::alpha(data$colour, data$alpha),
                                  fill = scales::alpha(data$fill, data$alpha)))
        }
)

#' Creating the geom -> geom_timeline()
#'
#' This function plots the dates of Earthquakes on a straight line.
#' The size of each point is directly proportional to the Ritcher scale value and the
#' colour is coded by the total deaths of each earthquake.
#'
#' @param data A dataframe containing the data to plot.
#' @param mapping Mapping argument to the ggplot layer.
#' @param stat Stat argument to the ggplot layer.
#' @param position Position argument to the ggplot layer.
#' @param na.rm na.rm argument to the ggplot layer.
#' @param show.legend show.legend argument to the ggplot layer.
#' @param inherit.aes inherit.aes argument to the ggplot layer.
#' @param ... Extra Params.
#'
#' @import ggplot2
#'
#' @return This function renders the plot into the current graphics device.
#'
#' @examples \dontrun{
#' readr::read_delim("earthquakes-2021-09-27_15-28-44_+0200.tsv") %>%
#' eq_clean_data() %>%
#' dplyr::filter(COUNTRY %in% c("TURKEY") &
#' (lubridate::year(DATE) >= 2000 & lubridate::year(DATE) <= 2015)) %>%
#' ggplot() + geom_timeline( aes(x = DATE, size = MAGNITUDE, fill = DEATHS)) +
#' ggplot2::labs(size = "Richter scale value", fill = "# Deaths") + theme_time()
#' }
#'
#' @export
geom_timeline <- function(mapping = NULL, data = NULL, stat = "identity",
                          position = "identity", na.rm = FALSE,
                          show.legend = NA, inherit.aes = TRUE, ...) {
              ggplot2::layer(
                      data = data,
                      mapping = mapping,
                      stat = stat,
                      geom = GeomTime,
                      position = position,
                      show.legend = show.legend, inherit.aes = inherit.aes,
                      params = list(na.rm = na.rm, ...)
             )
}

#' Creating a Geom -> GeomTimelineLabel
#'
#' This Geom returns a ggproto object for our geom to inherit from. It also includes
#' labels for each of the earthquakes plotted. The creation of this function is documented
#' inside the function for easy comprehension and to reduce the size of this description.
#'
#' @param data A dataframe with the data to plot.
#' @param x Data to be plotted on the x-axis.
#' @param y Data to be plotted on the y-coordinate.
#' @param size Column of data proportional to the size of each point.
#' @param colour Column of data depicting the colour of each point.
#' @param shape Column of data in charge of the shape of each of the points.
#' @param alpha Column of data used to apply the alpha. \cr \cr
#' @param fill  String introduced to modify the fill of the points.S
#'
#' @import grid
#' @import ggplot2
#'
#' @return The function returns a Geom to be used by geom_timeline to render
#'         the images into the plot.
#'
#' 
GeomTimelineLabel <- ggplot2::ggproto(
  "GeomTimelineLabel", ggplot2::Geom,
  required_aes = c("x", "label"),
  draw_key = ggplot2::draw_key_blank,

  # Setup values for n_max
  setup_data = function(data, params) {
    data <- data %>%
      dplyr::group_by("group") %>%
      dplyr::top_n(params$n_max, size) %>%
      dplyr::ungroup()
  },

  draw_panel = function(data, panel_scales, coord, n_max){

    # transform data
    coords <- coord$transform(data, panel_scales)

    # construct grobs for lines and locations
    n_grp <- length(unique(data$group))
    offset <- 0.1 / n_grp
    lines <- grid::polylineGrob(
      x = grid::unit(c(coords$x, coords$x), "mm"),
      y = grid::unit(c(coords$y, coords$y + offset), "mm"),
      id = rep(1:dim(coords)[1], 2),
      gp = grid::gpar(col = "darkgrey", alpha = 0.6, lwd = 0.5)
    )

    locations <- grid::textGrob(
      label = coords$label,
      x = grid::unit(coords$x, "npc"),
      y = grid::unit(coords$y + offset, "npc"),
      just = c("left", "bottom"),
      rot = 45,
      gp = grid::gpar(fontsize = 10)
    )

    # return yline and dps grobs
    grid::gList(lines, locations)
  }
)

#' Creating the geom -> geom_timeline_label()
#'
#' This function plots the dates of Earthquakes on a straight line.
#' The size of each point is directly proportional to the Ritcher scale value and the
#' colour is coded by the total deaths of each earthquake. Also a label with the location
#' name will be displayed if possible.
#'
#' @param data A dataframe containing the data to plot.
#' @param mapping Mapping argument to the ggplot layer.
#' @param stat Stat argument to the ggplot layer.
#' @param position Position argument to the ggplot layer.
#' @param na.rm na.rm argument to the ggplot layer.
#' @param show.legend show.legend argument to the ggplot layer.
#' @param inherit.aes inherit.aes argument to the ggplot layer.
#' @param ... Extra Params.
#'
#' @import ggplot2
#'
#' @return This function renders the plot into the current graphics device.
#'
#' @examples \dontrun{
#' readr::read_delim("earthquakes-2021-09-27_15-28-44_+0200.tsv") %>%
#' eq_clean_data() %>%
#' dplyr::filter(COUNTRY %in% c("TURKEY", "CALIFORNIA") & lubridate::year(DATE) > 1950) %>%
#' ggplot(aes(x = DATE, y = COUNTRY, color = DEATHS, size = MAGNITUDE))
#' + geom_timeline() + geom_timeline_label(aes(label =LOCATION_NAME), n_max = 3)
#' + ggplot2::labs(size = "Richter scale value", col = "# Deaths") + theme_time()
#' }
#'
#' @export
geom_timeline_label <- function(mapping = NULL, data = NULL, stat = "identity",
                          position = "identity", na.rm = FALSE,
                          show.legend = NA, inherit.aes = TRUE, ...) {
  ggplot2::layer(
    geom = GeomTimelineLabel,
    mapping = mapping,
    data = data,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
