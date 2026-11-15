* Publication-Grade Global Economies Thematic Map in Stata
* Adheres to IMF World Economic Outlook taxonomy and Gastel & Day exhibit standards
* Demonstrates global country mapping, Robinson projection, and WEO classifications
*
* Required Stata SSC Packages:
*   ssc install spmap, replace
*   ssc install shp2dta, replace
*   ssc install geo2xy, replace
*
* Citations:
* - International Monetary Fund (2024). World Economic Outlook: Steady but Slow: Resilience amid Divergence.
*   Washington, DC: International Monetary Fund.
* - Robinson, A. H. (1974). A New Map Projection: Its Development and Characteristics.
*   International Yearbook of Cartography, 14, 145-155.

clear all
set more off

* 1. Shapefile Preparation and Robinson Projection
* Download Natural Earth 110m cultural country boundaries:
* shp2dta using "ne_110m_admin_0_countries.shp", data("world_attr.dta") coord("world_coord.dta") replace

* Drop Antarctica (ISO_A3 == "ATA") to eliminate polar distortion:
* use "world_attr.dta", clear
* drop if ISO_A3 == "ATA"
* save "world_attr_clean.dta", replace

* Project coordinates into Robinson projection (+proj=robin) via geo2xy:
* use "world_coord.dta", clear
* geo2xy _Y _X, proj(robinson) replace
* save "world_coord_projected.dta", replace

* 2. Merge IMF WEO Classification Data
* use "world_attr_clean.dta", clear
* merge 1:1 ISO_A3 using "imf_weo_classification.dta", keep(master match) nogen

* Define discrete classification variable:
* 1 = "Advanced Economies"
* 2 = "Emerging Market Economies"
* 3 = "Low-Income and Developing Economies"

* 3. Render Global Publication Map Using spmap
* Note: in-figure title omitted; notes carry self-contained specification
* spmap econ_class using "world_coord_projected.dta", id(_ID) ///
*     clmethod(unique) ///
*     fcolor("0 114 178" "213 94 0" "0 158 115") ///
*     ocolor(white ..) osize(0.02 ..) ///
*     legend(pos(6) ring(1) rows(1) size(small) region(lcolor(none))) ///
*     note("Notes: Global economic taxonomy following IMF World Economic Outlook (2024) classification." ///
*          "Advanced economies comprise 41 high-income industrial economies. Emerging market economies comprise" ///
*          "major middle-income industrializing jurisdictions. Projected using Robinson projection (Robinson, 1974)." ///
*          "Antarctica omitted.", size(vsmall) span)

* 4. Export Vector PDF and Raster PNG
* graph export "stata_global_economies_map.pdf", as(pdf) replace
* graph export "stata_global_economies_map.png", as(png) replace width(2400)
