"""
Publication-Grade Slopegraph in Python.
Adheres to Edward Tufte's table-graphic principles in The Visual Display of Quantitative Information (1983).
Displays changes across two time periods with direct in-line typography and no detached legends.

Citations:
- Tufte, E. R. (1983). The Visual Display of Quantitative Information. Cheshire, CT: Graphics Press.
"""

from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt


def create_slopegraph_data():
    """
    Constructs sample state-level tax revenue or compliance shares before and after a major reform.
    """
    entities = [
        {"state": "California", "pre": 11.2, "post": 13.8, "status": "Treated"},
        {"state": "New York", "pre": 10.8, "post": 12.9, "status": "Treated"},
        {"state": "New Jersey", "pre": 9.4, "post": 11.1, "status": "Treated"},
        {"state": "Massachusetts", "pre": 8.9, "post": 9.2, "status": "Control"},
        {"state": "Illinois", "pre": 8.1, "post": 7.9, "status": "Control"},
        {"state": "Ohio", "pre": 7.4, "post": 7.1, "status": "Control"},
        {"state": "Texas", "pre": 6.8, "post": 6.5, "status": "Control"},
        {"state": "Florida", "pre": 5.9, "post": 5.7, "status": "Control"},
    ]
    return pd.DataFrame(entities)


def plot_slopegraph(df, out_png=None, out_pdf=None, style_path=None):
    """
    Renders Tufte slopegraph with direct left and right annotations and zero chartjunk.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    fig, ax = plt.subplots(figsize=(6.8, 6.2), dpi=300)
    
    x_pre = 0.0
    x_post = 1.0
    
    color_treated = "#D55E00"
    color_control = "#777777"
    
    for _, row in df.iterrows():
        is_treated = (row["status"] == "Treated")
        line_color = color_treated if is_treated else color_control
        line_width = 1.8 if is_treated else 0.9
        alpha_val = 0.95 if is_treated else 0.70
        z_ord = 5 if is_treated else 3
        
        ax.plot([x_pre, x_post], [row["pre"], row["post"]],
                color=line_color, linewidth=line_width, alpha=alpha_val, zorder=z_ord)
        
        ax.scatter([x_pre, x_post], [row["pre"], row["post"]],
                   color=line_color, s=26 if is_treated else 16, zorder=z_ord + 1)
        
        # Left label: State name and pre-value
        left_text = f"{row['state']}  {row['pre']:.1f}%"
        ax.text(x_pre - 0.04, row["pre"], left_text, ha="right", va="center",
                fontsize=8.5, fontweight="bold" if is_treated else "normal",
                color=line_color if is_treated else "#333333")
        
        # Right label: Post-value and state name
        right_text = f"{row['post']:.1f}%  {row['state']}"
        ax.text(x_post + 0.04, row["post"], right_text, ha="left", va="center",
                fontsize=8.5, fontweight="bold" if is_treated else "normal",
                color=line_color if is_treated else "#333333")
        
    y_min = df[["pre", "post"]].min().min() - 0.8
    y_max = df[["pre", "post"]].max().max() + 0.8
    
    ax.axvline(x_pre, color="#CCCCCC", linestyle=":", linewidth=0.6, zorder=1)
    ax.axvline(x_post, color="#CCCCCC", linestyle=":", linewidth=0.6, zorder=1)
    
    # Column Header labels
    ax.text(x_pre, y_max + 0.4, "Pre-Reform\n(2014)", ha="center", va="bottom",
            fontsize=9.5, fontweight="bold", color="#111111")
    ax.text(x_post, y_max + 0.4, "Post-Reform\n(2020)", ha="center", va="bottom",
            fontsize=9.5, fontweight="bold", color="#111111")
    
    ax.set_xlim(-0.45, 1.45)
    ax.set_ylim(y_min, y_max + 1.2)
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.grid(False)
    
    # Self-contained note below exhibit
    note_text = (
        "Notes: Tufte (1983) slopegraph table-graphic showing effective state tax revenue shares before and after statutory reform. "
        "Vermillion trajectories denote jurisdictions adopting statutory reform; gray trajectories denote non-adopting comparison jurisdictions. "
        "Numbers represent effective state tax revenues as a percentage of gross state product."
    )
    fig.text(0.04, -0.05, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.16, top=0.92, left=0.10, right=0.90)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    tufte_style = base_dir.parent.parent / "templates" / "tufte.mplstyle"
    out_png = base_dir / "slopegraph_preview.png"
    out_pdf = base_dir / "slopegraph.pdf"
    
    data = create_slopegraph_data()
    plot_slopegraph(data, out_png=out_png, out_pdf=out_pdf, style_path=tufte_style)
    print(f"Slopegraph saved to {out_png} and {out_pdf}")
