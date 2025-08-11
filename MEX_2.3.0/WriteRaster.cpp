/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
   write raster to a single-band image file */ 

/********calling convention************
 *WriteRaster(fileRas,raster,geoTrans,spatialRef,dataType,outFormat,NoDataValue)
 *WriteRaster(fileRas,raster,geoTrans,spatialRef,dataType,outFormat,NoDataValue,startRow,startCol,rows,cols)
 *geoTrans and spatialRef can be [] if unknown
***************************************/
#include "mexOperation.h"
#ifdef __linux__
    #define strEqual 0
    #define strcmp strcmp
#elif _WIN64
    #define strEqual 1
    #define strcmp strcmp
#else
    #error Platform not supported
    #define strEqual 0
#endif
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
    double *raster,*rasterC;
    double *geoTrans;
    const char* spatialRef;
    char **papszOptions = NULL;
    GDALDataType dataType;
    double NoDataValue;
    int startRow,startCol,rows,cols;
    // inter variables
    int nr,nc;
    GDALDriverH driverH;
    GDALDatasetH dstDsH;
    GDALRasterBandH bandH;
    
    mxArray *mxRaster, *mxNoData, *mxInput[2];
    if (nlhs>0)
        mexErrMsgTxt("excessive output");
    if (nrhs!=11 && nrhs!=7)
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
 //   raster=mxGetPr(mxRaster);
 //   rasterC=new double[nr*nc];
/*    for (int r=0;r<nr;r++)
        for (int c=0;c<nc;c++)
            rasterC[r*nr+c]=2;*/
  //  memcpy(rasterC, raster, nr*nc*sizeof(double));
    
    //dataType
    dataType=(GDALDataType)(int)(*mxGetPr(prhs[4]));
    /*************Flush data to disk*********************/
    //papszOptions = CSLSetNameValue( papszOptions, "TILED", "YES" );
    if (strcmp(fmt, "GTiff")==strEqual)
        papszOptions = CSLSetNameValue( papszOptions, "COMPRESS", "deflate" );
    else
        papszOptions=NULL;
    if (nrhs==7)
    {
        driverH = GDALGetDriverByName(fmt);
        startRow=0;
        startCol=0;
        
        dstDsH = GDALCreate(driverH, fileRas,nc,nr, 1, dataType, papszOptions);
    }
    else
    {
        startRow=(int)(*mxGetPr(prhs[7]));
        startCol=(int)(*mxGetPr(prhs[8]));
        FILE *fp = fopen (fileRas, "r");
        if (fp!=NULL) 
        {
            fclose (fp);
            dstDsH=GDALOpen(fileRas,GA_Update);
   //         mexPrintf("flushing data to an existing file\n");
        }
        else
        {
            driverH = GDALGetDriverByName(fmt);
            rows=(int)(*mxGetPr(prhs[9]));
            cols=(int)(*mxGetPr(prhs[10]));
            dstDsH = GDALCreate(driverH,fileRas,cols,rows, 1, dataType, papszOptions);
   //         mexPrintf("created a new file\n");
        }
        startRow=startRow-1;
        startCol=startCol-1;
    }
    bandH=GDALGetRasterBand(dstDsH,1);
    GDALRasterIO(bandH,GF_Write,startCol,startRow, nc, nr, raster, 
            nc, nr, GDT_Float64, 0,0);
    GDALSetRasterNoDataValue(bandH,NoDataValue);
//    free(rasterC);
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