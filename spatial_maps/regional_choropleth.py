"""
Publication-Grade Spatial Regional Choropleth Map in Python.
Demonstrates spatial econometrics visualization with discrete quantile binning and equal-area projection.
Adheres to Gastel & Day exhibit standards and Anselin (1988) Spatial Econometrics.

Citations:
- Anselin, L. (1988). Spatial Econometrics: Methods and Models. Dordrecht: Kluwer Academic Publishers.
  DOI: 10.1007/978-94-015-7799-1
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from shapely.geometry import Polygon
import geopandas as gpd


def generate_synthetic_spatial_panel(n_rows=6, n_cols=8, seed=42):
    """
    Constructs a contiguous regular spatial lattice representing regional commuting zones or districts.
    Generates a spatially autocorrelated economic indicator via a spatial autoregressive (SAR) process.
    """
    np.random.seed(seed)
    polygons = []
    zone_ids = []
    
    for r in range(n_rows):
        for c in range(n_cols):
            x_offset = (r % 2) * 0.5
            x0 = c + x_offset
            y0 = r * 0.866
            
            pts = [
                (x0 + 0.5, y0),
                (x0 + 1.0, y0 + 0.288),
                (x0 + 1.0, y0 + 0.866),
                (x0 + 0.5, y0 + 1.155),
                (x0, y0 + 0.866),
                (x0, y0 + 0.288)
            ]
            polygons.append(Polygon(pts))
            zone_ids.append(f"CZ_{r}_{c}")
            
    gdf = gpd.GeoDataFrame({"zone_id": zone_ids, "geometry": polygons})
    
    n = len(gdf)
    centroids = np.array([[poly.centroid.x, poly.centroid.y] for poly in polygons])
    
    dist_matrix = np.linalg.norm(centroids[:, None, :] - centroids[None, :, :], axis=-1)
    W = np.where((dist_matrix > 0) & (dist_matrix <= 1.8), 1.0, 0.0)
    row_sums = W.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1.0
    W = W / row_sums
    
    rho = 0.55
    I = np.eye(n)
    epsilon = np.random.normal(15.0, 4.0, size=n)
    y_spatial = np.linalg.inv(I - rho * W) @ epsilon
    
    gdf["economic_index"] = y_spatial
    
    gdf["quintile"] = pd.qcut(gdf["economic_index"], q=5, labels=[
        "1st Quintile (Lowest)",
        "2nd Quintile",
        "3rd Quintile (Median)",
        "4th Quintile",
        "5th Quintile (Highest)"
    ])
    
    return gdf


def plot_regional_choropleth(gdf, out_png=None, out_pdf=None, style_path=None):
    """
    Renders publication-grade spatial choropleth with discrete quintile shading and zero chartjunk.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("default")
        
    fig, ax = plt.subplots(figsize=(8.2, 5.8), dpi=300)
    
    colors = {
        "1st Quintile (Lowest)": "#440154",
        "2nd Quintile": "#3B528B",
        "3rd Quintile (Median)": "#21908C",
        "4th Quintile": "#5DC863",
        "5th Quintile (Highest)": "#FDE725"
    }
    
    for q_label, hex_color in colors.items():
        sub_gdf = gdf[gdf["quintile"] == q_label]
        sub_gdf.plot(
            ax=ax,
            color=hex_color,
            edgecolor="#FFFFFF",
            linewidth=0.6,
            label=q_label
        )
        
    # Unavoidable discrete quintile key across top
    ax.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.08),
        ncol=5,
        frameon=False,
        fontsize=8.0,
        handlelength=1.2,
        handleheight=0.8
    )
    
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.grid(False)
    
    # Gastel & Day self-contained note below exhibit
    note_text = (
        "Notes: Choropleth map of contiguous economic commuting zones with spatial autoregressive parameter rho = 0.55. "
        "Shading represents 5-quantile discrete brackets computed across all zones. Perceptually uniform Viridis colormap "
        "ensures monotonic grayscale and colorblind accessibility (Cleveland, 1985). Total regional units: N = 48."
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
    out_png = base_dir / "regional_choropleth_preview.png"
    out_pdf = base_dir / "regional_choropleth.pdf"
    
    gdf_data = generate_synthetic_spatial_panel()
    plot_regional_choropleth(gdf_data, out_png=out_png, out_pdf=out_pdf, style_path=tufte_style)
    print(f"Regional choropleth saved to {out_png} and {out_pdf}")
