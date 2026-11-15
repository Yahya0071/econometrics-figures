# Repository Audit and Modernization Report

**Audit Date:** 2026-11-15  
**Auditor:** Empirical Research Advisor and Technical Editor  
**Environment:** Windows 11, Python 3.14.2 (virtual environment `.venv`), R version 4.6.0  
**Verified Package Stack:**
- `numpy==2.5.4`
- `pandas==3.1.1`
- `matplotlib==3.11.2`
- `scipy==1.18.1`
- `statsmodels==0.15.0`
- `geopandas==1.2.0`
- `shapely==2.2.0`
- `pyproj==3.8.0`
- `pyogrio==0.13.0`
- `pyyaml==6.0.3`

---

## 1. Post-Upgrade Script Status Table

Status definitions:
- **RAN-LOCAL:** Executed directly in the local Windows environment with exit code 0 and verified outputs.
- **STATIC-CHECK:** Source inspected and statically validated for syntax, directory independence, and package declarations.
- **NOT-RUN:** Not executed in this local session.
- **CI-PENDING:** Scheduled for execution on automated continuous integration runners.

| Script Path | Lang | Findings from code reading | Status | Outputs Written | Evidence |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `causal_inference/event_studies/event_study.py` | Python | TWFE homogeneous DGP; missing PDF; in-figure title | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 5.52s, 2026-11-15). |
| `causal_inference/event_studies/monte_carlo.py` | Python | Monte Carlo was not reproducible from committed code | **RAN-LOCAL** | CSV + MD | Executed via `.venv/Scripts/python.exe` (200 draws, seeds 1000 to 1199, exit code 0, 195.99s, 2026-11-15). |
| `causal_inference/event_studies/event_study.R` | R | In-figure title; homogeneous DGP; standard TWFE only | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` with `fixest` (exit code 0, 2.81s, 2026-11-15). |
| `causal_inference/event_studies/event_study.do` | Stata | Homogeneous DGP; missing `avar` dependency declaration | **STATIC-CHECK** | PDF + PNG (declared) | Statically verified. Added `ssc install avar` and `eventstudyinteract`; path-independent syntax. |
| `causal_inference/regression_discontinuity/rd_plots.py` | Python | PNG only; in-figure title; legend box; uniform kernel | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 3.74s, 2026-11-15). |
| `causal_inference/regression_discontinuity/rd_plots.R` | R | In-figure title; single PDF output | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.48s, 2026-11-15). |
| `causal_inference/regression_discontinuity/rd_plots.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented sharp RD with `rdrobust` and `rdplot` (Calonico, Cattaneo, and Titiunik, 2014, 2015). |
| `causal_inference/synthetic_control/synthetic_control.py` | Python | PNG only; in-figure titles; detached legend boxes | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.74s, 2026-11-15). |
| `causal_inference/synthetic_control/synthetic_control.R` | R | In-figure titles; single PDF output | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.39s, 2026-11-15). |
| `causal_inference/synthetic_control/synthetic_control.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented synthetic control via `synth` (Abadie, Diamond, and Hainmueller, 2010). |
| `distributions/binscatters/binscatter.py` | Python | PNG only; in-figure title; wrong Cattaneo citation | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 3.61s, 2026-11-15). Citation corrected. |
| `distributions/binscatters/binscatter.R` | R | In-figure title; single PDF output; wrong citation | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.25s, 2026-11-15). Citation corrected. |
| `distributions/binscatters/binscatter.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented via `binsreg` (Cattaneo et al., 2024) and `binscatter` (Stepner, 2013). |
| `distributions/coefficient_plots/coefficient_plots.py` | Python | PNG only; in-figure title; missing PDF | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.07s, 2026-11-15). |
| `distributions/coefficient_plots/coefficient_plots.R` | R | In-figure title; deprecated `geom_errorbarh` | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.28s, 2026-11-15). Replaced with `geom_errorbar(..., orientation = "y")`. |
| `distributions/coefficient_plots/coefficient_plots.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented multi-model forest exhibit via `coefplot` (Jann, 2014) with dual 90% and 95% CIs. |
| `distributions/tufte_minimal/tufte_boxplot.py` | Python | PNG only; in-figure titles for both exhibits | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.55s, 2026-11-15). Dual PDF and PNG written for both exhibits. |
| `distributions/tufte_minimal/tufte_boxplot.R` | R | In-figure title; single PDF output | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.21s, 2026-11-15). |
| `distributions/tufte_minimal/tufte_boxplot.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented Tufte midgap boxplot with percentile spikes and median points. |
| `distributions/slopegraphs/slopegraph.py` | Python | PNG only; in-figure title | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.02s, 2026-11-15). |
| `distributions/slopegraphs/slopegraph.R` | R | In-figure title; single PDF output | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.19s, 2026-11-15). |
| `distributions/slopegraphs/slopegraph.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented Tufte slopegraph via paired trajectory coordinates with direct labels. |
| `spatial_maps/state_tile_grid.py` | Python | PNG only; in-figure title | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.31s, 2026-11-15). |
| `spatial_maps/state_tile_grid.R` | R | Missing R implementation | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.25s, 2026-11-15). Equal-area tile grid via `geom_tile`. |
| `spatial_maps/state_tile_grid.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented 51-jurisdiction equal-area tile grid cartogram via coordinate scatter tiles. |
| `spatial_maps/regional_choropleth.py` | Python | PNG only; in-figure title | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.34s, 2026-11-15). |
| `spatial_maps/regional_choropleth.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented 25-region spatial lattice choropleth with Anselin spatial autocorrelation. |
| `spatial_maps/choropleth_map.R` | R | In-figure title; single PDF output; requires `sf` | **STATIC-CHECK** | PDF + PNG (conditional) | Inspected syntax and packages; requires `sf` (not installed in local Windows R 4.6.0; installed in CI). |
| `spatial_maps/bivariate_choropleth.py` | Python | PNG only; in-figure title; `os.path` | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 2.99s, 2026-11-15). |
| `spatial_maps/bivariate_choropleth.R` | R | In-figure title; requires `sf` and `biscale` | **STATIC-CHECK** | PDF + PNG (conditional) | Inspected syntax and packages; requires `sf` and `biscale` (installed in CI via setup-r-dependencies). |
| `spatial_maps/global_economies_map.py` | Python | PNG only; in-figure title; `os.path` | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 4.04s, 2026-11-15). |
| `spatial_maps/global_economies_map.R` | R | In-figure title; requires `sf` | **STATIC-CHECK** | PDF + PNG (conditional) | Inspected syntax and packages; Robinson projection verified; requires `sf` (installed in CI). |
| `spatial_maps/stata_global_map.do` | Stata | In-figure title in comments | **STATIC-CHECK** | PDF + PNG (declared) | Statically verified. Declared packages (`spmap`, `shp2dta`, `geo2xy`); documented dual export. |
| `spatial_maps/stata_spatial_map.do` | Stata | In-figure title in comments; Pisati citation typo | **STATIC-CHECK** | PDF + PNG (declared) | Statically verified. Corrected Pisati citation to Vol 4, Issue 4, pp. 361-378. |
| `spatial_maps/stata_bimap.do` | Stata | In-figure title in comments | **STATIC-CHECK** | PDF + PNG (declared) | Statically verified. Declared packages (`bimap`); documented dual export. |
| `time_series/impulse_responses/irf_plots.py` | Python | PNG only; in-figure title; legend box | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 4.09s, 2026-11-15). |
| `time_series/impulse_responses/irf_plots.R` | R | In-figure title; single PDF output; stray Rplots.pdf | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.34s, 2026-11-15). `invisible()` added to suppress Rplots.pdf. |
| `time_series/impulse_responses/irf_plots.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented local projections IRF with Newey-West standard errors (Jorda, 2005). |
| `diagrams_and_dags/sparklines/sparklines.py` | Python | Uses `os.path` | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `.venv/Scripts/python.exe -W error` (exit code 0, 1.53s, 2026-11-15). All 4 series exported. |
| `diagrams_and_dags/sparklines/sparklines.R` | R | Missing R implementation | **RAN-LOCAL** | PDF + PNG (300 DPI) | Executed via `Rscript.exe` (exit code 0, 1.35s, 2026-11-15). All 4 macroeconomic sparklines exported. |
| `diagrams_and_dags/sparklines/sparklines.do` | Stata | Missing Stata implementation | **STATIC-CHECK** | PDF + PNG (declared) | Implemented 12-period sparklines for 4 macroeconomic indicators with min/max dots. |
| `diagrams_and_dags/sparklines/sparkline_table.tex` | LaTeX | Local pdflatex unavailable | **STATIC-CHECK** | PDF (declared) | Standalone table syntax inspected and validated. Added to CI TeX Live pipeline. |
| `diagrams_and_dags/causal_dags/*.tex` | LaTeX | Local pdflatex unavailable | **STATIC-CHECK** | PDF (declared) | Standalone TikZ syntax inspected for DAG collider, confounding, and IV. Added to CI pipeline. |
| `diagrams_and_dags/timelines/*.tex` | LaTeX | Local pdflatex unavailable | **STATIC-CHECK** | PDF (declared) | Standalone TikZ timeline syntax inspected and validated. Added to CI pipeline. |

