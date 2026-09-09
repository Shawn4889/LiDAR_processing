# Original from #Xiaoxuan Li, updating with Ghermay Araya
# Load necessary libraries
# lidR for LiDAR data manipulation and raster for working with raster data
library(lidR)
library(raster)

# Set your working directory or adjust file paths as needed
# setwd("C:/BGLproject")

# Define the path to the LAS file
file_dir <- "C:/BGLproject/tile_29920_-2719680.las"

# Read the ALS (Airborne Laser Scanning) file with specific attributes
# select = "i,c,r" selects intensity (i), class (c), and return number (r) for reading
las <- readLAS(file_dir, select = "i,c,r")

# Check if the LAS file is empty or path is incorrect to prevent errors
if (is.empty(las)) {
  stop("LAS file is empty or path is incorrect.")
}

# Thin the ALS data to homogenize point density across the area
# homogenize(1, 1) aims to achieve a target point density of 1 point per m²
# This helps in reducing data size and processing time for large datasets
las_sub <- decimate_points(las, homogenize(1, 1))
writeLAS(las_sub, "C:/BGLproject/las_thin.las")

# Normalize the height of the LAS points by subtracting the digital terrain model (DTM)
# tin() uses a Triangular Irregular Network for ground surface estimation
# na.rm = TRUE removes points with no data in the normalization process
las_norm <- normalize_height(las_sub, tin(), na.rm = TRUE)
writeLAS(las_norm, "C:/BGLproject/las_norm.las")

# Generate a Canopy Height Model (CHM) from the normalized LAS data
# grid_canopy() creates a raster where each cell value represents the height of the highest point within the cell
# p2r() is a pit-free algorithm with parameters to adjust the canopy model generation
chm <- grid_canopy(las_norm, 1, p2r())
# Save the CHM to a file with georeferencing information (TFW=YES) and allow overwrite if exists
writeRaster(chm, "C:/BGLproject/chm.tif", options = c('TFW=YES'), overwrite = TRUE)

# Plot the generated CHM for a preliminary visual inspection
plot(chm)

# IMPORTANT: The script pauses here for pit filling to be conducted in Python
# NOTE: The pitfilling is not using arcpy and will result in a grid that is differenet from the original code with arcpy from Shawn

# After pit filling in Python, re-import the pit-filled CHM for further processing
pit_filled_chm_path <- "C:/BGLproject/chm_filled.tif"
chm_pitfilled <- raster(pit_filled_chm_path)

# Plot the pit-filled CHM to verify improvements or changes
plot(chm_pitfilled)

# Find local maxima in the CHM to detect tree tops
# lmf() looks for local maxima within a defined window, useful for identifying individual trees
# The parameters are:
# - ws: window size, determines the area around each point to search for maxima, affecting the sensitivity to tree density
# - threshold: minimum height (in meters) to be considered a tree
# - shape: defines the shape of the search window, "circular" for round trees
tt <- find_trees(chm_pitfilled, lmf(5, shape = "circular", ws = 5))

# Plot the detected tree tops on the CHM for visual verification
# Trees are marked in red for clear identification
plot(chm_pitfilled)
plot(tt, add = TRUE, col = "red")
