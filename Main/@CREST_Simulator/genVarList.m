function [varListInFile,varListInMem]=genVarList(this)
varListInFile={};
varListInMem={};
if this.globalVar.output_ExcS
    varListInFile{end+1}='excS';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.soilSurf.ExcS';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.excS';
    end
end
%     cmd=['save ' fileOutVar];
if this.globalVar.output_ExcI
    varListInFile{end+1}='excI';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.soilSurf.ExcI';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.excI';
    end
end
if this.globalVar.output_Rain
    varListInFile{end+1}='rain';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.rain';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.rain';
    end
end
if this.globalVar.output_SM
    varListInFile{end+1}='SM';
    if strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.SM';
    end
end

if this.globalVar.output_Snow
    varListInFile{end+1}='snow';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.snow';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.snow';
    end
end
if this.globalVar.output_EAct
    varListInFile{end+1}='EAct';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.EAct';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.EAct';
    end
end
if this.globalVar.output_SWE
    varListInFile{end+1}='SWE';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.snowpack.swqTotal';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.SWE';
    end
end
if this.globalVar.output_W
    varListInFile{end+1}='W';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='this.soilSurf.W';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.W0';
    end
end
if this.globalVar.output_intRain
    varListInFile{end+1}='intWater';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='intWater';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.intRain';
    end   
end
if this.globalVar.output_intSnow
    varListInFile{end+1}='intSnow';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='intSnow';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.intSnow';
    end
end
if this.globalVar.output_rainBare
    varListInFile{end+1}='rainBare';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='rainBare';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.rainBare';
    end
end
%/ modified
if this.globalVar.output_actTranspir
    varListInFile{end+1}='actTranspir';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='actTranspir';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.actTranspir';
    end
end
%/ modified
if this.globalVar.output_EPot
    varListInFile{end+1}='EPot';
    if strcmpi(this.globalVar.taskType,'LandSurf')
        varListInMem{end+1}='EPot';
    elseif strcmpi(this.globalVar.taskType,'Mosaic')
        varListInMem{end+1}='this.stateVar.EPot';
    end
end