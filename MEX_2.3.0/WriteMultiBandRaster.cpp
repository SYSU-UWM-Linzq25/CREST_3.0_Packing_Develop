/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
   write raster to a Multi-band image file */ 

/********calling convention************
 *WriteMultiBandRaster(fileRas,raster,geoTrans,spatialRef,dataType,outFormat,NoDataValue,nBands,band,createNew)
 *WriteMultiBandRaster(fileRas,raster,geoTrans,spatialRef,dataType,outFormat,NoDataValue,startRow,startCol,rows,cols,nBands,band,createNew)
 *geoTrans and spatialRef can be [] if unknown
***************************************/
#include "mexOperation.h"
// #ifndef  WIN32
// #include <unistd.h>
// #endif
#include "gdal.h"
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
    char **papszOptions = NULL;
    GDALDataType dataType;
    double NoDataValue;
    int startRow,startCol,rows,cols,nBands,band;
    // inter variables
    int nr,nc;
    bool createNew;
    GDALDriverH driverH;
    GDALDatasetH dstDsH;
    GDALRasterBandH bandH;
    mxArray *mxRaster, *mxNoData, *mxInput[2];
    if (nlhs>0)
        mexErrMsgTxt("excessive output");
    if (nrhs!=14&& nrhs!=10)
        mexErrMsgTxt("incorrect number of input");
    //fileName
    fileRas=ImportString(prhs[0]);
    //format
    fmt=ImportString(prhs[5]);
    //size
    nr=mxGetM(prhs[1]);
    nc=mxGetN(prhs[1]);
    mxRaster=(mxArray *)prhs[1];
    /****************deal with the no data value********************/
    //Get the no data value
    NoDataValue=(*mxGetPr(prhs[6]));
    //replace the NaN values in the matrix by the NoData value
    mxInput[0]=mxRaster;
    mxInput[1]=(mxArray *)prhs[6];
    mexCallMATLAB(1,&mxRaster,2,mxInput,"ReplaceNull");
    raster=mxGetPr(Transpose(mxRaster));
//     raster=mxGetPr(prhs[1]));
    //dataType
    dataType=(GDALDataType)(int)(*mxGetPr(prhs[4]));
    /*************Flush data to disk*********************/
  //  papszOptions = CSLSetNameValue( papszOptions, "TILED", "YES" );
    papszOptions = CSLSetNameValue( papszOptions, "COMPRESS", "LZW" );
    if (nrhs==10)
    {
        driverH = GDALGetDriverByName(fmt);
        startRow=0;
        startCol=0;
        nBands=(int)(*mxGetPr(prhs[7]));
        band=(int)(*mxGetPr(prhs[8]));
        createNew=(bool)(*mxGetPr(prhs[9]));
        if (createNew)
            dstDsH = GDALCreate(driverH, fileRas,nc,nr, nBands, dataType, papszOptions);
        else
            dstDsH=GDALOpen(fileRas,GA_Update);
    }
    else
    {
        nBands=(int)(*mxGetPr(prhs[11]));
        band=(int)(*mxGetPr(prhs[12]));
        createNew=(bool)(*mxGetPr(prhs[13]));
        if (!createNew)
            dstDsH=GDALOpen(fileRas,GA_Update);
        else
        {
            driverH = GDALGetDriverByName(fmt);
            startRow=(int)(*mxGetPr(prhs[7]));
            startCol=(int)(*mxGetPr(prhs[8]));
            rows=(int)(*mxGetPr(prhs[9]));
            cols=(int)(*mxGetPr(prhs[10]));
            dstDsH = GDALCreate(driverH,fileRas,cols,rows, nBands, dataType, papszOptions);
        }
        startRow=startRow-1;
        startCol=startCol-1;
    }
    bandH=GDALGetRasterBand(dstDsH,band);
    GDALRasterIO(bandH,GF_Write,startCol,startRow, nc, nr, raster, 
            nc, nr, GDT_Float64, 0,0);
    GDALSetRasterNoDataValue(bandH,NoDataValue);
    /****************end of fushing data**************************/
    /*****************Set GeoTransform coefficients*************/
    if (!mxIsEmpty(prhs[2]))
    {
        geoTrans=mxGetPr(prhs[2]);
        GDALSetGeoTransform (dstDsH, geoTrans);
    }
    if (!mxIsEmpty(prhs[3]))
    {
        spatialRef=ImportString(prhs[3]);
        GDALSetProjection (dstDsH, spatialRef);
    }
    GDALFlushCache (dstDsH);
    GDALClose((GDALDatasetH) dstDsH); 
}