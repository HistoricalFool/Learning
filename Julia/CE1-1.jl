# Part A: Find expenditure share of each category
using SymPy, Optim

# Define parameters
omega_a = 0.3
omega_m = 0.3
omega_s = 0.4

p_a = 1
p_m = 1
p_s = 1

c_bar_a = 0.5
c_bar_m = 0
c_bar_s = 1

C = 100

# Define the system of first-order conditions
c_a, c_m, c_s, lambda = symbols("c_a c_m c_s lambda")

FOC_a = omega_a / (c_a + c_bar_a) - lambda * p_a
FOC_m = omega_m / (c_m + c_bar_m) - lambda * p_m
FOC_s = omega_s / (c_s + c_bar_s) - lambda * p_s
budget_eq = p_a * c_a + p_m * c_m + p_s * c_s - C

sols = solve([FOC_a, FOC_m, FOC_s, budget_eq], [c_a, c_m, c_s, lambda])

c_a_sol = float(sols[c_a])
c_m_sol = float(sols[c_m])
c_s_sol = float(sols[c_s])

s_a = p_a * c_a_sol / C
s_m = p_m * c_m_sol / C
s_s = p_s * c_s_sol / C

println("Optimal consumption for agriculture (c_a): $c_a_sol")
println("Optimal consumption for manufacturing (c_m): $c_m_sol")
println("Optimal consumption for services (c_s): $c_s_sol")
println("Expenditure share for agriculture (s_a): $s_a")
println("Expenditure share for manufacturing (s_m): $s_m")
println("Expenditure share for services (s_s): $s_s")

# Part B: Changing shares with c-bar
c_bar_a = -0.5
c_bar_m = 0
c_bar_s = 1

C_values = range(10, 500, length=100)

s_a_vals = zeros(length(C_values))
s_m_vals = zeros(length(C_values))
s_s_vals = zeros(length(C_values))

for i in 1:length(C_values)
    C = C_values[i]
    
    c_a, c_m, c_s, lambda = symbols("c_a c_m c_s lambda")
    
    FOC_a = omega_a / (c_a + c_bar_a) - lambda * p_a
    FOC_m = omega_m / (c_m + c_bar_m) - lambda * p_m
    FOC_s = omega_s / (c_s + c_bar_s) - lambda * p_s
    budget_eq = p_a * c_a + p_m * c_m + p_s * c_s - C
    
    sols = solve([FOC_a, FOC_m, FOC_s, budget_eq], [c_a, c_m, c_s, lambda])
    
    c_a_sol = float(sols[c_a])
    c_m_sol = float(sols[c_m])
    c_s_sol = float(sols[c_s])
    
    s_a_vals[i] = p_a * c_a_sol / C
    s_m_vals[i] = p_m * c_m_sol / C
    s_s_vals[i] = p_s * c_s_sol / C
end

plot(C_values, s_a_vals, "r", label="Agriculture (s_a)")
plot!(C_values, s_m_vals, "g", label="Manufacturing (s_m)")
plot!(C_values, s_s_vals, "b", label="Services (s_s)")
xlabel!("Total Expenditure (C)")
ylabel!("Expenditure Shares")
title!("Expenditure Shares vs Total Expenditure")
legend()
grid!(true)
