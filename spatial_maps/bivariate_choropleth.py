"""
Publication-Grade Bivariate Choropleth Map of the United States in Python.
Replicates the signature aesthetic of Asjad Naqvi's stata-bimap and Joshua Stevens (2015).
Features the classic 45-degree rotated diamond 2D legend with diagonal directional axes,
Albers Equal Area planar projection, and contiguous US state boundaries.

Citations:
- Stevens, J. (2015). Bivariate Choropleth Maps: A How-to Guide.
- Naqvi, A. (2022). BIMAP: Stata module to produce bivariate choropleth maps.
  Statistical Software Components S459091, Boston College Department of Economics.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MplPolygon
import geopandas as gpd


# Joshua Stevens (2015) Classic Blue-Pink Bivariate 3x3 Palette (Pink-Blue)
# Equivalent to Asjad Naqvi's bimap palette
# Columns: X quantiles (0: Low, 1: Medium, 2: High)
# Rows: Y quantiles (0: Low, 1: Medium, 2: High)
BIVARIATE_PALETTE_3X3 = {
    (0, 0): "#E8E8E8",  # Low X, Low Y (Neutral light gray)
    (1, 0): "#B0D5DF",  # Med X, Low Y
    (2, 0): "#64ACBE",  # High X, Low Y (Strong Cyan/Blue)
    (0, 1): "#E4ACAC",  # Low X, Med Y
    (1, 1): "#AD9EA5",  # Med X, Med Y
    (2, 1): "#627F8C",  # High X, Med Y
    (0, 2): "#C85A5A",  # Low X, High Y (Strong Red/Pink)
    (1, 2): "#985356",  # Med X, High Y
    (2, 2): "#574249"   # High X, High Y (Dark Plum/Purple)
}


def load_contiguous_us_data():
    """
    Loads contiguous US states boundaries from local cache with explicit CRS handling:
    X: Median Household Income ($ thousands)
    Y: Share of Population with Bachelor's Degree or Higher (%)
    """
    base_dir = Path(__file__).resolve().parent
    geojson_path = base_dir / "data" / "us_states.geojson"
    
    if geojson_path.is_file():
        gdf = gpd.read_file(geojson_path)
    else:
        url = "https://raw.githubusercontent.com/python-visualization/folium/master/examples/data/us-states.json"
        gdf = gpd.read_file(url)
        
    gdf = gdf[~gdf["id"].isin(["AK", "HI", "PR", "DC"])].copy()
    
    # Explicitly ensure CRS is set before reprojection to Albers Equal Area
    if gdf.crs is None:
        gdf = gdf.set_crs(epsg=4326)
    gdf = gdf.to_crs(epsg=5070)
    
    # Synthetic empirical state indicators
    np.random.seed(42)
    n = len(gdf)
    
    mean_vec = [68.0, 34.0]
    cov_mat = [[140.0, 52.0], [52.0, 48.0]]
    sim_vals = np.random.multivariate_normal(mean_vec, cov_mat, size=n)
    
    gdf["income"] = sim_vals[:, 0]
    gdf["college_share"] = sim_vals[:, 1]
    
    gdf["x_tercile"] = pd.qcut(gdf["income"], q=3, labels=[0, 1, 2]).astype(int)
    gdf["y_tercile"] = pd.qcut(gdf["college_share"], q=3, labels=[0, 1, 2]).astype(int)
    
    gdf["biv_color"] = [
        BIVARIATE_PALETTE_3X3[(x, y)]
        for x, y in zip(gdf["x_tercile"], gdf["y_tercile"])
    ]
    
    return gdf


def draw_rotated_diamond_legend(ax, x_label="Higher Income", y_label="Higher College Share"):
    """
    Renders the classic 45-degree rotated 3x3 diamond legend used in stata-bimap and Joshua Stevens (2015).
    """
    cos45 = np.cos(np.pi / 4.0)
    sin45 = np.sin(np.pi / 4.0)
    cell_size = 0.92
    
    for i in range(3):
        for j in range(3):
            color = BIVARIATE_PALETTE_3X3[(i, j)]
            corners = np.array([
                [-cell_size / 2.0, -cell_size / 2.0],
                [cell_size / 2.0, -cell_size / 2.0],
                [cell_size / 2.0, cell_size / 2.0],
                [-cell_size / 2.0, cell_size / 2.0]
            ])
            corners += np.array([i + 0.5, j + 0.5])
            
            rot_x = corners[:, 0] * cos45 - corners[:, 1] * sin45
            rot_y = corners[:, 0] * sin45 + corners[:, 1] * cos45
            
            poly = MplPolygon(
                np.column_stack([rot_x, rot_y]),
                closed=True,
                facecolor=color,
                edgecolor="#FFFFFF",
                linewidth=0.7,
                zorder=10
            )
            ax.add_patch(poly)
            
    r_apex = 3.0 * cos45
    
    # Bottom-Right Axis Arrow (X variable)
    ax.annotate(
        "", xy=(r_apex + 0.35, r_apex + 0.35), xytext=(-0.1, -0.1),
        arrowprops=dict(arrowstyle="->", color="#222222", lw=1.1),
        zorder=12
    )
    ax.text(
        r_apex / 2.0 + 0.35, r_apex / 2.0 - 0.35,
        x_label,
        rotation=45, ha="center", va="top",
        fontsize=7.8, fontweight="bold", color="#222222",
        zorder=12
    )
    
    # Bottom-Left Axis Arrow (Y variable)
    ax.annotate(
        "", xy=(-r_apex - 0.35, r_apex + 0.35), xytext=(0.1, -0.1),
        arrowprops=dict(arrowstyle="->", color="#222222", lw=1.1),
        zorder=12
    )
    ax.text(
        -r_apex / 2.0 - 0.35, r_apex / 2.0 - 0.35,
        y_label,
        rotation=-45, ha="center", va="top",
        fontsize=7.8, fontweight="bold", color="#222222",
        zorder=12
    )
    
    ax.set_xlim(-3.0, 3.0)
    ax.set_ylim(-0.8, 5.0)
    ax.set_aspect("equal")
    ax.axis("off")


def plot_bivariate_us_map(gdf, out_png=None, out_pdf=None, style_path=None):
    """
    Renders professional bivariate US choropleth adhering to stata-bimap and Gastel & Day exhibit standards.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    fig, ax = plt.subplots(figsize=(10.0, 6.5), dpi=300)
    
    for biv_tuple, hex_col in BIVARIATE_PALETTE_3X3.items():
        sub_gdf = gdf[(gdf["x_tercile"] == biv_tuple[0]) & (gdf["y_tercile"] == biv_tuple[1])]
        if len(sub_gdf) > 0:
            sub_gdf.plot(
                ax=ax,
                color=hex_col,
                edgecolor="#FFFFFF",
                linewidth=0.75,
                zorder=3
            )
            
    ax.axis("off")
    ax.grid(False)
    
    # Inset 45-degree Rotated Diamond Legend in Atlantic / Gulf space
    # The 2D key is unavoidable for bivariate choropleth mapping
    legend_ax = fig.add_axes([0.76, 0.12, 0.20, 0.28])
    draw_rotated_diamond_legend(legend_ax, x_label="Median Income", y_label="College Degree Share")
    
    # Self-contained note below exhibit
    note_text = (
        "Notes: Bivariate choropleth map generated according to Asjad Naqvi's stata-bimap and Joshua Stevens (2015). "
        "Both continuous indicators are partitioned into sample population terciles (3x3 classification). Cyan shades denote "
        "high median income with low college attainment; pink/red shades denote high college attainment with low median income; "
        "dark plum indicates joint high attainment across both dimensions. State boundaries projected using Albers Equal Area (ESRI:102003 / EPSG:5070). "
        "Sample: 48 contiguous states."
    )
    fig.text(0.05, 0.04, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(left=0.04, right=0.96, top=0.96, bottom=0.12)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    tufte_style = base_dir.parent / "templates" / "tufte.mplstyle"
    out_png = base_dir / "bivariate_choropleth_preview.png"
    out_pdf = base_dir / "bivariate_choropleth.pdf"
    
    us_gdf = load_contiguous_us_data()
    plot_bivariate_us_map(us_gdf, out_png=out_png, out_pdf=out_pdf, style_path=tufte_style)
    print(f"Bivariate US choropleth saved to {out_png} and {out_pdf}")
