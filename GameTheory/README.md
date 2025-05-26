# Interactive Game Theory Solver

This R Shiny application provides an interactive tool for solving two-player zero-sum games. It allows users to define a payoff matrix and then calculates the optimal strategies for both players (Player A and Player B) and the value of the game, determining whether a pure or mixed strategy is optimal.

## Features

* **Dynamic Payoff Matrix Input**: Easily define the dimensions of the payoff matrix (rows for Player A, columns for Player B) and input individual cell values.
* **Optimal Strategy Calculation**: Solves for both pure strategies (if a saddle point exists) and mixed strategies (using linear programming).
* **Game Value Determination**: Calculates the expected payoff of the game when both players play optimally.
* **Clear Output**: Presents the game type, optimal probabilities for each player, and the game value in an easy-to-read format.

## How to Use

To run this application, you need to have R and the following R packages installed:

* `shiny`
* `lpSolveAPI`
* `shinyWidgets`

### Installation

1.  **Install R**: If you don't have R installed, download it from the [CRAN website](https://cran.r-project.org/).
2.  **Install RStudio (Optional but Recommended)**: RStudio is an excellent IDE for R development. Download it from the [RStudio website](https://posit.co/download/rstudio-desktop/).
3.  **Install Required R Packages**: Open R or RStudio and run the following commands in the console:

    ```R
    install.packages("shiny")
    install.packages("lpSolveAPI")
    install.packages("shinyWidgets")
    ```

### Running the Application

1.  Save the provided R code into a file named `app.R`.
2.  Open `app.R` in RStudio.
3.  Click the "Run App" button in RStudio, or execute the following command in the R console:

    ```R
    shiny::runApp("app.R")
    ```

### Interacting with the App

1.  **Set Matrix Dimensions**: Use the "Rows (Player A)" and "Cols (Player B)" numeric inputs to define the size of your payoff matrix.
2.  **Generate Matrix**: Click the "Generate Matrix" button. Input fields for the payoff matrix will appear.
3.  **Input Payoff Values**: Enter the payoff values for each cell in the matrix. These values represent the payoff to Player A for each combination of strategies.
4.  **Solve Game**: Click the "Solve Game" button to calculate and display the optimal strategies and game value.

## Game Theory Concepts Explained

* **Pure Strategy**: Choosing one action deterministically.
* **Mixed Strategy**: Randomizing over possible actions.
* **Saddle Point**: An outcome where neither player can unilaterally improve their payoff.
* **Game Value**: The expected payoff when both players play optimally.

## Solver Logic

The application uses the `lpSolveAPI` package to solve the linear programming problems involved in finding mixed strategies. It first checks for a pure strategy solution (saddle point). If none exists, it formulates and solves linear programs to determine the optimal mixed strategies and the game value.

## Styling

The application includes custom CSS to enhance the user interface.

## Credits

Developed by Bhuvan