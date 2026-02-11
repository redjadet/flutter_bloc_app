# How the Mann-Whitney U-Test Is Calculated

This document explains the Mann-Whitney U-test used in the Dispersion Analyzer feature.

It covers:

- the statistically correct (textbook) calculation

---

## 1. Purpose of the Test

- Compare two independent samples (e.g., radial distances from Dataset A vs Dataset B).
- Test whether their distributions differ in tendency (larger/smaller values), without assuming normality.
- Use a two-sided hypothesis for "any difference".

---

## 2. Inputs

- Sample A: list of `nA` numeric values.
- Sample B: list of `nB` numeric values.
- Alpha (`alpha`): significance threshold (e.g., `0.05`).

---

## 3. Step-by-Step Calculation

### Step 1: Pool and sort

- Combine A and B into one list of size `N = nA + nB`.
- Sort ascending while keeping sample origin labels (A or B).

### Step 2: Assign ranks (with ties)

- Assign ranks `1..N`.
- For tied values, assign each tied value the average of occupied ranks.

Example:

- Values: `10, 20, 20, 20, 30`
- Ranks: `1, 3, 3, 3, 5`

### Step 3: Sum ranks for sample A

- `R1 = sum of ranks belonging to sample A`.

### Step 4: Compute U

- `U1 = nA*nB + nA*(nA+1)/2 - R1`
- `U2 = nA*nB - U1`
- Test statistic reported in this app: `U = min(U1, U2)`

Null mean:

- `mu = nA*nB/2`

### Step 5: Tie correction term

- For each tie group of size `t`, compute `t^3 - t`.
- Sum over tie groups:
- `T = sum(t^3 - t)`

### Step 6: Variance under null (textbook)

Tie-corrected variance for Mann-Whitney U:

- `sigma^2 = (nA*nB/12) * ( (N + 1) - T/(N*(N-1)) )`
- `sigma = sqrt(sigma^2)`

This is the standard normal-approximation variance with ties.

### Step 7: Continuity-corrected z and p-value

- Let `d = U - mu`.
- Absolute continuity-corrected z used for two-sided p-value:
- `zAbs = max(|d| - 0.5, 0) / sigma`
- Two-sided p-value:
- `p = 2 * (1 - Phi(zAbs))`

Where `Phi` is the standard normal CDF.

### Step 8: Significance

- Significant if `p <= alpha`.

### Step 9: Effect size

Two common forms:

- Directional rank-biserial (signed): derived from `U1` (or `U2`) and can be in `[-1, 1]`.
- Magnitude-only form: if `U = min(U1, U2)` is used, then
- `r_rb = 1 - 2*U/(nA*nB)`
- This is non-directional and lies in `[0, 1]`.

---

## 4. Edge Cases

- If `nA == 0` or `nB == 0`:
- Return `U=0`, `z=0`, `p=1`, `isSignificant=false`, and small-sample caution.
- If all values are tied heavily, `sigma` can be near zero; implementation guards against divide-by-zero by using `z=0` path when `sigma <= 0`.
- Small sample caution is raised when `nA < 20` or `nB < 20` (normal approximation may be rough).

---

## 5. Quick Reference

| Quantity | Formula |
| --- | --- |
| `U1` | `nA*nB + nA*(nA+1)/2 - R1` |
| `U2` | `nA*nB - U1` |
| `U` (app) | `min(U1, U2)` |
| `mu` | `nA*nB/2` |
| `T` | `sum(t^3 - t)` over tie groups |
| `sigma^2` (textbook) | `(nA*nB/12) * ( (N+1) - T/(N*(N-1)) )` |
| `zAbs` | `max(abs(U-mu)-0.5, 0) / sigma` |
| two-sided `p` | `2 * (1 - Phi(zAbs))` |
| rank-biserial (magnitude form) | `1 - 2*U/(nA*nB)` when `U=min(...)` |
