/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
   read raster from a single-band image file */

//calling convention
//[raster,geoTrans,proj,dataType,NoDataVal]=ReadMultiBandRaster(fileName,band);
//[raster,geoTrans,proj,dataType,NoDataVal]=ReadMultiBandRaster(fileName,band,startRow,startCol,rows,cols);
#include "mexOperation.h"
#include "gdal.h"
#include "mex.h"
using namespace std;
#ifdef __linux__
    #pragma comment (lib,"libgdal.so")
    //linux code goes here
#elif _WIN64
    // windows code goes here
    #pragma comment (lib,"gdal_i.lib")
#else
    #error Platform not supported
#endif


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    /* input variables*/
	mxArray* mxSrcFile;
	int strLen,status;
	char* pszSrcFile;
    int iBand;
	GDALDatasetH pDSrc;
    GDALRasterBandH pBand;
    
    int x0,y0,rows,cols,xSize,ySize;
    double* raster;
    /*output variables*/
    int CPLErr,bSuccess;
    mxArray *mxRaster;
    //geoTransform
    double geoTrans[6];mxArray *mxGeoTrans;
    
    //spatial Reference
    const char *spatialRef;mxArray *mxProjection;
    // data type
    GDALDataType DataType;mxArray *mxDataType;
    
    double NoData;mxArray* mxNoData;
    int out_type_size;
    void* dptr;
    mxArray* mxInput[2];
	if ( nrhs !=2 && nrhs!=6 )
		mexErrMsgTxt("incorrect input"); 
    pszSrcFile=ImportString((mxArray *)prhs[0]);
    iBand=*mxGetPr(prhs[1]);
    //Start GDAL Operations
	pDSrc = (GDALDatasetH)GDALOpen(pszSrcFile, GA_ReadOnly);
    mxFree(pszSrcFile);
    if (pDSrc==NULL)
    {
        mexErrMsgTxt ( "File is corrputed.\n" );
    }
    pBand=GDALGetRasterBand(pDSrc,iBand);
    DataType=GDALGetRasterDataType(pBand);
    xSize=GDALGetRasterXSize(pDSrc);
    ySize=GDALGetRasterYSize(pDSrc);
    if (nrhs==2)// read the entire image
    {
        x0=0;
        y0=0;
        cols=xSize;
        rows=ySize;
    }
    else // read a specified block
    {
        x0 = *(mxGetPr(prhs[3]))-1;
        y0 = *(mxGetPr(prhs[2]))-1;
        cols=*(mxGetPr(prhs[5]));
        rows=*(mxGetPr(prhs[4]));
        if ((x0+cols)>xSize || (y0+rows)>ySize)
        {
            printf("image size(%d,%d),requsted bounds(%d,%d)",ySize,xSize,y0+rows,x0+cols);
            mexErrMsgTxt ( "Extent exceeds the image size" );
        }
    }
    raster=new double[rows*cols];
    GDALRasterIO(pBand,GF_Read,x0,y0, cols, rows, raster, 
            cols, rows, GDT_Float64, 0,0);
    out_type_size = GDALGetDataTypeSize ( GDT_Float64 ) / 8;
    
    mxRaster=ExportRealMatrix((const double*)raster,rows,cols,out_type_size,1);
    delete raster;
    if (nlhs<1 )
        mexErrMsgTxt ( "output arguments not assigned" );
    else
    {
        NoData=GDALGetRasterNoDataValue(pBand,&bSuccess);
        mxNoData=mxCreateDoubleScalar(NoData);
        mxInput[0]=mxRaster;
        mxInput[1]=mxNoData;
        mexCallMATLAB(1,&mxRaster,2,mxInput,"SetNull");
        plhs[0] = mxRaster;
        if (nlhs>=2)
        {
            CPLErr=GDALGetGeoTransform(pDSrc,geoTrans);
            if (CPLErr!=CE_None)
                mexErrMsgTxt("error in reading head"); 
            mxGeoTrans=ExportRealMatrix((const double*)geoTrans,1,6,out_type_size,0);
            plhs[1]=mxGeoTrans;
        }
        if (nlhs>=3)
        {
            spatialRef=GDALGetProjectionRef (pDSrc);
            mxProjection=mxCreateString(spatialRef);
            plhs[2]=mxProjection;
        }
        if (nlhs>=4)
        {
            mxDataType=mxCreateDoubleScalar(DataType);
            plhs[3]=mxDataType;
        }
        if (nlhs>=5)
        {
            plhs[4]=mxNoData;
        }
    }
    GDALClose((GDALDatasetH) pDSrc); 
}