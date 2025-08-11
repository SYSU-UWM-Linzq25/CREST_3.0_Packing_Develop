/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
  set the band name of a multi-band image file */ 

/********calling convention************
 *SetBandName(fileRas,band,bandName)
 *fileRas: a string containing the file Name
 *band: 1-based band index
 *bandName: a string containing the band name
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
    const char*fileRas, *bandName;
    int band;
    // inter variables
    int nr,nc;
    GDALDatasetH dstDsH;
    GDALRasterBandH bandH;
    if (nlhs>0)
        mexErrMsgTxt("excessive output");
    if (nrhs==10)
        mexErrMsgTxt("incorrect input");
    //fileName
    fileRas=ImportString(prhs[0]);
    band=(int)(*mxGetPr(prhs[1]));
    bandName=ImportString(prhs[2]);
    dstDsH=GDALOpen(fileRas,GA_Update);
    bandH=GDALGetRasterBand(dstDsH,band);
    GDALSetDescription(bandH,bandName);
    GDALFlushCache (dstDsH);
    GDALClose((GDALDatasetH) dstDsH); 
}