---

## 2. Monte Carlo Simulation: Two-Way Fixed Effects vs. Sun-Abraham (2021)

To evaluate finite-sample properties and potential identification distortion under treatment effect heterogeneity, a 200-replication Monte Carlo simulation was executed via `causal_inference/event_studies/monte_carlo.py`.

- **Command:** `.venv/Scripts/python.exe causal_inference/event_studies/monte_carlo.py`
- **Replications:** 200 independent panel realizations
- **Seed range:** 1000 to 1199 (inclusive)
- **Total runtime:** 195.99 seconds (Python 3.14.2 on Windows 11)
- **Sample per draw:** $N = 400$ units, $T = 12$ periods ($4,800$ unit-by-period observations)
- **Adoption Timing:** Cohort 4 ($t = 4$), Cohort 7 ($t = 7$), Cohort 9 ($t = 9$), and never-treated ($c = 999$)
- **Treatment Effects:**
  - Cohort 4: $\tau_{4}(k) = 3.0 + 1.2 \ln(k + 1)$
  - Cohort 7: $\tau_{7}(k) = 1.5 + 0.4 \ln(k + 1)$
  - Cohort 9: $\tau_{9}(k) = 0.8 + 0.1 \ln(k + 1)$
- **Reference Period:** $t = -1$ (normalized to 0)
- **Endpoint Bins:** $k \le -5$ and $k \ge 5$
- **Estimand Definition:**
  - For interior relative time $k$, the realized cohort-share-weighted average of $\tau_c(k)$ over cohorts observed at $k$.
  - For endpoint bins ($k \le -5$ and $k \ge 5$), the realized cohort-share-weighted average over cohorts of each cohort's mean effect across the periods that cohort contributes to the bin.

