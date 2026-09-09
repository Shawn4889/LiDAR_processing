#This clip function can be used to clip your individual or single large CHM or ALOS images
def clip_ras():
    dir_shp = r"E:\ChangMap\Boundingbox\Clip_new.shp"
    dir_ras = r"E:\ChangMap\CHM\DB_20210905\DB_chm\Pitfill/"
    dir_out = r"E:\ChangMap\CHM\DB_20210905\DB_chm\Subset/"
    arcpy.env.workspace = dir_ras
    arcpy.MakeFeatureLayer_management(dir_shp, "fLayer")
    chms = arcpy.ListRasters('*.tif*')
    for chm in chms:
        print(str(chm))
        outraster = dir_out + chm
        desc = arcpy.Describe("fLayer")
        extent = str(desc.extent.XMin) + " " + \
                 str(desc.extent.YMin) + " " + \
                 str(desc.extent.XMax) + " " + \
                 str(desc.extent.YMax)
        arcpy.Clip_management(chm, extent, outraster, "fLayer", -999, "ClippingGeometry", "NO_MAINTAIN_EXTENT")
