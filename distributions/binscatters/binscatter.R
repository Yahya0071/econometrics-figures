# Publication-Grade Binned Scatter Plot (R / ggplot2)
# Adheres to Gastel & Day exhibit standards and Cattaneo et al. (2024)
#
# Citations:
# - Cattaneo, M. D., R. K. Crump, M. H. Farrell, and Y. Feng (2024). On Binscatter.
#   American Economic Review, 114(5), 1488-1514.
#   DOI: 10.1257/aer.20221576

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Simulate Microdata
simulate_binscatter_data <- function(n = 5000, seed = 42) {
  set.seed(seed)
  x <- rnorm(n, mean = 10, sd = 1.2)
  group <- rbinom(n, size = 1, prob = 0.5)
  beta_0 <- 2.0 - 0.8 * group
  beta_1 <- 0.65 + 0.17 * group
  y <- beta_0 + beta_1 * x + rnorm(n, mean = 0, sd = 0.9)
  
  data.frame(x = x, y = y, group = factor(group, labels = c("Group A", "Group B")))
}

# 2. Compute Quantile Bins
compute_quantile_bins <- function(df, n_bins = 20) {
  split_dfs <- split(df, df$group)
  
  binned_list <- lapply(split_dfs, function(sub_df) {
    probs <- seq(0, 1, length.out = n_bins + 1)
    breaks <- quantile(sub_df$x, probs = probs, na.rm = TRUE)
    sub_df$bin <- cut(sub_df$x, breaks = unique(breaks), include.lowest = TRUE)
    
    agg <- aggregate(cbind(x, y) ~ bin, data = sub_df, FUN = mean)
    agg$group <- sub_df$group[1]
    agg
  })
  
  do.call(rbind, binned_list)
}

# 3. Render Exhibit
plot_binscatter_r <- function(raw_df, binned_df, out_pdf = "binscatter_r.pdf", out_png = "binscatter_r.png") {
  p <- ggplot() +
    # Binned mean markers
    geom_point(
      data = binned_df,
      aes(x = x, y = y, color = group),
      size = 2.4,
      alpha = 0.85
    ) +
    # Linear OLS regression lines fit on microdata
    geom_smooth(
      data = raw_df,
      aes(x = x, y = y, color = group),
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      linewidth = 0.9
    ) +
    scale_color_manual(values = c("Group A" = "#0072B2", "Group B" = "#D55E00")) +
    annotate("text", x = 13.0, y = 10.6, label = "Group A Fit", color = "#0072B2", size = 3.3, fontface = "bold", hjust = 0) +
    annotate("text", x = 13.0, y = 12.0, label = "Group B Fit", color = "#D55E00", size = 3.3, fontface = "bold", hjust = 0) +
    labs(
      x = "Log Parental Income (X)",
      y = "Standardized Student Test Score (Y)",
      caption = paste(
        "Notes: Scatter markers display mean coordinates within 20 equal-sized quantile bins per cohort.",
        "Solid lines depict linear OLS regression fits on underlying microdata. Total sample: N = 5,000.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "none",
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ebebeb", linewidth = 0.3),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 24, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 7.2, height = 4.6, device = "pdf")
  ggsave(out_png, plot = p, width = 7.2, height = 4.6, dpi = 300)
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
  
  raw <- simulate_binscatter_data()
  binned <- compute_quantile_bins(raw)
  out_pdf <- file.path(script_dir, "binscatter_r.pdf")
  out_png <- file.path(script_dir, "binscatter_r.png")
  plot_binscatter_r(raw, binned, out_pdf, out_png)
  invisible(NULL)
}

if (!interactive()) {
  main()
}
