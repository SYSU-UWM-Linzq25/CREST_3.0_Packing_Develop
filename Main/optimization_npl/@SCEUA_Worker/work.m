function bEnd=work(this,simulator,funcHandle)
% after check that there is parameter file
while true
    if exist(this.filePar,'file')==2
        %read in parameter
        [xTemp,keywords]=this.readpar();
        %delete parameter
        delete(this.filePar);
        [NSCE,tElapse]=funcHandle(simulator,xTemp,keywords);
        %write NSCE result
        tempnum=1-NSCE;
        outputres(this,tempnum);
        this.LogToFile(NSCE,tElapse,xTemp)
        bEnd=false;
        break;
    elseif exist(this.getProgressFileName(),'file')==2
        bEnd=true;
        break;
    end
end
end