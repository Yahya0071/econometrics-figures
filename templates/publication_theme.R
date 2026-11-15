# R / ggplot2 Academic Publication Theme
# Adheres to Gastel & Day exhibit standards for empirical research
# Compatible with American Economic Review (AER), QJE, JFE, and Review of Financial Studies

suppressPackageStartupMessages({
  if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
  library(ggplot2)
})

theme_academic <- function(base_size = 10, base_family = "serif") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # High data-to-ink ratio: clean white background
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      
      # Axis lines: distinct dark bottom and left axes, no top or right spines
      axis.line.x = element_line(color = "#222222", linewidth = 0.5),
      axis.line.y = element_line(color = "#222222", linewidth = 0.5),
      
      # Ticks: subtle exterior ticks
      axis.ticks = element_line(color = "#222222", linewidth = 0.5),
      axis.ticks.length = unit(0.15, "cm"),
      
      # Minimal subtle horizontal gridlines only
      panel.grid.major.y = element_line(color = "#EAEAEA", linewidth = 0.4, linetype = "dashed"),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      
      # Typography: bold titles, standard labels, self-contained notes
      plot.title = element_text(
        face = "bold",
        size = rel(1.1),
        hjust = 0,
        margin = margin(b = 6)
      ),
      plot.subtitle = element_text(
        size = rel(0.95),
        hjust = 0,
        margin = margin(b = 8),
        color = "#444444"
      ),
      plot.caption = element_text(
        size = rel(0.78),
        hjust = 0,
        margin = margin(t = 10),
        color = "#333333",
        lineheight = 1.15
      ),
      
      # Axis titles and labels
      axis.title.x = element_text(
        size = rel(0.95),
        margin = margin(t = 6)
      ),
      axis.title.y = element_text(
        size = rel(0.95),
        margin = margin(r = 6),
        angle = 90
      ),
      axis.text = element_text(
        size = rel(0.85),
        color = "#222222"
      ),
      
      # Legend: clean, unboxed, transparent
      legend.background = element_blank(),
      legend.box.background = element_blank(),
      legend.key = element_blank(),
      legend.position = "top",
      legend.justification = "left",
      legend.direction = "horizontal",
      legend.text = element_text(size = rel(0.85)),
      legend.title = element_text(size = rel(0.85), face = "bold"),
      legend.margin = margin(b = 4),
      
      # Facet strips
      strip.background = element_rect(fill = "#F4F4F4", color = "#CCCCCC", linewidth = 0.4),
      strip.text = element_text(face = "bold", size = rel(0.9), color = "#222222"),
      
      # Margins
      plot.margin = margin(t = 12, r = 14, b = 12, l = 12)
    )
}

# Colorblind-safe palettes (Okabe-Ito and Tol)
scale_color_academic <- function(...) {
  scale_color_manual(
    values = c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9", "#999999"),
    ...
  )
}

scale_fill_academic <- function(...) {
  scale_fill_manual(
    values = c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9", "#999999"),
    ...
  )
}

# Standardized save function for single- and double-column journal exhibits
save_academic_figure <- function(plot, filename, width = 7.0, height = 4.5, dpi = 300) {
  ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    device = cairo_pdf
  )
  message(sprintf("Figure saved to %s (Dimensions: %.1f x %.1f in, %d DPI)", filename, width, height, dpi))
}
