# Publication-Grade Event-Study Plot for Staggered Difference-in-Differences (R / ggplot2)
# Compares standard Two-Way Fixed Effects (TWFE) with Sun and Abraham (2021) Interaction-Weighted estimator
#
# Citations:
# - Sun, L., and S. Abraham (2021). Estimating dynamic treatment effects in event study designs with
#   heterogeneous treatment effects. Journal of Econometrics, 225(2), 175-199.
#   DOI: 10.1016/j.jeconom.2020.09.006
# - Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing.
#   Journal of Econometrics, 225(2), 254-277.
#   DOI: 10.1016/j.jeconom.2021.03.014
# - Callaway, B., and P. H. Sant'Anna (2021). Difference-in-differences with multiple time periods.
#   Journal of Econometrics, 225(2), 200-230.
#   DOI: 10.1016/j.jeconom.2020.12.001

suppressPackageStartupMessages({
  library(ggplot2)
  if (requireNamespace("fixest", quietly = TRUE)) {
    library(fixest)
  }
})

# 1. Simulate Staggered Panel with Cohort Heterogeneity
simulate_staggered_panel <- function(n_units = 400, n_periods = 12, seed = 42) {
  set.seed(seed)
  units <- rep(1:n_units, each = n_periods)
  time <- rep(1:n_periods, times = n_units)
  
  cohort_pool <- c(4, 7, 9, 999)
  unit_cohorts <- sample(cohort_pool, size = n_units, replace = TRUE, prob = c(0.25, 0.25, 0.25, 0.25))
  cohort <- rep(unit_cohorts, each = n_periods)
  
  df <- data.frame(unit = units, time = time, cohort = cohort)
  df$rel_time <- ifelse(df$cohort == 999, -999, df$time - df$cohort)
  
  # Unit and time fixed effects
  unit_fe <- rnorm(n_units, mean = 5.0, sd = 1.5)
  time_fe <- 1.2 * sin((1:n_periods) / 2.0)
  df$alpha_i <- unit_fe[df$unit]
  df$gamma_t <- time_fe[df$time]
  
  # Cohort-heterogeneous treatment effects
  k_val <- pmax(0, df$rel_time)
  te <- rep(0, nrow(df))
  
  m4 <- (df$cohort == 4) & (df$rel_time >= 0)
  te[m4] <- 3.0 + 1.2 * log(k_val[m4] + 1.0)
  
  m7 <- (df$cohort == 7) & (df$rel_time >= 0)
  te[m7] <- 1.5 + 0.4 * log(k_val[m7] + 1.0)
  
  m9 <- (df$cohort == 9) & (df$rel_time >= 0)
  te[m9] <- 0.8 + 0.1 * log(k_val[m9] + 1.0)
  
  df$true_te <- te
  df$outcome <- df$alpha_i + df$gamma_t + te + rnorm(nrow(df), mean = 0, sd = 1.0)
  
  return(df)
}

# 2. Compute True Cohort-Weighted Effect Estimand
compute_true_effect_estimand <- function(df, min_event = -5, max_event = 5, n_periods = 12) {
  window <- min_event:max_event
  cohort_list <- c(4, 7, 9)
  cohort_sizes <- sapply(cohort_list, function(c) sum(df$cohort == c) / n_periods)
  names(cohort_sizes) <- as.character(cohort_list)
  
  get_tau <- function(c, k) {
    if (k < 0) return(0.0)
    if (c == 4) return(3.0 + 1.2 * log(k + 1.0))
    if (c == 7) return(1.5 + 0.4 * log(k + 1.0))
    if (c == 9) return(0.8 + 0.1 * log(k + 1.0))
    return(0.0)
  }
  
  true_vals <- numeric(length(window))
  
  for (idx in seq_along(window)) {
    k <- window[idx]
    if (k == min_event) {
      weights <- c()
      mean_effs <- c()
      for (c in cohort_list) {
        ks_c <- (1:n_periods) - c
        ks_lead <- ks_c[ks_c <= min_event]
        if (length(ks_lead) > 0) {
          weights <- c(weights, cohort_sizes[as.character(c)])
          effs <- sapply(ks_lead, function(kc) get_tau(c, kc))
          mean_effs <- c(mean_effs, mean(effs))
        }
      }
      true_vals[idx] <- sum(weights * mean_effs) / sum(weights)
    } else if (k == max_event) {
      weights <- c()
      mean_effs <- c()
      for (c in cohort_list) {
        ks_c <- (1:n_periods) - c
        ks_lag <- ks_c[ks_c >= max_event]
        if (length(ks_lag) > 0) {
          weights <- c(weights, cohort_sizes[as.character(c)])
          effs <- sapply(ks_lag, function(kc) get_tau(c, kc))
          mean_effs <- c(mean_effs, mean(effs))
        }
      }
      true_vals[idx] <- sum(weights * mean_effs) / sum(weights)
    } else {
      weights <- c()
      effs <- c()
      for (c in cohort_list) {
        if ((c + k >= 1) && (c + k <= n_periods)) {
          weights <- c(weights, cohort_sizes[as.character(c)])
          effs <- c(effs, get_tau(c, k))
        }
      }
      true_vals[idx] <- sum(weights * effs) / sum(weights)
    }
  }
  
  data.frame(event_time = window, true_effect = true_vals)
}

