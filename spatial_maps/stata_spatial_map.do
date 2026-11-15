* Publication-Grade Thematic Spatial Mapping in Stata: From tmap to spmap and grmap
* Adheres to Gastel & Day exhibit standards and StataCorp official spatial guidelines
*
* Citations:
* - Pisati, M. (2004). Simple thematic mapping. Stata Journal, 4(4), 361-378. DOI: 10.1177/1536867X0400400401
* - Pisati, M. (2007). spmap: Stata module to visualize spatial data. Statistical Software Components S456816.
* - Picard, R. (2010). geo2xy: Stata module to convert latitude and longitude to planar coordinates.

clear all
set more off

* ==============================================================================
* 1. REQUIRED STATA PACKAGES
* ==============================================================================
* ssc install spmap, replace
* ssc install shp2dta, replace
* ssc install geo2xy, replace

* ==============================================================================
* 2. SHAPEFILE CONVERSION AND PROJECTION CORRECTION
* ==============================================================================
* Step A: Convert ESRI shapefiles to Stata datasets
* Using Stata native command:
* spshape2dta "cb_2022_us_county_500k.shp", replace
* Or using classic shp2dta:
* shp2dta using "county_boundaries.shp", data("counties_attr.dta") coord("counties_coord.dta") replace

* Step B: Project spherical coordinates to Albers Equal Area using geo2xy
* use "counties_coord.dta", clear
* geo2xy _Y _X, proj(albers) replace
* save "counties_coord_projected.dta", replace

* ==============================================================================
* 3. MERGING ATTRIBUTES AND DECLARING SPATIAL STRUCTURE
* ==============================================================================
* use "counties_attr.dta", clear
* merge 1:1 fips using "county_economic_data.dta", keep(match) nogen

* In Stata, declare linked coordinates dataset:
* spset _ID, coord("counties_coord_projected.dta")

* ==============================================================================
* 4. ADVANCED MULTI-LAYER MAPPING (CHOROPLETH + BORDERS + POINT SYMBOLS)
* ==============================================================================
* Layer 1: Base polygon layer shaded by economic quintiles (upward mobility)
* Layer 2: Polygon overlay with state borders
* Layer 3: Point layer with proportional symbols for major metropolitan centers
* Note: in-figure title omitted; notes carry self-contained specification

* Implementation via grmap:
* grmap upward_mobility, ///
*     clmethod(quantile) clnumber(5) ///
*     fcolor(Blues) ///
*     ocolor(white ..) osize(vthin ..) ///
*     polygon(data("state_borders_coord.dta") ocolor(black) osize(medium)) ///
*     point(data("metro_centers.dta") x(_X) y(_Y) proportional(population) fcolor(cranberry) size(*0.8)) ///
*     legend(pos(12) ring(1) rows(1) size(small) region(lcolor(none))) ///
*     note("Notes: County-level upward mobility with state borders and metro centers." ///
*          "5-quantile choropleth across US counties. Coordinates projected using Albers Equal Area via geo2xy." ///
*          "Red markers reflect metropolitan area population size.", size(vsmall) span)

* Implementation via spmap:
* spmap upward_mobility using "counties_coord_projected.dta", id(_ID) ///
*     clmethod(quantile) clnumber(5) ///
*     fcolor(Blues) ///
*     ocolor(white ..) osize(vthin ..) ///
*     polygon(data("state_borders_coord.dta") ocolor(black) osize(medium)) ///
*     point(data("metro_centers.dta") x(_X) y(_Y) proportional(population) fcolor(cranberry) size(*0.8)) ///
*     legend(pos(12) ring(1) rows(1) size(small) region(lcolor(none))) ///
*     note("Notes: County-level upward mobility and urban agglomerations." ///
*          "Shapefile coordinates projected using Albers Equal Area (Picard, 2010; Pisati, 2007).", size(vsmall) span)

* ==============================================================================
* 5. EXPORTING PUBLICATION VECTOR AND RASTER GRAPHICS
* ==============================================================================
* graph export "stata_thematic_multilayer_map.pdf", as(pdf) replace
* graph export "stata_thematic_multilayer_map.png", as(png) replace width(2400)
