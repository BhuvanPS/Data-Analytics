library(shiny)
library(lpSolveAPI)
library(shinyWidgets)

# Solver function
# This function calculates the optimal strategies for Player A and Player B
# and the value of the game, for both pure and mixed strategies.
find_optimal_strategy_oneshot <- function(A) {
  m <- nrow(A)
  n <- ncol(A)

  # Calculate row minimums and column maximums for saddle point check
  row_mins <- apply(A, 1, min)
  col_maxs <- apply(A, 2, max)

  # Check for saddle point (Pure Strategy)
  # A saddle point exists if there's an element that is the minimum in its row
  # and the maximum in its column.
  for (i in 1:m) {
    for (j in 1:n) {
      if (A[i, j] == row_mins[i] && A[i, j] == col_maxs[j]) {
        strategyA <- rep(0, m)
        strategyB <- rep(0, n)
        strategyA[i] <- 1 # Player A chooses row i with probability 1
        strategyB[j] <- 1 # Player B chooses column j with probability 1
        return(list(
          type = "Pure Strategy",
          playerA_strategy = strategyA,
          playerB_strategy = strategyB,
          game_value = A[i, j] # Game value is the saddle point value
        ))
      }
    }
  }

  # Mixed Strategy (if no saddle point is found)
  # Linear programming is used to find optimal mixed strategies.
  # A shift is applied to the payoff matrix to ensure all values are non-negative,
  # which is a requirement for the standard LP formulation.
  min_val <- min(A)
  shift <- if (min_val < 0) -min_val else 0
  A_shifted <- A + shift

  # Player A's problem (maximize the game value)
  # Variables: p1, p2, ..., pm (probabilities for Player A's strategies) and v (game value)
  # Objective: Maximize v
  # Constraints:
  #   - Sum of probabilities = 1
  #   - Expected payoff for each of Player B's strategies >= v
  #   - Probabilities >= 0
  lpA <- make.lp(0, m + 1) # m variables for probabilities, 1 for game value
  set.objfn(lpA, c(rep(0, m), 1)) # Objective function coefficients (0 for probs, 1 for v)
  lp.control(lpA, sense = "max") # Maximize
  for (j in 1:n) add.constraint(lpA, c(A_shifted[, j], -1), ">=", 0) # Expected payoff constraints
  add.constraint(lpA, c(rep(1, m), 0), "=", 1) # Sum of probabilities for Player A = 1
  for (i in 1:m) set.bounds(lpA, lower = 0, columns = i) # Probabilities for Player A >= 0
  solve(lpA) # Solve the linear program
  solA <- get.variables(lpA)
  probsA <- solA[1:m] # Player A's optimal probabilities
  game_val <- solA[m + 1] - shift # Game value (shifted back)

  # Player B's problem (minimize the game value)
  # Variables: q1, q2, ..., qn (probabilities for Player B's strategies) and w (game value)
  # Objective: Minimize w
  # Constraints:
  #   - Sum of probabilities = 1
  #   - Expected payoff for each of Player A's strategies <= w
  #   - Probabilities >= 0
  lpB <- make.lp(0, n + 1) # n variables for probabilities, 1 for game value
  set.objfn(lpB, c(rep(0, n), 1)) # Objective function coefficients (0 for probs, 1 for w)
  lp.control(lpB, sense = "min") # Minimize
  for (i in 1:m) add.constraint(lpB, c(A_shifted[i, ], -1), "<=", 0) # Expected payoff constraints
  add.constraint(lpB, c(rep(1, n), 0), "=", 1) # Sum of probabilities for Player B = 1
  for (j in 1:n) set.bounds(lpB, lower = 0, columns = j) # Probabilities for Player B >= 0
  solve(lpB) # Solve the linear program
  solB <- get.variables(lpB)
  probsB <- solB[1:n] # Player B's optimal probabilities

  return(list(
    type = "Mixed Strategy",
    playerA_strategy = probsA,
    playerB_strategy = probsB,
    game_value = game_val
  ))
}

