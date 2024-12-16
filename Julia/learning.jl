using DataFrames, GLM, StatsBase, Random, PrettyTables

# Set a random seed for reproducibility
Random.seed!(123)

# Generate synthetic data
n = 500
df = DataFrame(
    id = 1:n,
    x1 = randn(n),
    x2 = randn(n),
    treated = rand([0, 1], n),
    post = rand([0, 1], n),
)

# Create dependent variables for regressions
df.y_ols = 3 .+ 2 .* df.x1 .- 1.5 .* df.x2 .+ 0.5 .* df.treated .+ randn(n)  # For OLS
df.y_did = 5 .+ 1 .* df.treated .* df.post + 0.2 .* randn(n)  # For Difference-in-Differences
df.y_probit = df.x1 .- 0.5 .* df.x2 .+ 0.8 .* df.treated .> 0  # Binary outcome for Probit

# OLS Regression
println("\nOLS Regression:")
ols_model = lm(@formula(y_ols ~ x1 + x2 + treated), df)
ols_table = coeftable(ols_model)
ols_data = DataFrame(
    Coefficient = ols_table.cols[1],       # Coefficients
    StdError = ols_table.cols[2],          # Standard Errors
    tvalue = ols_table.cols[3],            # t-values
    Pval = ols_table.cols[4]               # p-values
)
pretty_table(ols_data; header=["Coefficient", "Std. Error", "t-value", "P>|t|"], formatters=ft_printf("%.4f"))
println("R²: ", r2(ols_model))
println("Adjusted R²: ", adjr2(ols_model))

# Difference-in-Differences Regression
println("\nDifference-in-Differences Regression:")
df.did_interaction = df.treated .* df.post  # Interaction term
did_model = lm(@formula(y_did ~ treated + post + did_interaction), df)
did_table = coeftable(did_model)
did_data = DataFrame(
    Coefficient = did_table.cols[1],       # Coefficients
    StdError = did_table.cols[2],          # Standard Errors
    tvalue = did_table.cols[3],            # t-values
    Pval = did_table.cols[4]               # p-values
)
pretty_table(did_data; header=["Coefficient", "Std. Error", "t-value", "P>|t|"], formatters=ft_printf("%.4f"))
println("R²: ", r2(did_model))
println("Adjusted R²: ", adjr2(did_model))

# Probit Regression
println("\nProbit Regression:")
df.y_probit = convert(Vector{Int}, df.y_probit)  # Ensure binary outcome is an integer
probit_model = glm(@formula(y_probit ~ x1 + x2 + treated), df, Binomial(), ProbitLink())
probit_table = coeftable(probit_model)
probit_data = DataFrame(
    Coefficient = probit_table.cols[1],    # Coefficients
    StdError = probit_table.cols[2],       # Standard Errors
    zvalue = probit_table.cols[3],         # z-values
    Pval = probit_table.cols[4]            # p-values
)
pretty_table(probit_data; header=["Coefficient", "Std. Error", "z-value", "P>|z|"], formatters=ft_printf("%.4f"))

println("\nModel Summary:")
println("Log-Likelihood: ", loglikelihood(probit_model))
println("Pseudo R²: ", 1 - loglikelihood(probit_model) / loglikelihood(glm(@formula(y_probit ~ 1), df, Binomial(), ProbitLink())))

# Display confidence intervals for Probit model
conf_intervals = confint(probit_model)
conf_table = DataFrame(Variable=coefnames(probit_model), Lower=conf_intervals[:, 1], Upper=conf_intervals[:, 2])
pretty_table(conf_table; header=["Variable", "Lower CI", "Upper CI"], formatters=ft_printf("%.4f"))
