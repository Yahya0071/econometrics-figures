# Publication-Grade Figures for Empirical Research

A standardized repository providing publication-ready figure templates and computational scripts in Python, R, Stata, and LaTeX/TikZ. Designed specifically for empirical researchers, graduate students, and applied economists preparing manuscripts for leading academic journals (*AER*, *QJE*, *JFE*, *Review of Economic Studies*) and doctoral theses.

Adheres strictly to the exhibit standards of Gastel and Day (2016), the identification requirements of modern econometrics, and the data-ink maximization principles of Edward Tufte (*The Visual Display of Quantitative Information*, 1983).

---

## Repository Architecture

```text
figures/
├── templates/
│   ├── academic.mplstyle          # Standard journal Matplotlib stylesheet
│   ├── tufte.mplstyle             # Tufte minimalist stylesheet (zero chartjunk)
│   ├── publication_theme.R        # Custom ggplot2 publication theme
│   ├── theme_tufte.R              # Tufte minimalist ggplot2 theme
│   └── stata_publication_scheme.do # Stata graph styling macros
├── causal_inference/
│   ├── event_studies/             # Staggered DiD: TWFE bias vs Sun-Abraham (2021) robust correction
│   ├── regression_discontinuity/  # Sharp RD with binned means and local linear fits
│   └── synthetic_control/         # Trajectories and in-space placebo permutation envelopes
├── distributions/
│   ├── binscatters/               # Quantile binned scatter plots with OLS projections
│   ├── coefficient_plots/         # Multi-model forest plots with 90% and 95% confidence bands
│   ├── tufte_minimal/             # Midgap boxplots (IQR white space) and dot-dash rugs
│   └── slopegraphs/               # Table-graphics with in-line typography and no detached legends
├── spatial_maps/
│   ├── global_economies_map.py    # IMF World Economic Outlook (Advanced vs Emerging vs Developing)
│   ├── state_tile_grid.py         # Equal-area US state tile-grid cartogram
│   ├── regional_choropleth.py     # Commuting zone spatial lattice choropleth
│   ├── bivariate_choropleth.py    # 3x3 bivariate choropleth with 45-degree rotated diamond legend
│   ├── global_economies_map.R     # R Robinson projected global economic taxonomy map
│   ├── choropleth_map.R           # R sf & geom_sf spatial mapping implementation
│   ├── bivariate_choropleth.R     # R biscale & cowplot bivariate choropleth pipeline
│   ├── stata_global_map.do        # Stata Robinson projected world country mapping
│   ├── stata_spatial_map.do       # Stata multi-layer spatial mapping pipeline (spmap, grmap)
│   └── stata_bimap.do             # Stata bivariate choropleths (Asjad Naqvi's bimap)
├── time_series/
│   └── impulse_responses/         # Local projections IRF with HAC standard error bands
└── diagrams_and_dags/
    ├── causal_dags/               # Standalone TikZ diagrams for confounding, IV, and colliders
    ├── timelines/                 # Policy rollout and staggered adoption schematics
    └── sparklines/                # Word-sized data-dense graphics for table integration
```

---

## Core Methodological Standards

### 1. Dual Vector and Raster Export
Every script simultaneously exports two complementary formats:
- **Vector PDF:** Retains infinite resolution for direct embedding into LaTeX manuscripts and top journal production workflows.
- **300 DPI Raster PNG:** Provides high-density rasterization for immediate desktop preview, presentation slides, and markdown documentation.

### 2. Modern Staggered Difference-in-Differences
Under staggered treatment timing with heterogeneous adoption effects across cohorts, standard Two-Way Fixed Effects (TWFE) leads-and-lags specifications suffer from negative weighting. Earlier-treated units act as controls for later-treated units, contaminating both pre-trend diagnostic tests and post-treatment dynamic estimates (Goodman-Bacon, 2021).