# 3. Estimate Both TWFE and Sun-Abraham Estimators
estimate_event_study <- function(df, min_event = -5, max_event = 5) {
  window <- min_event:max_event
  
  # --- Model A: TWFE with Endpoint Binning ---
  df$twfe_lead_bin <- as.numeric(df$cohort != 999 & df$rel_time <= min_event)
  df$twfe_lag_bin <- as.numeric(df$cohort != 999 & df$rel_time >= max_event)
  
  twfe_vars <- c("twfe_lead_bin")
  for (k in window) {
    if (!(k %in% c(min_event, max_event, -1))) {
      vname <- paste0("twfe_k_", ifelse(k < 0, paste0("m", abs(k)), k))
      df[[vname]] <- as.numeric(df$cohort != 999 & df$rel_time == k)
      twfe_vars <- c(twfe_vars, vname)
    }
  }
  twfe_vars <- c(twfe_vars, "twfe_lag_bin")
  
  if (requireNamespace("fixest", quietly = TRUE)) {
    fml_twfe <- as.formula(paste("outcome ~", paste(twfe_vars, collapse = " + "), "| unit + time"))
    fit_twfe <- fixest::feols(fml_twfe, data = df, cluster = ~unit)
    co_twfe <- as.data.frame(fixest::coeftable(fit_twfe))
    
    twfe_rows <- list()
    for (k in window) {
      if (k == -1) {
        twfe_rows[[length(twfe_rows) + 1]] <- data.frame(
          event_time = -1, estimate = 0.0, se = 0.0, ci_lower = 0.0, ci_upper = 0.0,
          model = "Panel A: Two-Way Fixed Effects (TWFE)"
        )
      } else if (k == min_event) {
        est <- co_twfe["twfe_lead_bin", "Estimate"]
        se <- co_twfe["twfe_lead_bin", "Std. Error"]
        twfe_rows[[length(twfe_rows) + 1]] <- data.frame(
          event_time = k, estimate = est, se = se, ci_lower = est - 1.96 * se, ci_upper = est + 1.96 * se,
          model = "Panel A: Two-Way Fixed Effects (TWFE)"
        )
      } else if (k == max_event) {
        est <- co_twfe["twfe_lag_bin", "Estimate"]
        se <- co_twfe["twfe_lag_bin", "Std. Error"]
        twfe_rows[[length(twfe_rows) + 1]] <- data.frame(
          event_time = k, estimate = est, se = se, ci_lower = est - 1.96 * se, ci_upper = est + 1.96 * se,
          model = "Panel A: Two-Way Fixed Effects (TWFE)"
        )
      } else {
        vname <- paste0("twfe_k_", ifelse(k < 0, paste0("m", abs(k)), k))
        est <- co_twfe[vname, "Estimate"]
        se <- co_twfe[vname, "Std. Error"]
        twfe_rows[[length(twfe_rows) + 1]] <- data.frame(
          event_time = k, estimate = est, se = se, ci_lower = est - 1.96 * se, ci_upper = est + 1.96 * se,
          model = "Panel A: Two-Way Fixed Effects (TWFE)"
        )
      }
    }
    df_twfe <- do.call(rbind, twfe_rows)
    
    # --- Model B: Sun-Abraham via fixest::sunab ---
    fit_sa <- fixest::feols(
      outcome ~ sunab(cohort, time, ref.c = 999, ref.p = -1) | unit + time,
      data = df,
      cluster = ~unit
    )
    co_sa <- as.data.frame(fixest::coeftable(fit_sa))
    co_sa$vname <- rownames(co_sa)
    co_sa$event_time <- as.numeric(gsub("time::", "", co_sa$vname))
    
    sa_rows <- list()
    for (k in window) {
      if (k == -1) {
        sa_rows[[length(sa_rows) + 1]] <- data.frame(
          event_time = -1, estimate = 0.0, se = 0.0, ci_lower = 0.0, ci_upper = 0.0,
          model = "Panel B: Sun & Abraham (2021) IW"
        )
      } else {
        sub_sa <- co_sa[co_sa$event_time == k, ]
        if (nrow(sub_sa) > 0) {
          est <- sub_sa$Estimate[1]
          se <- sub_sa$`Std. Error`[1]
          sa_rows[[length(sa_rows) + 1]] <- data.frame(
            event_time = k, estimate = est, se = se, ci_lower = est - 1.96 * se, ci_upper = est + 1.96 * se,
            model = "Panel B: Sun & Abraham (2021) IW"
          )
        }
      }
    }
    df_sa <- do.call(rbind, sa_rows)
    return(rbind(df_twfe, df_sa))
  } else {
    stop("fixest package required for Sun and Abraham estimation in R.")
  }
}

