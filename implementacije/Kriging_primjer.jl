using Plots
plotly() 

using LinearAlgebra

# Definišemo funkciju
function f(x, y)
    return sin((x - y) / 2) * cos(sqrt(x^2 + y^2) / 2)
end

function covariance(x1, y1, x2, y2, range=1.0)
    d = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return exp(-d / range)  # Exponential covariance function (Gaussian)
end

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

function covariance_vector(x, y, x_new, y_new, range=1.0)
    n = length(x)
    C_new = zeros(n)
    for i in 1:n
        C_new[i] = covariance(x[i], y[i], x_new, y_new, range)
    end
    return C_new
end

function kriging_interpolation(x, y, z, x_new, y_new, range=1.0)
    n = length(x)
    
    C = covariance_matrix(x, y, range)
    
    C += 1e-10 * I
    
    C_new = covariance_vector(x, y, x_new, y_new, range)
    
    weights = C \ C_new
    
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

x_grid = -3:0.1:3
y_grid = -3:0.1:3

X = [xi for xi in x_grid, yi in y_grid]
Y = [yi for xi in x_grid, yi in y_grid]
Z = [kriging_interpolation(x_known, y_known, f_known, xi, yi) for xi in x_grid, yi in y_grid]

F_actual = [f(xi, yi) for xi in x_grid, yi in y_grid]

absolute_errors = [abs(Z[i] - F_actual[i]) for i in 1:length(Z)]

relative_errors = [abs(absolute_errors[i]) / abs(F_actual[i]) for i in 1:length(F_actual) if F_actual[i] != 0]

mean_relative_error = mean(relative_errors)

println("Srednja relativna greška: ", mean_relative_error)

surface(X, Y, Z, xlabel="x", ylabel="y", zlabel="Interpolated f(x, y)", title="3D Surface Plot of Kriging Interpolation")
