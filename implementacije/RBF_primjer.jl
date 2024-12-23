using Plots
plotly()  

function f(x, y)
    return sin((x - y) / 2) * cos(sqrt(x^2 + y^2) / 2)
end

# Radijalne Bazne Funkcije (RBF)
# 1. Gaussian RBF
function gaussian_rbf(x1, y1, x2, y2, epsilon=1.0)
    r = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return exp(-(epsilon * r)^2)
end

# 2. Multiquadric RBF
function multiquadric_rbf(x1, y1, x2, y2, epsilon=1.0)
    r = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return sqrt(1 + (epsilon * r)^2)
end

# 3. Inverse Quadratic RBF
function inverse_quadratic_rbf(x1, y1, x2, y2, epsilon=1.0)
    r = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return 1.0 / (1.0 + (epsilon * r)^2)
end

# 4. Thin Plate Spline RBF (bez epsilon parametra)
function thin_plate_spline_rbf(x1, y1, x2, y2)
    r = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    return r == 0 ? 0 : r^2 * log(r)
end

function rbf_interpolation(x_known, y_known, f_known, x_new, y_new, rbf_function, epsilon=1.0)
    N = length(f_known)
    
    A = zeros(N, N)
    for i in 1:N
        for j in 1:N
            A[i, j] = rbf_function(x_known[i], y_known[i], x_known[j], y_known[j], epsilon)
        end
    end
    
    coeffs = A \ f_known
    interpolated_value = 0.0
    for i in 1:N
        interpolated_value += coeffs[i] * rbf_function(x_known[i], y_known[i], x_new, y_new, epsilon)
    end
    
    return interpolated_value
end

x_known = [-3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0,
            -3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

y_known = [-3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0,
             3.0,  2.5,  2.0,  1.5,  1.0,  0.5, 0.0, -0.5, -1.0, -1.5, -2.0, -2.5, -3.0]

f_known = [f(x_known[i], y_known[i]) for i in 1:length(x_known)]

x_grid = -3:0.1:3
y_grid = -3:0.1:3

function plot_rbf_surface(rbf_function, epsilon=1.0, rbf_name="RBF")
    # Izračunaj interpolirane vrednosti za svaku tačku na mreži koristeći RBF
    X = [xi for xi in x_grid, yi in y_grid]
    Y = [yi for xi in x_grid, yi in y_grid]
    Z = [rbf_interpolation(x_known, y_known, f_known, xi, yi, rbf_function, epsilon) for xi in x_grid, yi in y_grid]
    
    # Prikaži 3D površinu
    surface(X, Y, Z, xlabel="x", ylabel="y", zlabel="Interpolated f(x, y)", title="3D Surface Plot of $rbf_name Interpolation")
end

function plot_original_function()
    X = [xi for xi in x_grid, yi in y_grid]
    Y = [yi for xi in x_grid, yi in y_grid]
    Z = [f(xi, yi) for xi in x_grid, yi in y_grid]
    
    # Prikaži 3D površinu originalne funkcije
    surface(X, Y, Z, xlabel="x", ylabel="y", zlabel="f(x, y)", title="3D Surface Plot of Original Function")
end

plot_rbf_surface(gaussian_rbf, 1.0, "Gaussian RBF")
plot_rbf_surface(multiquadric_rbf, 1.0, "Multiquadric RBF")
plot_rbf_surface(inverse_quadratic_rbf, 1.0, "Inverse Quadratic RBF")
plot_rbf_surface(thin_plate_spline_rbf, rbf_name="Thin Plate Spline RBF")

plot_original_function()