# 4. Render Exhibit
render_event_study_plot <- function(estimates_df, true_df, out_pdf, out_png) {
  # Direct label coordinates at k = 5
  true_k5 <- subset(true_df, event_time == 5)$true_effect
  est_k5_twfe <- subset(estimates_df, event_time == 5 & grepl("TWFE", model))$estimate
  est_k5_sa <- subset(estimates_df, event_time == 5 & grepl("Sun", model))$estimate
  
  p <- ggplot() +
    # Zero line
    geom_hline(yintercept = 0, color = "#888888", linetype = "solid", linewidth = 0.4) +
    # Reference event time vertical dashed line
    geom_vline(xintercept = -1, color = "#444444", linetype = "dashed", linewidth = 0.5) +
    # True effect path (grey dotted line)
    geom_line(
      data = true_df,
      aes(x = event_time, y = true_effect),
      color = "#555555",
      linetype = "dotted",
      linewidth = 0.85
    ) +
    # Confidence ribbon
    geom_ribbon(
      data = estimates_df,
      aes(x = event_time, ymin = ci_lower, ymax = ci_upper),
      fill = "#0072B2",
      alpha = 0.15
    ) +
    # Point estimates line and error bars
    geom_line(
      data = estimates_df,
      aes(x = event_time, y = estimate),
      color = "#0072B2",
      linewidth = 0.7
    ) +
    geom_errorbar(
      data = estimates_df,
      aes(x = event_time, ymin = ci_lower, ymax = ci_upper),
      color = "#0072B2",
      width = 0.2,
      linewidth = 0.5
    ) +
    geom_point(
      data = estimates_df,
      aes(x = event_time, y = estimate),
      color = "#0072B2",
      size = 2.0
    ) +
    # Normalized reference point at (-1, 0)
    geom_point(
      data = data.frame(event_time = -1, estimate = 0),
      aes(x = event_time, y = estimate),
      color = "#D55E00",
      size = 2.4,
      shape = 17
    ) +
    facet_wrap(~ model, ncol = 2) +
    scale_x_continuous(breaks = seq(-5, 5, by = 1), labels = c("<= -5", -4:4, "5+")) +
    labs(
      x = "Event Time Relative to Policy Adoption (Periods)",
      y = "Estimated Treatment Effect",
      caption = paste(
        "Notes: Exhibit illustrates potential distortion of Two-Way Fixed Effects (TWFE) under treatment effect heterogeneity across adoption cohorts",
        "(Sun and Abraham, 2021; Goodman-Bacon, 2021). Treatment adopted at t = 4, 7, and 9; never-treated cohort serves as control.",
        "Panel A reports standard TWFE with endpoint binning at k <= -5 and k >= 5.",
        "Panel B reports the Sun and Abraham interaction-weighted estimator, recovering the cohort-share-weighted effect across relative periods.",
        "Pointwise 95% confidence intervals reflect standard errors clustered at the unit level treating sample cohort shares as fixed.",
        "Total observations: N = 4,800; clusters: G = 400.",
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ebebeb", linewidth = 0.3),
      strip.text = element_text(face = "bold", size = 10, hjust = 0),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 12)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 8.5, height = 4.8, device = "pdf")
  ggsave(out_png, plot = p, width = 8.5, height = 4.8, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  invisible(p)
}

# 5. Main Execution
main <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  df <- simulate_staggered_panel(n_units = 400, n_periods = 12, seed = 42)
  true_df <- compute_true_effect_estimand(df, min_event = -5, max_event = 5)
  estimates_df <- estimate_event_study(df, min_event = -5, max_event = 5)
  
  out_pdf <- file.path(script_dir, "event_study_r.pdf")
  out_png <- file.path(script_dir, "event_study_r.png")
  
  render_event_study_plot(estimates_df, true_df, out_pdf, out_png)
  invisible(NULL)
}

if (!interactive()) {
  main()
}
