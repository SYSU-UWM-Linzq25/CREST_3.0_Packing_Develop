function ImportObservation(this,eventMode,dirObs,FEDB,obsFormat,STCDOutlets)
disp('reading observation data');
fileObs=this.GenerateFileNames(dirObs);
if ~isempty(STCDOutlets)
    [~,this.indexOutlets]=ismember(STCDOutlets,this.STCD);
else
    this.indexOutlets=[];
end
for ip=1:this.nPeriods
    disp([num2str(ip),'/',num2str(this.nPeriods)]);
    iRunoff=this.noObserv*ones(round((this.endDate(ip)-this.warmupDate(ip))/this.timeStep),this.nSites);
    nValidate=round((this.endDate(ip)-this.warmupDate(ip))/this.timeStep);
    nWarmup=round((this.warmupDate(ip)-this.startDate(ip))/this.timeStep)+1;
    if any(this.indexOutlets==0)
        error('one or more information of outlets are not provided');
    end
    for i=1:this.nSites
        fileName=fileObs{i};
        formatSpec='%s %f';
        if isscalar(this.indexOutlets)
            if i==this.indexOutlets && exist(fileName,'file')~=2
                error('observation of outlets must be provided');
            end
        end
        switch eventMode
            case 'AllEvents'
                [sh,eh]=HydroSites.ReadFloodEvents(FEDB,this.STCD{i});
            case 'AnnualPeak'
                [~,~,sh,eh]=HydroSites.ReadFloodEvents(FEDB,this.STCD{i});
            otherwise
                disp(['complete hydrograph will be used at gauge ' this.STCD{i}, '.']);
        end
        if exist(fileName,'file')==2
            % jump the head
            fid=fopen(fileName);
            head=textscan(fid,'%s',1);
            raw=textscan(fid,formatSpec,'Delimiter',',');
            fclose(fid);
            if isnumeric(raw{1}(1))
%                         obsDateTimeStr=cell2mat(raw(2:end,1));
                obsDateTimeStr=num2str(raw{1});
            elseif ischar(raw{1}{1})
                obsDateTimeStr=char(raw{1});
            end
            if isempty(obsFormat)
                obsDateTime=datenum(obsDateTimeStr);
            else
                obsDateTime=datenum(obsDateTimeStr,obsFormat);
            end
            data=raw{2};
            clear raw
           
            indexObsInModel=(obsDateTime-this.warmupDate(ip))/this.timeStep;
            rIndexObsInModel=round(indexObsInModel);
            indexObsInModel=rIndexObsInModel.*...
                (abs(rIndexObsInModel-indexObsInModel)<1e-4)+...
                indexObsInModel.*(abs(rIndexObsInModel-indexObsInModel)>=1e-4);
            indexObs=(1:size(data,1))';
            indexInRange=logical((indexObsInModel>=1).*(indexObsInModel<=nValidate));
           %% set flow in non-flood period NaN
           if strcmpi(eventMode,'AllEvents') || strcmpi(eventMode,'AnnualPeak') 
                indexInFlood=false*ones(size(indexInRange,1),1);
                for ie=1:length(sh)
                    indexInFlood(obsDateTime>=sh(ie) & obsDateTime<=eh(ie))=true;
                end
                maskObs=indexInRange&indexInFlood;
           else
               maskObs=indexInRange;
           end
            iRunoff(indexObsInModel(maskObs),i)=data(indexObs(maskObs));
        end
    end
    if this.nPeriods==1 && this.warmupDate(ip)>this.startDate(ip)
        iRunoff=[this.noObserv*ones(nWarmup,this.nSites);iRunoff];
    end
    this.runoff=[this.runoff;iRunoff];
end
end