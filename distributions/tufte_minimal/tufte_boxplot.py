"""
Tufte Minimalist Boxplot and Dot-Dash Scatter Plot in Python.
Adheres to Edward Tufte's principles in The Visual Display of Quantitative Information (1983).
Maximizes data-ink ratio by using white space to convey IQR and marginal rugs for density.

Citations:
- Tufte, E. R. (1983). The Visual Display of Quantitative Information. Cheshire, CT: Graphics Press.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def simulate_subgroup_distributions(n_per_group=300, seed=42):
    """
    Simulates wage microdata across four educational attainment categories.
    """
    np.random.seed(seed)
    categories = [
        "1. High School",
        "2. Some College",
        "3. Bachelor Degree",
        "4. Graduate Degree"
    ]
    
    means = [16.5, 21.0, 32.5, 46.0]
    sds = [3.5, 5.0, 8.5, 12.0]
    
    records = []
    for cat, m, s in zip(categories, means, sds):
        wages = np.random.lognormal(mean=np.log(m), sigma=s / m, size=n_per_group)
        for w in wages:
            records.append({"education": cat, "wage": w})
            
    return pd.DataFrame(records)


def plot_tufte_minimal_boxplot(df, out_png=None, out_pdf=None, style_path=None):
    """
    Renders Tufte's minimal midgap boxplot:
    - Dot at median
    - White-space empty gap between 25th and 75th percentiles (IQR)
    - Thin whisker line from 2.5th to 25th percentile, and 75th to 97.5th percentile
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    categories = df["education"].unique()
    n_cats = len(categories)
    
    fig, ax = plt.subplots(figsize=(7.2, 4.6), dpi=300)
    
    x_positions = np.arange(1, n_cats + 1)
    
    for idx, cat in enumerate(categories):
        sub_wages = df[df["education"] == cat]["wage"].values
        q0, q25, q50, q75, q100 = np.percentile(sub_wages, [2.5, 25, 50, 75, 97.5])
        x = x_positions[idx]
        
        # Lower whisker: 2.5th percentile to 25th percentile
        ax.plot([x, x], [q0, q25], color="#222222", linewidth=1.1, solid_capstyle="round")
        
        # Upper whisker: 75th percentile to 97.5th percentile
        ax.plot([x, x], [q75, q100], color="#222222", linewidth=1.1, solid_capstyle="round")
        
        # Median: discrete point in the center of the IQR gap
        ax.scatter([x], [q50], color="#0072B2", s=30, zorder=4, edgecolors="none")
        
        # Horizontal tick at median
        ax.plot([x - 0.08, x + 0.08], [q50, q50], color="#0072B2", linewidth=1.0)
        
    ax.set_xticks(x_positions)
    ax.set_xticklabels(categories, fontsize=9.0)
    
    all_wages = df["wage"].values
    y_min, y_max = np.percentile(all_wages, [1, 99])
    ax.set_ylim(0, y_max * 1.05)
    
    ax.set_ylabel("Hourly Wage ($USD)", fontsize=9.5, labelpad=8)
    ax.set_xlabel("", labelpad=4)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    ax.spines["left"].set_linewidth(0.6)
    ax.spines["left"].set_color("#333333")
    
    ax.grid(False)
    
    # Self-contained exhibit note below
    note_text = (
        "Notes: Tufte (1983) minimal boxplot design. Central marker denotes the sample median. "
        "The empty white space gap spans the interquartile range (25th to 75th percentiles). "
        "Vertical lines extend to the 2.5th and 97.5th percentiles. Total sample size: N = 1,200."
    )
    fig.text(0.04, -0.05, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.18, top=0.96, left=0.12, right=0.95)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


def plot_tufte_dot_dash(out_png=None, out_pdf=None, style_path=None):
    """
    Renders Tufte's Dot-Dash scatter plot:
    Marginal data rugs along axes reveal univariate distributions alongside bivariate scatter.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    np.random.seed(42)
    n = 180
    x = np.random.normal(50, 10, n)
    y = 0.65 * x + np.random.normal(0, 5, n) + 15
    
    fig, ax = plt.subplots(figsize=(6.8, 4.6), dpi=300)
    
    ax.scatter(x, y, color="#0072B2", alpha=0.6, s=24, edgecolors="none")
    
    # Marginal rug along bottom (x-distribution)
    y_rug_pos = y.min() - 4
    for val in x:
        ax.plot([val, val], [y_rug_pos - 0.8, y_rug_pos + 0.8], color="#444444", linewidth=0.5, alpha=0.7)
        
    # Marginal rug along left (y-distribution)
    x_rug_pos = x.min() - 4
    for val in y:
        ax.plot([x_rug_pos - 0.8, x_rug_pos + 0.8], [val, val], color="#444444", linewidth=0.5, alpha=0.7)
        
    ax.set_xlim(x_rug_pos - 2, x.max() + 3)
    ax.set_ylim(y_rug_pos - 2, y.max() + 3)
    
    ax.set_xlabel("R&D Intensity (\\% of Sales)", fontsize=9.0, labelpad=8)
    ax.set_ylabel("Firm Productivity Growth Rate (\\%)", fontsize=9.0, labelpad=8)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_position(("data", x_rug_pos - 1.5))
    ax.spines["bottom"].set_position(("data", y_rug_pos - 1.5))
    ax.spines["left"].set_linewidth(0.5)
    ax.spines["bottom"].set_linewidth(0.5)
    
    ax.grid(False)
    
    note_text = (
        "Notes: Tufte (1983) dot-dash graphic. Individual tick marks along the axes trace univariate marginal distributions, "
        "allowing simultaneous micro and macro inspection of the bivariate relationship without added charting clutter."
    )
    fig.text(0.04, -0.05, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.18, top=0.96, left=0.12, right=0.95)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    tufte_style = base_dir.parent.parent / "templates" / "tufte.mplstyle"
    out_bp_png = base_dir / "tufte_boxplot_preview.png"
    out_bp_pdf = base_dir / "tufte_boxplot.pdf"
    out_dd_png = base_dir / "tufte_dot_dash_preview.png"
    out_dd_pdf = base_dir / "tufte_dot_dash.pdf"
    
    df_data = simulate_subgroup_distributions()
    plot_tufte_minimal_boxplot(df_data, out_png=out_bp_png, out_pdf=out_bp_pdf, style_path=tufte_style)
    plot_tufte_dot_dash(out_png=out_dd_png, out_pdf=out_dd_pdf, style_path=tufte_style)
    print(f"Tufte boxplot saved to {out_bp_png} and {out_bp_pdf}")
    print(f"Tufte dot-dash saved to {out_dd_png} and {out_dd_pdf}")