# User Interface (UI)
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background: #f4f6f8;
        color: #333;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        padding-top: 20px;
      }
      .container-fluid {
        max-width: 1200px;
        margin: auto;
        padding: 20px;
        background-color: #fff;
        box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        border-radius: 10px;
      }
      .title-panel {
        color: #37474f;
        text-align: center;
        padding-bottom: 20px;
        border-bottom: 1px solid #e0e0e0;
        margin-bottom: 30px;
      }
      h2 {
        color: #263238;
      }
      h3 {
        color: #37474f;
        margin-top: 20px;
      }
      .sidebar {
        background-color: #eceff1;
        padding: 20px;
        border-radius: 8px;
      }
      .main-content {
        padding: 20px;
      }
      .form-group {
        margin-bottom: 15px;
      }
      .btn-generate, .btn-solve, .btn-reset {
        background-color: #00796b;
        color: white;
        border: none;
        padding: 12px 25px;
        font-weight: 500;
        border-radius: 6px;
        cursor: pointer;
        transition: background-color 0.3s ease;
        margin-top: 15px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
      }
      .btn-generate:hover, .btn-solve:hover, .btn-reset:hover {
        background-color: #004d40;
      }
      .btn-reset {
        background-color: #f44336; /* Red for reset */
      }
      .btn-reset:hover {
        background-color: #d32f2f;
      }
      #matrixInputs {
        margin-top: 20px;
      }
      .matrix-row {
        display: flex;
        gap: 10px;
        margin-bottom: 10px;
      }
      .matrix-cell {
        flex-grow: 1;
      }
      .numeric-input-label {
        display: block;
        font-size: 0.9em;
        color: #546e7a;
        margin-bottom: 5px;
      }
      .shiny-input-container:not(.shiny-input-container-inline) {
        width: 100%;
      }
      .result-output {
        margin-top: 30px;
        padding: 15px;
        background-color: #e0f2f1;
        border-radius: 8px;
        border: 1px solid #b2dfdb;
      }
      .info-box-outer {
        background-color: #f9fbe7;
        border: 1px solid #cddc39;
        border-radius: 8px;
        padding: 15px;
        margin-top: 20px;
      }
      .info-box-outer h3 {
        color: #827717;
        margin-top: 0;
      }
      .info-list {
        list-style-type: disc;
        padding-left: 20px;
        color: #43a047;
      }
      .info-list strong {
        color: #2e7d32;
      }
      .creator {
        text-align: center;
        color: #78909c;
        font-size: 0.9em;
        margin-top: 20px;
      }
    "))
  ),

  div(class = "container-fluid",
    div(class = "title-panel",
      h2("Interactive Game Theory Solver")
    ),

    fluidRow(
      column(width = 4, class = "sidebar",
        numericInput("rows", "Rows (Player A):", value = 2, min = 1, max = 10),
        numericInput("cols", "Cols (Player B):", value = 2, min = 1, max = 10),
        actionButton("generate", "Generate Matrix", class = "btn-generate")
        # Removed actionButton("reset")
      ),
      column(width = 8, class = "main-content",
        div(
          id = "matrixInputs",
          h3("Payoff Matrix (Player A's perspective)"),
          uiOutput("matrixInputs")
        ),

        uiOutput("solveBtnUI"),

        div(class = "result-output",
          h3("Solution"),
          verbatimTextOutput("result")
        ),

        tags$div(
          class = "info-box-outer",
          h3("Game Theory Concepts"),
          tags$ul(class = "info-list",
            tags$li(tags$strong("Pure Strategy:"), "Choosing one action deterministically."),
            tags$li(tags$strong("Mixed Strategy:"), "Randomizing over possible actions."),
            tags$li(tags$strong("Saddle Point:"), "An outcome where neither player can unilaterally improve their payoff."),
            tags$li(tags$strong("Game Value:"), "The expected payoff when both players play optimally.")
          )
        ),

        tags$div(class = "creator",
          tags$p("Developed with ❤️ by Bhuvan")
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  # reactiveVal to store the current state of the matrix.
  # NULL initially, and after a reset.
  matrix_inputs <- reactiveVal(NULL)

  # Store initial row/column values to revert to on reset
  # These are no longer strictly needed without reset, but kept for consistency
  # or if reset functionality is added back later.
  initial_rows <- reactiveVal(2)
  initial_cols <- reactiveVal(2)

  # Update initial_rows when input$rows changes
  observeEvent(input$rows, {
    initial_rows(input$rows)
  })

  # Update initial_cols when input$cols changes
  observeEvent(input$cols, {
    initial_cols(input$cols)
  })

  # Event handler for "Generate Matrix" button
  observeEvent(input$generate, {
    # Ensure rows and cols inputs are available
    req(input$rows, input$cols)
    # Initialize matrix_inputs with a new matrix of zeros based on current row/col values
    matrix_inputs(matrix(0, nrow = input$rows, ncol = input$cols))
  })

  # Render the matrix input fields dynamically
  output$matrixInputs <- renderUI({
    # Require matrix_inputs to be not NULL to render the matrix
    req(matrix_inputs())
    mat <- matrix_inputs()
    rows <- nrow(mat)
    cols <- ncol(mat)

    # Create UI elements for each cell in the matrix
    matrix_ui <- lapply(1:rows, function(i) {
      div(class = "matrix-row",
        lapply(1:cols, function(j) {
          div(class = "matrix-cell",
            div(class = "numeric-input-label", paste0("(", i, ",", j, ")")),
            numericInput(
              inputId = paste0("cell_", i, "_", j),
              label = NULL,
              value = mat[i, j], # Use the value from the reactive matrix_inputs
              width = "100%"
            )
          )
        })
      )
    })

    tagList(matrix_ui)
  })

  # Render the "Solve Game" button only if a matrix has been generated
  output$solveBtnUI <- renderUI({
    req(matrix_inputs()) # Button appears only when matrix_inputs is not NULL
    actionButton("solve", "Solve Game", class = "btn-solve")
  })

  # Event handler for "Solve Game" button
  observeEvent(input$solve, {
    req(matrix_inputs()) # Ensure a matrix exists
    mat <- matrix_inputs() # Get the current matrix dimensions
    rows <- nrow(mat)
    cols <- ncol(mat)

    # Create a new matrix to store values from the input fields
    updated_matrix <- matrix(NA, nrow = rows, ncol = cols)
    for (i in 1:rows) {
      for (j in 1:cols) {
        val <- input[[paste0("cell_", i, "_", j)]]
        # Assign value, default to 0 if input is NULL
        updated_matrix[i, j] <- ifelse(is.null(val), 0, as.numeric(val))
      }
    }

    # Update matrix_inputs reactive value with the values from the UI
    matrix_inputs(updated_matrix)

    # Call the solver function
    result <- find_optimal_strategy_oneshot(updated_matrix)

    # Render the solution output
    output$result <- renderPrint({
      cat("--- Optimal Strategy ---\n\n")
      cat("Game Type: ", result$type, "\n\n")
      cat("Player A's Optimal Strategy (Probabilities):\n")
      print(round(result$playerA_strategy, 3))
      cat("\nPlayer B's Optimal Strategy (Probabilities):\n")
      print(round(result$playerB_strategy, 3))
      cat("\nGame Value (Expected Payoff to Player A):\n")
      cat(round(result$game_value, 3), "\n")
    })
  })

  # Removed the observeEvent for input$reset
}

# Run the Shiny application
shinyApp(ui = ui, server = server)
