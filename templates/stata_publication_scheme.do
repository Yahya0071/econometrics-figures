* Stata Academic Publication Graph Settings
* Adheres to Gastel & Day exhibit standards for empirical research
* Compatible with American Economic Review (AER), QJE, and JFE guidelines

* Define global formatting macros for consistent journal exhibits
global graph_opts ///
    graphregion(color(white) margin(medium)) ///
    plotregion(color(white) margin(small)) ///
    bgcolor(white)

* Axes and gridlines: clean zero lines, no vertical grid, subtle horizontal grid
global axis_opts ///
    ylabel(, nogrid labsize(small) angle(horizontal)) ///
    xlabel(, labsize(small)) ///
    ytick(, noticks) ///
    xtick(, noticks) ///
    xscale(lcolor(black) lwidth(medium)) ///
    yscale(lcolor(black) lwidth(medium))

* Legend options: unboxed, left-aligned, horizontal
global legend_opts ///
    legend(region(lcolor(none) fcolor(none)) ///
           size(small) ///
           pos(12) ring(1) rows(1))

* Recommended color palette (Colorblind safe):
* Navy/Primary: "0 114 178"
* Vermillion/Secondary: "213 94 0"
* Green: "0 158 115"
* Charcoal/Neutral: "50 50 50"
* Light gray reference: "200 200 200"

* Example export macro for vector PDF
* graph export "figure.pdf", replace as(pdf) width(2100) height(1350)
