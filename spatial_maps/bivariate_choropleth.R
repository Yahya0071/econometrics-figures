# Publication-Grade Bivariate Choropleth Map (R / biscale & ggplot2)
# Adheres to Gastel & Day exhibit standards and Prener (2019) biscale architecture
# Corresponds to Asjad Naqvi's stata-bimap and Joshua Stevens' bivariate palettes

suppressPackageStartupMessages({
  if (requireNamespace("sf", quietly = TRUE)) {
    library(sf)
  }
  if (requireNamespace("biscale", quietly = TRUE)) {
    library(biscale)
  }
  if (requireNamespace("cowplot", quietly = TRUE)) {
    library(cowplot)
  }
  library(ggplot2)
})

# 1. Synthesize Bivariate Spatial Data
create_bivariate_spatial_sf <- function(n_rows = 6, n_cols = 8, seed = 42) {
  set.seed(seed)
  polys <- list()
  counter <- 1
  
  for (r in 0:(n_rows - 1)) {
    for (c in 0:(n_cols - 1)) {
      x_offset <- (r %% 2) * 0.5
      x0 <- c + x_offset
      y0 <- r * 0.866
      
      coords <- matrix(c(
        x0 + 0.5, y0,
        x0 + 1.0, y0 + 0.288,
        x0 + 1.0, y0 + 0.866,
        x0 + 0.5, y0 + 1.155,
        x0, y0 + 0.866,
        x0, y0 + 0.288,
        x0 + 0.5, y0
      ), ncol = 2, byrow = TRUE)
      
      polys[[counter]] <- sf::st_polygon(list(coords))
      counter <- counter + 1
    }
  }
  
  sfc <- sf::st_sfc(polys)
  n <- length(sfc)
  
  income <- rnorm(n, mean = 60, sd = 10)
  hazard <- -0.4 * income + rnorm(n, mean = 60, sd = 8)
  
  sf::st_sf(
    zone_id = paste0("Zone_", seq_along(sfc)),
    income = income,
    hazard = hazard,
    geometry = sfc
  )
}

# 2. Render Publication Bivariate Map with 2D Legend
plot_bivariate_map_r <- function(gdf, out_pdf = "bivariate_choropleth_r.pdf", out_png = "bivariate_choropleth_r.png") {
  data_biv <- biscale::bi_class(gdf, x = income, y = hazard, style = "quantile", dim = 3)
  
  map_plot <- ggplot(data_biv) +
    geom_sf(aes(fill = bi_class), color = "white", linewidth = 0.4, show.legend = FALSE) +
    biscale::bi_scale_fill(pal = "DkBlue", dim = 3) +
    labs(
      caption = "Notes: Bivariate choropleth map (3x3 classification). Corresponds to Naqvi (2022) and Stevens (2015)."
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  legend_plot <- biscale::bi_legend(
    pal = "DkBlue",
    dim = 3,
    xlab = "Higher Income ",
    ylab = "Higher Hazard ",
    size = 8
  )
  
  final_plot <- cowplot::ggdraw() +
    cowplot::draw_plot(map_plot, 0, 0, 1, 1) +
    cowplot::draw_plot(legend_plot, 0.74, 0.64, 0.22, 0.22)
  
  ggsave(out_pdf, plot = final_plot, width = 8.5, height = 6.0, device = "pdf")
  ggsave(out_png, plot = final_plot, width = 8.5, height = 6.0, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  return(final_plot)
}

main <- function() {
  if (!requireNamespace("sf", quietly = TRUE) ||
      !requireNamespace("biscale", quietly = TRUE) ||
      !requireNamespace("cowplot", quietly = TRUE)) {
    message("Packages 'sf', 'biscale', or 'cowplot' are not installed; skipping local R execution.")
    return(invisible(NULL))
  }
  
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  spatial_data <- create_bivariate_spatial_sf()
  out_pdf <- file.path(script_dir, "bivariate_choropleth_r.pdf")
  out_png <- file.path(script_dir, "bivariate_choropleth_r.png")
  plot_bivariate_map_r(spatial_data, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
