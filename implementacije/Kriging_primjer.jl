using Plots
plotly()  # Set the backend to PlotlyJS

using LinearAlgebra

# Definišemo funkciju
function f(x, y)
    return sin((x - y) / 2) * cos(sqrt(x^2 + y^2) / 2)
end

# Izračunava kovarijansu između dva para tačaka
function covariance(x1, y1, x2, y2, range=1.0)
    d = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return exp(-d / range)  # Exponential covariance function (Gaussian)
end

# Kreira matricu kovarijanse za skup tačaka
function covariance_matrix(x, y, range=1.0)
    n = length(x)
    C = zeros(n, n)
    for i in 1:n
        for j in 1:n
            C[i, j] = covariance(x[i], y[i], x[j], y[j], range)
        end
    end
    return C
end

# Kreira vektor kovarijanse između tačaka i novih tačaka
function covariance_vector(x, y, x_new, y_new, range=1.0)
    n = length(x)
    C_new = zeros(n)
    for i in 1:n
        C_new[i] = covariance(x[i], y[i], x_new, y_new, range)
    end
    return C_new
end

# Kriging interpolacija
function kriging_interpolation(x, y, z, x_new, y_new, range=1.0)
    n = length(x)
    
    # Matrica kovarijanse
    C = covariance_matrix(x, y, range)
    
    # Dodajemo malo dijagonalu za numeričku stabilnost
    C += 1e-10 * I
    
    # Vektor kovarijanse za nove tačke
    C_new = covariance_vector(x, y, x_new, y_new, range)
    
    # Računamo težine
    weights = C \ C_new
    
    # Izračunavamo vrednost
    z_new = dot(weights, z)
    return z_new
end

# Definiši poznate tačke
#x_known = [-3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0,
#            -3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

#y_known = [-3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0,
#             3.0,  2.5,  2.0,  1.5,  1.0,  0.5, 0.0, -0.5, -1.0, -1.5, -2.0, -2.5, -3.0]

x_known = [-3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
           0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0,
           -3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
            0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0]

y_known = [-3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
           0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0,
            3.0,  2.75,  2.5,  2.25,  2.0,  1.75,  1.5,  1.25,  1.0,  0.75,  0.5,  0.25, 0.0,
           -0.25, -0.5, -0.75, -1.0, -1.25, -1.5, -1.75, -2.0, -2.25, -2.5, -2.75, -3.0]


f_known = [f(x_known[i], y_known[i]) for i in 1:length(x_known)]

# Definiši opseg tačaka za interpolaciju
x_grid = -3:0.1:3
y_grid = -3:0.1:3

# Izračunaj interpolirane vrednosti za svaku tačku na mreži
X = [xi for xi in x_grid, yi in y_grid]
Y = [yi for xi in x_grid, yi in y_grid]
Z = [kriging_interpolation(x_known, y_known, f_known, xi, yi) for xi in x_grid, yi in y_grid]

# Izračunaj stvarne vrednosti funkcije za svaku tačku na mreži
F_actual = [f(xi, yi) for xi in x_grid, yi in y_grid]

# Izračunaj apsolutne greške
absolute_errors = [abs(Z[i] - F_actual[i]) for i in 1:length(Z)]

# Izračunaj relativne greške
relative_errors = [abs(absolute_errors[i]) / abs(F_actual[i]) for i in 1:length(F_actual) if F_actual[i] != 0]

# Izračunaj srednju relativnu grešku
mean_relative_error = mean(relative_errors)

# Prikaz srednje relativne greške
println("Srednja relativna greška: ", mean_relative_error)

# Plot the 3D surface for Kriging interpolation
surface(X, Y, Z, xlabel="x", ylabel="y", zlabel="Interpolated f(x, y)", title="3D Surface Plot of Kriging Interpolation")
