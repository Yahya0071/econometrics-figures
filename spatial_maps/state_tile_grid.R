# Publication-Grade US State Tile-Grid Cartogram (R / ggplot2)
# Eliminates landmass distortion by according equal visual area to each state
#
# Adheres to Gastel & Day exhibit standards and Tufte's data-ink principles

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. State Tile Grid Coordinate Layout
state_grid_df <- data.frame(
  state = c(
    "AK", "ME",
    "VT", "NH",
    "WA", "ID", "MT", "ND", "MN", "IL", "WI", "MI", "NY", "MA", "RI",
    "OR", "NV", "WY", "SD", "IA", "IN", "OH", "PA", "NJ", "CT",
    "CA", "UT", "CO", "NE", "MO", "KY", "WV", "VA", "MD", "DE",
    "AZ", "NM", "KS", "AR", "TN", "NC", "SC", "DC",
    "OK", "LA", "MS", "AL", "GA",
    "HI", "TX", "FL"
  ),
  col = c(
    0, 11,
    10, 11,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    2, 3, 4, 5, 6, 7, 8, 9,
    4, 5, 6, 7, 8,
    0, 4, 9
  ),
  row = c(
    7, 7,
    6, 6,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    2, 2, 2, 2, 2, 2, 2, 2,
    1, 1, 1, 1, 1,
    0, 0, 0
  )
)

# 2. Simulate State Economic Data
simulate_state_data <- function(seed = 42) {
  set.seed(seed)
  df <- state_grid_df
  df$value <- round(rnorm(nrow(df), mean = 12.5, sd = 3.2), 1)
  
  # Quintile bins
  q_cuts <- quantile(df$value, probs = seq(0, 1, by = 0.2))
  df$quintile <- cut(
    df$value,
    breaks = q_cuts,
    include.lowest = TRUE,
    labels = c(
      "1st Quintile (Lowest)",
      "2nd Quintile",
      "3rd Quintile (Median)",
      "4th Quintile",
      "5th Quintile (Highest)"
    )
  )
  df
}

# 3. Render Publication Exhibit
plot_state_tile_grid_r <- function(df, out_pdf, out_png) {
  p <- ggplot(df, aes(x = col, y = row)) +
    geom_tile(aes(fill = quintile), color = "#FFFFFF", linewidth = 0.8, width = 0.92, height = 0.92) +
    geom_text(aes(label = state), nudge_y = 0.12, fontface = "bold", size = 3.2, color = "#FFFFFF") +
    geom_text(aes(label = sprintf("%.1f", value)), nudge_y = -0.16, size = 2.4, color = "#F0F0F0") +
    scale_fill_manual(
      values = c(
        "1st Quintile (Lowest)" = "#440154",
        "2nd Quintile" = "#3B528B",
        "3rd Quintile (Median)" = "#21908C",
        "4th Quintile" = "#5DC863",
        "5th Quintile (Highest)" = "#FDE725"
      )
    ) +
    scale_y_continuous(expand = c(0.04, 0.04)) +
    scale_x_continuous(expand = c(0.04, 0.04)) +
    coord_equal() +
    labs(
      fill = "",
      caption = paste(
        "Notes: Equal-area tile grid cartogram of 50 US states and District of Columbia.",
        "Color shading depicts quintiles of the simulated state economic indicator.",
        "Numbers inside tiles denote jurisdiction-level observed values.",
        sep = "\n"
      )
    ) +
    theme_void(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "bottom",
      legend.direction = "horizontal",
      legend.key.height = unit(0.35, "cm"),
      legend.key.width = unit(1.0, "cm"),
      legend.text = element_text(size = 7.5, color = "#222222"),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 12)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 8.8, height = 6.2, device = "pdf")
  ggsave(out_png, plot = p, width = 8.8, height = 6.2, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  return(invisible(p))
}

main <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  df <- simulate_state_data()
  out_pdf <- file.path(script_dir, "state_tile_grid_r.pdf")
  out_png <- file.path(script_dir, "state_tile_grid_r.png")
  plot_state_tile_grid_r(df, out_pdf, out_png)
  invisible(NULL)
}

if (!interactive()) {
  main()
}
