* Publication-Grade Local Projections Impulse Response Functions (IRF) in Stata
* Adheres to Gastel & Day exhibit standards and Jorda (2005)
*
* Citations:
* - Jorda, O. (2005). Estimation and Inference of Impulse Responses by Local Projections.
*   American Economic Review, 95(1), 161-182.
*   DOI: 10.1257/0002828053828518

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE MACROECONOMIC TIME SERIES (250 Quarters)
* ==============================================================================
local t_periods = 250
set obs `t_periods'
gen t = _n
tsset t

gen shock = rnormal(0, 1.0)
gen pi = 0
gen y = 0

* Generate dynamic autoregressive transmission
forvalues i = 2/`t_periods' {
    local prev = `i' - 1
    quietly {
        replace pi = 0.65 * pi[`prev'] - 0.45 * shock[`prev'] + rnormal(0, 0.4) in `i'
        replace y = 0.70 * y[`prev'] - 0.60 * shock[`prev'] + 0.20 * pi[`prev'] + rnormal(0, 0.5) in `i'
    }
}

* ==============================================================================
* 2. ESTIMATE LOCAL PROJECTIONS WITH NEWEY-WEST HAC STANDARD ERRORS
* ==============================================================================
local max_h = 12

postfile irf_results h beta se ci68_lo ci68_hi ci95_lo ci95_hi using "irf_temp.dta", replace

forvalues h = 0/`max_h' {
    local lags = `h' + 1
    newey F`h'.y shock, lag(`lags')
    local b = _b[shock]
    local s = _se[shock]
    local c68_l = `b' - 1.00 * `s'
    local c68_h = `b' + 1.00 * `s'
    local c95_l = `b' - 1.96 * `s'
    local c95_h = `b' + 1.96 * `s'
    post irf_results (`h') (`b') (`s') (`c68_l') (`c68_h') (`c95_l') (`c95_h')
}
postclose irf_results

* ==============================================================================
* 3. PUBLICATION EXHIBIT
* ==============================================================================
preserve
use "irf_temp.dta", clear

twoway ///
    (rarea ci95_lo ci95_hi h, color("0 114 178%20") lwidth(none)) ///
    (rarea ci68_lo ci68_hi h, color("0 114 178%35") lwidth(none)) ///
    (line beta h, color("0 114 178") lwidth(medthick)) ///
    (scatter beta h, color("0 114 178") msymbol(circle) msize(small)), ///
    yline(0, lcolor(gs8) lpattern(solid) lwidth(thin)) ///
    xlabel(0(2)`max_h') ///
    xtitle("Quarters Since Monetary Policy Shock (h)", size(small)) ///
    ytitle("Response of Real Output (y)", size(small)) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(order(3 "Point Estimate" 2 "68% Confidence Band" 1 "95% Confidence Band") ///
           ring(0) pos(1) col(1) region(lcolor(white))) ///
    note("Notes: Local projections estimated using OLS with Newey-West standard errors (Jorda, 2005)." ///
         "Lags set to h + 1 at each horizon. Shaded bands depict 68% and 95% confidence intervals." ///
         "Sample: T = 250 quarterly periods.", ///
         size(vsmall) span)

graph export "irf_plot_stata.pdf", as(pdf) replace
graph export "irf_plot_stata.png", as(png) replace width(2400)
restore

erase "irf_temp.dta"
