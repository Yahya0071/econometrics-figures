# Tufte Minimalist Distribution Exhibits

This module implements Edward Tufte's re-engineered data graphics from *The Visual Display of Quantitative Information* (1983, 2001), prioritizing maximum data-ink ratio and zero chartjunk.

---

## 1. Principles of Minimalist Distribution Design

1. **The Midgap Boxplot:**
   Traditional Tukey boxplots consume substantial ink on enclosing rectangles. Tufte replaces the box with an intentional white-space gap spanning the interquartile range ($Q_1$ to $Q_3$), positioning an isolated point at the median:
   - Median: Dot at $Q_2$.
   - Interquartile Range: Blank open space between $Q_1$ and $Q_3$.
   - Whiskers: Thin vertical lines from the outer percentiles to the quartile boundaries.
   This design reduces non-data ink by more than 70% while improving graphical readability.

2. **The Dot-Dash Graphic (Marginal Rugs):**
   Combines a bivariate scatter plot with univariate marginal tick marks along the axes. Every data coordinate is projected onto the coordinate frame, providing an integrated micro/macro view without requiring separate histograms.

---

## 2. Included Scripts

| File | Language | Design Implemented |
| :--- | :--- | :--- |
| `tufte_boxplot.py` | Python (`matplotlib`) | Midgap boxplot and dot-dash marginal rug scatter plot. |
| `tufte_boxplot.R` | R (`ggplot2`) | ggplot2 implementation using `geom_linerange` and `theme_tufte_academic`. |
| `tufte_boxplot.do` | Stata | Tufte midgap boxplot with percentile spikes and median markers. |

---

## 3. Key References

- **Cleveland, W. S. (1985).** *The Elements of Graphing Data*. Wadsworth Advanced Books.
- **Tufte, E. R. (1983, 2001).** *The Visual Display of Quantitative Information* (2nd ed.). Graphics Press.
