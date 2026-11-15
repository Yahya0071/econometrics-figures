# Spatial Econometrics, Choropleths, Cartograms & Global Maps

This module provides reproducible, publication-grade spatial maps, multi-layer overlays, state cartograms, and global economic taxonomy exhibits across Python, R, and Stata, designed specifically for empirical economics.

---

## 1. Methodological Challenges in Economic Mapping

Spatial visualization in empirical economics requires navigating five structural challenges:

1. **Global Projections & Robinson Compromise:**
   Displaying global country maps using the Mercator projection severely distorts landmass areas, inflating Europe, North America, and Greenland while shrinking South America and Africa.
   - *Solution:* Global economic maps (`global_economies_map.py`) must use compromise or equal-area global projections, primarily the **Robinson projection (`+proj=robin`)** or **Equal Earth (`EPSG:8857`)**, with Antarctica excluded.

2. **The Landmass Distortion Bias ("Land Does Not Vote"):**
   In standard sub-national maps, sparsely populated rural jurisdictions (e.g., Montana, Wyoming, interior Australia) occupy enormous visual area, whereas dense economic agglomerations (e.g., New York City, Chicago, London) collapse into invisible pinpricks. 
   - *Solution:* Equal-representation state tile-grid cartograms (`state_tile_grid.py`) where each jurisdiction receives identical graphical area.

3. **Quantile Discrete Classification vs Continuous Gradients:**
   Human perception cannot accurately distinguish continuous color gradients across complex maps (Cleveland, 1985; Harrower and Brewer, 2003).
   - *Solution:* Partition data into 5 or 10 discrete quantile intervals (quintiles or deciles) using perceptually uniform, colorblind-safe color ramps (Viridis, Tol, ColorBrewer).

4. **Multi-Layer Thematic Overlays (The Stata Spatial Architecture):**
   Top-tier journal maps rarely present isolated choropleth polygons. As outlined in StataCorp's foundational mapping documentation (Pisati, 2004, 2007; Picard, 2010):
   - *Base Polygon Layer:* Shaded by economic quantiles (e.g., local unemployment or poverty).
   - *Boundary Overlay Line Layer:* Thicker administrative boundaries (e.g., state or national borders) superimposed via `polygon()` or `line()`.
   - *Proportional Point Layer:* Proportional circle symbols (`point()`) indicating urban population centers, bank branches, or facility locations.

5. **Bivariate Choropleths ($3 \times 3$ Color Matrix):**
   Researchers often need to evaluate how two economic variables co-vary spatially (e.g., poverty and air pollution, or real wages and housing costs).
   - *Solution:* Bivariate mapping (`bivariate_choropleth.py`, `bivariate_choropleth.R`, and Asjad Naqvi's `stata_bimap.do`). Both variables are split into terciles, yielding a 9-color matrix displayed alongside an integrated 45-degree rotated diamond legend.

---

## 2. Software Implementations & Libraries

| Software | Core Libraries | Primary Method |
| :--- | :--- | :--- |
| **Python** | `geopandas`, `shapely`, `matplotlib` | Global Robinson projections, US Albers projection, tile cartograms, and bivariate matrices. |
| **R** | `sf`, `biscale`, `cowplot`, `ggplot2` | `geom_sf()`, `bi_class()`, `bi_legend()`, and discrete quantile binning (`cut_number`). |
| **Stata** | `grmap` (Stata 15+), `spmap` (Pisati), `bimap` (Naqvi), `geo2xy` (Picard) | Global country maps, multi-layer overlays, and bivariate choropleths. |

---

## 3. Included Scripts

| File | Language | Design Implemented |
| :--- | :--- | :--- |
| `global_economies_map.py` | Python (`geopandas`, `matplotlib`) | Global map of Advanced, Emerging, and Developing economies (IMF WEO, Robinson projection). |
| `state_tile_grid.py` | Python (`matplotlib`) | Equal-area US state tile-grid cartogram with discrete quintile shading. |
| `regional_choropleth.py` | Python (`geopandas`, `shapely`) | Spatial autoregressive (SAR) lattice choropleth with discrete quintiles. |
| `bivariate_choropleth.py` | Python (`geopandas`, `matplotlib`) | Contiguous US bivariate map with 45-degree rotated diamond legend (Albers projection). |
| `global_economies_map.R` | R (`sf`, `ggplot2`) | Global economic taxonomy map using Robinson projection and `theme_tufte_academic`. |
| `choropleth_map.R` | R (`sf`, `ggplot2`) | Simple features spatial polygon map using `theme_tufte_academic`. |
| `bivariate_choropleth.R` | R (`sf`, `biscale`, `cowplot`) | Bivariate map with rotated 2D legend using `biscale`. |
| `stata_global_map.do` | Stata (`spmap`, `geo2xy`) | Global country mapping in Stata using Robinson projection. |
| `stata_spatial_map.do` | Stata (`grmap`, `spmap`, `geo2xy`) | Multi-layer spatial mapping pipeline (choropleth + state borders + proportional points). |
| `stata_bimap.do` | Stata (`bimap`, Asjad Naqvi) | Direct implementation of Naqvi's `bimap` package with 2D legends. |

---

## 4. Key References

- **Anselin, L. (1988).** *Spatial Econometrics: Methods and Models*. Kluwer Academic Publishers.
- **Autor, D. H., Dorn, D., & Hanson, G. H. (2013).** The China syndrome: Local labor market effects of import competition in the United States. *American Economic Review*, 103(6), 2121-2168.
- **Chetty, R., Hendren, N., Kline, P., & Saez, E. (2014).** Where is the land of opportunity? The geography of intergenerational mobility in the United States. *Quarterly Journal of Economics*, 129(4), 1553-1623.
- **Harrower, M., & Brewer, C. A. (2003).** ColorBrewer.org: An online tool for selecting colour schemes for maps. *Cartographic Journal*, 40(1), 27-37.
- **International Monetary Fund (IMF) (2024).** *World Economic Outlook: Policy Pivot, Rising Threats*. Washington, DC: International Monetary Fund. DOI: 10.5089/9798400255892.081
- **Naqvi, A. (2022).** BIMAP: Stata module to produce bivariate choropleth maps. *Statistical Software Components* S459091, Boston College.
- **Pebesma, E. (2018).** Simple Features for R: Standardized support for spatial vector data. *R Journal*, 10(1), 439-446.
- **Picard, R. (2010).** geo2xy: Stata module to convert latitude and longitude to xy coordinates. *Statistical Software Components*, Boston College.
- **Pisati, M. (2004).** Simple thematic mapping. *Stata Journal*, 4(4), 361-378. DOI: 10.1177/1536867X0400400401
- **Pisati, M. (2007).** spmap: Stata module to visualize spatial data. *Statistical Software Components*, Boston College.
- **Prener, C. (2019).** biscale: Tools and Palettes for Bivariate Thematic Mapping. *R package version 1.0.0*.
- **Robinson, A. H. (1974).** A new map projection: Its development and characteristics. *International Yearbook of Cartography*, 14, 145-155.
- **Stevens, J. (2015).** Bivariate choropleth maps: A how-to guide. *Joshua Stevens Research Notes*.
