function fileRes=genResName(this,core,isEV)
if isEV
    fileRes=[this.comFolder,this.fileNameHead,num2str(core) '.evres'];
else
    fileRes=[this.comFolder,this.fileNameHead,num2str(core) '.res'];
end
end