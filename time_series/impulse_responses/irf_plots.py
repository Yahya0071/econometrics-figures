"""
Publication-Grade Impulse Response Function (IRF) Plots in Python.
Adheres to Gastel & Day exhibit standards and Jorda (2005) Local Projections.

Citations:
- Jorda, O. (2005). Estimation and Inference of Impulse Responses by Local Projections.
  American Economic Review, 95(1), 161-182.
  DOI: 10.1257/0002828053828518
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm


def simulate_macro_time_series(n_periods=250, seed=42):
    """
    Generates synthetic macroeconomic quarterly time series with an exogenous policy shock.
    """
    np.random.seed(seed)
    shock = np.random.normal(0, 1.0, size=n_periods)
    
    pi = np.zeros(n_periods)
    y = np.zeros(n_periods)
    
    for t in range(1, n_periods):
        pi[t] = 0.65 * pi[t - 1] - 0.45 * shock[t - 1] + np.random.normal(0, 0.4)
        y[t] = 0.70 * y[t - 1] - 0.60 * shock[t - 1] + 0.20 * pi[t - 1] + np.random.normal(0, 0.5)
        
    return pd.DataFrame({"time": np.arange(1, n_periods + 1), "shock": shock, "pi": pi, "y": y})


def estimate_local_projections(df, response_var="y", shock_var="shock", max_horizon=12):
    """
    Estimates Jorda (2005) local projections with Newey-West HAC standard errors:
    Y_{t+h} = alpha_h + beta_h * Shock_t + epsilon_{t+h}
    """
    irf_results = []
    
    for h in range(max_horizon + 1):
        df_h = df.copy()
        df_h["y_lead"] = df_h[response_var].shift(-h)
        
        valid = df_h.dropna(subset=["y_lead", shock_var])
        
        X = sm.add_constant(valid[[shock_var]])
        model = sm.OLS(valid["y_lead"], X).fit(cov_type="HAC", cov_kwds={"maxlags": h + 1})
        
        coef = model.params[shock_var]
        se = model.bse[shock_var]
        
        irf_results.append({
            "horizon": h,
            "estimate": coef,
            "se": se,
            "ci68_lo": coef - 1.0 * se,
            "ci68_hi": coef + 1.0 * se,
            "ci95_lo": coef - 1.96 * se,
            "ci95_hi": coef + 1.96 * se
        })
        
    return pd.DataFrame(irf_results)


def plot_irf(irf_df, response_label="Output Gap (%)", out_png=None, out_pdf=None, style_path=None):
    """
    Renders publication-grade impulse response exhibit with dual confidence bands (68% and 95%).
    Exports both vector PDF and 300 DPI raster PNG with direct labels.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("seaborn-v0_8-whitegrid" if "seaborn-v0_8-whitegrid" in plt.style.available else "default")
        
    fig, ax = plt.subplots(figsize=(7.5, 4.8), dpi=300)
    
    h = irf_df["horizon"]
    est = irf_df["estimate"]
    
    # Null reference line
    ax.axhline(0, color="#666666", linestyle="-", linewidth=0.8, alpha=0.8)
    
    # 95% Confidence Band (lighter outer ribbon)
    ax.fill_between(
        h, irf_df["ci95_lo"], irf_df["ci95_hi"],
        color="#0072B2", alpha=0.15
    )
    
    # 68% Confidence Band (darker inner ribbon, 1 standard error)
    ax.fill_between(
        h, irf_df["ci68_lo"], irf_df["ci68_hi"],
        color="#0072B2", alpha=0.25
    )
    
    # IRF Trajectory Line and markers
    ax.plot(h, est, color="#0072B2", linewidth=2.0, marker="o", markersize=4.5)
    
    # Direct endpoint labels at horizon h = 12
    last_h = h.iloc[-1]
    ax.text(last_h + 0.25, est.iloc[-1], "Local Projection IRF", color="#0072B2", fontsize=8.5, fontweight="bold", va="center")
    ax.text(last_h + 0.25, irf_df["ci68_hi"].iloc[-1], "68% Band (1 SE)", color="#0072B2", fontsize=7.5, va="center")
    ax.text(last_h + 0.25, irf_df["ci95_hi"].iloc[-1], "95% Band", color="#555555", fontsize=7.5, va="center")
    
    ax.set_xlabel("Quarters Post Shock ($h$)", fontsize=9.5, labelpad=6)
    ax.set_ylabel(f"Response of {response_label}", fontsize=9.5, labelpad=6)
    
    ax.set_xticks(h)
    ax.set_xlim(0, last_h + 2.8)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#222222")
    ax.spines["bottom"].set_color("#222222")
    ax.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.8)
    ax.xaxis.grid(False)
    
    # Self-contained note below exhibit
    note_text = (
        "Notes: Solid line traces point estimates from Jorda (2005) local projections over a 12-quarter horizon. "
        "Dark shaded ribbon indicates 68% (one standard error) confidence band; light shaded ribbon indicates 95% confidence band. "
        "Standard errors are estimated using Newey-West (HAC) adjustment with horizon-dependent lag length h + 1."
    )
    fig.text(0.04, -0.06, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.20, top=0.95, left=0.10, right=0.82)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    style_file = base_dir.parent.parent / "templates" / "academic.mplstyle"
    out_png = base_dir / "irf_preview.png"
    out_pdf = base_dir / "irf_plot.pdf"
    
    macro_data = simulate_macro_time_series()
    irf_data = estimate_local_projections(macro_data, response_var="y", shock_var="shock", max_horizon=12)
    plot_irf(irf_data, out_png=out_png, out_pdf=out_pdf, style_path=style_file)
    print(f"IRF plots saved to {out_png} and {out_pdf}")