The repository implements:
- **TWFE Baseline:** Fully documented with endpoint binning ($k \le -5$ and $k \ge 5$).
- **Sun and Abraham (2021) Interaction-Weighted Estimator:** Interacts relative event time indicators with adoption cohort indicators, restricts the comparison pool strictly to never-treated units, and aggregates cohort-specific effects using clean sample shares. Standard errors are computed using the cluster-robust delta-method covariance matrix.
- **Direct Parity in R and Stata:** Implemented in R via `fixest::sunab` and documented in Stata via `eventstudyinteract` and `reghdfe`.

### 3. Tufte Minimalist Principles
- **Direct Endpoint Typography:** Legends are replaced with direct labels positioned immediately adjacent to line endpoints wherever feasible (event studies, synthetic control, binscatters, impulse responses, and slopegraphs).
- **Elimination of In-Figure Titles:** Titles and subtitles are placed exclusively in the self-contained note and caption block, mirroring professional journal typesetting.
- **Data-Ink Ratio:** Heavy gridlines and decorative frames are suppressed. Tufte midgap boxplots convey the interquartile range through empty white space.

### 4. Spatial Econometrics and Projections
- **Equal-Area and Robinson Projections:** World maps employ the Robinson compromise projection (`+proj=robin`) to avoid Mercator equatorial distortion. US spatial maps apply Albers Equal Area Conic (`EPSG:5070`).
- **Cartograms for Landmass Bias:** State tile-grid cartograms provide equal visual representation across jurisdictions, preventing sparsely populated landmass from dominating visual attention.
- **Bivariate Spatial Correlation:** Replicates the signature 45-degree diamond legend of Asjad Naqvi's `bimap` and Joshua Stevens (2015), classifying two continuous variables into a joint 3x3 tercile matrix.

---

## Quickstart

### Python Environment
Recommended: Python 3.11, 3.12, or 3.13. On Python 3.14, pure-Python wheels function properly while C-extension geospatial packages may depend on pre-compiled wheels.

Install required dependencies:
```bash
pip install numpy pandas matplotlib scipy statsmodels geopandas shapely pyproj pyogrio
```

Run any figure generator from the repository root with strict warning enforcement:
```bash
# Causal Inference
python -W error causal_inference/event_studies/event_study.py
python -W error causal_inference/regression_discontinuity/rd_plots.py
python -W error causal_inference/synthetic_control/synthetic_control.py

# Distributions and Tufte Minimalist Exhibits
python -W error distributions/binscatters/binscatter.py
python -W error distributions/coefficient_plots/coefficient_plots.py
python -W error distributions/tufte_minimal/tufte_boxplot.py
python -W error distributions/slopegraphs/slopegraph.py

# Spatial Maps and Cartograms
python -W error spatial_maps/global_economies_map.py
python -W error spatial_maps/state_tile_grid.py
python -W error spatial_maps/regional_choropleth.py
python -W error spatial_maps/bivariate_choropleth.py

# Time Series and Table-Graphics
python -W error time_series/impulse_responses/irf_plots.py
python -W error diagrams_and_dags/sparklines/sparklines.py
```

### R Environment
Required libraries:
```r
install.packages(c("ggplot2", "sf", "biscale", "cowplot", "patchwork", "fixest"))
```

Execute any generator directly:
```bash
Rscript causal_inference/event_studies/event_study.R
Rscript distributions/binscatters/binscatter.R
Rscript spatial_maps/global_economies_map.R
```

### Stata Environment
Required SSC packages:
```stata
ssc install reghdfe, replace
ssc install ftools, replace
ssc install eventstudyinteract, replace
ssc install coefplot, replace
ssc install bimap, replace
ssc install spmap, replace
ssc install shp2dta, replace
ssc install geo2xy, replace
```

### LaTeX / TikZ Compilation
Compile standalone DAGs, timelines, and sparkline tables using pdflatex:
```bash
pdflatex -output-directory=diagrams_and_dags/causal_dags diagrams_and_dags/causal_dags/dag_collider.tex
pdflatex -output-directory=diagrams_and_dags/timelines diagrams_and_dags/timelines/policy_rollout_timeline.tex
```

