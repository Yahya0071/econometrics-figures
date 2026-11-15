* Publication-Grade Bivariate Choropleth Map in Stata using bimap
* Adheres to Gastel & Day exhibit standards and Asjad Naqvi's bimap package
*
* Required Stata Packages (install from SSC before running):
*   ssc install bimap, replace
*   ssc install spmap, replace
*   ssc install palettes, replace
*   ssc install colrspace, replace
*   ssc install geo2xy, replace
*
* Citations:
* - Naqvi, A. (2022). BIMAP: Stata module to produce bivariate choropleth maps.
*   Statistical Software Components S459091, Boston College Department of Economics.
* - Stevens, J. (2015). Bivariate Choropleth Maps: A How-to Guide.

clear all
set more off

* 1. Preparing Linked Spatial Shapefiles
* Convert ESRI shapefiles into master attribute and coordinate datasets:
* shp2dta using "us_counties.shp", data("county_attributes.dta") coord("county_coordinates.dta") replace

* Project coordinates into Albers Equal Area:
* use "county_coordinates.dta", clear
* geo2xy _Y _X, proj(albers) replace
* save "county_coordinates_albers.dta", replace

* 2. Merge Variables of Interest
* use "county_attributes.dta", clear
* merge 1:1 fips using "county_economic_data.dta", keep(match) nogen

* 3. Execute bimap Command
* Variable 1 (x-axis): median_income
* Variable 2 (y-axis): college_share
* Cutoff method: quantile (3x3 tercile grid)
* Note: in-figure title omitted; notes carry self-contained specification

* bimap median_income college_share using "county_coordinates_albers.dta", ///
*     id(_ID) ///
*     cut(quantile) ///
*     palette(bluered) ///
*     ocolor(white ..) osize(0.04 ..) ///
*     note("Notes: Bivariate choropleth map generated according to Asjad Naqvi's bimap and Joshua Stevens (2015)." ///
*          "Both continuous indicators are partitioned into sample population terciles (3x3 classification)." ///
*          "Cyan shades denote high median income with low college attainment; pink and red shades denote high college" ///
*          "attainment with low median income; dark plum denotes joint high attainment across both dimensions." ///
*          "Coordinates projected using Albers Equal Area.", size(vsmall) span) ///
*     textx("Higher Income") ///
*     texty("Higher College Share") ///
*     box(0.12) ///
*     legend(pos(2) ring(0) size(small))

* 4. Export High-Resolution Vector PDF and Raster PNG
* graph export "stata_bivariate_choropleth.pdf", as(pdf) replace
* graph export "stata_bivariate_choropleth.png", as(png) replace width(2400)
