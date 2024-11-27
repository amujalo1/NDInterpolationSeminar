using Plots
using Statistics  # Import the Statistics package for mean calculation

plotly()  # Set the backend to PlotlyJS

# Define the function f(x, y)
function f(x, y)
    return sin((x - y) / 2) * cos(sqrt(x^2 + y^2) / 2)
end

# Function to compute Euclidean distance
function euclidean_distance(x1, y1, x2, y2)
    sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

# Shepard's interpolation function
function shepard_interpolation(x, y, x_known, y_known, f_known, p=2)
    N = length(f_known)
    numerator = 0.0
    denominator = 0.0
    for i in 1:N
        dist = euclidean_distance(x, y, x_known[i], y_known[i])
        if dist == 0.0
            return f_known[i]  # Return known value if point is the same
        end
        weight = 1.0 / dist^p
        numerator += weight * f_known[i]
        denominator += weight
    end
    return numerator / denominator
end

# Known points and their function values
x_known = [-3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
           0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0,
           -3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
            0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0]

y_known = [-3.0, -2.75, -2.5, -2.25, -2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0,
           0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0,
            3.0,  2.75,  2.5,  2.25,  2.0,  1.75,  1.5,  1.25,  1.0,  0.75,  0.5,  0.25, 0.0,
           -0.25, -0.5, -0.75, -1.0, -1.25, -1.5, -1.75, -2.0, -2.25, -2.5, -2.75, -3.0]

f_known = [f(x_known[i], y_known[i]) for i in 1:length(x_known)]

# Define the range of points for interpolation
x_grid = -3:0.1:3
y_grid = -3:0.1:3

# Initialize arrays to store results
error_results = Dict{Int, Matrix{Float64}}()

# Iterate over different values of p
for p in [1, 2, 3, 4,5,10]
    Z_interpolated = [shepard_interpolation(xi, yi, x_known, y_known, f_known, p) for xi in x_grid, yi in y_grid]
    Z_actual = [f(xi, yi) for xi in x_grid, yi in y_grid]
    relative_error = abs.(Z_interpolated .- Z_actual) ./ (abs.(Z_actual) .+ 1e-10)  # Add a small constant to avoid division by zero
    error_results[p] = relative_error
    surface(X, Y, Z_interpolated, xlabel="x", ylabel="y", zlabel="Interpolated f(x, y)",
            title="3D Surface Plot of Shepard Interpolation with p = $p")
end

for (p, error_matrix) in error_results
    println("Mean Relative Error for p = $p:")
    println(mean(error_matrix))  # Print the mean relative error

    # Plot relative error surface
    surface(X, Y, error_matrix, xlabel="x", ylabel="y", zlabel="Relative Error",
            title="Relative Error Surface Plot for p = $p")
end
