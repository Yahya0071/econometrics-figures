"""
Publication-Grade Coefficient and Forest Plots in Python.
Adheres to Gastel & Day exhibit standards.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def create_synthetic_model_estimates():
    """
    Constructs sample empirical estimates across regression specifications and subsamples.
    """
    models = [
        {"spec": "(1) Baseline OLS", "subgroup": "Full Sample", "estimate": 0.42, "se": 0.11},
        {"spec": "(2) + Industry Fixed Effects", "subgroup": "Full Sample", "estimate": 0.35, "se": 0.09},
        {"spec": "(3) + Firm Controls", "subgroup": "Full Sample", "estimate": 0.28, "se": 0.08},
        {"spec": "(4) Instrumental Variables (2SLS)", "subgroup": "Full Sample", "estimate": 0.49, "se": 0.16},
        {"spec": "(5) Subsample: Manufacturing", "subgroup": "By Sector", "estimate": 0.31, "se": 0.12},
        {"spec": "(6) Subsample: Services", "subgroup": "By Sector", "estimate": 0.24, "se": 0.10},
        {"spec": "(7) Subsample: High Capital Intensity", "subgroup": "By Capital Tier", "estimate": 0.38, "se": 0.11},
        {"spec": "(8) Subsample: Low Capital Intensity", "subgroup": "By Capital Tier", "estimate": 0.18, "se": 0.09},
    ]
    
    df = pd.DataFrame(models)
    df["ci90_lo"] = df["estimate"] - 1.645 * df["se"]
    df["ci90_hi"] = df["estimate"] + 1.645 * df["se"]
    df["ci95_lo"] = df["estimate"] - 1.960 * df["se"]
    df["ci95_hi"] = df["estimate"] + 1.960 * df["se"]
    
    return df


def plot_coefficient_forest(df, out_png=None, out_pdf=None, style_path=None):
    """
    Renders publication-grade coefficient plot with dual confidence intervals (90% and 95%).
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("seaborn-v0_8-whitegrid" if "seaborn-v0_8-whitegrid" in plt.style.available else "default")
        
    n_estimates = len(df)
    y_positions = np.arange(n_estimates)[::-1]
    
    fig, ax = plt.subplots(figsize=(7.8, 5.2), dpi=300)
    
    # Null hypothesis zero reference line
    ax.axvline(0, color="#666666", linestyle="--", linewidth=0.9, alpha=0.8)
    ax.text(0.01, -0.7, "Null ($\\beta = 0$)", color="#666666", fontsize=7.5, ha="left", va="bottom")
    
    color_map = {
        "Full Sample": "#0072B2",
        "By Sector": "#D55E00",
        "By Capital Tier": "#009E73"
    }
    
    for idx, row in df.iterrows():
        y = y_positions[idx]
        c = color_map.get(row["subgroup"], "#0072B2")
        
        # 95% Confidence Interval (thin outer line)
        ax.plot([row["ci95_lo"], row["ci95_hi"]], [y, y], color=c, linewidth=1.2, alpha=0.75, solid_capstyle="round")
        
        # 90% Confidence Interval (thick inner line)
        ax.plot([row["ci90_lo"], row["ci90_hi"]], [y, y], color=c, linewidth=2.8, alpha=0.95, solid_capstyle="round")
        
        # Point estimate marker
        ax.scatter(row["estimate"], y, color=c, s=42, zorder=5, edgecolors="#FFFFFF", linewidth=0.8)
        
        # Numeric label of point estimate and SE to the right
        stat_str = f"{row['estimate']:.2f} ({row['se']:.2f})"
        ax.text(row["ci95_hi"] + 0.03, y, stat_str, va="center", ha="left", fontsize=8.0, color="#222222")
        
    ax.set_yticks(y_positions)
    ax.set_yticklabels(df["spec"], fontsize=8.5)
    
    # Subgroup dividers separating specification groups
    ax.axhline(3.5, color="#CCCCCC", linestyle=":", linewidth=0.8, zorder=1)
    ax.axhline(1.5, color="#CCCCCC", linestyle=":", linewidth=0.8, zorder=1)
    
    # Subgroup headers inside the right margin
    ax.text(0.95, 7.35, "Full Sample Specifications", color="#0072B2", fontsize=8.0, fontweight="bold", ha="right", va="center")
    ax.text(0.95, 3.25, "Sector Subsamples", color="#D55E00", fontsize=8.0, fontweight="bold", ha="right", va="center")
    ax.text(0.95, 1.25, "Capital Subsamples", color="#009E73", fontsize=8.0, fontweight="bold", ha="right", va="center")
    
    ax.set_xlabel("Estimated Coefficient ($\\beta$) with 90% and 95% Confidence Intervals", fontsize=9.0, labelpad=8)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#222222")
    ax.spines["bottom"].set_color("#222222")
    ax.xaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.8)
    ax.yaxis.grid(False)
    
    ax.set_xlim(-0.15, 0.98)
    ax.set_ylim(-1.0, n_estimates - 0.2)
    
    # Gastel & Day self-contained note below exhibit
    note_text = (
        "Notes: Figure reports point estimates with 90% (thick inner bar) and 95% (thin outer bar) confidence intervals. "
        "Standard errors are clustered at the state-by-industry level. Values to the right of each interval show point estimates "
        "with standard errors in parentheses."
    )
    fig.text(0.04, -0.05, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.18, top=0.96, left=0.38, right=0.95)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    style_file = base_dir.parent.parent / "templates" / "academic.mplstyle"
    out_png = base_dir / "coefficient_plot_preview.png"
    out_pdf = base_dir / "coefficient_plot.pdf"
    
    data = create_synthetic_model_estimates()
    plot_coefficient_forest(data, out_png=out_png, out_pdf=out_pdf, style_path=style_file)
    print(f"Coefficient plots saved to {out_png} and {out_pdf}")