---

## Continuous Integration and Verification

The repository includes a comprehensive GitHub Actions workflow (`.github/workflows/ci.yml`) enforcing strict publication quality:
1. **Python Matrix (3.11, 3.12, 3.13, 3.14):** All 13 Python generators are executed with `python -W error`, ensuring zero runtime warnings or deprecations. Python 3.14 is monitored with `continue-on-error` while geospatial wheel availability stabilizes.
2. **R Script Validation:** All R scripts are executed on Ubuntu runners using `r-lib/actions/setup-r@v2`.
3. **LaTeX / TikZ Compilation:** Standalone TikZ DAGs, policy timelines, and sparkline tables are compiled using `pdflatex` via TeX Live.
4. **Style and Invariant Linting:** An automated audit verifies zero em dashes (\u2014, \u2013) and zero occurrences of prohibited AI filler words (`delve`, `pivotal`, `tapestry`, `intricate`, `multifaceted`).
5. **Stata Transparency:** Stata scripts cannot be executed on standard GitHub Actions runners due to proprietary licensing; they are linted locally for exact syntax, package declarations, and directory independence.

---

## References

- Abadie, A., A. Diamond, and J. Hainmueller (2010). Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program. *Journal of the American Statistical Association*, 105(490), 493-505. DOI: 10.1198/jasa.2009.ap08746
- Anselin, L. (1988). *Spatial Econometrics: Methods and Models*. Dordrecht: Kluwer Academic Publishers. DOI: 10.1007/978-94-015-7799-1
- Callaway, B., and P. H. C. Sant'Anna (2021). Difference-in-Differences with Multiple Time Periods. *Journal of Econometrics*, 225(2), 200-230. DOI: 10.1016/j.jeconom.2020.12.001
- Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. *Econometrica*, 82(6), 2295-2326. DOI: 10.3982/ECTA11757
- Calonico, S., M. D. Cattaneo, and R. Titiunik (2015). Optimal Data-Driven Regression Discontinuity Plots. *Journal of the American Statistical Association*, 110(512), 1753-1769. DOI: 10.1080/01621459.2015.1017578
- Cattaneo, M. D., R. K. Crump, M. H. Farrell, and Y. Feng (2024). On Binscatter. *American Economic Review*, 114(5), 1488-1514. DOI: 10.1257/aer.20221576
- Goodman-Bacon, A. (2021). Difference-in-Differences with Variation in Treatment Timing. *Journal of Econometrics*, 225(2), 254-277. DOI: 10.1016/j.jeconom.2021.03.014
- International Monetary Fund (IMF) (2024). *World Economic Outlook: Policy Pivot, Rising Threats*. Washington, DC: International Monetary Fund. DOI: 10.5089/9798400255892.081
- Jorda, O. (2005). Estimation and Inference of Impulse Responses by Local Projections. *American Economic Review*, 95(1), 161-182. DOI: 10.1257/0002828053828518
- Naqvi, A. (2022). BIMAP: Stata module to produce bivariate choropleth maps. Statistical Software Components S459091, Boston College Department of Economics.
- Pisati, M. (2004). Simple Thematic Mapping. *Stata Journal*, 4(4), 361-378. DOI: 10.1177/1536867X0400400401
- Robinson, A. H. (1974). A New Map Projection: Its Development and Characteristics. *International Yearbook of Cartography*, 14, 145-155.
- Sun, L., and S. Abraham (2021). Estimating Dynamic Treatment Effects in Event Study Designs with Heterogeneous Treatment Effects. *Journal of Econometrics*, 225(2), 175-199. DOI: 10.1016/j.jeconom.2020.09.006
- Tufte, E. R. (1983). *The Visual Display of Quantitative Information*. Cheshire, CT: Graphics Press.
- Tufte, E. R. (2006). *Beautiful Evidence*. Cheshire, CT: Graphics Press.
