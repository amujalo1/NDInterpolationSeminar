using Plots
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
            return f_known[i]  # Vrati poznatu vrijednost
        end
        weight = 1.0 / dist^p
        numerator += weight * f_known[i]
        denominator += weight
    end
    return numerator / denominator
end

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

# Compute interpolated values for each point in the grid
X = [xi for xi in x_grid, yi in y_grid]
Y = [yi for xi in x_grid, yi in y_grid]
Z = [shepard_interpolation(xi, yi, x_known, y_known, f_known) for xi in x_grid, yi in y_grid]

# Plot the 3D surface
surface(X, Y, Z, xlabel="x", ylabel="y", zlabel="Interpolated f(x, y)", title="3D Surface Plot of Shepard Interpolation")