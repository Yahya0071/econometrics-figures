# Coefficient & Forest Plot Exhibits

This module produces publication-grade coefficient and forest plots for multi-model comparisons and subgroup heterogeneity analysis.

---

## 1. Econometric Foundation

Empirical research requires demonstrating sensitivity across econometric specifications (e.g., adding high-dimensional fixed effects, time-varying controls, or instrumenting endogenous regressors). A multi-model coefficient plot communicates:
- Stability of point estimates across specifications.
- Precision differences across subsamples.
- Clear comparison against the null hypothesis $\beta = 0$.

---

## 2. Exhibit Standards (Gastel & Day, Ch. 16-17)

Every coefficient plot in this module incorporates:
1. **Dual Confidence Intervals:** Both 90% (inner thick bar) and 95% (outer thin bar) confidence intervals to display statistical significance at conventional critical thresholds.
2. **Explicit Reference Line:** Vertical dashed line at the null hypothesis $\beta = 0$.
3. **Point Estimate Labels:** Direct numeric readout of $\hat{\beta}$ and standard error beside each marker, preventing visual ambiguity.
4. **Hierarchical Categorization:** Subgroup color coding and clear vertical ordering.
5. **Self-Contained Notes:** Documentation of clustering level and confidence interval parameters.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `coefficient_plots.py` | Python (`matplotlib`, `pandas`) | Dual-band horizontal forest plot with direct annotation labels. |
| `coefficient_plots.R` | R (`ggplot2`) | ggplot2 implementation using the academic theme and coordinate limits. |

---

## 4. Key References

- **Gastel, B., & Day, R. A. (2016).** *How to Write and Publish a Scientific Paper* (8th ed.). Cambridge University Press.
- **Jann, B. (2014).** Plotting regression coefficients and other estimates. *Stata Journal*, 14(4), 708-737.
