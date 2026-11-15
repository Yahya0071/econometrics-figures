* Publication-Grade Coefficient and Forest Plot in Stata
* Adheres to Gastel & Day exhibit standards and Ben Jann (2014) coefplot framework
*
* Required Stata Packages (install via SSC before running):
*   ssc install coefplot, replace
*
* Citations:
* - Jann, B. (2014). Plotting regression coefficients and other estimates.
*   Stata Journal, 14(4), 708-737.
*   DOI: 10.1177/1536867X1401400402

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE MICRODATA FOR MULTI-MODEL COMPARISON
* ==============================================================================
local n = 1000
set obs `n'

gen firm = _n
gen industry = ceil(runiform() * 5)
gen capital = rnormal(10, 2)
gen controls = rnormal(5, 1)

* Instrumental variable setup
gen z = rnormal(0, 1)
gen treatment = 0.6 * z + 0.2 * controls + rnormal(0, 0.8)
gen outcome = 0.35 * treatment + 0.15 * controls + rnormal(0, 1.2)

* ==============================================================================
* 2. ESTIMATE SPECIFICATIONS ACROSS IDENTIFICATION TIERS
* ==============================================================================
* Model 1: Baseline Bivariate OLS
reg outcome treatment, vce(robust)
estimates store m1

* Model 2: Industry Fixed Effects
reg outcome treatment i.industry, vce(robust)
estimates store m2

* Model 3: Fixed Effects + Firm Controls
reg outcome treatment i.industry controls, vce(robust)
estimates store m3

* Model 4: Instrumental Variables (2SLS)
ivregress 2sls outcome i.industry controls (treatment = z), vce(robust)
estimates store m4

* ==============================================================================
* 3. PUBLICATION EXHIBIT VIA COEFPLOT
* ==============================================================================
coefplot ///
    (m1, label("(1) Baseline OLS") mcolor("0 114 178") ciopts(lcolor("0 114 178" "0 114 178"))) ///
    (m2, label("(2) + Industry FE") mcolor("0 114 178") ciopts(lcolor("0 114 178" "0 114 178"))) ///
    (m3, label("(3) + Controls") mcolor("0 114 178") ciopts(lcolor("0 114 178" "0 114 178"))) ///
    (m4, label("(4) 2SLS / IV") mcolor("213 94 0") ciopts(lcolor("213 94 0" "213 94 0"))), ///
    keep(treatment) horizontal ///
    levels(95 90) ///
    ciopts(lwidth(thin medthick)) ///
    msymbol(circle) msize(medium) ///
    xline(0, lcolor(gs8) lpattern(dash) lwidth(thin)) ///
    xtitle("Estimated Treatment Coefficient (beta)", size(small)) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(ring(0) pos(2) col(1) region(lcolor(white))) ///
    note("Notes: Exhibit plots point estimates alongside dual 90% (thick inner) and 95% (thin outer) confidence intervals." ///
         "Standard errors are robust to heteroskedasticity. Models evaluate specification sensitivity from unadjusted OLS" ///
         "through high-dimensional fixed effects and instrumental variable 2SLS identification." ///
         "Sample: N = 1,000 observations.", ///
         size(vsmall) span)

* ==============================================================================
* 4. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "coefficient_plot_stata.pdf", as(pdf) replace
graph export "coefficient_plot_stata.png", as(png) replace width(2400)
