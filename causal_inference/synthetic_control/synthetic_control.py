"""
Publication-Grade Synthetic Control Plots in Python.
Adheres to Gastel & Day exhibit standards and Abadie, Diamond, and Hainmueller (2010).

Citations:
- Abadie, A., A. Diamond, and J. Hainmueller (2010). Synthetic Control Methods for
  Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program.
  Journal of the American Statistical Association, 105(490), 493-505.
  DOI: 10.1198/jasa.2009.ap08746
"""

from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize


def simulate_synthetic_control_data(n_donors=20, n_pre=15, n_post=10, seed=42):
    """
    Generates synthetic panel for 1 treated unit and n_donors control units.
    Intervention occurs at t = n_pre + 1.
    """
    np.random.seed(seed)
    n_total = n_pre + n_post
    time = np.arange(1, n_total + 1)
    
    # Common factors
    factor1 = np.sin(time / 3.0) * 2.0
    factor2 = 0.3 * time
    
    # Donor units
    donor_matrix = np.zeros((n_total, n_donors))
    for j in range(n_donors):
        loadings = np.random.uniform(0.2, 1.2, size=2)
        noise = np.random.normal(0, 0.4, size=n_total)
        donor_matrix[:, j] = 5.0 + loadings[0] * factor1 + loadings[1] * factor2 + noise
        
    # Treated unit: convex combination of first 4 donors + shock post-treatment
    true_weights = np.array([0.4, 0.3, 0.2, 0.1] + [0.0] * (n_donors - 4))
    treated_trajectory = donor_matrix @ true_weights + np.random.normal(0, 0.3, size=n_total)
    
    # Post-treatment effect (+1.2 growing divergence)
    treatment_effect = np.zeros(n_total)
    treatment_effect[n_pre:] = 1.2 + 0.3 * np.arange(1, n_post + 1)
    treated_trajectory += treatment_effect
    
    return time, treated_trajectory, donor_matrix, n_pre


def fit_synthetic_control(treated, donors, n_pre):
    """
    Fits constrained synthetic control weights minimizing pre-treatment MSE.
    Weights must be non-negative and sum to 1.
    """
    n_donors = donors.shape[1]
    y1_pre = treated[:n_pre]
    y0_pre = donors[:n_pre, :]
    
    def loss(w):
        diff = y1_pre - y0_pre @ w
        return np.sum(diff ** 2)
    
    init_w = np.ones(n_donors) / n_donors
    bounds = [(0.0, 1.0) for _ in range(n_donors)]
    constraints = {"type": "eq", "fun": lambda w: np.sum(w) - 1.0}
    
    res = minimize(loss, init_w, method="SLSQP", bounds=bounds, constraints=constraints)
    optimal_w = res.x
    
    synthetic_series = donors @ optimal_w
    gap_series = treated - synthetic_series
    
    return optimal_w, synthetic_series, gap_series


def compute_placebo_gaps(donors, n_pre):
    """
    Runs in-space placebo iterations by assigning treatment status to each donor unit.
    """
    n_donors = donors.shape[1]
    placebo_gaps = []
    
    for j in range(n_donors):
        pseudo_treated = donors[:, j]
        pseudo_donors = np.delete(donors, j, axis=1)
        
        _, _, p_gap = fit_synthetic_control(pseudo_treated, pseudo_donors, n_pre)
        placebo_gaps.append(p_gap)
        
    return np.array(placebo_gaps)


