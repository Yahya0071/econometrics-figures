# Tufte Minimalist Boxplot and Rug Plot (R / ggplot2)
# Adheres to Edward Tufte's principles in The Visual Display of Quantitative Information (1983)
#
# Citations:
# - Tufte, E. R. (1983). The Visual Display of Quantitative Information. Cheshire, CT: Graphics Press.

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Simulate Subgroup Microdata
simulate_tufte_data <- function(n_per_group = 300, seed = 42) {
  set.seed(seed)
  categories <- c("1. High School", "2. Some College", "3. Bachelor Degree", "4. Graduate Degree")
  means <- c(16.5, 21.0, 32.5, 46.0)
  sds <- c(3.5, 5.0, 8.5, 12.0)
  
  df_list <- list()
  for (i in seq_along(categories)) {
    wages <- rlnorm(n_per_group, meanlog = log(means[i]), sdlog = sds[i] / means[i])
    df_list[[i]] <- data.frame(education = categories[i], wage = wages)
  }
  do.call(rbind, df_list)
}

# 2. Render Tufte Minimal Boxplot Exhibit
plot_tufte_boxplot_r <- function(df, out_pdf = "tufte_boxplot_r.pdf", out_png = "tufte_boxplot_r.png") {
  stats_list <- lapply(split(df, df$education), function(sub) {
    p <- quantile(sub$wage, probs = c(0.025, 0.25, 0.50, 0.75, 0.975))
    data.frame(
      education = sub$education[1],
      q025 = p[1], q25 = p[2], q50 = p[3], q75 = p[4], q975 = p[5]
    )
  })
  stats_df <- do.call(rbind, stats_list)
  
  p <- ggplot(stats_df, aes(x = education)) +
    # Lower whisker: 2.5th to 25th percentile
    geom_linerange(aes(ymin = q025, ymax = q25), linewidth = 0.6, color = "#222222") +
    # Upper whisker: 75th to 97.5th percentile
    geom_linerange(aes(ymin = q75, ymax = q975), linewidth = 0.6, color = "#222222") +
    # Median marker: discrete point in the center of the IQR gap
    geom_point(aes(y = q50), size = 2.2, color = "#0072B2") +
    labs(
      x = "",
      y = "Hourly Wage ($USD)",
      caption = paste(
        "Notes: Tufte (1983) minimal boxplot design. Central point indicates the median.",
        "White space gap spans the interquartile range (25th to 75th percentiles). Outer lines extend to 2.5th and 97.5th percentiles.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      panel.grid = element_blank(),
      axis.line.y = element_line(color = "#333333", linewidth = 0.5),
      axis.line.x = element_blank(),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 7.0, height = 4.5, device = "pdf")
  ggsave(out_png, plot = p, width = 7.0, height = 4.5, dpi = 300)
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
  
  dat <- simulate_tufte_data()
  out_pdf <- file.path(script_dir, "tufte_boxplot_r.pdf")
  out_png <- file.path(script_dir, "tufte_boxplot_r.png")
  plot_tufte_boxplot_r(dat, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
