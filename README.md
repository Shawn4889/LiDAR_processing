# LiDAR CHM Processing Workflow

This repository contains a simple workflow for processing airborne LiDAR data into Canopy Height Models (CHMs), filling canopy gaps, merging individual CHM tiles by study site, and clipping CHM or ALOS imagery to study boundaries.

## Workflow

```text
LiDAR LAS files
      ↓
Individual CHM
LiDAR_processing.R
      ↓
Pit Fill
PitFilProcess.py
      ↓
Merge CHMs by Site
Merge.py
      ↓
Clip CHM / ALOS Images
Clip.py
```

## 1. Individual CHM — `LiDAR_processing.R`

This script processes an individual LiDAR tile and generates a canopy height model.

Main steps:

* Read the LAS file
* Thin the LiDAR point cloud
* Normalize point heights using a TIN-based ground surface
* Generate a **1 m CHM**
* Export intermediate LAS files and the CHM
* After pit filling, reload the processed CHM for optional tree-top detection

Typical outputs:

```text
las_thin.las
las_norm.las
chm.tif
```

The pit-filled CHM is processed separately in Python before tree-top detection continues in R.

---

## 2. Pit Fill — `PitFilProcess.py`

This script fills zero-value gaps in an individual CHM using a **3 × 3 focal mean**.

Processing logic:

```text
CHM cell = 0
      ↓
Calculate 3 × 3 neighborhood mean
      ↓
If filled height >= 3 m
    keep filled value
Otherwise
    keep original CHM value
```

The final output is a pit-filled CHM that can be used for further analysis or site-level mosaicking.

> Note: the current script fills cells with a value of `0`; it does not directly target NoData cells.

---

## 3. Merge Individual CHMs — `Merge.py`

This script mosaics individual CHM tiles into a single CHM for each study site.

Example structure:

```text
CHM/
├── Site_A/
│   ├── tile_01.tif
│   ├── tile_02.tif
│   └── tile_03.tif
│
└── Site_B/
    ├── tile_01.tif
    └── tile_02.tif
```

Output:

```text
Site_A_merge.tif
Site_B_merge.tif
```

The current `Merge.py` should be treated as a template. Before running it, define the input directory and output projection and update paths for your own project.

---

## 4. Clip CHMs or ALOS Images — `Clip.py`

This script clips raster datasets using a study-area polygon.

It can be used for:

* Individual CHMs
* Merged site-level CHMs
* ALOS imagery
* Other TIFF raster products

Inputs:

```text
Clipping boundary shapefile
+
Input raster directory
```

Output:

```text
Clipped raster(s)
```

The script uses the polygon geometry as the clipping boundary and assigns `-999` as the output NoData value.

---

## Recommended Processing Order

For a typical site:

```text
1. Process each LiDAR tile
   ↓
2. Generate individual CHMs
   ↓
3. Apply pit filling
   ↓
4. Merge processed CHMs by site
   ↓
5. Clip the merged CHM to the study area
```

Clipping can also be performed on individual CHMs before merging when tile-level subsets are required.

## Suggested Project Structure

```text
Project/
├── LiDAR_raw/
├── CHM_individual/
├── CHM_pitfilled/
├── CHM_merged/
├── ALOS/
├── Boundary/
└── Clipped_outputs/
```

## Requirements

### R

* `lidR`
* `raster`

### Python

* ArcGIS Pro Python environment
* `arcpy`
* ArcGIS Spatial Analyst for the pit-fill workflow

## Notes

The scripts currently contain example or hard-coded file paths. Update all working directories, input paths, output paths, and projection settings before running them on a new dataset.

The recommended workflow is:

**LiDAR_processing.R → PitFilProcess.py → Merge.py → Clip.py**
