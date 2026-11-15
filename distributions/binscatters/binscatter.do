* Publication-Grade Binned Scatter Plot (Binscatter) in Stata
* Adheres to Gastel & Day exhibit standards and Cattaneo, Crump, Farrell, and Feng (2024)
*
* Required Stata Packages (install via SSC before running):
*   ssc install binsreg, replace
*   ssc install binscatter, replace
*
* Citations:
* - Cattaneo, M. D., R. K. Crump, M. H. Farrell, and Y. Feng (2024). On Binscatter.
*   American Economic Review, 114(5), 1488-1514.
*   DOI: 10.1257/aer.20221576
* - Stepner, M. (2013). BINSCATTER: Stata module to generate binned scatterplots.
*   Statistical Software Components S457709, Boston College.

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE MICRODATA WITH TWO SUBGROUPS
* ==============================================================================
local n = 5000
set obs `n'

gen x = rnormal(10.0, 1.2)
gen group = (runiform() > 0.5)

* Group-specific conditional expectation functions:
* Group 0 (A): Intercept 2.0, slope 0.65
* Group 1 (B): Intercept 1.2, slope 0.82
gen y = 2.0 + 0.65 * x + rnormal(0, 0.9) if group == 0
replace y = 1.2 + 0.82 * x + rnormal(0, 0.9) if group == 1

label define grplbl 0 "Group A" 1 "Group B"
label values group grplbl

* ==============================================================================
* 2. NONPARAMETRIC BINSCATTER VIA BINSREG (Cattaneo et al., 2024)
* ==============================================================================
* Optimal data-driven quantile bin selection with linear fits and confidence bands
binsreg y x, by(group) dots(1 1) line(1 1) ci(3 3) ///
    legend(order(1 "Group A" 2 "Group B") ring(0) pos(11) region(lcolor(white))) ///
    plotx(x) ///
    plotoptions( ///
        title("") subtitle("") ///
        xtitle("Policy Covariate / Continuous Predictor (x)", size(small)) ///
        ytitle("Observed Economic Outcome (y)", size(small)) ///
        graphregion(color(white)) bgcolor(white) ///
        note("Notes: Binned scatter plot estimated using optimal data-driven partitioning (Cattaneo, Crump, Farrell, and Feng, 2024)." ///
             "Dots represent mean outcomes within quantile-spaced bins. Solid lines depict local linear fits." ///
             "Shaded ribbons denote 95% uniform confidence intervals. Total sample: N = 5,000 observations.", ///
             size(vsmall) span) ///
    )

graph export "binscatter_binsreg_stata.pdf", as(pdf) replace
graph export "binscatter_binsreg_stata.png", as(png) replace width(2400)

* ==============================================================================
* 3. CLASSIC BINSCATTER (Stepner, 2013)
* ==============================================================================
binscatter y x, by(group) nquantiles(20) line(lfit) ///
    xtitle("Policy Covariate / Continuous Predictor (x)", size(small)) ///
    ytitle("Observed Economic Outcome (y)", size(small)) ///
    legend(order(1 "Group A" 2 "Group B") ring(0) pos(11) region(lcolor(white))) ///
    graphregion(color(white)) bgcolor(white) ///
    note("Notes: Binned scatter plot constructed using 20 equal-sized quantile bins (Stepner, 2013)." ///
         "Solid lines depict subgroup-specific OLS linear regressions. Sample: N = 5,000 observations.", ///
         size(vsmall) span)

graph export "binscatter_stata.pdf", as(pdf) replace
graph export "binscatter_stata.png", as(png) replace width(2400)
