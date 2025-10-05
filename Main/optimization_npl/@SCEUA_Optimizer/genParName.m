function parFileName=genParName(obj,core,isEV)
if isEV
    parFileName=[obj.comFolder,obj.fileNameHead,num2str(core) '.evpar'];
else
    parFileName=[obj.comFolder,obj.fileNameHead,num2str(core) '.par'];
end
end