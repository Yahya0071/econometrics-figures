# Publication-Grade Synthetic Control Plots (R / ggplot2)
# Adheres to Gastel & Day exhibit standards and Abadie, Diamond, and Hainmueller (2010)
#
# Citations:
# - Abadie, A., A. Diamond, and J. Hainmueller (2010). Synthetic Control Methods for
#   Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program.
#   Journal of the American Statistical Association, 105(490), 493-505.
#   DOI: 10.1198/jasa.2009.ap08746

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Simulate Synthetic Panel
simulate_sc_data <- function(n_donors = 20, n_pre = 15, n_post = 10, seed = 42) {
  set.seed(seed)
  n_total <- n_pre + n_post
  time <- 1:n_total
  
  factor1 <- sin(time / 3) * 2
  factor2 <- 0.3 * time
  
  donors <- matrix(0, nrow = n_total, ncol = n_donors)
  for (j in 1:n_donors) {
    loadings <- runif(2, 0.2, 1.2)
    noise <- rnorm(n_total, 0, 0.4)
    donors[, j] <- 5 + loadings[1] * factor1 + loadings[2] * factor2 + noise
  }
  
  true_w <- c(0.4, 0.3, 0.2, 0.1, rep(0, n_donors - 4))
  treated <- donors %*% true_w + rnorm(n_total, 0, 0.3)
  
  treated[-(1:n_pre)] <- treated[-(1:n_pre)] + 1.2 + 0.3 * (1:n_post)
  
  list(time = time, treated = as.vector(treated), donors = donors, n_pre = n_pre)
}

# 2. Fit Constrained Synthetic Weights via Quadratic Programming
fit_synth_weights <- function(treated, donors, n_pre) {
  n_donors <- ncol(donors)
  Y1_pre <- treated[1:n_pre]
  Y0_pre <- donors[1:n_pre, ]
  
  dvec <- t(Y0_pre) %*% Y1_pre
  Dmat <- t(Y0_pre) %*% Y0_pre + diag(1e-6, n_donors)
  
  Amat <- cbind(rep(1, n_donors), diag(1, n_donors))
  bvec <- c(1, rep(0, n_donors))
  
  if (requireNamespace("quadprog", quietly = TRUE)) {
    qp <- quadprog::solve.QP(Dmat, dvec, Amat, bvec, meq = 1)
    w <- qp$solution
  } else {
    w <- rep(1 / n_donors, n_donors)
  }
  
  synth <- donors %*% w
  gap <- treated - synth
  list(weights = w, synthetic = as.vector(synth), gap = as.vector(gap))
}

# 3. Render Exhibit
plot_sc_r <- function(sim_data, res_sc, out_pdf = "synthetic_control_r.pdf", out_png = "synthetic_control_r.png") {
  time <- sim_data$time
  n_pre <- sim_data$n_pre
  
  # Format for faceted ggplot2
  df_panel_a <- data.frame(
    time = rep(time, 2),
    value = c(sim_data$treated, res_sc$synthetic),
    series = rep(c("Treated", "Synthetic"), each = length(time)),
    panel = "Panel A: Outcome Trajectories"
  )
  
  df_panel_b <- data.frame(
    time = time,
    value = res_sc$gap,
    series = "Treated Gap",
    panel = "Panel B: Estimated Treatment Gap"
  )
  
  df_combined <- rbind(df_panel_a, df_panel_b)
  
  p <- ggplot(df_combined, aes(x = time, y = value, color = series, linetype = series)) +
    geom_vline(xintercept = n_pre, linetype = "dashed", color = "#666666", linewidth = 0.5) +
    geom_line(linewidth = 0.9) +
    facet_wrap(~ panel, scales = "free_y", ncol = 2) +
    scale_color_manual(
      values = c("Treated" = "#D55E00", "Synthetic" = "#0072B2", "Treated Gap" = "#D55E00")
    ) +
    scale_linetype_manual(
      values = c("Treated" = "solid", "Synthetic" = "dashed", "Treated Gap" = "solid")
    ) +
    labs(
      x = "Time Period",
      y = "Outcome / Treatment Gap",
      color = "",
      linetype = "",
      caption = paste(
        "Notes: Panel A compares actual outcome trajectory with synthetic counterfactual constructed via pre-treatment constrained optimization.",
        "Panel B displays estimated treatment gap (actual minus synthetic). Dashed vertical line indicates policy intervention at t = 15.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      legend.position = "top",
      legend.justification = "right",
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ebebeb", linewidth = 0.3),
      strip.text = element_text(face = "bold", size = 9.5, hjust = 0),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 9.5, height = 4.6, device = "pdf")
  ggsave(out_png, plot = p, width = 9.5, height = 4.6, dpi = 300)
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
  
  dat <- simulate_sc_data()
  sol <- fit_synth_weights(dat$treated, dat$donors, dat$n_pre)
  out_pdf <- file.path(script_dir, "synthetic_control_r.pdf")
  out_png <- file.path(script_dir, "synthetic_control_r.png")
  plot_sc_r(dat, sol, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
