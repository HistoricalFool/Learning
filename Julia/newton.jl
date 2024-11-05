using LinearAlgebra, ForwardDiff, Printf

## Defining Newton Algorithm
function newton(U,S,tol,maxiter)
  # Gradient matrix
  g(S) = ForwardDiff.gradient(U,S)
  
  # Hessian U
  H(S) = ForwardDiff.hessian(U,S)

  # Copying
  S_old = copy(S)

  results = []
  for k = 1:maxiter
    step = H(S_old) \ (-g(S_old))

    S_new = S_old + step

    norm_step = norm(step)
    norm_S_old = norm(S_old)
    
    push!(results, [k; S_new])

    if norm_step < tol * (1+norm_S_old)
      S = S_new
      break
    elseif k == maxiter
      println("Maximum iterations reached.")
    else
      S_old = S_new
    end
  end
  return S, results
end

beta = 0.9
Tau = 6 
r = 0.2
omega = [0,1,1,1,1,0,0]
S_1 = zeros(5)
S_2 = [0.5,0.5,0.5,0.5,0.5]

tol = 1e-6
maxiter = 25

u(c) = -exp(-c)

function U(S)
  U = 0
  S = [0; S; 0]
  for t = 1:Tau+1
    c = (1+r)*S[t] + omega[t] - S[t+1]
    U += (beta^t) * u(c)
  end
  return U
end

S1, results1 = newton(U,S_1,tol,maxiter)
S2, results2 = newton(U,S_2,tol,maxiter)

headers = ["Iteration"; ["S$i" for i = 1:length(S1)]]
println("\nIteration S1 Using Zeros:")
println(tabulate(results1, headers=headers, tablefmt="fancy_grid", floatfmt=".4f"))
println("\nOptimal Savings for S1:", S1)

headers_2 = ["Iteration"; ["S$i" for i = 1:length(S2)]]
println("\nIteration S2 using 0.5:")
println(tabulate(results2, headers=headers_2, tablefmt="fancy_grid", floatfmt=".4f"))
println("\nOptimal Savings for S2:", S2)
