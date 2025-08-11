/* GDAL MEX Utility (v1.0) by Shen,Xinyi
contact: Xinyi.Shen@uconn.edu,Feb, 2015
/********calling convention************
*WriteRasterInfo(fileRas,geoTrans,spatialRef,dataType,outFormat,NoDataValue)
***************************************/
#include "mexOperation.h"
// #ifndef  WIN32
// #include <unistd.h>
// #endif
#include "gdal.h"
//#include "cpl_conv.h"
#include "gdal_priv.h"
#include "mex.h"
#pragma comment (lib,"gdal_i.lib")
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
/* input variables */
const char*fileRas, *fmt;
double* raster;
double* geoTrans;
const char* spatialRef;
GDALDataType dataType;
double NoDataValue;
// inter variables
int nr,nc;
GDALDatasetH dstDsH;
GDALRasterBandH bandH;

mxArray *mxNoData;
if (nlhs>0)
    mexErrMsgTxt("excessive output");
if (nrhs!=6)
    mexErrMsgTxt("incorrect number of input");
//fileName
fileRas=ImportString(prhs[0]);
//format
fmt=ImportString(prhs[4]);
/****************deal with the no data value********************/
//Get the no data value
NoDataValue=(*mxGetPr(prhs[5]));
//dataType
dataType=(GDALDataType)(int)(*mxGetPr(prhs[3]));
dstDsH=GDALOpen(fileRas,GA_Update);
bandH=GDALGetRasterBand(dstDsH,1);
GDALSetRasterNoDataValue(bandH,NoDataValue);
/****************end of fushing data**************************/
/*****************Set GeoTransform coefficients*************/
if (!mxIsEmpty(prhs[1]))
{
    geoTrans=mxGetPr(prhs[1]);
    GDALSetGeoTransform (dstDsH, geoTrans);
}
if (!mxIsEmpty(prhs[2]))
{
    spatialRef=ImportString(prhs[2]);
    GDALSetProjection (dstDsH, spatialRef);
}
GDALFlushCache (dstDsH);
GDALClose((GDALDatasetH) dstDsH); 
}