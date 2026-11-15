"""
Monte Carlo Simulation Study: Two-Way Fixed Effects vs Sun-Abraham (2021).
Evaluates finite-sample bias, RMSE, rejection rates, and coverage under staggered adoption
with cohort-heterogeneous treatment effects.

Parameters:
- Draws: 200 independent panel realizations
- Seed range: 1000 to 1199 (inclusive)
- Panel dimensions: N = 400 units, T = 12 periods (4,800 unit-period observations per draw)
- Adoption cohorts: t = 4, 7, 9, and never-treated (c = 999)

Outputs:
- monte_carlo_results.csv: Machine-readable tabular summary across relative event times
- monte_carlo_results.md: Markdown table with formatted results

Citations:
- Sun, L., & Abraham, S. (2021). Estimating dynamic treatment effects in event study designs with
  heterogeneous treatment effects. Journal of Econometrics, 225(2), 175-199.
  DOI: 10.1016/j.jeconom.2020.09.006
- Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing.
  Journal of Econometrics, 225(2), 254-277.
  DOI: 10.1016/j.jeconom.2021.03.014
"""

import sys
import time
from pathlib import Path
import numpy as np
import pandas as pd

# Ensure parent directory is on sys.path for direct script execution
_script_dir = Path(__file__).resolve().parent
if str(_script_dir.parent.parent) not in sys.path:
    sys.path.insert(0, str(_script_dir.parent.parent))

from causal_inference.event_studies.event_study import (
    simulate_staggered_panel,
    estimate_event_study,
    compute_true_effect_estimand
)


def run_monte_carlo(n_draws=200, start_seed=1000, min_event=-5, max_event=5):
    """
    Executes the Monte Carlo loop across independent panel draws.
    Tracks estimates, true estimands, confidence interval exclusion of zero,
    and confidence interval coverage of the true estimand.
    """
    window = list(range(min_event, max_event + 1))
    
    # Storage records per event time
    twfe_estimates = {k: [] for k in window}
    twfe_rejects = {k: [] for k in window}
    sa_estimates = {k: [] for k in window}
    sa_rejects = {k: [] for k in window}
    sa_covers = {k: [] for k in window}
    true_estimands = {k: [] for k in window}
    
    start_time = time.time()
    print(f"Starting Monte Carlo simulation: {n_draws} draws (seeds {start_seed} to {start_seed + n_draws - 1})...")
    
    for i in range(n_draws):
        seed = start_seed + i
        df = simulate_staggered_panel(n_units=400, n_periods=12, seed=seed)
        true_dict = compute_true_effect_estimand(df, min_event=min_event, max_event=max_event)
        df_twfe, df_sa, _, _ = estimate_event_study(df, min_event=min_event, max_event=max_event)
        
        twfe_dict = df_twfe.set_index("event_time").to_dict(orient="index")
        sa_dict = df_sa.set_index("event_time").to_dict(orient="index")
        
        for k in window:
            true_k = true_dict[k]
            true_estimands[k].append(true_k)
            
            # TWFE record
            est_twfe = twfe_dict[k]["est"]
            lo_twfe = twfe_dict[k]["ci_lo"]
            hi_twfe = twfe_dict[k]["ci_hi"]
            twfe_estimates[k].append(est_twfe)
            if k == -1:
                twfe_rejects[k].append(0.0)
            else:
                twfe_rejects[k].append(float(lo_twfe > 0 or hi_twfe < 0))
                
            # Sun-Abraham record
            est_sa = sa_dict[k]["est"]
            lo_sa = sa_dict[k]["ci_lo"]
            hi_sa = sa_dict[k]["ci_hi"]
            sa_estimates[k].append(est_sa)
            if k == -1:
                sa_rejects[k].append(0.0)
                sa_covers[k].append(1.0)
            else:
                sa_rejects[k].append(float(lo_sa > 0 or hi_sa < 0))
                sa_covers[k].append(float(lo_sa <= true_k <= hi_sa))
                
        if (i + 1) % 25 == 0 or (i + 1) == n_draws:
            elapsed = time.time() - start_time
            print(f"  Completed {i + 1}/{n_draws} draws ({elapsed:.1f}s elapsed)...")
            
    total_time = time.time() - start_time
    print(f"Simulation completed in {total_time:.2f} seconds.")
    
    # Aggregate statistics
    results = []
    for k in window:
        trues = np.array(true_estimands[k])
        twfes = np.array(twfe_estimates[k])
        sas = np.array(sa_estimates[k])
        
        true_mean = float(np.mean(trues))
        twfe_mean = float(np.mean(twfes))
        twfe_bias = float(np.mean(twfes - trues))
        twfe_rmse = float(np.sqrt(np.mean((twfes - trues) ** 2)))
        twfe_rej = float(np.mean(twfe_rejects[k]))
        
        sa_mean = float(np.mean(sas))
        sa_bias = float(np.mean(sas - trues))
        sa_rmse = float(np.sqrt(np.mean((sas - trues) ** 2)))
        sa_rej = float(np.mean(sa_rejects[k]))
        sa_cov = float(np.mean(sa_covers[k])) if k >= 0 else float(np.nan)
        
        results.append({
            "event_time": k,
            "true_mean": true_mean,
            "twfe_mean": twfe_mean,
            "twfe_bias": twfe_bias,
            "twfe_rmse": twfe_rmse,
            "twfe_reject": twfe_rej,
            "sa_mean": sa_mean,
            "sa_bias": sa_bias,
            "sa_rmse": sa_rmse,
            "sa_reject": sa_rej,
            "sa_coverage": sa_cov
        })
        
    df_results = pd.DataFrame(results)
    return df_results, total_time


