"""
Publication-Grade Event-Study Plot for Staggered Difference-in-Differences.
Demonstrates Two-Way Fixed Effects (TWFE) negative-weighting distortion under cohort heterogeneity,
and provides the Sun and Abraham (2021) Interaction-Weighted heterogeneity-robust correction.

Citations:
- Sun, L., & Abraham, S. (2021). Estimating dynamic treatment effects in event study designs with
  heterogeneous treatment effects. Journal of Econometrics, 225(2), 175-199.
  DOI: 10.1016/j.jeconom.2020.09.006
- Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing.
  Journal of Econometrics, 225(2), 254-277.
  DOI: 10.1016/j.jeconom.2021.03.014
- Callaway, B., & Sant'Anna, P. H. (2021). Difference-in-differences with multiple time periods.
  Journal of Econometrics, 225(2), 200-230.
  DOI: 10.1016/j.jeconom.2020.12.001
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm


def simulate_staggered_panel(n_units=400, n_periods=12, seed=42):
    """
    Simulates a panel dataset with staggered policy adoption and cohort-heterogeneous treatment effects.
    - Cohort 4: adopts at t = 4 (high initial shock, steep growth)
    - Cohort 7: adopts at t = 7 (moderate shock, moderate growth)
    - Cohort 9: adopts at t = 9 (low shock, flat growth)
    - Cohort 999: never-treated comparison units
    """
    np.random.seed(seed)
    unit_ids = np.repeat(np.arange(1, n_units + 1), n_periods)
    time_periods = np.tile(np.arange(1, n_periods + 1), n_units)
    
    cohort_assignment = np.random.choice([4, 7, 9, 999], size=n_units, p=[0.25, 0.25, 0.25, 0.25])
    cohorts = np.repeat(cohort_assignment, n_periods)
    
    df = pd.DataFrame({
        "unit": unit_ids,
        "time": time_periods,
        "cohort": cohorts
    })
    
    df["rel_time"] = np.where(df["cohort"] == 999, -999, df["time"] - df["cohort"])
    
    # Unit and Time Fixed Effects
    unit_fe = np.random.normal(5.0, 1.5, size=n_units)
    time_fe = 1.2 * np.sin(np.arange(1, n_periods + 1) / 2.0)
    
    df["alpha_i"] = unit_fe[df["unit"].values - 1]
    df["gamma_t"] = time_fe[df["time"].values - 1]
    
    # Cohort-heterogeneous treatment effects
    k_val = np.maximum(0, df["rel_time"].values)
    te = np.zeros(len(df))
    
    mask4 = (df["cohort"].values == 4) & (df["rel_time"].values >= 0)
    te[mask4] = 3.0 + 1.2 * np.log(k_val[mask4] + 1.0)
    
    mask7 = (df["cohort"].values == 7) & (df["rel_time"].values >= 0)
    te[mask7] = 1.5 + 0.4 * np.log(k_val[mask7] + 1.0)
    
    mask9 = (df["cohort"].values == 9) & (df["rel_time"].values >= 0)
    te[mask9] = 0.8 + 0.1 * np.log(k_val[mask9] + 1.0)
    
    df["true_te"] = te
    epsilon = np.random.normal(0, 1.0, size=len(df))
    df["outcome"] = df["alpha_i"] + df["gamma_t"] + te + epsilon
    
    return df


def get_cohort_treatment_effect(cohort, rel_time):
    """
    Evaluates the DGP treatment effect function tau_c(k) for cohort c at relative time k.
    For rel_time < 0, effect is 0.0 under the parallel trends assumption.
    For rel_time >= 0, effects follow cohort-specific logarithmic growth.
    """
    if rel_time < 0:
        return 0.0
    if cohort == 4:
        return 3.0 + 1.2 * np.log(rel_time + 1.0)
    elif cohort == 7:
        return 1.5 + 0.4 * np.log(rel_time + 1.0)
    elif cohort == 9:
        return 0.8 + 0.1 * np.log(rel_time + 1.0)
    return 0.0


def compute_true_effect_estimand(df, min_event=-5, max_event=5, n_periods=12):
    """
    Computes the true cohort-share-weighted average treatment effect estimand for each event time k.
    Matches the estimand targeted by the Sun and Abraham (2021) interaction-weighted estimator:
    - For interior event times (min_event < k < max_event), the cohort-share-weighted average of
      tau_c(k) over cohorts observed at k, using the realized cohort sizes in df.
    - For endpoint bins (k <= min_event and k >= max_event), the cohort-share-weighted average over
      cohorts of each cohort's mean effect across the event times that cohort contributes to the bin.
    """
    cohort_list = [4, 7, 9]
    cohort_sizes = {c: int((df["cohort"] == c).sum() // n_periods) for c in cohort_list}
    window = list(range(min_event, max_event + 1))
    estimands = {}
    
    for k in window:
        if k == min_event:
            active_c = []
            mean_effects = []
            weights = []
            for c in cohort_list:
                ks_c = [t - c for t in range(1, n_periods + 1) if (t - c) <= min_event]
                if ks_c:
                    active_c.append(c)
                    weights.append(cohort_sizes[c])
                    mean_effects.append(np.mean([get_cohort_treatment_effect(c, k_c) for k_c in ks_c]))
            total_w = sum(weights)
            estimands[k] = float(sum(w * eff for w, eff in zip(weights, mean_effects)) / total_w)
        elif k == max_event:
            active_c = []
            mean_effects = []
            weights = []
            for c in cohort_list:
                ks_c = [t - c for t in range(1, n_periods + 1) if (t - c) >= max_event]
                if ks_c:
                    active_c.append(c)
                    weights.append(cohort_sizes[c])
                    mean_effects.append(np.mean([get_cohort_treatment_effect(c, k_c) for k_c in ks_c]))
            total_w = sum(weights)
            estimands[k] = float(sum(w * eff for w, eff in zip(weights, mean_effects)) / total_w)
        else:
            active_c = []
            effects = []
            weights = []
            for c in cohort_list:
                if 1 <= c + k <= n_periods:
                    active_c.append(c)
                    weights.append(cohort_sizes[c])
                    effects.append(get_cohort_treatment_effect(c, k))
            total_w = sum(weights)
            estimands[k] = float(sum(w * eff for w, eff in zip(weights, effects)) / total_w)
            
    return estimands


def estimate_event_study(df, min_event=-5, max_event=5):
    """
    Estimates both standard TWFE (with endpoint binning) and the Sun-Abraham (2021)
    Interaction-Weighted estimator, using never-treated units as the comparison pool.
    """
    df = df.copy()
    window = list(range(min_event, max_event + 1))
    
    # --------------------------------------------------------------------------
    # 1. TWFE with Endpoint Binning
    # --------------------------------------------------------------------------
    df["twfe_lead_bin"] = ((df["cohort"] != 999) & (df["rel_time"] <= min_event)).astype(float)
    df["twfe_lag_bin"] = ((df["cohort"] != 999) & (df["rel_time"] >= max_event)).astype(float)
    
    twfe_regressors = ["twfe_lead_bin"]
    for k in window:
        if k in (min_event, max_event, -1):
            continue
        vname = f"twfe_k_{k}"
        df[vname] = ((df["cohort"] != 999) & (df["rel_time"] == k)).astype(float)
        twfe_regressors.append(vname)
    twfe_regressors.append("twfe_lag_bin")
    
    X_fe = pd.get_dummies(df[["unit", "time"]], columns=["unit", "time"], drop_first=True, dtype=float)
    X_twfe = pd.concat([df[twfe_regressors], X_fe], axis=1)
    X_twfe = sm.add_constant(X_twfe)
    
    fit_twfe = sm.OLS(df["outcome"], X_twfe).fit(cov_type="cluster", cov_kwds={"groups": df["unit"]})
    
    twfe_res = []
    for k in window:
        if k == -1:
            twfe_res.append({"event_time": -1, "est": 0.0, "se": 0.0, "ci_lo": 0.0, "ci_hi": 0.0})
        elif k == min_event:
            est = fit_twfe.params["twfe_lead_bin"]
            se = fit_twfe.bse["twfe_lead_bin"]
            twfe_res.append({"event_time": k, "est": est, "se": se, "ci_lo": est - 1.96 * se, "ci_hi": est + 1.96 * se})
        elif k == max_event:
            est = fit_twfe.params["twfe_lag_bin"]
            se = fit_twfe.bse["twfe_lag_bin"]
            twfe_res.append({"event_time": k, "est": est, "se": se, "ci_lo": est - 1.96 * se, "ci_hi": est + 1.96 * se})
        else:
            vname = f"twfe_k_{k}"
            est = fit_twfe.params[vname]
            se = fit_twfe.bse[vname]
            twfe_res.append({"event_time": k, "est": est, "se": se, "ci_lo": est - 1.96 * se, "ci_hi": est + 1.96 * se})
            
    df_twfe = pd.DataFrame(twfe_res)
    
    # --------------------------------------------------------------------------
    # 2. Sun-Abraham (2021) Interaction-Weighted Estimator
    # --------------------------------------------------------------------------
    cohort_list = [4, 7, 9]
    cohort_weights_base = {c: (df["cohort"] == c).sum() // 12 for c in cohort_list}
    sa_regressors = []
    
    for c in cohort_list:
        c_lead = f"sa_c{c}_lead_bin"
        df[c_lead] = ((df["cohort"] == c) & (df["rel_time"] <= min_event)).astype(float)
        if df[c_lead].sum() > 0:
            sa_regressors.append(c_lead)
            
        for k in window:
            if k in (min_event, max_event, -1):
                continue
            c_k = f"sa_c{c}_k_{k}"
            df[c_k] = ((df["cohort"] == c) & (df["rel_time"] == k)).astype(float)
            if df[c_k].sum() > 0:
                sa_regressors.append(c_k)
                
        c_lag = f"sa_c{c}_lag_bin"
        df[c_lag] = ((df["cohort"] == c) & (df["rel_time"] >= max_event)).astype(float)
        if df[c_lag].sum() > 0:
            sa_regressors.append(c_lag)
            
    X_sa = pd.concat([df[sa_regressors], X_fe], axis=1)
    X_sa = sm.add_constant(X_sa)
    
    fit_sa = sm.OLS(df["outcome"], X_sa).fit(cov_type="cluster", cov_kwds={"groups": df["unit"]})
    cov_matrix = fit_sa.cov_params()
    
    sa_res = []
    for k in window:
        if k == -1:
            sa_res.append({"event_time": -1, "est": 0.0, "se": 0.0, "ci_lo": 0.0, "ci_hi": 0.0})
            continue
            
        active_cohorts = []
        var_names = []
        for c in cohort_list:
            if k == min_event:
                vn = f"sa_c{c}_lead_bin"
            elif k == max_event:
                vn = f"sa_c{c}_lag_bin"
            else:
                vn = f"sa_c{c}_k_{k}"
            if vn in fit_sa.params:
                active_cohorts.append(c)
                var_names.append(vn)
                
        w_vec = np.array([cohort_weights_base[c] for c in active_cohorts], dtype=float)
        w_vec /= w_vec.sum()
        
        coef_sub = fit_sa.params[var_names].values
        point_est = float(np.sum(w_vec * coef_sub))
        
        cov_sub = cov_matrix.loc[var_names, var_names].values
        var_est = float(w_vec @ cov_sub @ w_vec)
        se_est = float(np.sqrt(np.maximum(0, var_est)))
        
        sa_res.append({
            "event_time": k,
            "est": point_est,
            "se": se_est,
            "ci_lo": point_est - 1.96 * se_est,
            "ci_hi": point_est + 1.96 * se_est
        })
        
    df_sa = pd.DataFrame(sa_res)
    return df_twfe, df_sa, fit_twfe.nobs, len(np.unique(df["unit"]))


def plot_event_study_comparison(df_twfe, df_sa, true_path, n_obs, n_clusters, out_pdf, out_png, style_path=None):
    """
    Renders two-panel publication exhibit comparing standard TWFE against the Sun-Abraham estimator.
    Direct endpoint labels replace detached legends; in-figure titles are omitted.
    """
    if style_path and Path(style_path).exists():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(7.2, 7.0), dpi=300, sharex=True)
    
    event_times = df_twfe["event_time"].values
    true_vals = [true_path[k] for k in event_times]
    
    # --------------------------------------------------------------------------
    # Panel A: TWFE Leads & Lags (Biased Baseline)
    # --------------------------------------------------------------------------
    ax1.axhline(0, color="#666666", linestyle="-", linewidth=0.7, alpha=0.8)
    ax1.axvline(-1, color="#D55E00", linestyle="--", linewidth=0.9, alpha=0.9)
    
    # True Effect trajectory
    ax1.plot(event_times, true_vals, color="#222222", linestyle=":", linewidth=1.4, zorder=2)
    
    # TWFE estimates and confidence bands
    ax1.fill_between(event_times, df_twfe["ci_lo"], df_twfe["ci_hi"], color="#0072B2", alpha=0.15)
    ax1.errorbar(
        event_times, df_twfe["est"],
        yerr=[df_twfe["est"] - df_twfe["ci_lo"], df_twfe["ci_hi"] - df_twfe["est"]],
        fmt="o", color="#0072B2", ecolor="#0072B2", elinewidth=1.1, capsize=0,
        markersize=4.8, markerfacecolor="#0072B2", markeredgecolor="#FFFFFF", markeredgewidth=0.6,
        zorder=4
    )
    
    # Direct endpoint labels
    y_twfe_end = df_twfe["est"].iloc[-1]
    y_true_end = true_vals[-1]
    if abs(y_twfe_end - y_true_end) < 0.35:
        y_true_lbl1 = max(y_twfe_end, y_true_end) + 0.18
        y_twfe_lbl = min(y_twfe_end, y_true_end) - 0.18
    else:
        y_true_lbl1 = y_true_end
        y_twfe_lbl = y_twfe_end
    ax1.text(5.2, y_twfe_lbl, "TWFE Estimate", ha="left", va="center",
             fontsize=8.5, fontweight="bold", color="#0072B2")
    ax1.text(5.2, y_true_lbl1, "True Effect", ha="left", va="center",
             fontsize=8.5, color="#222222")
    
    # Panel label outside plotting area (top-left)
    ax1.text(0.0, 1.04, "Panel A: Two-Way Fixed Effects (TWFE with Endpoint Binning)",
             transform=ax1.transAxes, fontsize=9.5, fontweight="bold", ha="left", va="bottom", color="#111111")
    
    ax1.set_ylabel("Estimated Effect", fontsize=9.0, labelpad=6)
    ax1.spines["top"].set_visible(False)
    ax1.spines["right"].set_visible(False)
    ax1.spines["left"].set_linewidth(0.6)
    ax1.spines["bottom"].set_linewidth(0.6)
    ax1.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.7)
    ax1.xaxis.grid(False)
    
    # --------------------------------------------------------------------------
    # Panel B: Sun-Abraham (2021) Interaction-Weighted (Robust)
    # --------------------------------------------------------------------------
    ax2.axhline(0, color="#666666", linestyle="-", linewidth=0.7, alpha=0.8)
    ax2.axvline(-1, color="#D55E00", linestyle="--", linewidth=0.9, alpha=0.9)
    
    # True Effect trajectory
    ax2.plot(event_times, true_vals, color="#222222", linestyle=":", linewidth=1.4, zorder=2)
    
    # Sun-Abraham estimates and confidence bands
    ax2.fill_between(event_times, df_sa["ci_lo"], df_sa["ci_hi"], color="#009E73", alpha=0.18)
    ax2.errorbar(
        event_times, df_sa["est"],
        yerr=[df_sa["est"] - df_sa["ci_lo"], df_sa["ci_hi"] - df_sa["est"]],
        fmt="s", color="#009E73", ecolor="#009E73", elinewidth=1.1, capsize=0,
        markersize=4.8, markerfacecolor="#009E73", markeredgecolor="#FFFFFF", markeredgewidth=0.6,
        zorder=4
    )
    
    # Direct endpoint labels with vertical collision avoidance
    y_sa_end = df_sa["est"].iloc[-1]
    if abs(y_sa_end - y_true_end) < 0.35:
        y_true_lbl2 = max(y_sa_end, y_true_end) + 0.18
        y_sa_lbl = min(y_sa_end, y_true_end) - 0.18
    else:
        y_true_lbl2 = y_true_end
        y_sa_lbl = y_sa_end
    ax2.text(5.2, y_sa_lbl, "Sun-Abraham (Robust)", ha="left", va="center",
             fontsize=8.5, fontweight="bold", color="#009E73")
    ax2.text(5.2, y_true_lbl2, "True Effect", ha="left", va="center",
             fontsize=8.5, color="#222222")
    
    # Panel label outside plotting area (top-left)
    ax2.text(0.0, 1.04, "Panel B: Sun and Abraham (2021) Interaction-Weighted Estimator",
             transform=ax2.transAxes, fontsize=9.5, fontweight="bold", ha="left", va="bottom", color="#111111")
    
    ax2.set_xlabel("Time Relative to Policy Adoption ($t = 0$)", fontsize=9.0, labelpad=6)
    ax2.set_ylabel("Estimated Effect", fontsize=9.0, labelpad=6)
    xtick_labels = [r"$\leq -5$" if k == -5 else (r"$5+$" if k == 5 else str(k)) for k in event_times]
    ax2.set_xticks(event_times)
    ax2.set_xticklabels(xtick_labels)
    ax2.set_xlim(-5.5, 7.8)
    
    ax2.spines["top"].set_visible(False)
    ax2.spines["right"].set_visible(False)
    ax2.spines["left"].set_linewidth(0.6)
    ax2.spines["bottom"].set_linewidth(0.6)
    ax2.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.7)
    ax2.xaxis.grid(False)
    
    # Self-contained Gastel & Day exhibit notes
    note_text = (
        "Notes: Exhibit illustrates potential distortion of Two-Way Fixed Effects (TWFE) under treatment effect heterogeneity across adoption cohorts "
        "(Sun and Abraham, 2021; Goodman-Bacon, 2021). Treatment adopted at t = 4, 7, and 9; never-treated cohort serves as control. "
        "Panel A reports standard TWFE with endpoint binning at k <= -5 and k >= 5. "
        "Panel B reports the Sun and Abraham interaction-weighted estimator, recovering the cohort-share-weighted effect across relative periods. "
        "Pointwise 95% confidence intervals reflect standard errors clustered at the unit level treating sample cohort shares as fixed. "
        f"Total observations: N = {n_obs:,}; clusters: G = {n_clusters:,}."
    )
    fig.text(0.04, -0.06, note_text, ha="left", va="top", fontsize=7.2, color="#333333", wrap=True)
    
    fig.subplots_adjust(left=0.08, right=0.92, top=0.94, bottom=0.12, hspace=0.22)
    fig.savefig(out_pdf, format="pdf", bbox_inches="tight")
    fig.savefig(out_png, dpi=300, format="png", bbox_inches="tight")
    plt.close(fig)
    print(f"Event study comparison saved: {out_pdf} and {out_png}")


def main():
    base_dir = Path(__file__).resolve().parent
    repo_root = base_dir.parent.parent
    style_file = repo_root / "templates" / "tufte.mplstyle"
    
    out_pdf = base_dir / "event_study.pdf"
    out_png = base_dir / "event_study_preview.png"
    
    df_panel = simulate_staggered_panel()
    true_eff = compute_true_effect_estimand(df_panel)
    df_twfe, df_sa, n_obs, n_clust = estimate_event_study(df_panel)
    
    plot_event_study_comparison(
        df_twfe, df_sa, true_eff, n_obs, n_clust,
        out_pdf=out_pdf, out_png=out_png,
        style_path=style_file
    )


if __name__ == "__main__":
    main()
