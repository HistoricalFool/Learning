using LinearAlgebra, ForwardDiff, Printf

# Defining the Newton algorithm
function newton(U, S, tol, maxiter)
    # Gradient matrix U
    g(S) = ForwardDiff.gradient(U, S)
    # Hessian U
    H(S) = ForwardDiff.hessian(U, S)
    
    # Copying
    S_old = copy(S)
    results = []

    for k = 1:maxiter
        # Calculating steps using Hessian and Gradient
        step = H(S_old) \ (-g(S_old))
        # New S value
        S_new = S_old + step

        norm_step = norm(step)
        norm_S_old = norm(S_old)

        push!(results, vcat(k, S_new))

        if norm_step < tol * (1 + norm_S_old)
            S = S_new
            break
        elseif k == maxiter
            println("Maximum iterations has been reached.")
        else
            S_old = S_new
        end
    end
    return S, results
end
## Use C-K with various combinations to insert greek letters ##
# Defining parameters
β = 0.9
T = 6
r = 0.2
w = [0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0]
S_1 = zeros(Float64, 5)
S_2 = fill(0.5, 5)

tol = 1e-6
maxiter = 25

# Defining utility function
u(c) = -exp(-c)

function U(S)
    # Create extended S array with 0.0 at start and end
    S_extended = vcat(0.0, S, 0.0)
    
    # Initialize utility
    utility = 0.0
    
    # Calculate utility for each time period
    for t = 1:T
        # Calculate consumption at time t
        c = (1+r)*S_extended[t] + w[t] - S_extended[t+1]
        # Add discounted utility
        utility += (β^t) * u(c)
    end
    
    return utility
end

# Run optimization with both initial conditions
S1, results1 = newton(U, S_1, tol, maxiter)
S2, results2 = newton(U, S_2, tol, maxiter)

# Helper function to print a row of values
function print_row(iteration, values)
    @printf("%4d │", iteration)
    for value in values
        @printf(" %8.4f │", value)
    end
    println()
end

# Function to print results table
function print_results(results, title)
    println("\n", title)
    println("Iter │   S1    │   S2    │   S3    │   S4    │   S5    │")
    println("─────┼─────────┼─────────┼─────────┼─────────┼─────────┤")
    
    for row in results
        print_row(Int(row[1]), row[2:end])
    end
end

# Print results
print_results(results1, "Results for zero initial guess:")
println("\nOptimal Savings for S1: ", S1)

print_results(results2, "Results for 0.5 initial guess:")
println("\nOptimal Savings for S2: ", S2)
