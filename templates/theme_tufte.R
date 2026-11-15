# R / ggplot2 Tufte Minimalist Academic Theme
# Adheres to Edward Tufte's principles from The Visual Display of Quantitative Information (1983, 2001)
# Maximizes data-ink ratio by stripping chartjunk, heavy borders, and distracting grids

suppressPackageStartupMessages({
  if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
  library(ggplot2)
})

theme_tufte_academic <- function(base_size = 10, base_family = "serif") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # Pure white background, zero decorative borders
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      
      # Minimalist axis lines: thin, restrained
      axis.line.x = element_line(color = "#333333", linewidth = 0.4),
      axis.line.y = element_line(color = "#333333", linewidth = 0.4),
      
      # Exterior subtle ticks
      axis.ticks = element_line(color = "#333333", linewidth = 0.4),
      axis.ticks.length = unit(0.12, "cm"),
      
      # Zero panel gridlines: data points and white space guide the eye
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      
      # Restrained typography
      plot.title = element_text(
        face = "bold",
        size = rel(1.05),
        hjust = 0,
        margin = margin(b = 6)
      ),
      plot.subtitle = element_text(
        size = rel(0.9),
        hjust = 0,
        margin = margin(b = 10),
        color = "#444444"
      ),
      plot.caption = element_text(
        size = rel(0.75),
        hjust = 0,
        margin = margin(t = 10),
        color = "#333333",
        lineheight = 1.15
      ),
      
      # Axis titles and text
      axis.title.x = element_text(size = rel(0.9), margin = margin(t = 6)),
      axis.title.y = element_text(size = rel(0.9), margin = margin(r = 6), angle = 90),
      axis.text = element_text(size = rel(0.82), color = "#222222"),
      
      # Legend: unboxed, unobtrusive
      legend.background = element_blank(),
      legend.box.background = element_blank(),
      legend.key = element_blank(),
      legend.position = "none", # Tufte prefers direct curve labeling over detached legends
      
      # Facet strips
      strip.background = element_blank(),
      strip.text = element_text(face = "bold", size = rel(0.85), color = "#222222", hjust = 0),
      
      # Margins
      plot.margin = margin(t = 12, r = 16, b = 12, l = 12)
    )
}
