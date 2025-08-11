function [fileName,subName]=GenerateExpVarNames(dir,date,subfmt,filefmt)
fileName=[dir,datestr(date,filefmt),'.mat'];
if nargout>1
    subName=['s' datestr(date,subfmt)];
end
end