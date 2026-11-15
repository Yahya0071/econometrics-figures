# Table-Graphics and Sparklines

This module implements Edward Tufte's concept of sparklines: data-intense, design-simple, word-sized graphics integrated directly into tables and continuous prose.

---

## 1. Principles of Sparkline Design (Tufte, 1983, 2006)

Traditional quantitative papers isolate figures onto separate pages, requiring readers to cross-reference tables and narrative text. Sparklines unify these domains:
- **Typographic Resolution:** Graphics sized identically to surrounding font metrics ($0.8$ to $1.2$ em).
- **Zero Chartjunk:** Spines, ticks, labels, and background colors are completely eliminated.
- **Micro-Markers:** Discrete color points highlight the sample minimum, maximum, and final terminal observation.
- **Seamless LaTeX Integration:** Vector PDF output embeds directly into standard `booktabs` table environments via `\includegraphics`.

---

## 2. Included Files

| File | Type | Description |
| :--- | :--- | :--- |
| `sparklines.py` | Python (`matplotlib`) | Generator producing standalone vector PDF and PNG sparkline assets. |
| `sparkline_table.tex` | LaTeX | Demonstrates embedding sparklines into an empirical publication table. |

---

## 3. Key References

- **Tufte, E. R. (1983).** *The Visual Display of Quantitative Information*. Graphics Press.
- **Tufte, E. R. (2006).** *Beautiful Evidence*. Graphics Press.
