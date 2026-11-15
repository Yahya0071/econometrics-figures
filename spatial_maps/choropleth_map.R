# Publication-Grade Spatial Choropleth Map (R / sf & ggplot2)
# Adheres to Gastel & Day exhibit standards and Pebesma (2018) Simple Features
# Demonstrates discrete quantile binning and equal-area planar projection

suppressPackageStartupMessages({
  if (requireNamespace("sf", quietly = TRUE)) {
    library(sf)
  }
  library(ggplot2)
})

# 1. Synthesize Contiguous Hexagonal Spatial Units
create_synthetic_spatial_sf <- function(n_rows = 6, n_cols = 8, seed = 42) {
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
      
      polys[[counter]] <- st_polygon(list(coords))
      counter <- counter + 1
    }
  }
  
  sfc <- st_sfc(polys)
  values <- rnorm(length(sfc), mean = 20, sd = 5)
  
  st_sf(
    zone_id = paste0("CZ_", seq_along(sfc)),
    economic_index = values,
    geometry = sfc
  )
}

# 2. Render Publication Spatial Map
plot_choropleth_r <- function(gdf, out_pdf = "choropleth_r.pdf", out_png = "choropleth_r.png") {
  gdf$quintile <- cut(
    gdf$economic_index,
    breaks = quantile(gdf$economic_index, probs = seq(0, 1, 0.2)),
    include.lowest = TRUE,
    labels = c("1st Quintile (Lowest)", "2nd Quintile", "3rd Quintile (Median)", "4th Quintile", "5th Quintile (Highest)")
  )
  
  p <- ggplot(gdf) +
    geom_sf(aes(fill = quintile), color = "white", linewidth = 0.4) +
    scale_fill_viridis_d(
      name = "",
      option = "viridis",
      guide = guide_legend(nrow = 1, title.position = "top", label.position = "bottom")
    ) +
    labs(
      caption = "Notes: Choropleth map of economic commuting zones. Shading corresponds to 5-quantile discrete brackets. Projection: Planar equal-area coordinates."
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      legend.position = "top",
      legend.justification = "center",
      legend.text = element_text(size = rel(0.75)),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 8.0, height = 5.5, device = "pdf")
  ggsave(out_png, plot = p, width = 8.0, height = 5.5, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  return(p)
}

main <- function() {
  if (!requireNamespace("sf", quietly = TRUE)) {
    message("Package 'sf' is not installed; skipping local R choropleth execution.")
    return(invisible(NULL))
  }
  
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  spatial_df <- create_synthetic_spatial_sf()
  out_pdf <- file.path(script_dir, "choropleth_r.pdf")
  out_png <- file.path(script_dir, "choropleth_r.png")
  plot_choropleth_r(spatial_df, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