def write_outputs(df_results, total_time, n_draws=200, start_seed=1000):
    """
    Writes CSV and Markdown output tables to the script directory.
    """
    csv_path = _script_dir / "monte_carlo_results.csv"
    md_path = _script_dir / "monte_carlo_results.md"
    
    df_results.to_csv(csv_path, index=False)
    print(f"Results CSV written: {csv_path}")
    
    md_lines = [
        f"# Monte Carlo Simulation Results: Event Study Estimators",
        f"",
        f"- Number of draws: {n_draws}",
        f"- Seed range: {start_seed} to {start_seed + n_draws - 1}",
        f"- Total runtime: {total_time:.2f} seconds",
        f"- Sample per draw: N = 400 units, T = 12 periods (4,800 observations)",
        f"",
        f"| Relative Time (k) | True Estimand | TWFE Mean | TWFE Bias | TWFE RMSE | TWFE Rejection Rate | SA Mean | SA Bias | SA RMSE | SA Rejection Rate | SA Coverage (95% CI) |",
        f"| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |"
    ]
    
    for _, row in df_results.iterrows():
        k_str = f"<= -5" if int(row['event_time']) == -5 else (f"5+" if int(row['event_time']) == 5 else f"{int(row['event_time']):+d}" if int(row['event_time']) != 0 else "0")
        cov_str = f"{row['sa_coverage']:.3f}" if not np.isnan(row['sa_coverage']) else "N/A"
        md_lines.append(
            f"| {k_str} | {row['true_mean']:.3f} | {row['twfe_mean']:.3f} | {row['twfe_bias']:+.3f} | {row['twfe_rmse']:.3f} | {row['twfe_reject']:.3f} | {row['sa_mean']:.3f} | {row['sa_bias']:+.3f} | {row['sa_rmse']:.3f} | {row['sa_reject']:.3f} | {cov_str} |"
        )
        
    md_content = "\n".join(md_lines) + "\n"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"Results Markdown written: {md_path}")


def main():
    n_draws = 200
    start_seed = 1000
    df_results, total_time = run_monte_carlo(n_draws=n_draws, start_seed=start_seed)
    write_outputs(df_results, total_time, n_draws=n_draws, start_seed=start_seed)


if __name__ == "__main__":
    main()
