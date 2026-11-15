"""
Publication-Grade Sparklines Generator in Python.
Adheres to Edward Tufte's principles: word-sized, data-dense graphics embedded in text or tables.

Citations:
- Tufte, E. R. (2006). Beautiful Evidence. Cheshire, CT: Graphics Press.
"""

from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt


def generate_sparkline(data, output_path, width=2.2, height=0.45, dpi=300):
    """
    Renders a single minimal sparkline:
    - Zero axes, zero ticks, zero borders
    - End-value dot
    - Min and max highlighted markers
    """
    fig, ax = plt.subplots(figsize=(width, height), dpi=dpi)
    
    x = np.arange(len(data))
    y = np.array(data)
    
    # Base sparkline path
    ax.plot(x, y, color="#222222", linewidth=1.1, solid_capstyle="round")
    
    # Highlight Minimum
    min_idx = np.argmin(y)
    ax.scatter([min_idx], [y[min_idx]], color="#D55E00", s=14, zorder=5)
    
    # Highlight Maximum
    max_idx = np.argmax(y)
    ax.scatter([max_idx], [y[max_idx]], color="#0072B2", s=14, zorder=5)
    
    # Highlight Final Point
    ax.scatter([x[-1]], [y[-1]], color="#222222", s=16, zorder=6)
    
    # Eliminate all borders, spines, ticks, and backgrounds
    ax.set_axis_off()
    fig.patch.set_visible(False)
    ax.patch.set_visible(False)
    
    plt.subplots_adjust(left=0.02, right=0.98, top=0.98, bottom=0.02)
    fig.savefig(str(output_path), dpi=dpi, transparent=True, bbox_inches="tight", pad_inches=0.01)
    plt.close(fig)


def generate_table_sparkline_suite(output_dir):
    """
    Generates a suite of sample economic sparklines for table insertion.
    Exports both vector PDF and 300 DPI raster PNG.
    """
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)
    
    series_dict = {
        "inflation": [1.8, 1.9, 2.1, 2.3, 2.4, 4.7, 7.0, 8.9, 6.5, 3.7, 3.1, 2.6],
        "unemployment": [6.2, 5.8, 5.3, 4.9, 4.1, 8.1, 5.4, 3.9, 3.6, 3.7, 3.9, 4.1],
        "federal_funds": [0.25, 0.25, 0.50, 0.75, 1.25, 0.25, 0.25, 1.75, 4.25, 5.25, 5.25, 4.75],
        "oil_price": [52, 58, 64, 71, 55, 39, 68, 95, 82, 78, 81, 74]
    }
    
    for name, series in series_dict.items():
        pdf_path = out_path / f"spark_{name}.pdf"
        png_path = out_path / f"spark_{name}.png"
        generate_sparkline(series, pdf_path)
        generate_sparkline(series, png_path)
        print(f"Generated sparklines for {name}: {pdf_path} and {png_path}")


if __name__ == "__main__":
    out_dir = Path(__file__).resolve().parent
    generate_table_sparkline_suite(out_dir)
