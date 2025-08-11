/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
   read a shape file */
/*calling convention
*[xLoc,yLoc,wkt,attrib]=readShapeAttrib(shapeName,attField)
*/
#include "mexOperation.h"
#include "gdal.h"
#include "ogr_api.h"
#ifdef __linux__
    #pragma comment (lib,"libgdal.so")
    #define strEqual 0
    #define strcmp strcmp
    //linux code goes here
#elif _WIN64
    // windows code goes here
    #pragma comment (lib,"gdal_i.lib")
    #define strEqual 1
    #define strcmp strcmp
#else
    #error Platform not supported
    #define strEqual 0
#endif
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    /****************input variables*******************/
    const char *shapeName,*outletID;
    int IDField;
    /**************************************************/
    /****************output variables******************/
    double *xLoc, *yLoc;
    char *wktStr;
    mxArray* mwIDs;
    GDALDriverH driverH;
    OGRDataSourceH dsH;
    OGRLayerH layerH;
    OGRFeatureH featureH;
    OGRGeometryH geoH;
    OGRSpatialReferenceH srH;
    int nFeature;
    const char* siteID;
    int ik, out_type_size;
    int nOut;
    /***************convert input variables************/
    shapeName=ImportString(prhs[0]);
    IDField=(int)(*mxGetPr(prhs[1]));
    if (nrhs==3)
        outletID=ImportString(prhs[2]);
    /**************************************************/
    driverH=OGRGetDriverByName("ESRI Shapefile");
    dsH=OGR_Dr_Open(driverH,shapeName,true);
    layerH=OGR_DS_GetLayer(dsH,0);
    nFeature=OGR_L_GetFeatureCount(layerH,false);
    srH=OGR_L_GetSpatialRef(layerH);
    OSRExportToWkt(srH,&wktStr);
    OGRFeatureDefnH hFDefn = OGR_L_GetLayerDefn(layerH);
    OGRFieldDefnH hFieldDefn = OGR_FD_GetFieldDefn(hFDefn, IDField);
    OGRFieldType fieldType = OGR_Fld_GetType(hFieldDefn);

    if (nrhs==2)// read all sites
    {
        xLoc=new double[nFeature];
        yLoc=new double[nFeature];
        mwIDs=mxCreateCellMatrix ((mwSize)nFeature,1);
        nOut=nFeature;
    }
    else
         mexErrMsgTxt("incorrect input");
    
    for (int i=1;i<=nFeature;i++)
    {
        featureH=OGR_L_GetFeature(layerH,i-1);
        mxArray *cellValue = NULL;
        ik=i;
        if (fieldType == OFTString) 
        {
            const char *value = OGR_F_GetFieldAsString(featureH, IDField);
            if (value != NULL) 
            {
                cellValue = mxCreateString(value);
            } 
        }
        else if (fieldType == OFTInteger) 
        {
            int intValue = OGR_F_GetFieldAsInteger(featureH, IDField);
            cellValue = mxCreateDoubleScalar((double)intValue);
        } 
        else if (fieldType == OFTReal) 
        {
            double realValue = OGR_F_GetFieldAsDouble(featureH, IDField);
            cellValue = mxCreateDoubleScalar(realValue);
        }
        mxSetCell(mwIDs, ik-1, cellValue);
        
        geoH=OGR_F_GetGeometryRef(featureH);
        xLoc[ik-1]=OGR_G_GetX(geoH,0);
        yLoc[ik-1]=OGR_G_GetY(geoH,0);
        OGR_F_Destroy(featureH);
    }
    /***************convert output variables************/
    out_type_size = GDALGetDataTypeSize ( GDT_Float64 ) / 8;
    plhs[0]=ExportRealMatrix(xLoc,nOut,1,out_type_size,false);
    plhs[1]=ExportRealMatrix(yLoc,nOut,1,out_type_size,false);
    plhs[2]=mxCreateString(wktStr);
    if (nlhs==4)
        plhs[3]=mwIDs;
    delete xLoc;
    delete yLoc;
//     delete shapeName;
    /***************************************************/
}