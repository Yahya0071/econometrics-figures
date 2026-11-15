# Tufte Slopegraph Exhibits

This module produces publication-grade slopegraphs (table-graphics) for comparing multi-entity outcomes across two distinct time horizons or policy states.

---

## 1. Design Principles (Tufte, 1983, p. 158)

A slopegraph integrates quantitative tables directly with graphic trajectories:
1. **Parallel Time Coordinates:** Entities are plotted at pre- and post-intervention points along two parallel vertical axes.
2. **Direct Typography (No Detached Legends):** The name of each unit and its numerical value are printed directly at the endpoints of the line, eliminating eye-darting between legends and chart areas.
3. **Slope as Rate of Change:** The slope of each line directly communicates both the direction (increase/decrease) and the velocity of change across entities.
4. **Focal Highlighting:** Entities subjected to policy shocks or experimental treatments are highlighted using bold primary colors (e.g., vermillion), while untreated comparison units remain in muted neutral gray.

---

## 2. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `slopegraph.py` | Python (`matplotlib`) | Pure Python slopegraph with collision-free text alignment and high data-ink ratio. |
| `slopegraph.R` | R (`ggplot2`) | ggplot2 implementation using direct text coordinates and `theme_tufte_academic`. |

---

## 3. Key References

- **Schwabish, J. A. (2014).** An economist's guide to visualizing data. *Journal of Economic Perspectives*, 28(1), 209-234.
- **Tufte, E. R. (1983).** *The Visual Display of Quantitative Information*. Graphics Press.
