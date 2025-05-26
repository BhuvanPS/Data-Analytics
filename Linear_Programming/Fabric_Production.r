# Load the required package for Linear Programming
library(lpSolveAPI)

# Define number of decision variables (3 fabrics × 3 seasons)
num_decisions <- 9

# Initialize LP model with zero constraints and 9 variables
model <- make.lp(0, num_decisions)

# Set the coefficients of the objective function (profit per unit)
profit_vector <- c(25, 10, 5, 22, 7, 2, 25, 10, 5)
set.objfn(model, profit_vector)

# === Add Demand Constraints ===
# Ensure seasonal production does not exceed demand
add.constraint(model, c(1, 1, 1, 0, 0, 0, 0, 0, 0), "<=", 3500)  # Spring
add.constraint(model, c(0, 0, 0, 1, 1, 1, 0, 0, 0), "<=", 3300)  # Autumn
add.constraint(model, c(0, 0, 0, 0, 0, 0, 1, 1, 1), "<=", 4200)  # Winter

# === Add Fabric Proportion Constraints per Season ===
# Spring
add.constraint(model, c(0.45, -0.55, -0.55, 0, 0, 0, 0, 0, 0), ">=", 0)   # Cotton ≥ 45%
add.constraint(model, c(-0.30, 0.70, -0.30, 0, 0, 0, 0, 0, 0), ">=", 0)   # Wool ≥ 30%

# Autumn
add.constraint(model, c(0, 0, 0, 0.55, -0.45, -0.45, 0, 0, 0), ">=", 0)   # Cotton ≥ 55%
add.constraint(model, c(0, 0, 0, -0.40, 0.60, -0.40, 0, 0, 0), ">=", 0)   # Wool ≥ 40%

# Winter
add.constraint(model, c(0, 0, 0, 0, 0, 0, 0.70, -0.30, -0.30), ">=", 0)   # Cotton ≥ 70%
add.constraint(model, c(0, 0, 0, 0, 0, 0, -0.50, 0.50, -0.50), ">=", 0)   # Wool ≥ 50%

# Ensure all decision variables are treated as real and non-negative
set.type(model, columns = 1:num_decisions, type = "real")

# Set the LP direction to maximization
lp.control(model, sense = "max")

# Solve the LP model
solve(model)

# Output the optimal profit
max_profit <- get.objective(model)
cat("Optimal Profit:", max_profit, "\n")

# Extract and display optimal values for decision variables
solution <- get.variables(model)
solution_matrix <- matrix(solution, nrow = 3, byrow = FALSE,
                          dimnames = list(c("Cotton", "Wool", "Silk"),
                                          c("Spring", "Autumn", "Winter")))

cat("Optimal Production Plan (units):\n")
print(solution_matrix)

# Reference: Berkelaar, M., Eikland, K., & Notebaert, P. (2022). lpSolveAPI: R Interface to 'lp_solve' Version 5.5.2.0. CRAN. https://cran.r-project.org/package=lpSolveAPI