def plot_synthetic_control(time, treated, synthetic, gap, placebos, n_pre, out_png=None, out_pdf=None, style_path=None):
    """
    Renders two-panel publication exhibit: Trajectory comparison and Placebo gap distribution.
    Exports both vector PDF and 300 DPI PNG with direct labels.
    """
    if style_path and Path(style_path).is_file():
        plt.style.use(str(style_path))
    else:
        plt.style.use("seaborn-v0_8-whitegrid" if "seaborn-v0_8-whitegrid" in plt.style.available else "default")
        
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8), dpi=300)
    
    # ---------------- Panel A: Trajectories ----------------
    ax1.axvline(n_pre, color="#555555", linestyle="--", linewidth=0.9)
    ax1.text(
        n_pre + 0.3, ax1.get_ylim()[1] if ax1.get_ylim()[1] != 0 else 12.0,
        f"Intervention ($T_0 = {n_pre}$)",
        color="#444444",
        fontsize=8.0,
        verticalalignment="top"
    )
    
    l_treat, = ax1.plot(time, treated, color="#D55E00", linewidth=2.0)
    l_synth, = ax1.plot(time, synthetic, color="#0072B2", linewidth=1.8, linestyle="-.")
    
    # Direct endpoint labels
    ax1.text(time[-1] + 0.4, treated[-1], "Treated", color="#D55E00", fontsize=8.5, fontweight="semibold", va="center")
    ax1.text(time[-1] + 0.4, synthetic[-1], "Synthetic", color="#0072B2", fontsize=8.5, fontweight="semibold", va="center")
    
    ax1.set_xlim(time[0] - 0.5, time[-1] + 3.2)
    ax1.set_xlabel("Time Period", fontsize=9.5, labelpad=6)
    ax1.set_ylabel("Outcome Level", fontsize=9.5, labelpad=6)
    ax1.text(0.03, 0.95, "Panel A: Outcome Trajectories", transform=ax1.transAxes, fontsize=10, fontweight="bold", va="top")
    
    ax1.spines["top"].set_visible(False)
    ax1.spines["right"].set_visible(False)
    ax1.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.8)
    ax1.xaxis.grid(False)
    
    # ---------------- Panel B: Placebo Gaps ----------------
    ax2.axhline(0, color="#666666", linestyle="-", linewidth=0.8, alpha=0.8)
    ax2.axvline(n_pre, color="#555555", linestyle="--", linewidth=0.9)
    ax2.text(
        n_pre + 0.3, ax2.get_ylim()[1] if ax2.get_ylim()[1] != 0 else 3.0,
        f"Intervention ($T_0 = {n_pre}$)",
        color="#444444",
        fontsize=8.0,
        verticalalignment="top"
    )
    
    # Donor placebos in gray
    for idx in range(placebos.shape[0]):
        ax2.plot(time, placebos[idx], color="#B0B0B0", linewidth=0.75, alpha=0.55)
        
    ax2.plot(time, gap, color="#D55E00", linewidth=2.2)
    
    # Direct endpoint labels for Panel B
    ax2.text(time[-1] + 0.4, gap[-1], "Treated Gap", color="#D55E00", fontsize=8.5, fontweight="semibold", va="center")
    ax2.text(time[-1] + 0.4, placebos[-1, -1], "Placebos", color="#888888", fontsize=8.5, va="center")
    
    ax2.set_xlim(time[0] - 0.5, time[-1] + 3.8)
    ax2.set_xlabel("Time Period", fontsize=9.5, labelpad=6)
    ax2.set_ylabel("Treatment Gap (Observed minus Synthetic)", fontsize=9.5, labelpad=6)
    ax2.text(0.03, 0.95, "Panel B: In-Space Placebo Permutations", transform=ax2.transAxes, fontsize=10, fontweight="bold", va="top")
    
    ax2.spines["top"].set_visible(False)
    ax2.spines["right"].set_visible(False)
    ax2.yaxis.grid(True, linestyle="--", linewidth=0.5, color="#E5E5E5", alpha=0.8)
    ax2.xaxis.grid(False)
    
    # Full self-contained note below exhibit
    note_text = (
        f"Notes: Panel A reports the observed outcome trajectory of the treated unit alongside the synthetic counterfactual "
        f"constructed via constrained quadratic optimization on pre-treatment periods (t = 1 to {n_pre}). Panel B displays the treatment "
        f"gap (observed minus synthetic) for the treated unit compared to in-space placebo iterations across all {placebos.shape[0]} donor units. "
        f"Dashed vertical line indicates policy intervention at t = {n_pre}."
    )
    fig.text(0.04, -0.06, note_text, ha="left", va="top", fontsize=7.5, color="#333333", wrap=True)
    
    fig.subplots_adjust(bottom=0.20, top=0.92, left=0.07, right=0.93, wspace=0.25)
    
    if out_png:
        fig.savefig(out_png, dpi=300, bbox_inches="tight")
    if out_pdf:
        fig.savefig(out_pdf, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    style_file = base_dir.parent.parent / "templates" / "academic.mplstyle"
    out_png = base_dir / "synthetic_control_preview.png"
    out_pdf = base_dir / "synthetic_control.pdf"
    
    t_axis, y_treat, donor_mat, t_cutoff = simulate_synthetic_control_data()
    opt_w, synth_y, gap_y = fit_synthetic_control(y_treat, donor_mat, t_cutoff)
    placebo_mat = compute_placebo_gaps(donor_mat, t_cutoff)
    plot_synthetic_control(t_axis, y_treat, synth_y, gap_y, placebo_mat, t_cutoff, out_png=out_png, out_pdf=out_pdf, style_path=style_file)
    print(f"Synthetic control plots saved to {out_png} and {out_pdf}")
