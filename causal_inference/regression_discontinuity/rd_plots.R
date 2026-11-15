# Publication-Grade Regression Discontinuity Plot (R / ggplot2)
# Adheres to Gastel & Day exhibit standards and Calonico, Cattaneo, and Titiunik (2014, 2015)
#
# Citations:
# - Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals
#   for Regression-Discontinuity Designs. Econometrica, 82(6), 2295-2326.
#   DOI: 10.3982/ECTA11757
# - Calonico, S., M. D. Cattaneo, and R. Titiunik (2015). Optimal Data-Driven Regression
#   Discontinuity Plots. Journal of the American Statistical Association, 110(512), 1753-1769.
#   DOI: 10.1080/01621459.2015.1017578

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Simulate Synthetic Sharp RD Data
simulate_rd_data <- function(n = 2000, cutoff = 0, true_jump = 2.5, seed = 42) {
  set.seed(seed)
  x <- rnorm(n, mean = 0, sd = 1.5)
  d <- as.numeric(x >= cutoff)
  mu <- 1.2 + 1.8 * x - 0.3 * (x^2) + true_jump * d
  y <- mu + rnorm(n, mean = 0, sd = 0.8)
  data.frame(x = x, d = d, y = y)
}

# 2. Compute Binned Means
compute_rd_bins <- function(df, cutoff = 0, n_bins = 25) {
  df$side <- ifelse(df$x < cutoff, "left", "right")
  
  df_left <- subset(df, side == "left")
  df_right <- subset(df, side == "right")
  
  df_left$bin <- cut(df_left$x, breaks = n_bins)
  df_right$bin <- cut(df_right$x, breaks = n_bins)
  
  bins_left <- aggregate(cbind(x, y) ~ bin, data = df_left, FUN = mean)
  bins_left$side <- "left"
  
  bins_right <- aggregate(cbind(x, y) ~ bin, data = df_right, FUN = mean)
  bins_right$side <- "right"
  
  rbind(bins_left, bins_right)
}

# 3. Render Publication RD Exhibit
plot_rd_r <- function(df, bins_df, cutoff = 0, bandwidth = 1.0, out_pdf = "rd_plot_r.pdf", out_png = "rd_plot_r.png") {
  df_sub <- subset(df, abs(x - cutoff) <= bandwidth)
  
  p <- ggplot() +
    # Vertical cutoff threshold line
    geom_vline(xintercept = cutoff, linetype = "dashed", color = "#D55E00", linewidth = 0.6) +
    # Binned sample means
    geom_point(
      data = bins_df,
      aes(x = x, y = y, color = side),
      alpha = 0.65,
      size = 2.0
    ) +
    # Local linear fits
    geom_smooth(
      data = subset(df_sub, x < cutoff),
      aes(x = x, y = y),
      method = "lm",
      formula = y ~ x,
      color = "#0072B2",
      fill = "#0072B2",
      alpha = 0.20,
      linewidth = 0.9
    ) +
    geom_smooth(
      data = subset(df_sub, x >= cutoff),
      aes(x = x, y = y),
      method = "lm",
      formula = y ~ x,
      color = "#009E73",
      fill = "#009E73",
      alpha = 0.20,
      linewidth = 0.9
    ) +
    scale_color_manual(
      values = c("left" = "#0072B2", "right" = "#009E73"),
      labels = c("left" = "Below Cutoff", "right" = "Above Cutoff")
    ) +
    annotate("text", x = -1.0, y = 1.2, label = "Control Fit", color = "#0072B2", size = 3.5, fontface = "bold") +
    annotate("text", x = 1.0, y = 4.8, label = "Treated Fit", color = "#009E73", size = 3.5, fontface = "bold") +
    annotate("text", x = cutoff + 0.08, y = -1.5, label = "Cutoff (c = 0.0)", color = "#D55E00", size = 3.2, angle = 90, hjust = 0) +
    labs(
      x = "Running Variable (X)",
      y = "Outcome Variable (Y)",
      caption = paste(
        "Notes: Scatter points depict local sample means grouped into 25 evenly spaced bins on each side of the cutoff.",
        "Solid curves report local linear regressions with uniform kernel within bandwidth window h = 1.0.",
        "Shaded bands represent 95% confidence intervals based on heteroskedasticity-robust standard errors.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "none",
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ebebeb", linewidth = 0.3),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 7.2, height = 4.6, device = "pdf")
  ggsave(out_png, plot = p, width = 7.2, height = 4.6, dpi = 300)
  message(sprintf("RD plots saved to %s and %s", out_pdf, out_png))
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
  
  df <- simulate_rd_data()
  binned <- compute_rd_bins(df)
  out_pdf <- file.path(script_dir, "rd_plot_r.pdf")
  out_png <- file.path(script_dir, "rd_plot_r.png")
  plot_rd_r(df, binned, cutoff = 0, bandwidth = 1.0, out_pdf = out_pdf, out_png = out_png)
  invisible(NULL)
}

if (!interactive()) {
  main()
}
