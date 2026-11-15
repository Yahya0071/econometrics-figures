* Publication-Grade Regression Discontinuity (RD) Plots in Stata
* Adheres to Gastel & Day exhibit standards and Calonico, Cattaneo, and Titiunik (2014, 2015)
*
* Required Stata Packages (install via SSC before running):
*   ssc install rdrobust, replace
*   ssc install lpdensity, replace
*
* Citations:
* - Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals
*   for Regression-Discontinuity Designs. Econometrica, 82(6), 2295-2326.
*   DOI: 10.3982/ECTA11757
* - Calonico, S., M. D. Cattaneo, and R. Titiunik (2015). Optimal Data-Driven Regression
*   Discontinuity Plots. Journal of the American Statistical Association, 110(512), 1753-1769.
*   DOI: 10.1080/01621459.2015.1017578

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE SYNTHETIC SHARP RD MICRODATA
* ==============================================================================
local n = 2000
local cutoff = 0.0
local true_jump = 2.5

set obs `n'
gen x = rnormal(0, 1.5)
gen d = (x >= `cutoff')
gen mu = 1.2 + 1.8 * x - 0.3 * (x^2) + `true_jump' * d
gen y = mu + rnormal(0, 0.8)

* ==============================================================================
* 2. NONPARAMETRIC RD ESTIMATION
* ==============================================================================
* Optimal bandwidth selection and robust bias-corrected confidence intervals
rdrobust y x, c(`cutoff') p(1) kernel(triangular)

local tau_hat : display %4.2f e(tau_cl)
local se_hat : display %4.2f e(se_tau_rb)
local p_val : display %4.3f e(pv_rb)
local bw_l : display %4.2f e(h_l)
local n_eff = e(N_h_l) + e(N_h_r)

* ==============================================================================
* 3. PUBLICATION EXHIBIT VIA RDPLOT
* ==============================================================================
* Generates data-driven binned scatter and polynomial regression curves
rdplot y x, c(`cutoff') p(1) h(`bw_l') kernel(triangular) ///
    graph_options( ///
        title("") subtitle("") ///
        xtitle("Running Variable Relative to Threshold (c = 0)", size(small)) ///
        ytitle("Outcome Measure (y)", size(small)) ///
        xline(`cutoff', lcolor(cranberry) lpattern(dash) lwidth(thin)) ///
        graphregion(color(white)) bgcolor(white) ///
        legend(off) ///
        note("Notes: Scatter points depict sample means grouped into optimal data-driven quantile-spaced bins" ///
             "(Calonico, Cattaneo, and Titiunik, 2014, 2015). Solid curves represent local linear regressions estimated with" ///
             "triangular kernel within bandwidth h = `bw_l'. Robust bias-corrected estimate: tau = `tau_hat' (SE = `se_hat', p = `p_val')." ///
             "Effective sample size within bandwidth: N = `n_eff'; total sample size: N = `n'.", ///
             size(vsmall) span) ///
    )

* ==============================================================================
* 4. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "rd_plot_stata.pdf", as(pdf) replace
graph export "rd_plot_stata.png", as(png) replace width(2400)
