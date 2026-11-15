# Publication-Grade Global Economies Choropleth Map (R / sf & ggplot2)
# Adheres to IMF World Economic Outlook taxonomy and Gastel & Day exhibit standards
# Projected in the Robinson compromise projection (+proj=robin)

suppressPackageStartupMessages({
  if (requireNamespace("sf", quietly = TRUE)) {
    library(sf)
  }
  library(ggplot2)
})

# 1. IMF WEO Advanced Economies ISO-3 Vector
advanced_iso3 <- c(
  "USA", "CAN", "GBR", "DEU", "FRA", "ITA", "JPN",
  "AUT", "BEL", "CYP", "EST", "FIN", "GRC", "IRL", "LVA", "LTU", "LUX",
  "MLT", "NLD", "PRT", "SVK", "SVN", "ESP", "HRV", "AND", "SMR",
  "AUS", "NZL", "CHE", "NOR", "SWE", "DNK", "ISL", "SGP", "KOR", "TWN",
  "HKG", "MAC", "ISR", "CZE", "PRI"
)

emerging_iso3 <- c(
  "CHN", "IND", "BRA", "RUS", "ZAF", "MEX", "IDN", "TUR", "SAU", "ARG",
  "POL", "THA", "MYS", "CHL", "COL", "PER", "PHL", "VNM", "EGY", "PAK",
  "BGD", "NGA", "ARE", "QAT", "KWT", "KAZ", "ROU", "HUN", "DZA", "MAR",
  "IRN", "UKR", "ECU", "OMN", "BGR", "SRB", "DOM", "GTM", "PAN", "CRI",
  "URY", "JOR", "LBN", "TUN", "LKA", "KEN", "GHA"
)

# 2. Load and Classify World Geometry
load_world_sf <- function(script_dir) {
  geojson_path <- file.path(script_dir, "data", "world_countries.geojson")
  if (!file.exists(geojson_path)) {
    geojson_path <- file.path("spatial_maps", "data", "world_countries.geojson")
  }
  
  world <- sf::st_read(geojson_path, quiet = TRUE)
  world <- subset(world, `ISO3166-1-Alpha-3` != "ATA")
  
  if (is.na(sf::st_crs(world))) {
    sf::st_crs(world) <- 4326
  }
  world_robin <- sf::st_transform(world, crs = "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")
  
  iso_col <- world_robin$`ISO3166-1-Alpha-3`
  world_robin$group <- "Low-Income & Developing Economies"
  world_robin$group[iso_col %in% emerging_iso3] <- "Emerging Market Economies"
  world_robin$group[iso_col %in% advanced_iso3] <- "Advanced Economies"
  
  world_robin$group <- factor(
    world_robin$group,
    levels = c("Advanced Economies", "Emerging Market Economies", "Low-Income & Developing Economies")
  )
  return(world_robin)
}

# 3. Render Publication World Map
plot_global_map_r <- function(world_sf, out_pdf = "global_economies_r.pdf", out_png = "global_economies_r.png") {
  p <- ggplot(world_sf) +
    geom_sf(aes(fill = group), color = "#FFFFFF", linewidth = 0.25) +
    scale_fill_manual(
      name = "",
      values = c(
        "Advanced Economies" = "#0072B2",
        "Emerging Market Economies" = "#D55E00",
        "Low-Income & Developing Economies" = "#009E73"
      )
    ) +
    labs(
      caption = "Notes: Country classifications adhere to the IMF World Economic Outlook taxonomy. Robinson projection (+proj=robin). Antarctica omitted."
    ) +
    theme_minimal(base_size = 9, base_family = "sans") +
    theme(
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      legend.position = "bottom",
      legend.justification = "center",
      legend.direction = "horizontal",
      legend.text = element_text(size = rel(0.8)),
      plot.caption = element_text(size = 7.5, color = "#333333", hjust = 0, margin = margin(t = 10)),
      plot.margin = margin(12, 16, 12, 12)
    )
  
  ggsave(out_pdf, plot = p, width = 11.0, height = 6.2, device = "pdf")
  ggsave(out_png, plot = p, width = 11.0, height = 6.2, dpi = 300)
  message(sprintf("Saved: %s and %s", out_pdf, out_png))
  return(p)
}

main <- function() {
  if (!requireNamespace("sf", quietly = TRUE)) {
    message("Package 'sf' is not installed; skipping local R world map execution.")
    return(invisible(NULL))
  }
  
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
  } else {
    script_dir <- getwd()
  }
  
  world_data <- load_world_sf(script_dir)
  out_pdf <- file.path(script_dir, "global_economies_r.pdf")
  out_png <- file.path(script_dir, "global_economies_r.png")
  plot_global_map_r(world_data, out_pdf, out_png)
}

if (!interactive()) {
  main()
}
