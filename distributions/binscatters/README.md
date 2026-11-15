# Nonparametric Binned Scatter Plots (Binscatter)

This module produces publication-grade binned scatter plots for visualizing conditional expectation functions and subgroup heterogeneity.

---

## 1. Econometric Foundation

Binned scatter plots approximate the conditional expectation function $\mathbb{E}[Y_i \mid X_i]$ without imposing parametric functional forms (Cattaneo, Crump, Farrell, and Feng, 2024).

The sample is partitioned into $J$ mutually exclusive quantile bins:

$$\mathcal{B}_j = (q_{j-1}, q_j], \quad j = 1, \dots, J$$

Within each bin $j$, the sample means of both the running variable $\bar{X}_j$ and the outcome $\bar{Y}_j$ are calculated:

$$\bar{X}_j = \frac{1}{N_j} \sum_{i \in \mathcal{B}_j} X_i, \quad \bar{Y}_j = \frac{1}{N_j} \sum_{i \in \mathcal{B}_j} Y_i$$

A linear or polynomial regression line estimated on the underlying microdata is overlaid to display the conditional relationship while preventing graphical distortion from raw point clouds.

---

## 2. Exhibit Standards (Gastel & Day, Ch. 16-17)

Every binscatter exhibit incorporates:
1. **Equal-Sized Quantile Bins:** Bins contain an identical number of observations to reflect empirical data mass.
2. **Subgroup Stratification:** Distinguishable color palettes for comparative cohorts with reported group slopes and standard errors.
3. **Linear Regression Projections:** Unbiased OLS trend lines projected across the 1st to 99th percentiles of support.
4. **Self-Contained Notes:** Footnote reports total observation count $N$ and binning parameters.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `binscatter.py` | Python (`statsmodels`, `matplotlib`) | Quantile bin calculation, OLS estimation, and publication export. |
| `binscatter.R` | R (`ggplot2`) | ggplot2 implementation using the academic theme and quantile splitting. |

---

## 4. Key References

- **Cattaneo, M. D., Crump, R. K., Farrell, M. H., & Feng, Y. (2024).** On binscatter. *American Economic Review*, 114(5), 1488-1514.
- **Chetty, R., Hendren, N., Kline, P., & Saez, E. (2014).** Where is the land of opportunity? The geography of intergenerational mobility in the United States. *Quarterly Journal of Economics*, 129(4), 1553-1623.
