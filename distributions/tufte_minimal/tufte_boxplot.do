* Publication-Grade Tufte Minimalist Boxplot in Stata
* Adheres to Edward Tufte's data-ink maximization principles (Tufte, 1983)
*
* Citations:
* - Tufte, E. R. (1983). The Visual Display of Quantitative Information.
*   Cheshire, CT: Graphics Press. LCCN: 83081490. ISBN: 978-0-9613921-4-7.

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE WAGE DISTRIBUTIONS ACROSS EDUCATION CATEGORIES
* ==============================================================================
local n_per_group = 300
local total_n = `n_per_group' * 4

set obs `total_n'
gen group = ceil(_n / `n_per_group')

label define grplbl 1 "High School" 2 "Some College" 3 "Bachelor Degree" 4 "Graduate Degree"
label values group grplbl

* Generate log-normal wage distributions
gen wage = exp(rnormal(ln(16.5), 3.5 / 16.5)) if group == 1
replace wage = exp(rnormal(ln(21.0), 5.0 / 21.0)) if group == 2
replace wage = exp(rnormal(ln(32.5), 8.5 / 32.5)) if group == 3
replace wage = exp(rnormal(ln(46.0), 12.0 / 46.0)) if group == 4

* ==============================================================================
* 2. CALCULATE PERCENTILES (Median, IQR, Whiskers)
* ==============================================================================
egen p2 = pctile(wage), p(2.5) by(group)
egen p25 = pctile(wage), p(25) by(group)
egen p50 = pctile(wage), p(50) by(group)
egen p75 = pctile(wage), p(75) by(group)
egen p98 = pctile(wage), p(97.5) by(group)

* Collapse to summary records for rendering
collapse (mean) p2 p25 p50 p75 p98, by(group)

* ==============================================================================
* 3. PUBLICATION EXHIBIT: TUFTE MINIMAL MIDGAP BOXPLOT
* ==============================================================================
* Lower whisker: p2 to p25 (solid thin line)
* Upper whisker: p75 to p98 (solid thin line)
* White space between p25 and p75 represents the interquartile range (IQR)
* Single dot at p50 marks the median
twoway ///
    (rspike p2 p25 group, lcolor("51 51 51") lwidth(thin)) ///
    (rspike p75 p98 group, lcolor("51 51 51") lwidth(thin)) ///
    (scatter p50 group, msymbol(circle) mcolor("17 17 17") msize(small)), ///
    xlabel(1 "High School" 2 "Some College" 3 "Bachelor Degree" 4 "Graduate Degree", noticks) ///
    xtitle("Educational Attainment Tier", size(small)) ///
    ytitle("Hourly Wage ($ USD)", size(small)) ///
    yscale(range(0 80)) ///
    ylabel(0(20)80, angle(0)) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(off) ///
    note("Notes: Tufte (1983) minimalist boxplot. Whiskers extend from the 2.5th to 25th percentile and from the" ///
         "75th to 97.5th percentile. The white-space gap between whiskers depicts the interquartile range (IQR)." ///
         "Solid black circle indicates the subgroup median. Sample: N = 1,200 microdata observations.", ///
         size(vsmall) span)

* ==============================================================================
* 4. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "tufte_boxplot_stata.pdf", as(pdf) replace
graph export "tufte_boxplot_stata.png", as(png) replace width(2400)
