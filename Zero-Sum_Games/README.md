# 🎯 Game Theory Solver (Pure & Mixed Strategies) in R using lpSolveAPI

This R project provides a general solver for two-player **zero-sum games** using a **payoff matrix**. It supports both **pure strategies** (when a saddle point exists) and **mixed strategies** (using Linear Programming via `lpSolveAPI`).

---

## 📦 Requirements

- R (version ≥ 3.6)
- R package: `lpSolveAPI`

Install the required package in R:

```r
install.packages("lpSolveAPI")
```

---

## 🧠 Features

- ✅ Detects **Pure Strategy** equilibrium (saddle point)
- 🔁 Solves **Mixed Strategy** using Linear Programming (LP)
- Computes:
  - Optimal strategy for Player A and Player B
  - Game value (expected payoff)
  - Strategy probabilities

---

## 🚀 How to Use

### 1. Clone or copy the script

Download or clone the repository, then load the script in your R environment.

### 2. Define your payoff matrix

The matrix must represent **Player A’s payoffs**:

```r
payoff_matrix <- matrix(c(4, 2,
                          3, 1), nrow = 2, byrow = TRUE)
```

### 3. Run the solver

Use the following function to find the optimal strategy (pure or mixed):

```r
result <- find_optimal_strategy_oneshot(payoff_matrix)
```

### 4. View results

```r
result$type               # "Pure Strategy" or "Mixed Strategy"
result$playerA_strategy   # Strategy probabilities for Player A
result$playerB_strategy   # Strategy probabilities for Player B
result$game_value         # Expected payoff (game value)
```

---

## 🧪 Example

```r
payoff_matrix <- matrix(c(4, 2,
                          3, 1), nrow = 2, byrow = TRUE)
```

**Output:**

```
=== Game Type ===
 Pure Strategy 

=== Player A Strategy ===
[1] 1 0

=== Player B Strategy ===
[1] 0 1

=== Game Value ===
[1] 2
```

---

## 📚 How It Works

- **Pure Strategy Detection**:
  - Checks for saddle point: `max(row mins) == min(col maxes)`
- **Mixed Strategy Solver**:
  - LP formulation:
    - Player A: maximize `v` such that Aᵗx ≥ v and ∑x = 1
    - Player B: minimize `v` such that Ay ≤ v and ∑y = 1

Implemented using the `lpSolveAPI` R package for building and solving LP problems.

---

## 📁 Files

- `ZeroSumGame.R` – Main script
- `README.md` – Documentation file

---

## 📌 Notes

- Works only for **2-player zero-sum games**
- Input matrix must be numeric and 2D (e.g., 2x2, 3x4, etc.)
- Payoff matrix should be from **Player A's** perspective

---

## 📚 References

- Game Theory by John von Neumann and Oskar Morgenstern
- [lpSolveAPI Documentation](https://cran.r-project.org/package=lpSolveAPI)

---

## 🧊 License

MIT License. Feel free to use and modify.
