* Publication-Grade Slopegraph in Stata
* Adheres to Edward Tufte's table-graphic principles (Tufte, 1983)
*
* Citations:
* - Tufte, E. R. (1983). The Visual Display of Quantitative Information.
*   Cheshire, CT: Graphics Press. LCCN: 83081490. ISBN: 978-0-9613921-4-7.

clear all
set more off

* ==============================================================================
* 1. INPUT SLAPEGRAPH DATA
* ==============================================================================
input str15 state pre post treated
"California"     11.2 13.8 1
"New York"       10.8 12.9 1
"New Jersey"      9.4 11.1 1
"Massachusetts"   8.9  9.2 0
"Illinois"        8.1  7.9 0
"Ohio"            7.4  7.1 0
"Texas"           6.8  6.5 0
"Florida"         5.9  5.7 0
end

* Reshape to long format for paired line plotting
gen id = _n
reshape long val, i(id state treated) j(period, string)
gen time = (period == "post")

label define timelbl 0 "Pre-Reform" 1 "Post-Reform"
label values time timelbl

* Generate coordinate labels for direct endpoint typography
gen lbl = state + " " + string(val, "%3.1f")

* ==============================================================================
* 2. PUBLICATION EXHIBIT (Tufte Slopegraph with Zero Chartjunk)
* ==============================================================================
twoway ///
    (line val time if treated == 0, cmissing(n) connect(L) lcolor(gs10) lwidth(medium)) ///
    (line val time if treated == 1, cmissing(n) connect(L) lcolor("213 94 0") lwidth(medthick)) ///
    (scatter val time if treated == 0 & time == 0, msymbol(circle) mcolor(gs8) msize(small) mlabel(lbl) mlabpos(9) mlabcolor(gs6) mlabsize(vsmall)) ///
    (scatter val time if treated == 0 & time == 1, msymbol(circle) mcolor(gs8) msize(small) mlabel(lbl) mlabpos(3) mlabcolor(gs6) mlabsize(vsmall)) ///
    (scatter val time if treated == 1 & time == 0, msymbol(circle) mcolor("213 94 0") msize(small) mlabel(lbl) mlabpos(9) mlabcolor("213 94 0") mlabsize(vsmall)) ///
    (scatter val time if treated == 1 & time == 1, msymbol(circle) mcolor("213 94 0") msize(small) mlabel(lbl) mlabpos(3) mlabcolor("213 94 0") mlabsize(vsmall)), ///
    xlabel(0 "Pre-Reform" 1 "Post-Reform", noticks labsize(small)) ///
    xscale(range(-0.5 1.5)) ///
    yscale(off) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(off) ///
    note("Notes: Tufte (1983) slopegraph exhibit. Vermillion trajectories denote treated jurisdictions" ///
         "experiencing policy reform; gray trajectories denote control jurisdictions." ///
         "Values report effective state tax revenue share as percentage of gross state product.", ///
         size(vsmall) span)

* ==============================================================================
* 3. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "slopegraph_stata.pdf", as(pdf) replace
graph export "slopegraph_stata.png", as(png) replace width(2400)
