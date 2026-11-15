* Publication-Grade Synthetic Control Method in Stata
* Adheres to Gastel & Day exhibit standards and Abadie, Diamond, and Hainmueller (2010)
*
* Required Stata Packages (install via SSC before running):
*   ssc install synth, replace
*   ssc install synth_runner, replace
*
* Citations:
* - Abadie, A., A. Diamond, and J. Hainmueller (2010). Synthetic Control Methods for
*   Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program.
*   Journal of the American Statistical Association, 105(490), 493-505.
*   DOI: 10.1198/jasa.2009.ap08746

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE SYNTHETIC PANEL (1 Treated Unit, 20 Donors, 25 Periods)
* ==============================================================================
local n_units = 21
local n_pre = 15
local n_post = 10
local n_total = `n_pre' + `n_post'

set obs `n_units'
gen unit = _n

* Expand to panel structure
expand `n_total'
bysort unit: gen time = _n

* Common unobserved dynamic factors
gen f1 = sin(time / 3.0) * 2.0
gen f2 = 0.3 * time

* Donor unit idiosyncratic loadings and noise
gen loading1 = runiform(0.2, 1.2)
gen loading2 = runiform(0.2, 1.2)
bysort unit: replace loading1 = loading1[1]
bysort unit: replace loading2 = loading2[1]

gen outcome = 5.0 + loading1 * f1 + loading2 * f2 + rnormal(0, 0.4)

* Construct treated unit (unit 1) as convex combination of donors 2 to 5 plus policy shock
* True donor weights: 0.4 on unit 2, 0.3 on unit 3, 0.2 on unit 4, 0.1 on unit 5
tempfile fulldata
save `fulldata'

* Generate synthetic treated trajectory
keep if inlist(unit, 2, 3, 4, 5)
gen w = 0.4 if unit == 2
replace w = 0.3 if unit == 3
replace w = 0.2 if unit == 4
replace w = 0.1 if unit == 5
collapse (sum) outcome = outcome [aw = w], by(time)
gen unit = 1
gen noise = rnormal(0, 0.3)
replace outcome = outcome + noise
drop noise

* Add treatment effect divergence after t = 15
gen post_shock = 1.2 + 0.3 * (time - `n_pre') if time > `n_pre'
replace outcome = outcome + post_shock if time > `n_pre'
drop post_shock

tempfile treated_unit
save `treated_unit'

use `fulldata', clear
drop if unit == 1
append using `treated_unit'
sort unit time

* ==============================================================================
* 2. SYNTHETIC CONTROL ESTIMATION
* ==============================================================================
tsset unit time

* Pre-treatment predictor list
local pre_vars ""
forvalues t = 1/`n_pre' {
    local pre_vars "`pre_vars' outcome(`t')"
}

* Estimate synthetic weights and save trajectories
synth outcome `pre_vars', trunit(1) trperiod(16) keep("synth_out.dta", replace)

* ==============================================================================
* 3. PUBLICATION EXHIBIT: TRAJECTORIES AND GAPS
* ==============================================================================
preserve
use "synth_out.dta", clear
rename _time time
rename _Y_treated y_treated
rename _Y_synthetic y_synth

gen gap = y_treated - y_synth

* Trajectory Exhibit
twoway ///
    (line y_treated time, lcolor("0 114 178") lwidth(medthick)) ///
    (line y_synth time, lcolor("213 94 0") lpattern(dash) lwidth(medthick)), ///
    xline(15.5, lcolor(gs8) lpattern(shortdash) lwidth(thin)) ///
    xtitle("Time Period (t)", size(small)) ///
    ytitle("Outcome Level", size(small)) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(order(1 "Treated Unit" 2 "Synthetic Control") ring(0) pos(11) region(lcolor(white))) ///
    note("Notes: Synthetic control estimated via constrained optimization minimizing pre-intervention MSE" ///
         "(Abadie, Diamond, and Hainmueller, 2010). Intervention begins at t = 16 (dashed vertical line)." ///
         "Sample: 1 treated unit, 20 donor pool units; 15 pre-treatment periods, 10 post-treatment periods.", ///
         size(vsmall) span)

graph export "synthetic_control_stata.pdf", as(pdf) replace
graph export "synthetic_control_stata.png", as(png) replace width(2400)
restore

erase "synth_out.dta"
