using DataFrames, GLM, StatsBase, Random

# Set a Random Seed for reproducibility
Random.seed!(123)

# Generate synthetic data
n = 500
df = DataFrame(
  id = 1:n,
  x1 = randn(n),
  x2 = randn(n),
  treated = rand([0,1], n),
  post = rand([0.,1], n),
)

# Create dependent variables for regressions
df.y_ols = 3 .+ 2 .* df.x1 .- 1.5 .* df.x2 .+ 0.5 .* df.treated .+ randn(n) # For OLS
df.y_did = 5 .+ 1 .* df.treated .* df.post + 0.2 .* randn(n) # For diff-in-diff
df.y_probit = df.x1 .- 0.5 .* df.x2 .+ 0.8 .* df.treated .> 0 # Binary outcome for Probit

# OLS Regression
println("OLS Regression:")
ols_model = lm(@formula(y_ols ~ x1 + x2 + treated), df)
println(ols_model)

# Diff-in-Diff Regression
println("\nDifferences-in-Differences Regression:")
df.did_interaction = df.treated .* df.post
did_model = lm(@formula(y_did ~ treated + post + did_interaction), df)
println(did_model)

# Probit Regression
println("\nProbit Regression:")
df.y_probit = convert(Vector{Int}, df.y_probit) # Ensure binary outcome is an integer
probit_model = glm(@formula(y_probit ~ x1 + x2 + treated), df, Binomial(), ProbitLink())
println(probit_model)