### Monte Carlo Simulation Results Table

The numbers below are generated directly by `monte_carlo.py` and saved to `monte_carlo_results.csv` and `monte_carlo_results.md`:

| Relative Time ($k$) | True Estimand | TWFE Mean | TWFE Bias | TWFE RMSE | TWFE Rejection Rate | SA Mean | SA Bias | SA RMSE | SA Rejection Rate | SA Coverage (95% CI) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $\le -5$ | 0.000 | 1.289 | +1.289 | 1.293 | 1.000 | 0.003 | +0.003 | 0.118 | 0.040 | N/A |
| $-4$ | 0.000 | 0.877 | +0.877 | 0.883 | 1.000 | 0.002 | +0.002 | 0.128 | 0.030 | N/A |
| $-3$ | 0.000 | 0.190 | +0.190 | 0.211 | 0.500 | 0.008 | +0.008 | 0.098 | 0.040 | N/A |
| $-2$ | 0.000 | 0.115 | +0.115 | 0.151 | 0.185 | 0.004 | +0.004 | 0.114 | 0.050 | N/A |
| $-1$ | 0.000 | 0.000 | +0.000 | 0.000 | 0.000 | 0.000 | +0.000 | 0.000 | 0.000 | N/A |
| $0$ | 1.771 | 1.805 | +0.033 | 0.102 | 1.000 | 1.815 | +0.043 | 0.118 | 1.000 | 0.925 |
| $+1$ | 2.166 | 2.153 | -0.013 | 0.101 | 1.000 | 2.181 | +0.015 | 0.104 | 1.000 | 0.945 |
| $+2$ | 2.396 | 2.531 | +0.135 | 0.173 | 1.000 | 2.429 | +0.032 | 0.108 | 1.000 | 0.935 |
| $+3$ | 2.560 | 2.831 | +0.271 | 0.295 | 1.000 | 2.540 | -0.020 | 0.114 | 1.000 | 0.955 |
| $+4$ | 3.537 | 3.283 | -0.254 | 0.288 | 1.000 | 3.537 | -0.001 | 0.130 | 1.000 | 0.950 |
| $5+$ | 3.810 | 4.396 | +0.586 | 0.600 | 1.000 | 3.764 | -0.046 | 0.135 | 1.000 | 0.920 |

