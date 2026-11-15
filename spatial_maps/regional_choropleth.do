* Publication-Grade Regional Lattice Choropleth Mapping in Stata
* Adheres to Gastel & Day exhibit standards and Anselin (1988)
*
* Required Stata Packages (install via SSC before running):
*   ssc install spmap, replace
*   ssc install shp2dta, replace
*
* Citations:
* - Anselin, L. (1988). Spatial Econometrics: Methods and Models.
*   Dordrecht: Kluwer Academic Publishers. DOI: 10.1007/978-94-015-7799-1
* - Pisati, M. (2004). Simple thematic mapping. Stata Journal, 4(4), 361-378.
*   DOI: 10.1177/1536867X0400400401

clear all
set more off
set seed 42

* ==============================================================================
* 1. SIMULATE REGIONAL LATTICE (5x5 Grid Regions)
* ==============================================================================
local n_regions = 25
set obs `n_regions'

gen id = _n
gen row = ceil(id / 5)
gen col = mod(id - 1, 5) + 1

* Spatially correlated economic indicator
gen spatial_x = col * 10
gen spatial_y = row * 10
gen val = 15.0 + 1.2 * spatial_x + 0.8 * spatial_y + rnormal(0, 4.0)

* ==============================================================================
* 2. CHOROPLETH EXHIBIT (Tile Lattice Representation)
* ==============================================================================
* When boundary shapefiles are available:
* spmap val using "regional_coords.dta", id(id) clmethod(quantile) clnumber(5) ...
*
* Fallback lattice visualization using native Stata vector coordinates:
xtile quintile = val, nquantiles(5)
gen lbl = string(val, "%3.1f")

twoway ///
    (scatter row col if quintile == 1, msymbol(square) msize(vhuge) mcolor("68 1 84") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(small)) ///
    (scatter row col if quintile == 2, msymbol(square) msize(vhuge) mcolor("59 82 139") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(small)) ///
    (scatter row col if quintile == 3, msymbol(square) msize(vhuge) mcolor("33 144 140") mlabel(lbl) mlabpos(0) mlabcolor(white) mlabsize(small)) ///
    (scatter row col if quintile == 4, msymbol(square) msize(vhuge) mcolor("93 200 99") mlabel(lbl) mlabpos(0) mlabcolor(black) mlabsize(small)) ///
    (scatter row col if quintile == 5, msymbol(square) msize(vhuge) mcolor("253 231 37") mlabel(lbl) mlabpos(0) mlabcolor(black) mlabsize(small)), ///
    xscale(range(0 6) off) ///
    yscale(range(0 6) off) ///
    graphregion(color(white)) bgcolor(white) ///
    legend(order(1 "1st Quintile (Lowest)" 2 "2nd Quintile" 3 "3rd Quintile" 4 "4th Quintile" 5 "5th Quintile (Highest)") ///
           rows(1) pos(6) size(vsmall) region(lcolor(white))) ///
    note("Notes: Spatial lattice choropleth across 25 contiguous economic regions (Anselin, 1988)." ///
         "Shading depicts quintiles of the regional indicator exhibiting spatial autoregressive autocorrelation." ///
         "Text inside cells reports region-specific observed value.", ///
         size(vsmall) span)

* ==============================================================================
* 3. VECTOR PDF AND HIGH-RESOLUTION RASTER EXPORT
* ==============================================================================
graph export "regional_choropleth_stata.pdf", as(pdf) replace
graph export "regional_choropleth_stata.png", as(png) replace width(2400)
