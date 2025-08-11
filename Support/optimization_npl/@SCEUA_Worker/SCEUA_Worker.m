classdef SCEUA_Worker<handle
%% this class controls each CREST worker in a calibration process
    properties (Access=private)
        fileGranted;
        comFolder;
        statusFolder;
        nodeName;
        filePar;
        fileevPar
        fileRes;%_res.mat
        fileevRes;
        fileExit;
        fileevExit;
        fmt='%6d: %8.4f  %6d ';
        logFile;
        fileNameHead='worker_';
        statusName='completed';
    end
    properties (GetAccess=public)
        coreID;
    end
    methods (Access=public)
        function this=SCEUA_Worker(coreID,resPath,outSTCD,comFolder,statusFolder)
            this.coreID=coreID;
            this.comFolder=comFolder;
            this.statusFolder=statusFolder;
            this.fileRes=[this.comFolder,this.fileNameHead,num2str(coreID),'.res'];
            this.filePar=[this.comFolder,this.fileNameHead,num2str(coreID),'.par'];
            this.fileevRes=[this.comFolder,this.fileNameHead,num2str(coreID),'.evres'];
            this.fileevPar=[this.comFolder,this.fileNameHead,num2str(coreID),'.evpar'];
            this.fileExit=[this.statusFolder,this.fileNameHead,num2str(coreID),'.exit'];
            this.fileevExit=[this.statusFolder,'terminate',num2str(coreID),'.sta'];
            this.logFile=SCEUA_Optimizer.GenLogFileName(resPath,outSTCD);
        end
        
        bEnd=work(this,simulator,funcHandle);
        bEvolveEnd=workEvolve(this,simulator,funcHandle);
    end
    %% local folder processing
    methods (Access=public)
        exitAtOnce(this);
        [cf,cx]=EvolveComplex(this,nspl,npg,nps,bl,bu,cf,cx,simulator,funcHandle,keywords);
        [snew,fnew,nCalls]=cceua(this,s,sf,bl,bu,simulator,funcHandle,keywords);
    end
    methods (Access=private)
        fileName=getProgressFileName(this);
        LogToFile(this,fTemp,tElapse,xTemp);
        outputres(this,res); 
        outputEvolveres(this,cf,cx,nspl);
        [xTemp,keywords]=readpar(this);
        [nspl,npg,nps,bl,bu,cf,cx,keywords]=readevpar(this);
    end
end