/* GDAL MEX Utility (v1.0) by Shen,Xinyi
   contact: Xinyi.Shen@uconn.edu,Feb, 2015
   reproject, resample and clip */
/************ calling convention *****************/
/* ResampleAndClip(geoTransTar,wktTar,tarXSize,tarYSize,strSrcFile,strDstFile,fmt)
ResampleAndClip(geoTransTar,wktTar,tarXSize,tarYSize,strSrcFile,strDstFile,fmt,bandSrc)
ResampleAndClip(geoTransTar,wktTar,tarXSize,tarYSize,strSrcFile,strDstFile,fmt,bandSrc,resampleAlg)
ResampleAndClip(geoTransTar,wktTar,tarXSize,tarYSize,strSrcFile,strDstFile,fmt,bandSrc,resampleAlg,ignoreSrcnodata,dstnodata)
resampleAlg:
    1: Nearest Neighbouring
    2: Bilinear   
    3: Average
    4: Max
    5: Min
    6: Median
    7: Mode*/
/****************************************************/
#include "mexOperation.h"
#include "gdal.h"
#include "ogr_core.h"
#include "gdalwarper.h"
#include "cpl_conv.h"
#include "cpl_string.h"
#include "mex.h"
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    /*************definition of input arguments****************/
    double* geoTransTar;
    const char *wktTar, *strSrcFile, *strDstFile, *fmt;
    char **papszOptions=NULL;
    int tarXSize,tarYSize,bandSrc;
    /***********************************************************/
    char *ext; 
    int optAlg; 
    GDALDatasetH dsSrcH, dsDstH;
    GDALDriverH dstDriverH;
    GDALRasterBandH bandSrcH,bandDstH;
    OGRSpatialReferenceH srSrcH;
    const char *wktSrc; 
    char *projWG84;
    GDALDataType dataType;
    double geoTransSrc[6],resScalingRatioX,resScalingRatioY;
    GDALResampleAlg resampleAlg;
    GDALWarpOptions *wos;
    int bSuccess;
    int NoData;
    int ignoreSrcnodata=0;
    /*************Converting Input Arguments*****************/
    if(nlhs>0)
        mexErrMsgTxt("no output");
    geoTransTar=mxGetPr(prhs[0]);
    wktTar=ImportString(prhs[1]);
    tarXSize=(int)(*mxGetPr(prhs[2]));
    tarYSize=(int)(*mxGetPr(prhs[3]));
    strSrcFile=ImportString(prhs[4]);
    strDstFile=ImportString(prhs[5]);
    fmt=ImportString(prhs[6]);
    if (nrhs>=8)
        bandSrc=(int)(*mxGetPr(prhs[7]));
    else
        bandSrc=1;
    if (nrhs>=9)
    {
        optAlg=(int)(*mxGetPr(prhs[8]));
        switch (optAlg)
        {
            case 1: //Nearest Neighbouring
                    resampleAlg=GRA_NearestNeighbour;
                    break;
            case 2: //Bilinear
                    resampleAlg=GRA_Bilinear;
                    break;
            case 3: //Average
                    resampleAlg=GRA_Average;
                    break;
            case 4: 
                     resampleAlg=GRA_Max;
                     break;
            case 5:
                    resampleAlg=GRA_Min;
                    break;
            case 6:
                    resampleAlg=GRA_Med;
                    break;
            case 7:
                    resampleAlg=GRA_Mode;
                    break;
            // case 8: resampleAlg=GRA_Sum;
        }
    }
    /*******************************************************/
    ext=fileExtension(strSrcFile);
    dsSrcH = GDALOpen(strSrcFile, GA_ReadOnly);
    mxFree((void *)strSrcFile);
    bandSrcH=GDALGetRasterBand(dsSrcH,1);
    // if (resampleAlg==GRA_NearestNeighbour || resampleAlg==GRA_Max \
    //    || resampleAlg==GRA_Min || resampleAlg==GRA_Med || resampleAlg==GRA_Mode)
        dataType=GDALGetRasterDataType(bandSrcH);
    // else
    //     dataType=GDT_Float32;
    wktSrc = GDALGetProjectionRef(dsSrcH);
    srSrcH=OSRNewSpatialReference (wktSrc);
    if(strlen(wktSrc)==0)
    {
        // the forcing data has no projection info
        // we brutally assign a WGS84 Geographic CS for it
        OSRSetWellKnownGeogCS(srSrcH,"WGS84");
        OSRExportToWkt(srSrcH,&projWG84);
        GDALSetProjection(dsSrcH,projWG84);
    }
    GDALGetGeoTransform(dsSrcH,geoTransSrc);
    if (nrhs<9)
    {
        if (IsGeographic(wktTar,geoTransTar))
        {
            if (!IsGeographic(wktSrc,geoTransSrc))
            {
                resScalingRatioX=(geoTransTar[1]+geoTransTar[2])*110574/(geoTransSrc[1]+geoTransSrc[2]);
                resScalingRatioY=fabs((geoTransTar[4]+geoTransTar[5])*110574/(geoTransSrc[4]+geoTransSrc[5]));
            }
            else // if the projection file is missing, CS is considered as GCS srSrc.IsGeographic
            {
                resScalingRatioX=(geoTransTar[1]+geoTransTar[2])/(geoTransSrc[1]+geoTransSrc[2]);
                resScalingRatioY=fabs((geoTransTar[4]+geoTransTar[5])/(geoTransSrc[4]+geoTransSrc[5]));
            }
        }
        else
        {
            if (!IsGeographic(wktSrc,geoTransSrc))
            {
                resScalingRatioX=(geoTransTar[1]+geoTransTar[2])/(geoTransSrc[1]+geoTransSrc[2]);
                resScalingRatioY=fabs((geoTransTar[4]+geoTransTar[5])/(geoTransSrc[4]+geoTransSrc[5]));
            }
            else// srSrc.IsGeographic
            {
                resScalingRatioX=(geoTransTar[1]+geoTransTar[2])/((geoTransSrc[1]+geoTransSrc[2])*110574);
                resScalingRatioY=fabs((geoTransTar[4]+geoTransTar[5])/((geoTransSrc[4]+geoTransSrc[5])*110574));
            }
        }
        //the scaling ratio is set 1 if not far from 1

        if  (resScalingRatioX<=1.2) // no average
            resampleAlg=GRA_Bilinear;
        else if (resScalingRatioX>1.2 && resScalingRatioX<2)//bilinear
            resampleAlg=GRA_NearestNeighbour;
        else if (resScalingRatioX>=2)//average
            resampleAlg=GRA_Average;
    }
    // create the output file and dataset
    dstDriverH = GDALGetDriverByName(fmt);
    mxFree((void *)fmt);
    dsDstH = GDALCreate(dstDriverH,strDstFile,tarXSize,tarYSize, 1, dataType, NULL);
    // set the geotransformation coefficients
    GDALSetGeoTransform (dsDstH, geoTransTar);
    // set the projection of the output file
    GDALSetProjection (dsDstH, wktTar);
    //GDALSetRasterNoDataValue(GDALGetRasterBand(dsDstH,1),noDataVal);
    mxFree((void *)wktTar);
    
    /********************* set the noData ********************************/
    if (nrhs>=10)
        ignoreSrcnodata=(int)(*mxGetPr(prhs[9]));
    if (ignoreSrcnodata && nrhs>=11) //Ignore source nodata
        NoData=(int)(*mxGetPr(prhs[10]));
    else
        NoData=GDALGetRasterNoDataValue(bandSrcH,&bSuccess);
    
    /************* set the warp options ********************/
    wos = GDALCreateWarpOptions();
    papszOptions = CSLSetNameValue( papszOptions, "OPTIMIZE_SIZE", "TRUE" );
    papszOptions = CSLSetNameValue( papszOptions, "TILED", "YES" );
    papszOptions = CSLSetNameValue( papszOptions, "COMPRESS", "LZW" );
    wos->papszWarpOptions = papszOptions;//CSLDuplicate(NULL);  
    wos->hSrcDS = dsSrcH;
    wos->hDstDS = dsDstH;
    wos->nBandCount = 1;
    wos->panSrcBands = (int *) CPLMalloc(1*sizeof(int));  
    wos->panDstBands = (int *) CPLMalloc(1*sizeof(int));  
    wos->panSrcBands[0] = bandSrc;
    wos->panDstBands[0] = 1; 
    wos->padfSrcNoDataReal=(double *) CPLMalloc(1*sizeof(double));
    wos->padfSrcNoDataImag=(double *) CPLMalloc(1*sizeof(double));
    if (ignoreSrcnodata)
    {
        wos->padfSrcNoDataReal[0]=-1;
        wos->padfSrcNoDataImag[0]=0;
    }
    else
    {
        wos->padfSrcNoDataReal[0]=NoData;
        wos->padfSrcNoDataImag[0]=0;
    }
    printf("DstNodata:%d\n",NoData);
    printf("ignoreSrcNodata:%d\n",ignoreSrcnodata);
    printf("resampleAlg:%d\n",resampleAlg);
    wos->padfDstNoDataReal=(double *) CPLMalloc(1*sizeof(double));  
    wos->padfDstNoDataReal[0]=NoData;
    wos->padfDstNoDataImag=(double *) CPLMalloc(1*sizeof(double));
    wos->padfDstNoDataImag[0]=0;
    
    wos->eWorkingDataType = dataType;  
    wos->eResampleAlg = resampleAlg;
    wos->pfnTransformer = GDALGenImgProjTransform;  
    wos->pTransformerArg = GDALCreateGenImgProjTransformer2(dsSrcH, dsDstH, NULL);
    /***************************************************************************/
    /************* set the warp operation and execute********************/
    GDALWarpOperation oOperation;
    oOperation.Initialize(wos);
    oOperation.ChunkAndWarpImage( 0, 0,tarXSize, tarYSize );
    GDALDestroyGenImgProjTransformer(wos->pTransformerArg);  
    if (bSuccess)
    {
        bandDstH=GDALGetRasterBand(dsDstH,1);
        GDALSetRasterNoDataValue(bandDstH,NoData);
    }
    /*************release resources*****************************************/
    GDALDestroyWarpOptions(wos); 
    GDALClose((GDALDatasetH) dsSrcH);  
    GDALClose((GDALDatasetH) dsDstH);
    /***************************************************************************/
    
}
