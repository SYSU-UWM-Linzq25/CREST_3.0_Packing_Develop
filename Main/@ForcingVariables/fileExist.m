function fe=fileExist(fileName)
prefix=strsplit(fileName,'"');
if length(prefix)>1
    fe=exist(prefix{2},'file')==2;
else
    fe=exist(fileName,'file')==2;
end
end