function createRedistFrmMFile(mainMfile,outDir)
list=matlab.codetools.requiredFilesAndProducts(mainMfile);
curDir=pwd;
for i=1:length(list)
    mFile=list{i};
    pcode(mFile);
    [~,fileName]=fileparts(mFile);
    pFile=[curDir,'\',fileName,'.p'];
    movefile(pFile,outDir);
end
end