# Publication-Grade Coefficient and Forest Plot (R / ggplot2)
# Adheres to Gastel & Day exhibit standards

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Model Estimates Table
create_model_estimates <- function() {
  data.frame(
    spec = factor(
      c(
        "(1) Baseline OLS",
        "(2) + Industry Fixed Effects",
        "(3) + Firm Controls",
        "(4) Instrumental Variables (2SLS)",
        "(5) Subsample: Manufacturing",
        "(6) Subsample: Services",
        "(7) Subsample: High Capital Intensity",
        "(8) Subsample: Low Capital Intensity"
      ),
      levels = rev(c(
        "(1) Baseline OLS",
        "(2) + Industry Fixed Effects",
        "(3) + Firm Controls",
        "(4) Instrumental Variables (2SLS)",
        "(5) Subsample: Manufacturing",
        "(6) Subsample: Services",
        "(7) Subsample: High Capital Intensity",
        "(8) Subsample: Low Capital Intensity"
      ))
    ),
    subgroup = c(rep("Full Sample", 4), rep("By Sector", 2), rep("By Capital Tier", 2)),
    estimate = c(0.42, 0.35, 0.28, 0.49, 0.31, 0.24, 0.38, 0.18),
    se = c(0.11, 0.09, 0.08, 0.16, 0.12, 0.10, 0.11, 0.09)
  )
}

# 2. Render Exhibit
plot_coefficient_forest_r <- function(df, out_pdf = "coefficient_plot_r.pdf", out_png = "coefficient_plot_r.png") {
  df$ci90_lo <- df$estimate - 1.645 * df$se
  df$ci90_hi <- df$estimate + 1.645 * df$se
  df$ci95_lo <- df$estimate - 1.960 * df$se
  df$ci95_hi <- df$estimate + 1.960 * df$se
  df$label <- sprintf("%.2f (%.2f)", df$estimate, df$se)
  
  p <- ggplot(df, aes(x = estimate, y = spec, color = subgroup)) +
    # Null reference line
    geom_vline(xintercept = 0, linetype = "dashed", color = "#666666", linewidth = 0.5) +
    # 95% Confidence Interval (thin outer line)
    geom_errorbar(aes(xmin = ci95_lo, xmax = ci95_hi), width = 0, orientation = "y", linewidth = 0.7, alpha = 0.75) +
    # 90% Confidence Interval (thick inner line)
    geom_errorbar(aes(xmin = ci90_lo, xmax = ci90_hi), width = 0, orientation = "y", linewidth = 1.6, alpha = 0.95) +
    # Point estimates
    geom_point(size = 2.6, shape = 21, fill = "white", stroke = 1.2) +
    # Numeric text labels
    geom_text(aes(x = ci95_hi + 0.03, label = label), hjust = 0, size = 2.8, color = "#222222") +
    scale_color_manual(values = c("Full Sample" = "#0072B2", "By Sector" = "#D55E00", "By Capital Tier" = "#009E73")) +
    coord_cartesian(xlim = c(-0.15, 0.98)) +
    labs(
      x = "Estimated Coefficient with 90% and 95% Confidence Intervals",
      y = "",
      caption = paste(
        "Notes: Horizontal bars display 90% (thick inner) and 95% (thin outer) confidence intervals.",
        "Standard errors are clustered at the state-by-industry level.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "none",
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "#ebebeb", linewidth = 0.3),
      panel.grid.major.y = element_blank(),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 7.5, height = 4.8, device = "pdf")
  ggsave(out_png, plot = p, width = 7.5, height = 4.8, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  return(p)
}

main <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  dat <- create_model_estimates()
  out_pdf <- file.path(script_dir, "coefficient_plot_r.pdf")
  out_png <- file.path(script_dir, "coefficient_plot_r.png")
  plot_coefficient_forest_r(dat, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
