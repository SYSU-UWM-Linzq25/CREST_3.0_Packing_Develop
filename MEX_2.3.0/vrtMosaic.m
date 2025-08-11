function fileList=vrtMosaic(dirTiles,ext,dirOut,bRecursively)
if ~exist('ext','var')
    ext='.tif';
end
if ~bRecursively
    files=dir(fullfile(dirTiles,['*',ext]));
else
    files=dir(fullfile(dirTiles,['**/*',ext]));
end
if exist('dirOut','var')==1
    fileList=fullfile(dirOut,'fileList.txt');
else
    fileList=fullfile(dirTiles,'fileList.txt');
end

fid=fopen(fileList,'w');
for i=1:length(files)
    if strcmpi(files(i).name(end),'.')
        continue;
    end
    fprintf(fid,'%s\n', fullfile(files(i).folder,files(i).name));
end
fclose(fid);
end