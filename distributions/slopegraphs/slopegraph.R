# Publication-Grade Slopegraph (R / ggplot2)
# Adheres to Edward Tufte's table-graphic principles in The Visual Display of Quantitative Information (1983)
#
# Citations:
# - Tufte, E. R. (1983). The Visual Display of Quantitative Information. Cheshire, CT: Graphics Press.

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. State Reform Dataset
create_slope_data <- function() {
  data.frame(
    state = c("California", "New York", "New Jersey", "Massachusetts", "Illinois", "Ohio", "Texas", "Florida"),
    pre = c(11.2, 10.8, 9.4, 8.9, 8.1, 7.4, 6.8, 5.9),
    post = c(13.8, 12.9, 11.1, 9.2, 7.9, 7.1, 6.5, 5.7),
    status = c("Treated", "Treated", "Treated", "Control", "Control", "Control", "Control", "Control")
  )
}

# 2. Render Slopegraph
plot_slopegraph_r <- function(df, out_pdf = "slopegraph_r.pdf", out_png = "slopegraph_r.png") {
  df$label_left <- sprintf("%s  %.1f%%", df$state, df$pre)
  df$label_right <- sprintf("%.1f%%  %s", df$post, df$state)
  
  df_long <- data.frame(
    state = rep(df$state, 2),
    year = rep(c(0, 1), each = nrow(df)),
    value = c(df$pre, df$post),
    status = rep(df$status, 2)
  )
  
  p <- ggplot() +
    # Vertical time axes
    geom_vline(xintercept = 0, linetype = "dotted", color = "#CCCCCC", linewidth = 0.5) +
    geom_vline(xintercept = 1, linetype = "dotted", color = "#CCCCCC", linewidth = 0.5) +
    # Trajectory lines
    geom_line(
      data = df_long,
      aes(x = year, y = value, group = state, color = status, linewidth = status, alpha = status)
    ) +
    # End points
    geom_point(
      data = df_long,
      aes(x = year, y = value, color = status, size = status)
    ) +
    # Left text labels
    geom_text(
      data = df,
      aes(x = -0.05, y = pre, label = label_left, color = status),
      hjust = 1, size = 3.0
    ) +
    # Right text labels
    geom_text(
      data = df,
      aes(x = 1.05, y = post, label = label_right, color = status),
      hjust = 0, size = 3.0
    ) +
    scale_color_manual(values = c("Treated" = "#D55E00", "Control" = "#777777")) +
    scale_linewidth_manual(values = c("Treated" = 1.1, "Control" = 0.6)) +
    scale_alpha_manual(values = c("Treated" = 1.0, "Control" = 0.75)) +
    scale_size_manual(values = c("Treated" = 2.0, "Control" = 1.3)) +
    scale_x_continuous(
      breaks = c(0, 1),
      labels = c("Pre-Reform\n(2014)", "Post-Reform\n(2020)"),
      limits = c(-0.55, 1.55),
      position = "top"
    ) +
    labs(
      y = "",
      x = "",
      caption = paste(
        "Notes: Tufte (1983) slopegraph exhibit. Vermillion trajectories denote treated jurisdictions.",
        "Gray trajectories denote control jurisdictions. Values reflect effective state tax revenue share.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "none",
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_text(face = "bold", size = rel(1.0), color = "#111111"),
      panel.grid = element_blank(),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 12)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 6.8, height = 6.0, device = "pdf")
  ggsave(out_png, plot = p, width = 6.8, height = 6.0, dpi = 300)
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
  
  dat <- create_slope_data()
  out_pdf <- file.path(script_dir, "slopegraph_r.pdf")
  out_png <- file.path(script_dir, "slopegraph_r.png")
  plot_slopegraph_r(dat, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
