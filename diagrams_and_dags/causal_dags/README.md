# Directed Acyclic Graphs (Causal DAGs)

This module provides vector-native LaTeX / TikZ templates for illustrating identification strategies, backdoor adjustments, instrumental variables, and collider stratification.

---

## 1. Methodological Foundation

Causal DAGs encode structural assumptions regarding data-generating processes (Pearl, 2009):
- **Backdoor Criterion:** A set of covariates $\mathbf{W}$ blocks every path between treatment $D$ and outcome $Y$ containing an arrow pointing into $D$.
- **Instrumental Variables:** An instrument $Z$ must satisfy relevance ($\operatorname{Cov}(Z, D) \neq 0$), unconfounded assignment ($Z \perp U$), and the exclusion restriction (all paths from $Z$ to $Y$ operate solely through $D$).
- **Collider Bias (Bad Controls):** Conditioning on a common descendant $C$ of treatment and outcome unblocks a non-causal path, inducing spurious correlation (Angrist and Pischke, 2009).

---

## 2. Compilation Instructions

Compile each `.tex` file directly to standalone vector PDF using any standard TeX distribution:

```bash
pdflatex dag_confounding.tex
pdflatex dag_instrumental_variable.tex
pdflatex dag_collider.tex
```

---

## 3. Included Templates

| File | Structure Illustrated | Identifying Principle |
| :--- | :--- | :--- |
| `dag_confounding.tex` | Treatment $D$, Outcome $Y$, Confounder $W$ | Backdoor path closure via conditioning on $W$. |
| `dag_instrumental_variable.tex` | Instrument $Z$, Treatment $D$, Outcome $Y$, Unobserved $U$ | Relevance and exclusion restriction validation. |
| `dag_collider.tex` | Treatment $D$, Outcome $Y$, Collider $C$ | Danger of conditioning on post-treatment variables. |

---

## 4. Key References

- **Angrist, J. D., & Pischke, J.-S. (2009).** *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press.
- **Cinelli, C., Forney, A., & Pearl, J. (2022).** A crash course in good and bad controls. *Sociological Methods & Research*, 53(3), 1071-1104.
- **Pearl, J. (2009).** *Causality: Models, Reasoning, and Inference* (2nd ed.). Cambridge University Press.
