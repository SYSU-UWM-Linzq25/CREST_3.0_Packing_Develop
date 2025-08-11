function WRF_preprocess(forcingpath,outdir)
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/MEX']);
%addpath('/shared/stormcenter/Qing_Y/src_new/MEX/');
GDALLoad();
dirIn = forcingpath;
dirOut = strcat(outdir,'/Forcing/');
mkdir(dirOut);
FileList = dir(fullfile(dirIn,'/*.tm00'));
if length(FileList )==0
    return
end
[~,foldername,~]=fileparts(dirIn);
timestart = erase(foldername,{'_','UTC'});
for i = 1:length(FileList)
    File_Now = strcat(FileList(i).folder,'/',FileList(i).name);
    timenow = datestr((datenum(timestart,'yyyymmddHH') + (i-1)/24),'yyyymmddHH');
    FileOut = strcat(dirOut,'WRF_',timenow,'.tm00');
    copyfile(File_Now,FileOut)
end
dirOut = strcat(outdir,'/Precip/');
mkdir(dirOut);
for i = 1
    File = strcat(FileList(i).folder,'/',FileList(i).name);
    [nBand,nRow,nCol,GeoTrans,ProjOut,DataType,NoDataVal] = RasterInfo(File);
    [Dat,~,~,~,~] = ReadMultiBandRaster(File,6);
    Dat(logical(Dat<0))=0;
    Dat(isnan(Dat))=0;
    FileOut = strcat(dirOut,'WRF_',timestart,'.tif');
    WriteRaster(FileOut,Dat,GeoTrans,ProjOut,DataType,'GTiff',NoDataVal(1));
end
if length(FileList )==1
    return
end
for i = 2:length(FileList )
    File_Pre = strcat(FileList(i-1).folder,'/',FileList(i-1).name);
    File_Now = strcat(FileList(i).folder,'/',FileList(i).name);
    [nBand,nRow,nCol,GeoTrans,ProjOut,DataType,NoDataVal] = RasterInfo(File_Now);
    [Dat_Pre,~,~,~,~] = ReadMultiBandRaster(File_Pre,6);
    [Dat_Now,~,~,~,~] = ReadMultiBandRaster(File_Now,6);
    Dat = Dat_Now-Dat_Pre;
    Dat(logical(Dat<0))=0;
    Dat(isnan(Dat))=0;
    timenow = datestr((datenum(timestart,'yyyymmddHH') + (i-1)/24),'yyyymmddHH');
    FileOut =strcat(dirOut,'WRF_',timenow,'.tif');
    WriteRaster(FileOut,Dat,GeoTrans,ProjOut,DataType,'GTiff',NoDataVal(1));
end