### Econometric Assessment of Results:
1. **Pre-Treatment Periods ($k < 0$):**
   - True effect is zero across all pre-treatment periods under the parallel trends DGP.
   - TWFE exhibits severe positive bias and distortion at early relative periods: at $k \le -5$ (bias +1.289, rejection rate 1.000) and $k = -4$ (bias +0.877, rejection rate 1.000). At $k = -3$, TWFE rejects zero in 50.0% of draws (bias +0.190). At $k = -2$, rejection rate is 18.5% (bias +0.115). An applied researcher evaluating parallel trends via standard TWFE would erroneously reject the null hypothesis in 100% of samples at $k \le -4$.
   - Sun-Abraham (2021) Interaction-Weighted estimator demonstrates negligible pre-trend bias (between +0.002 and +0.008 across all lead periods). Rejection rates range from 0.030 to 0.050, matching nominal 5% size.
2. **Post-Treatment Periods ($k \ge 0$):**
   - At $k = 0$ and $k = 1$, TWFE bias is modest (+0.033 and -0.013).
   - At $k = 2$ and $k = 3$, TWFE develops positive bias (+0.135 and +0.271).
   - At $k = 4$, TWFE shows negative bias of -0.254, understating the true effect (3.283 versus true estimand 3.537).
   - At $k \ge 5$ (lag bin), TWFE substantially overstates the true bin estimand (+0.586 bias; mean 4.396 versus true 3.810).
   - Sun-Abraham maintains minimal bias across all horizons (between -0.046 and +0.043), with empirical 95% confidence interval coverage between 92.0% and 95.5% (averaging 93.8%), aligning closely with nominal coverage.

---

## 3. Primary Citation Audit and Verification

Every citation in the repository was re-verified against Crossref metadata or primary publisher catalogs.

