#The original code is missing, please revise this to adapt to your own codebase. This is just a template to run ArcPy merge code to merge individual CHMs to single CHM per site.
def merge():
    case_list = os.listdir(chm_dir)
    for case in case_list:
        print("Merging case: " + case)
        rasters = []
        chm_dir2 = chm_dir + case
        chm_list = os.listdir(chm_dir2)
        arcpy.env.workspace = chm_dir2
        for file in chm_list:
            if "tif" in file:
                rasters.append(file)
        ras_list = ";".join(rasters)
        print(ras_list)
        arcpy.MosaicToNewRaster_management(ras_list, chm_dir2, case + "_merge.tif", Proj,
                                           "32_BIT_FLOAT", "1", "1", "LAST", "FIRST")

