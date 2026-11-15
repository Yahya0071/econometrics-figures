# Impulse Response Functions (IRF) via Local Projections

This module produces publication-grade impulse response exhibits using the local projections framework of Jorda (2005).

---

## 1. Econometric Foundation

Local projections estimate dynamic structural responses through a sequence of single-equation regressions for each forecast horizon $h = 0, 1, \dots, H$:

$$Y_{t+h} = \alpha_h + \beta_h \cdot \text{Shock}_t + \mathbf{\Gamma}_h' \mathbf{X}_t + \varepsilon_{t+h}$$

Where:
- $\beta_h$ traces the dynamic response of outcome $Y$ to an unexpected shock at horizon $h$.
- $\mathbf{X}_t$ denotes contemporaneous and lagged control variables.
- Standard errors are adjusted for autocorrelation induced by overlapping forecast errors using Newey-West (HAC) estimators with bandwidth $h + 1$.
- Unlike standard vector autoregressions (VARs), local projections are robust to misspecification of the underlying multivariate lag dynamic.

---

## 2. Exhibit Standards (Gastel & Day, Ch. 16-17)

Every IRF exhibit in this module incorporates:
1. **Dual Confidence Bands:** Both 68% (one standard error) and 95% confidence intervals, adhering to macroeconomic publishing standards (Ramey, 2016).
2. **Zero Null Line:** A solid horizontal reference line at 0.
3. **Discrete Horizon Ticks:** Explicit integer markings for each projection period.
4. **Self-Contained Notes:** Definition of the structural shock, outcome units, and autocorrelation adjustments.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `irf_plots.py` | Python (`statsmodels`, `matplotlib`) | Macro series simulation, HAC local projections, and dual-band plot. |
| `irf_plots.R` | R (`ggplot2`) | ggplot2 implementation using the academic theme and confidence ribbons. |
| `irf_plots.do` | Stata (`newey`) | Jorda (2005) local projections IRF with Newey-West HAC bands. |

---

## 4. Key References

- **Jorda, O. (2005).** Estimation and inference of impulse responses by local projections. *American Economic Review*, 95(1), 161-182. DOI: 10.1257/0002828053828518
- **Ramey, V. A. (2016).** Macroeconomic shocks and their propagation. *Handbook of Macroeconomics*, 2, 71-162.
