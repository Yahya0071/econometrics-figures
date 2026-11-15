"""
Publication-Grade Binned Scatter Plots (Binscatter) in Python.
Adheres to Gastel & Day exhibit standards and Cattaneo, Crump, Farrell, and Feng (2024).

Citations:
- Cattaneo, M. D., R. K. Crump, M. H. Farrell, and Y. Feng (2024). On Binscatter.
  American Economic Review, 114(5), 1488-1514.
  DOI: 10.1257/aer.20221576
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm


def simulate_binscatter_data(n=5000, seed=42):
    """
    Generates synthetic microdata with two distinct demographic or policy groups.
    """
    np.random.seed(seed)
    x = np.random.normal(loc=10.0, scale=1.2, size=n)
    group = np.random.binomial(1, 0.5, size=n)
    
    beta_0 = 2.0 - 0.8 * group
    beta_1 = 0.65 + 0.17 * group
    
    noise = np.random.normal(0, 0.9, size=n)
    y = beta_0 + beta_1 * x + noise
    
    return pd.DataFrame({"x": x, "y": y, "group": group})


def compute_group_bins(df, group_val, n_bins=20):
    """
    Constructs equal-sized quantile bins and computes mean coordinates and regression line.
    """
    sub_df = df[df["group"] == group_val].copy()
    
    sub_df["bin"] = pd.qcut(sub_df["x"], q=n_bins, duplicates="drop")
    
    binned = sub_df.groupby("bin", observed=True).agg(
        x_mean=("x", "mean"),
        y_mean=("y", "mean")
    ).dropna().reset_index()
    
    X = sm.add_constant(sub_df["x"])
    model = sm.OLS(sub_df["y"], X).fit(cov_type="HC1")
    slope = model.params["x"]
    se = model.bse["x"]
    r2 = model.rsquared
    
    x_grid = np.linspace(sub_df["x"].quantile(0.01), sub_df["x"].quantile(0.99), 100)
    y_pred = model.predict(sm.add_constant(x_grid))
    
    return binned, x_grid, y_pred, slope, se, r2


def plot_binscatter(df, out_png=None, out_pdf=None, style_path=None):
    """
    Renders publication-grade two-group binscatter plot with direct endpoint labeling.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("seaborn-v0_8-whitegrid" if "seaborn-v0_8-whitegrid" in plt.style.available else "default")
        
    fig, ax = plt.subplots(figsize=(7.5, 4.8), dpi=300)
    
    bins0, grid0, pred0, slope0, se0, r2_0 = compute_group_bins(df, group_val=0, n_bins=20)
    bins1, grid1, pred1, slope1, se1, r2_1 = compute_group_bins(df, group_val=1, n_bins=20)
    
    # Plot Group 0 (Group A)
    ax.scatter(
        bins0["x_mean"],
        bins0["y_mean"],
        color="#0072B2",
        s=34,
        alpha=0.85,
        edgecolors="none"
    )
    ax.plot(grid0, pred0, color="#0072B2", linewidth=1.6)
    
    # Plot Group 1 (Group B)
    ax.scatter(
        bins1["x_mean"],
        bins1["y_mean"],
        color="#D55E00",
        s=34,
        alpha=0.85,
        edgecolors="none"
    )
    ax.plot(grid1, pred1, color="#D55E00", linewidth=1.6)
    
    # Direct endpoint labels
    ax.text(
        grid0[-1] + 0.10,
        pred0[-1],
        f"Group A\n$\\hat{{\\beta}} = {slope0:.3f}$ ({se0:.3f})",
        color="#0072B2",
        fontsize=8.5,
        fontweight="semibold",
        verticalalignment="center"
    )
    ax.text(
        grid1[-1] + 0.10,
        pred1[-1],
        f"Group B\n$\\hat{{\\beta}} = {slope1:.3f}$ ({se1:.3f})",
        color="#D55E00",
        fontsize=8.5,
        fontweight="semibold",
        verticalalignment="center"
    )
    
    ax.set_xlabel("Log Parental Income ($X_i$)", fontsize=9.5, labelpad=6)
    ax.set_ylabel("Standardized Student Test Score ($Y_i$)", fontsize=9.5, labelpad=6)
    ax.set_xlim(df["x"].quantile(0.005) - 0.2, df["x"].quantile(0.995) + 1.8)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#222222")
    ax.spines["bottom"].set_color("#222222")
    ax.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.8)
    ax.xaxis.grid(False)
    
    # Gastel & Day self-contained note below figure
    note_text = (
        f"Notes: Observations are partitioned into 20 equal-sized quantile bins per demographic cohort. "
        f"Scatter markers display mean coordinates within each quantile bin. Solid lines represent linear OLS regression "
        f"fits on underlying microdata. Heteroskedasticity-robust standard errors in parentheses. Total sample size: N = {len(df):,}."
    )
    fig.text(0.04, -0.06, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.20, top=0.95, left=0.10, right=0.85)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    style_file = base_dir.parent.parent / "templates" / "academic.mplstyle"
    out_png = base_dir / "binscatter_preview.png"
    out_pdf = base_dir / "binscatter.pdf"
    
    data = simulate_binscatter_data()
    plot_binscatter(data, out_png=out_png, out_pdf=out_pdf, style_path=style_file)
    print(f"Binscatter plots saved to {out_png} and {out_pdf}")
