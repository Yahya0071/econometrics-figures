# Regression Discontinuity (RD) Exhibits

This module produces publication-grade figures for sharp and fuzzy regression discontinuity designs.

---

## 1. Econometric Foundation

The regression discontinuity design evaluates the local average treatment effect (LATE) at a known institutional threshold $c$:

$$\tau_{RD} = \lim_{x \downarrow c} \mathbb{E}[Y_i \mid X_i = x] - \lim_{x \uparrow c} \mathbb{E}[Y_i \mid X_i = x]$$

Where:
- $X_i$ is the continuous running (forcing) variable.
- Treatment assignment changes discontinuously at $X_i = c$.
- Identification rests on the continuity of potential outcome distributions $\mathbb{E}[Y_i(0) \mid X_i = x]$ and $\mathbb{E}[Y_i(1) \mid X_i = x]$ across the cutoff.

---

## 2. Exhibit Standards (Gastel & Day, Ch. 16-17)

Every RD plot in this module incorporates:
1. **Binned Scatter Points:** Local sample means plotted within data-driven or evenly spaced bins to convey underlying density without displaying thousands of overlapping observations.
2. **Local Polynomial Fit:** Separate regression curves estimated below and above $c$ using optimal bandwidth selectors.
3. **95% Confidence Envelopes:** Shaded intervals reflecting robust standard errors.
4. **Cutoff Indicator:** A distinct vertical reference line at $X = c$.
5. **Estimate Box:** Inline display of point estimate $\hat{\tau}_{RD}$ and standard error.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `rd_plots.py` | Python (`statsmodels`, `matplotlib`) | Self-contained synthetic DGP, binned calculations, local linear fit, and export. |
| `rd_plots.R` | R (`ggplot2`) | ggplot2 implementation using the academic theme and local linear fits. |

---

## 4. Key References

- **Calonico, S., Cattaneo, M. D., & Titiunik, R. (2014).** Robust nonparametric confidence intervals for regression-discontinuity designs. *Econometrica*, 82(6), 2295-2326.
- **Calonico, S., Cattaneo, M. D., & Titiunik, R. (2015).** Optimal data-driven regression discontinuity plots. *Journal of the American Statistical Association*, 110(512), 1753-1769.
- **Lee, D. S., & Lemieux, T. (2010).** Regression discontinuity designs in economics. *Journal of Economic Literature*, 48(2), 281-355.
- **McCrary, J. (2008).** Manipulation of the running variable in the regression discontinuity design: A density test. *Journal of Econometrics*, 142(2), 698-714.
