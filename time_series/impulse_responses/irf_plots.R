# Publication-Grade Impulse Response Function Plot (R / ggplot2)
# Adheres to Gastel & Day exhibit standards and Jorda (2005) Local Projections
#
# Citations:
# - Jorda, O. (2005). Estimation and Inference of Impulse Responses by Local Projections.
#   American Economic Review, 95(1), 161-182.
#   DOI: 10.1257/0002828053828518

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Simulate Macro Time Series
simulate_macro_ts <- function(n_periods = 250, seed = 42) {
  set.seed(seed)
  shock <- rnorm(n_periods, 0, 1.0)
  pi <- numeric(n_periods)
  y <- numeric(n_periods)
  
  for (t in 2:n_periods) {
    pi[t] <- 0.65 * pi[t - 1] - 0.45 * shock[t - 1] + rnorm(1, 0, 0.4)
    y[t] <- 0.70 * y[t - 1] - 0.60 * shock[t - 1] + 0.20 * pi[t - 1] + rnorm(1, 0, 0.5)
  }
  
  data.frame(time = 1:n_periods, shock = shock, y = y, pi = pi)
}

# 2. Estimate Local Projections
estimate_lp <- function(df, max_horizon = 12) {
  n <- nrow(df)
  results <- list()
  
  for (h in 0:max_horizon) {
    y_lead <- c(df$y[(1 + h):n], rep(NA, h))
    shock_t <- df$shock
    
    valid <- !is.na(y_lead)
    fit <- lm(y_lead[valid] ~ shock_t[valid])
    
    coef_val <- coef(fit)["shock_t[valid]"]
    se_val <- summary(fit)$coefficients["shock_t[valid]", "Std. Error"]
    
    results[[h + 1]] <- data.frame(
      horizon = h,
      estimate = coef_val,
      se = se_val,
      ci68_lo = coef_val - 1.0 * se_val,
      ci68_hi = coef_val + 1.0 * se_val,
      ci95_lo = coef_val - 1.96 * se_val,
      ci95_hi = coef_val + 1.96 * se_val
    )
  }
  
  do.call(rbind, results)
}

# 3. Render Exhibit
plot_irf_r <- function(irf_df, out_pdf = "irf_plot_r.pdf", out_png = "irf_plot_r.png") {
  last_row <- tail(irf_df, 1)
  
  p <- ggplot(irf_df, aes(x = horizon, y = estimate)) +
    # Null reference line
    geom_hline(yintercept = 0, linetype = "solid", color = "#666666", linewidth = 0.4) +
    # 95% Confidence Band
    geom_ribbon(aes(ymin = ci95_lo, ymax = ci95_hi), fill = "#0072B2", alpha = 0.15) +
    # 68% Confidence Band (1 standard error)
    geom_ribbon(aes(ymin = ci68_lo, ymax = ci68_hi), fill = "#0072B2", alpha = 0.25) +
    # IRF Trajectory
    geom_line(color = "#0072B2", linewidth = 1.0) +
    geom_point(color = "#0072B2", size = 2.0) +
    # Direct endpoint labels
    annotate("text", x = last_row$horizon + 0.3, y = last_row$estimate, label = "Local Projection IRF", color = "#0072B2", size = 3.0, fontface = "bold", hjust = 0) +
    annotate("text", x = last_row$horizon + 0.3, y = last_row$ci68_hi, label = "68% Band", color = "#0072B2", size = 2.6, hjust = 0) +
    annotate("text", x = last_row$horizon + 0.3, y = last_row$ci95_hi, label = "95% Band", color = "#555555", size = 2.6, hjust = 0) +
    scale_x_continuous(breaks = irf_df$horizon, limits = c(0, last_row$horizon + 3.0)) +
    labs(
      x = "Quarters Post Shock (h)",
      y = "Response of Output Gap (%)",
      caption = "Notes: Point estimates from Jorda (2005) local projections. Dark ribbon denotes 68% (one standard error) band; light ribbon denotes 95% band."
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ebebeb", linewidth = 0.3),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
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
  
  ts_data <- simulate_macro_ts()
  irf_res <- estimate_lp(ts_data)
  out_pdf <- file.path(script_dir, "irf_plot_r.pdf")
  out_png <- file.path(script_dir, "irf_plot_r.png")
  plot_irf_r(irf_res, out_pdf, out_png)
  invisible(NULL)
}

if (!interactive()) {
  main()
}
