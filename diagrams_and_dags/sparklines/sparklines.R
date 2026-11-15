# Publication-Grade Sparklines Generator in R
# Adheres to Edward Tufte's principles in Beautiful Evidence (2006):
# word-sized, data-dense graphics designed for tabular integration.
#
# Citations:
# - Tufte, E. R. (2006). Beautiful Evidence. Cheshire, CT: Graphics Press.
#   LCCN: 2006925585. ISBN: 978-0-9613921-7-8.

suppressPackageStartupMessages({
  library(ggplot2)
})

generate_sparkline_r <- function(y_vals, out_pdf, out_png, width = 2.2, height = 0.45) {
  df <- data.frame(x = seq_along(y_vals), y = y_vals)
  
  min_idx <- which.min(df$y)
  max_idx <- which.max(df$y)
  last_idx <- nrow(df)
  
  p <- ggplot(df, aes(x = x, y = y)) +
    geom_line(color = "#222222", linewidth = 0.6) +
    # Highlight Minimum (Vermillion)
    geom_point(data = df[min_idx, ], aes(x = x, y = y), color = "#D55E00", size = 1.3) +
    # Highlight Maximum (Blue)
    geom_point(data = df[max_idx, ], aes(x = x, y = y), color = "#0072B2", size = 1.3) +
    # Highlight Final Observation (Black)
    geom_point(data = df[last_idx, ], aes(x = x, y = y), color = "#222222", size = 1.4) +
    theme_void() +
    theme(
      plot.margin = margin(1, 2, 1, 2),
      panel.background = element_blank(),
      plot.background = element_blank()
    )
  
  ggsave(out_pdf, plot = p, width = width, height = height, device = "pdf")
  ggsave(out_png, plot = p, width = width, height = height, dpi = 300)
  invisible(p)
}

main <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  series_list <- list(
    "inflation" = c(1.8, 1.9, 2.1, 2.3, 2.4, 4.7, 7.0, 8.9, 6.5, 3.7, 3.1, 2.6),
    "unemployment" = c(6.2, 5.8, 5.3, 4.9, 4.1, 8.1, 5.4, 3.9, 3.6, 3.7, 3.9, 4.1),
    "federal_funds" = c(0.1, 0.1, 0.1, 0.1, 0.2, 0.1, 0.1, 1.6, 5.1, 5.3, 5.1, 4.6),
    "oil_price" = c(52.1, 64.3, 57.0, 39.7, 68.1, 94.5, 82.1, 77.6, 85.2, 78.4, 75.1, 71.3)
  )
  
  for (name in names(series_list)) {
    out_pdf <- file.path(script_dir, paste0("spark_", name, "_r.pdf"))
    out_png <- file.path(script_dir, paste0("spark_", name, "_r.png"))
    generate_sparkline_r(series_list[[name]], out_pdf, out_png)
    message(sprintf("Saved sparkline: %s and %s", out_pdf, out_png))
  }
  invisible(NULL)
}

if (!interactive()) {
  main()
}
