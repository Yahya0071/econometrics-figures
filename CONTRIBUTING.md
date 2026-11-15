# Contributing to Academic Figures

We welcome contributions of publication-grade figures, estimators, and diagrams. To maintain the standard required by leading academic journals (*AER*, *QJE*, *JFE*, *Review of Economic Studies*), all contributions must satisfy the following invariants.

---

## 1. Contribution Invariants

1. **Zero Proprietary Data Dependencies:** Every script must be completely executable out-of-the-box using an inlined synthetic Data Generating Process (DGP) or public verifiable data sources (e.g., FRED, World Bank, Natural Earth).
2. **Dual Vector and Raster Export:** Every script must export both an uncompressed vector PDF (for LaTeX compilation and journal production) and a 300 DPI raster PNG (for quick preview and web rendering).
3. **Identification Over Convenience:** In causal inference exhibits, scripts must implement robust modern estimators rather than biased legacy specifications. Staggered adoption event studies must account for cohort heterogeneity via robust estimators (e.g., Sun and Abraham, 2021).
4. **Direct Endpoint Labeling:** Eliminate detached legend boxes wherever feasible by placing concise labels directly at line endpoints.
5. **No In-Figure Titles:** Keep figures uncluttered by placing titles and subtitles in the caption or notes block rather than inside the plot canvas.
6. **Gastel and Day Exhibit Standards:**
   - Standalone, self-contained notes must accompany every figure, stating sample size, specification, clustering level, and interval level.
   - Point estimates must always be presented alongside explicit uncertainty bounds.
   - Bar charts must start at zero; reference lines must explicitly denote the null hypothesis ($\beta = 0$) or reference period ($t = -1$).
7. **Windows Safety:** All file paths must use `pathlib.Path` or `os.path.join`, resolved relative to `__file__`, with UTF-8 encoding when opening text files.
8. **Accessible Palettes:** Use colorblind-safe palettes (Okabe-Ito, Tol, Viridis) and verify visual legibility when printed in grayscale.
9. **Zero Em Dashes:** Under no circumstances should em dashes be used in documentation, code comments, axis titles, or notes. Use commas, semicolons, parentheses, colons, or distinct sentences.
10. **No Prohibited AI Filler Vocabulary:** Submissions containing decorative filler vocabulary (`delve`, `pivotal`, `tapestry`, `intricate`, `multifaceted`) will be rejected.

---

## 2. Pull Request Checklist

Before submitting a pull request, verify:
- [ ] Python script executes cleanly with `python -W error <script>` with zero errors and zero warnings.
- [ ] Script exports both vector PDF and 300 DPI raster PNG.
- [ ] Direct typography is used instead of detached legend boxes where applicable.
- [ ] In-figure titles are removed and moved to the notes block.
- [ ] Self-contained notes are placed below the chart.
- [ ] Econometric citations include authors, year, journal, volume, and verified DOIs.
- [ ] Automated style check passes with zero em dashes and zero blacklisted words.
