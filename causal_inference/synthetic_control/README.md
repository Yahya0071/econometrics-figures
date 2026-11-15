# Synthetic Control Method (SCM) Exhibits

This module produces publication-grade comparative case study figures using the synthetic control method.

---

## 1. Econometric Foundation

The synthetic control method constructs an optimal convex combination of untreated donor pool units to serve as a counterfactual for a single treated unit (Abadie, Diamond, and Hainmueller, 2010):

$$\hat{Y}_{1t}(0) = \sum_{j=2}^{J+1} w_j^* Y_{jt}, \quad \text{subject to } \sum_{j=2}^{J+1} w_j^* = 1, \quad w_j^* \ge 0$$

Where optimal weights $\mathbf{W}^*$ minimize the pre-intervention mean squared error between the treated unit and the donor pool:

$$\min_{\mathbf{W}} \|\mathbf{Y}_{1,\text{pre}} - \mathbf{Y}_{0,\text{pre}} \mathbf{W}\|^2$$

Statistical inference is obtained through in-space and in-time placebo permutation tests rather than standard large-$N$ asymptotic approximations.

---

## 2. Exhibit Standards (Gastel & Day, Ch. 16-17)

Every synthetic control exhibit incorporates:
1. **Two-Panel Architecture:** Panel A presents actual vs synthetic trajectories; Panel B presents the gap along with donor placebo distributions.
2. **Intervention Vertical Line:** Explicit dashed indicator at the treatment timing $T_0$.
3. **Weight Constrained Optimization:** Convex non-negative weighting to prevent extrapolation beyond the support of the donor pool.
4. **Self-Contained Notes:** Documentation of pre-treatment periods, donor pool sample size, and placebo iteration counts.

---

## 3. Included Scripts

| File | Language | Description |
| :--- | :--- | :--- |
| `synthetic_control.py` | Python (`scipy.optimize`, `matplotlib`) | Quadratic programming weights optimization, placebo simulation, and two-panel layout. |
| `synthetic_control.R` | R (`ggplot2`, `patchwork`) | Reproducible script for SCM trajectory and gap exhibits. |
| `synthetic_control.do` | Stata (`synth`) | Constrained synthetic control trajectory and placebo gap exhibit. |

---

## 4. Key References

- **Abadie, A. (2021).** Using synthetic controls: Feasibility, data requirements, and methodological aspects. *Journal of Economic Literature*, 59(2), 391-425.
- **Abadie, A., Diamond, A., & Hainmueller, J. (2010).** Synthetic control methods for comparative case studies: Estimating the effect of California's tobacco control program. *Journal of the American Statistical Association*, 105(490), 493-505. DOI: 10.1198/jasa.2009.ap08746
