* Publication-Grade US State Tile-Grid Cartogram in Stata
* Adheres to Gastel & Day exhibit standards and Tufte's data-ink principles
*
* Citations:
* - Tufte, E. R. (1983). The Visual Display of Quantitative Information.
*   Cheshire, CT: Graphics Press. LCCN: 83081490. ISBN: 978-0-9613921-4-7.

clear all
set more off
set seed 42

* ==============================================================================
* 1. INPUT 51-JURISDICTION TILE GRID COORDINATES
* ==============================================================================
input str2 state col row
"AK" 0 7
"ME" 11 7
"VT" 10 6
"NH" 11 6
"WA" 1 5
"ID" 2 5
"MT" 3 5
"ND" 4 5
"MN" 5 5
"IL" 6 5
"WI" 7 5
"MI" 8 5
"NY" 9 5
"MA" 10 5
"RI" 11 5
"OR" 1 4
"NV" 2 4
"WY" 3 4
"SD" 4 4
"IA" 5 4
"IN" 6 4
"OH" 7 4
"PA" 8 4
"NJ" 9 4
"CT" 10 4
"CA" 1 3
"UT" 2 3
"CO" 3 3
"NE" 4 3
"MO" 5 3
"KY" 6 3
"WV" 7 3
"VA" 8 3
"MD" 9 3
"DE" 10 3
"AZ" 2 2
"NM" 3 2
"KS" 4 2
"AR" 5 2
"TN" 6 2
"NC" 7 2
"SC" 8 2
"DC" 9 2
"OK" 4 1
"LA" 5 1
"MS" 6 1
"AL" 7 1
"GA" 8 1
"HI" 0 0
"TX" 4 0
"FL" 9 0
end

* Simulate state economic indicator
gen val = round(rnormal(12.5, 3.2), 0.1)

* Compute quintiles
xtile quintile = val, nquantiles(5)

* Label text for each tile (State + Value)
gen lbl = state + char(10) + string(val, "%3.1f")

* ==============================================================================
* 2. PUBLICATION EXHIBIT (Equal-Area Tile Grid)
* ==============================================================================
twoway ///
    (scatter row col if quintile == 1, msymbol(square) msize(vhuge) mcolor("68 1 84") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
    (scatter row col if quintile == 2, msymbol(square) msize(vhuge) mcolor("59 82 139") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
    (scatter row col if quintile == 3, msymbol(square) msize(vhuge) mcolor("33 144 140") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
    (scatter row col if quintile == 4, msymbol(square) msize(vhuge) mcolor("93 200 99") mlabel(lbl) mlabpos(0) mlabcolor(black) mlabsize(vsmall)) ///
    (scatter row col if quintile == 5, msymbol(square) msize(vhuge) mcolor("253 231 37") mlabel(lbl) mlabpos(0) mlabcolor(black) mlabsize(vsmall)), ///
    xscale(range(-1 12) off) ///
    yscale(range(-1 8) off) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(order(1 "1st Quintile (Lowest)" 2 "2nd Quintile" 3 "3rd Quintile" 4 "4th Quintile" 5 "5th Quintile (Highest)") ///
           rows(1) pos(6) size(vsmall) region(lcolor(white))) ///
    note("Notes: Equal-area tile grid cartogram of 50 US states and District of Columbia." ///
         "Shading depicts quintiles of the simulated state economic indicator." ///
         "Text inside tiles reports state abbreviation and observed value.", ///
         size(vsmall) span)

* ==============================================================================
* 3. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "state_tile_grid_stata.pdf", as(pdf) replace
graph export "state_tile_grid_stata.png", as(png) replace width(2400)
