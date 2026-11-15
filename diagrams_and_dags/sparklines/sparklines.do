* Publication-Grade Sparklines in Stata
* Adheres to Edward Tufte's principles in Beautiful Evidence (2006):
* word-sized, data-dense graphics designed for tabular integration.
*
* Citations:
* - Tufte, E. R. (2006). Beautiful Evidence. Cheshire, CT: Graphics Press.
*   LCCN: 2006925585. ISBN: 978-0-9613921-7-8.

clear all
set more off

* ==============================================================================
* 1. INPUT 12-PERIOD MACROECONOMIC SERIES
* ==============================================================================
input t inflation unemployment federal_funds oil_price
 1 1.8 6.2 0.1 52.1
 2 1.9 5.8 0.1 64.3
 3 2.1 5.3 0.1 57.0
 4 2.3 4.9 0.1 39.7
 5 2.4 4.1 0.2 68.1
 6 4.7 8.1 0.1 94.5
 7 7.0 5.4 0.1 82.1
 8 8.9 3.9 1.6 77.6
 9 6.5 3.6 5.1 85.2
10 3.7 3.7 5.3 78.4
11 3.1 3.9 5.1 75.1
12 2.6 4.1 4.6 71.3
end

* ==============================================================================
* 2. GENERATE SPARKLINES FOR EACH SERIES
* ==============================================================================
local series "inflation unemployment federal_funds oil_price"

foreach var of local series {
    quietly {
        egen min_val = min(`var')
        egen max_val = max(`var')
        gen is_min = (`var' == min_val)
        gen is_max = (`var' == max_val)
        gen is_end = (_n == _N)
    }
    
    twoway ///
        (line `var' t, lcolor("34 34 34") lwidth(medthick)) ///
        (scatter `var' t if is_min == 1, msymbol(circle) mcolor("213 94 0") msize(medium)) ///
        (scatter `var' t if is_max == 1, msymbol(circle) mcolor("0 114 178") msize(medium)) ///
        (scatter `var' t if is_end == 1, msymbol(circle) mcolor("34 34 34") msize(medium)), ///
        xscale(off) ///
        yscale(off) ///
        graphregion(color(white)) bgcolor(white) ///
        legend(off)
        
    graph export "spark_`var'_stata.pdf", as(pdf) replace
    graph export "spark_`var'_stata.png", as(png) replace width(800)
    
    drop min_val max_val is_min is_max is_end
}
