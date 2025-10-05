function dateVarSto=ReadAForcVar(this,mode,taskType,...
    dirIntVar,dateVarSto,intervalVar,varName,fmtVar,dateConvVar,dirExtVar,extVar,bandVar,...
                varTsRatio,varTsTrans,varULim,varLLim,...
                core,nCores,dateReset)
%% updating history
% updated to have the forecast mode (2) on Jul. 5, 2019
% updated to copy files to a local folder to avoid frequently reading from
% the scratch folder (for internal monthly files only)
% updated on Feb. 23, 2016: reorganize forcing variable to monthly files
% created in Mar. 2015 
% updated in Oct. 2016 (copy the external forcing file into the local
% folder and added the file lock mechanism to limit the number of
% simultaneous copy
global SECONDS_PER_DAY
[rows,cols]=size(this.basinMask);
[nameInt,subName]=ForcingVariables.GenerateIntForcingFileName(dirIntVar,this.timeFormat,this.fmtSubDir,this.dateCur);
[~,prefix]=fileparts(dirIntVar);
if ~exist('dateReset','var')==1
    dateReset=[];
end
dateToRead=ForcingVariables.fileDateToUpdate(this.dateCur,dateVarSto,dateReset,intervalVar);
if strcmpi(taskType,'ImportForc')% && this.forceIm
    existed=false;
else
    existed=true;
end
dirIntCache=[this.dirLocal,num2str(core),'_',num2str(nCores),this.pathSplitor,'in'];
dirIntCacheOut=[this.dirLocal,num2str(core),'_',num2str(nCores),this.pathSplitor,'out'];
if existed
    % Cache the file to the compute node
    [~,name,ext]=fileparts(nameInt);
    if ~isempty(this.dirLocal)
        if exist(dirIntCache,'dir')~=7
            mkdir(dirIntCache);
        end
        nameIntCache=[dirIntCache,this.pathSplitor,name,ext];
        if ~exist(nameIntCache,'file')
            % remove the forcing file of the last bunch from the local
            % directory
            delete([dirIntCache,this.pathSplitor,prefix,'*.mat'])
            % copy the new bunch to the local directory
            %this.ioLocker.request();
            %this.ioLocker.checkPermission();
            %disp(['copying ' nameInt ' to ' nameIntCache]);
            %copyfile(nameInt,nameIntCache);
            %this.ioLocker.release();
        end
        %nameInt=nameIntCache;
    end
    %load(nameInt,subName);
    %cmd=['this.' varName '=' subName ';'];
    %eval(cmd);
    startTime = tic;
    % Assuming nameInt contains the full path to the MAT file
    matObj = matfile(nameInt);
    % Load the variable from MAT file
    variableData = matObj.(subName);
    % Assign the loaded variable to the specified field in the 'this' structure
    this.(varName) = variableData;
    elapsedTime = toc(startTime);
    fprintf('Time taken to load and assign variable "%s": %.6f seconds\n', subName, elapsedTime);
else
    if strcmpi(dirIntVar(end),'this.pathSplitor')~=1
        dirInt=fileparts(dirIntVar);
    else
        dirInt=dirIntVar;
    end
    if exist(dirInt,'dir')~=7
        mkdir(dirInt);
    end
    if abs(dateToRead-this.dateCur)>intervalVar
        warning([varName 'setting error, please check the control file']);
    end
    if dateToRead~=dateVarSto
%% (2)
%         varNameExt=ForcingVariables.GenerateExtForcingFileName(dateToRead,intervalVar,fmtVar,dateConvVar,dirExtVar,extVar,this.pathSplitor);
        if ~isnan(this.dateStartFore)
            varNameExt=ForcingVariables.GenerateExtForcingFileName(dateToRead,intervalVar,fmtVar,dateConvVar,dirExtVar,extVar,this.pathSplitor,...
               this.dateStartFore);
        else
            varNameExt=ForcingVariables.GenerateExtForcingFileName(dateToRead,intervalVar,fmtVar,dateConvVar,dirExtVar,extVar,this.pathSplitor);
        end
%% (2)
        [~,fileExtLocal,ext]=fileparts(varNameExt);
        fileExtLocalFull=[dirIntCache,this.pathSplitor,fileExtLocal,ext];
        %% construct a general name of this forcing file
        nameExt=fileExtLocal;
        idx=ismember(nameExt,num2str(int32(0:9)));
        nameExt(idx)='*';
       %% copy the forcing file from to the local
        if ForcingVariables.fileExist(varNameExt)
            if exist(fileExtLocalFull,'file')~=2
                % remove old forcing files from the local folder
                delete([dirIntCache,this.pathSplitor,nameExt,ext]);
                disp('copying a forcing file from external to local folder...')
                copyfile(varNameExt,fileExtLocalFull);
            end
            % if ForcingVariables.fileExist(varNameExt)
            [forcRas,~,~]=ForcingVariables.ReadProjectedRaster(fileExtLocalFull,bandVar,rows,cols,this.geoTrans,this.spatialRef,...
                this.decompBeforeSrc,this.decompBeforeDst,dirIntCache,this.pathSplitor,core,this.Interpolation); %Modified by Rehenuma
            %% updated to remove NaN values and values out of the range of the basin
            % validGrids=(~isnan(forcRas))&(forcRas<=(varULim-varTsTrans)*varTsRatio)&(forcRas>=(varLLim-varTsTrans)*varTsRatio)&this.maskEnt;
            validGrids=(~isnan(forcRas))&(forcRas<=varULim)&(forcRas>=varLLim)&this.maskEnt; % Modified by Linzq25, August 11th,2025
            if sum(sum(validGrids))~=sum(sum(this.maskEnt))
    %             if abs(this.dateStart-this.dateCur)<1e-2*this.timeStep && sum(sum(validGrids))~=sum(sum(this.maskEnt))
                disp(['NaN values appears in ' varName ' file. Interpolating...']);
                forcRas=FillMissing(forcRas,this.maskEnt,varLLim*varTsRatio,varULim*varTsRatio);
                % validGrids=(~isnan(forcRas))&(forcRas<=(varULim-varTsTrans)*varTsRatio)&(forcRas>=(varLLim-varTsTrans)*varTsRatio)&this.maskEnt;
                validGrids=(~isnan(forcRas))&(forcRas<=varULim*varTsRatio)&(forcRas>=varLLim*varTsRatio)&this.maskEnt; % Modified by Linzq25, August 11th,2025
            end
            if sum(sum(validGrids))~=sum(sum(this.maskEnt))
    %             if abs(this.dateStart-this.dateCur)<1e-2*this.timeStep && sum(sum(validGrids))~=sum(sum(this.maskEnt))
    %                 disp(['NaN values appears in the forcing file of' varName, ' on the starting time step']);
    %                 disp ('move one time step back');
    %                 dateVarSto=-1;
                error('unable to fill all missing values')
    %                 return;
            end
            cmd=['this.' varName '(validGrids)=forcRas(validGrids)/varTsRatio+varTsTrans;'];
            eval(cmd);
        else
            switch mode
                case 'simu'
                    warning(strcat('missing   ', varName, ' data on ', datestr(this.dateCur)));
            end
        end
    end
    cmd=[subName '=this.' varName ';'];
    eval(cmd);
    [~,nameIntLocal,ext]=fileparts(nameInt);
    fileIntLocal=[dirIntCacheOut,this.pathSplitor,nameIntLocal,ext];
    if exist(fileIntLocal,'file')~=2    
        save(fileIntLocal, subName, '-v7.3');
    else
        save(fileIntLocal, subName, '-append');
    end
    %% decide whether to save
    dateNext=ForcingVariables.addDatenum(this.dateCur,this.timeStep);
    fileChanged=this.hasFileChanged();
    % if the file to save has been chaged or it is the last date, move the file from cache 
    if fileChanged || ...
        round(dateNext*SECONDS_PER_DAY)>round(this.dateEnd(this.iPeriod)*SECONDS_PER_DAY)
        disp(['moving the monthly/daily ' varName ' to the external folder...' ]);
        movefile(fileIntLocal,nameInt,'f');
    end
end
dateVarSto=dateToRead;
end

