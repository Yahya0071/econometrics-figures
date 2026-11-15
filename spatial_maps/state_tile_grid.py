"""
Publication-Grade US State Tile-Grid Cartogram in Python.
Eliminates geographic landmass bias ("land is not people") by granting equal visual weight to each state.
Adheres to Gastel & Day exhibit standards and Edward Tufte's data-ink maximization principles.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches


STATE_GRID = {
    "AK": (0, 7), "ME": (11, 7),
    "VT": (10, 6), "NH": (11, 6),
    "WA": (1, 5), "ID": (2, 5), "MT": (3, 5), "ND": (4, 5), "MN": (5, 5), "IL": (6, 5), "WI": (7, 5), "MI": (8, 5), "NY": (9, 5), "MA": (10, 5), "RI": (11, 5),
    "OR": (1, 4), "NV": (2, 4), "WY": (3, 4), "SD": (4, 4), "IA": (5, 4), "IN": (6, 4), "OH": (7, 4), "PA": (8, 4), "NJ": (9, 4), "CT": (10, 4),
    "CA": (1, 3), "UT": (2, 3), "CO": (3, 3), "NE": (4, 3), "MO": (5, 3), "KY": (6, 3), "WV": (7, 3), "VA": (8, 3), "MD": (9, 3), "DE": (10, 3),
    "AZ": (2, 2), "NM": (3, 2), "KS": (4, 2), "AR": (5, 2), "TN": (6, 2), "NC": (7, 2), "SC": (8, 2), "DC": (9, 2),
    "OK": (4, 1), "LA": (5, 1), "MS": (6, 1), "AL": (7, 1), "GA": (8, 1),
    "HI": (0, 0), "TX": (4, 0), "FL": (9, 0)
}


def simulate_state_economic_data(seed=42):
    """
    Generates synthetic state-level economic indicators (e.g., minimum wage or labor mobility).
    """
    np.random.seed(seed)
    states = list(STATE_GRID.keys())
    values = np.random.normal(loc=12.5, scale=3.2, size=len(states))
    values = np.round(values, 1)
    
    df = pd.DataFrame({"state": states, "value": values})
    
    df["quintile"] = pd.qcut(df["value"], q=5, labels=[
        "1st Quintile (Lowest)",
        "2nd Quintile",
        "3rd Quintile (Median)",
        "4th Quintile",
        "5th Quintile (Highest)"
    ])
    
    return df


def plot_state_tile_grid(df, out_png=None, out_pdf=None, style_path=None):
    """
    Renders publication-grade state cartogram where each jurisdiction has identical graphical area.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    fig, ax = plt.subplots(figsize=(8.8, 6.2), dpi=300)
    
    quintile_colors = {
        "1st Quintile (Lowest)": "#440154",
        "2nd Quintile": "#3B528B",
        "3rd Quintile (Median)": "#21908C",
        "4th Quintile": "#5DC863",
        "5th Quintile (Highest)": "#FDE725"
    }
    
    text_colors = {
        "1st Quintile (Lowest)": "#FFFFFF",
        "2nd Quintile": "#FFFFFF",
        "3rd Quintile (Median)": "#FFFFFF",
        "4th Quintile": "#111111",
        "5th Quintile (Highest)": "#111111"
    }
    
    tile_width = 0.90
    tile_height = 0.90
    
    val_map = dict(zip(df["state"], df["value"]))
    q_map = dict(zip(df["state"], df["quintile"]))
    
    for state, (col, row) in STATE_GRID.items():
        q_label = q_map.get(state, "3rd Quintile (Median)")
        val = val_map.get(state, 0.0)
        
        bg_color = quintile_colors[q_label]
        txt_color = text_colors[q_label]
        
        rect = patches.Rectangle(
            (col - tile_width / 2.0, row - tile_height / 2.0),
            tile_width,
            tile_height,
            linewidth=0.5,
            edgecolor="#FFFFFF",
            facecolor=bg_color,
            zorder=3
        )
        ax.add_patch(rect)
        
        ax.text(
            col, row + 0.12, state,
            ha="center", va="center",
            fontsize=8.5, fontweight="bold",
            color=txt_color, zorder=4
        )
        ax.text(
            col, row - 0.16, f"{val:.1f}",
            ha="center", va="center",
            fontsize=7.0,
            color=txt_color, zorder=4
        )
        
    # Discrete horizontal legend across top (unavoidable for quintile choropleth classification)
    legend_patches = [
        patches.Patch(color=quintile_colors[label], label=label)
        for label in quintile_colors
    ]
    ax.legend(
        handles=legend_patches,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.08),
        ncol=5,
        frameon=False,
        fontsize=8.0,
        handlelength=1.2,
        handleheight=0.8
    )
    
    ax.set_xlim(-0.8, 12.0)
    ax.set_ylim(-0.8, 8.2)
    ax.set_aspect("equal")
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.grid(False)
    
    # Self-contained note below exhibit
    note_text = (
        "Notes: Equal-representation state tile-grid cartogram. Each state is represented by an identical geometric area "
        "to prevent visual distortion from geographic landmass. Shading corresponds to 5-quantile discrete brackets computed across "
        "all 50 states and the District of Columbia. Numbers display average annualized real wage growth (%)."
    )
    fig.text(0.04, -0.04, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.14, top=0.92, left=0.04, right=0.96)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    tufte_style = base_dir.parent / "templates" / "tufte.mplstyle"
    out_png = base_dir / "state_tile_grid_preview.png"
    out_pdf = base_dir / "state_tile_grid.pdf"
    
    data = simulate_state_economic_data()
    plot_state_tile_grid(data, out_png=out_png, out_pdf=out_pdf, style_path=tufte_style)
    print(f"State tile grid map saved to {out_png} and {out_pdf}")
