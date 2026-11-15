# Event-Study Exhibits for Staggered Difference-in-Differences

This module provides reproducible, publication-grade event-study figures for panel difference-in-differences designs with staggered policy adoption.

---

## 1. Econometric Foundation

Two-way fixed effects (TWFE) regressions with dynamic leads and lags can suffer from severe bias when treatment effects vary across cohorts or over time (Goodman-Bacon, 2021; Sun and Abraham, 2021; de Chaisemartin and D'Haultfoeuille, 2020). Modern estimators decompose treatment effects by cohort and event time to eliminate negative weighting:

$$Y_{it} = \alpha_i + \gamma_t + \sum_{k \neq -1} \beta_k \cdot \mathbf{1}\{t - E_i = k\} + \varepsilon_{it}$$

Where:
- $E_i$ denotes the initial policy adoption period for unit $i$.
- $k = t - E_i$ denotes relative event time.
- $k = -1$ is normalized to 0 as the reference period.
- Pre-treatment coefficients ($k < -1$) evaluate the credibility of parallel trends.
- Post-treatment coefficients ($k \ge 0$) trace dynamic treatment effects.

---

## 2. Exhibit Design Standards (Gastel & Day, Ch. 16-17)

Every event-study figure in this module incorporates:
1. **Normalized Baseline:** The reference period at $t = -1$ is explicitly fixed at 0.
2. **Distinct Pre- and Post-Treatment Bands:** Shaded 95% confidence intervals differentiate diagnostic pre-trend leads from dynamic treatment effects.
3. **Reference Lines:** A solid horizontal line at 0 and a vertical dashed line at $t = -1$.
4. **Self-Contained Notes:** Footnotes report cluster levels, sample size $N$, and cluster count $G$.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `event_study.py` | Python (`statsmodels`, `matplotlib`) | Self-contained synthetic DGP, cluster-robust estimation, and export. |
| `monte_carlo.py` | Python (`numpy`, `pandas`, `statsmodels`) | 200-draw Monte Carlo simulation comparing TWFE and Sun-Abraham (2021). |
| `event_study.R` | R (`ggplot2`, `fixest`) | Clean ggplot2 implementation using the academic theme. |
| `event_study.do` | Stata (`reghdfe`, `coefplot`, `eventstudyinteract`) | Stata script with synthetic panel simulation and exhibit options. |

---

## 4. Key References

- **Callaway, B., & Sant'Anna, P. H. (2021).** Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200-230. DOI: 10.1016/j.jeconom.2020.12.001
- **Goodman-Bacon, A. (2021).** Difference-in-differences with variation in treatment timing. *Journal of Econometrics*, 225(2), 254-277. DOI: 10.1016/j.jeconom.2021.03.014
- **Sun, L., & Abraham, S. (2021).** Estimating dynamic treatment effects in event study designs with heterogeneous treatment effects. *Journal of Econometrics*, 225(2), 175-199. DOI: 10.1016/j.jeconom.2020.09.006
