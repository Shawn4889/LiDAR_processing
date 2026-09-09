import arcpy
from arcpy.sa import *
arcpy.env.overwriteOutput = True

arcpy.env.workspace = r"C:\BGLproject\testing_python_process"
chm = "chm_test_gap_unfilled.tif"
# fill NAs
chm_out = Con(Raster(chm) == 0, FocalStatistics(Raster(chm), NbrRectangle(3, 3), "MEAN"), Raster(chm))
chm_out.save("chm_test_gap_unfilled_everything.tif")
# results above 3m
OutRaster = Con(chm_out < 3, Raster(chm), chm_out)  #above 3 meters keep the result and output it
OutRaster.save("chm_pitfill_above3mresult.tif")



