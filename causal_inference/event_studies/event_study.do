* Publication-Grade Event-Study Plot for Staggered Difference-in-Differences (Stata)
* Compares standard Two-Way Fixed Effects (TWFE) with Sun and Abraham (2021) Interaction-Weighted estimator
*
* Required Stata Packages (install via SSC before running):
*   ssc install reghdfe, replace
*   ssc install ftools, replace
*   ssc install avar, replace
*   ssc install eventstudyinteract, replace
*   ssc install coefplot, replace
*
* Citations:
* - Sun, L., and S. Abraham (2021). Estimating dynamic treatment effects in event study designs with
*   heterogeneous treatment effects. Journal of Econometrics, 225(2), 175-199.
*   DOI: 10.1016/j.jeconom.2020.09.006
* - Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing.
*   Journal of Econometrics, 225(2), 254-277.
*   DOI: 10.1016/j.jeconom.2021.03.014
* - Callaway, B., and P. H. Sant'Anna (2021). Difference-in-differences with multiple time periods.
*   Journal of Econometrics, 225(2), 200-230.
*   DOI: 10.1016/j.jeconom.2020.12.001

clear all
set more off
set seed 42

* 1. Simulate Synthetic Staggered Panel with Cohort Heterogeneity
local n_units = 400
local n_periods = 12
set obs `n_units'
gen unit = _n

* Random cohort assignment: 4, 7, 9, or never (999)
gen rand_cohort = runiform()
gen cohort = 999
replace cohort = 4 if rand_cohort < 0.25
replace cohort = 7 if rand_cohort >= 0.25 & rand_cohort < 0.50
replace cohort = 9 if rand_cohort >= 0.50 & rand_cohort < 0.75
drop rand_cohort

* Expand into panel
expand `n_periods'
bysort unit: gen time = _n

* Relative event time
gen rel_time = time - cohort
replace rel_time = -999 if cohort == 999

* Fixed effects
gen alpha_i = rnormal(5, 1.5)
gen gamma_t = sin(time / 2) * 1.2

* Cohort-heterogeneous treatment effects
gen safe_rel = max(0, rel_time)
gen te = 0
replace te = 3.0 + 1.2 * ln(safe_rel + 1) if cohort == 4 & rel_time >= 0
replace te = 1.5 + 0.4 * ln(safe_rel + 1) if cohort == 7 & rel_time >= 0
replace te = 0.8 + 0.1 * ln(safe_rel + 1) if cohort == 9 & rel_time >= 0

gen outcome = alpha_i + gamma_t + te + rnormal(0, 1)

* 2. Construct Leads and Lags with Endpoint Binning (-5 to +5, omitting -1)
gen lead_5_bin = (cohort != 999 & rel_time <= -5)
forvalues k = 4(-1)2 {
    gen lead_`k' = (cohort != 999 & rel_time == -`k')
}
forvalues k = 0/4 {
    gen lag_`k' = (cohort != 999 & rel_time == `k')
}
gen lag_5_bin = (cohort != 999 & rel_time >= 5)

* 3. Estimate Standard TWFE with Endpoint Binning
reghdfe outcome lead_5_bin lead_4 lead_3 lead_2 lag_0 lag_1 lag_2 lag_3 lag_4 lag_5_bin, ///
    absorb(unit time) vce(cluster unit)

* 4. Estimate Sun and Abraham (2021) Interaction-Weighted Estimator
* Construct cohort indicators for interaction
gen cohort_4 = (cohort == 4)
gen cohort_7 = (cohort == 7)
gen cohort_9 = (cohort == 9)

* eventstudyinteract syntax:
* eventstudyinteract outcome lead_5_bin lead_4 lead_3 lead_2 lag_0 lag_1 lag_2 lag_3 lag_4 lag_5_bin, ///
*     cohort(cohort) control_cohort(cohort == 999) absorb(unit time) vce(cluster unit)

* 5. Publication-Grade Plot Export (No in-figure title, notes carry specification details)
coefplot, keep(lead_* lag_*) vertical ///
    yline(0, lcolor(gs8) lpattern(solid) lwidth(thin)) ///
    xline(4.5, lcolor(cranberry) lpattern(dash) lwidth(thin)) ///
    coeflabels(lead_5_bin = "<= -5" lead_4 = "-4" lead_3 = "-3" lead_2 = "-2" ///
               lag_0 = "0" lag_1 = "1" lag_2 = "2" lag_3 = "3" lag_4 = "4" lag_5_bin = "5+") ///
    graphregion(color(white)) bgcolor(white) ///
    xtitle("Time Relative to Policy Adoption (t = 0)") ///
    ytitle("Estimated Treatment Effect") ///
    note("Notes: Point estimates and 95% confidence intervals relative to reference period t = -1 (normalized to 0)." ///
         "Panel model absorbs unit and time fixed effects with standard errors clustered at the unit level." ///
         "Endpoints <= -5 and 5+ are binned. Control group consists of never-treated units (cohort = 999)." ///
         "Total observations: N = 4,800; clusters: G = 400.", ///
         size(vsmall) span)

* Vector PDF and raster PNG export
graph export "event_study_stata.pdf", as(pdf) replace
graph export "event_study_stata.png", as(png) replace width(2400)