| Key | Fields Checked | Primary URL Consulted | Outcome | Notes / Action Taken |
| :--- | :--- | :--- | :---: | :--- |
| **Cattaneo, Crump, Farrell, and Feng (2024)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `https://pubs.aeaweb.org/doi/10.1257/aer.20221576` | **Corrected** | Corrected from *Review of Economic Studies* 91(4), 2135-2166, DOI 10.1093/restud/rdad076 to *American Economic Review* 114(5), 1488-1514, DOI 10.1257/aer.20221576 across all files. |
| **Abadie, Diamond, and Hainmueller (2010)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `http://www.tandfonline.com/doi/abs/10.1198/jasa.2009.ap08746` | **Corrected** | Corrected terminal digit in DOI from `ap08740` (returned HTTP 404) to `ap08746`. Confirmed on Taylor and Francis / JASA. |
| **Pisati (2004)** | Title, Author, Year, Journal, Vol, Issue, Pages, DOI | `https://doi.org/10.1177/1536867x0400400401` | **Corrected** | Corrected volume, issue, and pagination from 4(2), 180-194 to 4(4), 361-378, DOI 10.1177/1536867X0400400401 in Stata and spatial docs. |
| **International Monetary Fund (2024)** | Title, Institution, Year, Publisher, DOI | `https://elibrary.imf.org/display/book/9798400255892/9798400255892.xml` | **Confirmed** | *World Economic Outlook: Policy Pivot, Rising Threats* (October 2024), DOI 10.5089/9798400255892.081. |
| **Calonico, Cattaneo, and Titiunik (2014)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `http://doi.wiley.com/10.3982/ECTA11757` | **Confirmed** | *Econometrica* 82(6), 2295-2326, DOI 10.3982/ECTA11757. |
| **Calonico, Cattaneo, and Titiunik (2015)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `https://www.tandfonline.com/doi/full/10.1080/01621459.2015.1017578` | **Confirmed** | *Journal of the American Statistical Association* 110(512), 1753-1769, DOI 10.1080/01621459.2015.1017578. |
| **Goodman-Bacon (2021)** | Title, Author, Year, Journal, Vol, Issue, Pages, DOI | `https://linkinghub.elsevier.com/retrieve/pii/S0304407621001445` | **Confirmed** | *Journal of Econometrics* 225(2), 254-277, DOI 10.1016/j.jeconom.2021.03.014. |
| **Callaway and Sant'Anna (2021)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `https://linkinghub.elsevier.com/retrieve/pii/S0304407620303948` | **Confirmed** | *Journal of Econometrics* 225(2), 200-230, DOI 10.1016/j.jeconom.2020.12.001. Added to README references. |
| **Sun and Abraham (2021)** | Title, Authors, Year, Journal, Vol, Issue, Pages, DOI | `https://linkinghub.elsevier.com/retrieve/pii/S030440762030378X` | **Confirmed** | *Journal of Econometrics* 225(2), 175-199, DOI 10.1016/j.jeconom.2020.09.006. |
| **Jorda (2005)** | Title, Author, Year, Journal, Vol, Issue, Pages, DOI | `https://pubs.aeaweb.org/doi/10.1257/0002828053828518` | **Confirmed** | *American Economic Review* 95(1), 161-182, DOI 10.1257/0002828053828518. |
| **Anselin (1988)** | Title, Author, Year, Publisher, Series, DOI | `http://link.springer.com/10.1007/978-94-015-7799-1` | **Confirmed** | *Spatial Econometrics: Methods and Models*, Studies in Operational Regional Science, Kluwer, DOI 10.1007/978-94-015-7799-1. |
| **Robinson (1974)** | Title, Author, Year, Journal, Vol, Pages, OCLC | `https://www.worldcat.org/title/1753177` | **Confirmed** | *International Yearbook of Cartography* 14, 145-155, Kirschbaum Verlag, OCLC: 1753177. |
| **Tufte (1983)** | Title, Author, Year, Publisher, LCCN, ISBN | `https://lccn.loc.gov/83081490` | **Confirmed** | *The Visual Display of Quantitative Information*, Graphics Press, LCCN: 83081490, ISBN: 978-0-9613921-4-7. |
| **Tufte (2006)** | Title, Author, Year, Publisher, LCCN, ISBN | `https://lccn.loc.gov/2006925585` | **Confirmed** | *Beautiful Evidence*, Graphics Press, LCCN: 2006925585, ISBN: 978-0-9613921-7-8. |
| **Naqvi (2022)** | Title, Author, Year, Archive, RePEc Handle | `https://ideas.repec.org/c/boc/bocode/s459091.html` | **Confirmed** | BIMAP: Stata module to produce bivariate choropleth maps, Boston College SSC S459091. |
| **Rambachan and Roth (2023)** | Methodological Scope | N/A | **Removed** | Dropped from event study headers because the code implements dynamic estimation, not the Rambachan-Roth parallel trends sensitivity bounds. |

---

## 4. Cross-Language Parity Coverage Matrix

| Exhibit Module | Python (`.py`) | R (`.R`) | Stata (`.do`) | LaTeX (`.tex`) | Parity Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Event Studies (Staggered DiD) | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Regression Discontinuity | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Synthetic Control | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Binscatters | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Coefficient Plots | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Tufte Minimal Boxplot / Rug | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Slopegraphs | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| State Tile Grid Cartogram | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Regional Lattice Choropleth | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Bivariate Choropleth | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Global Economies (IMF WEO) | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Impulse Response Functions | Yes | Yes | Yes | N/A | Full Tri-Language Parity |
| Sparklines | Yes | Yes | Yes | Yes | Complete Quad-Language Parity |
| Causal DAGs | N/A | N/A | N/A | Yes | Standalone TikZ |
| Rollout Timelines | N/A | N/A | N/A | Yes | Standalone TikZ |
