# Load lpSolveAPI
if (!require("lpSolveAPI")) install.packages("lpSolveAPI", dependencies = TRUE)
library(lpSolveAPI)

# Example: Replace this with any matrix
payoff_matrix <- matrix(c(3, 8,
                          7, 1), nrow = 2, byrow = TRUE)

print("Payoff Matrix (Player A):")
print(payoff_matrix)

find_optimal_strategy_oneshot <- function(A) {
  m <- nrow(A)
  n <- ncol(A)

  # Check for pure strategy saddle point
  row_mins <- apply(A, 1, min)
  col_maxs <- apply(A, 2, max)

  saddle_point <- NULL
  for (i in 1:m) {
    for (j in 1:n) {
      if (A[i, j] == row_mins[i] && A[i, j] == col_maxs[j]) {
        saddle_point <- list(row = i, col = j, value = A[i, j])
        break
      }
    }
    if (!is.null(saddle_point)) break
  }

  if (!is.null(saddle_point)) {
    strategyA <- rep(0, m)
    strategyB <- rep(0, n)
    strategyA[saddle_point$row] <- 1
    strategyB[saddle_point$col] <- 1
    return(list(
      type = "Pure Strategy",
      playerA_strategy = strategyA,
      playerB_strategy = strategyB,
      game_value = saddle_point$value
    ))
  }

  # No saddle point: solve mixed strategy using LP

  # Shift to non-negative
  min_val <- min(A)
  shift <- if (min_val < 0) -min_val else 0
  A_shifted <- A + shift

  # Player A LP (maximize v)
  lpA <- make.lp(0, m + 1)
  set.objfn(lpA, c(rep(0, m), 1))
  lp.control(lpA, sense = "max")
  for (j in 1:n) add.constraint(lpA, c(A_shifted[, j], -1), ">=", 0)
  add.constraint(lpA, c(rep(1, m), 0), "=", 1)
  for (i in 1:m) set.bounds(lpA, lower = 0, columns = i)
  solve(lpA)
  solA <- get.variables(lpA)
  probsA <- solA[1:m]
  game_val <- solA[m + 1] - shift

  # Player B LP (minimize v)
  lpB <- make.lp(0, n + 1)
  set.objfn(lpB, c(rep(0, n), 1))
  lp.control(lpB, sense = "min")
  for (i in 1:m) add.constraint(lpB, c(A_shifted[i, ], -1), "<=", 0)
  add.constraint(lpB, c(rep(1, n), 0), "=", 1)
  for (j in 1:n) set.bounds(lpB, lower = 0, columns = j)
  solve(lpB)
  solB <- get.variables(lpB)
  probsB <- solB[1:n]

  return(list(
    type = "Mixed Strategy",
    playerA_strategy = probsA,
    playerB_strategy = probsB,
    game_value = game_val
  ))
}

# Run solver
result <- find_optimal_strategy_oneshot(payoff_matrix)

# Print results
cat("=== Game Type ===\n", result$type, "\n")
cat("\n=== Player A Strategy ===\n")
print(result$playerA_strategy)
cat("\n=== Player B Strategy ===\n")
print(result$playerB_strategy)
cat("\n=== Game Value ===\n")
print(result$game_value)

